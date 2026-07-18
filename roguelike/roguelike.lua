-- 肉鸽通用函数
zl = {}

--开始之前检测一下，有没有其他肉鸽未结束探索
zl.放弃未结束的肉鸽探索 = function()
    path.跳转("首页")

    tap("面板作战")
    if not appear("主页") then return false end

    if not wait(function()
            if findOne("主题曲界面") then return true end
            tap("主题曲")
        end, 5) then
        return false
    end

    if not wait(function()
            if findOne("在长期探索") then return true end
            tap("集成战略")
        end, 5) then
        return false
    end

    local jump = true
    toast('检测是否有未结束的肉鸽探索')
    if not wait(function()
            if findAny({ "傀影_探索中", "水月_探索中", "萨米_探索中", "萨卡兹_探索中" }) then
                log('还有探索没有结束')
                tap({ scale(279), scale(501) })
                jump = false
                return true
            end
        end, 3, .1) then
        return false
    end
    disappear('在长期探索')
    ssleep(2)
    local rougelike_list = { "傀影_放弃本次探索", "水月_放弃本次探索", "萨米_放弃本次探索", "萨卡兹_放弃本次探索" }
    local p = findAny(rougelike_list) or 'nil'
    local pp = p:match("^(.-)_")
    log(pp)
    zl_abandon_explore(pp)
    path.跳转("首页")
end

