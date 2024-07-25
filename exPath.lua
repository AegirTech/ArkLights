-- ===========================================
--          额外路径
-- 请所有贡献者在此处添加额外需要的路径
--
-- 命名规范推荐
--  1. 中文命名
--  2. 禁止重载path.lua中已有的路径，避免污染
--
-- ===========================================

path.水月与深蓝之树前瞻投资 = function()
    mizuki_fight_time = mizuki_fight_time or 10
    log("开始水月肉鸽")
    log("检查浪离灯熄")
    if checkPointColor(mizuki_point.浪离灯熄) then
        wait(function()
            if findAny({ "水月_常规行动", "面板" }) then return true end
            if checkPointColor(mizuki_point.等待开始页面标题) then
                return true
            end
            tap({ 630, 597 })
        end, 30)
        -- return
    end

    -- 每8小时做日常
    log("检查每8小时做日常")
    if not zl_no_waste_last_time or time() - zl_no_waste_last_time > 8 * 3600 *
        1000 then
        -- 并非首次
        if zl_no_waste_last_time then
            log("非首次8小时日常")
            zl_no_waste_last_time = nil
            setControlBar()
            restart_account()
            -- saveConfig("hideUIOnce", "true")
            -- save_extra_mode(extra_mode, extra_mode_multi)
            -- restartPackage()
        end

        -- 首次
        if zl_no_waste then
            log("首次做日常")
            setControlBar()
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
            running = "水月与深蓝之树"
            zl_no_waste_last_time = time()
            -- mizuki_navigation()
            -- return false
        end

        zl_no_waste_last_time = time()
    end

    local in_fight_return = ''

    local jumpout
    log("检查是否在关内")
    if findOne("战略返回") then
        tap("战略返回")
        appear("水月_常规行动", 2)
    end

    log("检查是否在暂停")
    if findOne("暂停中") and findOne("生命值") then
        restartapp(appid)
        return false
    end

    log("导航到水月肉鸽")
    if mizuki_navigation() then
        log("水月肉鸽导航成功")
    else
        log("水月肉鸽导航失败")
        return false
    end

    log("检查等级")
    if zl_level_enough then
        if zl_no_waste then
            -- todo
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end
        stop("等级已满，肉鸽结束", '', false, true)
        return false
    end

    log("检查投币")
    if zl_coin_enough then
        if zl_no_waste then
            -- todo
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end
        stop("投币已满，肉鸽结束", '', false, true)
        return false
    end

    -- 检测等级
    local zl_level_check = function()
        if not (str2int(zl_max_level, 0) > 0) then return false end
        if not checkPointColor(mizuki_point.等待开始页面标题) then
            log("未找到水月常规行动")
            return false
        end

        -- if not wait(function()
        --   if not findOne("水月_常规行动") then return true end
        --   tap("战略等级入口")
        -- end) then return end

        log("开始识别等级")

        local x = nil

        local handle = createOcr()
        if handle ~= nil then
            local text = ocrTextEx(handle, mizuki_point.战略等级[1],
                mizuki_point.战略等级[2],
                mizuki_point.战略等级[3],
                mizuki_point.战略等级[4])
            if text ~= nil then
                text = text:gsub(" ", "")
                text = text:gsub("O", "0")
                text = text:gsub("l", "1")
                x = str2int(text:match("%d+"))
                log("识别结果：" .. text)
                log("战略等级：" .. x)
            else
                x = -1
            end
            releaseOcr(handle)
        end

        -- if x == 125 and not findOne("战略等级" .. x) then return end
        if x >= 0 and x <= 155 then
            log("识别等级成功")
            return x
        else
            log("识别等级失败")
            return false
        end
    end

    log("检测等级")
    local zl_level = zl_level_check() or -1
    log("等级：" .. zl_level .. "/" .. zl_max_level)
    if not zl_level_enough and zl_level == str2int(zl_max_level, 10000) then
        zl_level_enough = true
        captureqqimagedeliver("INFO", "肉鸽任务完成",
            table.join(qqmessage, ' ') .. " " ..
            (zl_level or '') .. "等级已满")
    end

    -- 检测源石锭
    local zl_coin_check = function()
        if not (str2int(zl_max_coin, 0) > 0) then return end
        if str2int(zl_max_coin, 0) >= 1000 then return end

        if not checkPointColor(mizuki_point.等待开始页面标题) then
            log("未找到水月常规行动")
            return false
        end

        if not wait(function()
                if not checkPointColor(mizuki_point.等待开始页面标题) then return true end
                tap(mizuki_point.战略源石锭入口)
            end) then
            return
        end

        local prex = -1
        local ans = wait(function()
            ssleep(.5)
            -- if not findOne("水月_常规行动") then return 0 end
            local x = ocr("战略源石锭") or {}
            log(4195, x)
            x = (x[1] or {}).text or ""
            x = number_ocr_correct(x)
            x = str2int(x:match("[^%d](%d+)$"), -1)
            log("4128", x)
            if x >= 0 and x == prex then return x end
            -- if x >= 0 then return x end
            prex = x
        end, 5)
        wait(function()
            tap("返回")
            if waitUntilFindColor(mizuki_point.等待开始页面标题) then return true end
        end, 5)
        if ans ~= nil and type(ans) == "number" then
            ans = ans % 1000
        end
        return ans
    end

    log("检测源石锭")
    local zl_coin = zl_coin_check() or -1
    log("源石锭：" .. zl_coin .. "/" .. zl_max_coin)
    if not zl_coin_enough and zl_coin >= str2int(zl_max_coin, 10000) then
        zl_coin_enough = true
        captureqqimagedeliver("INFO", "肉鸽任务完成",
            table.join(qqmessage, ' ') .. " " .. (zl_coin or '') ..
            "源石锭已满")
    end

    -- 等级/源石锭 阶段性通知
    log("等级/源石锭 阶段性通知")
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

    -- 放弃探索
    log("检测放弃探索")
    if checkPointColor(mizuki_point.放弃探索) then
        if not wait(function()
                if findOne("返回确认界面") then return true end
                tap("放弃本次探索")
            end, 5) then
            log(2608)
            -- 无法直接放弃的情况 不处理
            if not wait(function()
                    if not checkPointColor(mizuki_point.等待开始页面标题) then return true end
                    tap("继续探索")
                    ssleep(.5)
                    log(2613)
                end, 5) then
                return
            end

            if not wait(function()
                    if checkPointColor(mizuki_point.等待开始页面标题) then return true end
                    -- 第一次数据更新处理
                    if findAny({
                            "面板", "活动公告返回", "签到返回", "签到返回黄",
                            "开始唤醒", "bilibili_framelayout_only",
                        }) then
                        jumpout = true
                        return true
                    end
                    log("放弃探索")
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
                if not checkPointColor(mizuki_point.放弃探索) then
                    return true
                end
                -- 第一次数据更新处理
                if findAny({
                        "面板", "活动公告返回", "签到返回", "签到返回黄",
                        "开始唤醒", "bilibili_framelayout_only",
                    }) then
                    jumpout = true
                    return true
                end
            end, 30) then
            return false
        end
    end
    if jumpout then
        log("水月强制跳出1")
        return false
    end

    -- 等级满了，放弃行动后回到首页再截个图
    if zl_level_enough or zl_coin_enough then
        -- wait(function(reset_wait_start_time)
        --   if not findOne("水月_常规行动") then return true end
        --   tap("战略确认")
        -- end,5)

        captureqqimagedeliver("INFO", "肉鸽行动结束",
            table.join(qqmessage, ' ') .. " 放弃行动后")

        wait(function(reset_wait_start_time)
            if checkPointColor(mizuki_point.等待开始页面标题) then return true end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            tap("战略确认")
        end, 5)
        return false
        -- return path.fallback.签到返回()
    end

    -- 点认知塑造后继续
    -- if not lighter_enough and not zl_disable_lighter and mizuki_fight_time >= 10 then
    --     if mizuki_cognition() then
    --         return path.水月与深蓝之树前瞻投资()
    --     end
    -- end

    log("开始探索")
    if not wait(function(reset_wait_start_time)
            if findOne("战略返回") then return true end
            -- 第二次数据更新处理
            if findAny({
                    "面板", "活动公告返回", "签到返回", "签到返回黄",
                    "开始唤醒", "bilibili_framelayout_only",
                }) then
                jumpout = true
                return true
            end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            tap("战略确认")
            tap("继续探索")
        end, 20) then
        -- 初始选难度
        tap("战略难度列表" .. (zl_more_experience and "2" or "1"))
        -- 点认知塑造后继续
        if not lighter_enough and not zl_disable_lighter then
            if mizuki_cognition() then
                return path.水月与深蓝之树前瞻投资()
            end
        end
        return false
    end
    if jumpout then
        log("水月强制跳出2")
        return false
    end

    -- 选择分队
    log("选择分队")
    tapUntilCheckedPointColor(mizuki_point.指挥分队,
        mizuki_point.招募组合进度条,
        "点击近卫分队", 0.5)

    log("选择招募")
    tapUntilCheckedPointColor(mizuki_point.取长补短,
        mizuki_point.初始招募进度条,
        "点击取长补短")

    log("开始选人")
    log("不招辅助")
    if not wait(function()
            if findOne("确认招募") then return true end
            if findOne("剿灭说明") then tap("剿灭说明") end
            tap("辅助招募券")
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
            -- if findOne("水月_初始招募") then return true end
            if checkPointColor(mizuki_point.初始招募进度条) then return true end
        end, 10) then
        return false
    end

    log("招募近卫")
    if not wait(function()
            tap("近卫招募券")
            tap("招募说明关闭")
            -- if not findOne("水月_初始招募") and findOne("确认招募") then
            --     return true
            -- end
            if not checkPointColor(mizuki_point.初始招募进度条, 0.98) and findOne("确认招募") then
                return true
            end
        end, 10) then
        return false
    end

    if not waitUntilFindColor(mizuki_point.选择助战按钮) then return false end

    if not wait(function()
            if findAny({ "水月_初始招募", "战略返回" }) then
                log(26)
                return true
            end
            if findOne("返回确认界面") then
                log(27)
                -- 虽然不知道会不会走这儿
                tap("左取消")
                disappear("返回确认界面")
                -- 不等会怎么样呢，有时会闪
                ssleep(.5)
            end
            log(28, zl_best_operator)
            local idx = str2int(zl_best_operator, -1)

            if idx >= 1 and idx <= 12 then
                -- 指定
                tap("近卫招募列表" .. (zl_best_operator or 1))
                findTap("确认招募")
                tap("开包skip")
            elseif idx == -1 then
                -- 助战自动
                mizuki_help_fight()
            else
                stop("请设置近卫干员序号(1~12)", '', true, false)
            end
        end, 10) then
        return false
    end

    if not single_man_operation then
        log("招募医疗")
        if not wait(function()
                tap("医疗招募券")
                tap("招募说明关闭")
                if not checkPointColor(mizuki_point.初始招募进度条, 0.98) and findOne("确认招募") then
                    return true
                end
            end, 10) then
            return false
        end

        if not waitUntilFindColor(mizuki_point.选择助战按钮) then return false end

        if not wait(function()
                if checkPointColor(mizuki_point.偏左战略返回) then
                    log("医疗干员选完")
                    return true
                end
                if findOne("返回确认界面") then
                    log(27)
                    -- 虽然不知道会不会走这儿
                    tap("左取消")
                    disappear("返回确认界面")
                    -- 不等会怎么样呢，有时会闪
                    ssleep(.5)
                end

                -- 借用近卫坐标
                tap("近卫招募列表" .. 1)
                findTap("确认招募")
                tap("开包skip")
            end, 10) then
            return false
        end
    else
        log("不招募医疗")
        if not wait(function()
                tap("医疗招募券")
                tap("招募说明关闭")
                if not checkPointColor(mizuki_point.初始招募进度条, 0.98) and findOne("确认招募") then
                    return true
                end
            end, 10) then
            return false
        end

        if not waitUntilFindColor(mizuki_point.选择助战按钮) then return false end

        if not wait(function()
                if checkPointColor(mizuki_point.偏左战略返回) then
                    log("医疗干员选完")
                    return true
                end
                if findOne("返回确认界面") then
                    log(27)
                    -- 虽然不知道会不会走这儿
                    tap("右右确认")
                    disappear("返回确认界面")
                    -- 不等会怎么样呢，有时会闪
                    ssleep(.5)
                end

                findTap("确认招募")
                tap("开包skip")
            end, 10) then
            return false
        end
    end

    -- 选医疗干员的时候可能点太快已经进地图了
    -- todo 处理没有进地图的情况 手动再点一下

    -- 检查是否进入水月正式作战
    if not waitUntilFindColor(mizuki_point.天光海岸) then return false end

    log("进入第一关作战")
    if not wait(function()
            tap(mizuki_point.第一关)
            tap(mizuki_point.第一关)
            tap(mizuki_point.第一关)
            if waitUntilFindColor(mizuki_point.选中关卡) then return true end
        end) then
        in_fight_return = "无法进入作战"
        return mizuki_restart("无法进入作战")
    end

    local firstFight = true
    -- 第一关作战
    if not mizuki_fight(firstFight) then
        log("第一关作战出现问题")
        return flase
    end

    for i = 1, 4 do if not mizuki_start_from_select() then break end end
