# https://github.com/yuanyan3060/ArknightsGameResource/tree/main/gamedata/excel/character_table.json
# 去除character_table中不需要的字段

import requests
import json

url = "https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/main/gamedata/excel/character_table.json"
url2 = "https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/main/gamedata/excel/uniequip_table.json"


def filter_fields(json_obj, fields):
    filtered_obj = {}
    for key, value in json_obj.items():
        if key in fields:
            filtered_obj[key] = value
        elif isinstance(value, dict):
            filtered_value = filter_fields(value, fields)
            if filtered_value:
                filtered_obj[key] = filtered_value
        elif isinstance(value, list):
            filtered_list = []
            for item in value:
                if isinstance(item, dict):
                    filtered_item = filter_fields(item, fields)
                    if filtered_item:
                        filtered_list.append(filtered_item)
            if filtered_list:
                filtered_obj[key] = filtered_list
    return filtered_obj


def remove_key(json_obj, key_to_remove):
    if isinstance(json_obj, dict):
        for key in list(json_obj.keys()):
            if key == key_to_remove:
                del json_obj[key]
            else:
                remove_key(json_obj[key], key_to_remove)
    elif isinstance(json_obj, list):
        for item in json_obj:
            remove_key(item, key_to_remove)
    return json_obj


def save_to_json(file_path, data):
    try:
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False)
        print(f"JSON数据获取成功并保存为{file_path}")
    except IOError as e:
        print(f"无法写入文件: {file_path}. 错误: {e}")


def convert_to_lua_table(data, indent=0):
    lua_table = "{\n"
    if isinstance(data, dict):
        for key, value in data.items():
            if key == 'L-44"留声机"' or value == "TRAP":
                continue
            if isinstance(value, (dict, list)):
                # 递归调用函数处理嵌套的字典或列表
                lua_table += (
                    "    " * indent
                    + f'["{key}"] = {convert_to_lua_table(value, indent + 1)},\n'
                )
            elif isinstance(value, str):
                # 字符串需要用引号包围
                lua_table += "    " * indent + f'["{key}"] = "{value}",\n'
            else:
                # 其他类型的值直接转换
                lua_table += "    " * indent + f'["{key}"] = "{value}",\n'
    elif isinstance(data, list):
        for item in data:
            if isinstance(item, (dict, list)):
                # 递归调用函数处理列表中的字典或列表
                lua_table += (
                    "    " * indent + f"{convert_to_lua_table(item, indent + 1)},\n"
                )
            elif isinstance(item, str):
                # 字符串需要用引号包围
                lua_table += "    " * indent + f'"{item}",\n'
            else:
                # 其他类型的值直接转换
                lua_table += "    " * indent + f"{item},\n"
    lua_table = lua_table.rstrip(",\n") + "\n" + "    " * (indent - 1) + "}"
    return lua_table


response = requests.get(url)
character_type_list = {}
char_table = {}
character_equip_list = {}
if response.status_code == 200:
    character_table_dict = json.loads(response.text)
    """# 本地
with open('./character_table.json', 'r', encoding='utf-8') as f:
    character_table_dict = json.load(f)
    """

    # 干员职业类别,自动战斗用

    for character_name in character_table_dict.keys():
        character_data = character_table_dict[character_name]
        if (
            character_data["name"] in character_type_list
            and character_data["profession"] == "TRAP"
        ):
            continue
        character_type_list[character_data["name"]] = character_data["profession"]

    for character_id in character_table_dict.keys():
        character_data = character_table_dict[character_id]
        if (
            character_data["profession"] != "TOKEN"
            and character_data["profession"] != "TRAP"
        ):
            selected_data = filter_fields(
                character_data, ["evolveCost", "levelUpCost", "lvlUpCost"]
            )
            selected_data = remove_key(selected_data, "type")

            char_table[character_id] = selected_data
            char_table[character_id]["name"] = character_data["name"]

    save_to_json("./res/char_type/character_type_list.json", character_type_list)
    save_to_json("./res/char_type/char_table.json", char_table)

else:
    print("无法获取JSON数据")

response2 = requests.get(url2)
if response2.status_code == 200:
    character_equipment_dict = json.loads(response2.text)
    """# 本地
with open("./res/char_type/uniequip_table.json", "r", encoding="utf-8") as f:
    character_equipment_dict = json.load(f)
    """

    for character_id in character_equipment_dict["charEquip"].keys():
        # 该干员持有的所有模组
        char_equip_group = character_equipment_dict["charEquip"][character_id]
        # 第一个模组通常为name+证章,去掉"证章"得到name
        char_name = character_equipment_dict["equipDict"][char_equip_group[0]][
            "uniEquipName"
        ][:-2]
        character_equip_list[char_name] = [0] * (len(char_equip_group))
        # print(char_name, "有", len(char_equip_group), "个模组")
        for i in range(len(char_equip_group)):
            equip_id = char_equip_group[i]
            equip_name = character_equipment_dict["equipDict"][equip_id]["uniEquipName"]
            if "证章" in equip_name:
                continue
            equip_mission_2 = character_equipment_dict["equipDict"][equip_id][
                "missionList"
            ][1]
            stage_id = character_equipment_dict["missionList"][equip_mission_2][
                "paramList"
            ][1]
            character_equip_list[char_name][i] = equip_name

    save_to_json("./res/char_type/equip_table.json", character_equip_list)
else:
    print("无法获取模组JSON数据")


"""
# 将几个表格转换成lua文件方便更新，转换后过大，放弃
lua_variables = {
    "character_type_list": character_type_list,
    "char_table": char_table,
    "character_equip_list": character_equip_list,
}

# 将转换后的Lua表保存到文件
file_path = "chartag.lua"
with open(file_path, "w", encoding="utf-8") as file:
    for var_name, data in lua_variables.items():
        lua_table = convert_to_lua_table(data)
        file.write(f"{var_name} = {lua_table}\n\n")

print(f"Lua variables have been saved to {file_path}")
"""
