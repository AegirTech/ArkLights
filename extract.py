#!/usr/bin/env python
import itertools
import json
import os
import re
import subprocess
from collections import defaultdict
from pathlib import Path

import fire
import requests


# 请使用720p图像计算


def unpack(source_folder="arknights", destination_folder="arknights_extract"):
    import UnityPy

    for root, dirs, files in os.walk(source_folder):
        for file_name in files:
            file_path = os.path.join(root, file_name)
            env = UnityPy.load(file_path)
            for path, obj in env.container.items():
                dest = os.path.join(destination_folder, *path.split("/"))
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                dest, ext = os.path.splitext(dest)

                if obj.type.name in ["Texture2D", "Sprite"]:
                    data = obj.read()
                    dest = dest + ".png"
                    data.image.save(dest)
                elif obj.type.name == "TextAsset":
                    data = obj.read()
                    dest = dest + ".txt"
                    with open(dest, "wb") as f:
                        f.write(bytes(data.script))
                elif obj.type.name == "MonoBehaviour":
                    if obj.serialized_type.nodes:
                        tree = obj.read_typetree()
                        dest = dest + ".json"
                        with open(dest, "wt", encoding="utf8") as f:
                            json.dump(tree, f, ensure_ascii=False, indent=4)
                    else:
                        data = obj.read()
                        dest = dest + ".bin"
                        with open(dest, "wb") as f:
                            f.write(data.raw_data)


def decrypt(src):
    from Crypto.Cipher import AES
    from Crypto.Util.Padding import unpad

    # pip install pycryptodome
    # base on https://github.com/InfiniteTsukuyomi/PyAutoGame
    # base on https://github.com/Rhine-Department-0xf/Rhine-DFramwork/blob/main/client/encryption.py
    # follow https://blog.hoshi.tech/archives/70/
    # TODO
    CHAT_MASK = ""
    key = bytearray(CHAT_MASK[:16].encode())
    mask = bytearray(CHAT_MASK[16:].encode())
    iv = bytearray(16)

    def decrypt_text_asset(data):
        for i in range(16):
            iv[i] = data[i] ^ mask[i]
        aes = AES.new(key, AES.MODE_CBC, iv)
        data = aes.decrypt(data[16:])
        data = unpad(data, AES.block_size)
        return data

    for x in Path(src).glob("*.txt"):
        x = open(x, "wb")
        x.write(decrypt_text_asset(x.read()))


def test():
    x = "ArknightsGameData/zh_CN/gamedata/levels/activities/act16side/level_act16side_08.json"
    x = json.loads(open(x).read())
    x0 = x
    x = x0["mapData"]
    m = len(x["map"])
    n = len(x["map"][0])
    print("m,n", m, n)

    ans = [[""] * n for i in range(m)]
    for i, t in enumerate(x["tiles"]):
        y = i % n
        x = i // n
        # print("x,y", x, y)
        if x == 0:
            ans[x][y] = "\n"
        type = t["tileKey"]
        if type == "tile_forbidden":
            ans[x][y] = "x"
        elif type == "tile_start":
            ans[x][y] = "s"
        elif type == "tile_end":
            ans[x][y] = "e"
        elif type == "tile_floor":
            ans[x][y] = "f"
        elif type == "tile_telin":
            ans[x][y] = "i"
        elif type == "tile_telout":
            ans[x][y] = "o"
        elif type == "tile_wall":
            ans[x][y] = "w"
        elif type == "tile_wall":
            ans[x][y] = "w"
        elif type == "tile_road":
            ans[x][y] = " "
        else:
            ans[x][y] = type

    x = x0["predefines"]["tokenInsts"]
    for t in x:
        x, y = t["position"]["row"], t["position"]["col"]
        print("x,y", x, y)

        ans[x][y] = "b"

    ans = "\n".join("".join(x) for x in reversed(ans))
    print(ans)


def avator2operator(src="ArknightsGameData/zh_CN/gamedata/excel/character_table.json"):
    data = json.loads(open(src).read())
    png = Path("png_noalpha").glob("char_*")
    ans = {}
    for p in png:
        # print("p",p)
        try:
            o = next(k for k in data if p.stem.startswith(k))
            ans[str(p.stem)] = data[o]["name"]
        except Exception:
            print("not found", p)

    return json.dumps(ans, ensure_ascii=False)


