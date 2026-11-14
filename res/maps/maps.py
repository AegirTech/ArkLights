# -*- coding: utf-8 -*-
"""明日方舟地图包生成与发布脚本（GitHub Action 每日调用）

从 Arknights-Bot-Resource 在线拉取 levels.json，计算 1920x1080 分辨率下
各关卡格子屏幕坐标，在内存中打包输出到 res/maps.zip（附加 version.json 作为
地图包版本号），随后调用 0.py rm 发布地图包（热更新 CDN + 新加坡服务器）。

运行方法：
    python res/maps/maps.py                # 生成并发布
    python res/maps/maps.py --no-upload    # 仅生成，不发布

依赖：numpy、requests（见 requirements.txt）
"""
import io
import json
import math
import os
import pathlib
import subprocess
import sys
import zipfile
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import List, Optional, Tuple

import numpy as np
import requests

# Windows 文件名非法字符替换（用于压缩包内文件名）
def sanitize_filename(name: str) -> str:
    invalid_chars = '<>:"/\\|?*'
    for ch in invalid_chars:
        name = name.replace(ch, '_')
    return name


def map_name(data: dict) -> Optional[str]:
    """返回去掉前缀制表符的地图名，没有地图名时返回 None"""
    name = data["name"]
    if name is not None and name.startswith("\t"):
        name = name.lstrip("\t")
    return name


def map_filenames(data: dict, name: Optional[str]) -> List[str]:
    """关卡写入压缩包的文件名：地图名/地图代号/stageId，并去重"""
    filenames = []
    if name is not None:
        filenames.append(sanitize_filename(name) + ".json")
    if data["code"]:
        filenames.append(sanitize_filename(data["code"]) + ".json")
    filenames.append(data["stageId"] + ".json")
    return list(dict.fromkeys(filenames))


# 定义全局变量
height_type_map = {
    "LOWLAND": 0,
    "HIGHLAND": 1,
}

buildable_type_map = {
    "NONE": 0,
    "MELEE": 1,
    "RANGED": 2,
    "ALL": 3,
}


@dataclass
class Tile:
    heightType: int
    buildableType: int

    @classmethod
    def from_json(cls, json_data: dict) -> "Tile":
        # 将字符串类型映射为数字类型
        height_type = height_type_map.get(json_data["heightType"], 0)
        buildable_type = buildable_type_map.get(json_data["buildableType"], 0)
        return cls(heightType=height_type, buildableType=buildable_type)


@dataclass
class Level:
    stageId: str
    code: str
    levelId: str
    name: str
    height: int = 0
    width: int = 0
    tiles: List[List[Tile]] = None
    view: List[List[int]] = None

    @classmethod
    def from_json(cls, json_data: dict) -> "Level":
        raw_tiles = json_data["tiles"]
        tiles = []
        for row in raw_tiles:
            row_tiles = []
            for tile in row:
                row_tiles.append(Tile.from_json(tile))
            tiles.append(row_tiles)

        return cls(
            stageId=json_data["stageId"],
            code=json_data["code"],
            levelId=json_data["levelId"],
            name=json_data["name"],
            height=json_data["height"],
            width=json_data["width"],
            tiles=tiles,
            view=json_data["view"],
        )

    def get_width(self):
        return self.width

    def get_height(self):
        return self.height

    def get_tile(self, row: int, col: int) -> Optional[Tile]:
        if 0 <= row <= self.height and 0 <= col <= self.width:
            return self.tiles[row][col]
        return None


class Calc:
    width: int
    height: int
    ratio: float
    matrix_p: np.array = None

    def __init__(self, width: Optional[int], height: Optional[int]):
        if width is not None and height is not None:
            self.init(width, height)

    def init(self, width: int, height: int):
        self.width = width
        self.height = height
        self.ratio = height / width
        self.matrix_p = np.array(
            [
                [self.ratio / math.tan(math.pi * 20 / 180), 0, 0, 0],
                [0, 1 / math.tan(math.pi * 20 / 180), 0, 0],
                [0, 0, -(1000 + 0.3) / (1000 - 0.3), -(1000 * 0.3 * 2) / (1000 - 0.3)],
                [0, 0, -1, 0],
            ]
        )

    def adapter(self) -> Tuple[float, float]:
        fromRatio = 9 / 16
        toRatio = 3 / 4
        if self.ratio < fromRatio - 0.00001:
            return 0, 0

        t = (self.ratio - fromRatio) / (toRatio - fromRatio)

        return -1.4 * t, -2.8 * t

    def run(
        self, code: str = "", name: str = "", side: bool = False
    ) -> List[List[Tuple[int, int]]]:
        """
        :param code: 关卡代号 例如:0-1 1-7
        :param name: 关卡名称 例如:与虫为伴 code和name中选填一个，一般情况code更方便，但是肉鸽关卡不能用code确定
        :param side: 是否是放置干员时的视角
        :return: 格子坐标构成的列表
        """
        result: List[List[Tuple[int, int]]] = []
        level = None
        for item in levels:
            if code == item.code or name == item.name:
                level = item
        if level is None:
            return []
        if side:
            x, y, z = level.view[1]
        else:
            x, y, z = level.view[0]
        adapter_y, adapter_z = self.adapter()
        y += adapter_y
        z += adapter_z
        raw = np.array(
            [
                [1, 0, 0, -x],
                [0, 1, 0, -y],
                [0, 0, 1, -z],
                [0, 0, 0, 1],
            ]
        )
        matrix_x = np.array(
            [
                [1, 0, 0, 0],
                [0, math.cos(math.pi * 30 / 180), -math.sin(math.pi * 30 / 180), 0],
                [0, -math.sin(math.pi * 30 / 180), -math.cos(math.pi * 30 / 180), 0],
                [0, 0, 0, 1],
            ]
        )
        matrix_y = np.array(
            [
                [math.cos(math.pi * 10 / 180), 0, math.sin(math.pi * 10 / 180), 0],
                [0, 1, 0, 0],
                [-math.sin(math.pi * 10 / 180), 0, math.cos(math.pi * 10 / 180), 0],
                [0, 0, 0, 1],
            ]
        )

        if side:
            matrix = np.dot(matrix_x, matrix_y)
            matrix = np.dot(matrix, raw)
        else:
            matrix = np.dot(matrix_x, raw)
        matrix = np.dot(self.matrix_p, matrix)
        h = level.get_height()
        w = level.get_width()
        for y in range(h):
            tmp: List[Tuple[int, int]] = []
            for x in range(w):
                tile = level.get_tile(y, x)
                if tile is None:
                    continue

                # 计算坐标
                p_x, p_y, p_z, p_w = np.dot(
                    matrix,
                    np.array(
                        [
                            (x - (w - 1) / 2),
                            ((h - 1) / 2) - y,
                            tile.heightType * -0.4,
                            1,
                        ]
                    ),
                )
                p_x = (1 + p_x / p_w) / 2
                p_y = (1 + p_y / p_w) / 2
                center = int(p_x * self.width), int((1 - p_y) * self.height)
                tmp.append((center))
            result.append(tmp)
        return result


