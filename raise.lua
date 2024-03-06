-- ===========================================
--               自动化练干员
-- ===========================================

-- 初始化数据及玩家信息
raise_init = function()
    if not character_table then
        local file = io.open(getWorkPath() .. "/gamedata/excel/character_table.json", "r")
        character_table = file:read("*a")
        file:close()
        local status
        status, character_table = pcall(JsonDecode, character_table)
        if not status then
            log("游戏数据character_table读取失败")
            return
        end
    end
    if not item_table then
        file = io.open(getWorkPath() .. "/gamedata/excel/item_table.json", "r")
        item_table = file:read("*a")
        file:close()
        local status
        status, item_table = pcall(JsonDecode, item_table)
        if not status then
            log("游戏数据item_table读取失败")
            return
        end
    end
    if not character_id2name then
        for k, v in ipairs(character_table) do
            if string.startsWith(k, "char") then
                local name = v["name"]
                character_id2name[k] = name
                character_name2id[name] = k
            end
        end
    end

    -- 其余接口暂未实现
    player_info_init(raise_get_player_info())
end

-- 接口获取玩家信息
raise_get_player_info = function()
    if (not a60_token_offcial) or (not a60_token_bili) then return end
    if server == 0 then
        local url = "http://pyark.a60.one:88/login/offcial?username=%s&password=%s&token=%s"
        url = string.format(url, username, password, a60_token_offcial)
    else
        local url = "http://pyark.a60.one:88/login/bilibili?username=%s&password=%s&token=%s"
        url = string.format(url, username, password, a60_token_bili)
    end
    local ret, code = httpGet(url)
    if code ~= 200 then return end
    local status, player_data = pcall(JsonDecode, ret)
    if not status then return end
    return player_data
end

player_info_init = function(player_data)
    player_inventory_info = player_data["user"]["inventory"] -- charid, data 仓库数据
    player_character_info = {}                               -- 干员数据
    local ori_player_character_info = player_data["user"]["troop"]["chars"]
    for k, v in pairs(ori_player_character_info) do
        local name = v["charId"]
        player_character_info[name] = v
    end
end

-- 材料ID转换材料名
raise_item_id_to_name = function(id)
    return item_table["items"][id]["name"]
end

-- 干员ID转换干员名
raise_character_id_to_name = function(id)
    return character_id2name[id]
end

-- 干员名字转换到ID
raise_character_name_to_id = function(name)
    return character_name2id[name]
end

-- 获取指定干员ID的精英化等级
raise_character_phase_level = function(id)
    return player_character_info[id]["evolvePhase"]
end

-- 获取指定干员ID的技能信息
raise_character_skill_info = function(id)
    return player_character_info[id]["skills"]
end

-- 获取指定干员指定技能的升级材料
raise_character_skill_upgrade_material = function(id, skill_id_index)
    local skill_info = character_table[id]["skills"][skill_id_index]
    return skill_info
end

-- 计算指定干员指定技能的升级材料总数 返回 材料ID:数量
raise_character_skill_upgrade_material_total = function(id, skill_id_index, target_level)
    local current_skill_level = player_character_info[id]["skills"][skill_id_index]["specializeLevel"]
    local skill_info = raise_character_skill_upgrade_material(id, skill_id_index)
    if target_level == current_skill_level then return {} end
    total_material = {}
    for i = target_level, current_skill_level + 1, -1 do
        local levelUpCostCond = skill_info["levelUpCostCond"][i]["levelUpCost"]
        for k, v in pairs(levelUpCostCond) do
            if v["type"] == "MATERIAL" then
                local id = v["id"]
                local count = v["count"]
                if total_material[id] then
                    total_material[id] = total_material[id] + count
                else
                    total_material[id] = count
                end
            end
        end
    end
    return total_material
end

-- 获取指定干员的精英化材料
raise_character_phase_upgrade_material = function(id)
    return character_table[id]["phases"]
end