end

path.沙中之火 = function()
    log("生息演算沙中之火")
    if checkPointColor(sandfire_point.提示) and checkPointColor(sandfire_point.驻扎地) then
        tapUntilCheckedPointColor(sandfire_point.退出, sandfire_point.奖励, "退出当前", 0.3)
    end
    if not sandfire_navigation() then return false end
    if not sand_fire_unstop then
        if sandfir_get_reward() then return false end
    end
    sandfire_check_giveup()
    sandfire_init_fight_group()
    if not sandfir_next() then
        toast("error")
        return path.沙中之火()
    end
end

萨卡兹_分支选择 = function()
    local 第一列 = {}
    local 第二列 = {}
    local 第三列 = {}
    local 第一列选择 = 0
    local 第二列选择 = 0
    local 第三列选择 = 0
    -- 第一列关卡判断
    for i = 1, 2 do
        if findOne("萨卡兹_第一列_不期而遇_列表" .. i) then
            table.insert(第一列, "不期而遇")
        else
            table.insert(第一列, "作战")
        end
    end
    log("第1列")
    log(第一列)

    -- 第二列关卡判断
    log("第2列")
    local 第二列分支_数目 = 0
    local 第二列分支_来源上 = false
    local 第二列分支_来源下 = false
    if findOne("萨卡兹_第二列_中间分支_来源上") then
        第二列分支_来源上 = true
    end
    if findOne("萨卡兹_第二列_中间分支_来源下") then
        第二列分支_来源下 = true
    end
    log(第二列分支_来源上, 第二列分支_来源下)
    if (not 第二列分支_来源上) and (not 第二列分支_来源下) then --2列
        第二列分支_数目 = 2
        for i = 1, 2 do
            if findOne("萨卡兹_第二列_不期而遇2_列表" .. i) then
                table.insert(第二列, "不期而遇")
            else
                local ox = find_color("萨卡兹_第二列_紧急作战2_查找列表" .. i, "DADADA")
                if ox then
                    table.insert(第二列, "紧急作战")
                else
                    table.insert(第二列, "作战")
                end
            end
        end
    else
        第二列分支_数目 = 3
        for i = 1, 3 do
            if findOne("萨卡兹_第二列_不期而遇3_列表" .. i) then
                table.insert(第二列, "不期而遇")
            else
                local ox = find_color("萨卡兹_第二列_紧急作战3_查找列表" .. i, "DADADA")
                if ox then
                    table.insert(第二列, "紧急作战")
                else
                    table.insert(第二列, "作战")
                end
            end
        end
    end
    log(第二列分支_数目)
    log(第二列)

    -- 第三列关卡判断
    -- 似乎没必要 第三列基本全是不期而遇
    -- 如果是三列 就默认全部是直线 不考虑分支（懒得写了）
    -- 如果是二三都为2列 也默认全部是直线
    log("第3列")
    local 第三列分支_数目 = 2
    local po = find_color("萨卡兹_第三列_三条分支寻找范围", "FEFEFE")
    if po then
        第三列分支_数目 = 3
    end
    if 第三列分支_数目 == 3 then
        for i = 1, 3 do
            if findOne("萨卡兹_第三列_不期而遇3_列表" .. i) then
                table.insert(第三列, "不期而遇")
            else
                local ox = find_color("萨卡兹_第三列_紧急作战3_查找列表" .. i, "DADADA")
                if ox then
                    table.insert(第三列, "紧急作战")
                else
                    table.insert(第三列, "作战")
                end
            end
        end
    else
        for i = 1, 2 do
            if findOne("萨卡兹_第三列_不期而遇2_列表" .. i) then
                table.insert(第三列, "不期而遇")
            else
                local ox = find_color("萨卡兹_第三列_紧急作战2_查找列表" .. i, "DADADA")
                if ox then
                    table.insert(第三列, "紧急作战")
                else
                    table.insert(第三列, "作战")
                end
            end
        end
    end
    log(第三列分支_数目)
    log(第三列)
    local 第三列分支_32连接下 = false
    local 第三列分支_32连接上 = false
    if 第二列分支_数目 == 3 and 第三列分支_数目 == 2 then
        local po = find_color("萨卡兹_第三列_32_中间分支连接下查找范围", "FEFEFE")
        if po then
            第三列分支_32连接下 = true --找到则是连接的第三条分支的第二个
        end

        local po = find_color("萨卡兹_第三列_32_中间分支连接上查找范围", "FEFEFE")
        if po then
            第三列分支_32连接上 = true --找到则是连接的第三条分支的第二个
        end
    end
    log(第三列分支_32连接上, 第三列分支_32连接下)
    local 第三列分支_23连接下 = false
    local 第三列分支_23连接上 = false
    if 第二列分支_数目 == 2 and 第三列分支_数目 == 3 then
        local po = find_color("萨卡兹_第三列_23_中间分支连接下查找范围", "FEFEFE")
        if po then
            第三列分支_23连接下 = true --找到则是连接的第三条分支的第二个
        end

        local po = find_color("萨卡兹_第三列_23_中间分支连接上查找范围", "FEFEFE")
        if po then
            第三列分支_23连接上 = true --找到则是连接的第三条分支的第二个
        end
    end
    log(第三列分支_23连接上, 第三列分支_23连接下)

    -- 生成路线图
    local skz_map = {}
    local function checkCondition(i, j, k, branch2, branch3)
        if branch2 and branch3 then
            return { { 1, 1, 1 }, { 1, 2, 2 }, { 2, 3, 2 } }
        elseif branch2 and not branch3 then
            return { { 1, 1, 1 }, { 1, 2, 2 }, { 1, 3, 2 } }
        elseif not branch2 and branch3 then
            return { { 1, 1, 1 }, { 1, 2, 1 }, { 1, 3, 2 } }
        elseif not branch2 and not branch3 then
            return { { 1, 1, 1 }, { 2, 2, 1 }, { 1, 3, 2 } }
        end
        return {}
    end

    for i, v in ipairs(第一列) do
        for j, w in ipairs(第二列) do
            for k, x in ipairs(第三列) do
                if 第二列分支_数目 == 第三列分支_数目 then
                    if 第二列分支_数目 == 2 then
                        if i == j and j == k then
                            table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                        end
                    else
                        if 第二列分支_来源上 then
                            if i == 1 and j == k and (j == 1 or 2) then
                                table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                            end
                            if i == 2 and j == 3 and k == 3 then
                                table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                            end
                        end
                        if 第二列分支_来源下 then
                            if i == 2 and j == k and (j == 2 or 3) then
                                table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                            end
                            if i == 1 and j == 1 and k == 1 then
                                table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                            end
                        end
                    end
                else
                    if 第二列分支_数目 == 2 and 第三列分支_数目 == 3 then
                        local 条件组合 = {
                            { 第三列分支_23连接下, { { 1, 1, 1 }, { 2, 2, 2 }, { 2, 2, 3 } } },
                            { 第三列分支_23连接上, { { 1, 1, 1 }, { 1, 1, 2 }, { 2, 2, 3 } } }
                        }
                        -- 遍历每个条件组合并插入数据到 skz_map
                        for _, 条件 in ipairs(条件组合) do
                            local 第三列条件, 值组合 = table.unpack(条件)
                            if 第三列条件 then
                                for _, 值 in ipairs(值组合) do
                                    local a, b, c = table.unpack(值)
                                    if i == a and j == b and k == c then
                                        table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                                    end
                                end
                            end
                        end
                    else
                        -- 相反就是 第二列 3 第三列 2
                        local 条件组合 = {
                            { 第三列分支_32连接下, 第二列分支_来源上, { { 1, 1, 1 }, { 1, 2, 2 }, { 2, 3, 2 } } },
                            { 第三列分支_32连接下, 第二列分支_来源下, { { 1, 1, 1 }, { 2, 2, 2 }, { 2, 3, 2 } } },
                            { 第三列分支_32连接上, 第二列分支_来源上, { { 1, 1, 1 }, { 1, 2, 1 }, { 2, 3, 2 } } },
                            { 第三列分支_32连接上, 第二列分支_来源下, { { 1, 1, 1 }, { 2, 2, 1 }, { 2, 3, 2 } } }
                        }
                        -- 遍历每个条件组合并插入数据到 skz_map
                        for _, 条件 in ipairs(条件组合) do
                            local 第三列条件, 第二列条件, 值组合 = table.unpack(条件)
                            if 第三列条件 then
                                if 第二列条件 then
                                    for _, 值 in ipairs(值组合) do
                                        local a, b, c = table.unpack(值)
                                        if i == a and j == b and k == c then
                                            table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    log(skz_map)

    local function find_best_route(routes)
        local best_score = 50
        local best_route = nil
        for _, route in ipairs(routes) do
            local score = 0
            for rx, segment in ipairs(route) do
                if segment[2] == "紧急作战" then
                    score = score + 8
                elseif segment[2] == "不期而遇" then
                    if rx == 1 then
                        -- score = score + 1
                        -- 在第一列优先
                    else
                        score = score + 2
                    end
                elseif segment[2] == "作战" then
                    if rx == 1 then
                        score = score + 1
                    end
                    score = score + 3
                end
            end
            log(score, route)
            if score < best_score then
                best_score = score
                best_route = route
            end
        end
        log(best_score, route)
        return best_route
    end
    local best_route = find_best_route(skz_map)
    if not best_route then
        log("没有满足条件的路线")
        -- best_route = skz_map[1]
        best_route = { { 1, 第一列[1] }, { 1, 第二列[1] }, { 1, 第三列[1] } }
    end
    log(best_route)
    best_route[1][3] = 2
    best_route[2][3] = 第二列分支_数目
    best_route[3][3] = 第三列分支_数目
    return best_route
