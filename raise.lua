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
    local fight_plan = {}
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
    烧结核凝晶 = { 转质盐聚块 = 1, 切削原液 = 1, 精炼溶剂 = 1 }

}

材料等级 = {
    金色材料 = {
        "烧结核凝晶",
        "晶体电子单元",
        "D32钢",
        "双极纳米片",
        "聚合剂",
    },
    紫色材料 = {
        "转质盐聚块",
        "环烃预制体",
        "切削原液",
        "固化纤维板",
        "精炼溶剂",
        "晶体电路",
        "炽合金块",
        "聚合凝胶",
        "三水锰矿",
        "五水研磨石",
        "RMA70-24",
        "提纯源岩",
        "改量装置",
        "聚酸酯块",
        "糖聚块",
        "异铁块",
        "白马醇",
        "酮阵列",
    },
    绿色材料 = {
        "异铁",
        "糖",
        "聚酸酯",
        "酮凝集",
        "固源岩",
        "装置",
    },
    灰色材料 = {
        "源岩",
        "破损装置",
        "酯原料",
        "代糖",
        "异铁碎片",
        "双酮",
    },
    蓝色材料 = {
        "半自然溶剂",
        "炽合金",
        "晶体元件",
        "凝胶",
        "扭转醇",
        "轻锰矿",
        "研磨石",
        "RMA70-12",
        "固源岩组",
        "全新装置",
        "聚酸酯组",
        "糖组",
        "异铁组",
        "酮凝集组",
        "环烃聚质",
        "转质盐组",
        "化合切削液",
        "褐素纤维",
    }

}

材料等级颜色 = {
    -- 灰色材料可信度很低，因为游戏多处用到灰色
    -- 灰色材料 = "A0A0A0",
    紫色材料 = "332344",
    绿色材料 = "DEE639",
    蓝色材料 = "00ACF0",
    金色材料 = "FCC708",
}

材料颜色点 = { -- 点位需要尽可能多，且保证准确
    源岩 = { "C9B888", "374040", "9D8D65" },
    破损装置 = { "3E3E36", "B86B6B", "752020", "812727" },
    酯原料 = { "7CA639", "F7FF83", "417A30" },
    代糖 = { "A0876E", "AAB5BA" },
    异铁碎片 = { "4F6073", "96C8E3", "1E2626" },
    双酮 = { "F5DA45", "AC8A57" },

    异铁 = { "5385BE", "545C5C", "6188A1" },
    糖 = { "91C31E", "8F765D" },
    聚酸酯 = { "B7D92F", "B4C4BC", "6A9B18" },
    酮凝集 = { "A46A11", "779898", "FFEC16" },
    固源岩 = { "7A7251", "202830", "D7C7A6" },
    装置 = { "414949", "912B2B", "B23636" },

    环烃聚质 = { "454555", "74749D", "0E0E15", "ACACB3" },
    转质盐组 = { "E9E9E9", "787878", "6993B4", "324354" },
    化合切削液 = { "45688B", "45B8FA", "1727F5" },
    褐素纤维 = { "CDAB4E", "938271", "0B0804" },
    半自然溶剂 = { "E877A0", "FDF5ED", "FECCC8" },
    炽合金 = { "D6C9BC", "647495", "203051", "A48B7B" },
    晶体元件 = { "2F906F", "56674E", "16A179" },
    凝胶 = { "A1FDFD", "005A8B", "12C7FF" },
    扭转醇 = { "C2631C", "CD3604", "FEDB15", "F5BB68" },
    轻锰矿 = { "2F284A", "A29AB6", "3B3257", "2110A5" },
    研磨石 = { "CB9797", "CB999B", "35364F" },
    ["RMA70-12"] = { "FFFED5", "AFAF8E", "503727", "9D7453" },
    固源岩组 = { "424242", "D9C18F", "B79F65" },
    全新装置 = { "CB3636", "BB2F2F", "641A1A" },
    聚酸酯组 = { "96C72A", "EAF287", "A5CE39" },
    糖组 = { "927958", "1CAECF", "684F2E" },
    异铁组 = { "6BA9D2", "517BA4", "2A3A42", "C1CAB9" },
    酮凝集组 = { "DCCC38", "324B5C", "553C1B" },

    烧结核凝晶 = { "292931", "CAB9E8", "6D5E73", "DED3F7" },
    晶体电子单元 = { "284949", "D37046", "1F1616" },
    D32钢 = { "E8F6F9", "387283", "2A637C" },
    双极纳米片 = { "450505", "EABE95", "D30906", "FFEF95" },
    聚合剂 = { "435454", "2C878F", "3DAA04" },

    转质盐聚块 = { "9D5295", "3B333E", "BEAFB6" },
    环烃预制体 = { "8989AA", "C5C5CD", "626293" },
    切削原液 = { "3E7DFC", "45454D", "438FFE" },
    固化纤维板 = { "93835A", "A8A697", "B39258", "D2CAA9", "787026" },
    精炼溶剂 = { "FF71A7", "FFFCFC" },
    晶体电路 = { "8CA988", "ECAA5F", "388B72" },
    炽合金块 = { "D0F8F8", "FBC23E", "55869F" },
    聚合凝胶 = { "0386BE", "9BFFFF", "DEFFFF" },
    白马醇 = { "727A82", "BF2222", "CC8282" },
    三水锰矿 = { "7D7D95", "0000E7" },
    五水研磨石 = { "D19E7C", "7E9494", "AC6846" },
    ["RMA70-24"] = { "D6B5B5", "DD0700", "CFB6B7" },
    提纯源岩 = { "CFB68D", "D4B381", "755C3B" },
    改量装置 = { "3E4646", "B63535", "A93131" },
    聚酸酯块 = { "BFDD50", "92BB1F", "245E35" },
    糖聚块 = { "5C4C33", "9A8261", "EFEFEF", "F0CE03" },
    异铁块 = { "4677AE", "66A8E1", "273748" },
    酮阵列 = { "D26E00", "415149", "F7DC00" },
}

