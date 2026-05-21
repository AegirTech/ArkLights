-- ===========================================
--               生息演算
--               沙洲遗闻
-- ===========================================
reachFourthDay = false
Tales_within_the_sand = {}

沙洲遗闻 = function()
    log("沙洲遗闻开始")
    if findOne("主页长期探索_生息演算") then
        tap("主页长期探索_生息演算", 0.1)
    end
    if findOne("生息底栏烹饪按钮") then
        log("检测到在游戏内")
        tap("生息演算左上角返回")
        if findOne("生息底栏烹饪按钮") then
            tap("生息演算_全局_返回")
        end
        appear("生息演算主页进入")
    end
    if not findOne("生息演算主页进入") then
        log.warn("未找到主页，从头开始")
        Tales_within_the_sand.生息跳转()
    end
    if not findOne("生息演算未结算_反") then
        log.warn("存在未结算")
        tap("生息演算主页进入")
        if reachFourthDay or sand_mode == 0 then
            reachFourthDay = true
            Tales_within_the_sand.回到三天前存档()
        else
            Tales_within_the_sand.删除存档()
        end
    end
    Tales_within_the_sand.掉线状态判断()
    if Tales_within_the_sand.检查代币数量() then
        return true
    end
    if not request_memory_clean() then
        Tales_within_the_sand.开始演算(sand_mode)
    else
        path.跳转("首页")
    end
end

Tales_within_the_sand.生息跳转 = function()
    -- tap("面板作战")
    -- appear("生息演算_主页导航", 5)
    -- if not findOne("生息演算_主页导航") then
    --     -- 游戏内卡死则直接重启游戏
    --     captureqqimagedeliver("INFO", "即将重启游戏", "导航失败，重启游戏", true)
    --     restartapp(appid)
    -- end
    -- if not wait(function()
    --         if findOne("生息演算_公告弹窗") then
    --             tap("生息演算_公告弹窗关闭")
    --         end
    --         if findAny({ "生息演算_主页导航", "生息演算_游戏主页", "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
    --                 "手机验证码登录", "生息演算_游戏设置页面", "生息演算_游戏设置弹窗", "主页长期探索", "主页长期探索_生息演算", "生息演算主页进入" }) then
    --             return true
    --         end
    --     end, 60) then
    --     restartapp(appid)
    --     captureqqimagedeliver("INFO", "即将重启游戏", "导航失败", true)
    -- end
    path.跳转("首页")
    -- Tales_within_the_sand.掉线状态判断()
    tap("面板作战")
    if not wait(function()
            appearTap("主页长期探索", 0.2)
            appearTap("主页长期探索_生息演算_全部主题", 0.2)
            if appear("主页长期探索_生息演算_进入主题") then
                tap("主页长期探索_生息演算_沙洲遗闻")
            end
            appearTap("主页长期探索_生息演算_进入主题", 0.2)
            if findOne("生息演算主页进入") then return true end
        end, 10) then
        log(55)
        path.跳过剧情()
    end
    if findOne("生息演算主页进入") then return true end
end

Tales_within_the_sand.切换难度 = function(sand_mode)
    if sand_mode >= 2 then
        log("切换休养")
        if findOne("沙洲遗闻休养模式") then return true end
        if findOne("生息演算主页进入") then
            tap("沙洲遗闻挑战模式")
            appearTap("沙洲遗闻切换休养", 2)
            appear("生息演算主页进入", 1)
        end
        return
    end
    if findOne("沙洲遗闻标准模式") then return true end
    if findOne("生息演算主页进入") then
        tap("沙洲遗闻挑战模式")
        appearTap("沙洲遗闻切换选择", 2)
        appear("生息演算主页进入", 1)
    end
end

Tales_within_the_sand.重置地图位置 = function(skip)
    log("重置地图位置")
    tap("生息演算左上角返回")
    ssleep(.1)
    if not wait(function()
            if findOne("生息演算主页进入") then
                return true
            end
            if findOne("沙洲遗闻换季教程") then
                tap("生息演算进入下一天")
            end
            tap("生息演算左上角返回")
            ssleep(.1)
        end, 5) then
    end
    if not skip and Tales_within_the_sand.检查代币数量() then
        return true
    end
    if not findOne("生息演算主页进入") then
        Tales_within_the_sand.生息跳转() -- 可能存在模拟器卡顿导致多返回一次页面
    end
    if not wait(function()
            if findOne("生息底栏烹饪按钮") then return true end
            if findOne("沙洲遗闻开启今日") then
                if not wait(function()
                        tap("沙洲遗闻开启今日")
                        if not findOne("沙洲遗闻开启今日") then return true end
                    end, 7) then
                end
                ssleep(.1)
            end
            tap("生息演算主页进入")
            ssleep(0.3)
        end, 10) then
        return
    end
    log("重置地图位置结束")
end

Tales_within_the_sand.开始演算 = function(sand_mode)
    log("开始演算")
    if findOne("生息演算主页进入") then
        Tales_within_the_sand.切换难度(sand_mode)
        tap("生息演算主页进入")
    end
    if not reachFourthDay then
        -- 剧情部分
        Tales_within_the_sand.会聚之地()
        appear("生息底栏烹饪按钮", 3)
        Tales_within_the_sand.掉线状态判断()
        Tales_within_the_sand.掉线状态判断()

        if not appear("生息底栏烹饪按钮", 10) then
            return 沙洲遗闻()
        end

        Tales_within_the_sand.重置地图位置()
        if sand_mode >= 2 then
            --休养模式
            Tales_within_the_sand.生息关卡进入("沙洲遗闻聚羽之地")
            Tales_within_the_sand.下一天()
            Tales_within_the_sand.生息关卡进入("沙洲遗闻林中寻宝2")
            ssleep(.5)
            Tales_within_the_sand.生息演算奇遇("沙洲遗闻奇遇砾沙平原")
            ssleep(.5)
            Tales_within_the_sand.生息关卡进入("沙洲遗闻射程以内")
            Tales_within_the_sand.下一天()
            --第四天
            Tales_within_the_sand.下一天()
            Tales_within_the_sand.生息关卡进入("沙洲遗闻饮水为饵", true)
            Tales_within_the_sand.下一天()
            Tales_within_the_sand.下一天()
            -- 第七天
            Tales_within_the_sand.下一天()
            Tales_within_the_sand.下一天()
            Tales_within_the_sand.下一天()
            -- 第十天
            Tales_within_the_sand.重置地图位置(true)
            tap("沙洲遗闻林中寻宝3")
            appear("生息演算开始行动", 2)
            ssleep(.2)
            Tales_within_the_sand.生息关卡进入("沙洲遗闻原始奔腾2")
            Tales_within_the_sand.下一天()
            Tales_within_the_sand.下一天()
            Tales_within_the_sand.生息关卡进入("沙洲遗闻树林之主")
            Tales_within_the_sand.下一天()
        else
            --标准模式
            Tales_within_the_sand.生息关卡进入("沙洲遗闻丰饶灌木林")

            if not appear("生息底栏烹饪按钮", 10) then
                return 沙洲遗闻()
            end
            Tales_within_the_sand.下一天()
            Tales_within_the_sand.下一天()
            Tales_within_the_sand.掉线状态判断()

            Tales_within_the_sand.敌袭1()
            Tales_within_the_sand.下一天()
        end
        reachFourthDay = true
    end
    if sand_mode >= 2 then
        Tales_within_the_sand.六天奇遇循环()
        Tales_within_the_sand.下一天()
        Tales_within_the_sand.下一天()
        Tales_within_the_sand.下一天()
        Tales_within_the_sand.连续跳过()
    else
        return Tales_within_the_sand.四到七天()
    end
end