end


path.萨卡兹的无终奇语前瞻投资 = function()
    if zl_blueprint then
        萨卡兹_蓝图分队()
        return
    end
    log('start skz')
    if findOne("萨卡兹_戛然而止") then
        log('萨卡兹_戛然而止')
        wait(function()
            if findAny({ "萨卡兹_常规行动", "面板" }) then return true end
            tap("新战略确认")
        end, 15)
        return
    end

    -- 肉鸽每8小时做日常
    zl_eight_daily()

    local in_fight_return = ''
    local restart = function()
        toast(in_fight_return or '重开')
        ssleep(3)
        if not request_memory_clean() then
            path.萨卡兹的无终奇语前瞻投资(true)
        else
            path.跳转("首页")
        end
    end

    --判断是否在其他界面
    local jumpout
    if findOne("战略返回") then path.fallback.战略返回() end
    if findOne("暂停中") and findOne("生命值") then restartapp(appid) end

    -- 先导航到常规行动
    zl_navigation('萨卡兹_常规行动', '萨卡兹的无终奇语进入主题')

    --肉鸽 等级源石锭检查
    萨卡兹肉鸽完成 = zl_level_coin_inquire('萨卡兹_常规行动', '萨卡兹_等级检测范围', '萨卡兹_源石锭检测范围')
    if 萨卡兹肉鸽完成 then
        return
    end

    -- 放弃探索
    if findOne("萨卡兹_放弃本次探索") then
        if not wait(function()
                if findOne("返回确认界面") then return true end
                tap("萨卡兹_放弃本次探索")
            end, 5) then
            log(2608)
            -- 无法直接放弃的情况 不处理
            if not wait(function()
                    if not findOne("萨卡兹_常规行动") then return true end
                    tap("萨卡兹_继续探索")
                    ssleep(.5)
                    log(2613)
                end, 5) then
                return
            end

            if not wait(function()
                    if findOne("萨卡兹_常规行动") then return true end
                    -- 第一次数据更新处理
                    if findAny({
                            "面板", "活动公告返回", "签到返回", "签到返回黄",
                            "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
                        }) then
                        jumpout = true
                        return true
                    end
                    tap("新战略确认")
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
                tap("新战略确认")
                if findOne("萨卡兹_常规行动") and not findOne("萨卡兹_放弃探索") then
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
    if jumpout then return end

    local t = time()
    if not wait(function(reset_wait_start_time)
            if findOne("战略返回") then return true end
            -- 第二次数据更新处理
            if findAny({
                    "面板", "活动公告返回", "签到返回", "签到返回黄",
                    "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
                }) then
                jumpout = true
                return true
            end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
            tap("新战略确认")
            tap("继续探索")
            if time() - t > 2 * 1000 then --第一次时候，需要选择难度等级
                ssleep(1)
                t = time()
                log('选择一次难度等级')
                tap({ scale(1759), scale(567) })
            end
        end, 15) then
        -- 初始选难度
        tap('萨米_难度选择确认')

        return
    end
    if jumpout then return end

    -- 开始探索 一路按到 招募干员
    -- local first_time_see_first_card = 0

    if not wait(function(reset_wait_start_time)
            if findOne("萨卡兹_初始招募") then return true end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
            tap("新战略确认")
            tap("新战略确认")
            tap("新战略确认")
        end, 10) then
        return
    end

    if not wait(function(reset_wait_start_time)
            if findOne("萨卡兹_初始招募") then return true end
            tap("萨卡兹_近卫招募券")
        end, 10) then
        return
    end

    log('招募近卫')
    if not wait(function()
            tap("近卫招募券")
            tap("招募说明关闭")
            if not findOne("萨卡兹_初始招募") and findOne("确认招募") then
                return true
            end
        end, 10) then
        return
    end

    if not wait(function()
            if findAny({ "萨卡兹_初始招募", "战略返回" }) then
                log(26)
                return true
            end
            if findOne("返回确认界面") then
                log(27)
                -- 虽然不知道会不会走这儿
                tap("左取消")
                disappear("返回确认界面")
                -- 不等会怎么样呢，有时会闪
                ssleep(.5)
            end
            log(28, zl_best_operator)
            local idx = str2int(zl_best_operator, -1)

            if idx >= 1 and idx <= 12 then
                -- 指定
                tap("近卫招募列表" .. (zl_best_operator or 1))
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

    -- 第2人
    log('招募辅助')
    if not wait(function()
            tap("萨卡兹_辅助招募券")
            tap("招募说明关闭")
            if findOne("确认招募") then return true end
        end, 10) then
        return
    end
    appear('战略助战')
    if not wait(function()
            if findOne("萨卡兹_希望源石锭界面") then
                -- if findAny({ "", "战略返回" }) then
                log(26)
                return true
            end
            if findOne("返回确认界面") then
                log(27)
                -- 虽然不知道会不会走这儿
                tap("左取消")
                disappear("返回确认界面")
                -- 不等会怎么样呢，有时会闪
                ssleep(.5)
            end
            tap("近卫招募列表" .. 1)
            findTap("确认招募")
            tap("开包skip")
        end, 10) then
        return
    end

    --ssleep(1)
    -- 第3人
    log('招募医疗')
    if not wait(function()
            tap("萨卡兹_医疗招募券")
            tap("招募说明关闭")
            if findOne("确认招募") then return true end
        end, 10) then
        return
    end
    appear('战略助战')
    if not wait(function()
            if findOne("萨卡兹_希望源石锭界面") then
                --if findAny({ "萨米_初始招募", "战略返回" }) then
                log(26)
                return true
            end
            if findOne("返回确认界面") then
                log(27)
                -- 虽然不知道会不会走这儿
                tap("左取消")
                disappear("返回确认界面")
                -- 不等会怎么样呢，有时会闪
                ssleep(.5)
            end
            tap("近卫招募列表" .. 1)
            findTap("确认招募")
            tap("开包skip")
        end, 10) then
        return
    end


    if not appear("萨卡兹_初始招募") then return end
    log(2698)
    -- 进入探索 必须分为两段，否则产生位移
    if not wait(function()
            if not findOne("萨卡兹_初始招募") then return true end
            tap("萨卡兹_进入探索")
        end, 5) then
        return
    end

    log(2700)
    --点击进入探索之后，有一段时间的加载界面，需要点击
    local xtime = time()
    if not wait(function()
            if findOne("战略返回") then return true end
            tap("战略确认")
            --第一次会弹出‘战略帮助’那个界面
            if time() - xtime > 3 * 1000 then
                xtime = time()
                tap("招募说明关闭")
            end
        end, 15) then
        return
    end
    ssleep(0.5) -- 右边第三列有概率加载过慢
    -- 分支选择 返回每一列行数
    萨卡兹路线 = 萨卡兹_分支选择()
    log("路线选择", 萨卡兹路线)
    -- if debug_mode then
    --     ssleep(5)
    -- end
    --延迟一会，否则会产生位移，可以拿来后续做线路优化的筛选
    --目前默认选择上面的线路
    ssleep(1)
    findTap("萨卡兹_待编入负荷干员")
    local t = time()
    if not wait(function()
            findTap("萨卡兹_点击负荷干员")
            if time() - t > 1500 then
                t = time()
                tap('招募说明关闭') --第一次加载会有这个弹窗
            end
            if findOne('萨卡兹_等待负荷干员列表出现') then return true end
        end, 10, .3) then
        return false
    end
    ssleep(1)
    for i = 1, #point['萨卡兹_选项负荷干员列表'] do
        tap('萨卡兹_选项负荷干员列表' .. i)
        ssleep(.1)
    end
    tap("萨卡兹_等待负荷干员列表出现")
    disappear('萨卡兹_等待负荷干员列表出现')
    ssleep(.5)
    tap("萨卡兹_收起负荷干员")
    ::fight_first::
    log("准备进入第一关作战")
    ssleep(.5)
    if not 萨卡兹路线[1] then return end --有时候值为空会出错
    local 第一列 = 萨卡兹路线[1][1]
    table.remove(萨卡兹路线, 1)
    if not wait(function()
            -- tap("萨卡兹_第一次作战上")
            tap("萨卡兹_第一列_作战列表" .. 第一列)
            if findOne('萨卡兹_第一次作战被点击') then return true end
        end, 5) then
        -- in_fight_return = "无法进入第一关"
        zl_repos_path('萨卡兹_放弃本次探索')
        goto fight_first
    end

    --检查作战关卡名字
    if not zl_fight_name_ocr() then return end
    toast(now_fight_name)
    ssleep(1)
    if not wait(function()
            if findOne("快捷编队") then return true end
            tap("萨卡兹_进入")
        end, 5) then
        zl_repos_path('萨卡兹_放弃本次探索')
        goto fight_first
    end

    if not wait(function()
            if findOne("确认招募") then return true end
            tap("快捷编队")
        end, 10) then
        return
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
        return
    end

    if not wait(function()
            if not findOne("确认招募") then return true end
            tap("确认招募")
        end, 10) then
        return
    end

    if not appear("快捷编队") then return end


    ::fight_trusteeship::
    -- 开始游戏
    if not wait(function()
            tap("确认招募")
            if not findOne("快捷编队") then return true end
            -- 出现过在这儿卡死的
            if not disappear("正在提交反馈至神经", network_timeout) then
                restartapp(appid)
                return true
            end
        end, 10) then
        return
    end
    log(3306)
    -- 等待加载游戏界面
    if not wait(function()
            if findOne("单选确认框") then return true end
            if findOne("生命值") then return true end
        end, 60) then
        return
    end

    if not findOne("生命值") then return end

    -- 需要等等才能点两倍速
    appearTap("两倍速", 3)

    -- 部署干员到关卡位置
    zl_deploy(point.萨卡兹_作战关卡[now_fight_name])

    appear("生命值")

    local last_time_see_life = time()
    local skill_times = 0
    if not wait(function()
            --
            -- toast('当前等级：' .. zl_level, 0, scale(1080))
            if findOne("返回确认界面") then tap("左取消") end
            if findOne("暂停中") then
                tap("开包skip")
                disappear("暂停中")
            end
            if findOne("生命值") then last_time_see_life = time() end
            -- 超过3秒没看到生命值
            if time() - last_time_see_life > 5000 then
                tap("战略确认")
                return true
            end

            tap("开始行动1")
            local p = findOne("技能亮")
            local jump = false
            if p and skill_times < zl_skill_times then
                skill_times = skill_times + 1
                tap({ p[1], p[2] + scale(200) })
                --把【appear("生命值蓝", 5)】改成下面的，有时候打完会停顿一会，下面加快判断
                wait(function()
                    if findOne("萨卡兹_成功通过") then
                        log('成功通过')
                        jump = true
                        return true
                    end
                    if findOne("生命值蓝") then return true end
                end, 5)
                if jump then return true end

                ssleep(0.5)
                wait(function()
                    tap("开技能")
                    if disappear("生命值蓝", 1) then return true end
                end)
                ssleep(1)
            end
        end, 300) then
        return restartapp(appid)
    end

    appear({ "战略返回", "萨卡兹_联系中断", '萨卡兹_戛然而止' }, 30)
    if findOne("萨卡兹_戛然而止") then
        log('戛然而止界面，准备返回')
        return
    end
    if findOne("萨卡兹_联系中断") then
        log('重启')
        restartapp(appid)
        return
    end
    if not findOne("战略返回") then return end

    if not zl_fight_after_skz() then
        log("未能完成战斗后拾取")
        return false
    end
    log("完成一次战斗")

    ::fight_select::
    log('在选择节点界面')
    log(萨卡兹路线)
    if next(萨卡兹路线) == nil then
        -- local idxs = -1
        -- local idxs, maxIndex = zl_selection_node()
        -- --如果maxIndex是1 2 则是战斗关卡   3 4 是不期而遇
        -- if idxs > 0 then
        --     log(idxs, maxIndex)
        --     tap(point.萨卡兹关卡节点坐标[idxs])
        --     ssleep(.5)
        -- end

        -- 最后为商店
        sx = { scale(1761), scale(846) }
        oricol = getColor(sx[1], sx[2])
        if not wait(function()
                if findOne("萨卡兹_商店进入") then
                    return true
                end
                tap("萨卡兹_地图商店坐标")
            end, 5) then
            return
        end
        ssleep(.5)
        maxIndex = 5
    else
        sx = { scale(1761), scale(846) }
        oricol = getColor(sx[1], sx[2])
        log("每列节点", 萨卡兹路线[1][3])
        log(萨卡兹路线)
        if not wait(function()
                if getColor(sx[1], sx[2]) ~= oricol then
                    return true
                end
                tap("萨卡兹_" .. 萨卡兹路线[1][3] .. "节点_作战列表" .. 萨卡兹路线[1][1])
            end, 5, .2) then
            return
        end
        if 萨卡兹路线[1][2] == "不期而遇" then
            maxIndex = 4
        else
            maxIndex = 1
        end
        table.remove(萨卡兹路线, 1)
        ssleep(.5)
    end

    if maxIndex <= 3 then
        --进入战斗
        --检测作战关卡名字
        zl_fight_name_ocr()

        log("进入战斗")
        if not wait(function()
                if findOne("快捷编队") then return true end
                tap("萨卡兹_进入")
            end, 10) then
            return
        end
        goto fight_trusteeship
    elseif maxIndex == 4 then
        --进入不期而遇
        log("进入不期而遇")
        appear('萨卡兹_不期而遇节点出现')
        wait(function()
            tap("萨卡兹_进入")
            tap("萨卡兹_思维混乱确认红") --偶尔有情况 思维负载太多了，第一第二个节点都是作战时候，第三个节点有概率出现
        end, 2)
        if not wait(function()
                if not findOne("萨米_战略帮助") then return true end
                tap("战略确认")
            end, 15) then
            toast('进入不期而遇出错,可能误点到了什么')
            return restartapp(appid)
        end

        --判断不期而遇事件，并处理
        log('处理不期而遇事件')
        if not wait(function()
                local x = function()
                    local incident
                    local t = time()
                    if not wait(function()
                            incident = ocr("萨卡兹_不期而遇事件名字检测")
                            if time() - t > 1000 then --不期而遇事件，偶尔下面的 '√' 会一直存在，间隔点击一次
                                t = time()
                                if not findOne('萨米_希望源石锭界面') then
                                    tap({ scale(960), scale(935) }) --更上面一点，防止误触
                                end
                            end
                            if incident[1] then return true end
                            if findOne("萨卡兹_战略帮助") then return true end
                        end, 8) then
                        return false
                    end
                    if not incident[1] then return false end
                    local str = incident[1].text
                    log('事件名字：', str)
                    if findOne('萨卡兹_不期而遇确认') then tap("萨卡兹_不期而遇确认点击") end
                    if string.finds(str, { "虫" }) then
                        if zl_event_solve(3, "萨卡兹_战略帮助") then return true end
                    elseif string.finds(str, { '解', '故事', '高空', '不散' }) then
                        if zl_event_solve(2, "萨卡兹_战略帮助") then return true end
                    elseif string.finds(str, { '相遇', "萨米", "维", "女士" }) then
                        if zl_event_solve(1, "萨卡兹_战略帮助") then return true end
                    end
                end
                if x() then return true end
                if findOne("萨卡兹_战略帮助") then return true end
            end, 30) then
            return false
        end

        -- 检查是否点到思维界面
        ssleep(0.5)
        if findOne("萨卡兹_思维界面") then tap("萨卡兹_思维返回") end
        if not wait(function()
                if findOne("战略返回") then return true end
                if findOne("萨卡兹_思维界面") then tap("萨卡兹_思维返回") end
            end, 3) then
        end

        goto fight_select
    end

    -- 商店

    local goto_next_level = function()
        wait(function()
            if not findOne("战略返回") then return true end
            tap("诡意行商离开")
        end, 10)
        wait(function()
            if findOne("战略返回") then return true end
            tap("诡意行商离开")
        end, 10)
        appear('战略返回')
        findTap('战略返回')
    end

    if not wait(function()
            -- if not findOne("战略帮助") then return true end
            if findAny({ "诡意行商投资", "诡意行商离开" }) then return true end
            tap("萨卡兹_商店进入")
            tap("萨卡兹_思维混乱确认红") --偶尔有情况 思维负载太多了，第一第二个节点都是作战时候，第三个节点有概率出现
        end, 3) then
        return zl_repos_path('萨卡兹_放弃本次探索')
    end

    --check_goods()

    --投币

    if not zl_skip_coin then zl_shop_coin() end
    if zl_only_coin then
        log('只是投币，准备退出')
        findTap('战略退出')
        appear('萨卡兹_放弃本次探索', 3)
        return true
    end
    --购买商品
    if not wait(function()
            if findOne("诡意行商离开") then return true end
            tap("开包skip")
        end, 5) then
        return
    end
    for i = 1, 10 do if not zl_shop_buy() then break end end

    return goto_next_level()
end

path.生息演算沙中之火 = never_end_wrapper(path.沙中之火)

path.水月与深蓝之树 = never_end_wrapper(path.水月与深蓝之树前瞻投资)

path.萨卡兹的无终奇语 = never_end_wrapper(path.萨卡兹的无终奇语前瞻投资)