材料颜色点_不存在 = { -- 极少数的可能存在误判
    源岩 = {},
    破损装置 = {},
    酯原料 = {},
    代糖 = { "8F4A00", "A07D53" },
    异铁碎片 = {},
    双酮 = {},

    异铁 = {},
    糖 = { "ADBEB5" },
    聚酸酯 = {},
    酮凝集 = {},
    固源岩 = {},
    装置 = {},

    环烃聚质 = { "4089E3", "C7AFE3", "D6A3A7", "2110A5" },
    转质盐组 = { "D9A8B0", "129675", "8C6B28", "3587EE" },
    化合切削液 = {},
    褐素纤维 = { "CE3B00" },
    半自然溶剂 = {},
    炽合金 = {},
    晶体元件 = {},
    凝胶 = {},
    扭转醇 = {},
    轻锰矿 = {},
    研磨石 = {},
    ["RMA70-12"] = { "8C6B28" },
    固源岩组 = { "BB8833", "E7D8D2" },
    全新装置 = {},
    聚酸酯组 = {},
    糖组 = { "D5C430", "C33501" },
    异铁组 = {},
    酮凝集组 = {},

    烧结核凝晶 = {},
    晶体电子单元 = { "A92111" },
    D32钢 = {},
    双极纳米片 = {},
    聚合剂 = {},

    转质盐聚块 = { "FF72A5" },
    环烃预制体 = { "398BFE", "0000AD", "B2A0D0" },
    切削原液 = {},
    固化纤维板 = { "C38F21" },
    精炼溶剂 = {},
    晶体电路 = {},
    炽合金块 = {},
    聚合凝胶 = {},
    白马醇 = { "E80202" },
    三水锰矿 = {},
    五水研磨石 = {},
    ["RMA70-24"] = {},
    提纯源岩 = {},
    改量装置 = { "EB6704", "E50707" },
    聚酸酯块 = {},
    糖聚块 = { "D26E00" },
    异铁块 = {},
    酮阵列 = {},
}

-- 在指定区域内寻找，存在所有特征点，返回材料名 根据材料等级判断用于降低错误率，查找时颜色可信度均为1
raise_find_material = function(area)
    local material = ""
    local skip = false
    local material_level = ""
    for k, v in pairs(材料等级颜色) do
        if find_color(area, v, 1, 0.98) ~= nil then
            material_level = k
            break
        end
    end
    if material_level == "" then material_level = "灰色材料" end
    -- log("material_level", material_level)
    local test_material = function(test_material_level)
        for k, v in pairs(材料等级[test_material_level]) do
            skip = false
            -- log("开始尝试" .. v)
            for _, j in pairs(材料颜色点[v]) do
                if find_color(area, j, 1, 0.98) == nil then
                    skip = true
                    break
                end
            end
            if not skip then
                if 材料颜色点_不存在[v] ~= {} then
                    for _, j in pairs(材料颜色点_不存在[v]) do
                        if find_color(area, j, 1, 0.98) ~= nil then
                            skip = true
                            break
                        end
                    end
                end
                if not skip then
                    material = v
                    break
                end
            end
        end
    end
    test_material(material_level)
    if material == "" then
        for k, v in pairs(材料等级) do
            if k ~= material_level then
                test_material(k)
            end
        end
    end
    -- table.removev(材料等级[material_level], material)
    -- log("material", material)
    return material
end

-- 仓库识别
raise_storage_dentify = function()

end