Tales_within_the_sand.掉线状态判断 = function()
    log("生息掉线检测")

    if findOne("沙洲遗闻基地产出") then
        if not wait(function()
                if findOne("生息底栏烹饪按钮") then return true end
                tap("生息演算下一天_勾")
            end, 5) then
        end
        return true
    end
    if findOne("生息演算_其他界面1") then
        return 沙洲遗闻()
    end
    if findOne("主页长期探索_生息演算_沙洲遗闻") then
        tap("主页长期探索_生息演算_沙洲遗闻")
        ssleep(1)
        tap("主页长期探索_生息演算_进入主题")
        return 沙洲遗闻()
    end

    if not reachFourthDay and findAny({ "生息演算会聚之地判断", }) then
        return Tales_within_the_sand.会聚之地()
    end
    if findOne("生息演算关卡左上角退出") then
        -- 不清楚某些情况会没结束的
        if not wait(function()
                if findOne("生息底栏烹饪按钮") then
                    return true
                end
                appearTap("生息演算关卡左上角退出", 0.1)
                tap("生息演算_确认按钮")
            end, 20) then
        end
        return 沙洲遗闻()
    end
    if findOne("生息演算开始行动") then
        tap("生息演算_全局_返回")
        return 沙洲遗闻()
    end
    if findAny({
            "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
            "手机验证码登录", "生息演算_游戏设置页面", "生息演算_游戏设置弹窗",
        }) then
        path.跳转("首页")
        return 沙洲遗闻()
    end
    --[[if not findAny({ "生息演算主页进入", "生息底栏烹饪按钮", "沙洲遗闻开启今日", }) then
        -- 未知页面
        --snapShot("/mnt/sdcard/test.png")
        restartapp(appid)
        path.跳转("首页")
        return 沙洲遗闻()
    end]]
end

Tales_within_the_sand.删除存档 = function()
    log("删除存档")
    Tales_within_the_sand.掉线状态判断()
    if not findOne("生息底栏烹饪按钮") then
        tap("生息演算主页进入")
    end
    appear("生息底栏烹饪按钮", 3)
    if not appear("生息底栏烹饪按钮", 10) then
        return 沙洲遗闻()
    end
    if not wait(function()
            if not appear("生息底栏弹出页面", 0.1) then
                tap("生息底栏更多按钮")
            end
            tap("生息底栏更多_删除存档2")
            tap("生息底栏更多_删除存档")
            appearTap("生息演算确认删除存档", 0.1)
            if appear("生息演算主页进入", 0.5) then return true end
        end, 5) then
        Tales_within_the_sand.删除存档()
    end
end

Tales_within_the_sand.四到七天 = function()
    log("四到七天")
    while true do
        if Tales_within_the_sand.重置地图位置() then
            reachFourthDay = false
            return false
        end
        Tales_within_the_sand.生息关卡进入("沙洲遗闻聚羽之地")
        Tales_within_the_sand.生息关卡进入("沙洲遗闻直奔深渊")
        Tales_within_the_sand.下一天()
        Tales_within_the_sand.生息关卡进入("沙洲遗闻参差林木")
        Tales_within_the_sand.生息关卡进入("沙洲遗闻原始奔腾")
        Tales_within_the_sand.下一天()
        Tales_within_the_sand.生息关卡进入("沙洲遗闻林中寻宝")
        Tales_within_the_sand.生息演算奇遇("沙洲遗闻奇遇砾沙平原")
        Tales_within_the_sand.回到三天前存档()
    end
end

Tales_within_the_sand.回到三天前存档 = function()
    log("回档")
    Tales_within_the_sand.掉线状态判断()
    if not findOne("生息底栏烹饪按钮") then
        tap("生息演算主页进入")
    end
    if not appear("生息底栏烹饪按钮", 10) then
        if findOne("沙洲遗闻开启今日") then
            if not wait(function()
                    if not findOne("沙洲遗闻开启今日") then return true end
                    tap("沙洲遗闻开启今日")
                    ssleep(.1)
                end, 7) then
            end
            return 沙洲遗闻()
        else
            return 沙洲遗闻()
        end
    end
    if not wait(function()
            if not findOne("生息底栏弹出页面") then
                tap("生息底栏更多按钮")
            end
            -- 天数过高位置不一样
            local xp = find_color("生息底栏更多_读取存档查找范围", "B1B056", 1, 0.95)
            if xp then
                tap(xp)
            end
            -- if findOne("生息底栏弹出页面") then tap("生息底栏更多_读取存档") end
            appearTap("生息读取存档确认", .1)
            if findOne("生息读取存档确认红") then
                tap("生息读取存档确认红")
                ssleep(1)
            end
            if findOne("生息中间存档") then
                tap("生息中间存档")
                ssleep(1)
            end
            if findOne("生息左边存档") then
                tap("生息左边存档")
                ssleep(1)
            end
            appearTap("生息左边存档确认", .1)
            if findOne("沙洲遗闻开启今日") then
                if not wait(function()
                        if not findOne("沙洲遗闻开启今日") then return true end
                        if findOne("生息底栏烹饪按钮") then return true end
                        tap("沙洲遗闻开启今日")
                        ssleep(.1)
                    end, 7) then
                end
                return true
            end
        end, 15) then
    end
end

Tales_within_the_sand.检查代币数量 = function()
    if not Prosperity_same_number then
        captureqqimagedeliver("INFO", "生息任务开始", "生息任务开始", true)
        Prosperity_same_number = 0
    end
    if sand_nostop then return end
    if sand_noincrease_stop and Prosperity_same_number > 5 then
        log.warn("连续5次未增加")
        if cloud_get_task then
            log("云控上报")
            captureqqimagedeliver("INFO", "生息任务结束2", "繁荣值" .. nx, true)
            cloud.releaseDeviceByTaskInfo()
        else
            log("非云控")
            log("生息演算任务完成,繁荣值" .. nx)
        end
        return true
    end
end

Tales_within_the_sand.生息演算地图缩放 = function(min)
    log("生息演算地图缩放", min)
    if min then
        Apoint = { point["生息演算缩放开始"], point["生息演算缩放结束"], point["生息演算缩放结束"] }
    else
        Apoint = { point["生息演算缩放结束"], point["生息演算缩放开始"], point["生息演算缩放开始"] }
    end
    gesture({
        {
            point = Apoint,
            start = 0,
            duration = 300,
        },
    })
end

Tales_within_the_sand.生息演算奇遇节点 = function()
    Tales_within_the_sand.掉线状态判断()
    Tales_within_the_sand.生息演算地图缩放(true)
    ssleep(0.5)
    if not findOne("生息底栏烹饪按钮") then
        log.warn("生息演算奇遇节点未找到底栏")
        return
    end
    local 判断内容 = ""
    if not wait(function()
            tap("生息演算奇遇点")
            if findOne("生息演算奇遇判断") then
                判断内容 = "生息演算奇遇判断"
                return true
            end
            -- if findOne("生息演算奇遇地摊") then
            --     判断内容 = "生息演算奇遇地摊"
            --     return true
            -- end
        end, 5) then
    end
    if not findOne(判断内容) then
        log.warn("生息演算奇遇节点未找到判断")
        return
    end

    if not wait(function()
            tap("生息演算奇遇确认决断")
            if not findOne(判断内容) then return true end
        end, 5) then
    end

    if not wait(function()
            appearTap("生息演算奇遇_好的确认", 1)
            tap("生息演算奇遇_好的")
            if not findOne(判断内容) then return true end
        end, 5) then
    end
end

