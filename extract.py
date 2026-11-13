#!/usr/bin/env python
import itertools
import json
import os
import re
import subprocess
import sys
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


def screencap(stem, serial="127.0.0.1:5555"):
    """抓取设备截图并缩放到720p（screencap_distance2 基于720p图像计算）"""
    stem = str(stem)
    screencap = Path("screencap")
    screencap.mkdir(exist_ok=True, parents=True)
    if ":" in serial:
        subprocess.run(["adb", "connect", serial], capture_output=True)
    raw = screencap / f"{stem}.raw.png"
    with open(raw, "wb") as f:
        subprocess.run(["adb", "-s", serial, "exec-out", "screencap", "-p"], stdout=f)
    from PIL import Image

    im = Image.open(raw).convert("RGB")
    if im.height != 720:
        im = im.resize((1280, 720))
    im.save(screencap / f"{stem}.png")
    raw.unlink()


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


def is_hex_stage(name):
    """剧情关/教学关/特殊关用蓝色六边形比色点代替点击坐标"""
    return any(s in name for s in ("-ST-", "TR-", "-P-", "-MO-"))


def is_single_page_stage(name):
    """EX/S/MO 关通常单独成页，默认不滑动，直接使用当前页坐标且不输出 distance"""
    return any(s in name for s in ("-EX-", "-S-", "-MO-"))


def stage_key(name, prefix="HD"):
    """把关卡代号的活动前缀换成 prefix，如 TL-ST-1 -> HD-ST-1"""
    if not prefix:
        return name
    _, sep, rest = name.partition("-")
    return prefix + sep + rest if sep else name


def lua_strip_comment(line):
    """去掉Lua行内注释，字符串里的--保留"""
    out = []
    quote = None
    for i, c in enumerate(line):
        if quote:
            out.append(c)
            if c == quote:
                quote = None
        elif c in "\"'":
            quote = c
            out.append(c)
        elif line[i:i + 2] == "--":
            break
        else:
            out.append(c)
    return "".join(out)


def lua_num(field):
    """字段转数字，支持 1920 - 1 这类纯算术表达式，非数字返回 None"""
    field = field.strip()
    if re.fullmatch(r"[\d\s+\-*/().]+", field) and re.search(r"\d", field):
        try:
            return float(eval(field))  # 字符已白名单为纯算术
        except Exception:
            return None
    return None


def numpad_cell(x, y):
    """1920x1080基线坐标 -> 所在九宫格区域（行*3+列），按三等分"""
    col = 0 if x < 1920 / 3 else (1 if x < 1920 * 2 / 3 else 2)
    row = 0 if y < 1080 / 3 else (1 if y < 1080 * 2 / 3 else 2)
    return row * 3 + col


def numpad(points):
    """点组的小键盘1-9区域（1=左下 9=右上）。

    按点组主要分布在哪个区域投票决定，第一个点计算两次，平票取第一个点所在区域。
    """
    cells = [numpad_cell(x, y) for x, y in points]
    votes = defaultdict(int)
    for c in cells:
        votes[c] += 1
    votes[cells[0]] += 1  # 第一个点计算两次
    first = cells[0]
    return "789456123"[max(votes, key=lambda c: (votes[c], c == first))]


