#!/usr/bin/env python
import io
import itertools
import json
import os
import re
import subprocess
import tempfile
from collections import defaultdict
from pathlib import Path

import fire


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
    from Crypto.Util.Padding import pad, unpad

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
def skillicon2operator(
    char=os.path.join(
        os.getcwd(), "ArknightsGameResource/gamedata/excel/character_table.json"
    ),
    build=os.path.join(
        os.getcwd(), "ArknightsGameResource/gamedata/excel/building_data.json"
    ),
):
    char = json.loads(open(char, encoding="utf-8").read())
    build = json.loads(open(build, encoding="utf-8").read())

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
                operator = char2name[c]
                phase = (b2["cond"]["phase"])[-1]
                ans[buffname].append(operator + str(phase))

    return json.dumps(ans, ensure_ascii=False)


def recruit(
    char=os.path.join(
        os.getcwd(), "ArknightsGameResource/gamedata/excel/character_table.json"
    ),
    gacha=os.path.join(
        os.getcwd(), "ArknightsGameResource/gamedata/excel/gacha_table.json"
    ),
    to="lua",
):
    char = json.loads(open(char, encoding="utf-8").read())
    gacha = json.loads(open(gacha, encoding="utf-8").read())
    tag = [x["tagName"] for x in gacha["gachaTags"] if x["tagId"] < 100]

    recruit_char = gacha["recruitDetail"]
    recruit_char = re.sub(r"<[^>]+>", "", recruit_char, 0)
    recruit_char = re.findall(r"\\n(.*)", recruit_char)
    recruit_char = set(y.strip() for x in recruit_char for y in x.split("/"))
    print(recruit_char)

    # 排除非公招干员
    char = {k: v for k, v in char.items() if v["name"] in recruit_char}

    # 排除6星干员，没有高级资深一定不出6星，没有资深可能出5星
    char = {k: v for k, v in char.items() if v["rarity"] + 1 < 6}

    # 排除12星干员，拉满9小时最低3星
    char = {k: v for k, v in char.items() if v["rarity"] + 1 >= 3}

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

    char2star = {v["name"]: v["rarity"] + 1 for k, v in char.items()}
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


def screencap_distance(path="screencap"):
    screencap = Path(path)
    import torch

    torch.backends.cudnn.enabled = False
    import easyocr
    from PIL import Image

    reader = easyocr.Reader(["en", "ch_sim"])
    point = defaultdict(int)
    distance = defaultdict(int)
    shift_right = 0
    # 滑动到最右边时 hd-1的x坐标相距屏幕中心的距离
    distance[1] = -260
    for x in sorted(screencap.glob("*.jpg")):
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
            text = text.replace("I", "1")
            text = text.replace("l", "1")
            text = text.replace("- ", "-")
            text = text.replace(" ", "-")
            text = text.replace("B12", "BI-2")
            text = text.replace(" ", "")
            text = text.replace("1C", "IC")
            text = text.replace("EX", "")
            text = text.replace("--", "-")
            m = re.search("^.?.-(\d+)$", text)
            print("m", m)
            if not m:
                continue
            print("m", m)
            m = int(m.group(1))
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
        p[0] = 960 + shift_right * 1080 // 720
        print(f'["HD-{x}"] = ' + "{" + str(p[0]) + "," + str(p[1]) + "},")

    # 距离膨胀系数，部分活动需要微调
    distanceExpansionCoefficient = 1.10
    for x in sorted(distance):
        p = distance[x] - shift_right
        p = int(p * distanceExpansionCoefficient)
        print(f'["HD-{x}"] = ' + "{ swip_right_max, -" + str(p) + "},")


def process_transparent_pixels(
    input_folder=os.path.join(os.getcwd(), "ArknightsGameResource/skill"),
    output_folder=os.path.join(os.getcwd(), "ArknightsGameResource/skill_new"),
):
    # 用于处理技能图标背景 不知道为什么透明背景识别失败
    import os
    import shutil
    from PIL import Image

    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    for filename in os.listdir(input_folder):
        input_path = os.path.join(input_folder, filename)
        output_path = os.path.join(output_folder, filename)
        if filename.endswith(".png"):
            image = Image.open(input_path).convert("RGBA")
            pixels = image.load()
            for i in range(image.width):
                for j in range(image.height):
                    r, g, b, a = pixels[i, j]
                    if a == 0:
                        pixels[i, j] = (61, 61, 61, 255)
            image.save(output_path)
        else:
            shutil.copy2(input_path, output_path)


if __name__ == "__main__":
    fire.Fire()