Tales_within_the_sand.生息演算奇遇 = function(关卡)
    log("生息演算奇遇")
    Tales_within_the_sand.掉线状态判断()
    if not appear(关卡, 3) then return end
    tap(关卡)
    appear("生息演算奇遇页面", 2)
    if findOne("生息演算奇遇开始行动") then
        tap("生息演算左上角返回")
        ssleep(.2)
        tap("生息演算右上角生息日")
        ssleep(.2)
        Tales_within_the_sand.下一天()
        return
    end
    for i = 1, 2 do
        log(i)
        local q = false
        if not wait(function()
                if findAny({ "生息底栏烹饪按钮", "生息演算奇遇开始行动" }) then
                    q = true
                    return true
                end
                tap("沙洲遗闻奇遇确定")
                ssleep(.2)
                if findOne("沙洲遗闻奇遇标签") then
                    tap("沙洲遗闻奇遇标签")
                    ssleep(.2)
                    tap("生息演算消磨时间")
                    log("奇遇缺少材料")
                    ssleep(.1)
                    q = true
                    return true
                end
            end, 3.5) then
        end
        if q then break end
        q = false
        if not wait(function()
                local p = findOne("沙洲遗闻对话确定")
                if p then
                    tap(p)
                    ssleep(.2)
                    if not wait(function()
                            --右上角出现标签就是完成了
                            if findOne("沙洲遗闻奇遇标签") then
                                tap("沙洲遗闻奇遇标签")
                                ssleep(.2)
                                tap("生息演算消磨时间")
                                log("完成奇遇")
                                ssleep(.1)
                                q = true
                                return true
                            end
                            if findAny({ "沙洲遗闻右边奇遇", "生息底栏烹饪按钮", "生息演算奇遇开始行动" }) then
                                return true
                            end
                            tap({ scale(1737), p[2] })
                            ssleep(.2)
                        end, 5) then
                        return true
                    end
                end
                if q then return true end
            end, 5) then
        end
        if q then break end
    end
    ssleep(.2)
    if findOne("生息演算奇遇开始行动") then
        tap("生息演算左上角返回")
        ssleep(.2)
        tap("生息演算右上角生息日")
        ssleep(.2)
        Tales_within_the_sand.下一天()
        return
    end
    if not wait(function()
            if findOne("沙洲遗闻决断点已补充") then
                log("荒季过天")
                if not wait(function()
                        tap("沙洲遗闻决断点已补充")
                        ssleep(.1)
                        if not findOne("沙洲遗闻决断点已补充") then return true end
                    end, 5) then
                    return true
                end
                return true
            end
            if findOne("沙洲遗闻开启今日荒季") then
                log("荒季过天")
                if not wait(function()
                        tap("沙洲遗闻开启今日荒季")
                        ssleep(.1)
                        if not findOne("沙洲遗闻开启今日荒季") then return true end
                    end, 5) then
                    return true
                end
                return true
            end
            if findOne("生息演算消磨时间") or findOne("生息演算消磨时间2") then tap("生息演算消磨时间") end
            if findOne("生息演算跳过当日确认") then tap("生息演算跳过当日确认") end
            if findOne("生息演算进入下一天") then tap("生息演算进入下一天") end

            if findOne("沙洲遗闻奇遇标签") then
                tap("沙洲遗闻奇遇标签")
                ssleep(.2)
            end
            if findOne("生息演算完成生存周期") then
                ssleep(2)
                local text = ocro("沙洲遗闻转化繁荣点数")
                log.debug(text)
                if text == "MAX" or (text ~= nil and tonumber(text) == nil) then
                    log("繁荣点数已满")
                    Prosperity_same_number = 6
                end
                tap("沙洲遗闻开启今日")
            end
            log.debug()
            appearTap("沙洲遗闻开启今日", .1)
            if findOne("沙洲遗闻开启今日") then
                log("荒季过天")
                if not wait(function()
                        tap("沙洲遗闻开启今日")
                        ssleep(.1)
                        if not findOne("沙洲遗闻开启今日") then return true end
                    end, 5) then
                    return true
                end
                return true
            end
            if findOne("沙洲遗闻基地产出") then
                log("沙洲遗闻基地产出")
                if not wait(function()
                        if findOne("生息底栏烹饪按钮") then return true end
                        tap("生息演算下一天_勾")
                        ssleep(.5)
                    end, 5) then
                end
                return true
            end
        end, 20) then
    end
    appear("生息底栏烹饪按钮", 6)
    ssleep(.2)
end

Tales_within_the_sand.敌袭1 = function()
    log("敌袭1")
    Tales_within_the_sand.掉线状态判断()
    if not appear("沙洲遗闻敌袭1", 5) then
        return
    end
    ssleep(.1)
    tap("沙洲遗闻敌袭1")
    appearTap("沙洲遗闻敌袭开始行动", 5)
    appear("生息演算开始行动", 3)
    ssleep(1)
    if not wait(function()
            tap("沙洲遗闻快捷编队")
            if not findOne("沙洲遗闻快捷编队") then return true end
        end, 5, .1) then
        return
    end
    appear("沙洲遗闻编入队伍", 3)
    ssleep(1)
    tap("生息演算编队清空选择")
    ssleep(1)
    if not findOne("生息演算职业选择") then tap("生息演算职业选择") end
    if not appear("生息演算近卫选择", .5) then
        tap("生息演算近卫选择")
        appear("生息演算近卫选择", .5)
    end

    local oper_selected = 0
    for i = 1, 8 do
        tap("生息演算干员选择列表" .. i)
        oper_selected = oper_selected + 1
        ssleep(.3)
        if findOne("生息演算干员选择阻挡1") then
            tap("生息演算干员选择列表" .. i)
            oper_selected = oper_selected - 1
        end
        if oper_selected == 4 then break end
    end
    if not wait(function()
            if not findOne("沙洲遗闻编入队伍") then return true end
            tap("沙洲遗闻编入队伍")
        end, 5) then
        return
    end
    appear("生息演算开始行动")
    if not wait(function()
            tap("生息演算开始行动")
            if not findOne("生息演算开始行动") then return true end
            -- 出现过在这儿卡死的
            if not disappear("正在提交反馈至神经", network_timeout) then
                return true
            end
        end, 10) then
        return
    end
    -- 游戏界面
    if not wait(function()
            if findOne("单选确认框") then return true end
            if findOne("生命值") then return true end
        end, 30) then
        return
    end

    if not findOne("生命值") then return end

    -- 需要等等才能点
    appearTap("两倍速", 3)
    ssleep(.3)

    -- 向左滑动
    local 关卡内向左滑动 = function()
        gesture({
            {
                point = { { screen.width * 0.95,  screen.height / 2 },
                    { screen.width * 0.2,             screen.height / 2 },
                    { screen.width * 0.2 - scale(10), screen.height / 2 },
                    { screen.width * 0.2 + scale(10), screen.height / 2 },
                    { screen.width * 0.2 - scale(10), screen.height / 2 },
                    { screen.width * 0.2 + scale(10), screen.height / 2 } },
                start = 0,
                duration = 600,
            },
        })
        sleep(650)
    end

    -- 总有滑动不到底的情况
    关卡内向左滑动()
    关卡内向左滑动()
    关卡内向左滑动()

    local n = 识别未部署干员数量()
    log("待部署区干员数量", n)
    for i = 1, n do
        if not wait(function()
                if findOne("生息演算干员费用够列表1") then
                    local p = point["沙洲遗闻敌袭1部署列表" .. i]
                    log(p)
                    deploy(screen.width - scale(210), p[1], p[2], 4)
                    return true
                end
                if not findOne("生命值") then
                    log.debug()
                    -- return true
                end
            end, 30) then
            return
        end
    end
    -- 退出关卡
    if not wait(function()
            if findOne("生息底栏烹饪按钮") then
                return true
            end

            if findOne("生息演算行动结束") then
                tap("生息演算_确认按钮")
            end

            if findOne("生息演算主页进入") then
                return true
            end
            ssleep(1)
        end, 130) then
    end
    ssleep(.1)