def parse_point_values(value):
    """从Lua条目值里取出代表坐标组 -> [(x, y), ...]。

    点位（多点找色字符串/嵌套坐标对）取全部点；范围（纯数字table）取中心位置。
    """
    pairs = re.findall(r"(\d+)\|(\d+)\|", value)
    if pairs:
        return [(float(a), float(b)) for a, b in pairs]
    v = value.strip()
    if not (v.startswith("{") and v.endswith("}")):
        return None
    if v.count("{") > 1:  # 嵌套table（如 { {x,y}, ... }）取全部点
        pairs = re.findall(r"\{\s*(-?\d+)\s*,\s*(-?\d+)\s*\}", v)
        return [(float(a), float(b)) for a, b in pairs] if pairs else None
    nums = [lua_num(f) for f in v[1:-1].split(",") if f.strip()]
    if not nums or any(n is None for n in nums):
        return None
    if len(nums) == 2:  # 坐标对
        return [(nums[0], nums[1])]
    if len(nums) % 2 == 0:  # 范围 { x1,y1,x2,y2 } 取中心
        xs, ys = nums[0::2], nums[1::2]
        return [((min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2)]
    return None


def auto_center(path="point.lua", write=True, refresh=False, modes=None):
    """根据 point 中点位/范围的分布自动补齐 center 表的小键盘1-9定位。

    点位（多点找色字符串/坐标对）按点组主要分布区域投票，第一个点计算两次；
    范围（纯数字table）看中心位置；坐标落在1920x1080基线九宫格的哪一格，
    center 就补哪个数（1=左下 2=下 3=右下 4=左 5=中 6=右 7=左上 8=上 9=右上）。
    缩放模式（"maxscale"/"maxscalex"/"anisotropy"）反映目标屏幕如何渲染该界面，
    无法从点位几何推断，需通过 modes={键名: 模式} 传入，对应条目生成
    { 数字, "模式" }，其余生成裸数字。
    只补没有显式 center 的可换算条目，每行附带"自动补齐"注释；
    refresh=True 先删除旧的自动补齐行再按当前规则重算；
    write=False 仅打印不写回。可重复运行（幂等）。
    """
    # newline="" 读写保留原换行符（point.lua 是 CRLF）
    lines = open(path, encoding="utf8", newline="").read().splitlines(keepends=True)
    eol = "\r\n" if lines[0].endswith("\r\n") else "\n"

    def block_bounds(start_pat):
        """顶级table块的行区间 [start, end)，end 为收尾 } 所在行"""
        start = next(i for i, l in enumerate(lines) if start_pat.match(l))
        depth = 0
        for i in range(start, len(lines)):
            code = lua_strip_comment(lines[i])
            depth += code.count("{") - code.count("}")
            if depth <= 0 and i > start:
                return start, i
        return start, len(lines) - 1

    if refresh:  # 删除旧的自动补齐行，后续按当前规则重算
        s, e = block_bounds(re.compile(r"^center = \{"))
        lines = [l for i, l in enumerate(lines)
                 if not (s < i < e and "自动补齐" in l)]

    entry_pat = re.compile(r'\s*(?:\["([^"]+)"\]|([^\s={}()]+))\s*=\s*(.*)$')
    key_pat = re.compile(r'\s*(?:\["([^"]+)"\]|([^\s={}()]+))\s*=')

    # center 块与已有键
    center_start, center_end = block_bounds(re.compile(r"^center = \{"))
    center_keys = set()
    for line in lines[center_start + 1:center_end]:
        m = key_pat.match(lua_strip_comment(line))
        if m:
            center_keys.add(m.group(1) or m.group(2))

    # 收集 point 块内的条目（含命名子表条目）与 point["x"] = ... 形式的赋值
    point_start, point_end = block_bounds(re.compile(r"^point = \{"))
    p720_start, p720_end = block_bounds(re.compile(r"^point720 = \{"))
    entries = []
    pending = None  # 多行值累积 [key, parts]
    for i in range(point_start + 1, point_end):
        line = lines[i]
        if pending is not None:
            pending[1].append(lua_strip_comment(line))
            joined = "".join(pending[1]).rstrip()
            if (joined.count("{") <= joined.count("}")
                    and joined.count('"') % 2 == 0 and joined.count("'") % 2 == 0
                    and joined[-1:] in ",\"'}]"):
                entries.append((pending[0], joined.rstrip(", ").strip()))
                pending = None
            continue
        stripped = line.strip()
        if not stripped or stripped.startswith("--"):
            continue
        m = entry_pat.match(lua_strip_comment(line))
        if not m:
            continue  # 列表数组元素等无名内容
        key, rest = (m.group(1) or m.group(2)), m.group(3).rstrip()
        rest = rest.rstrip(",").strip()
        if (not rest or rest.count("{") > rest.count("}")
                or rest.count('"') % 2 or rest.count("'") % 2):
            # 多行值：看下一个有效行是否为条目（含=）来区分命名子表
            j = i + 1
            while (j < point_end and (not lines[j].strip()
                                      or lines[j].strip().startswith("--"))):
                j += 1
            nxt = lua_strip_comment(lines[j]) if j < point_end else ""
            if key_pat.match(nxt):
                continue  # 命名子表，子条目由后续行逐条解析
            pending = [key, [rest]]
            continue
        entries.append((key, rest))
    for i in range(len(lines)):
        if p720_start <= i <= p720_end or point_start <= i <= point_end:
            continue  # point720 是720p原生坐标，不参与基线换算
        m = re.match(r'point\[(["\'])([^"\']+)\1\]\s*=\s*(.*)$', lua_strip_comment(lines[i]))
        if m:
            entries.append((m.group(2), m.group(3).rstrip().rstrip(",").strip()))

    # 计算缺失 center 的条目
    modes = modes or {}
    generated = []
    seen = set()
    for key, value in entries:
        points = parse_point_values(value)
        if not points or key in center_keys or key in seen:
            continue
        seen.add(key)
        digit = numpad(points)
        mode = modes.get(key)
        if mode:
            value_out = f'{{ {digit}, "{mode}" }}'
        else:
            value_out = digit
        token = key if re.fullmatch(r"[^\W\d][\w]*", key, re.UNICODE) else f'["{key}"]'
        generated.append(f"    {token} = {value_out}, -- 自动补齐")

    print("\n".join(generated) or "没有需要补齐的条目")
    print(f"自动补齐 {len(generated)} 条 center（{path} 第 {center_end + 1} 行前）")

    if write and generated:
        lines[center_end:center_end] = [l + eol for l in generated]
        open(path, "w", encoding="utf8", newline="").write("".join(lines))
        print(f"已写入 {path}")
    return generated


def find_hex_point(image_path, bbox, offset=5):
    """取蓝色六边形中心偏左上一点的坐标和颜色。

    返回 (real_x, y, "RRGGBB", rel_x)：real_x/y 为截图中的真实坐标(1080p)，
    rel_x 为取点相对关卡名左边缘的水平偏移(1080p)，用于换算滑动到位后的位置。
    颜色取自720p截图，offset为720p下的像素偏移。
    """
    import numpy as np
    from PIL import Image

    img = np.asarray(Image.open(image_path).convert("RGB"))
    xs = [p[0] for p in bbox]
    ys = [p[1] for p in bbox]
    x0, x1 = min(xs), max(xs)
    y0, y1 = min(ys), max(ys)
    # 六边形在关卡名左侧
    left, top = max(0, x0 - 120), max(0, y0 - 40)
    right, bottom = min(img.shape[1], x0 + 10), min(img.shape[0], y1 + 40)
    crop = img[top:bottom, left:right]
    # 未通关关卡的六边形为 00B1FF
    r, g, b = crop[..., 0], crop[..., 1], crop[..., 2]
    mask = (r < 80) & (g > 130) & (g < 220) & (b > 200)
    if not mask.any():
        return None
    yy, xx = np.nonzero(mask)
    # 取中位数定位，避免把附近的其它蓝色元素算进来
    cx, cy = int(np.median(xx)) + left, int(np.median(yy)) + top
    px, py = max(0, cx - offset), max(0, cy - offset)
    color = "".join(f"{int(v):02X}" for v in img[py, px])
    # 六边形相对关卡名左边缘的水平偏移不随滑动变化，据此换算到滑动到位后的横坐标
    rel_x = (cx - x0 - offset) * 1080 // 720
    return px * 1080 // 720, py * 1080 // 720, color, rel_x


def screencap_distance2(path="screencap", point_x=1080, hex_offset=5,
                        distance_coefficient=1.11, shift_right=None, st_offset=0,
                        prefix="HD"):
    """prefix: 输出关卡代号的前缀，默认HD（如 TL-ST-1 -> HD-ST-1），传空串保留原代号；
    point_x: 普通关卡点位固定的x坐标(1080p)；hex_offset: 六边形取点相对中心的左上偏移(720p)；
    distance_coefficient: 距离膨胀系数，补偿手势滚动与手指位移的差异，部分活动需要微调；
    shift_right: 首页第一关满右滑时的真实横坐标与点位的偏差(720p)，默认按截图自动计算；
    st_offset: 教程/剧情关额外滑动量，部分活动需要

    距离在720p截图上量取，与 shift_right 同在720p单位下计算后直接输出（手势滚动比已含在系数里）。
    """
    screencap = Path(path)
    import torch

    torch.backends.cudnn.enabled = False
    import easyocr

    reader = easyocr.Reader(["en", "ch_sim"])
    point = defaultdict(int)
    point_image = {}
    point_bbox = {}
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

    distance[1] = 0
    images = sorted(screencap.glob("*.png"))
    # EX和S关大部分在同一页上 少数不在
    same_page = len(images) == 1
    # 第一张截图是满右滑后的首页
    first_image = str(images[0]) if images else ""
    # 距离按截图分辨率换算到1080p（截图约定为720p，即×1.5）
    from PIL import Image

    image_scale = 1080 / Image.open(images[0]).height if images else 1

    for image_path in images:
        x = reader.readtext(str(image_path))
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
            point_image[m] = str(image_path)
            point_bbox[m] = loc
        for m in sorted(visible_point):
            if m in distance:
                continue
            distance[m] = visible_point[m] - visible_point[m - 1] + distance[m - 1]
            print("m-1,distance[m-1]", m - 1, distance, visible_point)
        # print("visible_point", visible_point)
    # print("point", point)
    # print("distance", distance)

    # 首页（满右滑）就可见、且真实横坐标在目标点左侧的关卡滑不过去，不滑动并用真实坐标
    no_swipe = set()
    for m in sorted(point):
        name = all_list[m - 1]
        key = stage_key(name, prefix)
        real_x = point[m][0] * 1080 // 720
        # 首页可见且位于点位左侧的关卡滑不过去；EX/S/MO 单独成页，默认不滑动
        no_swipe_stage = (point_image[m] == first_image and real_x < point_x) or \
            is_single_page_stage(name)
        if no_swipe_stage:
            no_swipe.add(m)
        if is_hex_stage(name):
            hex_point = find_hex_point(point_image[m], point_bbox[m], hex_offset)
            if hex_point:
                hex_x, hy, color, rel_x = hex_point
                if no_swipe_stage:
                    print(f'["{key}"] = "{hex_x}|{hy}|{color}",')
                else:
                    print(f'["{key}"] = "{point_x + rel_x}|{hy}|{color}",')
                continue
            print(f"warning: 未找到 {name} 的蓝色六边形", file=sys.stderr)
        p = [v * 1080 // 720 for v in point[m]]
        if not no_swipe_stage:
            # 点位统一放在屏幕右半侧，不再强制到屏幕中心
            p[0] = point_x
        print(f'["{key}"] = ' + "{" + str(p[0]) + "," + str(p[1]) + "},")

    if shift_right is None:
        # 首页第一关满右滑时的真实横坐标与目标点位的偏差，用于把每关的滑动落点对齐到 point_x
        shift_right = (point[1][0] * 1080 // 720 - point_x) / image_scale if point[1] else 0

    for x in sorted(distance):
        key = stage_key(all_list[x - 1], prefix)
        # EX/S/MO 关单独成页，不输出 distance
        if is_single_page_stage(all_list[x - 1]):
            continue
        # 首页可直接点击的关卡不需要滑动
        if x in no_swipe:
            print(f'["{key}"] = ' + "{ swip_right_max, -0 },")
            continue
        p = (distance[x] + shift_right) * distance_coefficient
        p = int(p)
        # 教程剧情关坐标修正，部分活动需要
        if "TR" in all_list[x - 1] or "ST" in all_list[x - 1]:
            p = p + st_offset
        if p < 0:
            p = 0
        if same_page:
            print(f'["{key}"] = ' + "{ swip_right_max, -0 },")
        else:
            print(
                f'["{key}"] = '
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