# https://github.com/yuanyan3060/ArknightsGameResource 使用此解包仓库
def skillicon2operator():
    import zipfile

    char = None
    build = None
    resp = requests.get(
        "https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/zh_CN/gamedata/excel/character_table.json"
    )
    if resp.status_code == 200:
        char = json.loads(resp.text)
    resp = requests.get(
        "https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/zh_CN/gamedata/excel/building_data.json"
    )
    if resp.status_code == 200:
        build = json.loads(resp.text)
    if not char or not build:
        return "get data failed"
    char2name = {k: char[k]["name"] for k in char}
    buffid2name = {}
    for c, b in build["buffs"].items():
        buffid2name[b["buffId"]] = b["skillIcon"]

    ans = defaultdict(list)
    for c, b in build["chars"].items():
        for b1 in b["buffChar"]:
            for b2 in b1["buffData"]:
                buffid = b2["buffId"]
                buffname = buffid2name[buffid]
                buffname = buffname.lower()
                operator = char2name[c]
                phase = (b2["cond"]["phase"])[-1]
                ans[buffname].append(operator + str(phase))

    # 定义输出目录：当前工作目录下的 ArknightsGameResource/new
    output_folder = os.path.join(os.getcwd(), "ArknightsGameResource/new")
    # 定义最终的输出文件路径
    file_name = os.path.join(output_folder, "skillicon2operator.json")

    # 判断目录是否存在，不存在则递归创建（包括多级目录）
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    with open(file_name, "w", encoding="utf-8") as f:
        json.dump(ans, f, ensure_ascii=False)

    zip_file_path = os.path.join(os.path.dirname(output_folder), "skill.zip")
    # 创建并写入压缩包
    with zipfile.ZipFile(zip_file_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(output_folder):
            for file in files:
                file_full_path = os.path.join(root, file)
                file_arcname = os.path.relpath(
                    file_full_path, start=output_folder
                )
                zipf.write(file_full_path, file_arcname)

    return "skillicon2operator done && skill.zip created success"
    # return json.dumps(ans, ensure_ascii=False)


def recruit(
    to="lua",
):
    char = None
    gacha = None
    resp = requests.get(
        "https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/zh_CN/gamedata/excel/character_table.json"
    )
    if resp.status_code == 200:
        char = json.loads(resp.text)
    resp = requests.get(
        "https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/zh_CN/gamedata/excel/gacha_table.json"
    )
    if resp.status_code == 200:
        gacha = json.loads(resp.text)
    if not char or not gacha:
        return "get data failed"
    tag = [x["tagName"] for x in gacha["gachaTags"] if x["tagId"] < 100]

    recruit_char = gacha["recruitDetail"]
    recruit_char = re.sub(r"<[^>]+>", "", recruit_char, 0)
    recruit_char = re.findall(r"\\n(.*)", recruit_char)
    recruit_char = set(y.strip() for x in recruit_char for y in x.split("/"))
    print(recruit_char)

    # 排除非公招干员
    char = {k: v for k, v in char.items() if v["name"] in recruit_char}

    # 排除6星干员，没有高级资深一定不出6星，没有资深可能出5星
    char = {k: v for k, v in char.items() if int(v["rarity"][-1]) < 6}

    # 排除12星干员，拉满9小时最低3星
    char = {k: v for k, v in char.items() if int(v["rarity"][-1]) >= 3}

    profession2tag = defaultdict(
        lambda: "???",
        {
            "CASTER": "术师干员",
            "MEDIC": "医疗干员",
            "PIONEER": "先锋干员",
            "SNIPER": "狙击干员",
            "SPECIAL": "特种干员",
            "SUPPORT": "辅助干员",
            "TANK": "重装干员",
            "WARRIOR": "近卫干员",
        },
    )
    position2tag = defaultdict(
        lambda: "???",
        {
            "MELEE": "近战位",
            "RANGED": "远程位",
        },
    )
    star2tag = defaultdict(
        lambda: "",
        {
            5: "资深干员",
            6: "高级资深干员",
            1: "支援机械",
        },
    )
    char2tag = {
        v["name"]: list(
            filter(
                None,
                [
                    *v["tagList"],
                    profession2tag[v["profession"]],
                    # star2tag[v["rarity"] + 1],
                    position2tag[v["position"]],
                ],
            )
        )
        for k, v in char.items()
    }

    char2star = {v["name"]: int(v["rarity"][-1]) for k, v in char.items()}
    tag2char = defaultdict(set)
    for c, t in char2tag.items():
        for t in t:
            tag2char[t].add(c)

    # tag2star = defaultdict(float)
    goodtag = []
    stuff = [1, 2, 3]
    min_star = 4
    # max_star = 5
    # stop_combination = []

    for num in range(1, 7):
        for t in itertools.combinations(tag, num):
            # t = set(t)
            # if any(tt.issubset(t) for tt in stop_combination):
            #     continue
            c = set.intersection(*(tag2char[t] for t in t))
            if len(c) == 0:
                continue

            s1 = min(char2star[c] for c in c)
            if s1 < min_star:
                continue
            s2 = max(char2star[c] for c in c)
            s3 = sum(char2star[c] for c in c) / len(c)
            # 最低星 最高星 期望星 标签数
            s = s1 + s2 / 10 + s3 / 100 + (6 - len(t)) / 1000
            # tag2star[tuple(t)] = s
            goodtag.append([s, list(t), list(c)])
            # if s1 >= max_star:
            #     stop_combination.append(t)

    # 按分数排序
    goodtag = sorted(goodtag, reverse=True)

    # 去重
    visited = []
    oktag = []
    for t in goodtag:
        ts = set(t[1])
        if any(tt.issubset(ts) for tt in visited):
            continue
        visited.append(ts)
        oktag.append(t)
    goodtag = oktag

    # 格式化
    goodtag = [(x[1], int(x[0]), x[2]) for x in goodtag]

    # lua table
    # tag2star = {k: v for k, v in sorted(tag2star.items(), key=lambda x: -x[1])}
    # goodtag = json.dumps(goodtag, ensure_ascii=False)
    # print(tag2star)
    if to == "lua":
        goodtag = py2lua(goodtag)
    elif to == "rust":
        goodtag = py2rust(goodtag)
    elif to == "json":
        goodtag = json.dumps(goodtag, ensure_ascii=False)

    return goodtag


def py2lua(x):
    if type(x) is list or type(x) is tuple:
        ans = "{"
        for i, y in enumerate(x):
            ans += py2lua(y)
            if i < len(x) - 1:
                ans += ","
        ans += "}"
        return ans
    elif type(x) is int:
        return str(x)
    elif type(x) is str:
        return '"' + x + '"'


def py2rust(x):
    if type(x) is list:
        ans = "vec!["
        for i, y in enumerate(x):
            ans += py2rust(y)
            if i < len(x) - 1:
                ans += ","
        ans += "]"
        return ans
    if type(x) is tuple:
        ans = "("
        for i, y in enumerate(x):
            ans += py2rust(y)
            if i < len(x) - 1:
                ans += ","
        ans += ")"
        return ans
    elif type(x) is int:
        return str(x)
    elif type(x) is str:
        return '"' + x + '"'


def screencap(stem):
    stem = str(stem)
    screencap = Path("screencap")
    screencap.mkdir(exist_ok=True, parents=True)
    serial = "127.0.0.1:5555"
    subprocess.run(["adb", "connect", serial])
    subprocess.Popen(
        f"adb -s {serial} exec-out screencap -p > {screencap / stem}.jpg",
        shell=True,
    )


def get_level_info() -> list:
    response = requests.get(
        url="https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/zh_CN/gamedata"
        "/excel/story_review_table.json"
    )
    if response.status_code != 200:
        return []
    data = response.json()
    latest_act = max(data, key=lambda k: int(data[k]["startTime"]))
    latest_remakeact = max(data, key=lambda k: int(data[k]["remakeStartTime"]))
    if data[latest_remakeact]["remakeStartTime"] > data[latest_act]["startTime"]:
        latest_act = latest_remakeact
    response = requests.get(
        url="https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/zh_CN/gamedata"
        "/excel/stage_table.json"
    )
    if response.status_code != 200:
        return []
    data = response.json()["stages"]
    ret_list = []
    for k, v in data.items():
        if (
            (latest_act in k)
            and (story_code := v["code"])
            and (story_code not in ret_list)
        ):
            ret_list.append(story_code)
    # print(latest_act, ret_list)
    return ret_list


def screencap_distance2(path="screencap"):
    screencap = Path(path)
    import torch

    torch.backends.cudnn.enabled = False
    import easyocr

    reader = easyocr.Reader(["en", "ch_sim"])
    point = defaultdict(int)
    distance = defaultdict(int)
    online = True
    if online:
        all_list = get_level_info()
    else:
        all_list = [
            "HS-ST-1",
            "HS-1",
            "HS-TR-1",
            "HS-2",
            "HS-3",
            "HS-4",
            "HS-TR-2",
            "HS-5",
            "HS-ST-2",
            "HS-6",
            "HS-7",
            "HS-8",
            "HS-9",
            "HS-ST-3",
        ]
        # all_list = ["DH-S-1", "DH-S-2", "DH-S-3", "DH-S-4", "DH-MO-1"]
    print(all_list)

    # 滑动到最右边时 hd-1的x坐标相距屏幕中心的距离
    shift_right = -0
    distance[1] = 0
    # EX和S关大部分在同一页上 少数不在
    same_page = len(list(screencap.glob("*.png"))) == 1

    for x in sorted(screencap.glob("*.png")):
        x = reader.readtext(str(x))
        print("x", x)
        visible_point = defaultdict(int)
        for loc, text, confidence in x:
            text = text.replace(" G", "-6")
            text = text.replace("CI -2", "CW-2")
            text = text.replace("-G", "-6")
            text = text.replace("-g", "-9")
            text = text.replace("IIW", "IW")
            text = text.replace("IB", "WB")
            text = text.replace("I", "-1")
            text = text.replace("l", "-1")
            text = text.replace("- ", "-")
            text = text.replace(" ", "-")
            text = text.replace("B12", "BI-2")
            text = text.replace(" ", "")
            text = text.replace("00-", "OD-")
            text = text.replace("1C", "IC")
            # text = text.replace("ST-1", "")
            # text = text.replace("ST-2", "")
            # text = text.replace("ST-3", "")
            # text = text.replace("TR-1", "")
            # text = text.replace("EX", "")
            text = text.replace("--", "-")
            m = re.search(r"^.?.-(\d+)$", text)
            n = re.search(r"^.?.-.?.-(\d+)$", text)

            m = m or n
            if not m:
                continue
            if m.group(0) not in all_list:
                continue
            print("m", m)
            m = all_list.index(m.group(0)) + 1
            # m = int(m.group(1))
            visible_point[m] = loc[0][0]
            if point[m]:
                continue
            point[m] = loc[0]
        for m in sorted(visible_point):
            if m in distance:
                continue
            distance[m] = visible_point[m] - visible_point[m - 1] + distance[m - 1]
            print("m-1,distance[m-1]", m - 1, distance, visible_point)
        # print("visible_point", visible_point)
    # print("point", point)
    # print("distance", distance)

    for x in sorted(point):
        p = point[x]
        p = [x * 1080 // 720 for x in p]
        if not same_page:
            p[0] = 960 + shift_right * 1080 // 720
        # print(f'["HD-{x}"] = ' + "{" + str(p[0]) + "," + str(p[1]) + "},")
        print(
            f'["HD{all_list[x - 1][2:]}"] = ' + "{" + str(p[0]) + "," + str(p[1]) + "},"
        )

    # 距离膨胀系数，部分活动需要微调
    distanceExpansionCoefficient = 1.12
    for x in sorted(distance):
        p = distance[x] + shift_right
        p = int(p * distanceExpansionCoefficient)
        # 教程剧情关坐标修正
        if "TR" in all_list[x - 1] or "ST" in all_list[x - 1]:
            p = p + 15
        if p < 0:
            p = 0
        if same_page:
            print(f'["HD{all_list[x - 1][2:]}"] = ' + "{ swip_right_max, -0 },")
        else:
            print(
                f'["HD{all_list[x - 1][2:]}"] = '
                + "{ swip_right_max, -"
                + str(p)
                + "},"
            )
        # print(f'["HD-{x}"] = ' + "{ swip_right_max, -" + str(p) + "},")


def screencap_distance(path="screencap"):
    screencap = Path(path)
    import torch

    torch.backends.cudnn.enabled = False
    import easyocr

    reader = easyocr.Reader(["en", "ch_sim"])
    point = defaultdict(int)
    distance = defaultdict(int)
    shift_right = 0
    # 滑动到最右边时 hd-1的x坐标相距屏幕中心的距离
    distance[1] = 242
    for x in sorted(screencap.glob("*.png")):
        x = reader.readtext(str(x))
        print("x", x)
        visible_point = defaultdict(int)
        for loc, text, confidence in x:
            text = text.replace("16", "HD")
            text = text.replace(" G", "-6")
            text = text.replace("CI -2", "CW-2")
            text = text.replace("-G", "-6")
            text = text.replace("-g", "-9")
            text = text.replace("IIW", "IW")
            text = text.replace("IB", "WB")
            text = text.replace("I", "1")
            text = text.replace("l", "1")
            text = text.replace("- ", "-")
            text = text.replace(" ", "-")
            text = text.replace("B12", "BI-2")
            text = text.replace(" ", "")
            text = text.replace("1C", "IC")
            text = text.replace("ORG", "OR-6")
            text = text.replace("EX", "")
            text = text.replace("4", "-4")
            text = text.replace("1", "-1")
            text = text.replace("--", "-")
            text = text.replace("1-4", "14")
            text = text.replace("1-1", "11")
            text = text.replace("-HD", "-16")
            print("m0", text)
            m = re.search(r"^.?.-(\d+)$", text)
            print("m", m)
            if not m:
                continue
            print("m", m)
            m = int(m.group(1))
            visible_point[m] = loc[0][0]
            if point[m]:
                continue
            point[m] = loc[0]
        print(visible_point)
        for m in sorted(visible_point):
            if m in distance:
                continue
            distance[m] = visible_point[m] - visible_point[m - 1] + distance[m - 1]
            print("m-1,distance[m-1]", m - 1, distance, visible_point)
        # print("visible_point", visible_point)
    # print("point", point)
    # print("distance", distance)

    for x in sorted(point):
        p = point[x]
        p = [x * 1080 // 720 for x in p]
        p[0] = 960 + shift_right * 1080 // 720
        print(f'["HD-{x}"] = ' + "{" + str(p[0]) + "," + str(p[1]) + "},")

    # 距离膨胀系数，部分活动需要微调
    distanceExpansionCoefficient = 1.11
    for x in sorted(distance):
        p = distance[x] - shift_right
        p = int(p * distanceExpansionCoefficient)
        print(f'["HD-{x}"] = ' + "{ swip_right_max, -" + str(p) + "},")


def process_transparent_pixels(
    input_folder=os.path.join(os.getcwd(), "ArknightsGameResource/skill"),
    output_folder=os.path.join(os.getcwd(), "ArknightsGameResource/new"),
):
    # 用于处理技能图标背景
    import os
    import shutil
    from PIL import Image

    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    center_x, center_y = 18, 18  # 或者 19, 19 根据需要调整
    radius = 18.3
    for filename in os.listdir(input_folder):
        if "style" in filename:
            continue
        input_path = os.path.join(input_folder, filename)
        output_path = os.path.join(output_folder, filename.lower())
        if filename.endswith(".png"):
            image = Image.open(input_path).convert("RGBA")
            pixels = image.load()
            # 给图片叠加一个#3d3d3d的背景图层
            background_r, background_g, background_b = 61, 61, 61  # 背景色#3d3d3d
            # 遍历每个像素点
            for i in range(image.size[0]):
                for j in range(image.size[1]):
                    r, g, b, a = pixels[i, j]
                    # 如果像素是透明的或半透明的，则用背景色替换
                    if a < 255:
                        # 计算混合颜色
                        new_r = (a * r + (255 - a) * background_r) // 255
                        new_g = (a * g + (255 - a) * background_g) // 255
                        new_b = (a * b + (255 - a) * background_b) // 255
                        pixels[i, j] = (new_r, new_g, new_b, 255)  # 设置为不透明
            image.save(output_path)
        else:
            shutil.copy2(input_path, output_path)


def char2vue():
    char = None
    resp = requests.get(
        "https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/zh_CN/gamedata/excel/character_table.json"
    )
    if resp.status_code == 200:
        char = json.loads(resp.text)
    for k, v in char.items():
        if k.startswith("char_") and ("预备干员" not in v["name"]):
            print("{ value: '" + v["name"] + "', label: '" + v["name"] + "' },")


if __name__ == "__main__":
    fire.Fire()