end

Tales_within_the_sand.制作饮料 = function()
    log("制作饮料")

    --if not wait(function()
    appearTap("生息演算制作饮料确认", 1)
    appearTap("生息演算制作饮料auto1", 1)
    for i = 1, 6 do
        tap("生息演算制作饮料auto1")
        ssleep(.1)
    end
    ssleep(.1)
    appearTap("生息演算投入食料", .5)
    appear("生息演算获得饮料", 5)
    if not wait(function()
            if findOne("生息演算获得饮料") then
                tap("生息演算获得饮料")
            end
            if findOne("生息演算烹饪台") then
                tap("生息演算左上角返回")
            end
            if findOne("生息演算开始行动") then
                return true
            end
        end, 5) then
    end
    --end, 15) then
    --end

    return true
end

Tales_within_the_sand.生息关卡进入 = function(关卡, 剧情)
    log("进入关卡:" .. 关卡)
    Tales_within_the_sand.掉线状态判断()
    if not wait(function()
            if findOne(关卡) then
                tap(关卡)
                return true
            end
        end, 3) then
        return
    end
    -- 进入关卡
    if not wait(function()
            appearTap("生息演算进入关卡", 0.1)
            if findOne("生息演算缺少饮料") then
                tap("生息演算缺少饮料")
                if not Tales_within_the_sand.制作饮料() then return false end
            end
            if findOne("生息演算制作饮料确认") then
                if not Tales_within_the_sand.制作饮料() then return false end
            end
            appearTap("生息演算开始行动", 0.1)
            appearTap("生息演算开始行动红色确认", 0.1)
            if findOne("生息演算关卡左上角退出") then
                return true
            end
        end, 20) then
    end
    if 剧情 then
        -- 等待剧情完成
        剧情进入确认 = false
        if not wait(function()
                if not 剧情进入确认 and findOne("生息演算聊天日志") then
                    剧情进入确认 = true
                end
                if findOne("生息演算关卡左上角退出") and 剧情进入确认 then
                    return true
                end
                tap("生息演算剧情点击点")
            end, 40) then
        end
    end

    -- 退出关卡
    if not wait(function()
            if findOne("生息底栏烹饪按钮") then return true end
            if findOne("生息演算关卡左上角退出") then tap("生息演算关卡左上角退出") end
            if findOne("生息演算_确认按钮") then tap("生息演算_确认按钮") end
            if findOne("生息演算行动结束") then tap("生息演算_确认按钮") end
            if findOne("生息演算剧情中") then tap("生息演算_确认按钮") end
            if findOne("生息演算主页进入") then return true end
            ssleep(.1)
        end, 30) then
    end
    ssleep(.1)
end

Tales_within_the_sand.会聚之地 = function()
    log("会聚之地")
    -- 等待加载到会聚之地
    if findOne("生息演算会聚之地_非剧情") then
        return
    end
    appear("生息演算会聚之地", 10)
    if not findOne("生息演算会聚之地") then
        return
    end
    -- 进入关卡
    tap("生息演算会聚之地")
    if not wait(function()
            if findOne("生息演算会聚之地开始行动") then
                tap("生息演算会聚之地开始行动")
                return true
            end
            tap("生息演算会聚之地")
        end, 5) then
    end

    -- 等待剧情完成
    剧情进入确认 = false
    if not wait(function()
            if not 剧情进入确认 and findOne("生息演算聊天日志") then
                剧情进入确认 = true
            end
            if findOne("生息演算关卡左上角退出") and 剧情进入确认 then
                return true
            end
            tap("生息演算剧情点击点")
        end, 40) then
    end

    -- 退出关卡
    if not wait(function()
            if findOne("生息底栏烹饪按钮") then
                return true
            end
            tap("生息演算关卡左上角退出")
            disappear("生息演算关卡左上角退出", 3)
            tap("生息演算_确认按钮")
            appear("生息底栏烹饪按钮", 2)
        end, 20) then
    end
    log("会聚之地结束")
end

Tales_within_the_sand.下一天 = function(check_point)
    log("下一天")
    Tales_within_the_sand.掉线状态判断()

    if not appear("生息底栏烹饪按钮", 5) then
        toast("生息底栏烹饪按钮未找到")
        return
    end
    log(findOne("生息演算消磨时间"))
    if not findOne("生息演算消磨时间") then
        tap("生息演算右上角生息日")
        ssleep(.2)
    end
    log.debug()
    开启今日 = false
    if not wait(function()
            if findOne("生息演算消磨时间") or findOne("生息演算消磨时间2") then tap("生息演算消磨时间") end
            if findOne("生息演算跳过当日确认") then tap("生息演算跳过当日确认") end
            if findOne("沙洲遗闻奇遇标签") then tap("沙洲遗闻奇遇标签") end
            if findOne("生息演算进入下一天") then tap("生息演算进入下一天") end
            if findOne("生息演算完成生存周期") then
                if check_point then
                    ssleep(1)
                    local text = ocro("沙洲遗闻转化繁荣点数")
                    log(text)
                    if text == "MAX" or (text ~= nil and tonumber(text) == nil) then
                        log("繁荣点数已满")
                        Prosperity_same_number = 6
                    end
                end
                tap("沙洲遗闻开启今日")
            end
            if findOne("沙洲遗闻后勤教程") then
                tap("沙洲遗闻后勤教程")
                if not wait(function()
                        if findOne("生息演算剧情下") then
                            tap("生息演算剧情下")
                            ssleep(.4)
                            tap("生息演算左上角返回")
                            ssleep(.2)
                        end
                        if findOne("沙洲遗闻开启今日") then return true end
                    end, 3) then
                    return true
                end
            end
            if findOne("沙洲遗闻决断点已补充") then
                if not wait(function()
                        tap("沙洲遗闻决断点已补充")
                        ssleep(.1)
                        if not findOne("沙洲遗闻决断点已补充") then return true end
                    end, 5) then
                    return true
                end
                return true
            end
            appearTap("沙洲遗闻开启今日", .1)
            if 开启今日 and findOne("生息底栏烹饪按钮") then
                return true
            end
            if findOne("沙洲遗闻开启今日荒季") then
                --荒季过天
                if not wait(function()
                        tap("沙洲遗闻开启今日荒季")
                        ssleep(.1)
                        if not findOne("沙洲遗闻开启今日荒季") then return true end
                    end, 5) then
                    return true
                end
            end
            if findOne("沙洲遗闻开启今日") or findOne("沙洲遗闻决断点已补充") then
                开启今日 = true
                if not wait(function()
                        tap("沙洲遗闻开启今日")
                        if findOne("生息底栏烹饪按钮") then return true end
                        if not findOne("沙洲遗闻开启今日") then return true end
                    end, 7) then
                    return false
                end
            end
            if findOne("生息演算奇遇开始行动") then
                tap("生息演算左上角返回")
                ssleep(.1)
            end
            if findOne("沙洲遗闻基地产出") then
                if not wait(function()
                        if findOne("生息底栏烹饪按钮") then return true end
                        tap("生息演算下一天_勾")
                        ssleep(.5)
                    end, 5) then
                end
                return true
            end
        end, 20) then
    end
    appear("生息底栏烹饪按钮", 6)
    if appear("生息演算剧情上", 1) then
        if not wait(function()
                tap("生息演算剧情上")
                ssleep(.1)
                if findOne("沙洲遗闻换季教程") then
                    tap("生息演算进入下一天")
                end
                if not findOne("生息演算剧情上") then
                    ssleep(.4)
                    return true
                end
            end, 5) then
            return true
        end
    end
    ssleep(.2)
end

-- ===========================================
--               商店购买
-- ===========================================