url = "https://raw.githubusercontent.com/yuanyan3060/Arknights-Bot-Resource/main/levels.json"
# 输出到 res/maps.zip
zip_path = pathlib.Path(__file__).resolve().parent.parent / "maps.zip"
execpath = pathlib.Path(__file__).resolve().parent.parent.parent
# levels.json 与 ArknightsGameResource 子模块根目录同源(同一 blob)，优先读子模块，缺失时回退在线拉取
submodule_levels = (
    pathlib.Path(__file__).resolve().parent.parent / "ArknightsGameResource" / "levels.json"
)


def load_levels():
    """优先读取子模块中的 levels.json，缺失时回退在线拉取，失败返回 None"""
    if submodule_levels.is_file():
        print(f"使用子模块 levels.json: {submodule_levels}")
        return json.loads(submodule_levels.read_text(encoding="utf-8"))
    print(f"子模块缺失，回退在线获取: {url}")
    response = requests.get(url, timeout=60)
    if response.status_code != 200:
        print("无法获取数据。错误代码:", response.status_code)
        return None
    return json.loads(response.text)

levels: List[Level] = []


def fill_maps_zip(zf: zipfile.ZipFile, level_table: list, calc: Calc) -> int:
    """向已打开的压缩包写入全部关卡坐标，返回处理的地图数量，不落盘中间 json"""
    levels.clear()
    # 地图名/地图代号会大量重名（例如肉鸽同布局的普通/紧急关卡），解压时后写覆盖先写。
    # 先算出每个文件名由最后一条关卡拥有，保证压缩包内没有重复条目。
    owners = {}
    for idx, data in enumerate(level_table):
        for filename in map_filenames(data, map_name(data)):
            owners[filename] = idx

    count = 0
    for idx, data in enumerate(level_table):
        levels.append(Level.from_json(data))
        name = map_name(data)
        maptype = 1
        if data["stageId"].startswith("camp"):
            maptype = 2  # 剿灭
        elif data["stageId"].startswith("lt"):
            maptype = 3  # 保全
        elif "roguelike" in data["levelId"]:
            maptype = 4  # 肉鸽
        elif data["stageId"].startswith("mem"):
            maptype = 5  # 悖论模拟
        elif "multi" in data["stageId"]:
            maptype = 6  # 促融共竞
        trainmap = 1 if data["code"] and "TR-" in data["code"] else 0
        coordinate = [
            calc.run(code=data["code"], name=name, side=False),
            calc.run(code=data["code"], name=name, side=True),
            maptype,
            trainmap,
        ]
        # 同一份坐标按 地图名/地图代号/stageId 三种文件名写入压缩包；
        # 少数关卡（新手引导、自走棋）没有地图名或代号，退化为只按 stageId 写入
        content = json.dumps(
            coordinate, sort_keys=True, indent=4, separators=(",", ": ")
        )
        for filename in map_filenames(data, name):
            if owners[filename] == idx:
                zf.writestr(filename, content)
        count += 1
        if count % 100 == 0:
            print(f"已处理 {count} 张地图")
    return count


def generate() -> None:
    level_table = load_levels()
    if level_table is None:
        return

    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as zf:
        count = fill_maps_zip(zf, level_table, Calc(1920, 1080))
        # 写入当前时间(东八区)作为地图包版本号，Lua 侧解压后读取展示
        now = datetime.now(timezone(timedelta(hours=8)))
        zf.writestr("version.json", now.strftime("%Y-%m-%d %H:%M:%S"))

    zip_path.write_bytes(buf.getvalue())
    print(f"地图坐标生成完毕，共 {count} 张地图，压缩包路径：{zip_path}")


def upload() -> None:
    # cwd 固定到仓库根目录，保证 0.py 能找到 main.lua 与 res/maps.zip
    subprocess.run([sys.executable, os.path.join(execpath, "0.py"), "rm"], cwd=execpath)
    print("文件上传完成")


if __name__ == "__main__":
    generate()
    if "--no-upload" in sys.argv:
        print("已跳过发布")
    else:
        upload()
