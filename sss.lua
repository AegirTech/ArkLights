-- ============= 保全作战 =============
--              自动作战相关
-- ===================================

-- 地图数据每一层需要重载一次
关卡地图数据 = nil
关卡地图放置数据 = nil
作业数据 = nil
当前层作战数据 = nil
-- 干员技能
编队干员技能 = nil
无限放技能干员 = nil
技能指定次数干员 = nil
干员职业 = nil
保全导能原件转换 = { -- 每次保全更新一下
    阿戈尔示波器 = 1,
    保全人才合作协议 = 2,
    膜装置导能阀 = 3,
}

职业名称转换 = {
    vanguard = "PIONEER",
    defender = "WARRIOR",
    guard = "TANK",
    sniper = "SNIPER",
    caster = "CASTER",
    medic = "MEDIC",
    specialist = "SPECIAL",
    supporter = "SUPPORT",
}

-- 初始化保全作战
sss = {}

保全抄作业 = function()
    sss.init()
    if 作业数据 == nil or 编队干员技能 == nil then
        log('作业数据加载失败')
        return false
    end
    if not sss.choose_oper() then return false end
    local 全部作战数据 = 作业数据["stages"]
    for _, 作战数据 in ipairs(全部作战数据) do
        当前层作战数据 = 作战数据
        if not sss.load_map() then
            return false
        end
        sss.start_fight()
        sss.finish_fight()
    end
end

sss.init = function()
    maa_code = homework[cur_fight]
    作业数据 = loadHomework(maa_code)

    if 作业数据 == nil then
        log('作业数据加载失败')
        return false
    end

    -- 对于MAA中的职业名称转换
    作业数据 = JsonEncode(作业数据)
    for k, v in pairs(职业名称转换) do
        作业数据 = 作业数据:gsub(k, v)
    end
    作业数据 = JsonDecode(作业数据)

    --构建技能相关数据
    local processSkillData = function(oper)
        if table.findk(oper, "skill_usage") then
            if oper["skill_usage"] == 1 then
                table.insert(无限放技能干员, oper["name"])
            elseif oper["skill_usage"] == 2 then
                技能指定次数干员[oper["name"]] = { oper["skill_times"] or 1, 0 }
            end
        end

        if table.findk(oper, "skill") then
            编队干员技能[oper["name"]] = oper["skill"]
        end
    end

    for _, oper in ipairs(作业["opers"]) do
        processSkillData(oper)
    end
    干员职业 = JsonDecode(readFile("character_type_list.json"))
    log("作业数据加载成功")
end


sss.load_map = function()
    local stages_data = 当前层作战数据
    local 地图名称 = stages_data["stage_name"]
    log("加载地图数据", 地图名称)
    local status, 地图数据 = pcall(loadMap, 地图名称)
    if not status then
        stop("地图数据读取失败,请去测试功能内更新地图包", '', true, true)
    end
    关卡地图数据 = 地图数据[1] --放技能坐标
    关卡地图放置数据 = 地图数据[2] --放置干员坐标
    地图类型 = 地图数据[3] --地图类型,主要用来区别杀敌数位置，1普通，2剿灭,3保全，4肉鸽，5悖论模拟
    if 地图类型 ~= 3 then
        log("地图类型不匹配")
        return false
    end
    log("读取地图数据成功")
    return true
end


sss.choose_oper = function()
    -- 选择干员
    if not appear("保全作战开始按钮") then return end
    tap("保全作战开始按钮", 1)
    if not appear("保全灰色下一步选择") then return end
    local 导能原件 = 作业数据["buff"]
    local 导能原件位置 = get(保全导能原件转换, 导能原件)
    if 导能原件位置 == nil then
        log("导能原件数据错误")
        return false
    end
    tap("保全导能原件" .. 导能原件位置)
    if not appearTap("保全蓝色下一步选择") then return end


    local 装备位置x, 装备位置y = point["保全战术装备"][1], point["保全战术装备"][2]
    for i, v in ipairs(作业数据["equipment"]) do
        local ttx, tty = 装备位置x, 装备位置y
        if i > 4 then
            local ttx = 装备位置x + (i - 5) * scale(475)
            tty = tty + scale(344)
        else
            local ttx = 装备位置x + (i - 1) * scale(475)
        end
        if v == "B" then
            ttx = ttx + scale(120)
        end
        if cmpColor(ttx, tty, "0092D3", 0.8) == 0 then
            tap(ttx, tty)
            ssleep(0.1)
        end
    end
    if not appearTap("保全蓝色下一步选择") then return end

    local 未编入 = {
        char = {},
        count = 0
    }
    local 干员类别 = { "PIONEER", "WARRIOR", "TANK", "SNIPER", "CASTER", "MEDIC", "SPECIAL", "SUPPORT" }

    appear("快捷编队", 3)
    if not wait(function()
            if findOne("编队清空选择") then return true end
            tap("快捷编队")
            sleep(10)
        end, 5) then
        return
    end
    if not wait(function()
            if findOne("无干员选中") then return true end
            tap("编队清空选择")
        end, 5) then
        return
    end
    if not findOne("职业选择") then
        tap("职业选择")
        appear("职业选择", 2)
    end
    if not findOne("等级降序") then
        tap("等级降序")
        appear("等级降序", 2)
    end


    local choseChar = function()
        local 干员 = 作业数据["opers"]
        local 工具人 = 作业数据["tool_men"]
        --8个职业
        for i = 1, 8 do
            local 干员名字字符串 = ""
            local 干员目录 = {}
            local 当前职业 = 干员类别[i]
            for _, item in ipairs(干员) do
                if 干员职业[item["name"]] == 当前职业 then
                    干员名字字符串 = 干员名字字符串 .. item["name"]
                    table.insert(干员目录, item["name"] .. item["skill"])
                end
            end
            if 干员名字字符串 ~= "" then
                if not findOne("普通作战编队列表" .. i) then
                    tap("普通作战编队列表" .. i)
                    appear("普通作战编队列表" .. i)
                    ssleep(0.3)
                end
                --print(干员目录)
                local 编入结果 = 选择干员(干员目录, "待编队干员", false)


                未编入.count = 未编入.count + 编入结果[1]

                -- if 编入结果[1] > 0 then
                --     for i = 1, 编入结果[1] do
                --         table.insert(未编入.char, 编入结果[2][i])
                --     end
                -- end
            end
            if i == 8 then
                if not findOne("职业选择") then
                    tap("职业选择")
                    appear("职业选择", 2)
                    sleep(300)
                end
            end

            -- 工具人选择
        end
    end

    choseChar()

    tap("编队确认")
    appear("快捷编队", 3)
    if 未编入.count >= 1 then
        log("编队未完成，需要手动编队")
        ssleep(30)
        return false
    end
    if not appearTap("保全蓝色下一步选择") then return end
end

sss.start_fight = function()
    -- 作战数据
end


sss.finish_fight = function()
    -- 结束作战/切换下一层
end