zl.查找指定干员 = function(干员, 肉鸽白名单, 最大翻页次数) --招募指定干员
    log("肉鸽招募干员", 干员)
    log(肉鸽白名单)
    local 被招募干员
    local 最大翻页次数 = 最大翻页次数 or 5
    local 横向距离 = 585
    local 纵向距离 = 205
    local 起始点横坐标, 起始点纵坐标 = 624, scale(144) --用于定位
    appear("确认招募", 3)
    ssleep(1)
    if type(干员) == "string" then
        for page = 0, 最大翻页次数 do --页
            local intX = findMultiColor(scale(586), 起始点纵坐标, scale(777), 起始点纵坐标 + 1,
                "2E2E2E", "0|" .. scale(-20) .. "|C3C3C3", 0, 0.95)
            local 偏移坐标 = scale(起始点横坐标) - intX
            --log("偏移坐标", 偏移坐标)
            for i = 0, 7 do
                point.肉鸽干员名称识别范围 = { scale(936 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(259 + 纵向距离 * (i % 4)),
                    scale(1125 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(294 + 纵向距离 * (i % 4)) }
                被招募干员 = correctCharName(ocro("肉鸽干员名称识别范围"))
                log(i, 被招募干员)
                if not 肉鸽白名单 or table.includes(肉鸽白名单, 被招募干员) then
                    point.肉鸽干员等级识别范围 = { scale(682 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(261 + 纵向距离 * (i % 4)),
                        scale(707 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(291 + 纵向距离 * (i % 4)) }
                    local 可招募干员等级 = tonumber(ocro("肉鸽干员等级识别范围")) or 1
                    local 可招募干员精英 = 0 --精二图标和精一图标不是完全重合
                    if cmpColor(scale(730 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(222 + 纵向距离 * (i % 4)), "FFFFFF", 0.95) == 1 then
                        可招募干员精英 = 2
                    elseif cmpColor(scale(730 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(215 + 纵向距离 * (i % 4)), "FFFFFF", 0.95) == 1 then
                        可招募干员精英 = 1
                    end --tap("近卫招募列表" .. (i + 1))
                    if table.includes(肉鸽队员, 被招募干员) then
                        table.insert(肉鸽队员, 被招募干员)
                    elseif 被招募干员 == "维什戴尔" then
                        招募开局干员 = 1
                    end
                    return 被招募干员, (i + 1), 可招募干员精英, 可招募干员等级
                end
            end
            ssleep(.5)
            zl.招募翻页()
        end
    end
    return 0, 0, 0, 1
end

zl.招募翻页 = function(left, nodelay)
    local duration
    local finger
    local delay
    if left then --滑到最左边
        local x1 = scale(616)
        local x2 = scale(10000 / 720 * 1080)
        local y1 = scale(533)
        duration = 400
        finger = { { point = { { x1, y1 }, { x2, y1 } }, duration = duration } }
        delay = 750
    else
        local x = scale(616)
        local y = scale(533)
        local y2 = scale(900)
        --修改x2坐标
        local x2 = scale(1200)
        local x3 = scale(1695)
        local y3 = scale(310)
        local slids = 50
        local slidd = 200
        local taps = slids + slidd + 150
        local tapd = 200
        local downd = taps + 100
        duration = downd
        finger = {
            { point = { { x, y }, { x, y2 } },    start = 0,     duration = downd },
            { point = { { x2, y }, { x2, y3 } },  start = slids, duration = slidd },
            { point = { { x3, y3 }, { x3, y3 } }, start = taps,  duration = tapd },
        }
        delay = 250
    end
    log(JsonEncode(finger))
    gesture(finger)
    sleep(duration + (nodelay and 0 or delay))
    return nodelay and delay or 0
end

zl.分析可招募干员 = function(最大翻页次数)
    log("分析可招募干员")
    local 可招募干员列表 = {}
    local 最大翻页次数 = 最大翻页次数 or 4
    local 横向距离 = 585
    local 纵向距离 = 205
    local 起始点横坐标, 起始点纵坐标 = 624, scale(144) --用于定位
    appear("确认招募", 3)
    zl.招募翻页(1)
    ssleep(1)
    for page = 0, 最大翻页次数 do
        local intX = findMultiColor(scale(586), 起始点纵坐标, scale(777), 起始点纵坐标 + 1,
            "2E2E2E", "0|" .. scale(-20) .. "|C3C3C3", 0, 0.95)
        if not intX then break end --没有干员可招募
        local 偏移坐标 = scale(起始点横坐标) - intX
        --log("偏移坐标", 偏移坐标)
        for i = 0, 7 do
            point.肉鸽干员名称识别范围 = { scale(936 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(259 + 纵向距离 * (i % 4)),
                scale(1125 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(294 + 纵向距离 * (i % 4)) }
            local 可招募干员 = correctCharName(ocro("肉鸽干员名称识别范围"))
            point.肉鸽干员等级识别范围 = { scale(682 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(261 + 纵向距离 * (i % 4)),
                scale(707 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(291 + 纵向距离 * (i % 4)) }
            local 可招募干员等级 = tonumber(ocro("肉鸽干员等级识别范围")) or 1
            point.肉鸽干员希望识别范围 = { scale(985 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(223 + 纵向距离 * (i % 4)),
                scale(1020 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(249 + 纵向距离 * (i % 4)) }
            local 需要希望 = tonumber(ocro("肉鸽干员希望识别范围")) or 7
            local 可招募干员精英 = 0 --精二图标和精一图标不是完全重合
            if cmpColor(scale(730 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(222 + 纵向距离 * (i % 4)), "FFFFFF", 0.95) == 1 then
                可招募干员精英 = 2
            elseif cmpColor(scale(730 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(215 + 纵向距离 * (i % 4)), "FFFFFF", 0.95) == 1 then
                可招募干员精英 = 1
            end
            --log(page, i, 可招募干员, 可招募干员精英, 可招募干员等级, 需要希望)
            可招募干员列表[可招募干员] = {
                page = page,
                index = i + 1,
                --name = 可招募干员,
                elite = 可招募干员精英,
                level = 可招募干员等级,
                hope = 需要希望,
            }
        end
        ssleep(.5)
        -- todo:滑到三星就break
        if 偏移坐标 < -80 then --已经翻到最后一页
            break
        end
        zl.招募翻页()
    end
    return 可招募干员列表
end

zl.加载干员招募评分 = function(theme)
    log("加载干员招募评分")
    local theme = theme or "sui"
    local theme_info = {
        oper_groups = {}, --保留groups的顺序信息
        all_groups = {},
        all_opers_recruit_info = {},
        all_opers_battle_info = {},
        conditions = {},
    }
    local file_path = "mnt/sdcard/Pictures/" .. theme .. "/recruitment.json"
    local recruit_json = JsonDecode(readFile(file_path))
    log("加载成功,初始化数据")
    theme_info.conditions = recruit_json.team_complete_condition
    local group_id = 0
    -- {"name":干员组名, "opers":组内干员组成的array}
    for _, group_json in ipairs(recruit_json.priority) do
        local group_name = group_json.name
        --log(group_name)
        table.insert(theme_info.oper_groups, group_name)

        -- 干员组信息
        local group_info = {}
        group_info.name = group_name
        group_info.id = group_id
        group_info.opers = {}
        -- 干员在组内的顺序,int
        local order_in_group = 1
        --遍历"opers"数组
        for _, oper_json in ipairs(group_json.opers) do
            local name = oper_json.name
            group_info.opers[order_in_group] = name

            -- 肉鸽干员招募信息
            local oper_recruit_info = {}
            local oper_battle_info = {}
            -- 干员已存在时仅做更新
            if theme_info.all_opers_recruit_info[name] then
                oper_recruit_info = theme_info.all_opers_recruit_info[name]
            end
            if theme_info.all_opers_battle_info[name] then
                oper_battle_info = theme_info.all_opers_battle_info[name]
            end

            oper_recruit_info.name = name
            oper_battle_info.name = name

            oper_recruit_info.recruit_priority = oper_json.recruit_priority or oper_recruit_info.recruit_priority or 0
            oper_recruit_info.promote_priority = oper_json.promote_priority or oper_recruit_info.promote_priority or 0
            oper_recruit_info.is_alternate = oper_json.is_alternate or oper_recruit_info.is_alternate or false
            oper_recruit_info.is_key = oper_json.is_key or oper_recruit_info.is_key or false
            oper_recruit_info.is_start = oper_json.is_start or oper_recruit_info.is_start or false

            oper_recruit_info.recruit_priority_when_team_full = oper_recruit_info.recruit_priority - 100
            oper_recruit_info.promote_priority_when_team_full = oper_recruit_info.promote_priority + 300

            if oper_json.recruit_priority_offsets then
                oper_recruit_info.recruit_priority_offsets = {}
                for _, offset_json in ipairs(oper_json.recruit_priority_offsets) do
                    local offset = {}
                    offset.groups = {}
                    for _, group in ipairs(offset_json.groups) do
                        table.insert(offset.groups, group)
                    end
                    offset.threshold = offset_json.threshold or 0
                    offset.is_less = offset_json.is_less or false
                    offset.offset = offset_json.offset or 0
                    table.insert(oper_recruit_info.recruit_priority_offsets, offset)
                end
            end

            if oper_json.collection_priority_offsets then
                oper_recruit_info.collection_priority_offsets = {}
                for _, offset_json in ipairs(oper_json.collection_priority_offsets) do
                    local offset = {}
                    offset.collection = offset_json.collection or ""
                    offset.offset = offset_json.offset or 0
                    table.insert(oper_recruit_info.collection_priority_offsets, offset)
                end
            end

            if not oper_battle_info.group_id then
                oper_battle_info.group_id = {}
            end
            table.insert(oper_battle_info.group_id, group_id)

            if not oper_battle_info.order_in_group then
                oper_battle_info.order_in_group = {}
                for i = 1, #recruit_json.priority do
                    oper_battle_info.order_in_group[i] = 0 --防止稀疏数组
                end
            end

            oper_battle_info.order_in_group[group_id] = order_in_group
            oper_battle_info.skill = oper_json.skill or oper_battle_info.skill or 0
            oper_battle_info.alternate_skill = oper_json.alternate_skill or oper_battle_info.alternate_skill or 0
            oper_battle_info.skill_usage = oper_json.skill_usage or oper_battle_info.skill_usage or 1
            oper_battle_info.skill_times = oper_json.skill_times or oper_battle_info.skill_times or 1
            oper_battle_info.alternate_skill_usage = oper_json.alternate_skill_usage or
                oper_battle_info.alternate_skill_usage or 1
            oper_battle_info.alternate_skill_times = oper_json.alternate_skill_times or
                oper_battle_info.alternate_skill_times or 1
            oper_battle_info.auto_retreat = oper_json.auto_retreat or oper_battle_info.auto_retreat or 0


            theme_info.all_opers_recruit_info[name] = oper_recruit_info
            theme_info.all_opers_battle_info[name] = oper_battle_info
            order_in_group = order_in_group + 1
        end

        theme_info.all_groups[group_name] = group_info
        group_id = group_id + 1
    end

    return theme_info
end

---@param recruit_info table 干员招募评分数据,读取的预设值json文件
---@param 可招募干员列表 table 识别出来的当前可供招募的干员列表
---@param 现有干员列表 table 已经招募的干员
zl.计算干员优先级 = function(recruit_info, 可招募干员列表, 现有干员列表)
    log("计算干员优先级")
    local 干员位置 = { name = "", page = 0, index = 1 }
    if not recruit_info or not 可招募干员列表 then return 干员位置 end
    local all_groups = recruit_info.all_groups
    local all_opers = recruit_info.all_opers_recruit_info
    local 当前可招募评分列表 = {}
    local team_complete = false
    --todo 判断阵容完备度

    --log(现有干员列表)
    for name, 可招募干员信息 in pairs(可招募干员列表) do
        local priority = -1000
        local 当前干员评分信息 = all_opers[name]
        --log(name)
        --log(可招募干员信息)
        --log(当前干员评分信息)
        if 当前干员评分信息 then
            if table.findk(现有干员列表, name) then --队伍中已有
                if 可招募干员信息.elite < 2 then --小于精二
                    priority = -1000
                else
                    priority = 当前干员评分信息.promote_priority
                end
            else --初次招募
                if 可招募干员信息.elite == 2 then
                    priority = 当前干员评分信息.recruit_priority + 当前干员评分信息.promote_priority
                elseif 可招募干员信息.elite == 1 and (可招募干员信息.level >= 55 or 可招募干员信息.level == 0) then
                    priority = 当前干员评分信息.recruit_priority
                else
                    priority = -1000
                end
                -- todo 根据offset再进行修正
            end
            if 可招募干员信息.hope == 0 then
                priority = priority + 100
            end
            if not 当前干员评分信息.is_key and not team_complete then
                priority = priority - 1000
            end
            if priority > 0 then
                当前可招募评分列表[name] = priority
            end
        end
        --log(name, priority)
    end
    log(当前可招募评分列表)
    local best = 0
    local best_oper = ""
    for k, v in pairs(当前可招募评分列表) do
        if v > best then
            best = v
            best_oper = k
        end
    end
    log("最高评分干员: " .. best_oper .. " 评分: " .. best)
    if best > 0 then
        干员位置 = 可招募干员列表[best_oper]
        干员位置.name = best_oper
    end
    log("干员位置: 第" .. 干员位置.page .. "页,第" .. 干员位置.index .. "个干员")
    return 干员位置
end

zl.判断阵容完备度 = function(recruit_info, 现有干员列表)

end

zl.招募并记录干员 = function(t)
    log(t)
    if not t then return end
    if t.name then
        zl.招募翻页(1)
        if t.page > 0 then
            for i = 1, t.page do
                zl.招募翻页()
            end
        end

        肉鸽参数["operators"][t.name] = {
            name = t.name,
            level = t.level,
            elite = t.elite,
        }
    end
    zl.选择干员(t.index)
end

zl.分析待编队干员 = function(最大翻页次数)
    log("分析待编队干员")
    local 待编队干员列表 = {}
    local 最大翻页次数 = 最大翻页次数 or 6
    local 横向距离 = 585
    local 纵向距离 = 205
    local 起始点横坐标, 起始点纵坐标 = 624, scale(144) --用于定位
    local 干员过多 = false
    appear("确认招募", 3)
    if not findOne("rl_第零列无干员") or not findOne("rl_第三列无干员") then
        干员过多 = true
        zl.招募翻页(1)
        ssleep(1)
    end

    for page = 0, 最大翻页次数 do
        local intX = findMultiColor(scale(586), 起始点纵坐标, scale(777), 起始点纵坐标 + 1,
            "2E2E2E", "0|" .. scale(-20) .. "|C3C3C3", 0, 0.95)
        if not intX then break end --没有干员可招募
        local 偏移坐标 = scale(起始点横坐标) - intX
        --log("偏移坐标", 偏移坐标)
        local 无干员 = false
        for i = 0, 7 do
            point.肉鸽干员名称识别范围 = { scale(936 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(259 + 纵向距离 * (i % 4)),
                scale(1125 + 横向距离 * math.floor(i / 4)) - 偏移坐标, scale(294 + 纵向距离 * (i % 4)) }
            local 干员 = correctCharName(ocro("肉鸽干员名称识别范围"))
            if not 干员 then
                无干员 = true
                break
            end
            log(page, i, 干员)
            if 偏移坐标 < -80 then
                if i >= 4 then --最后一页前面4个会重复
                    待编队干员列表[page * 8 + i + 1 - 4] = {
                        page = page,
                        index = i + 1,
                        name = 干员,
                    }
                end
            else
                待编队干员列表[page * 8 + i + 1] = {
                    page = page,
                    index = i + 1,
                    name = 干员,
                }
            end
        end

        ssleep(.5)
        if 偏移坐标 < -80 or 无干员 == true then --已经翻到最后一页
            break
        end
        zl.招募翻页()
    end
    if 干员过多 then
        zl.招募翻页(1)
        ssleep(1)
    end

    return 待编队干员列表
end

zl.自动编队 = function(recruit_info)
    log("肉鸽自动编队")
    appear("快捷编队", 3)
    local 已选择干员 = {}
    local all_opers_battle_info = recruit_info.all_opers_battle_info
    local 编队上限 = tonumber(ocro("rl_编队数量ocr范围"):match("/(%d+)")) or 6
    if not wait(function()
            if findOne("rl_编队清空选择") then return true end
            tap("快捷编队")
        end, 5, .1) then
        return
    end
    if not wait(function()
            if findOne("rl_无干员选中") then return true end
            tap("rl_编队清空选择")
        end, 5, .1) then
        return
    end
    local 待编队干员列表 = zl.分析待编队干员()
    if #肉鸽参数.operators > 编队上限 then
        local conditions = recruit_info.conditions
        local all_groups = recruit_info.all_groups
        local oper_
        log(conditions)
        log(all_groups)
        --没写好
        for i = 1, #conditions do --遍历所有控制组
            local groups = conditions[i].groups
            local threshold = conditions[i].threshold
            local count = 0
            for name, info in pairs(待编队干员列表) do --遍历待编队的干员
                for j = 1, #groups do --如果在组里就添加
                    local group_name = groups[j]
                    local opers = all_groups[group_name]["opers"]
                    if table.findv(opers, name) then
                        table.insert(已选择干员, info)
                        count = count + 1
                        break
                    end
                end
            end
            if count >= threshold then
                break
            end
        end
        log(已选择干员)
    else
        for i = 1, 12 do
            tap("近卫招募列表" .. i)
            ssleep(.01)
        end
        已选择干员 = 待编队干员列表
    end
    if not wait(function()
            if findOne("快捷编队") then return true end
            tap("确认招募")
        end, 5, .5) then
        return
    end
    ssleep(1)
    local 纵向距离, 横向距离 = 185, 86
    log(已选择干员, #已选择干员)
    for i = 1, #已选择干员 do
        local name = 已选择干员[i].name
        local skill = all_opers_battle_info[name].skill
        local alternate_skill = all_opers_battle_info[name].alternate_skill
        log(i, name, alternate_skill, skill)
        if alternate_skill > 0 then
            if i <= 4 then
                tap({ scale(362 + 横向距离 * (alternate_skill - 1)), scale(268 + 纵向距离 * (i - 1)) })
            elseif i <= 9 then
                tap({ scale(970 + 横向距离 * (alternate_skill - 1)), scale(163 + 纵向距离 * (i - 5)) })
            else
                tap({ scale(1578 + 横向距离 * (alternate_skill - 1)), scale(268 + 纵向距离 * (i - 10)) })
            end
            ssleep(.01)
        end
        if skill > 0 then
            if i <= 4 then
                tap({ scale(362 + 横向距离 * (skill - 1)), scale(268 + 纵向距离 * (i - 1)) })
            elseif i <= 9 then
                tap({ scale(970 + 横向距离 * (skill - 1)), scale(163 + 纵向距离 * (i - 5)) })
            else
                tap({ scale(1578 + 横向距离 * (skill - 1)), scale(268 + 纵向距离 * (i - 10)) })
            end
            ssleep(.01)
        end
    end
end


zl.选择干员 = function(idx) --选择当页干员
    if not wait(function()
            if findAny({ "萨卡兹_初始招募", "战略返回" }) then
                log.debug()
                return true
            end
            if findOne("返回确认界面") then
                log.debug()
                -- 虽然不知道会不会走这儿
                tap("左取消")
                disappear("返回确认界面")
                -- 不等会怎么样呢，有时会闪
                ssleep(.5)
            end
            log(idx)
            if idx >= 1 and idx <= 12 then
                -- 指定
                tap("近卫招募列表" .. idx)
                findTap("确认招募")
                tap("开包skip")
            elseif idx == -1 then
                -- 助战自动
                zl_help_fight(0, '萨卡兹_初始招募')
            else
                stop("请设置近卫干员序号(1~12)", '', true, false)
            end
        end, 120) then
        return
    end
end

zl.shop_get_coin = function()
    if not wait(function()
            tap({ scale(244), scale(536) })
        end, 2) then
    end
    log('诡意行商取钱开始')
    if not appear("诡意行商投资", 1) then return true end
    if not wait(function()
            if findOne("诡意行商余额提取") then return true end
            tap("诡意行商投资")
        end) then
        return
    end
    if not wait(function()
            if findOne("诡意行商余额提取页面") then return true end
            tap("诡意行商余额提取")
        end) then
        return
    end

    wait(function(reset_wait_start_time)
        -- 不能投情况
        if not findOne("诡意行商余额提取页面") then
            tap("诡意行商余额提取")
            appear("诡意行商余额提取页面")
        end
        if findOne("正在提交反馈至神经") then
            reset_wait_start_time()
        end
        tap("诡意行商余额提取")
        appear("诡意行商余额提取页面")
        tap("诡意行商确认提取")
    end, 10)
end

--通用的  肉鸽的第一次作战编队 直接引用就可以
zl.first_edit_team = function()
    if not wait(function()
            if findOne("快捷编队") then return true end
            tap("进入")
        end, 10) then
        return false
    end

    if not wait(function()
            if findOne("确认招募") then return true end
            tap("快捷编队")
        end, 10) then
        return false
    end

    if not wait(function()
            if findOne("攻击范围") and
                (zl_skill_idx ~= 2 or zl_skill_idx == 2 and findOne("战略二技能")) then
                tap("近卫招募列表2") --第2个干员
                ssleep(.2)
                tap("近卫招募列表3") --第3个干员
                return true
            end
            tap("近卫招募列表1")
            if not appear("攻击范围", 1) then return end
            if zl_skill_idx == 2 then
                tap("战略二技能")
                if not appear("战略二技能", 1) then return end
            end
        end, 10) then
        return false
    end

    if not wait(function()
            if not findOne("确认招募") then return true end
            tap("确认招募")
        end, 10) then
        return false
    end

    if not appear("快捷编队") then return false end
    return true
end

--肉鸽作战名字检测 type是肉鸽类型，是作战关卡名字检测的范围
zl.fight_name_ocr = function(rogueType)
    local rogueType = rogueType or '界园'
    local fight1ocr = {}
    --zl_fight_name 这个可修改替换为不同肉鸽的作战关卡名字
    log('rogueType: ', rogueType)
    local fight_name = {
        ['萨卡兹'] = {
            ["坏邻居"] = { "坏", "邻", "居" },
            ["安全检查"] = { "安", "全", "检", "熔", "炉" },
            ["夺路而逃"] = { "夺", "路", "逃" },
            ["公害"] = { "公", "害" },
            ["冰川期"] = { "冰", "川", "期" },
        },
        ['萨米'] = {
            ["待宰的兽群"] = { "待", "宰", "兽", '群' },
            ["死囚之夜"] = { "囚", "死" },
            ["度假村冤魂"] = { "度", "假", "村", "冤", "魂" },
            ["事不过四"] = { "事", "过", "四" },
            ["苔手"] = { "苔", "手" },
        },
        ['水月'] = {
            ["蓄水池"] = { "池", "水", "池" },
            ["虫群横行"] = { "虫", "群", "横", "行" },
            ["射手部队"] = { "射", "手", "部", "队" },
            ["共生"] = { "共", "生" },
            ["互助"] = { "互", "助" },
        },
        ['界园'] = {
            ["老戏骨"] = { "老", "戏", "骨" },
            ["正经生意"] = { "正", "经", "生", "意" },
            ["赶集"] = { "赶", "集" },
            ["狡鼷三窟"] = { "狡", "三", "窟" },
            ["驱虫"] = { "驱", "虫" },
            ["凭票入内"] = { "凭", "票", "入", "内" },
        },
    }
    zl_fight_name = fight_name[rogueType]
    log(zl_fight_name)
    if not wait(function()
            fight1ocr = ocr_ret(rogueType .. "_作战检测范围")
            log.debug(fight1ocr)
            if #fight1ocr > 1 then
                for name, chars in pairs(zl_fight_name) do
                    if string.finds(fight1ocr, chars) then
                        now_fight_name = name
                        return true
                    end
                end
                log("不知道什么作战：" .. fight1ocr)
                return
            else
                log("更换ocr")
                fight1ocr = ocrex_ret(rogueType .. "_作战检测范围")
                log.debug(fight1ocr)
                if #fight1ocr > 1 then
                    for name, chars in pairs(zl_fight_name) do
                        if string.finds(fight1ocr, chars) then
                            now_fight_name = name
                            return true
                        end
                    end
                    log("不知道什么作战2:" .. fight1ocr)
                    return
                end
            end
        end, 5, .2) then
        findTap('战略退出')
        return false
    end

    return true
end

zl.招募近卫 = function(type)
    local rogue_tpye = type or ''
    log('招募近卫')
    if not wait(function()
            tap(rogue_tpye .. '_' .. "近卫招募券")
            tap("招募说明关闭")
            if not findOne(rogue_tpye .. '_' .. "初始招募") and findOne("确认招募") then
                return true
            end
        end, 10) then
        return false
    end

    if not wait(function()
            if findAny({ rogue_tpye .. '_' .. "初始招募", "战略返回" }) then
                log.debug()
                return true
            end
            if findOne("返回确认界面") then
                log.debug()
                -- 虽然不知道会不会走这儿
                tap("左取消")
                disappear("返回确认界面")
                -- 不等会怎么样呢，有时会闪
                ssleep(.5)
            end
            log.debug(zl_best_operator)
            local idx = str2int(zl_best_operator, -1)

            if idx >= 1 and idx <= 12 then
                -- 指定
                tap("近卫招募列表" .. (zl_best_operator or 1))
                findTap("确认招募")
                tap("开包skip")
            elseif idx == -1 then
                -- 助战自动
                zl_help_fight(0, rogue_tpye .. '_' .. '初始招募', rogue_tpye)
            else
                stop("请设置近卫干员序号(1~12)", '', true, false)
            end
        end, 120) then
        return false
    end
    return true
end

zl.招募医疗 = function(type)
    local rogue_tpye = type or ''
    if not single_man_operation then
        log("招募医疗")
        if not wait(function()
                if findOne("确认招募") then return true end
                if findOne("剿灭说明") then tap("剿灭说明") end
                tap(rogue_tpye .. '_' .. "医疗招募券")
                tap("招募说明关闭")
            end, 10) then
            return false
        end
        appear('战略助战')
        if not wait(function()
                if findAny({ rogue_tpye .. '_' .. "初始招募", "战略返回" }) then
                    log.debug()
                    return true
                end
                if findOne("返回确认界面") then
                    log.debug()
                    -- 虽然不知道会不会走这儿
                    tap("左取消")
                    disappear("返回确认界面")
                    -- 不等会怎么样呢，有时会闪
                    ssleep(.5)
                end
                tap("近卫招募列表" .. 1)
                findTap("确认招募")
                tap("开包skip")
            end, 120) then
            return false
        end
    else
        log("不招募医疗")
        if not wait(function()
                if findOne("确认招募") then return true end
                if findOne("剿灭说明") then tap("剿灭说明") end
                tap(rogue_tpye .. '_' .. "医疗招募券")
                tap("招募说明关闭")
            end, 10) then
            return false
        end

        if not wait(function()
                tap("放弃招募")
                if findOne("剿灭说明") then tap("剿灭说明") end
                if not findOne("确认招募") then return true end
            end, 10) then
            return false
        end

        if not wait(function()
                tap("右右确认")
                if findOne("剿灭说明") then tap("剿灭说明") end
                if findOne(rogue_tpye .. '_' .. "初始招募") then return true end
            end, 10) then
            return false
        end
    end
    return true
end

zl.放弃招募辅助 = function(type)
    local rogue_tpye = type or ''
    -- 第二人，这里三步带了 剿灭说明 处理
    if not wait(function()
            if findOne("确认招募") then return true end
            if findOne("剿灭说明") then tap("剿灭说明") end
            tap(rogue_tpye .. '_' .. "辅助招募券")
            tap("招募说明关闭")
        end, 10) then
        return false
    end

    if not wait(function()
            tap("放弃招募")
            if findOne("剿灭说明") then tap("剿灭说明") end
            if not findOne("确认招募") then return true end
        end, 10) then
        return false
    end

    if not wait(function()
            tap("右右确认")
            if findOne("剿灭说明") then tap("剿灭说明") end
            if findOne(rogue_tpye .. '_' .. "初始招募") then return true end
        end, 10) then
        return false
    end
    return true
end

zl.大地图右滑 = function()
    gesture({
        {
            point = { { scale(1831), scale(864) }, { scale(915), scale(864) } },
            start = 0,
            duration = 500,
        },
    })
    ssleep(.5)
    tap({ scale(894), scale(864) })
    ssleep(.3)
end

-- 退出重进
zl.重置大地图 = function()
    findTap("战略返回")
    ssleep(.2)
    wait(function()
        tap({ scale(1708), scale(900) }) --采用固定的坐标，一直点击直到出现 '战略返回'
        ssleep(.2)
        if findOne("战略返回") then return true end
    end, 5)
    ssleep(.1)
end

zl.创建大地图二维数组 = function(nrows, ncols, initialValue)
    local matrix = {}
    for i = 1, nrows do
        matrix[i] = {}
        for j = 1, ncols do
            matrix[i][j] = initialValue or 0 -- 使用默认值0或者指定的初始值
        end
    end
    return matrix
end

zl.find_best_path = function(map, score_table)
    local rows = #map
    local cols = #map[1]

    -- 初始化dp和prev表
    local dp = {}
    local prev = {}
    for i = 1, rows do
        dp[i] = {}
        prev[i] = {}
        for j = 1, cols do
            dp[i][j] = -math.huge -- 负无穷大表示不可达
            prev[i][j] = nil
        end
    end

    -- 处理第一列
    for i = 1, rows do
        if map[i][1] ~= 0 then
            local node = map[i][1]
            local score_val = score_table[node.NodeType]
            if score_val then
                dp[i][1] = score_val
            else
                -- 如果score_table中未定义NodeType，使用0分
                dp[i][1] = 0
            end
        end
    end

    -- 处理第2列到最后一列
    for j = 2, cols do
        for i = 1, rows do
            if map[i][j] ~= 0 then
                local current_node = map[i][j]
                local current_score = score_table[current_node.NodeType] or 0

                -- 检查前一列的所有节点
                for k = 1, rows do
                    if map[k][j - 1] ~= 0 then
                        local prev_node = map[k][j - 1]
                        local nextNodes = prev_node.NextNode
                        -- 检查NextNode中是否包含当前节点坐标[i, j]
                        for _, coord in ipairs(nextNodes) do
                            if coord[1] == i and coord[2] == j then
                                local total_score = dp[k][j - 1] + current_score
                                if total_score > dp[i][j] then
                                    dp[i][j] = total_score
                                    prev[i][j] = k -- 记录前驱节点的行号
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    -- 在最后一列找到最大分数和对应的行号
    local max_score = -math.huge
    local best_row = nil
    for i = 1, rows do
        if dp[i][cols] > max_score then
            max_score = dp[i][cols]
            best_row = i
        end
    end

    if best_row == nil then
        return nil, nil -- 没有路径
    end

    -- 回溯路径
    local path = {}
    local j = cols
    local i = best_row
    while j >= 1 do
        table.insert(path, 1, { i, j }) -- 在头部插入，保持顺序从第一列到最后一列
        if j == 1 then
            break
        end
        i = prev[i][j]
        j = j - 1
    end

    return path, max_score
end

--肉鸽挑选节点，改关卡类型和坐标位置，可以适应其他肉鸽
zl.selection_node = function(select_number, rogueType)
    local rogueType = rogueType or '萨卡兹'
    local select_number = select_number or 0
    local paths = { -1, -1, -1, -1, -1 }
    --紧急 普通 普通2 不期  商店 ，越在后面优先级越高
    --有时候普通战斗关卡有两种颜色好像（  都放进来好了
    if rogueType == '萨卡兹' then
        关卡类型 = { "822E2E", "7268A9", "5B528D", "2E757F", "115340" }
    elseif rogueType == '萨米' then
        关卡类型 = { "994649", "7268A9", "468C9A", "4890A2", "2B6D5B" }
    elseif rogueType == '水月' then
        --紧急B35480 普通856BE2 兴致盎然 得偿所愿和商店一样 地区委托0EC6C8 不期而遇1ECBCE  商店149D81
        关卡类型 = { "B35480", "856BE2", "0EC6C8", "1ECBCE", "149D81" }
    end

    if select_number > 3 then
        log('校准线路次数超过3次，放弃本次探索重新来')
        back()
        path.跳转("首页")
    end
    if not wait(function()
            local current = time()
            if findOne_interval > 0 and current - findOne_last_time > findOne_interval then
                findOne_last_time = time()
                keepCapture()
            end

            -- 遍历关卡类型
            for i = 1, #point[rogueType .. '_关卡节点坐标列表'] do
                local xx = point[rogueType .. '_关卡节点坐标列表' .. i]
                local path_pos = xx[1] .. "|" .. xx[2]
                for j = 1, #关卡类型 do
                    local path_pos_color = path_pos .. "|" .. 关卡类型[j]
                    --print(path_pos_color)
                    local res = cmpColorEx(path_pos_color, 0.9)
                    if res == 1 then
                        print(rogueType, path_pos_color)
                        paths[i] = j
                    end
                end
            end
            -- print(paths)
            --找到的话就退出，至少会是1，如果没有找到则是{ -1, -1, -1, -1, -1 }
            for _, v in ipairs(paths) do
                if v > 0 then return true end
            end
        end, 3, .05) then
        log('找不到节点，重新校准路线')
        if not zl_repos_path(rogueType .. '_放弃本次探索') then return end
        return zl.selection_node(select_number + 1, rogueType)
    end

    --print(paths)
    local findMaxCoordinate = function(coords) --五个坐标里面取出权重最大的那个
        local maxCoord = coords[1]
        local maxIndex = 1
        for i = 2, #coords do
            if coords[i] > maxCoord then
                maxCoord = coords[i]
                maxIndex = i
            end
        end
        return maxIndex
    end

    local maxIndex = findMaxCoordinate(paths)
    --print("最大坐标的索引是：" .. maxIndex)
    if maxIndex ~= 0 and maxIndex ~= nil then
        --print("最大坐标的索引是：" .. maxIndex.."权重值为："..全部路径权重[maxIndex])
        return maxIndex, paths[maxIndex]
    else
        return -1, -1
    end
end

--不期而遇事件处理
zl_event_solve = function(xx, 战略帮助)
    --local 事件处理 = function(xx)
    local 战略帮助 = 战略帮助 or "战略帮助"
    local xx = xx or 1
    log('不期而遇事件处理：' .. xx)
    if not wait(function(reset_wait_start_time)
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            if findOne(战略帮助) then return true end
            tap("不期而遇选项点击列表" .. xx)
        end, 20, .05) then
        return false
    end
    return true
end

--肉鸽借助战
--reflashNum重新定位初始，初始给0
--初始招募界面 例如'放弃本次探索' '萨米_放弃本次探索'
--肉鸽类型  例如  '萨卡兹'  '萨米'  '水月'
zl_help_fight = function(reflashNum, 初始招募界面, 肉鸽类型, retry)
    local retry = retry or 0
    local 招募界面 = 初始招募界面 or '放弃本次探索'
    local 肉鸽类型 = 肉鸽类型 or '默认'
    reflashNum = reflashNum or 0
    single_man_operation = true
    if reflashNum > 8 then
        log("助战刷新次数超过8次")
        return false
    end
    if not wait(function()
            if findOne("战略助战界面") then return true end
            tap("战略助战")
        end, 5) then
        return
    end

    local operator
    if not wait(function()
            operator = ocr("战略助战干员范围")
            if #operator > 3 then return true end
        end, 5) then
        return false
    end

    local name2point = table.reduce(operator, function(a, c)
        a[c.text] = c
        return a
    end, {})

    --不同肉鸽试用的助战组不一样  感觉萨米和水月可以用一套的

    log('肉鸽类型: ', 肉鸽类型)
    if 肉鸽类型 == '萨米' then
        order = {
            { "百炼嘉维尔", 99, 2 },
            { "圣约送葬人", 99, 2 },
            -- { "乌尔比安", 99, 1 }, 好像反馈打不过
            { "羽毛笔", 99, 2 },
            { "海沫", 99, 2 },
        }
    elseif 肉鸽类型 == '水月' then
        order = {
            { "百炼嘉维尔", 99, 2 },
            { "圣约送葬人", 99, 2 },
            -- { "乌尔比安", 99, 1 },
            --{ "羽毛笔", 99, 2 },
            --{ "海沫", 99, 2 },
        }
    elseif 肉鸽类型 == '界园' then
        order = {
            { "百炼嘉维尔", 99, 2 },
            { "圣约送葬人", 99, 2 },
            --{ "耀骑士临光", 99, 1 },
            { "煌", 99, 1 },
        }
    elseif 肉鸽类型 == '黑流树海' then
        order = {
            { "百炼嘉维尔", 99, 2 },
            { "圣约送葬人", 99, 2 },
            { "煌", 99, 1 },
            { "怒潮凛冬", 99, 3 },
            { "丰川祥子", 0, 2 },
        }
    else
        order = {
            { "百炼嘉维尔", 99, 2 },
            { "圣约送葬人", 99, 2 },
            { "煌", 99, 1 }, --辅助，医疗这些都得开技能，也能不开
            { "耀骑士临光", 99, 1 },
            { "乌尔比安", 99, 1 },
        }
    end

    local best = table.findv(order, function(x) return name2point[x[1]] end)
    if not best then
        log("助战找不到所需干员，准备刷新", reflashNum)
        appear('肉鸽刷新助战蓝', 30)
        tap("肉鸽刷新助战蓝")
        reflashNum = reflashNum + 1
        ssleep(2) --偶尔有机子卡死，给多一点延迟，稳！
        return zl_help_fight(reflashNum, 招募界面, 肉鸽类型, retry + 1)
    end
    -- log("best", best)
    -- if not best then return point.战略助战干员列表1, 0, 1 end
    local p = name2point[best[1]]
    p = { p.l, p.t }
    tap(p)
    disappear("战略助战界面", 5)
    toast('再次判断助战干员')
    --再判断一次是否符号招募要求
    local target_operator = { '羽毛', '送葬', '圣', '嘉维尔', '海沫', '煌', '骑士', '临光', '比安', "怒潮", "丰川", "祥子" }
    if not wait(function()
            local target_best = ocr('战略助战确认干员范围')
            if target_best[1] then
                for _, v in ipairs(target_operator) do
                    if string.find(target_best[1].text, v, 1, true) then
                        log('符合的干员名字')
                        return true
                    end
                end
            end
            log(target_best.text)
            if target_best.text == best[1] then return true end
        end, 3, .2) then
        log('点击的助战干员名字不符合: ')
        reflashNum = reflashNum + 1
        tap({ 141, 54 })
        ssleep(2) --偶尔有机子卡死，给多一点延迟，稳！
        if retry > 6 then
            log("助战刷新次数超过6次")
            return false
        end
        return zl_help_fight(reflashNum, 招募界面, 肉鸽类型)
    end
    reflashNum = 0
    --默认为单人助战，如果是以下干员则再去招募个医疗
    if best[1] == "百炼嘉维尔" or best[1] == '乌尔比安' then
        single_man_operation = false
    end
    zl_skill_times = best[2]
    zl_skill_idx = best[3]
    --招募界面出来之后的，‘初始招募’界面色点
    local 初始招募界面 = 初始招募界面 or "初始招募"
    wait(function()
        if findAny({ "萨卡兹_希望源石锭界面", '水月_希望源石锭钥匙界面', "肉鸽_右上角希望" }) then return true end
        if findOne("战略助战确认界面") then tap("战略助战确认") end
        if not findOne("战略助战确认界面") then tap("开包skip") end
        if findOne("黑流树海_右上角希望") then return true end
    end, 10)
end

-- 集成战略干员摆放 摆放三个人， 写的有点乱 可以优化
zl_deploy = function(deploy_table, number)
    local number = number or 3
    for i = 1, number do
        if not wait(function()
                if findOne("干员费用够列表1") then return true end
                if not findOne("生命值") then
                    log("没找到生命值，继续等待")
                end
            end, 30) then
            return false
        end
        if i > 3 then i = 3 end
        wait(function()
            tap("干员费用够列表1")
            disappear("干员费用够列表1", 0.5)
            nDeploy3(1, deploy_table[i], 4 - i)

            wait(function()
                if findOne("生命值") then return true end
                tap("开始行动1")
            end)

            if i == 1 then
                if not appear("干员部署_黄", 5) then return true end
            elseif i == 2 then
                if not appear("干员部署_2蓝", 8) then return true end
            elseif i == 3 then
                if not appear("干员部署_蓝", 5) then return true end
            end
        end, 20)
    end
end

-- 集成战略干员摆放 摆放两个人的
zl_deploy2 = function(deploy_table)
    local number = 2
    if single_man_operation then number = 1 end
    for i = 1, number do
        if not wait(function()
                if findOne("干员费用够列表1") then return true end
                if not findOne("生命值") then
                    log("没找到生命值，继续等待")
                end
            end, 30) then
            return false
        end
        wait(function()
            tap("干员费用够列表1")
            disappear("干员费用够列表1", 0.5)
            nDeploy3(1, deploy_table[i], 4 - i)

            wait(function()
                if findOne("生命值") then return true end
                tap("开始行动1")
            end)

            if i == 1 then
                if disappear("干员部署_黄", 4) then return true end
            elseif i == 2 then
                if disappear("干员部署_2蓝", 2) then return true end
            end
        end, 20)
    end
end

-- 肉鸽重新校准路径
zl_repos_path = function(放弃本次探索)
    local 放弃本次探索 = 放弃本次探索 or '放弃本次探索'
    findTap("战略返回")
    local t = time()
    if not wait(function()
            if findOne(放弃本次探索) then return true end
            if time() - t > 1 * 1000 then --有时候前面战略返回点击了也不会退出，间隔1s再点击一次
                t = time()
                tap("战略返回")
            end
        end, 10) then
        log('超时未找到等待开始页面标题,准备结束')
        return path.跳转('首页')
    end
    local t = time()
    wait(function()
        tap({ scale(1708), scale(900) }) --采用固定的坐标，一直点击直到出现 '战略返回'
        if time() - t > 1 * 1000 then    --有时候前面战略返回点击了也不会退出，间隔1s再点击一次
            t = time()
            tap("战略确认")
        end
        if findOne("战略返回") then return true end
    end, 5)
end

zl_swip = function(left, swip_dis, nodelay)
    --活动商店滑动,滑动三个商品的距离
    local duration
    local finger
    local delay
    local swip_dis = swip_dis or 1550
    if left then
        local x1 = scale(200)
        local x2 = scale(10000 / 720 * 1080)
        local y1 = scale(810)
        duration = 400
        finger = { { point = { { x1, y1 }, { x2, y1 } }, duration = duration } }
        delay = 750
    else
        local x = scale(64) --滑动容器内较左侧
        local y = scale(655)
        local y2 = scale(494)
        --修改x2坐标，x+滑动距离,两个物品1031,三个物品1550
        local x2 = scale(swip_dis + x) --不可超出1920 目标x点
        local x3 = scale(1760)         --不会点到物品 X3Y3为点击的点，用于防止滑动
        local y3 = scale(790)
        local slids = 50
        local slidd = 200
        local taps = slids + slidd + 150
        local tapd = 200
        local downd = taps + 100
        duration = downd
        finger = {
            { point = { { x, y }, { x, y2 } },    start = 0,     duration = downd },
            { point = { { x2, y }, { x2, y3 } },  start = slids, duration = slidd },
            { point = { { x3, y3 }, { x3, y3 } }, start = taps,  duration = tapd },
        }
        delay = 250
    end
    log(JsonEncode(finger))
    gesture(finger)
    sleep(duration + (nodelay and 0 or delay))
    return nodelay and delay or 0
end

--1常规行动，也就是肉鸽主界面   2,在点击肉鸽列表的时候，选择的肉鸽
--zl_navigation('萨米_常规行动', '探索者的银淞止境进入主题')
--zl_navigation('水月_常规行动', '水月与深蓝之树进入主题')
--zl_navigation('常规行动', '傀影与猩红孤钻')
zl_navigation = function(常规行动, 需要点击的肉鸽)
    local 常规行动 = 常规行动 or '常规行动'
    local 需要点击的肉鸽 = 需要点击的肉鸽 or '傀影与猩红孤钻'
    -- 省略跳转
    if findOne(常规行动) then return true end

    path.跳转("首页")

    tap("面板作战")
    if not appear("主页") then return false end

    if not wait(function()
            if findOne("在长期探索") then return true end
            tap("集成战略")
        end, 5) then
        return false
    end

    if not wait(function()
            if findOne("在长期探索") then
                tap("查看全部主题")
                disappear('查看全部主题')
            end
            if findOne("选择集成战略列表界面") then return true end
        end, 10) then
        return
    end

    appear('选择集成战略列表界面')
    ssleep(1) --太快了停顿一会，稳!
    if not wait(function()
            log('滑动')
            -- --if not findOne("选择集成战略列表界面") then return true end --防止滑动出错
            -- gesture({
            --     {
            --         point = { { screen.width * 0.3,   screen.height * 0.95 },
            --             { screen.width * 0.8,             screen.height * 0.95 },
            --             { screen.width * 0.8 - scale(10), screen.height * 0.95 },
            --             { screen.width * 0.8 + scale(10), screen.height * 0.95 } },
            --         start = 0,
            --         duration = 800,
            --     },
            -- })
            zl_swip(true) --滑动到最左边
            ssleep(.5)
            if appear('傀影与猩红孤钻', 2) then return true end
            --作为定位，是否滑到了最左边
        end, 10) then
        return zl_navigation(常规行动, 需要点击的肉鸽)
    end

    if 需要点击的肉鸽 == '界园_进入主题' or 需要点击的肉鸽 == '黑流树海_进入主题' then
        log('滑动2')
        zl_swip(false, 1101)
    end

    if not wait(function()
            --if not findOne("选择集成战略列表界面") then return true end --防止出错
            if findOne(常规行动) then return true end
            tap(需要点击的肉鸽)
        end, 15) then
        return zl_navigation(常规行动, 需要点击的肉鸽)
    end

    log('导航成功')
    return true
end

-- 肉鸽每8小时做日常
zl_eight_daily = function()
    if not zl_no_waste_last_time or time() - zl_no_waste_last_time > 8 * 3600 *
        1000 then
        -- 并非首次
        if zl_no_waste_last_time then
            zl_no_waste_last_time = nil
            restart_account()
            -- saveConfig("hideUIOnce", "true")
            -- save_extra_mode(extra_mode, extra_mode_multi)
            -- restartPackage()
        end
        -- 首次
        if zl_no_waste then
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end

        zl_no_waste_last_time = time()
    end
end

--肉鸽 等级源石锭检查
zl_level_coin_inquire = function(常规行动, 等级检测范围, 源石锭检测范围)
    if zl_disable_inspect_level then return end
    local 常规行动 = 常规行动 or '常规行动'
    local 等级检测范围 = 等级检测范围 or '等级检测范围'
    local 源石锭检测范围 = 源石锭检测范围 or '源石锭检测范围'
    if zl_level_enough then
        if zl_no_waste then
            -- todo
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end
        log("结束zl_level")
        return true
        -- stop("肉鸽结束", '', false, true)
    end

    if zl_coin_enough then
        if zl_no_waste then
            -- todo
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end
        log("结束zl_coin")
        return true
        -- stop("肉鸽结束", '', false, true)
    end

    -- 检测等级 ，输入检测范围的名字
    --例如   zl_number_check()
    local zl_number_check = function(检测范围)
        --if not (str2int(zl_max_level, 0) > 0) then return end
        local 检测范围 = 检测范围 or {}
        if not findOne(常规行动) then return end
        local prex = -1
        local ans = wait(function()
            ssleep(.5)
            local r = ocro(检测范围)
            log.debug(r)
            -- if x == nil or type(x) ~= "string" or #x == 0 then
            --     return 0
            -- end
            if not r then r = "" end
            x = str2int(r:match("%d+"), -1)
            log.debug(type(x), x)
            if x >= 0 and x <= 999 then return x end
            prex = x
        end, 0.7) --给点检测时间
        return ans
    end

    local zl_level = zl_number_check(等级检测范围) or -1
    toast('等级:' .. zl_level)
    if not zl_level_enough and zl_level == str2int(zl_max_level, 10000) then
        zl_level_enough = true
        captureqqimagedeliver("INFO", "肉鸽任务完成", table.join(qqmessage,
                ' ') .. " " ..
            (zl_level or '') .. "等级已满")
        log("等级已满")
        return true
    end

    local zl_coin = zl_number_check(源石锭检测范围) or -1
    if zl_coin == 999 then zl_skip_coin = true end --源石锭999的话跳过投币，避免浪费时间
    toast('源石锭:' .. zl_coin)
    if not zl_coin_enough and zl_coin >= str2int(zl_max_coin, 10000) then
        zl_coin_enough = true
        captureqqimagedeliver("INFO", "肉鸽任务完成", table.join(qqmessage,
                ' ') .. " " ..
            (zl_coin or '') .. "源石锭已满")
        log("源石锭已满")
        return true
    end

    -- 等级/源石锭 阶段性通知
    if not zl_captcha_time or time() - zl_captcha_time > 3600 * 1000 then
        zl_captcha_time = time()
        local info = ''
        if str2int(zl_max_level, 0) > 0 then
            info = info .. zl_level .. '/' .. zl_max_level .. ' '
        end
        if str2int(zl_max_coin, 0) > 0 then
            info = info .. zl_coin .. '/' .. zl_max_coin
        end
        captureqqimagedeliver("INFO", "肉鸽任务推送",
            table.join(qqmessage, ' ') .. " " .. info)
    end
end

--肉鸽放弃探索
zl_abandon_rougelike = function(常规行动, 继续探索, 放弃探索)
    -- 放弃探索
    local 常规行动 = 常规行动 or '常规行动'
    local 继续探索 = 继续探索 or "萨米_继续探索"
    local 放弃探索 = 放弃探索 or "萨米_放弃本次探索"
    if findOne(放弃探索) then
        if not wait(function()
                if findOne("返回确认界面") then return true end
                tap(放弃探索)
            end, 5) then
            log.debug()
            -- 无法直接放弃的情况 不处理
            if not wait(function()
                    if not findOne(常规行动) then return true end
                    tap(继续探索)
                    ssleep(.5)
                    log.debug()
                end, 5) then
                return false
            end

            if not wait(function()
                    if findOne(常规行动) then return true end
                    -- 第一次数据更新处理
                    if findAny({
                            "面板", "活动公告返回", "签到返回", "签到返回黄",
                            "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
                        }) then
                        jumpout = true
                        return true
                    end
                    tap("战略确认")
                end, 5) then
                return false
            end
            if jumpout then return end
        end
        if not wait(function(reset_wait_start_time)
                if findOne("正在提交反馈至神经") then
                    reset_wait_start_time()
                end
                if findOne("返回确认界面") then
                    tap("右右确认")
                    return
                end
                tap("战略确认")
                if findOne(常规行动) and not findOne(放弃探索) then
                    return true
                end
                -- 第一次数据更新处理
                if findAny({
                        "面板", "活动公告返回", "签到返回", "签到返回黄",
                        "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
                    }) then
                    jumpout = true
                    return true
                end
            end, 30) then
            return
        end
    end
end

--肉鸽购买所需收藏品
zl_shop_check_goods = function()
    if type(zl_need_goods) ~= 'string' or #zl_need_goods:trim() == 0 then
        return
    end
    local need_goods = zl_need_goods:filterSplit()
    local goods1 = table.join(map(function(x) return x.text end,
        ocr("战略第一行商品范围")))
    local goods2 = table.join(map(function(x) return x.text end,
        ocr("战略第二行商品范围")))
    local goods = table.join({ goods1, goods2 })
    if goods:includes(need_goods) then
        stop("已遇到所需商品" .. goods, '', true, true)
    end
    log("未找到商品", goods, need_goods)
end

--肉鸽购买商店
zl_shop_buy = function()
    local p = appear(point["战略商品列表"], 1)
    p = findAny(point["战略商品列表"])
    if not p then return end
    if not wait(function()
            local x, y = point[p]:match("(%d+)" .. coord_delimeter .. "(%d+)")
            tap({ tonumber(x) - scale(111), tonumber(y) - scale(100) })
            if disappear(p, 1) then return true end
        end) then
        return
    end

    disappear("诡意行商离开", 1)
    if not wait(function(reset_wait_start_time)
            tap("诡意行商确认投资")
            if findOne("诡意行商离开") then return true end
            if findOne("确认招募") then
                local start_time = time()
                if not wait(function(reset_wait_start_time2)
                        if findOne("编队") then return true end
                        if findOne("返回确认界面") then
                            if time() - start_time < 2000 then
                                tap("左取消")
                            else
                                tap("右确认")
                            end
                            disappear("返回确认界面")
                            ssleep(.5)
                        end
                        if findOne("正在提交反馈至神经") then
                            reset_wait_start_time()
                            reset_wait_start_time2()
                        end
                        tap("近卫招募列表" .. 1)
                        findTap("确认招募")
                        tap("开包skip")
                        if findOne("肉鸽弹出窗口") then
                            tap("右确认")
                        end
                    end, 10) then
                    return
                end
            end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
        end, 10) then
        return
    end
    return true
end

zl_shop_coin = function()
    log("肉鸽投币处理")
    -- if not appear("诡意行商投资", 1) then return goto_next_level() end
    if not wait(function()
            if findOne("诡意行商投资") then return true end
            if findOne("肉鸽弹出窗口") then
                tap("左取消")
                ssleep(0.2)
            end
        end, 5) then
        return
    end

    if not wait(function()
            if findOne("诡意行商投币") then return true end
            if findOne("诡意行商投资入口") then return true end
            tap("诡意行商投资")
            if findOne("肉鸽弹出窗口") then
                tap("左取消")
                ssleep(0.2)
            end
        end, 5) then
        return
    end
    if not wait(function()
            if findOne("诡意行商投资入口") then return true end
            tap("诡意行商投币")
        end) then
        return
    end

    local coin_no_notification = sample("投币提示")

    wait(function(reset_wait_start_time)
        -- 不能投情况
        if not findOne("诡意行商投资入口") then return true end
        if findOne("投资受限白") then return true end
        if findOne("正在提交反馈至神经") then
            reset_wait_start_time()
        end
        if not findOne(coin_no_notification) then reset_wait_start_time() end
        tap("诡意行商确认投资")
    end, 7)
end

--肉鸽等级满了，放弃行动后回到首页再截个图
zl_level_coin_enough = function()
    if zl_level_enough or zl_coin_enough then
        captureqqimagedeliver("INFO", "肉鸽行动结束",
            table.join(qqmessage, ' ') .. " 放弃行动后")

        wait(function(reset_wait_start_time)
            if not disappear("常规行动") then return true end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            tap("战略确认")
        end, 5)
        return
    end
end

--肉鸽初始放弃探索
zl_abandon_explore = function(type)
    local rogue_tpye = type or ''
    -- 放弃探索
    if findOne(rogue_tpye .. "_放弃本次探索") then
        if not wait(function()
                if findOne("返回确认界面") then return true end
                tap(rogue_tpye .. "_放弃本次探索")
            end, 5) then
            log.debug()
            -- 无法直接放弃的情况 不处理
            if not wait(function()
                    if not findOne(rogue_tpye .. "_常规行动") then return true end
                    tap(rogue_tpye .. "_继续探索")
                    ssleep(.5)
                    log.debug()
                end, 5) then
                return
            end

            if not wait(function()
                    if findOne(rogue_tpye .. "_常规行动") then return true end
                    -- 第一次数据更新处理
                    if findAny({
                            "面板", "活动公告返回", "签到返回", "签到返回黄",
                            "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
                        }) then
                        jumpout = true
                        return true
                    end
                    tap("战略确认")
                end, 5) then
                return
            end
            if jumpout then return end
        end
        if not wait(function(reset_wait_start_time)
                if findOne("正在提交反馈至神经") then
                    reset_wait_start_time()
                end
                if findOne("返回确认界面") then
                    tap("右右确认")
                    return
                end
                tap("战略确认")
                if findOne(rogue_tpye .. "_常规行动") and not findOne(rogue_tpye .. "_放弃探索") then
                    return true
                end
                -- 第一次数据更新处理
                if findAny({
                        "面板", "活动公告返回", "签到返回", "签到返回黄",
                        "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
                    }) then
                    jumpout = true
                    return true
                end
            end, 30) then
            return false
        end
    end
    return true
end

-- 最后require,不然会找不到函数
require("mizuki")
require("sarkaz")
require("sami")
require("sui")
require("black")