Tales_within_the_sand.商店购买 = function()
    if not findAny({ "生息演算主页进入", "生息演算繁荣馈赠判断" }) then
        Tales_within_the_sand.生息跳转()
    end
    log("生息沙洲遗闻商店购买")
    appear("生息演算繁荣馈赠", 1)
    if not wait(function()
            if findOne("沙洲遗闻商店界面") then return true end
            appearTap("生息演算繁荣馈赠", 0.1)
        end, 5) then
    end

    disappear("正在提交反馈至神经", network_timeout)

    -- 防止各种掉帧等导致卡在领取等页面
    local 回到商店主页 = function()
        if not wait(function()
                if findOne("沙洲遗闻商店界面") then return true end
                tap("商店顶栏")
                ssleep(0.2)
            end, 10) then
            return
        end
    end

    if not appear("沙洲遗闻商店界面", 1) then
        log.warn("未找到商店")
        return
    end
    local 物品横间距, 物品纵间距 = scale(516), scale(242)
    回到商店主页()
    local t = os.time()
    while true do
        if os.time() - t > 5 * 60 then -- 任务总时长5分钟
            log("商店任务超时")
            return
        end
        for x = 0, 2 do -- 3*3商品进行购买
            for y = 0, 2 do
                log(x, y)
                for i = 1, 7 do
                    回到商店主页()
                    local intX, intY = findMultiColor(scale(120) + x * 物品横间距, scale(515) + y * 物品纵间距,
                        scale(386) + x * 物品横间距, scale(555) + y * 物品纵间距, "FFFFFF",
                        scale(17) .. "|" .. scale(-2) .. "|575757|" ..
                        scale(-100) .. "|" .. scale(-5) .. "|5A5A5A",
                        0, 0.85)
                    if intX == -1 then break end
                    if not wait(function()
                            tap({ intX, intY })
                            ssleep(.6)
                            if findOne("购买物品面板") then return true end
                        end, 1.8) then
                    end
                    if findOne("沙洲遗闻商店界面") then
                        log.warn("未能进入商品，大概是识别错了")
                        break
                    end
                    -- 点击购买
                    if not wait(function()
                            if findOne("商店购买数量最多") then
                                tap("商店购买数量最多")
                                ssleep(0.2)
                            end
                            if findOne("生息演算繁荣馈赠支付") then
                                tap("生息演算繁荣馈赠支付")
                                ssleep(0.5)
                                disappear("正在提交反馈至神经", network_timeout)
                            end
                            if not findOne("购买物品面板") then return true end
                        end, 5) then
                    end
                    --disappear("正在提交反馈至神经", network_timeout)
                    if findOne("购买物品面板") then
                        log.warn("未能购买，大概是钱花完了")
                        return true
                    end
                end
                log("开始下一个商品")
            end
        end
        回到商店主页()
        ssleep(.5)
        local sx = { screen.width * 0.8, screen.height * 0.5 }
        local oricol = getColor(sx[1], sx[2])
        path.swip_hd_shop()
        ssleep(.5)
        if getColor(sx[1], sx[2]) == oricol then
            log("大概滑动到底了吧~")
            return true
        end
    end
    return true
end

-- ===========================================
--               后期单纯跳过
-- ===========================================

Tales_within_the_sand.连续跳过 = function()
    ssleep(1)
    log("沙洲遗闻")
    if findOne("主页长期探索_生息演算_沙洲遗闻") then
        tap("主页长期探索_生息演算_沙洲遗闻", 0.1)
    end
    if not findOne("生息底栏烹饪按钮") then
        log("非游戏内")
        if not findOne("生息演算主页进入") then
            log.warn("未找到主页，从头开始")
            Tales_within_the_sand.生息跳转()
        end
        tap("生息演算主页进入")
        appear("生息底栏烹饪按钮", 5)
    end
    while true do
        Tales_within_the_sand.下一天()
        Tales_within_the_sand.下一天()
        Tales_within_the_sand.组装荧光棒()
        Tales_within_the_sand.下一天(true)
        Tales_within_the_sand.回到三天前存档()
    end
end

Tales_within_the_sand.循环下一天 = function()
    ssleep(1)
    log("沙洲遗闻")
    if not findOne("生息底栏烹饪按钮") then
        log("非游戏内")
        if not findOne("生息演算主页进入") then
            log.warn("未找到主页，从头开始")
            Tales_within_the_sand.生息跳转()
        end
        -- if not wait(function()
        --         if not findOne("生息底栏烹饪按钮") then tap("生息演算主页进入") end
        --         if findOne("生息底栏烹饪按钮") then return true end
        --     end, 3) then
        --     return
        -- end
    else
        tap("生息演算左上角返回")
        if findOne("生息底栏烹饪按钮") then
            tap("生息演算_全局_返回")
        end
        appear("生息演算主页进入")
    end
    if findOne("生息演算主页进入") then
        Tales_within_the_sand.切换难度(sand_mode)
        tap("生息演算主页进入")
    end
    while true do
        Tales_within_the_sand.下一天()
    end
end

-- ===========================================
--               休养模式相关
-- ===========================================
Tales_within_the_sand.组装种植箱 = function()
    wait(function()
        tap("沙洲遗闻组装台")
        disappear("沙洲遗闻组装台", 1)
        if not findOne("沙洲遗闻组装台") then
            return true
        end
    end, 5)
    ssleep(.1)
    wait(function()
        tap("沙洲遗闻组装台驻地设施")
        if appearTap("沙洲遗闻组装台种植箱") then
            if appearTap("沙洲遗闻组装台开始组装") then
                return true
            end
        end
    end, 5)
    back()
    wait(function()
        back()
        ssleep(.5)
        if appear("生息底栏烹饪按钮", 0.5) then
            return true
        end
    end, 5)
    种植箱 = true
    Tales_within_the_sand.重置地图位置()
end
Tales_within_the_sand.组装荧光棒 = function()
    -- 配方滑动,一次滑动3个
    local swip_formula = function(up)
        local duration
        local finger
        local delay
        if up then
            local x1 = scale(1130)
            local y1 = scale(159)
            local y2 = scale(6000 / 720 * 1080)
            duration = 400
            finger = { { point = { { x1, y1 }, { x1, y2 } }, duration = duration } }
            delay = 750
        else
            local x = scale(1200)
            local y = scale(169)
            local y2 = scale(778) --距离
            local x2 = scale(800)
            local x3 = scale(1130)
            local y3 = scale(910)
            local slids = 50
            local slidd = 200
            local taps = slids + slidd + 150
            local tapd = 200
            local downd = taps + 100
            duration = downd
            finger = {
                { point = { { x, y }, { x2, y } },    start = 0,     duration = downd },
                { point = { { x, y2 }, { x3, y2 } },  start = slids, duration = slidd },
                { point = { { x3, y3 }, { x3, y3 } }, start = taps,  duration = tapd },
            }
            delay = 250
        end
        log(JsonEncode(finger))
        gesture(finger)
        sleep(duration + delay)
    end
    荧光棒位置 = 0
    local 选择荧光棒 = function()
        --滑到最上面
        swip_formula(true)
        ssleep(.5)
        for i = 1, 5 do
            for j = 1, 6 do
                local formula = ocro("沙洲遗闻配方名称列表" .. j)
                log(formula)
                if formula == "荧光棒" then
                    荧光棒位置 = j
                    tap("沙洲遗闻配方名称列表" .. j)
                    return true
                end
            end
            swip_formula()
            ssleep(.3)
        end
    end
    local 退出商店 = function()
        wait(function()
            back()
            ssleep(1)
            if appear("生息底栏烹饪按钮", 1) then
                return true
            end
        end, 5)
    end
    wait(function()
        tap("沙洲遗闻组装台")
        disappear("沙洲遗闻组装台", 1)
        if not findOne("沙洲遗闻组装台") then
            return true
        end
    end, 5)
    if 选择荧光棒() then
        while true do
            appear("沙洲遗闻组装台开始组装", 2)
            if findOne("生息演算荧光棒加号不可点击") then
                退出商店()
                return
            end
            wait(function()
                if findOne("生息演算荧光棒加号不可点击") then
                    return true
                end
                tap("生息演算荧光棒加号")
            end, 12)
            -- 长按加号,大概1s+9
            -- gesture({
            --     {
            --         point = {
            --             { scale(1346), scale(788) },
            --             { scale(1346), scale(788) },
            --         },
            --         start = 0,
            --         duration = 11500,
            --     },
            -- })
            -- ssleep(11.5)
            tap("沙洲遗闻组装台开始组装")
            disappear("沙洲遗闻组装台开始组装", 5)
            wait(function()
                if findOne("沙洲遗闻组装台开始组装") then
                    return true
                end
                tap("沙洲遗闻配方名称列表" .. 荧光棒位置)
                ssleep(.5)
            end, 5)
        end
    end
    退出商店()
    -- Tales_within_the_sand.重置地图位置()