-- 材料识别
raise_material_identify = function()
    -- 从x 945/1686  y=120 开始y++ 识别 22BBFF 减去一定x值得到区域初始坐标
end

-- 向上滑动
raise_swipe_up = function()

end

-- 材料合成
raise_material_make = function()

end
-- 选择干员
char_choose = function(char_name)
    local character_type = JsonDecode(readFile("character_type_list.json"))
    local 干员类别 = { "PIONEER", "WARRIOR", "TANK", "SNIPER", "CASTER", "MEDIC", "SUPPORT", "SPECIAL" }
    path.跳转("干员")
    ssleep(.3)
    if not findOne("干员等级降序") then
        tap("干员等级降序")
        appear("干员等级降序", 2)
    end

    for i = 1, 8 do
        if character_type[char_name] == 干员类别[i] then
            if not findOne("普通作战编队列表" .. i) then
                tap("普通作战编队列表" .. i)
                appear("普通作战编队列表" .. i)
                sleep(200)
            end
        end
    end

    local last_char = {}
    local char_found = false
    while not char_found do
        local ret = 干员名ocr校正(ocrex("干员上"))
        log(ret)
        for i = 1, #ret do
            if ret[i]["text"] == char_name then
                char_found = true
                tap({ (ret[i]["l"] + ret[i]["r"]) / 2, ret[i]["t"] - scale(200) })
                appear("干员档案", 5)
                break
            end
        end
        if char_found then break end

        ret = 干员名ocr校正(ocrex("干员下"))
        log(ret)
        for i = 1, #ret do
            if ret[i]["text"] == char_name then
                char_found = true
                tap({ (ret[i]["l"] + ret[i]["r"]) / 2, ret[i]["t"] - scale(200) })
                appear("干员档案", 5)
                break
            end
        end
        if char_found then break end
        if ret[-1]["text"] == last_char then break else last_char = ret[-1]["text"] end
        swip_char() --仿照swip_inventory,没改坐标
end

-- 干员升级

-- 干员精英化

-- 技能升级

-- 技能专精

-- 仓库识别 测试
raise_test = function()
    ssleep(1)
    -- local area = { 469, 722, 710, 969 }
    -- local material = raise_find_material(area)
    -- log(material)

    log("start")
    local ms = {}
    local sx, sy = 12, 121
    for x = 0, 7 do
        for y = 0, 2 do
            area = { sx + x * scale(230), sy + y * scale(280), sx + x * scale(230) + scale(200), sy + y * scale(280) +
            scale(200) }
            local material = raise_find_material(area)
            -- log(x, y, material)
            table.insert(ms, { x, y, material })
        end
    end
    log("end")
    log(ms)
    ssleep(300)
end


-- 基建合成识别
raise_test2 = function()
    ssleep(1)
    local ms = {}
    local sx, sy = 251, 87
    log("start")
    for x = 0, 1 do
        for y = 0, 2 do
            area = { sx + x * scale(740), sy + y * scale(270), sx + x * scale(740) + scale(250), sy + y * scale(270) +
            scale(250) }
            local material = raise_find_material(area)
            -- log(x, y, material)
            table.insert(ms, { x, y, material })
        end
    end
    log("end")
    log(ms)
    ssleep(300)
end

raise_test3 = function()
    -- local pixel = getPixelColor(279, 792)
    -- print(pixel)
    -- local r, g, b = colorToRGB(pixel)
    -- print(r, g, b)

    -- local iswhite, isdis = false, false

    local area = { 199, 451, 435, 698 }
    local sx, sy = 213, 184
    local ms = {}

    function getcent(area)
        local 绿色, 蓝色 = 0, 0, 0, 0
        local pixel, r, g, b = "", 0, 0, 0
        local cx, cy = nil, nil
        local 蓝色区域差值 = 0
        for y = area[2], area[4], 1 do
            iswhite, isdis = false, false
            for x = area[1], area[3], 1 do
                pixel = getPixelColor(x, y)
                b, g, r = colorToRGB(pixel)
                --[[
            绿色，用于确定是否为小芯片
            28-103,35-120,20-73

            蓝色 用于确认芯片背景
            2-70,70-138,95-150

            蓝色之间的其他颜色为白色
            ]]
                --
                -- log(r, g, b)
                if r > 28 and r < 103 and g > 35 and g < 120 and b > 20 and b < 73 then
                    绿色 = 绿色 + 1
                elseif r > 2 and r < 70 and g > 70 and g < 138 and b > 95 and b < 150 then
                    蓝色 = 蓝色 + 1
                    if not cx then
                        cx = x
                        cy = y
                    end
                    蓝色区域差值 = 蓝色区域差值 + x - cx + y - cy
                end
            end
        end
        return 绿色, 蓝色, 蓝色区域差值
    end

    -- area = { 1506, 449, 1752, 695 }
    -- local 绿色, 蓝色 = getcent(area)
    -- local 比例 = 蓝色 / (scale(200) * scale(200))
    -- table.insert(ms, { x, y, 蓝色, 比例 })

    for x = 0, 3 do
        for y = 0, 2 do
            area = { sx + x * 230, sy + y * 280, sx + x * 230 + 200, sy + y * 280 + 200 }
            local 绿色, 蓝色, 蓝色差 = getcent(area)
            local 比例 = 蓝色 / (scale(200) * scale(200))
            -- log(x, y, material)
            table.insert(ms, { x, y, 蓝色, 比例, 蓝色差 / 蓝色 })
        end
    end

    -- local 比例 = 白色 / (绿色 + 蓝色 + 白色)
    -- log(绿色, 蓝色, 白色, 比例)
    log(ms)
    ssleep(2000)
