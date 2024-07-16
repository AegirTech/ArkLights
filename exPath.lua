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


path.萨卡兹的无终奇语前瞻投资 = function()
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
            path.萨米测试(true)
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
    --zl_level_coin_inquire()

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
                --ssleep(1)
                t = time()
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

    --延迟一会，否则会产生位移，可以拿来后续做线路优化的筛选
    --目前默认选择上面的线路
    ssleep(1)
    findTap("萨卡兹_待编入负荷干员")
    disappear('萨卡兹_待编入负荷干员')
    appear('萨卡兹_点击负荷干员')
    findTap('萨卡兹_点击负荷干员')
    ssleep(.5)
    appear('萨卡兹_等待负荷干员列表出现')
    -- ssleep(1)
    --编入负荷干员
    if not findOne("萨卡兹_等待负荷干员列表出现") then return true end
    for _, v in ipairs(point['萨卡兹_选项负荷干员']) do
        tap(v)
        ssleep(.1)
    end
    tap("萨卡兹_等待负荷干员列表出现")
    disappear('萨卡兹_等待负荷干员列表出现')
    ssleep(.5)
    tap("萨卡兹_收起负荷干员")

    ::fight_first::
    log("准备进入第一关作战")
    ssleep(.5)
    if not wait(function()
            tap("萨卡兹_第一次作战上")
            if findOne('萨卡兹_第一次作战被点击') then return true end
        end, 5) then
        -- in_fight_return = "无法进入第一关"
        zl_repos_path('萨卡兹_放弃本次探索')
        goto fight_first
    end

    --检查作战关卡名字
    if not skz_fight_name() then return end

    log('1313:' .. now_fight_name)
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
    -- 等待加载游戏界面,然后判断该地图是什么名字
    --log('准备识别关卡')
    -- if not wait(function()
    --         for _, v in ipairs(point.萨卡兹作战关卡寻找) do
    --             local color = v[2]
    --             if cmpColorEx(color, 0.9) == 1 then
    --                 now_fight_name = v[1]
    --                 log('找到地图了，地图名字是：' .. v[1])
    --                 return true
    --             end
    --         end
    --     end, 15, .2) then
    --     log('未知的关卡')
    --     return restartapp(appid)
    -- end

    -- 需要等等才能点两倍速
    appearTap("两倍速", 3)

    -- 部署干员到关卡位置
    zl_deploy(point.萨卡兹作战关卡[now_fight_name])

    appear("生命值")

    local last_time_see_life = time()
    local skill_times = 0
    local zl_level = zl_level or -1
    if not wait(function()
            toast('当前等级：' .. zl_level, 0, scale(1080))
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
            if p and skill_times < zl_skill_times then
                skill_times = skill_times + 1
                tap({ p[1], p[2] + scale(200) })
                -- appear("技能ready", 5)
                appear("生命值蓝", 5)
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

    appear({ "战略返回", "萨卡兹_联系中断" }, 30)
    if findOne("萨卡兹_联系中断") then
        log('重启')
        restartapp(appid)
        return
    end
    if not findOne("战略返回") then return end

    if not skz_after_fight() then
        log("未能完成战斗后拾取")
        return false
    end
    log("完成一次战斗")

    ::fight_select::
    log('在选择节点界面')
    local idxs = -1
    local idxs, maxIndex = zl_selection_node()
    --如果maxIndex是1 2 则是战斗关卡   3 4 是不期而遇
    if idxs > 0 then
        log(idxs, maxIndex)
        tap(point.萨卡兹关卡节点坐标[idxs])
        ssleep(.5)
    end

    if maxIndex == 1 or maxIndex == 2 then
        --进入战斗
        --检测作战关卡名字
        skz_fight_name()

        log("进入战斗")
        if not wait(function()
                if findOne("快捷编队") then return true end
                tap("萨卡兹_进入")
            end, 10) then
            return
        end
        goto fight_trusteeship
    elseif maxIndex == 3 or maxIndex == 4 then
        --进入不期而遇
        log("进入不期而遇")
        appear('萨卡兹_不期而遇节点出现')
        wait(function()
            tap("萨卡兹_进入")
        end, 2)
        if not wait(function()
                if not findOne("萨米_战略帮助") then return true end
                tap("战略确认")
            end, 10) then
            --return
        end

        --判断不期而遇事件，并处理
        log('处理不期而遇事件')
        if not wait(function()
                local x = function()
                    local incident
                    local t = time()
                    if not wait(function()
                            incident = ocr("萨卡兹_不期而遇事件名字检测")
                            -- if time() - t > 1500 then
                            --     t = time()
                            --     if not findOne('萨米_希望源石锭界面') then tap("战略确认") end
                            --     return
                            -- end
                            if incident[1] then return true end
                            if findOne("萨卡兹_战略帮助") then return true end
                        end, 8) then
                        return false
                    end
                    if not incident[1] then return false end
                    local str = incident[1].text
                    log('事件名字：', str)
                    if string.finds(str, { "虫" }) then
                        if zl_event_solve(3, "萨卡兹_战略帮助") then return true end
                    elseif string.finds(str, { '相遇', '解', '故事', '高空' }) then
                        if zl_event_solve(2, "萨卡兹_战略帮助") then return true end
                    elseif string.finds(x, { "萨米", "维", "女士" }) then
                        if zl_event_solve(1, "萨卡兹_战略帮助") then return true end
                    end
                end
                if x() then return true end
                if findOne("萨卡兹_战略帮助") then return true end
            end, 30) then
            return false
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
        end, 3) then
        return zl_repos_path('萨卡兹_放弃本次探索')
    end

    --check_goods()

    --投币

    if not zl_skip_coin then zl_shop_coin() end

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