end

Tales_within_the_sand.基地摆放物品 = function()
    tap("沙洲遗闻基地")
    if not appear("沙洲遗闻基地升级", 2) then return end
    ssleep(.5)
    tap("生息演算奇遇开始行动")
    if not appear("生息演算基建", 15) then return end

    -- 进入基建后
    local n = 识别未部署干员数量()
    log("待部署区物品数量", n)
    local j = 0
    for i = 1, n do
        j = j + 1
        if not wait(function()
                if findOne("生息演算干员费用够列表1") then
                    local p = point["沙洲遗闻基建部署列表" .. j]
                    log(j, p)
                    deploy(screen.width - scale(210), p[1], p[2], 4, true)
                    ssleep(.2)
                    return true
                end
                if not findOne("生命值") then
                    log.debug("已有部署")
                    i = i - 1
                    return true
                end
            end, 5) then
            return
        end
    end
    ssleep(.2)
    tap("作战中") --保存
    ssleep(.2)
    disappear("正在提交反馈至神经", network_timeout)
    Tales_within_the_sand.重置地图位置()
end

Tales_within_the_sand.六天奇遇循环 = function()
    log("奇遇循环")
    local 基地等级 = 1
    local 商店科技树等级 = 0
    种植箱 = (种植箱 == nil) and false or 种植箱
    while true do
        Tales_within_the_sand.重置地图位置()
        local lv等级 = ocro("沙洲遗闻基地等级判断范围") or ""
        lv等级 = string.gsub(lv等级, "LV.", "")
        lv等级 = tonumber(lv等级) or 1
        基地等级 = lv等级
        local 水 = tonumber(ocro("沙洲遗闻水") or 0) or 0
        local 石头 = tonumber(ocro("沙洲遗闻石头") or 0) or 0
        local 木头 = 石头
        if 基地等级 < 2 then
            -- 没开石头,识别的是木材的数量
            石头 = 0
        end
        if 基地等级 >= 2 then
            木头 = tonumber(ocro("沙洲遗闻木头") or 0) or 0
        end
        log("基地等级", 基地等级, "商店科技树等级", 商店科技树等级, "水", 水, "木头", 木头, "石头", 石头)
        if 基地等级 == 1 and findOne("沙洲遗闻基地可升级") then
            基地等级 = Tales_within_the_sand.基地升级(基地等级) or 1
            if 基地等级 == 2 then
                Tales_within_the_sand.后舍对话()
                Tales_within_the_sand.重置地图位置(true)
            end
        elseif 基地等级 == 2 and findOne("沙洲遗闻基地可升级") then
            -- 搓个水稻,丢基地里
            基地等级 = Tales_within_the_sand.基地升级(基地等级) or 2
        elseif 基地等级 == 3 and 木头 >= 198 then
            break
        elseif 基地等级 == 2 and 水 > 10 and 木头 > 30 and not 种植箱 and not skip_make then
            -- 种植箱,没开商店前按钮不一样
            Tales_within_the_sand.组装种植箱()
            Tales_within_the_sand.基地摆放物品()
        end
        Tales_within_the_sand.生息演算奇遇("沙洲遗闻奇遇风啸峡谷")
        tap("沙洲遗闻丢失的订单")
        appear("生息演算开始行动", 2)
        ssleep(.2)
        Tales_within_the_sand.生息演算奇遇("沙洲遗闻奇遇风啸峡谷2")
        if 商店科技树等级 >= 2 then Tales_within_the_sand.局内商店(基地等级, 木头, 石头) end
        Tales_within_the_sand.重置地图位置(true)
        tap("沙洲遗闻林中寻宝3")
        appear("生息演算开始行动", 2)
        ssleep(.2)
        Tales_within_the_sand.生息演算奇遇("沙洲遗闻奇遇砾沙平原2")
        Tales_within_the_sand.生息演算奇遇("沙洲遗闻奇遇崎岖窄路")
        Tales_within_the_sand.下一天()
        if 商店科技树等级 >= 2 then Tales_within_the_sand.局内商店(基地等级, 木头, 石头) end
        Tales_within_the_sand.下一天()
        if 基地等级 > 1 and 商店科技树等级 < 5 then
            商店科技树等级 = Tales_within_the_sand.科技树升级(商店科技树等级)
        end
    end
end

Tales_within_the_sand.基地升级 = function(基地等级)
    local level = 基地等级 or 1
    tap("沙洲遗闻基地")
    appearTap("沙洲遗闻基地升级", 2)
    if appear("沙洲遗闻基地升级确认", 2) then
        tap("沙洲遗闻基地升级确认")
        level = level + 1
        if not wait(function()
                tap("沙洲遗闻基地升级完成")
                if findOne("沙洲遗闻科技树升级灰") then return true end
            end, 6) then
        end
        if not wait(function()
                tap("生息演算左上角返回")
                ssleep(.2)
                if findOne("生息底栏烹饪按钮") then return true end
            end, 6) then
        end
    end
    return level
end

Tales_within_the_sand.局内商店 = function(基地等级, 木头, 石头)
    if not findOne("沙洲遗闻局内商店") then return end
    log(基地等级, 木头, 石头)
    tap("沙洲遗闻局内商店")
    appear("沙洲遗闻局内商店页面", 2)
    for j = 1, 2 do
        for i = 1, 4 do
            point.沙洲遗闻局内商品名范围 = { scale(630 + 327 * (i - 1)), scale(172 + 327 * (j - 1)), scale(844 + 327 * (i - 1)),
                scale(214 + 327 * (j - 1)) }
            local 商品名 = ocro("沙洲遗闻局内商品名范围")
            log(商品名)
            if (基地等级 == 2 and 商品名 == "石材" and 石头 < 40) or (基地等级 > 2 and 商品名 == "木材" and 木头 < 198) then
                tap({ scale(630 + 327 * (i - 1)), scale(172 + 327 * (j - 1)) })
                if not appear("沙洲遗闻局内商店确认支付", 2) then
                    tap("沙洲遗闻局内商店")
                    ssleep(.5)
                    break
                end
                gesture({
                    {
                        point = {
                            { scale(1552), scale(564) },
                            { scale(1552), scale(564) },
                        },
                        start = 0,
                        duration = 2500,
                    },
                })
                ssleep(2.5)
                if not wait(function()
                        tap("沙洲遗闻局内商店确认支付")
                        ssleep(.1)
                        if findOne("沙洲遗闻局内商店页面") then return true end
                    end, 2) then
                end
            end
        end
    end

    --退出商店
    ssleep(.1)

    wait(function()
        back()
        ssleep(.5)
        if appear("生息底栏烹饪按钮", 1) then
            return true
        end
    end, 5)

    -- tap("沙洲遗闻局内商店")
    -- disappear("沙洲遗闻局内商店页面", 2)