end

swip_inventory = function(left)
    local duration
    local finger
    local delay
    if left then
        local x1 = scale(600)
        local x2 = scale(10000 / 720 * 1080)
        local y1 = scale(533)
        duration = 400
        finger = { { point = { { x1, y1 }, { x2, y1 } }, duration = duration } }
        delay = 750
    else
        local x = scale(94)
        local y = scale(400)
        local y2 = scale(700)
        local x2 = scale(1720)
        local y3 = scale(700)
        local slids = 50
        local slidd = 200
        local taps = slids + slidd + 150
        local tapd = 200
        local downd = taps + 100
        duration = downd
        finger = {
            { point = { { x, y }, { x, y2 } },   start = 0,     duration = downd },
            { point = { { x2, y }, { x2, y3 } }, start = slids, duration = slidd },
            { point = { { x2, y }, { x2, y } },  start = taps,  duration = tapd },
        }
        delay = 250
    end
    log(JsonEncode(finger))
    gesture(finger)
    sleep(duration + delay)
end

swip_char = function(left)
    local duration
    local finger
    local delay
    if left then
        local x1 = scale(600)
        local x2 = scale(10000 / 720 * 1080)
        local y1 = scale(533)
        duration = 400
        finger = { { point = { { x1, y1 }, { x2, y1 } }, duration = duration } }
        delay = 750
    else
        local x = scale(94)
        local y = scale(400)
        local y2 = scale(700)
        local x2 = scale(1720)
        local y3 = scale(700)
        local slids = 50
        local slidd = 200
        local taps = slids + slidd + 150
        local tapd = 200
        local downd = taps + 100
        duration = downd
        finger = {
            { point = { { x, y }, { x, y2 } },   start = 0,     duration = downd },
            { point = { { x2, y }, { x2, y3 } }, start = slids, duration = slidd },
            { point = { { x2, y }, { x2, y } },  start = taps,  duration = tapd },
        }
        delay = 250
    end
    log(JsonEncode(finger))
    gesture(finger)
    sleep(duration + delay)
end

is_last_page = function()
    -- 检测最后一页 1710 y =240-600是否为空白
    local sx = scale(1710)
    keepCapture()
    for y = scale(240), scale(600), 1 do
        pixel = getPixelColor(sx, y)
        if pixel ~= "FFFFFF" then
            releaseCapture()
            return false
        end
    end
    releaseCapture()
    return true
end

-- 仓库识别 给定材料列表 只ocr给定的材料数量
raise_inventory_identify = function(materials)
    local sx, sy = scale(85), scale(185)
    local ms = {}
    local ret = {}
    if materials == nil or #materials == 0 then return end
    log(materials)
    swip_inventory(true)
    ssleep(0.5)
    log("start")
    local page = 0
    -- swip_inventory(true)
    while true do
        if page > 3 then break end

        keepCapture()
        for x = 0, 7 do
            for y = 0, 2 do
                area = { sx + x * scale(230), sy + y * scale(280), sx + x * scale(230) + scale(200), sy + y * scale(280) +
                scale(200) }
                local material = raise_find_material(area)
                -- log(x, y, material)
                -- table.insert(ms, { x, y, material })
                if material ~= "" then
                    -- log(material)
                    if table.includes(materials, material) then
                        if ret[material] == nil then
                            area[2] = area[2] + scale(150)
                            local num = ocrex(area)
                            if #num == 0 then
                                num = 0
                            else
                                num = num[1]["text"]
                            end
                            ret[material] = num
                            table.insert(ms, { x, y, material, num })
                        end
                    end
                end
            end
        end
        releaseCapture()

        swip_inventory()
        page = page + 1
    end
    log("end")
    log(ms)
    ssleep(300)
end


raise_test_all = function()
    -- ssleep(1.5)
    -- t = raise_find_material({ 923, 306, 1102, 465 })
    -- log(t)
    -- raise_test()
    raise_test2()
    ssleep(500)
end