-- 计算指定干员精英化材料总数
raise_character_phase_upgrade_material_total = function(id, target_phase)
    local total_material = {}
    local current_char_phase = raise_character_phase_level(id)
    if target_phase == current_char_phase then return {} end
    local phase_info = raise_character_phase_upgrade_material(id)
    table.remove(phase_info, 1)
    total_material = {}
    for i = target_phase, current_char_phase + 1, -1 do
        local levelUpCostCond = phase_info[i]["evolveCost"]
        for k, v in pairs(levelUpCostCond) do
            if v["type"] == "MATERIAL" then
                local id = v["id"]
                local count = v["count"]
                if total_material[id] then
                    total_material[id] = total_material[id] + count
                else
                    total_material[id] = count
                end
            end
        end
    end
    return total_material
end

-- 计算仓库材料缺失总数
raise_calculate_materials = function(materials)
    local need_materials = {}
    for k, v in pairs(materials) do
        local current_count = player_inventory_info[id]
        if current_count < v then
            need_materials[k] = v - current_count
        end
    end
    return need_materials
end

-- 根据材料生成需要刷的关卡 默认缺一个材料刷一次关
raise_generate_fight_plan = function(materials)
    local plan = {}
end


-- 生成刷图计划 传入干员名和计划名 返回作战列表
raise_generate_fight_plan = function(待养成干员, 养成计划)
    local stage_plan = {}
    local char_id = raise_character_name_to_id(待养成干员)
    if char_id == nil then return end
    if 养成计划.plan == "精英化" then
        local 精英化等级 = tonumber(养成计划.level)
        local 材料需求 = raise_character_phase_upgrade_material_total(char_id, 精英化等级)
        if 材料需求 == {} then return {} end
        材料需求 = raise_calculate_materials(材料需求)
    elseif 养成计划.plan == "专精" then
        local 专精等级 = tonumber(养成计划.level)
        local 专精技能 = tonumber(养成计划.index)
        local 材料需求 = raise_character_skill_upgrade_material_total(char_id, 专精技能, 专精等级)
        if 材料需求 == {} then return {} end
        材料需求 = raise_calculate_materials(材料需求)
    end
end

高级材料2低级材料 = {

}

材料等级 = {

}

材料等级颜色 = {
    -- 灰色材料可信度很低，因为游戏多处用到灰色
    -- 灰色材料 = "A0A0A0",
    绿色材料 = "DCE537",
    蓝色材料 = "00B3FD",
    紫色材料 = "332344",
    金色材料 = "FBC913",
}

材料颜色点 = { -- 点位需要尽可能多，且保证准确
    扭转醇 = {},
    轻锰矿 = {},
    研磨石 = {},
    固源岩组 = {},
    固源岩 = {},
    全新装置 = { "9A2626", "CC3737", "A62A2A" },
    装置 = {},
    糖组 = {},
    糖 = {},
    聚酸酯组 = {},
    聚酸酯 = {},
    异铁组 = {},
    异铁 = {},
    酮凝集组 = {},
    酮凝集 = {},
    凝胶 = {},
    炽合金 = {},
    晶体元件 = {},
    半自然溶剂 = {},
    化合切削液 = {},
    转质盐组 = {},
    褐素纤维 = {},
    环烃聚质 = {},
    ["RMA70-12"] = {}

}

-- 在指定区域内寻找，存在所有特征点，返回材料名 根据材料等级判断用于降低错误率，查找时颜色可信度均为1
raise_find_material = function(area)
    local material = ""
    local skip = false
    for k, v in pairs(材料颜色点) do
        local material_level = 材料等级[k]
        if material_level ~= "灰色材料" and find_color(area, 材料等级颜色[material_level]) == nil then
            goto continue
        else
            -- 灰色的直接判断不存在其他的颜色
            local is_material_level_0 = true
            for _, v in pairs(材料等级颜色) do
                if find_color(area, v, 1, 1) ~= nil then
                    is_material_level_0 = false
                    break
                end
            end
            if not is_material_level_0 then
                goto continue
            end
        end

        for _, j in pairs(v) do
            if find_color(area, j, 1, 1) == nil then
                skip = true
                break
            end
        end

        if not skip then
            material = k -- 已经找到，后续不再查找
            break
        end
        ::continue::
    end
end

-- 仓库识别
raise_storage_dentify = function()

end

-- 材料合成
raise_material_make = function()

end

-- 干员升级

-- 干员精英化

-- 技能升级

-- 技能专精