end

Tales_within_the_sand.科技树升级 = function(商店科技树等级)
    local level = 商店科技树等级 or 0
    if not findOne("沙洲遗闻科技树") then return level end
    tap("沙洲遗闻科技树")
    appear("沙洲遗闻科技树页面", 2)
    ssleep(.2)
    if not findOne("沙洲遗闻商店科技树") then tap("沙洲遗闻商店科技树") end
    appear("沙洲遗闻商店科技树", 2)
    ssleep(1.5)
    if 商店科技树等级 < 4 then
        for i = 1, 4 do
            if findOne("沙洲遗闻科技树升级列表" .. i) then
                tap("沙洲遗闻科技树升级列表" .. i)
                if appear("沙洲遗闻科技树升级确认", 2) then
                    tap("沙洲遗闻科技树升级确认")
                    level = i
                    ssleep(.2)
                end
            end
        end
    end

    if findOne("沙洲遗闻科技树升级完成4") then
        level = 4
        gesture({ { point = { { scale(1800), scale(533) }, { scale(200), scale(533) } }, duration = 300, } })
        ssleep(1) --等待回弹动画
        if findOne("沙洲遗闻科技树升级列表5") then
            tap("沙洲遗闻科技树升级列表5")
            if appear("沙洲遗闻科技树升级确认", 2) then
                tap("沙洲遗闻科技树升级确认")
                ssleep(.2)
                level = 5
            end
        else
            level = 5
        end
    end
    --退出科技树
    tap("沙洲遗闻科技树")
    disappear("沙洲遗闻科技树页面", 2)
    return math.max(level, 商店科技树等级)
end

Tales_within_the_sand.后舍对话 = function()
    -- 后舍对话
    Tales_within_the_sand.重置地图位置(true)
    appearTap("沙洲遗闻后舍存在任务", 5)
    if appear("生息演算奇遇页面", 5) then
        if not wait(function()
                local p = findOne("沙洲遗闻对话确定")
                if p then
                    tap(p)
                    ssleep(.2)
                    if not wait(function()
                            --右上角出现标签就是完成了
                            if findAny({ "沙洲遗闻右边奇遇", "生息底栏烹饪按钮", "生息演算奇遇开始行动", "沙洲遗闻奇遇标签" }) then
                                return true
                            end
                            tap({ scale(1737), p[2] })
                            ssleep(.2)
                        end, 5) then
                        return true
                    end
                end
            end, 5) then
        end
        appearTap("沙洲遗闻后舍存在任务", 5)
    end
    appearTap("生息演算会聚之地开始行动", 5)
    appear("生息演算关卡左上角退出")
    ssleep(3)
    appearTap("沙洲遗闻后舍交换石头干员存在", 5)
    ssleep(.5)
    appearTap("沙洲遗闻后舍交换石头干员开始对话", 5)
    appear("生息演算聊天日志")
    wait(function()
        if findOne("生息演算关卡左上角退出") then
            return true
        end
        tap("生息演算剧情点击点")
    end, 25)
    if not wait(function()
            if findOne("生息底栏烹饪按钮") then
                return true
            end
            tap("生息演算关卡左上角退出")
            ssleep(.5)
        end, 20) then
    end
    log("会聚之地兑换结束")
end


-- ===========================================
--               生息演算
--               重启锚点
-- ===========================================
Relaunch_anchor = {}
Relaunch_anchor_firsttime = true

重启锚点 = function()
    log("重启锚点开始")
    if findOne("主页长期探索_生息演算_重启锚点") then
        tap("主页长期探索_生息演算_重启锚点", 0.1)
    end
    if not findOne("生息演算_重启锚点_主页进入开始建设") then
        
    elseif findOne("生息演算_重启锚点_基地图标") then
        log("检测到在游戏内")
    else
        log.warn("未找到主页，从头开始")
        Relaunch_anchor.生息跳转()
    end
    Tales_within_the_sand.掉线状态判断()
    if Tales_within_the_sand.检查代币数量() then
        return true
    end

    Relaunch_anchor.开始演算(sand_mode)
end

Relaunch_anchor.开始演算 = function(sand2_mode)
    log("开始演算")
    if findOne("生息演算_重启锚点_主页进入开始建设") then
        tap("生息演算_重启锚点_主页进入开始建设")
        appear("生息演算_重启锚点_基地图标", 3)
    end
    --[[if sand2_mode == 4 then
        Relaunch_anchor.ra_15()
    else
        path.跳转("首页")
    end]]--
    
        Relaunch_anchor.ra_15()
end

Relaunch_anchor.ra_15 = function()
    log("重复刷RA-15")
            appear("生息演算_重启锚点_基地图标")
    if findOne("生息演算_重启锚点_基地图标") then
        if Relaunch_anchor_firsttime then
            appearTap("生息演算_重启锚点_基地图标", 3)
            appear("生息演算_重启锚点_基地介绍页")
            if not wait(function()
                if findOne("生息演算_重启锚点_基地图标") then return true end
                tap("生息演算左上角返回")
                ssleep(.5)
            end, 10) then
        end
            appearTap("生息演算_重启锚点_大地图左下ra15", 3)
        else
            appearTap("生息演算_重启锚点_大地图正中ra15", 3)
        end
        ssleep(2)
        appearTap("生息演算_重启锚点_开启建设", 3)
        if not wait(function()
                if findOne("生息演算_重启锚点_战术倾向确认选择") then return true end
                tap("生息演算_重启锚点_战术倾向")
            end, 10) then
        end
        tap("生息演算_重启锚点_战术倾向确认选择")
        ssleep(2)
        appearTap("生息演算_重启锚点_干员招募", 3)
        ssleep(2)
        appearTap("生息演算_重启锚点_确认招募", 3)
        appearTap("生息演算_重启锚点_确认", 3)
        ssleep(3)
        tap("生息演算_重启锚点_开启建设", 3)
        appear("生息演算_重启锚点_剧情")
        if not wait(function()
                if findOne("生息演算_重启锚点_战斗退出") then return true end
                tap("两倍速")
                ssleep(.5)
            end, 30) then
        end
        log("战斗开始")
        
        if sand2_fullbuff then
            log("满buff,14人")
            --sx_deploy13(point.生息演算_重启锚点_作战关卡["RA15"], 2)
            
                Deploy7(1, point.生息演算_重启锚点_作战关卡["RA15"][1], 14)
            appear("生息演算干员费用够列表", 10)



            tap("两倍速")
                ssleep(15)

                Deploy7(6, point.生息演算_重启锚点_作战关卡["RA15"][2], 13)
        else
            log("非满buff,7人")
            --sx_deploy7(point.生息演算_重启锚点_作战关卡["RA15"], 2)
            Deploy7(7, point.生息演算_重启锚点_作战关卡["RA15"][1], 7)
            appear("生息演算干员费用够列表", 10)

            tap("两倍速")
                ssleep(15)

                Deploy7(1, point.生息演算_重启锚点_作战关卡["RA15"][2], 7)
        end
        appearTap("生息演算_重启锚点_战斗任务可领取", 3)
        ssleep(2)
        appearTap("生息演算_重启锚点_战斗任务2绿", 3)
        ssleep(2)
        appearTap("生息演算_重启锚点_战斗任务确认领取", 3)
        if not wait(function()
                if findOne("生息演算_重启锚点_战斗任务2红") then return true end
                tap("生息演算_重启锚点_战斗任务可领取")
                ssleep(2)
            end, 60) then
        end
        if findOne("生息演算_重启锚点_战斗退出") then
            tap("生息演算_重启锚点_战斗退出")
        else
            tap("生息演算_重启锚点_战斗任务可领取")
            appearTap("生息演算_重启锚点_战斗退出", 3)
        end
        appearTap("生息演算_重启锚点_确认终止", 3)
        if not wait(function()
                if findOne("生息演算_重启锚点_完成建设") then return true end
                tap("生息演算_重启锚点_完成建设")
            end, 10) then
        end


        --完成建设界面 ocr得分


        appearTap("生息演算_重启锚点_完成建设", 3)
        Relaunch_anchor_firsttime = false
    end
