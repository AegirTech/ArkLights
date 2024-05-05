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


response = requests.get(url)
if response.status_code == 200:
    character_table_dict = json.loads(response.text)
    # 干员职业类别,自动战斗用
    character_type_list = {}
    for character_name in character_table_dict.keys():
        character_data = character_table_dict[character_name]
        character_type_list[character_data["name"]] = character_data["profession"]

    with open("character_type_list.json", "w", encoding="utf-8") as f:
        json.dump(character_type_list, f, ensure_ascii=False)

    print("JSON数据获取成功并保存为character_type_list.json")

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
            char_table[character_id] = selected_data
            char_table[character_id]["name"] = character_data["name"]

    with open("char_table.json", "w", encoding="utf-8") as f:
        json.dump(char_table, f, ensure_ascii=False)

    print("JSON数据获取成功并保存为char_table.json")
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
