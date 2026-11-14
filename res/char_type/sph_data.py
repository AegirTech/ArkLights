import requests
import json
import os
import re

# 获取当前脚本所在目录
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# 游戏数据表优先从 res/ArknightsGameResource 子模块(稀疏检出)读取，子模块缺失时回退在线拉取
SUBMODULE_DIR = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "ArknightsGameResource"))

# 卫戍协议赛季数据(activity_table.json, 含盟约/商店/装备); 干员名查 character_table.json
url = "https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/main/gamedata/excel/activity_table.json"
url_char = "https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/main/gamedata/excel/character_table.json"
# k佬解包库(子模块缺 activity_table 且 yuanyan3060 落后时的备选)
# url = "https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/zh_CN/gamedata/excel/activity_table.json"


def load_game_data(rel_path, fallback_url):
    """优先读取子模块中的游戏数据表，缺失时回退 fallback_url 在线获取，失败返回 None"""
    local = os.path.join(SUBMODULE_DIR, *rel_path.split("/"))
    if os.path.isfile(local):
        print(f"使用子模块数据: {rel_path}")
        with open(local, "r", encoding="utf-8") as f:
            return json.load(f)
    print(f"子模块缺失，回退在线获取: {fallback_url}")
    resp = requests.get(fallback_url, timeout=120)
    if resp.status_code == 200:
        return json.loads(resp.text)
    return None


def save_to_json(file_name, data):
    try:
        file_path = os.path.join(SCRIPT_DIR, file_name)
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False)
        print(f"JSON数据保存成功: {file_path}")
    except IOError as e:
        print(f"保存失败: {e}")


# 卡片/资源文本里的富文本标记(<@ba.vup>+2</>、<$ba.stun> 等)全部去掉
RICH_TAG = re.compile(r"<@ba\.[a-z]+>|<\$ba\.[a-z]+>|</>|<i>|</i>")


def clean(text):
    if text is None:
        return None
    return RICH_TAG.sub("", str(text)).strip()


def pick_season(activity_table):
    """取 activity.AUTOCHESS 下开始时间最新的赛季(当前赛季)"""
    acts = activity_table.get("activity", {}).get("AUTOCHESS", {})
    basic = activity_table.get("basicInfo", {})
    best_id, best_time = None, -1
    for act_id in acts:
        start = basic.get(act_id, {}).get("startTime", 0)
        if start > best_time:
            best_id, best_time = act_id, start
    if best_id is None:
        return None, None, None
    season_data = acts[best_id]
    version = next(iter(season_data))
    return best_id, version, season_data[version]


def main():
    activity_table = load_game_data("gamedata/excel/activity_table.json", url)
    character_table = load_game_data("gamedata/excel/character_table.json", url_char)
    if activity_table is None or character_table is None:
        print("无法获取游戏数据")
        return

    act_id, version, v = pick_season(activity_table)
    if v is None:
        print("activity_table 中没有 AUTOCHESS 赛季数据")
        return
    print(f"当前赛季: {act_id} {version}")

    auto = activity_table["autoChessData"]
    # 盟约 id→中文名(当季 bondInfoDict 为准，缺的用全局补)
    bond_names = {}
    for src in (auto.get("bondInfoDict", {}), v.get("bondInfoDict", {})):
        for bid, b in src.items():
            bond_names[bid] = b["name"]

    char_name = {}
    for cid, c in character_table.items():
        char_name[cid] = c["name"]

    # 商店干员池: chessId→charId(diy 自选位 charId 为空,跳过)
    # level 取最高档,desc 多条时换行合并,bonds 用 {盟约名:true} 表便于 Lua 查成员
    operators = {}
    for chess_id, e in v["charShopChessDatas"].items():
        if e.get("isHidden") or not e.get("charId"):
            continue
        name = char_name.get(e["charId"])
        if name is None:
            print(f"!! 干员名缺失: {e['charId']}")
            continue
        cc = v["charChessDataDict"].get(chess_id, {})
        entry = operators.setdefault(name, {"level": 0, "star": None, "bonds": {}, "desc": ""})
        level = e.get("chessLevel") or 0
        if level > entry["level"]:
            entry["level"] = level
        for b in cc.get("bondIds") or []:
            entry["bonds"][bond_names.get(b, b)] = True
        d = clean(cc.get("desc"))
        if d and d not in entry["desc"]:
            entry["desc"] = f"{entry['desc']}\n{d}" if entry["desc"] else d
        if entry["star"] is None:
            rarity = character_table.get(e["charId"], {}).get("rarity")
            entry["star"] = rarity + 1 if rarity is not None else None

    # 装备池: itemId→trapChessDataDict→effectInfoDataDict(名称/效果/purchasePrice)
    # level 为第一字段; 同名多档时保留先出现的并告警
    items = {}
    for item_id, e in v["trapShopChessDatas"].items():
        tc = v["trapChessDataDict"].get(item_id, {})
        eff = v["effectInfoDataDict"].get(tc.get("effectId"), {})
        name = clean(eff.get("effectName"))
        if name is None:
            print(f"!! 装备名缺失: {item_id}")
            continue
        item = {
            "level": e.get("itemLevel") or 1,
            "price": tc.get("purchasePrice"),
            "desc": clean(eff.get("effectDesc")),
            "giveBond": bond_names.get(tc.get("giveBondId")) if tc.get("canGiveBond") else None,
        }
        if name in items:
            print(f"!! 装备同名多档,保留先出现的: {name}")
            continue
        items[name] = item

    sph_data = {
        "season": f"{act_id} {version}",
        "operators": operators,
        "items": items,
    }
    save_to_json("sph_data.json", sph_data)
    print(f"干员 {len(operators)} 装备 {len(items)}")


if __name__ == "__main__":
    main()