end



Relaunch_anchor.生息跳转 = function()
    path.跳转("首页")
    -- Tales_within_the_sand.掉线状态判断()
    tap("面板作战")
    if not wait(function()
            appearTap("主页长期探索", 0.2)
            appearTap("主页长期探索_生息演算_全部主题", 0.2)
            if appear("主页长期探索_生息演算_进入主题") then
                tap("主页长期探索_生息演算_重启锚点")
            end
            appearTap("主页长期探索_生息演算_进入主题", 0.2)
            if findOne("生息演算_重启锚点_主页进入开始建设") then return true end
        end, 10) then
        log(56)
        path.跳过剧情()
    end
    if findOne("生息演算_重启锚点_主页进入开始建设") then return true end
end

Relaunch_anchor.掉线状态判断 = function()
    log("生息掉线检测")

    if findOne("主页长期探索_生息演算_重启锚点") then
        tap("主页长期探索_生息演算_重启锚点")
        ssleep(1)
        tap("主页长期探索_生息演算_进入主题")
        return 重启锚点()
    end

    if findOne("生息演算关卡左上角退出") then
        -- 不清楚某些情况会没结束的
        if not wait(function()
                if findOne("生息演算_重启锚点_基地图标") then
                    return true
                end
                appearTap("生息演算关卡左上角退出", 0.1)
                tap("生息演算_确认按钮")
            end, 20) then
        end
        return 重启锚点()
    end
    if findOne("生息演算_重启锚点_开始行动") then
        tap("生息演算_全局_返回")
        return 重启锚点()
    end
    if findAny({
            "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
            "手机验证码登录", "生息演算_游戏设置页面", "生息演算_游戏设置弹窗",
        }) then
        path.跳转("首页")
        return 重启锚点()
    end
    --[[if not findAny({ "生息演算主页进入", "生息底栏烹饪按钮", "沙洲遗闻开启今日", }) then
        -- 未知页面
        --snapShot("/mnt/sdcard/test.png")
        restartapp(appid)
        path.跳转("首页")
        return 重启锚点()
    end]]
end

Relaunch_anchor.商店购买 = function()
    if not findAny({ "生息演算_重启锚点_主页进入开始建设", "生息演算繁荣馈赠判断" }) then
        Relaunch_anchor.生息跳转()
    end
    log("生息重启锚点商店购买")
    appear("生息演算_重启锚点_进入商店", 1)
    if not wait(function()
            if findOne("生息演算_重启锚点_商店界面") then return true end
            appearTap("生息演算_重启锚点_进入商店", 0.1)
        end, 5) then
    end

    disappear("正在提交反馈至神经", network_timeout)

    -- 防止各种掉帧等导致卡在领取等页面
    local 回到商店主页 = function()
        if not wait(function()
                if findOne("生息演算_重启锚点_商店界面") then return true end
                tap("商店顶栏")
                ssleep(0.2)
            end, 10) then
            return
        end
    end

    if not appear("生息演算_重启锚点_商店界面", 1) then
        log("未找到商店")
        return
    end
    local 物品横间距, 物品纵间距 = scale(516), scale(242)
    回到商店主页()
    local t = os.time()
    while true do
        if os.time() - t > 5 * 60 then -- 任务总时长5分钟
            log("商店任务超时")
            return
        end
        for x = 0, 2 do -- 3*3商品进行购买
            for y = 0, 2 do
                log(x, y)
                for i = 1, 7 do
                    回到商店主页()
                    local intX, intY = findMultiColor(scale(120) + x * 物品横间距, scale(515) + y * 物品纵间距,
                        scale(386) + x * 物品横间距, scale(555) + y * 物品纵间距,
                        "FFFFFF", scale(17) .. "|" .. scale(-2) .. "|575757|" .. scale(-100) .. "|" ..
                        scale(-5) .. "|5A5A5A", 0, 0.85)
                    if intX == -1 then break end
                    if not wait(function()
                            tap({ intX, intY })
                            ssleep(.6)
                            if findOne("购买物品面板") then return true end
                        end, 1.8) then
                    end
                    if findOne("生息演算_重启锚点_商店界面") then
                        log("未能进入商品，大概是识别错了")
                        break
                    end
                    -- 点击购买
                    if not wait(function()
                            if findOne("生息演算繁荣馈赠商店最多") then
                                tap("生息演算繁荣馈赠商店最多")
                                ssleep(0.2)
                            end
                            if findOne("生息演算繁荣馈赠支付") then
                                tap("生息演算繁荣馈赠支付")
                                ssleep(0.5)
                                disappear("正在提交反馈至神经", network_timeout)
                            end
                            if not findOne("购买物品面板") then return true end
                        end, 5) then
                    end
                    --disappear("正在提交反馈至神经", network_timeout)
                    if findOne("购买物品面板") then
                        log("未能购买，大概是钱花完了")
                        return true
                    end
                end
                log("开始下一个商品")
            end
        end
        回到商店主页()
        ssleep(.5)
        local sx = { screen.width * 0.8, screen.height * 0.5 }
        local oricol = getColor(sx[1], sx[2])
        path.swip_hd_shop()
        ssleep(.5)
        if getColor(sx[1], sx[2]) == oricol then
            log("大概滑动到底了吧~")
            return true
        end
    end
    return true
end


-- 生息干员摆放
sx_deploy7 = function(deploy_table, number)
    local number = number or 2
    for i = 1, number do
        if not wait(function()
                if findOne("生息演算干员费用够列表") then return true end
                if not findOne("生息演算_重启锚点_战斗退出") then
                    log("没找到退出，继续等待")
                end
            end, 30) then
            return false
        end
        if i > 3 then i = 3 end
        wait(function()
            if i>1 then

                appear("生息演算干员费用够列表", 10)
            end
            if i == 1 then
                Deploy7(7, deploy_table[i], 7)
            elseif i == 2 then
                Deploy7(1, deploy_table[i], 7)
            end


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

sx_deploy13 = function(deploy_table, number)
    local number = number or 2
    for i = 1, number do
        if not wait(function()
                if findOne("生息演算干员费用够列表") then return true end
                if not findOne("生息演算_重启锚点_战斗退出") then
                    log("没找到退出，继续等待")
                end
            end, 30) then
            return false
        end
        if i > 3 then i = 3 end
        wait(function()
            if i>1 then
                
                disappear("生息演算干员费用够列表", 10)
            end
            if i == 1 then
                Deploy7(1, deploy_table[i], 14)
            elseif i == 2 then
                Deploy7(6, deploy_table[i], 13)
            end


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

-- src: 紧则从左数第几个干员 松则从右数第几个干员
-- dst: 目标位置，格式{x,y,direction} direction: 上1 右2 下3 左4
-- total: 当前有几个干员，不同干员数影响干员位置
Deploy7 = function(src, dst, total)
    total = total or 1
    local max_op_width = scale(178) --  in loose mode, each operator's width
    local x1
    if total * max_op_width > screen.width then
        -- tight
        max_op_width = screen.width // total
        x1 = src * max_op_width - max_op_width // 2
    else
        -- loose
        -- x1 = screen.width - (total - src) * max_op_width - max_op_width // 2
        x1 = screen.width - src * max_op_width + max_op_width // 2
    end
    deploy(x1, dst[1], dst[2], dst[3],true)
end
