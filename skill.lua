discover = still_wrapper(function(operators, pngdata, pageid, mood_only)
    -- 异步滑动
    -- local delay = swipo(false, true)
    -- local start_time = time()
    -- local w, h, color = getScreenPixel(table.unpack(point.第一干员卡片范围))

    local prewhite = 0
    -- TODO 是这个导致卡片没识别到吗
    local y = scale(383)
    local corner = {}
    for x = scale(600), scale(1590) do
        if cmpColor(x, y, 'FFFFFF', default_findcolor_confidence) == 1 then
            prewhite = prewhite + 1
        elseif prewhite > scale(5) and
            cmpColor(x, y, '898989', default_findcolor_confidence) == 1 then
            prewhite = 0
            table.insert(corner, x)
        end
    end
    log(113, #corner)

    local card = {}
    if #corner == 0 then
        log("基建换班找不到卡片")
        return
    end
    local prex = -math.huge
    for _, x in pairs(corner) do
        if x - prex > scale(207) then
            prex = x
            table.insert(card, { x, scale(379) })
            table.insert(card, { x, scale(801) })
        end
    end

    -- card = table.slice(card, 4, 4)
    -- log(114, card)
    local empty1_num = 0
    for idx, v in pairs(card) do
        -- 技能判断
        local icon1 = {
            v[1] + scale(7), v[2] + scale(18), v[1] + scale(60), v[2] + scale(70),
        }
        local icon2 = {
            v[1] + scale(70), v[2] + scale(18), v[1] + scale(123), v[2] + scale(70),
        }
        --log("icon1", icon1, v[1], v[2])
        local name = correctCharName(ocro({
            v[1] + scale(7), v[2] + scale(104), v[1] + scale(191), v[2] + scale(134),
        }))
        local png = ''
        local png2 = ''
        if not mood_only then
            png = 'empty1'
            png =
                findBuildingSkill(icon1[1], icon1[2], icon1[3], icon1[4], pngdata) or
                png

            -- 已到结尾，返回
            if png == 'empty1' then
                log("未识别到技能1", name)
                empty1_num = empty1_num + 1
                -- 第一页有可能有多个
                if (pageid > 1 and empty1_num > 1) or pageid == 1 and empty1_num > 3 then
                    log("page end", icon1, idx, v)
                    return true
                end
            end
            png2 = 'empty2'
            operator = skillpng2operator[png]
            if #operator == 1 then

            else
                png2 =
                    findBuildingSkill(icon2[1], icon2[2], icon2[3], icon2[4], pngdata) or
                    png2
                if png2 ~= 'empty2' and not disable_log then
                    operator2 = skillpng2operator[png2]
                    operator = table.intersect(operator, operator2)
                end
            end
        end

        -- 心情判断
        local mood = 0
        -- log(v[1])
        local mood1 = { v[1] + scale(49), v[2] + scale(93) }
        -- log(mood1)
        for i = 24, 1, -1 do
            local moodi = { mood1[1] + scale((i - 1) * 5.3478), mood1[2] }
            -- log(moodi, getColor(moodi[1], moodi[2]))
            -- if getColor(moodi[1], moodi[2]) == 'FFFFFF' then
            if cmpColor(moodi[1], moodi[2], 'FFFFFF', 0.4) == 1 then
                mood = i
                break
            end
        end
        --log(129, idx, operator, mood, name)
        --[[
        -- 异格将心情设为负值
        local yg1 = { v[1] + scale(7), v[2] - scale(219) }
        local yg2 = { v[1] + scale(7), v[2] - scale(205) }
        local yg3 = { v[1] + scale(15), v[2] - scale(264) }

        -- "1276|801|898989,1291|537|272727"
        log("yg1", yg1)
        log("yg2", yg2)
        log("yg3", yg3)
        yg1 = getPixelColor(yg1[1], yg1[2])
        yg2 = getPixelColor(yg2[1], yg2[2])
        yg3 = getPixelColor(yg3[1], yg3[2])
        log("yg1", yg1)
        log("yg2", yg2)
        log("yg3", yg3)
        if math.abs(colorDiff(yg1, yg2)) < 36 and table.any(ygStaitonColor,
                function(color)
                    return math.abs(colorDiff(yg1, color)) < 36
                end) and (math.abs(colorDiff(yg3, "ff003030")) < 75) then
            -- ffffbb22
            log("异格干员")
            mood = -mood
            if mood == 0 then mood = -1 end
        end
        -- exit()
        ]]
        table.insert(operators, { png, png2, mood, icon1, pageid, name })
    end
    -- sleep(max(0, delay - (time() - start_time)))
    log(217, operators)
    -- exit()
end)

-- 贸易站干员选择
-- operator: 列表，每个元素包含两个技能图标
-- dormitoryCapacity: 宿舍可容纳人数
-- dormitoryLevelSum: 宿舍等级之和
-- goldStationNum: 赤金生产线数
-- 返回效率最高的index
tradingStationOperatorBest = function(operator, dormitoryCapacity,
                                      dormitoryLevelSum, goldStationNum,
                                      goodType, level)
    log("194,goldStationNum,dormitoryCapacity,dormitoryLevelSum", 194,
        goldStationNum, dormitoryCapacity, dormitoryLevelSum)
    -- 参考 https://prts.wiki/w/罗德岛基建
    local maxStorage, maxOperator
    maxOperator = level
    if level == 1 then
        maxStorage = 6
    elseif level == 2 then
        maxStorage = 8
    else
        maxStorage = 10
    end

    -- 输入index组合，计算平均加成，与groundtruth差距：
    -- 1. 只考虑8小时平均收益，非实际换班间隔
    -- 2. 12心情以下干员不考虑，也忽略心情消耗
    -- 3. 忽略 ?? 效果
    local base, storage, all, gold, extra, only_need
    local score = function(icons)
        base = 0
        storage = 0 -- 容量
        extra = 0   -- 额外加成
        gold = goldStationNum
        all = {}
        only_need = {}

        -- 应用独立技能效果
        for _, icon in pairs(table.flatten(icons)) do
            all[icon] = (all[icon] or 0) + 1
            -- log(266, icon, goodType, base)
            if icon == 'bskill_tra_spd3' then
                base = base + 0.35
            elseif icon == 'bskill_tra_spd&formula1' then
                base = base + 0.3 + 0.04 -- 近似两种产物
            elseif icon == 'bskill_tra_spd&meet1' then
                base = base + 0.4        -- 近似满级会客厅
            elseif icon == 'bskill_tra_spd&cost' then
                base = base + 0.3
            elseif icon == 'bskill_tra_spd&limit7' then
                base = base + 0.3
                storage = storage + 1
            elseif icon == 'bskill_tra_spd&limit6' then
                base = base + 0.25
                storage = storage + 1
            elseif icon == 'bskill_tra_spd&limit5' then --银灰2
                base = base + 0.20
                storage = storage + 4
                if isCharExsit["灵知"] then
                    base = base - 0.15
                    storage = storage + 6
                end
            elseif icon == 'bskill_tra_spd_bd2' then --黑键2
                base = base + 0.005 * dormitoryCapacity
                if isCharExsit["迷迭香"] then
                    base = base + 0.31
                end
            elseif icon == 'bskill_tra_spd&limit4' then
                base = base + 0.15
                storage = storage + 4
            elseif icon == 'bskill_tra_spd&limit3' then
                base = base + 0.15
                storage = storage + 2
            elseif icon == 'bskill_tra_spd&limit2' then
                base = base + 0.1
                storage = storage + 4
            elseif icon == 'bskill_tra_spd&limit1' then
                base = base + 0.1
                storage = storage + 2
            elseif icon == 'bskill_tra_spd2' then
                base = base + 0.3
            elseif icon == 'bskill_tra_spd1' then
                base = base + 0.2
            elseif icon == "bskill_tra_par&per1" then -- 赫德雷 伊内丝和W加成不考虑
                base = base + 0.25
            elseif icon == "bskill_tra_par&per2" then
                base = base + 0.30
            elseif icon == "bskill_tra_spd&limit_down1" then -- 锏
                base = base + 0.20
                storage = storage - 2
            elseif icon == "bskill_tra_spd&limit_down2" then
                base = base + 0.25
                storage = storage - 6
            elseif icon == "bskill_tra_limit2spd" then
                base = base + math.floor(storage / 5) * 0.25
            elseif icon == "bskill_trade_ord_spd_variable" then -- 琳琅诗怀雅
                base = base + storage * 0.04
            elseif icon == 'bskill_tra_flow_gc2' then
                base = base + 0.05
                gold = gold + (gold // 2) * 2
            elseif icon == 'bskill_tra_flow_gc1' then
                base = base + 0.05
                gold = gold + (gold // 4) * 2
            elseif icon == 'bskill_tra_spd&limit_felyne' then --泰拉大陆调查团
                base = base + 0.05
                if isCharExsit["麒麟R夜刀"] and isCharExsit["火龙S黑角"] then
                    base = base + 0.361
                end
            elseif icon == 'bskill_tra_spd&dorm2' then
                base = base + 0.02 * dormitoryLevelSum
            elseif icon == 'bskill_tra_spd&dorm1' then
                base = base + 0.01 * dormitoryLevelSum
            elseif icon == 'bskill_tra_bd_n2' then
                base = base + 0.01 * dormitoryCapacity
                if isCharExsit["桑葚"] then
                    base = base + 0.21
                end
                if isCharExsit["重岳"] then
                    base = base + 0.15
                end
            elseif icon == 'bskill_tra_limit&cost"' then
                storage = storage + 5
            elseif icon == 'bskill_tra_wt&cost2' and goodType == '贵金属' then
                -- 认为裁缝B单独用效果极小
                base = base + 0.02
            elseif icon == 'bskill_tra_wt&cost1' and goodType == '贵金属' then
                -- 认为裁缝B单独用效果极小
                base = base + 0.01
            elseif all['bskill_tra_long2'] and goodType == '贵金属' then
                -- 认为投资B单独用效果极小
                base = base + 0.02
            elseif all['bskill_tra_long1'] and goodType == '贵金属' then
                -- 认为投资A单独用效果极小
                base = base + 0.01
            end
        end

        -- 应用全局性技能
        -- 火哨
        if all["bskill_tra_share1"] then base = base + (level - 1) * 0.15 end

        -- 拉狗徳狗
        local texas = all['bskill_tra_texas1'] or all['bskill_tra_texas2']
        if all['bskill_tra_Lappland1'] then
            if texas then
                storage = storage + 2
                base = base + 0.65
            end
        elseif all['bskill_tra_Lappland2'] then
            if texas then
                storage = storage + 4
                base = base + 0.65
            end
        end

        -- 雪雉
        if all['bskill_tra_spd_variable22'] then
            base = base + min(0.35, base // 0.05 * 0.05) *
                all['bskill_tra_spd_variable22']
        end

        -- 图耶
        if all['bskill_tra_flow_gs2'] then
            base = base + 0.05 + (gold // 2) * 0.15 * all['bskill_tra_flow_gs2']
        end
        if all['bskill_tra_flow_gs1'] then
            base = base + 0.05 + (gold // 4) * 0.15 * all['bskill_tra_flow_gs1']
        end
        -- 鸿雪
        if all['bskill_tra_flow_gs'] then
            base = base + 0.00 + (gold // 1) * 0.05 * all['bskill_tra_flow_gs']
        end

        -- 孑
        if all['bskill_tra_limit_count'] then
            -- 孑精1
            base = base + max(1, (maxStorage + storage - base // 0.1)) * 0.04
        elseif all['bskill_tra_limit_diff'] then
            -- https://ngabbs.com/read.php?tid=26013244&rand=499
            -- 孑0 / 德拉ii =112% (1天3换(18/6) 、只在换班时收单)
            -- 孑0 近似
            base = base + (maxStorage + storage) * 0.04 / (level + 1.12) * 4.034
        end

        -- 巫恋
        if all['bskill_tra_vodfox'] and goodType == '贵金属' then
            if maxOperator == 1 then
                base = 0
            elseif maxOperator == 2 then
                base = 0.45 + 0.01
            else
                -- 参考 https://bbs.nga.cn/read.php?tid=25965441&rand=365
                -- 即使柏喙/卡夫卡等价白板，也倾向于选，因为其他地方也不怎么用
                if all['bskill_tra_wt&cost2'] and all['bskill_tra_long2'] then
                    only_need = {
                        'bskill_tra_vodfox', 'bskill_tra_wt&cost2', 'bskill_tra_long2',
                    }
                    base = 1.7192
                elseif all['bskill_tra_wt&cost2'] and all['bskill_tra_long1'] then
                    only_need = {
                        'bskill_tra_vodfox', 'bskill_tra_wt&cost2', 'bskill_tra_long1',
                    }
                    base = 1.3205
                elseif all['bskill_tra_wt&cost2'] then
                    only_need = { 'bskill_tra_vodfox', 'bskill_tra_wt&cost2' }
                    base = 0.9218
                elseif all['bskill_tra_long2'] then
                    only_need = {
                        'bskill_tra_vodfox', 'bskill_tra_long2', 'bskill_tra_wt&cost1',
                    }
                    base = 1.4734 + 0.001 * all['bskill_tra_wt&cost1']
                elseif all['bskill_tra_long1'] then
                    only_need = {
                        'bskill_tra_vodfox', 'bskill_tra_long1', 'bskill_tra_wt&cost1',
                    }
                    base = 1.1927 + 0.001 * all['bskill_tra_wt&cost1']
                else
                    only_need = { 'bskill_tra_vodfox', 'bskill_tra_wt&cost1' }
                    base = 0.9120 + 0.001 * all['bskill_tra_wt&cost1']
                end
            end
        end

        -- 但书，禁用巫恋
        if not all['bskill_tra_vodfox'] and goodType == "贵金属" then
            if all['bskill_tra_against'] then base = (1 + base) * 1.276 - 1 end
            if all['bskill_tra_against2'] then base = (1 + base) * 1.556 - 1 end
        end

        -- 禁用尤里卡
        if all['bskill_tra_spd&wt1'] then base = -1 end

        return base, only_need
    end

    -- 过滤心情小于阈值的干员
    local minAllowedMood = shift_min_mood
    if disable_shift_mood then minAllowedMood = -1 end
    operator = table.filter(operator,
        function(x) return x[3] >= minAllowedMood end)
    -- 移除心情
    operatorIcon = map(function(x) return { x[1], x[2] } end, operator)

    -- 遍历全部组合
    local best = {}
    local best_score = -1
    local best_only_need = {}
    log(354, #operator, maxOperator)
    for _, c in pairs(table.combination(range(1, #operator), maxOperator)) do
        local s, only_need = score(table.index(operatorIcon, c))
        -- log(401, table.index(operator, c), s)
        if s > best_score then
            best = c
            best_score = s
            best_only_need = only_need
        end
    end

    best = table.index(operator, best)

    -- 特殊处理，只需要部分干员
    if #best_only_need > 0 then
        best = table.filter(best, function(v)
            return #table.intersect(best_only_need, { v[1], v[2] }) > 0
        end)
    end
    return best, best_score
end

testManufacturingStationOperatorBest = function()
    local operator = {
        { 'bskill_man_exp3', 'bskill_man_exp1',           12 }, { 'bskill_man_exp2', '', 12 },
        { '',                'bskill_man_spd_variable31', 12 }, { 'bskill_man_spd2', '', 12 },
        { '', 'bskill_man_spd&limit&cost2', 12 },
        { '', 'bskill_man_spd&limit&cost4', 12 },
    }
    local tradingStationNum = 3
    local powerStationNum = 3
    local goodType = "作战记录"
    local level = 3
    local best, best_score
    best, best_score = manufacturingStationOperatorBest(operator,
        tradingStationNum,
        powerStationNum, 0,
        goodType, level)

    log(best, best_score)
end

-- 制造站干员选择
-- operator: 列表，每个元素包含两个技能图标与心情
-- tradingStationNum: 贸易站数量
-- powerStationNum: 发电站数量
-- totalStationLevel: 等级总量
-- type: 制造物类别
-- level: 制造站等级
-- 返回效率最高的index
manufacturingStationOperatorBest = function(operator, tradingStationNum,
                                            powerStationNum, totalStationLevel,
                                            goodType, level)
    -- 参考 https://prts.wiki/w/罗德岛基建/制造站
    local maxStorage, maxOperator
    maxOperator = level
    if level == 1 then
        maxStorage = 24
    elseif level == 2 then
        maxStorage = 36
    else
        maxStorage = 54
    end
    --log(operator)
    log("401,goodType", goodType, operator[1])
    -- log("maxStorage", maxStorage)
    -- log("maxOperator", maxOperator)

    -- 输入index组合，计算平均加成，与groundtruth差距：
    -- 1. 只考虑8小时平均收益，非实际换班间隔
    -- 2. 12心情以下干员不考虑，也忽略心情消耗
    -- 3. 忽略 迷迭香所有技能 效果
    -- 4. 忽略 意识协议 效果（标准化技能识别不支持）
    -- 5. 忽略 我寻思能行 效果（发电站技能加成）
    local base, disable_moon_effect, storage, storages, standard, all, station,
    station_only, only_need, robot


    ---@param icons table [[技能1,技能2,name1],[技能1,技能2,name2],[技能1,技能2,name3]]
    local score = function(icons)
        base = 0
        robot = 0            -- 工程机器人
        storage = {}         -- 容量效果
        standard = 0         -- 标准化技能数量
        rhine = 0            --莱茵科技数量
        metallics = 0        --金属工艺数量
        station = 0          -- 根据设施加成
        station_only = false -- 是否只根据设施加成
        all = {}
        only_need = {}
        --log("icons", icons)
        --log(486, table.flatten(icons))

        -- 应用独立技能效果
        -- 一维化传入的干员技能组
        for idx, icon in pairs(table.flatten(icons)) do
            -- 传入的第几位干员,icons[operatoridx][3]返回干员名
            operatoridx = (idx + 2) // 3
            -- 计算重复的技能
            all[icon] = (all[icon] or 0) + 1
            -- log(266, icon, goodType, base)
            if icon == 'bskill_man_limit&cost5' then
                storage[operatoridx] = (storage[operatoridx] or 0) + 10
            elseif icon == 'bskill_man_exp3' then
                if goodType == '作战记录' then base = base + 0.35 end
                -- log(272, base)
            elseif icon == 'bskill_man_exp2' then
                if goodType == '作战记录' then base = base + 0.3001 end
            elseif icon == 'bskill_man_exp1' then
                if goodType == '作战记录' then base = base + 0.2501 end
            elseif icon == 'bskill_man_exp4' then
                if goodType == '作战记录' then base = base + 0.20 end
            elseif icon == 'bskill_man_gold2' then
                if goodType == '贵金属' then
                    base = base + 0.35
                    metallics = metallics + 1
                end
            elseif icon == 'bskill_man_gold1' then
                if goodType == '贵金属' then
                    base = base + 0.3001
                    metallics = metallics + 1
                end
            elseif icon == 'bskill_man_spd&trade' then
                -- 清流，使用贸易站数量
                if goodType == '贵金属' then
                    -- base = base + 0.20 * tradingStationNum
                    station = station + 0.20 * tradingStationNum
                end
            elseif icon == 'bskill_man_gold3' then --杏仁
                if goodType == '贵金属' then
                    base = base + 0.25
                end
                if isCharExsit["涤火杰西卡"] then
                    base = base + 0.05
                end
            elseif icon == 'bskill_man_gold&blacksteel' then --杏仁2
                if goodType == '贵金属' then
                    base = base + 0.02
                    if isCharExsit["涤火杰西卡"] then
                        base = base + 0.02
                    end
                end
            elseif icon == 'bskill_man_spd_bd_n1' then
                -- 迷迭香不考虑
            elseif icon == 'bskill_man_spd_bd1' then
                -- 迷迭香不考虑
            elseif icon == 'bskill_man_spd_bd2' then --迷迭香2
                if isCharExsit["絮雨"] then
                    base = base + 0.45
                end
            elseif icon == "bskill_man_gold&blacksteel" then
                -- 排除杏仁
            elseif icon == "bskill_man_cost_room1" then
                -- 排除黍
            elseif icon == "bskill_man_spd_bd5" then
                -- 排除截云
            elseif icon == "bskill_man_spd_bd6" then -- 截云2
                if isCharExsit["桑葚"] then
                    base = base + 0.4 / 2.5
                end
                if isCharExsit["重岳"] then
                    base = base + 0.05 / 2.5
                    if isCharExsit["令"] then
                        base = base + 0.05 / 2.5
                    end
                    if isCharExsit["夕"] then
                        base = base + 0.05 / 2.5
                    end
                end
                if isCharExsit["令"] then
                    base = base + 0.15 / 2.5
                end
            elseif icon == "bskill_man_spd_bd7" then --黍2
                if isCharExsit["桑葚"] then
                    base = base + 0.4 / 3
                end
                if isCharExsit["重岳"] then
                    base = base + 0.1 / 3 --自身和重岳
                    if isCharExsit["令"] then
                        base = base + 0.05 / 3
                    end
                    if isCharExsit["夕"] then
                        base = base + 0.05 / 3
                    end
                end
                if isCharExsit["令"] then
                    base = base + 0.15 / 3
                end
            elseif icon == 'bskill_man_spd3' then
                base = base + 0.30
                local name = icons[operatoridx][3]
                if table.findv({ "淬羽赫默" }, name) then
                    rhine = rhine + 1
                end
            elseif icon == 'bskill_man_spd2' then
                base = base + 0.25
                local name = icons[operatoridx][3]
                --log(name)
                if table.findv({ "史都华德", "香草", "调香师", "杰西卡", "水月", "罗比菈塔", "海沫" }, name) then
                    standard = standard + 1
                elseif table.findv({ "白面鸮", "赫默", "多萝西", "星源" }, name) then
                    rhine = rhine + 1
                elseif table.findv({ "远牙", "灰毫", "野鬃" }, name) then
                    if isCharExsit["薇薇安娜"] then base = base + 0.07 end
                    if isCharExsit["焰尾"] then
                        if goodType == "作战记录" then
                            base = base + 0.101
                        elseif goodType == "贵金属" then
                            base = base - 0.1
                        end
                    end
                    if isCharExsit["正义骑士号"] and name == "野鬃" then base = base + 0.052 end
                end
                if isCharExsit["涤火杰西卡"] and table.findv({ "香草", "杰西卡" }, name) then
                    base = base + 0.05
                end
            elseif icon == 'bskill_man_limit&cost3' then
                storage[operatoridx] = (storage[operatoridx] or 0) + 16
            elseif icon == 'bskill_man_spd&limit&cost3' then
                base = base + 0.25
                storage[operatoridx] = (storage[operatoridx] or 0) - 12
            elseif icon == 'bskill_man_spd_add1' then
                -- 8小时平均收益 ((0.2+0.24)/2*5+0.25*3)/8
                base = base + 0.23125
            elseif icon == 'bskill_man_spd_reduce' then --铅踝
                base = base + 0.22
            elseif icon == 'bskill_man_spd_add2' then
                -- 8小时平均收益 ((0.15+0.23)/2*5+0.25*3)/8
                base = base + 0.2125
            elseif icon == "bskill_man_spd_add3" then
                base = base + 0.1 -- 10小时平均收益 8h收益为0.073
            elseif icon == 'bskill_man_spd1' then
                base = base + 0.15
                local name = icons[operatoridx][3]
                --log(name)
                if table.findv({ "夜刀", "流星", "豆苗", "褐果", "石英", "洋灰", "历阵锐枪芬" }, name) then
                    standard = standard + 1
                elseif table.findv({ "白面鸮", "赫默", "星源" }, name) then
                    rhine = rhine + 1
                elseif table.findv({ "远牙", "灰毫", "野鬃" }, name) then
                    if isCharExsit["薇薇安娜"] then base = base + 0.07 end
                    if isCharExsit["焰尾"] then
                        if goodType == "作战记录" then
                            base = base + 0.101
                        elseif goodType == "贵金属" then
                            base = base - 0.1
                        end
                        if isCharExsit["正义骑士号"] and name == "野鬃" then base = base + 0.052 end
                    end
                end
            elseif icon == 'bskill_man_spd&limit3' then
                base = base + 0.1
                storage[operatoridx] = (storage[operatoridx] or 0) + 10
            elseif icon == 'bskill_man_spd&limit1' then
                base = base + 0.1
                storage[operatoridx] = (storage[operatoridx] or 0) + 6
            elseif icon == 'bskill_man_spd&limit&cost2' then
                base = base - 0.05
                storage[operatoridx] = (storage[operatoridx] or 0) + 19
            elseif icon == 'bskill_man_spd&limit&cost1' then
                base = base - 0.05
                storage[operatoridx] = (storage[operatoridx] or 0) + 16
            elseif icon == 'bskill_man_spd&limit&cost4' then
                base = base - 0.2
                storage[operatoridx] = (storage[operatoridx] or 0) + 17
            elseif icon == "bskill_man_fuze" then
                base = base + 0.2
            elseif icon == "bskill_man_gold4" then --阿罗玛
                if goodType == '贵金属' then base = base + 0.25 end
            elseif icon == 'bskill_man_exp&limit2' then
                if goodType == '作战记录' then
                    storage[operatoridx] = (storage[operatoridx] or 0) + 15
                end
            elseif icon == 'bskill_man_exp&limit1' then
                if goodType == '作战记录' then
                    storage[operatoridx] = (storage[operatoridx] or 0) + 12
                end
            elseif icon == 'bskill_man_exp&limit3' then
                if goodType == '作战记录' then
                    base = base - 0.0001
                    storage[operatoridx] = (storage[operatoridx] or 0) + 4
                end
            elseif icon == 'bskill_man_limit&cost2' then
                storage[operatoridx] = (storage[operatoridx] or 0) + 10
            elseif icon == 'bskill_man_limit&cost1' then
                storage[operatoridx] = (storage[operatoridx] or 0) + 8
            elseif icon == 'bskill_man_exp&cost' then
                -- Vlog 心情消耗不考虑
            elseif icon == 'bskill_man_originium2' then
                if goodType == '源石' then base = base + 0.35 end
            elseif icon == 'bskill_man_originium1' then
                if goodType == '源石' then base = base + 0.3001 end
            elseif icon == 'bskill_man_constrLv' then
                robot = min(64, robot + totalStationLevel)
            elseif icon == 'empty' then
                log('empty')
            end
        end

        -- 应用全局性技能
        -- 至简
        if all["bskill_man_spd_bd3"] then base = base + (robot // 16) * 0.05 end
        if all["bskill_man_spd_bd4"] then base = base + (robot // 8) * 0.05 end

        if all['bskill_man_spd_variable31'] then
            -- 泡泡
            for _, s in pairs(storage) do
                if s > 0 and s <= 16 then
                    base = base + s * 0.01 * all['bskill_man_spd_variable31']
                elseif s > 16 then
                    base = base + s * 0.03 * all['bskill_man_spd_variable31']
                end
            end
        elseif all['bskill_man_spd_variable11'] then
            -- 红云
            base = base + max(table.sum(storage), 0) * 0.02 *
                all['bskill_man_spd_variable11']
        end
        if all['bskill_man_spd_variable21'] then
            -- 槐虎
            base = base + min(0.4, base // 0.05 * 0.05) *
                all['bskill_man_spd_variable21']
        end

        -- 发电站数
        if all['bskill_man_spd&power3'] then
            station_only = true
            --加0.01让清流优先和自动化组上班
            station = station + 0.16 * powerStationNum * all['bskill_man_spd&power3']
            table.extend(only_need, { 'bskill_man_spd&power3' })
        end
        if all['bskill_man_spd&power2'] then
            station_only = true
            --加0.01让清流优先和自动化组上班
            station = station + 0.11 * powerStationNum * all['bskill_man_spd&power2']
            table.extend(only_need, { 'bskill_man_spd&power2' })
        end
        if all['bskill_man_spd&power1'] then
            station_only = true
            station = station + 0.06 * powerStationNum * all['bskill_man_spd&power1']
            table.extend(only_need, { 'bskill_man_spd&power1' })
        end
        if all['bskill_man_skill_spd'] then
            -- 水月，标准化技能数量
            base = base + standard * 0.05 * all['bskill_man_skill_spd'] - 0.0002
        end
        if all['bskill_man_skill_spd2'] then
            -- 多萝西，莱茵科技技能数量
            base = base + rhine * 0.05 * all['bskill_man_skill_spd2'] - 0.0002
        end
        if all['bskill_man_skill_spd3'] then
            -- 苍苔，金属工艺技能数量
            if goodType == '贵金属' then base = base + metallics * 0.05 * all['bskill_man_skill_spd3'] - 0.0002 end
        end

        -- 禁止过小容量
        if maxStorage + table.sum(storage) < 20 then base = -1 end
        -- 禁止多次减容量
        if table.sum(storage) < -15 then base = -1 end

        if station_only then
            base = station
            table.extend(only_need, { 'bskill_man_spd&trade' })
        else
            base = base + station
        end

        return base, only_need
    end

    -- 过滤心情小于阈值的干员
    local minAllowedMood = shift_min_mood
    if disable_shift_mood then minAllowedMood = -1 end
    operator = table.filter(operator,
        function(x) return x[3] >= minAllowedMood end)
    -- 移除心情
    operatorIcon = map(function(x) return { x[1], x[2], x[6] } end, operator)

    -- 遍历全部组合
    local best = {}
    local best_score = -1
    local best_only_need = {}
    for _, c in pairs(table.combination(range(1, #operator), maxOperator)) do
        --log(674, c, table.index(operatorIcon, c))
        local s, only_need = score(table.index(operatorIcon, c))
        if s > best_score then
            best = c
            best_score = s
            best_only_need = only_need
        end
        -- log(401, c, s)
        -- if table.equal(c, {1, 2, 3}) then exit() end
    end
    best = table.index(operator, best)

    -- 特殊处理，白板干员用白板
    if #best_only_need > 0 then
        best = table.filter(best, function(v)
            return #table.intersect(best_only_need, { v[1], v[2] }) > 0
        end)
    end
    return best, best_score
end

stationIconMask = {}
stationIconCenterMask = {}
w, h = 36, 36
for i = 1, h do
    for j = 1, w do
        if true then
            table.insert(stationIconMask, { i, j })
            -- log(613,i,j)
        end
        if ((i - 18.5) ^ 2 + (j - 18.5) ^ 2) < 17 ^ 2 then
            table.insert(stationIconCenterMask, { i, j })
        end
    end
end
-- exit()

findBuildingSkill = function(x1, y1, x2, y2, pngdata)
    local s = ''
    local w, h, color = getScreenPixel(x1, y1, x2, y2)
    local i, j, b, g, r
    local data = {}
    for _, m in pairs(stationIconMask) do
        i, j = m[1], m[2]
        -- b, g, r = colorToRGB(color[(i - 1) * w + j])
        b, g, r = colorToRGB(color[scale((i - 1) / 720 * 1080) * w +
        scale(j / 720 * 1080)])
        table.extend(data, { r, g, b })

        if nil then
            r = string.format('%X', r):padStart(2, '0')
            g = string.format('%X', g):padStart(2, '0')
            b = string.format('%X', b):padStart(2, '0')
            s = s .. i .. '|' .. j .. '|' .. r .. g .. b .. ','
        end
    end
    -- log(s)
    -- exit()
    --
    local best_score = 100
    -- local threshold = 100
    local best = nil
    local score = 0
    local scoreBase = 0
    local pointScore = 0
    -- local flatPoint = 0
    local abs = math.abs

    local flatScoreTable = {}
    local flatScore = 0
    for i = 1, #stationIconMask - 36 do
        flatScore = abs(data[i * 3 - 2] - data[(i + 1) * 3 - 2]) +
            abs(data[i * 3 - 1] - data[(i + 1) * 3 - 1]) +
            abs(data[i * 3] - data[(i + 1) * 3]) +
            abs(data[i * 3 - 2] - data[(i + 36) * 3 - 2]) +
            abs(data[i * 3 - 1] - data[(i + 36) * 3 - 1]) +
            abs(data[i * 3] - data[(i + 36) * 3])
        table.insert(flatScoreTable, 1 / (1 + flatScore))
        scoreBase = scoreBase + flatScoreTable[#flatScoreTable]
    end

    -- local tmp = ''
    for k, v in pairs(pngdata) do
        -- tmp = ''
        score = 0
        for i = 1, #stationIconMask do
            pointScore = abs(data[i * 3 - 2] - v[i * 3 - 2]) +
                abs(data[i * 3 - 1] - v[i * 3 - 1]) +
                abs(data[i * 3] - v[i * 3])
            score = score + pointScore * flatScoreTable[i]
            -- if i % 36 == 1 then tmp = tmp .. '\n' end
            -- if pointScore > 200 then
            --   tmp = tmp .. '1'
            -- else
            --   tmp = tmp .. ' '
            -- end
            if score / scoreBase > best_score then break end
        end
        score = score / scoreBase

        --if k == 'bskill_man_spd_bd2' then log(662, score, tmp) end    --森蚺
        --if k == 'bskill_man_spd&power2' then log(663, score, tmp) end --森蚺
        --if k == 'bskill_man_spd&power1' then log(663, score, tmp) end --异客
        -- if k == 'bskill_tra_spd_variable22' then log(662, score, tmp) end
        -- if k == 'bskill_tra_spd&wt1' then log(663, score, tmp) end
        --
        -- if k == 'bskill_tra_texas1' then log(662, score, tmp) end
        -- if k == 'bskill_tra_Lappland2' then log(663, score, tmp) end
        -- if k == 'bskill_meet_spd3' then log(663, score, tmp) end
        -- if k == 'bskill_meet_spd2' then log(662, score, tmp) end
        -- if k == 'bskill_man_spd2' then log(663, score, tmp) end
        -- if k == 'bskill_man_exp2' then log(662, score, tmp) end
        -- if k == 'bskill_ctrl_t_spd' then log('t', score, tmp) end
        -- if k == 'bskill_ctrl_c_spd' then log('c', score, tmp) end
        -- exit()

        if best_score > score then
            best_score = score
            best = k
        end
    end
    log(2208, best_score, best, x1, y1, x2, y2)
    --exit()
    return best
end

initPngdata = function()
    if skillpng2operator then return end

    -- 读取数据
    local f = io.open(getWorkPath() .. '/skill/skillicon2operator.json', 'r')
    skillpng2operator = f:read("*a")
    f:close()
    local status
    status, skillpng2operator = pcall(JsonDecode, skillpng2operator)
    if not status then stop("基建图标数据异常", 'cur') end

    -- 扩充精英化等级
    for k, v in pairs(skillpng2operator) do
        local extra = {}
        for _, o in pairs(v) do
            if o:endsWith('1') then table.insert(extra, o:sub(1, #o - 1) .. '2') end
            if o:endsWith('0') then
                table.insert(extra, o:sub(1, #o - 1) .. '1')
                table.insert(extra, o:sub(1, #o - 1) .. '2')
            end
        end
        table.extend(v, extra)
    end

    -- 第一技能缺失，无需再考虑
    skillpng2operator['empty1'] = {}

    -- 第二技能缺失，所有干员
    skillpng2operator['empty2'] = table.remove_duplicate(table.flatten(
        skillpng2operator))

    -- 读取图标
    manufacturingPngdata = {}
    tradingPngdata = {}
    meetingPngdata = {}
    controlPngdata = {}
    officePngdata = {}
    powerPngdata = {}
    stationType2pngData = {
        制造站 = manufacturingPngdata,
        贸易站 = tradingPngdata,
        会客厅 = meetingPngdata,
        控制中枢 = controlPngdata,
        办公室 = officePngdata,
        发电站 = powerPngdata,
    }
    local s = ''
    for v, _ in pairs(skillpng2operator) do
        local pngdata
        if v:startsWith("bskill_man") then
            pngdata = manufacturingPngdata
        elseif v:startsWith("bskill_tra_") then
            pngdata = tradingPngdata
        elseif v:startsWith("bskill_meet") then
            pngdata = meetingPngdata
        elseif v:startsWith("bskill_ctrl") then
            pngdata = controlPngdata
        elseif v:startsWith("bskill_hire") then
            pngdata = officePngdata
        elseif v:startsWith("bskill_pow") then
            pngdata = powerPngdata
        else
            pngdata = {}
        end

        local _, _, color = getImage(getWorkPath() .. '/skill/' .. v .. '.png')
        -- if v=='empty1' then
        --   print(color)
        -- end
        pngdata[v] = {}
        for _, m in pairs(stationIconMask) do
            i, j = m[1], m[2]
            b, g, r = colorToRGB(color[(w - i - 1) * w + j])
            table.extend(pngdata[v], { r, g, b })
            if nil and v == 'bskill_man_exp2' then
                -- if v == 'bskill_ws_evolve2' then
                r = string.format('%X', r):padStart(2, '0')
                g = string.format('%X', g):padStart(2, '0')
                b = string.format('%X', b):padStart(2, '0')
                s = s .. i .. '|' .. j .. '|' .. r .. g .. b .. ','
            end
        end
    end
    if not manufacturingPngdata['bskill_man_exp2'] then
        toast("基建图标数据异常")
        ssleep(5)
    end
    if not tradingPngdata['bskill_tra_spd&wt1'] then
        toast("基建图标数据异常")
        ssleep(5)
    end
end

-- 是否是贸易站，商品类别
chooseOperator = function(stationType, goodType, stationLevel,
                          tradingStationNum, powerStationNum, dormitoryCapacity,
                          dormitoryLevelSum, goldStationNum, totalStationLevel)
    log("stationType", stationType)
    log("goodType", goodType)
    log("stationLevel", stationLevel)
    log("tradingStationNum", tradingStationNum)
    log("powerStationNum", powerStationNum)
    log("dormitoryCapacity", dormitoryCapacity)
    log("dormitoryLevelSum", dormitoryLevelSum)
    log("goldStationNum", goldStationNum)
    log("totalStationLevel", totalStationLevel)
    -- exit()

    local start_time = time()
    initPngdata()
    -- 至少等一秒
    sleep(max(0, 1000 - (time() - start_time)))

    -- exit()
    -- ==> 滑动获取所有技能

    local maxSwipTimes = 10
    local operator = {}
    for i = 1, maxSwipTimes do
        -- if discover(operator,
        --             (not trading) and manufacturingPngdata or tradingPngdata, i) then
        -- log(stationType, #stationType2pngData[stationType])
        if discover(operator, stationType2pngData[stationType], i) then break end

        -- exit()
        -- 三次重试
        local state = sample("干员第一个")
        for j = 1, 3 do
            log("842尝试翻页", j)
            if findOne("正在提交反馈至神经") then
                disappear("正在提交反馈至神经", network_timeout)
                ssleep(.5)
            end
            swipo()
            if not findOne(state) then break end
        end
    end
    swipo(true, true)
    start_time = time()

    --log(671, operator)
    -- exit()

    -- TODO 滑动时就可以开始计算
    -- 计算最优技能
    local best, best_score
    if stationType == "制造站" then
        best, best_score = manufacturingStationOperatorBest(operator,
            tradingStationNum,
            virtralPowerStationNum,
            totalStationLevel,
            goodType, stationLevel)
        log("制造站选", best)
        for i = 1, #best do
            if table.findv(best[i], "bskill_man_spd_bd2") then
                isCharExsit["迷迭香"] = true
                break
            end
        end
    elseif stationType == "贸易站" then
        best, best_score = tradingStationOperatorBest(operator, dormitoryCapacity,
            dormitoryLevelSum,
            goldStationNum, goodType,
            stationLevel)
    elseif stationType == "会客厅" then
        best, best_score = meetingStationOperatorBest(operator)
    elseif stationType == "发电站" then
        best, best_score = powerStationOperatorBest(operator)
        log("发电站选", best)
        if table.findv(best[1], "bskill_pow_count") then
            virtralPowerStationNum = virtralPowerStationNum + 1
            isCharExsit["承曦格雷伊"] = true
        elseif table.findv(best[1], "bskill_pow_spd&cost") then
            isCharExsit["正义骑士号"] = true
            isCharExsit["作业平台"] = isCharExsit["作业平台"] or 0 + 1
        elseif table.findv({ "Lancet-2" }, best[1][6]) then
            isCharExsit["Lancet-2"] = true
            isCharExsit["作业平台"] = isCharExsit["作业平台"] or 0 + 1
        elseif table.findv({ "Castle-3", "THRM-EX", "正义骑士号", "Friston-3", "PhonoR-0" }, best[1][6]) then
            isCharExsit["作业平台"] = isCharExsit["作业平台"] or 0 + 1
        end
    elseif stationType == "办公室" then
        best, best_score = officeStationOperatorBest(operator)
        log("办公室选", best)
        if table.findv(best[1], "bskill_hire_spd_memento") then
            isCharExsit["絮雨"] = true
        elseif table.findv(best[1], "bskill_hire_spd_bd_n2") then
            isCharExsit["桑葚"] = true
        end
    elseif stationType == "控制中枢" then
        best, best_score = controlStationOperatorBest(operator)
    end
    sleep(max(0, 500 - (time() - start_time)))
    tap("清空选择")

    -- 按页数排序
    table.sort(best, function(a, b) return a[5] < b[5] end)

    -- 选择干员
    operator = best
    log(692, operator, best_score)
    local pageid = 1
    for i = 1, #operator do
        log(i, operator[i])
        while operator[i][5] > pageid do
            local state = sample("干员第一个")
            for j = 1, 3 do
                log("844尝试翻页", j)
                if findOne("正在提交反馈至神经") then
                    disappear("正在提交反馈至神经", network_timeout)
                    ssleep(.5)
                end
                swipo()
                if not findOne(state) then break end
            end
            pageid = pageid + 1
        end
        local p = operator[i][4]
        tap({ p[1] + scale(106), p[2] })
        sleep(50)
    end
    swipo(true, true)
    -- exit()
end

-- 会客厅干员选择：先选+25%，剩下按鹰序
-- 返回效率最高的index
meetingStationOperatorBest = function(operator)
    -- 过滤心情小于阈值的干员
    local minAllowedMood = shift_min_mood
    if disable_shift_mood then minAllowedMood = -1 end
    operator = table.filter(operator,
        function(x) return x[3] >= minAllowedMood end)
    local best = {}
    local best_score = -1
    local remain = {}
    for _, o in pairs(operator) do
        if table.includes({ o[1], o[2] }, 'bskill_meet_spdOwned1') then
            -- 禁用尤里卡
        elseif o[1] == "bskill_meet_spd&cost" or o[2] == "bskill_meet_spd&cost" then
            table.insert(best, 1, o)
        elseif o[1] == "bskill_meet_spdNotOwned2" or o[2] ==
            "bskill_meet_spdNotOwned2" then
            -- 晓歌有人评测过吗
            table.insert(best, 1, o)
        elseif o[1] == "bskill_meet_exchange" or o[2] == "bskill_meet_exchange" then
            table.insert(best, 1, o) -- 跃跃
        elseif o[1] == "bskill_meet_spd3" or o[2] == "bskill_meet_spd3" then
            table.insert(best, o)
        else
            table.insert(remain, o)
        end
    end
    log(best)
    best = table.slice(table.extend(best, remain), 1, 2)
    -- exit()
    return best, best_score
end

-- 办公室干员选择：
-- 返回效率最高的index
officeStationOperatorBest = function(operator)
    -- 过滤心情小于阈值的干员
    local minAllowedMood = shift_min_mood
    if disable_shift_mood then minAllowedMood = -1 end
    operator = table.filter(operator,
        function(x) return x[3] >= minAllowedMood end)
    local best = {}
    local best_score = -1
    for _, o in pairs(operator) do
        local s = 0
        for _, icon in pairs({ o[1], o[2] }) do
            if icon == "bskill_hire_skgoat2" then --斥罪
                s = s + 0.5
            elseif icon == "bskill_hire_skgoat" then
                s = s + 0.45
            elseif icon == "bskill_hire_spd5" then
                s = s + 0.45
            elseif icon == "bskill_hire_spd4" then
                s = s + 0.4
            elseif icon == "bskill_hire_spd3" then
                s = s + 0.35
            elseif icon == "bskill_hire_spd&clue" then
                s = s + 0.35 + 0.01
            elseif icon == "bskill_hire_spd2" then
                s = s + 0.3
            elseif icon == "bskill_hire_spd&ursus2" then
                s = s + 0.2
            elseif icon == "bskill_hire_spd_memento" then --絮雨2
                s = s + 0.31
            elseif icon == "bskill_hire_spd_bd_n2" then   --桑葚2
                s = s + 0.251
            elseif icon == "bskill_hire_spd&blacksteel2" then
                s = s + 0.2
            elseif icon == "bskill_hire_spd_bd_n1_n1" then
                s = s + 0.2
            elseif icon == "bskill_hire_spd&cost2" then
                s = s + 0.2
            elseif icon == "bskill_hire_blitz" then
                s = s + 0.2
            elseif icon == "bskill_hire_spd1" then
                s = s + 0.2
            elseif icon == "bskill_hire_spd&cost1" then
                s = s + 0.1
            elseif icon == "bskill_hire_spd" then
                s = s + 0.1
            end
        end
        table.insert(best, { s, o })
    end
    table.sort(best, function(a, b) return a[1] > b[1] end)
    best = best[1][2]
    return { best }, best_score
end

-- 控制中枢干员选择：同类技能不一起上
-- 返回效率最高的index
controlStationOperatorBest = function(operator)
    -- 过滤心情小于阈值的干员
    local minAllowedMood = shift_min_mood
    if disable_shift_mood then minAllowedMood = -1 end
    operator = table.filter(operator,
        function(x) return x[3] >= minAllowedMood end)
    local best = {}
    local best_score = -1
    --[[
    local remain = {}
    local goodicon = {
        'bskill_ctrl_t_spd',        -- +贸易7%
        'bskill_ctrl_p_spd',        -- +制造2%
        'bskill_ctrl_c_spd',        -- +线索25%
        'bskill_ctrl_cost_bd1&bd2', -- 令 进驻控制中枢时，当自身心情大于12时，人间烟火+15；当自身心情处于12以下时，感知信息+10
        'bskill_ctrl_cost_bd1',     -- 夕 进驻控制中枢时，控制中枢内所有干员的心情每小时恢复+0.05；当自身心情处于12以下时，人间烟火+15
        'bskill_ctrl_cost_bd2',     -- 夕 进驻控制中枢时，自身心情每小时消耗+0.5；当自身心情大于12时，感知信息+10
        -- 'bskill_ctrl_p_bot', -- +小车,加发电站数
        -- 'bskill_ctrl_token_p_spd', -- +小车,+制造2%
        -- 'bskill_ctrl_h_spd', -- 进驻控制中枢时，人力办公室联络速度小于30%时（其中包含基础联络速度5%），则联络速度额外+20%（该加成全局效果唯一，不受其它加成影响）
        'bskill_ctrl_psk',             -- 焰尾 进驻控制中枢时，每个进驻在制造站的红松骑士团干员，作战记录类配方的生产力+10%，贵金属类配方的生产力-10%
        'bskill_ctrl_t_limit&spd',     -- 灵知 进驻控制中枢时，每个进驻在贸易站的喀兰贸易干员，订单获取效率-15%，订单上限+6
        'bskill_ctrl_fraction_knight', -- 薇薇安娜 进驻控制中枢时，每个进驻在制造站的骑士干员生产力 +7%
        'bskill_ctrl_lonely',          --玛恩纳
        'bskill_ctrl_ash',             -- ash
        'bskill_ctrl_tachanka',        -- 机枪
    }
    ]]
    local manu_acc = false
    local trading_acc = false
    local mood_reduce = false
    local office_acc = false

    if #best <= 2 and not manu_acc and not trading_acc then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, "bskill_ctrl_token_p_spd2") and
                table.includes({ o[1], o[2] }, "bskill_ctrl_cost_felyne") then --麒麟r夜刀
                table.insert(best, o)
                isCharExsit["麒麟R夜刀"] = true
            elseif table.includes({ o[1], o[2] }, "bskill_ctrl_token_t_spd") then --火龙s黑角2
                table.insert(best, o)
                isCharExsit["火龙S黑角2"] = true
                isCharExsit["火龙S黑角"] = true
            elseif table.includes({ o[1], o[2] }, "bskill_ctrl_felyne") and
                not table.includes({ o[1], o[2] }, "bskill_ctrl_token_t_spd") then --火龙s黑角0
                table.insert(best, o)
                isCharExsit["火龙S黑角"] = true
            end
        end
        if isCharExsit["麒麟R夜刀"] and isCharExsit["火龙S黑角2"] then
            trading_acc = true
            manu_acc = true
        elseif isCharExsit["麒麟R夜刀"] and isCharExsit["火龙S黑角"] then
            manu_acc = true
        else
            isCharExsit["麒麟R夜刀"] = false
            isCharExsit["火龙S黑角"] = false
            isCharExsit["火龙S黑角2"] = false
            best = {}
        end
    end

    if #best <= 3 then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_t_spd') then
                if not trading_acc then
                    trading_acc = true
                    table.insert(best, o)
                    break
                end
            end
        end
    end

    if #best <= 4 then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_psk') then -- 焰尾
                table.insert(best, o)
                isCharExsit["焰尾"] = true
            elseif table.includes({ o[1], o[2] }, 'bskill_ctrl_fraction_knight') then -- 薇薇安娜
                table.insert(best, o)
                isCharExsit["薇薇安娜"] = true
            end
        end
    end


    if #best < 5 and isCharExsit["桑葚"] then
        log("寻找重岳")
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, "bskill_ctrl_cost_bd3") then --重岳
                table.insert(best, o)
                mood_reduce = true
                isCharExsit["重岳"] = true
                break
            end
        end
    end

    if #best < 5 and isCharExsit["絮雨"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_cost_bd1') then --夕
                table.insert(best, o)
            end
        end
    end

    if #best < 5 and isCharExsit["桑葚"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_cost_bd1&bd2') then --令
                table.insert(best, o)
                isCharExsit["令"] = true
            elseif table.includes({ o[1], o[2] }, 'bskill_ctrl_cost_bd2') then --夕
                table.insert(best, o)
                isCharExsit["夕"] = true
            end
        end
    end



    if #best < 5 and (isCharExsit["絮雨"] or isCharExsit["桑葚"]) then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_h_spd') and (isCharExsit["絮雨"] or isCharExsit["桑葚"]) then --琴柳
                if not office_acc then
                    office_acc = true
                    table.insert(best, o)
                    break
                end
            end
        end
    end

    if #best < 5 and not manu_acc then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_p_spd') then --凯尔希
                manu_acc = true
                table.insert(best, o)
                break
            end
        end
    end

    if #best < 5 and not manu_acc and (isCharExsit["作业平台"] and isCharExsit["作业平台"] > 1) then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_token_p_spd') then --布丁
                manu_acc = true
                table.insert(best, o)
                break
            end
        end
    end

    if #best < 5 and not office_acc then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_c_spd') and
                not table.includes({ o[1], o[2] }, 'bskill_ctrl_lda') then -- 老鲤c与t会判错
                office_acc = true
                table.insert(best, o)
                break
            end
        end
    end

    if #best < 5 and not (isCharExsit["絮雨"] or isCharExsit["桑葚"]) then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_t_limit&spd') then --灵知
                table.insert(best, o)
                isCharExsit["灵知"] = true
                break
            end
        end
    end

    if #best < 5 and not mood_reduce then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, "bskill_ctrl_cost_bd4") and (not isCharExsit["重岳"]) then --重岳2
                isCharExsit["重岳"] = true
                mood_reduce = true
                table.insert(best, o)
                break
            elseif table.includes({ o[1], o[2] }, "bskill_ctrl_lonely") then --玛恩纳
                mood_reduce = true
                table.insert(best, o)
                break
            elseif table.includes({ o[1], o[2] }, "bskill_ctrl_cost_expand") then --维什戴尔
                mood_reduce = true
                isCharExsit["维什戴尔"] = true
                table.insert(best, o)
                break
            end
        end
    end

    if #best < 5 and (not (isCharExsit["絮雨"] or isCharExsit["桑葚"])) and isCharExsit["Lancet-2"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_p_bot') then --森蚺
                table.insert(best, o)
                virtralPowerStationNum = virtralPowerStationNum + 2
                break
            end
        end
    end
    if #best < 5 then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_bd_spd') then --涤火杰西卡2
                table.insert(best, o)
                isCharExsit["涤火杰西卡"] = true
                break
            end
        end
    end
    if #best < 5 and not office_acc then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_c_spd1') then -- 魔王
                office_acc = true
                table.insert(best, o)
                break
            end
        end
    end



    if #best < 5 then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_ela') then --艾拉
                table.insert(best, o)
                break
            end
        end
    end



    for i = 1, 5 - #best do
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_sp') then --异格者
                table.insert(best, o)
                break
            elseif table.includes({ o[1], o[2] }, 'bskill_ctrl_cost') then --笑脸
                table.insert(best, o)
                break
            end
        end
    end



    log(best)
    --best = table.slice(table.extend(best, remain), 1, 5)
    return best, best_score
end

powerStationOperatorBest = function(operator)
    -- 过滤心情小于阈值的干员
    local minAllowedMood = shift_min_mood
    if disable_shift_mood then minAllowedMood = -1 end
    operator = table.filter(operator,
        function(x) return x[3] >= minAllowedMood end)
    local best = {}
    local best_score = -1
    for _, o in pairs(operator) do
        local s = 0
        for _, icon in pairs({ o[1], o[2] }) do
            if icon == "bskill_pow_count" then --程曦格雷伊2 发电站数量+1
                if isCharExsit["正义骑士号"] or isCharExsit["作业平台"] then
                    s = s - 1
                else
                    s = s + 0.1
                end
            elseif icon == "bskill_pow_spd1" then
                s = s + 0.1
                if table.findv({ "Lancet-2", "Castle-3", "THRM-EX", "正义骑士号", "Friston-3", "PhonoR-0" }, o[6]) and isCharExsit["承曦格雷伊"] then
                    s = s - 1
                end
                if table.findv({ "Lancet-2" }, o[6]) and isCharExsit["正义骑士号"] and not isCharExsit["承曦格雷伊"] then
                    s = s + 0.101
                end
            elseif icon == "bskill_pow_spd_P1" then --PhonoR-0
                if isCharExsit["承曦格雷伊"] then
                    s = s - 1
                end
            elseif icon == "bskill_power_rec_spd&addition2" then
                s = s + 0.15
            elseif icon == "bskill_power_rec_spd&addition1" then
                s = s + 0.13
            elseif icon == "bskill_power_rec_rhine" then --缪尔赛思
                s = s + 0.11
            elseif icon == "bskill_pow_drone" then
                s = s + 0.2
            elseif icon == "bskill_pow_spd3" then
                s = s + 0.2
                if table.findv({ "Lancet-2", "Castle-3", "THRM-EX", "正义骑士号", "Friston-3", "PhonoR-0" }, o[6]) then
                    --防止误判
                    s = s - 0.2
                end
            elseif icon == "bskill_pow_spd2" then
                s = s + 0.15
                --让异客和清流尽量在制造站上班
                if table.findv({ "异客", "清流" }, o[6]) then
                    s = s - 1
                end
            elseif icon == "bskill_pow_spd&cost" then --Friston-3
                if isCharExsit["凯尔希"] then
                    s = s + 0.05
                end
                if isCharExsit["承曦格雷伊"] then
                    s = s - 1
                end
            elseif icon == "bskill_pow_jnight" then --正义骑士号
                if isCharExsit["承曦格雷伊"] then
                    s = s - 1
                elseif isCharExsit["焰尾"] or isCharExsit["薇薇安娜"] then
                    s = s + 0.101
                end
            elseif icon == "bskill_pow_spd&cost" then --THRM-EX
                if isCharExsit["承曦格雷伊"] then
                    s = s - 1
                end
            end
        end
        table.insert(best, { s, o })
    end
    table.sort(best, function(a, b) return a[1] > b[1] end)
    best = best[1][2]
    return { best }, best_score
end

ygStaitonColor = {
    'ffffbb22', -- 贸易,
    'ff00d8ff', -- 制造,
    'ff77dcc7', -- 发电,
    'ffffffff', -- 宿舍,
    -- 'ffffffff', -- 控制,
    -- 'ffffffff', -- 会客,
}

is_training = function()
    local ret = find_color({ scale(46), scale(642), scale(172), scale(1026) }, "72001F", 0, 1)
    ret = ret and true or false
    return ret
end

correctCharName = function(t)
    --主要是720p下面的校正
    if t == nil then return end
    local 替换 = {
        ["森"] = "森蚺",
        ["铜"] = "锏",
        ["白面鸭"] = "白面鸮",
        ["3"] = "山",
        ["白面鸦"] = "白面鸮",
        ["白面鹗"] = "白面鸮",
        ["0"] = "山",
        ["E"] = "山",
        ["1"] = "山",
        ["T"] = "山",
        ["任"] = "山",
        ["灰"] = "灰烬",
        ["委"] = "黍",
        ["默德克萨斯"] = "缄默德克萨斯",
        ["翎羽羽"] = "翎羽",
        ["纯烟艾雅法拉"] = "纯烬艾雅法拉",
        ["纯艾雅法拉"] = "纯烬艾雅法拉",
        ["林纯艾雅法拉"] = "纯烬艾雅法拉",
        ["哞"] = "吽",
        ["子"] = "孑",
        ["巡巡林者"] = "巡林者",
        ["愧影"] = "傀影",
        ["狮蜴"] = "狮蝎",
        ["圣约送葬"] = "圣约送葬人",
        ["霸叶"] = "霜叶",
        ["灰亳"] = "灰毫",
        ["势"] = "芬",
    }

    local 原文本 = t
    --print(原文本)
    if 替换[原文本] then
        t = 替换[原文本]
    elseif 原文本:match("^白面.*$") then
        t = "白面鸮"
    elseif 原文本:find("纯") and 原文本:find("艾雅法拉") then
        t = "纯烬艾雅法拉"
    elseif 原文本:find("默") and 原文本:find("德克萨斯") then
        t = "缄默德克萨斯"
    end
    return t
end
