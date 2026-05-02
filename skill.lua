---滑动以获得基建干员信息
---@param operators table 干员
---@param pngdata table 该组干员属于那种建筑
---@param pageid number 最大翻页次数
---@param mood_only boolean 仅识别心情
---@param stationType string 建筑类型
discover = still_wrapper(function(operators, pngdata, pageid, mood_only, stationType)
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
    log.debug(#corner)

    local card = {}
    if #corner == 0 then
        log.warn("基建换班找不到卡片")
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
    log.debug(card)
    local empty1_num = 0
    for idx, v in pairs(card) do
        -- 技能图标1坐标
        local icon1 = {
            v[1] + scale(7), v[2] + scale(18), v[1] + scale(60), v[2] + scale(70),
        }
        -- 技能图标2坐标
        local icon2 = {
            v[1] + scale(70), v[2] + scale(18), v[1] + scale(123), v[2] + scale(70),
        }
        --log("icon1", icon1, v[1], v[2])
        local name = "干员名未进行识别"
        if dev_mode or (not not_use_ocr and not mood_only and
                table.findv({ "制造站", "发电站", "宿舍", "控制中枢" }, stationType)) then
            local status, charName = pcall(ocro, {
                v[1] + scale(7), v[2] + scale(104), v[1] + scale(191), v[2] + scale(134),
            })
            if status then
                name = correctCharName(charName)
            else
                toast("OCR错误：请在 高级设置-基建 内勾选不使用OCR")
            end
        end

        local png = ''
        local png2 = ''
        -- log("mood_only", mood_only)
        if not mood_only then
            png = 'empty1'
            png =
                findBuildingSkill(icon1[1], icon1[2], icon1[3], icon1[4], pngdata) or
                png
            log("png1", png, name)
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
                log("png2", png2, name)
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
        log.debug(idx, operator, mood, name)
        table.insert(operators, { png, png2, mood, icon1, pageid, name })
    end
    -- sleep(max(0, delay - (time() - start_time)))
    log.debug(operators)
    -- exit()
end)

-- 宿舍专用识别,不识别技能,只识别心情和干员名,有可能给深海队和推王组用
discoverWithOcr = still_wrapper(function(operators, pngdata, pageid, mood_only, stationType)
    local prewhite = 0
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
    log("dis ocr")
    log.debug(#corner)

    local card = {}
    if #corner == 0 then
        log.warn("基建换班找不到卡片")
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
    log.debug(card)
    local empty1_num = 0
    for idx, v in pairs(card) do
        -- 技能判断
        local icon1 = {
            v[1] + scale(7), v[2] + scale(18), v[1] + scale(60), v[2] + scale(70),
        }
        local name = "干员名未识别"
        if dev_mode or (not not_use_ocr) then
            log.debug()
            local status, charName = pcall(ocro, {
                v[1] + scale(7), v[2] + scale(104), v[1] + scale(191), v[2] + scale(134),
            })
            if status then
                name = correctCharName(charName)
            else
                toast("OCR错误：请在测试功能内勾选不使用OCR")
            end
        end

        local png = ''
        local png2 = ''

        -- 心情判断
        local mood = 0
        -- log(v[1])
        local mood1 = { v[1] + scale(49), v[2] + scale(93) }
        -- log(mood1)
        for i = 24, 1, -1 do
            local moodi = { mood1[1] + scale((i - 1) * 5.3478), mood1[2] }
            if cmpColor(moodi[1], moodi[2], 'FFFFFF', 0.4) == 1 then
                mood = i
                break
            end
        end
        log.debug(idx, operator, mood, name)
        table.insert(operators, { png, png2, mood, icon1, pageid, name })
    end
    log.debug(operators)
end)

--- 贸易站干员选择
---@param operator table 干员列表，每个元素包含两个技能图标与心情
---@param dormitoryCapacity integer 宿舍可容纳人数
---@param dormitoryLevelSum integer 宿舍等级之和
---@param goldStationNum integer 赤金生产线数
---@param goodType string 交易物类别
---@param level integer 贸易站等级
---@return tabel 返回效率最高的index
tradingStationOperatorBest = function(operator, dormitoryCapacity,
                                      dormitoryLevelSum, goldStationNum,
                                      goodType, level)
    log.debug("goldStationNum,dormitoryCapacity,dormitoryLevelSum",
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
            if icon == 'bskill_tra_spd3' then             -- 能天使2
                base = base + 0.35
            elseif icon == 'bskill_tra_spd&formula1' then --石英
                base = base + 0.3 + 0.04                  -- 近似两种产物
            elseif icon == 'bskill_tra_spd&meet1' then    --伺夜
                base = base + 0.4                         -- 近似满级会客厅
                if isCharExsit["八幡海铃"] then
                    base = base + 0.05
                end
            elseif icon == 'bskill_tra_ord_spd_ext2' then --贝洛内0
                base = base + 0.25
                if isCharExsit["八幡海铃"] then
                    base = base + 0.05
                end
            elseif icon == 'bskill_tra_ord_spd_ext3' then --贝洛内2
                base = base + 0.3
                if isCharExsit["八幡海铃"] then
                    base = base + 0.05
                end
            elseif icon == 'bskill_tra_share3' then --吉星2
                base = base + 0.2 * (level - 1)
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
            elseif icon == 'bskill_tra_share2' then     --吉星0
                base = base + 0.1 * (level - 1)
            elseif icon == 'bskill_tra_spd&limit5' then --蕾缪安2
                base = base + 0.20
            elseif icon == 'bskill_tra_spd_bd2' then    --黑键2
                base = base + 0.005 * dormitoryCapacity
                if isCharExsit["迷迭香"] or isCharExsit["絮雨"] then
                    base = base + 0.44
                end
            elseif icon == 'bskill_tra_spd&limit4' then --崖心2
                base = base + 0.15
                storage = storage + 4
                if isCharExsit["灵知"] then
                    base = base - 0.15
                    storage = storage + 6
                end
            elseif icon == 'bskill_tra_spd&limit3' then --银灰0,角峰0,讯使0
                base = base + 0.15
                storage = storage + 2
                if isCharExsit["灵知"] then
                    base = base - 0.15
                    storage = storage + 6
                end
            elseif icon == 'bskill_tra_spd&limit2' then
                base = base + 0.1
                storage = storage + 4
            elseif icon == 'bskill_tra_spd&limit1' then
                base = base + 0.1
                storage = storage + 2
            elseif icon == 'bskill_tra_closure' then --可露希尔2
                base = base + 0.1
            elseif icon == 'bskill_tra_spd2' then
                base = base + 0.3
            elseif icon == 'bskill_tra_spd1' then
                base = base + 0.2
            elseif icon == "bskill_tra_par&per1" then -- 赫德雷1 伊内丝和W加成不考虑
                base = base + 0.25
                if isCharExsit["伊内丝"] then
                    base = base + 0.05
                end
            elseif icon == "bskill_tra_par&per2" then -- 赫德雷2
                base = base + 0.30
                if isCharExsit["维什戴尔"] then
                    storage = storage + 2
                end
                if isCharExsit["伊内丝"] then
                    base = base + 0.05
                end
            elseif icon == "trade_ord_spd&par1" then -- 维娜·维多利亚 道格拉斯帮加成不考虑
                base = base + 0.30
            elseif icon == "trade_ord_spd&par2" then -- 维娜·维多利亚2 道格拉斯帮加成不考虑
                base = base + 0.30
                -- 道格拉斯帮加成0.1
            elseif icon == "bskill_tra_ord_spd_ext0" then -- 深巡1
                base = base + 0.25
                if isCharExsit["乌尔比安"] then
                    base = base + 0.05
                end
            elseif icon == "bskill_tra_ord_spd_ext1" then -- 深巡2
                base = base + 0.30
                if isCharExsit["乌尔比安"] then
                    base = base + 0.10
                end
            elseif icon == "bskill_tra_spd&limit_down1" then -- 锏
                base = base + 0.20
                storage = storage - 2
                if isCharExsit["灵知"] then
                    base = base - 0.15
                    storage = storage + 6
                end
            elseif icon == "bskill_tra_spd&limit_down2" then -- 锏2
                base = base + 0.25
                storage = storage - 6
                if isCharExsit["灵知"] then
                    base = base - 0.15
                    storage = storage + 6
                end
            elseif icon == 'bskill_tra_flow_gc2' then
                base = base + 0.05
                gold = gold + (gold // 2) * 2
            elseif icon == 'bskill_tra_flow_gc1' then
                base = base + 0.05
                gold = gold + (gold // 4) * 2
            elseif icon == 'bskill_tra_flow_durin' then --鸿雪2
                --默认桃金娘和杜林在宿舍
                -- gold = gold + 2
            elseif icon == 'bskill_tra_spd&limit_felyne' then --泰拉大陆调查团
                base = base + 0.05
                storage = storage + 2
                if isCharExsit["麒麟R夜刀"] and isCharExsit["火龙S黑角"] then
                    base = base + 0.361
                end
            elseif icon == 'bskill_tra_spd&dorm2' then
                base = base + 0.02 * dormitoryLevelSum
            elseif icon == 'bskill_tra_spd&dorm1' then
                base = base + 0.01 * dormitoryLevelSum
            elseif icon == 'bskill_tra_bd_n2' then --乌有2
                base = base + 0.01 * dormitoryCapacity
                if isCharExsit["桑葚"] then
                    base = base + 0.21
                end
                if isCharExsit["重岳"] then
                    base = base + 0.15
                end
            elseif icon == 'bskill_tra_limit&cost' then
                storage = storage + 5
            elseif icon == 'bskill_tra_limit&trade2' then -- 瑰盐0
                storage = storage + level
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
        if all['bskill_tra_lappland1'] then
            if texas then
                storage = storage + 2
                base = base + 0.65
            end
            if isCharExsit["八幡海铃"] then
                base = base + 0.05
            end
        elseif all['bskill_tra_lappland2'] then
            if texas then
                storage = storage + 4
                base = base + 0.65
            end
            if isCharExsit["八幡海铃"] then
                base = base + 0.05
            end
        end

        -- 贝洛内&伺夜
        local vigil = all["bskill_tra_spd&meet1"] -- 伺夜
        if all['bskill_tra_ord_spd_ext2'] and vigil then
            base = base + 0.05
            storage = storage + 2
        elseif all['bskill_tra_ord_spd_ext3'] and vigil then
            base = base + 0.1
            storage = storage + 2
        end

        -- 老能天使+蕾缪安2,老能天使技能不唯一(需要ocr),暂时不考虑

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

        -- 琳琅诗怀雅
        if all["bskill_trade_ord_spd_variable"] then base = base + storage * 0.04 end

        -- 锏2
        if all["bskill_tra_limit2spd"] then base = base + min(1.00, math.floor(storage / 5) * 0.25) end

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

        -- 但书，禁用巫恋、可露希尔
        if not all['bskill_tra_vodfox'] and not all['bskill_tra_closure'] and goodType == "贵金属" then
            if all['bskill_tra_against'] then base = (1 + base) * 1.276 - 1 end
            if all['bskill_tra_against2'] then base = (1 + base) * 1.556 - 1 end
        end

        -- 可露希尔，禁用巫恋、但书
        if not all['bskill_tra_against'] and not all['bskill_tra_against2'] and
            not all['bskill_tra_vodfox'] and not all['bskill_tra_closure'] and goodType == "贵金属" then
            if all['bskill_tra_closure'] then base = (1 + base) * 1.804 - 1 end
        end

        -- 禁用尤里卡
        if all['bskill_tra_spd&wt1'] then base = -1 end

        return base, only_need
    end
    log.debug()
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
    log.debug(#operator, maxOperator)
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
    log.debug(#best_only_need)
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

--- 制造站干员选择
---@param operator table 干员列表，每个元素包含两个技能图标与心情
---@param tradingStationNum integer 贸易站数量
---@param powerStationNum integer 发电站数量
---@param dormitoryLevelSum integer 宿舍等级之和
---@param totalStationLevel integer 建筑等级总量
---@param goodType string 制造物类别
---@param level integer 制造站等级
---@return tabel 返回效率最高的index
manufacturingStationOperatorBest = function(operator, tradingStationNum,
                                            powerStationNum, dormitoryLevelSum, totalStationLevel,
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
    log.debug("goodType", goodType, operator[1])
    -- log("maxStorage", maxStorage)
    -- log("maxOperator", maxOperator)

    -- 输入index组合，计算平均加成，与groundtruth差距：
    -- 1. 只考虑8小时平均收益，非实际换班间隔
    -- 2. 12心情以下干员不考虑，也忽略心情消耗
    local base, disable_moon_effect, storage, storages, standard, all, station,
    station_only, only_need, robot, abyssal_hunter

    ---@param icons table {[技能1,技能2,name1],[技能1,技能2,name2],[技能1,技能2,name3]}
    local score = function(icons)
        base = 0
        robot = 0            -- 工程机器人
        storage = {}         -- 容量效果
        standard = 0         -- 标准化技能数量
        rhine = 0            -- 莱茵科技数量
        metallics = 0        -- 金属工艺数量
        station = 0          -- 根据设施加成
        abyssal_hunter = 0   -- 深海猎人数量
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
            elseif icon == 'bskill_formula_spd_headb1' then
                if goodType == '作战记录' then base = base + 0.3 end
            elseif icon == 'bskill_formula_spd_headb2' then
                if goodType == '作战记录' then base = base + 0.3 end
            elseif icon == 'bskill_man_exp1' then
                if goodType == '作战记录' then base = base + 0.2501 end
            elseif icon == 'bskill_man_exp4' then
                if goodType == '作战记录' then base = base + 0.20 end
            elseif icon == 'bskill_man_exp&spd&limit&cost2' then -- 酒神2
                if goodType == '作战记录' then base = base + 0.35 end
            elseif icon == 'bskill_man_exp&spd&limit&cost1' then -- 酒神0
                if goodType == '作战记录' then base = base + 0.20 end
            elseif icon == 'bskill_formula_spd_headb1' then      -- 怒潮凛冬0
                if goodType == '作战记录' then base = base + 0.3 end
            elseif icon == 'bskill_formula_spd_headb2' then      -- 怒潮凛冬2
                -- 乌萨斯学生团暂时不考虑
                if goodType == '作战记录' then base = base + 0.3 end
            elseif icon == 'bskill_man_exp&spd&cost1' then --裂响2
                if goodType == '作战记录' then base = base + 0.34999 end
            elseif icon == 'bskill_man_gold2' then         -- 砾
                if goodType == '贵金属' then
                    base = base + 0.35
                    metallics = metallics + 1
                end
                if isCharExsit["薇薇安娜"] then base = base + 0.07 end
            elseif icon == 'bskill_man_gold1' then
                if goodType == '贵金属' then
                    base = base + 0.3001
                    metallics = metallics + 1
                end
            elseif icon == 'bskill_man_spd&dorm1' then
                -- 娜仁图亚
                if goodType == '贵金属' then
                    base = base + 0.01 * dormitoryLevelSum
                end
            elseif icon == 'bskill_man_spd&trade' then
                -- 清流，使用贸易站数量
                if goodType == '贵金属' then
                    -- base = base + 0.20 * tradingStationNum
                    station = station + 0.20 * tradingStationNum
                end
            elseif icon == 'bskill_man_spd_manu1' then
                -- 冬时0不考虑
            elseif icon == 'bskill_man_spd&trade1' then
                -- 引星棘刺2，使用贸易站数量
                if goodType == '贵金属' then
                    base = base + 0.03 * tradingStationNum
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
                -- 迷迭香1不考虑
            elseif icon == 'bskill_man_spd_bd1' then
                -- 迷迭香1不考虑
            elseif icon == 'bskill_man_spd_bd2' then --迷迭香2
                if isCharExsit["絮雨"] then
                    base = base + 0.40999
                end
            elseif icon == "bskill_man_cost_room1" then
                -- 排除黍1
            elseif icon == "bskill_man_spd_bd5" then
                -- 排除截云1
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
                elseif table.findv({ "白面鸮", "赫默", "多萝西", "星源", "溯光星源", "娜斯提" }, name) then
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
            elseif icon == 'bskill_man_spd&limit6' then
                base = base + 0.20
                storage[operatoridx] = (storage[operatoridx] or 0) - 8
            elseif icon == 'bskill_man_spd_add1' then
                -- 8小时平均收益 ((0.2+0.24)/2*5+0.25*3)/8
                base = base + 0.23125
            elseif icon == 'bskill_man_spd_veen' then   --维伊2,认为训练室3级
                base = base + 0.299
            elseif icon == 'bskill_man_spd_reduce' then --铅踝
                base = base + 0.22
            elseif icon == 'bskill_man_spd_add2' then
                -- 8小时平均收益 ((0.15+0.23)/2*5+0.25*3)/8
                base = base + 0.2125
            elseif icon == 'bskill_man_marcille1' then  --玛露西尔1
                base = base + 0.2
            elseif icon == 'bskill_man_marcille2' then  --玛露西尔2
                base = base + 0.3
            elseif icon == 'bskill_man_spd&cost1' then  --裁度0
                base = base + 0.2
            elseif icon == 'bskill_man_spd&cost2' then  --雪猎0
                base = base + 0.2
            elseif icon == 'bskill_man_spd&cost3' then  --雪猎2
                base = base + 0.3
            elseif icon == 'bskill_man_spd&limit5' then --裁度2
                base = base + 0.25
                storage[operatoridx] = (storage[operatoridx] or 0) + 6
            elseif icon == "bskill_man_spd_add3" then
                base = base + 0.1 -- 10小时平均收益 8h收益为0.073
            elseif icon == 'bskill_man_spd1' then
                base = base + 0.15
                local name = icons[operatoridx][3]
                --log(name)
                if table.findv({ "夜刀", "流星", "豆苗", "褐果", "石英", "洋灰", "历阵锐枪芬" }, name) then
                    standard = standard + 1
                elseif table.findv({ "白面鸮", "赫默", "星源", "溯光星源", "娜斯提" }, name) then
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
            elseif icon == 'bskill_man_constrlv' then
                robot = min(64, robot + totalStationLevel)
            elseif icon == 'abyssal_hunter' then
                local name = icons[operatoridx][3]
                abyssal_hunter = abyssal_hunter + 1
                if abyssal_hunter < 3 and not isCharExsit[name] then
                    base = base + 0.40 + 0.001 --加一点超过槐琥之类
                end
            elseif icon == 'empty' then
                log('empty')
            end
        end

        -- 应用全局性技能
        -- 至简
        if all["bskill_man_spd_bd3"] then base = base + (robot // 16) * 0.05 end
        if all["bskill_man_spd_bd4"] then base = base + (robot // 8) * 0.05 end

        -- Miss.Christine2
        local tragodia = all['bskill_man_exp&spd&limit&cost2'] or all['bskill_man_exp&spd&limit&cost1']
        if all['bskill_man_spd_double2'] and tragodia then
            if goodType == '作战记录' then base = base + 0.3 end
        end

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
            -- 槐琥
            base = base + min(0.4, base // 0.05 * 0.05 - abyssal_hunter * 0.4) *
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
        if all['bskill_man_spd_manu2'] then -- 冬时1，仓库加成不考虑
            station_only = true
            station = station + 0.1 * level
            table.extend(only_need, { 'bskill_man_spd_manu2' })
        end
        if all['bskill_man_skill_spd'] then
            -- 水月，标准化技能数量
            if not_use_ocr then standard = 1 end --自身至少是一个
            base = base + standard * 0.0501 * all['bskill_man_skill_spd'] - 0.0002
        end
        if all['bskill_man_skill_spd2'] then
            -- 多萝西，莱茵科技技能数量
            if not_use_ocr then rhine = 1 end --自身至少是一个
            base = base + rhine * 0.0501 * all['bskill_man_skill_spd2'] - 0.0002
        end
        if all['bskill_man_gold&rhine'] and goodType == '贵金属' then
            -- 娜斯提，全基建莱茵科技干员数量(不等同于莱茵科技数量,暂且认为一样)
            if not_use_ocr then rhine = 1 end --自身至少是一个
            base = base + rhine * 0.03 * all['bskill_man_gold&rhine']
        end
        if all['bskill_man_skill_spd3'] and goodType == '贵金属' then
            -- 苍苔，金属工艺技能数量
            base = base + metallics * 0.0501 * all['bskill_man_skill_spd3'] - 0.0002
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
    log.debug(#operator, maxOperator)
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
    log.debug("best", best)
    -- 特殊处理，白板干员用白板
    if #best_only_need > 0 then
        best = table.filter(best, function(v)
            return #table.intersect(best_only_need, { v[1], v[2] }) > 0
        end)
    end
    return best, best_score
end

local stationIconMask = {}
local w, h = 36, 36
for i = 1, h do
    for j = 1, w do
        if ((i - 18) ^ 2 + (j - 18) ^ 2) < 18.3 ^ 2 then
            table.insert(stationIconMask, { i, j })
        end
    end
end
-- exit()

findBuildingSkill = function(x1, y1, x2, y2, pngdata)
    local s = ''
    local w, h, color = getScreenPixel(x1, y1, x2, y2)
    local i, j, b, g, r
    local data = {}
    local abs = math.abs
    for _, m in pairs(stationIconMask) do
        i, j = m[1], m[2]
        -- b, g, r = colorToRGB(color[(i - 1) * w + j])
        -- 3d3d3d
        b, g, r = colorToRGB(color[scale((i - 1) / 720 * 1080) * w +
        scale(j / 720 * 1080)])
        -- if abs(b - 61) < 2 and abs(r - 61) < 2 and abs(g - 61) < 2 then
        --     -- 透明背景处理
        --     table.extend(data, { 255, 255, 255 })
        -- else
        --     table.extend(data, { r, g, b })
        -- end
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

    local flatScoreTable = {}
    local flatScore = 0
    local length = #stationIconMask - 36
    for i = 1, length do
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

        --if k == 'bskill_man_spd&power3' then log(662, score, tmp) end
        --if k == 'bskill_man_spd&power2' then log(663, score, tmp) end
        --if k == 'bskill_man_spd&power1' then log(663, score, tmp) end --异客

        if best_score > score then
            best_score = score
            best = k
        end
    end
    --log(2208, best_score, best, x1, y1, x2, y2)
    return best
end

initPngdata = function()
    if skillpng2operator then return end
    log("初始化图标")
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
    dormitoryPngdata = {}
    trainingPngdata = {}
    workshopPngdata = {}
    stationType2pngData = {
        制造站 = manufacturingPngdata,
        贸易站 = tradingPngdata,
        会客厅 = meetingPngdata,
        控制中枢 = controlPngdata,
        办公室 = officePngdata,
        发电站 = powerPngdata,
        宿舍 = dormitoryPngdata,
        肥鸭 = dormitoryPngdata,
        训练室 = trainingPngdata,
        加工站 = workshopPngdata,
    }
    local s = ''
    for v, _ in pairs(skillpng2operator) do
        local pngdata
        if v:startsWith("bskill_man") then
            pngdata = manufacturingPngdata
        elseif v:startsWith("bskill_formula") then
            pngdata = manufacturingPngdata
        elseif v:startsWith("bskill_tra_") then
            pngdata = tradingPngdata
        elseif v:startsWith("trade_") then
            pngdata = tradingPngdata
        elseif v:startsWith("bskill_meet") then
            pngdata = meetingPngdata
        elseif v:startsWith("bskill_ctrl") then
            pngdata = controlPngdata
        elseif v:startsWith("bskill_token_prod_spd3") then
            pngdata = controlPngdata
        elseif v:startsWith("bskill_hire") then
            pngdata = officePngdata
        elseif v:startsWith("bskill_pow") then
            pngdata = powerPngdata
        elseif v:startsWith("bskill_dorm") then
            pngdata = dormitoryPngdata
        elseif v:startsWith("bskill_train") then
            pngdata = trainingPngdata
        elseif v:startsWith("bskill_ws_") then
            pngdata = workshopPngdata
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
    png_init = true
    log("基建图标数据初始化完成")
end

local 选择干员1 = function(干员目录)
    local 需要干员数 = #干员目录
    local 已选择 = {}
    local selected = 0

    local 找干员 = function(识别结果)
        for i = 1, 需要干员数 do
            -- print "需要干员", i, 干员组[i]
            if 已选择[i] == nil then
                for _, 结果 in ipairs(识别结果) do
                    --print(结果)
                    if 结果["text"] == 干员目录[i] then
                        tap({ 结果["r"] - scale(100), 结果["b"] - scale(200) }) --肉鸽?
                        --加一个appear出现角色选择的蓝框
                        sleep(300)
                        已选择[i] = 1
                        selected = selected + 1
                        break
                    end
                end
            end
        end
    end
    keepCapture()
    for i = 1, 18 do
        local 识别结果 = 干员名ocr校正(ocrex("基建上排干员范围"))
        找干员(识别结果)
        识别结果 = 干员名ocr校正(ocrex("基建下排干员范围"))
        找干员(识别结果)
        if selected < 需要干员数 then
            swipo()
            keepCapture()
        else
            return { 0 }
        end
    end
end

-- 基建按照名字选择干员
chooseOperatorByOcr = function(干员)
    local 编入数量 = 0
    local 未编入数量 = 0

    if appear("筛选") then
        tap("职业选择")
        appear("职业选择", 2)
    end
    local choseChar = function(干员)
        local 记录未编入数量
        --8个职业
        for i = 1, 8 do
            local 干员名字字符串 = ""
            local 干员目录 = {}
            for _, item in ipairs(干员) do
                if 干员职业[item] == operator_job[i] then
                    干员名字字符串 = 干员名字字符串 .. item
                    table.insert(干员目录, item)
                end
            end
            if 干员名字字符串 ~= "" then
                if not findOne("普通作战编队列表" .. i) then
                    tap("普通作战编队列表" .. i)
                    appear("普通作战编队列表" .. i)
                    sleep(200)
                end
                未编入 = 选择干员1(干员目录)
                未编入数量 = 未编入数量 + 未编入[1]
                if 未编入数量 == 1 and 未编入干员[1] == nil then
                    未编入干员 = { i, 未编入[2] }
                end
            end
            --print("编入数量", 编入数量)
        end
    end
    choseChar(干员)
    releaseCapture()
    if not findOne("职业选择") then
        tap("职业选择")
        ssleep(.2)
        appear("职业选择", 2)
    end
    if findOne("职业选择") then
        tap("职业选择")
        appear("筛选", 2)
    end

    --[[ if not wait(function()
            if findOne("筛选") then return true end
            tap("筛选")
            ssleep(.5)
        end, 10) then
        return
    end ]]
    return true
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

    initPngdata()
    wait(function()
        return png_init
    end, 5)
    -- exit()
    -- ==> 滑动获取所有技能

    local maxSwipTimes = 10
    local operator = {}
    for i = 1, maxSwipTimes do
        -- if discover(operator,
        --             (not trading) and manufacturingPngdata or tradingPngdata, i) then
        -- log(stationType, #stationType2pngData[stationType])
        if discover(operator, stationType2pngData[stationType], i, false, stationType) then break end
        if stationType == "肥鸭" then break end
        -- exit()

        local state = sample("干员第一个")
        -- 三次重试
        for j = 1, 3 do
            log.debug("尝试第", j, "次翻页")
            if findOne("正在提交反馈至神经") then
                disappear("正在提交反馈至神经", network_timeout)
                ssleep(.5)
            end
            swipo()
            if not findOne(state) then break end
        end
    end
    if not not_use_ocr and stationType == "制造站" and isCharExsit["歌蕾蒂娅"] then
        -- 自定义深海猎人技能为"abyssal_hunter"
        table.insert(operator,
            { "abyssal_hunter", "empty2", 24, { scale(301), scale(901), scale(301), scale(901) }, 20, "斯卡蒂" })
        table.insert(operator,
            { "abyssal_hunter", "empty2", 24, { scale(301), scale(901), scale(301), scale(901) }, 20, "幽灵鲨" })
        table.insert(operator,
            { "abyssal_hunter", "empty2", 24, { scale(301), scale(901), scale(301), scale(901) }, 20, "乌尔比安" })
        table.insert(operator,
            { "abyssal_hunter", "empty2", 24, { scale(301), scale(901), scale(301), scale(901) }, 20, "安哲拉" })

        if not 干员职业 then
            干员职业 = JsonDecode(readFile("character_type_list.json"))
        end
    end

    swipo(true, true)
    start_time = time()

    log.debug(operator)
    -- 检查operator
    local tto = 0
    for i = 1, #operator do
        if operator[i][1] == "" then
            log("没有技能", operator[i])
            -- table.remove(operator, i)
            -- i = i - 1
            tto = tto + 1
        end
    end
    log(#operator, tto)
    if #operator == tto then
        log.warn("全部干员识别失败")
        return
    end

    -- 计算最优技能
    local best, best_score
    if stationType == "制造站" then
        best, best_score = manufacturingStationOperatorBest(operator,
            tradingStationNum,
            virtralPowerStationNum,
            dormitoryLevelSum,
            totalStationLevel,
            goodType, stationLevel)
        log("制造站选", best)
        for i = 1, #best do
            if table.findv(best[i], "bskill_man_spd_bd2") then
                isCharExsit["迷迭香"] = true
            elseif table.findv(best[i], "abyssal_hunter") then
                isCharExsit[best[i][6]] = true
            end
        end
    elseif stationType == "贸易站" then
        best, best_score = tradingStationOperatorBest(operator, dormitoryCapacity,
            dormitoryLevelSum,
            goldStationNum, goodType,
            stationLevel)
        log("贸易站选", best)
        for i = 1, #best do
            if table.findv(best[i], "bskill_tra_flow_durin") then
                isCharExsit["鸿雪"] = true
                break
            end
        end
    elseif stationType == "会客厅" then
        best, best_score = meetingStationOperatorBest(operator)
        if table.findv(best[1], "bskill_meet_spd_hast1") then
            isCharExsit["伊内丝"] = true
        end
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
        log("控制中枢选", best)
    elseif stationType == "宿舍" then
        best, best_score = dormitoryOperatorBest(operator, goodType, virtralPowerStationNum)
        log("宿舍选", best)
    elseif stationType == "肥鸭" then
        best, best_score = dormitoryOperatorFiammetta(operator)
        if best_score < 1 then
            return
        else
            log("宿舍选肥鸭")
        end
    elseif stationType == "训练室" then
        --goodType表示被训练干员的职业,stationLevel表示被训练干员的专精等级
        best, best_score = trainingOperatorBest(operator, goodType, stationLevel)
        log("训练室选", best)
    elseif stationType == "加工站" then
        --goodType表示材料,stationLevel表示材料等级等级
        best, best_score = workshopOperatorBest(operator, goodType, stationLevel)
        log("加工站选", best)
    end
    sleep(max(0, 500 - (time() - start_time)))
    tap("清空选择")

    -- 按页数排序
    table.sort(best, function(a, b) return a[5] < b[5] end)

    -- 选择干员
    operator = best
    log.debug(operator, best_score)
    local pageid = 1
    for i = 1, #operator do
        log(i, operator[i])
        while operator[i][5] > pageid do
            if not table.findv({ "abyssal_hunter" }, operator[i][1]) then
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
            end
            pageid = pageid + 1
        end
        if not table.findv({ "abyssal_hunter" }, operator[i][1]) then
            local p = operator[i][4]
            tap({ p[1] + scale(106), p[2] })
            sleep(50)
        end
    end

    local names = {}
    for i = 1, #operator do
        log.debug(i, operator[i])
        if table.findv({ "abyssal_hunter" }, operator[i][1]) then
            table.insert(names, operator[i][6])
        end
    end
    log(names)
    if #names > 0 then
        chooseOperatorByOcr(names)
    end
    swipo(true, true)
    return true
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
        if table.includes({ o[1], o[2] }, 'bskill_meet_spdowned1') then
            -- 禁用尤里卡
        elseif o[1] == "bskill_meet_spd&cost" or o[2] == "bskill_meet_spd&cost" then -- 见行者
            table.insert(best, 1, o)
        elseif o[1] == "bskill_meet_spdnotowned2" or o[2] ==
            "bskill_meet_spdnotowned2" then
            -- 晓歌
            table.insert(best, o)
        elseif o[1] == "bskill_meet_exchange" or o[2] == "bskill_meet_exchange" then -- 跃跃
            table.insert(best, 1, o)
        elseif table.includes({ o[1], o[2] }, 'bskill_meet_spd_confes1') and isCharExsit["肥鸭"] then --信仰搅拌机2
            table.insert(best, 1, o)
        elseif table.includes({ o[1], o[2] }, 'bskill_meet_spd_hast1') then --伊内丝
            table.insert(best, o)
        elseif table.includes({ o[1], o[2] }, "bskill_meet_spd3") then
            if o[6] ~= "伺夜" then
                table.insert(best, o)
            end
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
            if icon == "bskill_hire_skgoat2" then     --斥罪
                s = s + 0.5
            elseif icon == "bskill_hire_skgoat3" then --水灯心
                s = s + 0.3
            elseif icon == "bskill_hire_skgoat4" then --水灯心
                s = s + 0.45
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
            elseif icon == "bskill_ws_p_kalts2" then --凯尔希·思衡托2
                s = s + 0.3
            elseif icon == "bskill_hire_spd&ursus2" then
                s = s + 0.2
            elseif icon == "bskill_hire_spd_memento" then --絮雨2
                s = s + 0.31
            elseif icon == "bskill_hire_spd_bd_n2" then   --桑葚2
                s = s + 0.301
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

    local manu_acc = false    -- 制造加速
    local trading_acc = false -- 贸易加速
    local mood_reduce = false -- 其他设施心情减免
    local office_acc = false  -- 办公室加速

    if #best < 2 and not not_use_ocr then
        for _, o in pairs(operator) do
            if table.findv({ "诗怀雅" }, o[6]) then
                table.insert(best, o)
                trading_acc = true
            elseif table.includes({ o[1], o[2] }, "bskill_token_prod_spd3_lungmenguard") then
                table.insert(best, o)
                manu_acc = true
            end
        end
        if not trading_acc or not manu_acc then
            --重置
            best = {}
            manu_acc = false
            trading_acc = false
        end
    end

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

    if #best <= 3 and not trading_acc then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_t_spd') then
                -- 阿米娅/诗怀雅/阿斯卡纶..
                trading_acc = true
                table.insert(best, o)
                break
            elseif table.includes({ o[1], o[2] }, 'bskill_ctrl_tra&prod') then
                -- 望，大部分情况下是7%贸易加成
                trading_acc = true
                table.insert(best, o)
                break
            end
        end
    end

    --不使用ocr时无法区分松鼠团和标准化
    if #best <= 4 and not not_use_ocr then
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

    -- 夕
    if #best < 5 and isCharExsit["絮雨"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_cost_bd1') and o[3] > 22 then
                table.insert(best, o)
            end
        end
    end

    -- 令
    if #best < 5 and isCharExsit["桑葚"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_cost_bd1&bd2') and o[3] > 22 then
                table.insert(best, o)
                isCharExsit["令"] = true
                break
            end
        end
    end

    -- 不使用ocr时无法选择深海
    if #best < 5 and not not_use_ocr and use_abyssal_hunter and
        -- 这几个全齐的时候位置不够
        not (isCharExsit["承曦格雷伊"] and isCharExsit["焰尾"] and isCharExsit["薇薇安娜"]) then
        for _, o in pairs(operator) do
            -- 精二歌蕾蒂娅,高心情才使用
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_aegir2') and o[3] > 22 then
                table.insert(best, o)
                isCharExsit["歌蕾蒂娅"] = true
                break
            end
        end
    end

    -- 人间烟火和感知信息都要补琴柳
    if #best < 5 and (isCharExsit["絮雨"] or isCharExsit["桑葚"]) then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_h_spd') and (isCharExsit["絮雨"] or isCharExsit["桑葚"]) then
                if not office_acc then
                    office_acc = true
                    table.insert(best, o)
                    break
                end
            end
        end
    end

    if #best < 5 and not office_acc then
        for _, o in pairs(operator) do
            --八幡海铃0
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_hire_tmoris') then
                office_acc = true
                table.insert(best, o)
                --八幡海铃2,影响叙拉古干员效率计算
                if table.includes({ o[1], o[2] }, 'bskill_ctrl_t_limit&spd_tmoris') then
                    isCharExsit["八幡海铃"] = true
                end
                break
            end
        end
    end

    --凯尔希
    if #best < 5 and not manu_acc then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_p_spd') then
                manu_acc = true
                table.insert(best, o)
                break
            end
        end
    end

    --重岳
    if #best < 5 and isCharExsit["桑葚"] then
        log("寻找重岳")
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, "bskill_ctrl_cost_bd3") then
                table.insert(best, o)
                mood_reduce = true
                isCharExsit["重岳"] = true
                break
            end
        end
    end

    --人间烟火组有重岳再考虑夕
    if #best < 5 and isCharExsit["重岳"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_cost_bd1') then
                table.insert(best, o)
                isCharExsit["夕"] = true
                break
            end
        end
    end

    --丰川祥子1,2技能一样,可以和制造加速类技能叠加
    if #best < 5 then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_p_oblvns') then
                table.insert(best, o)
                isCharExsit["丰川祥子"] = true
                break
            end
        end
    end
    -- 若叶睦
    if #best < 5 and isCharExsit["丰川祥子"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_trade_mortis') then
                table.insert(best, o)
                break
            end
        end
    end
    -- 三角初华
    if #best < 5 and isCharExsit["丰川祥子"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_dorm_uika1') then
                table.insert(best, o)
                break
            end
        end
    end
    -- 祐天寺若麦
    if #best < 5 and isCharExsit["丰川祥子"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_meet_amoris1') then
                table.insert(best, o)
                break
            end
        end
    end

    -- 布丁
    if #best < 5 and not manu_acc and (isCharExsit["作业平台"] and isCharExsit["作业平台"] > 1) then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_token_p_spd') then
                manu_acc = true
                table.insert(best, o)
                break
            end
        end
    end

    --灵知
    if #best < 5 and not (isCharExsit["絮雨"] or isCharExsit["桑葚"]) then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_t_limit&spd') then
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
                isCharExsit["玛恩纳"] = true
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

    if #best < 5 and not not_use_ocr and (not (isCharExsit["絮雨"] or isCharExsit["桑葚"])) and isCharExsit["Lancet-2"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_p_bot') then --森蚺
                table.insert(best, o)
                virtralPowerStationNum = virtralPowerStationNum + 2
                break
            end
        end
    end
    --涤火杰西卡2
    if #best < 5 and not not_use_ocr then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_bd_spd') then
                table.insert(best, o)
                isCharExsit["涤火杰西卡"] = true
                break
            end
        end
    end
    -- 魔王
    if #best < 5 and isCharExsit["维什戴尔"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_c_spd1') then
                table.insert(best, o)
                break
            end
        end
    end
    --艾拉
    if #best < 5 and not isCharExsit["歌蕾蒂娅"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_ctrl_ela') then
                table.insert(best, o)
                break
            end
        end
    end

    if #best < 5 then
        for _, o in pairs(operator) do
            if not table.includes(best, o) and isCharExsit["玛恩纳"]
                -- 笑脸
                and table.includes({ o[1], o[2] }, 'bskill_ctrl_cost')
                --排除m3,不要跟凯尔希一起上班
                and not table.includes({ o[1], o[2] }, 'bskill_ctrl_p_spd')
            then
                table.insert(best, o)
            end
            if #best >= 5 then
                break
            end
        end
    end

    if #best < 5 then
        for _, o in pairs(operator) do
            if not table.includes(best, o) then                             -- 不要重复添加
                if table.includes({ o[1], o[2] }, 'bskill_ctrl_sp') or      -- 异格者
                    table.includes({ o[1], o[2] }, 'bskill_ctrl_cost') then -- 笑脸
                    table.insert(best, o)
                end
            end
            if #best >= 5 then
                break
            end
        end
    end

    --best = table.slice(table.extend(best, remain), 1, 5)
    return best, best_score
end

--挑选两个宿管
dormitoryOperatorBest = function(operator, goodType, virtralPowerStationNum)
    -- 过滤心情小于阈值的干员

    local best = {}
    local best_score = -1

    local all = {}
    local single = {}

    if isCharExsit["迷迭香"] or isCharExsit["絮雨"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, "bskill_dorm_all&bd_n1_2") and
                table.includes({ o[1], o[2] }, "bskill_dorm_all&bd_n1_n3") then --车尔尼2
                table.insert(best, o)
            elseif table.includes({ o[1], o[2] }, "bskill_dorm_all&bd_n1") and
                table.includes({ o[1], o[2] }, "bskill_dorm_all&bd_n1_n2") then --爱丽丝2
                table.insert(best, o)
            elseif table.includes({ o[1], o[2] }, "bskill_dorm_bdnum") or
                table.includes({ o[1], o[2] }, "bskill_dorm_rec_allbd") or o[6] == "塑心" then --塑心
                table.insert(best, o)
            end
        end
        return best, best_score
    end
    if isCharExsit["鸿雪"] then
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, "bskill_dorm_all&one1") or
                table.includes({ o[1], o[2] }, "bskill_dorm_all&one2") then --杜林
                table.insert(best, o)
            elseif table.includes({ o[1], o[2] }, "bskill_dorm_all2") and o[6] == "桃金娘" then --桃金娘
                table.insert(best, o)
            end
        end
        return best, best_score
    end
    -- all
    for _, o in pairs(operator) do
        local s = 0
        for _, icon in pairs({ o[1], o[2] }) do
            if icon == "bskill_dorm_all1" then
                s = s + 0.1
            elseif icon == "bskill_dorm_all2" then
                s = s + 0.15
            elseif icon == "bskill_dorm_all3" then
                s = s + 0.2
            elseif icon == "bskill_dorm_all&one1" then --杜林
                s = s + 0.2
                if isCharExsit["鸿雪"] then
                    s = s + 1
                end
            elseif icon == "bskill_dorm_all&one2" then --杜林
                s = s + 0.25
                if isCharExsit["鸿雪"] then
                    s = s + 1
                end
            elseif icon == "bskill_dorm_all&one3" then
                s = s + 0.1
            elseif icon == "bskill_hire_spd3" then
                s = s + 0.35
            elseif icon == "bskill_dorm_powtorecall2" then
                s = s + 0.15 + virtralPowerStationNum * 0.05
            end
        end
        table.insert(best, { s, o })
        table.sort(best, function(a, b) return a[1] > b[1] end)
        all = best[1][2]
    end

    -- single
    for _, o in pairs(operator) do
        local s = 0
        for _, icon in pairs({ o[1], o[2] }) do
            if icon == "bskill_dorm_single1" then
                s = s + 0.55
            elseif icon == "bskill_dorm_single2" then
                s = s + 0.65
            elseif icon == "bskill_dorm_single3" then
                s = s + 0.7
            elseif icon == "bskill_dorm_single4" then
                s = s + 0.75
            elseif icon == "bskill_dorm_single&one01" then
                s = s + 0.2
            elseif icon == "bskill_dorm_single&one02" then
                s = s + 0.25
            elseif icon == "bskill_dorm_single&one21" then
                s = s + 0.4
            elseif icon == "bskill_dorm_single&one22" then
                s = s + 0.5
            elseif icon == "bskill_dorm_single&one11" then
                s = s + 0.3
            elseif icon == "bskill_dorm_single&one12" then
                s = s + 0.35
            end
        end
        table.insert(best, { s, o })
        table.sort(best, function(a, b) return a[1] > b[1] end)
        single = best[1][2]
    end
    best = { all, single }
    log(best)
    return best, best_score
end

--挑选菲亚梅塔
dormitoryOperatorFiammetta = function(operator)
    -- 过滤心情小于阈值的干员
    local minAllowedMood = 24 --肥鸭技能只在满心情有效
    log.debug(operator)
    operator = table.filter(operator,
        function(x) return x ~= {} or x[3] >= minAllowedMood end)
    local best = {}
    local best_score = -1

    for _, o in pairs(operator) do
        for _, o in pairs(operator) do
            if table.includes({ o[1], o[2] }, 'bskill_dorm_exchangeap')
                or table.includes({ o[1], o[2] }, "bskill_dorm_reborn") then
                table.insert(best, o)
                best_score = 1
                return best, best_score
            end
        end
    end
    return best, best_score
end

powerStationOperatorBest = function(operator)
    -- 过滤心情小于阈值的干员
    log.debug()
    local minAllowedMood = shift_min_mood
    if disable_shift_mood then minAllowedMood = -1 end
    operator = table.filter(operator,
        function(x) return x[3] >= minAllowedMood end)
    local best = {}
    local best_score = -1
    for _, o in pairs(operator) do
        local s = 0
        for _, icon in pairs({ o[1], o[2] }) do
            if icon == "bskill_pow_count" then --承曦格雷伊2 发电站数量+1
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
            elseif icon == "bskill_pow_spd_p1" then --PhonoR-0
                if isCharExsit["承曦格雷伊"] then
                    s = s - 1
                end
            elseif icon == "bskill_power_rec_spd&addition2" then
                s = s + 0.15
            elseif icon == "bskill_power_rec_spd&addition1" then
                s = s + 0.13
            elseif icon == "bskill_power_rec_rhine" then --缪尔赛思
                s = s + 0.11
            elseif icon == "bskill_pow_drone" then       --承曦格雷伊1，无人机上限/10
                s = s + 0.22
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
    log.debug(best)
    table.sort(best, function(a, b) return a[1] > b[1] end)
    best = best[1][2]
    return { best }, best_score
end

trainingOperatorBest = function(operator, charType, targetLevel)
    -- 过滤心情小于阈值的干员
    local minAllowedMood = 16
    log("干员职业", charType, "目标等级", targetLevel)
    if disable_shift_mood then minAllowedMood = -1 end
    operator = table.filter(operator,
        function(x) return x[3] >= minAllowedMood end)
    local best = {}
    local best_score = -1
    --{ "PIONEER", "WARRIOR", "TANK", "SNIPER", "CASTER", "MEDIC", "SPECIAL", "SUPPORT" }
    for _, o in pairs(operator) do
        local s = 0
        for _, icon in pairs({ o[1], o[2] }) do
            if icon == "bskill_train_vanguard1" and charType == "PIONEER" then
                s = s + 0.3
            elseif icon == "bskill_train_vanguard2" and charType == "PIONEER" then
                s = s + 0.5
            elseif icon == "bskill_train_vanguard3" and charType == "PIONEER" then
                s = s + 0.6
            elseif icon == "bskill_train1_vanguard1" and charType == "PIONEER" then
                s = s + 0.3
                if targetLevel == 1 then
                    s = s + 0.45
                end
            elseif icon == "bskill_train_spd&profession2" and charType == "PIONEER" then
                s = s + 0.3
            elseif icon == "bskill_train_specialist&pioneer1" and (charType == "PIONEER" or charType == "SPECIAL") then
                s = s + 0.3
            elseif icon == "bskill_train_specialist&pioneer2" and (charType == "PIONEER" or charType == "SPECIAL") then
                s = s + 0.45
            elseif icon == "bskill_train_all" then
                s = s + 0.25
            elseif icon == "bskill_train_reducetime" and targetLevel < 3 then
                s = s + 0.7
            elseif icon == "bskill_train_spd&level" and targetLevel == 3 then -- 望2
                s = s + 0.7
            elseif icon == "bskill_train_fighter" and charType == "WARRIOR" then
                s = s + 0.3
            elseif icon == "bskill_train_vanguard&sniper" and (charType == "WARRIOR" or charType == "SNIPER") then
                s = s + 0.3
            elseif icon == "bskill_train_caster&vanguard1" and (charType == "WARRIOR" or charType == "CASTER") then
                s = s + 0.3
            elseif icon == "bskill_train_caster&vanguard2" and (charType == "WARRIOR" or charType == "CASTER") then
                s = s + 0.45
            elseif icon == "bskill_train_lord" and charType == "WARRIOR" then
                s = s + 0.3
            elseif icon == "bskill_train_guard1" and charType == "WARRIOR" then
                s = s + 0.3
            elseif icon == "bskill_train_guard2" and charType == "WARRIOR" then
                s = s + 0.5
            elseif icon == "bskill_train_guard3" and charType == "WARRIOR" then
                s = s + 0.6
            elseif icon == "bskill_train3_guard1" and charType == "WARRIOR" then
                s = s + 0.3
                if targetLevel == 3 then
                    s = s + 0.45
                end
            elseif icon == "bskill_train3_guard2" and charType == "WARRIOR" then
                s = s + 0.3
                if targetLevel == 3 then
                    s = s + 0.65
                end
            elseif icon == "bskill_train2_guard1" and charType == "WARRIOR" then
                s = s + 0.3
                if targetLevel == 2 then
                    s = s + 0.45
                end
            elseif icon == "bskill_train1_guard1" and charType == "WARRIOR" then
                s = s + 0.3
                if targetLevel == 1 then
                    s = s + 0.45
                end
            elseif icon == "bskill_train_caster&medic1" and (charType == "MEDIC" or charType == "CASTER") then
                s = s + 0.3
            elseif icon == "bskill_train_caster&medic2" and (charType == "MEDIC" or charType == "CASTER") then
                s = s + 0.45
            elseif icon == "bskill_train_medic1" and charType == "MEDIC" then
                s = s + 0.3
            elseif icon == "bskill_train_wandermedic" and charType == "MEDIC" then
                s = s + 0.3
            elseif icon == "bskill_train_medic2" and charType == "MEDIC" then
                s = s + 0.5
            elseif icon == "bskill_train_medic3" and charType == "MEDIC" then
                s = s + 0.6
            elseif icon == "bskill_train2_medic1" and charType == "MEDIC" then
                s = s + 0.3
                if targetLevel == 2 then
                    s = s + 0.45
                end
            elseif icon == "bskill_train_defender1" and charType == "TANK" then
                s = s + 0.3
            elseif icon == "bskill_train_defender2" and charType == "TANK" then
                s = s + 0.5
            elseif icon == "bskill_train_defender3" and charType == "TANK" then
                s = s + 0.6
            elseif icon == "bskill_train2_defender1" and charType == "TANK" then
                s = s + 0.3
                if targetLevel == 2 then
                    s = s + 0.45
                end
            elseif icon == " bskill_train_artsprotector" and charType == "TANK" then
                s = s + 0.3
            elseif icon == "bskill_train1_defender1" and charType == "TANK" then
                s = s + 0.3
                if targetLevel == 1 then
                    s = s + 0.45
                end
            elseif icon == "bskill_train_caster1" and charType == "CASTER" then
                s = s + 0.3
            elseif icon == "bskill_train_caster2" and charType == "CASTER" then
                s = s + 0.5
            elseif icon == "bskill_train_caster3" and charType == "CASTER" then
                s = s + 0.6
            elseif icon == "bskill_train1_caster1" and charType == "CASTER" then
                s = s + 0.3
                if targetLevel == 1 then
                    s = s + 0.45
                end
            elseif icon == "bskill_train2_caster1" and charType == "CASTER" then
                s = s + 0.3
                if targetLevel == 2 then
                    s = s + 0.45
                end
            elseif icon == "bskill_train3_caster2" and charType == "CASTER" then
                s = s + 0.3
                if targetLevel == 3 then
                    s = s + 0.65
                end
            elseif icon == "bskill_train_caster&supporter1" and (charType == "SUPPORT" or charType == "CASTER") then
                s = s + 0.3
            elseif icon == "bskill_train_supporter1" and charType == "SUPPORT" then
                s = s + 0.3
            elseif icon == "bskill_train_supporter2" and charType == "SUPPORT" then
                s = s + 0.5
            elseif icon == "bskill_train_supporter3" and charType == "SUPPORT" then
                s = s + 0.6
            elseif icon == "bskill_train3_supporter2" and charType == "SUPPORT" then
                s = s + 0.3
                if targetLevel == 3 then
                    s = s + 0.65
                end
            elseif icon == "bskill_train_siegesniper" and charType == "SNIPER" then
                s = s + 0.3
            elseif icon == "bskill_train_sniper1" and charType == "SNIPER" then
                s = s + 0.3
            elseif icon == "bskill_train_sniper2" and charType == "SNIPER" then
                s = s + 0.5
            elseif icon == "bskill_train_sniper3" and charType == "SNIPER" then
                s = s + 0.6
            elseif icon == "bskill_train3_sniper1" and charType == "SNIPER" then
                s = s + 0.3
                if targetLevel == 3 then
                    s = s + 0.45
                end
            elseif icon == "bskill_train2_sniper1" and charType == "SNIPER" then
                s = s + 0.3
                if targetLevel == 2 then
                    s = s + 0.45
                end
            elseif icon == "bskill_train3_sniper2" and charType == "SNIPER" then
                s = s + 0.3
                if targetLevel == 3 then
                    s = s + 0.65
                end
            elseif icon == "bskill_train1_supporter2" and charType == "SNIPER" then
                s = s + 0.3
                if targetLevel == 1 then
                    s = s + 0.65
                end
            elseif icon == "bskill_train_specialist1" and charType == "SPECIAL" then
                s = s + 0.3
            elseif icon == "bskill_train_specialist2" and charType == "SPECIAL" then
                s = s + 0.5
            elseif icon == "bskill_train_specialist3" and charType == "SPECIAL" then
                s = s + 0.6
            elseif icon == "bskill_train1_specialist1" and charType == "SPECIAL" then
                s = s + 0.3
                if targetLevel == 1 then
                    s = s + 0.45
                end
            elseif icon == "bskill_train3_specialist2" and charType == "SPECIAL" then
                s = s + 0.3
                if targetLevel == 3 then
                    s = s + 0.65
                end
            end
        end
        table.insert(best, { s, o })
    end
    table.sort(best, function(a, b) return a[1] > b[1] end)
    best = best[1][2]
    return { best }, best_score
end

workshopOperatorBest = function(operator, id, level)
    -- 暂时只考虑材料合成
    log.debug(id, level)
    --[[{"重装芯片组":"3232","糖聚块":"30024","固化纤维板":"31074","晶体元件":"31033","特种芯片组":"3282","辅助双芯片":"3273",
    "异铁块":"30044","化合切削液":"31053","聚合剂":"30115","烧结核凝晶":"30155","聚酸酯组":"30033","先锋芯片":"3211","源岩":"30011",
    "酮凝集":"30052","精炼溶剂":"31044","重装双芯片":"3233","轻锰矿":"30083","切削原液":"31054","酮阵列":"30054","医疗芯片":"3261",
    "双酮":"30051","晶体电子单元":"30145","环烃预制体":"31084","炽合金":"31023","炽合金块":"31024","聚合凝胶":"31014","近卫芯片":"3221",
    "狙击双芯片":"3243","术师双芯片":"3253","转质盐组":"31063","破损装置":"30061","狙击芯片":"3241","特种芯片":"3281","装置":"30062",
    "转质盐聚块":"31064","改量装置":"30064","代糖":"30021","术师芯片":"3251","酯原料":"30031","辅助芯片":"3271","固源岩组":"30013",
    "双极纳米片":"30125","RMA70-12":"30103","白马醇":"30074","晶体电路":"31034","辅助芯片组":"3272","环烃聚质":"31083","先锋双芯片":"3213",
    "全新装置":"30063","近卫芯片组":"3222","RMA70-24":"30104","半自然溶剂":"31043","褐素纤维":"31073","狙击芯片组":"3242","医疗芯片组":"3262",
    "近卫双芯片":"3223","聚酸酯":"30032","异铁":"30042","先锋芯片组":"3212","术师芯片组":"3252","特种双芯片":"3283","固源岩":"30012",
    "提纯源岩":"30014","异铁碎片":"30041","芯片助剂":"32001","糖":"30022","酮凝集组":"30053","三水锰矿":"30084","重装芯片":"3231",
    "异铁组":"30043","糖组":"30023","研磨石":"30093","聚酸酯块":"30034","医疗双芯片":"3263","扭转醇":"30073","五水研磨石":"30094",
    "凝胶":"31013","D32钢":"30135"}]]

    -- 过滤心情小于阈值的干员
    local minAllowedMood = 24
    if disable_shift_mood then minAllowedMood = -1 end
    operator = table.filter(operator,
        function(x) return x[3] >= minAllowedMood end)
    local best = {}
    local best_score = -1
    for _, o in pairs(operator) do
        local s = 0
        for _, icon in pairs({ o[1], o[2] }) do
            if icon == "bskill_ws_asc1" and #id == 4 and utf8.left(id, 2) == "32" then
                s = s + 0.7
            elseif icon == "bskill_ws_asc2" and #id == 4 and utf8.left(id, 2) == "32" then
                s = s + 0.8
            elseif icon == "bskill_hire_kalts2" then --凯尔希·思衡托2，尽量让在中枢上班
                s = s + 0.8
            elseif icon == "bskill_ws_p5" then       --凯尔希，尽量让在中枢上班
                --s = s + 0.70
            elseif icon == "bskill_ws_p4" then
                s = s + 0.65
            elseif icon == "bskill_ws_p3" then
                s = s + 0.6
            elseif icon == "bskill_ws_evolve4" then
                s = s + 1
            elseif icon == "bskill_ws_evolve3" then
                s = s + 0.8
            elseif icon == "bskill_ws_evolve2" then
                s = s + 0.75
            elseif icon == "bskill_ws_evolve1" then
                s = s + 0.7
            elseif icon == "bskill_ws_free" then            --瑕光0
                s = s + 0.8 - level * 0.1
            elseif icon == "bskill_ws_cost_blemishine" then --瑕光2
                s = s + 0.4
            elseif icon == "bskill_ws_bonus1" and level < 4 then
                s = s + 0.9
            elseif icon == "bskill_ws_bonus2" and level == 4 then
                s = s + 0.9
            elseif icon == "bskill_ws_alloyblock" and id == "31024" then                     --号角
                s = s + 1
            elseif icon == "bskill_ws_orirock" and (id == "30014" or id == "30013") then     --泥岩
                s = s + 0.9
            elseif icon == "bskill_ws_device" and (id == "30064" or id == "30063") then      --贾维
                s = s + 0.9
            elseif icon == "bskill_ws_crystalline" and (id == "31034" or id == "30145") then --特克诺
                s = s + 0.8
            elseif icon == "bskill_ws_skill3" and (id == "3302" or id == "3303") then        --技能书
                s = s + 0.8 + 1                                                              -- +1超过其他合成材料的加成
            elseif icon == "bskill_ws_skill2" and (id == "3302" or id == "3303") then        --技能书
                s = s + 0.75 + 1                                                             -- +1超过其他合成材料的加成
            elseif icon == "bskill_ws_skill1" and (id == "3302" or id == "3303") then        --技能书
                s = s + 0.7 + 1                                                              -- +1超过其他合成材料的加成
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
    local ret = find_color("训练室干员检测范围", "72001F", 0, 0.95)
    return ret and true or false
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
        ["正"] = "山",
        ["在"] = "山",
        ["乐"] = "山",
        ["灰"] = "灰烬",
        ["灰烟"] = "灰烬",
        ["灰炬"] = "灰烬",
        ["委"] = "黍",
        ["默德克萨斯"] = "缄默德克萨斯",
        ["翎羽羽"] = "翎羽",
        ["纯烟艾雅法拉"] = "纯烬艾雅法拉",
        ["纯艾雅法拉"] = "纯烬艾雅法拉",
        ["林纯艾雅法拉"] = "纯烬艾雅法拉",
        ["哞"] = "吽",
        ["哗"] = "吽",
        ["子"] = "孑",
        ["墨键"] = "黑键",
        ["愧影"] = "傀影",
        ["狮蜴"] = "狮蝎",
        ["圣约送葬"] = "圣约送葬人",
        ["霸叶"] = "霜叶",
        ["灰亳"] = "灰毫",
        ["势"] = "芬",
        ["淫灭之相"] = "湮灭之相",
        ["漂御银灰"] = "凛御银灰",
    }

    local 原文本 = t
    --print(原文本)
    if 替换[原文本] then
        t = 替换[原文本]
    elseif #原文本 >= 9 and 原文本:sub(1, 3) == 原文本:sub(4, 6) then
        -- 如果原文本开头的两个汉字相同,则去掉开头第一个汉字
        t = 原文本:sub(4)
    elseif 原文本:match("^白面.*$") then
        t = "白面鸮"
    elseif 原文本:find("纯") and 原文本:find("艾雅法拉") then
        t = "纯烬艾雅法拉"
    elseif 原文本:find("默") and 原文本:find("德克萨斯") then
        t = "缄默德克萨斯"
    elseif 原文本:find("荒芜") and 原文本:find("拉普") then
        t = "荒芜拉普兰德"
    elseif 原文本:find("司") and 原文本:find("惊") then
        t = "司霆惊蛰"
    end
    return t
end
