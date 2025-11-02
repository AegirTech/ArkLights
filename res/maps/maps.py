# https://raw.githubusercontent.com/yuanyan3060/Arknights-Bot-Resource/main/levels.json
import os
from typing import List, Optional, Tuple
from dataclasses import dataclass
import json
import pathlib
import math
import zipfile
import glob

import numpy as np

import requests

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
        # 使用全局变量
        height_type = height_type_map.get(json_data["heightType"], 0)
        buildable_type = buildable_type_map.get(json_data["buildableType"], 0)
        return cls(heightType=height_type, buildableType=buildable_type)


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
    ) -> List[List[Tuple[Tile, Tuple[int, int]]]]:
        """
        :param code: 关卡代号 例如:0-1 1-7
        :param name: 关卡名称 例如:与虫为伴 code和name中选填一个，一般情况code更方便，但是肉鸽关卡不能用code确定
        :param side: 是否是放置干员时的视角
        :return: Tile和坐标构成的列表
        """
        result: List[List[Tuple[Tile, Tuple[int, int]]]] = []
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
            tmp: List[Tuple[Tile, Tuple[int, int]]] = []
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
                # print(x,y,center)
            result.append(tmp)
        return result


levels_path = pathlib.Path(__file__).parent.parent / "levels.json"
map_path = pathlib.Path(__file__).parent / "maps"
map_path.mkdir(parents=True, exist_ok=True)

url = "https://raw.githubusercontent.com/yuanyan3060/Arknights-Bot-Resource/main/levels.json"
levels: List[Level] = []
calc = Calc(1920, 1080)

response = requests.get(url)
if response.status_code == 200:
    level_table = json.loads(response.text)
    for data in level_table:
        # print(data["name"], data["code"], data["stageId"])
        levels.append(Level.from_json(data))
        if data["name"] == None:
            continue
        elif data["name"].startswith("\t"):
            data["name"] = data["name"].lstrip("\t")
            # print(data["name"], data["code"])
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
        trainmap = 0
        if "TR-" in data["code"]:
            trainmap = 1
        coordinate = [
            calc.run(code=data["code"], name=data["name"], side=False),
            calc.run(code=data["code"], name=data["name"], side=True),
            maptype,
            trainmap,
        ]
        # print (coordinate)

        fw = open(
            map_path / (data["name"] + ".json"), "w", encoding="UTF-8"
        )  # 按地图名+保存坐标到txt
        fw.write(
            json.dumps(coordinate, sort_keys=True, indent=4, separators=(",", ": "))
        )  # 将字符串写入文件中

        fw = open(
            map_path / (data["code"] + ".json"), "w", encoding="UTF-8"
        )  # 按地图代号+保存坐标到txt
        fw.write(
            json.dumps(coordinate, sort_keys=True, indent=4, separators=(",", ": "))
        )  # 将字符串写入文件中

        fw = open(
            map_path / (data["stageId"] + ".json"), "w", encoding="UTF-8"
        )  # 按地图代号+保存坐标到txt
        fw.write(
            json.dumps(coordinate, sort_keys=True, indent=4, separators=(",", ": "))
        )  # 将字符串写入文件中
else:
    print("无法获取数据。错误代码:", response.status_code)

"""
with open(levels_path, encoding="UTF-8") as fp:
    level_table = json.load(fp)    
    for data in level_table:
        print(data["name"], data["code"], data["stageId"])
        levels.append(Level.from_json(data))
        if data["name"] == None:
            continue
        elif data["name"].startswith('\t'):
            data["name"] = data["name"].lstrip('\t')
            # print(data["name"], data["code"])
        maptype = 1
        if data["stageId"].startswith('camp'):
            maptype = 2  # 剿灭
        elif data["stageId"].startswith('lt'):
            maptype = 3  # 保全            
        elif "roguelike" in data["levelId"]:
            maptype = 4  # 肉鸽
        elif data["stageId"].startswith('mem'):
            maptype = 5  # 悖论模拟
        trainmap = 0
        if "TR-" in data["code"]:
            trainmap = 1
        coordinate = [calc.run(code=data["code"], name=data["name"], side=False),
                      calc.run(code=data["code"], name=data["name"], side=True), maptype, trainmap]
        # print (coordinate)

        fw = open(map_path / (data["name"] + ".json"), 'w', encoding="UTF-8")  # 按地图名+保存坐标到txt
        fw.write(json.dumps(coordinate, sort_keys=True, indent=4, separators=(',', ': ')))  # 将字符串写入文件中

        fw = open(map_path / (data["code"] + ".json"), 'w', encoding="UTF-8")  # 按地图代号+保存坐标到txt
        fw.write(json.dumps(coordinate, sort_keys=True, indent=4, separators=(',', ': ')))  # 将字符串写入文件中

        fw = open(map_path / (data["stageId"] + ".json"), 'w', encoding="UTF-8")  # 按地图代号+保存坐标到txt
        fw.write(json.dumps(coordinate, sort_keys=True, indent=4, separators=(',', ': ')))  # 将字符串写入文件中
"""


# 将json文件压缩到maps.zip用于添加到速通资源
def zip_files(file_folder, output_path):
    zipf = zipfile.ZipFile(output_path, "w", zipfile.ZIP_DEFLATED)
    files = glob.glob(str(file_folder / "*.json"))
    for file in files:
        zipf.write(file, arcname=pathlib.Path(file).name)
    zipf.close()


# 写入当前时间 到 version文件中
with open(map_path / "version.json", "w", encoding="UTF-8") as vf:
    from datetime import datetime

    now = datetime.now()
    vf.write(now.strftime("%Y-%m-%d %H:%M:%S"))


zip_files(map_path, map_path.parent.parent / "maps.zip")

output_path = os.path.join(map_path.parent.parent, "maps.zip")

"""
if __name__ == "__main__":
    calc = Calc(1920, 1080)#屏幕分辨率
    code = "CE-6"    
    print( json.dumps(calc.run(code, side=False)))    
    print( json.dumps(calc.run(code, side=True))) 
"""
