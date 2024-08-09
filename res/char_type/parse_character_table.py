# https://github.com/yuanyan3060/ArknightsGameResource/tree/main/gamedata/excel/character_table.json
# 去除character_table中不需要的字段

import requests
import json

url = "https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/main/gamedata/excel/character_table.json"


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


response = requests.get(url)
if response.status_code == 200:
    character_table_dict = json.loads(response.text)
    # 干员职业类别,自动战斗用
    character_type_list = {}
    for character_name in character_table_dict.keys():
        character_data = character_table_dict[character_name]
        if (
            character_data["name"] in character_type_list
            and character_data["profession"] == "TRAP"
        ):
            continue
        character_type_list[character_data["name"]] = character_data["profession"]

    # 干员精英化及专精数据,自动养成用
    char_table = {}
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

"""
#本地下载后
with open('./character_table.json', 'r', encoding='utf-8') as f:
    character_table_dict = json.load(f)
character_type_list = {}
for character_name in character_table_dict.keys():
    character_type_list[character_table_dict[character_name]['name']]=character_table_dict[character_name]['profession']
# print(new_character_table_dict)
with open('./character_type_list.json', 'w', encoding='utf-8') as f:
    json.dump(character_type_list, f, ensure_ascii=False)
"""
