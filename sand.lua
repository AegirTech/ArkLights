-- ===========================================
--               生息演算
--               沙洲遗闻
-- ===========================================
reachFourthDay = false
Tales_within_the_sand = {}

path.生息演算沙中之火 = never_end_wrapper(path.沙中之火)

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
        log("未找到主页，从头开始")
        Tales_within_the_sand.生息跳转()
    end
    if not findOne("生息演算未结算_反") then
        log("存在未结算")
        tap("生息演算主页进入")
        if reachFourthDay or sand_no_delete then
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
        Tales_within_the_sand.开始演算()
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
            appearTap("主页长期探索", 0.1)
            appearTap("主页长期探索_生息演算", 0.1)
            if findOne("生息演算主页进入") then return true end
        end, 10) then
        log(55)
        path.跳过剧情()
    end
    if findOne("生息演算主页进入") then return true end
end

Tales_within_the_sand.切换难度 = function()
    if findOne("沙洲遗闻标准模式") then return true end
    if findOne("生息演算主页进入") and findOne("沙洲遗闻挑战模式") then
        tap("沙洲遗闻挑战模式")
        appearTap("沙洲遗闻切换确认")
        appear("生息演算主页进入", .5)
    end
end

Tales_within_the_sand.重置地图位置 = function()
    log("重置地图位置")
    tap("生息演算左上角返回")
    ssleep(.1)
    if not wait(function()
            if findOne("生息演算主页进入") then
                return true
            end
            tap("生息演算左上角返回")
            ssleep(.1)
        end, 5) then
    end
    if Tales_within_the_sand.检查代币数量() then
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

Tales_within_the_sand.开始演算 = function()
    log("开始演算")
    if findOne("生息演算主页进入") then
        Tales_within_the_sand.切换难度()
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

        Tales_within_the_sand.生息关卡进入("沙洲遗闻丰饶灌木林")

        if not appear("生息底栏烹饪按钮", 10) then
            return 沙洲遗闻()
        end
        Tales_within_the_sand.下一天()
        Tales_within_the_sand.下一天()
        Tales_within_the_sand.掉线状态判断()

        Tales_within_the_sand.敌袭1()
        Tales_within_the_sand.下一天()
        reachFourthDay = true
    end
    return Tales_within_the_sand.四到七天()
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
    if findOne("主页长期探索_生息演算") then
        tap("主页长期探索_生息演算")
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
            if findOne("生息底栏弹出页面") then tap("生息底栏更多_读取存档") end
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
        -- 未声明变量时候为第一次启动
        captureqqimagedeliver("INFO", "生息任务开始", "生息任务开始", true)
    end
    Prosperity_same_number = Prosperity_same_number or 0
    prosperity_temp = prosperity_temp or 0
    if sand_nostop then return end
    log("获取代币数量")
    if not findOne("生息演算主页进入") then
        return false
    end
    local nx = 0
    local text = ocro("生息演算代币范围")

    if text ~= nil then
        text = text:gsub(" ", "")
        text = text:gsub("O", "0")
        text = text:gsub("l", "1")
        nx = str2int(text:match("%d+"))
        log("识别结果：" .. text)
        log("匹配结果：" .. nx)
    else
        x = -1
        return false
    end

    --繁荣度和上一次一样的话，记录
    if prosperity_temp == nx then
        Prosperity_same_number = Prosperity_same_number + 1
    else
        Prosperity_same_number = 0
    end
    prosperity_temp = nx
    -- 连续5次没有繁荣增长,认为已打满,防止部分客户提前消耗了代币,无法打到82500,导致无法提前结束,释放设备
    local current_month = os.date("*t").month
    local maxpoint = 63700 + current_month * 24400

    if nx > maxpoint then
        nx = 0 -- 识别错误
    end
    if nx == maxpoint then
        log("代币数量大于" .. maxpoint)
        if cloud_get_task then
            log("云控上报")
            captureqqimagedeliver("INFO", "生息任务结束1", "繁荣值" .. nx, true)
            cloud.releaseDeviceByTaskInfo()
        else
            log("非云控")
            log("生息演算任务完成,繁荣值" .. nx)
        end
        return true
    end

    if sand_noincrease_stop and Prosperity_same_number > 5 then
        log("连续5次未增加")
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
        log("生息演算奇遇节点未找到底栏")
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
        log("生息演算奇遇节点未找到判断")
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
    for i = 1, 2 do
        local q = false
        if not wait(function()
                tap("沙洲遗闻奇遇确定")
                ssleep(.2)
                --[[if findOne("生息演算奇遇_右上角_资源不足") then
                    local tx = ocr("生息演算奇遇右上角ocr")
                    tx = table2string(tx)
                    if tx:find("不足") or tx:find("所") or tx:find("资源") then
                        tap("生息演算右上角生息日")
                        disappear("生息演算奇遇_右上角_资源不足", 3)
                        return true
                    end
                end]]
                --
                if findOne("沙洲遗闻奇遇标签") then
                    tap("沙洲遗闻奇遇标签")
                    log("奇遇缺少材料")
                    q = true
                    return true
                end
            end, 3.5) then
        end
        if q then break end
        if not wait(function()
                --[[if findOne("生息演算奇遇_右上角_资源不足") then
                    local tx = ocr("生息演算奇遇右上角ocr")
                    tx = table2string(tx)
                    if tx:find("不足") or tx:find("所") or tx:find("资源") then
                        tap("生息演算右上角生息日")
                        disappear("生息演算奇遇_右上角_资源不足", 3)
                        return true
                    end
                end]]
                local p = findOne("沙洲遗闻对话确定")
                if p then
                    tap(p)
                    if not wait(function()
                            --右上角出现标签就是完成了
                            if findOne("沙洲遗闻奇遇标签") then
                                tap("沙洲遗闻奇遇标签")
                                log("完成奇遇")
                                q = true
                                return true
                            end
                            if findOne("沙洲遗闻右边奇遇") then
                                return true
                            end
                            tap({ scale(1737), p[2] })
                            ssleep(.1)
                        end, 5) then
                        return true
                    end
                end
            end, 5) then
        end
        if q then break end
    end
    if not wait(function()
            if findOne("生息演算消磨时间") then tap("生息演算消磨时间") end
            if findOne("生息演算跳过当日确认") then tap("生息演算跳过当日确认") end
            if findOne("沙洲遗闻奇遇标签") then tap("沙洲遗闻奇遇标签") end
            if findOne("生息演算进入下一天") then tap("生息演算进入下一天") end
            if findOne("生息演算完成生存周期") then tap("沙洲遗闻开启今日") end
            appearTap("沙洲遗闻开启今日", .1)
            if findOne("沙洲遗闻开启今日") then
                ssleep(.3)
                tap("沙洲遗闻开启今日")
                return true
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
    appear("生息演算开始行动", 0.8)
    if not wait(function()
            tap("沙洲遗闻快捷编队")
            if not findOne("沙洲遗闻快捷编队") then return true end
        end, 3) then
        return
    end
    appear("沙洲遗闻编入队伍", 1)
    tap("生息演算编队清空选择")
    ssleep(.2)
    if not findOne("生息演算职业选择") then tap("生息演算职业选择") end
    if not appear("生息演算近卫选择", .5) then
        tap("生息演算近卫选择")
        appear("生息演算近卫选择", .5)
    end
    local oper_selected = 0
    for i = 1, 8 do
        tap("生息演算干员选择列表" .. i)
        oper_selected = oper_selected + 1
        ssleep(.1)
        if findOne("生息演算干员选择阻挡1") then
            tap("生息演算干员选择列表" .. i)
            oper_selected = oper_selected - 1
        end
        if oper_selected == 4 then break end
    end
    if not wait(function()
            if not findOne("沙洲遗闻编入队伍") then return true end
            tap("沙洲遗闻编入队伍")
        end, 3) then
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
    gesture({
        {
            point = { { screen.width * 0.95,  screen.height / 2 },
                { screen.width * 0.2,             screen.height / 2 },
                { screen.width * 0.2 - scale(10), screen.height / 2 },
                { screen.width * 0.2 + scale(10), screen.height / 2 },
                { screen.width * 0.2 - scale(10), screen.height / 2 },
                { screen.width * 0.2 + scale(10), screen.height / 2 } },
            start = 0,
            duration = 500,
        },
    })
    sleep(550)

    gesture({
        {
            point = { { screen.width * 0.95,  screen.height / 2 },
                { screen.width * 0.2,             screen.height / 2 },
                { screen.width * 0.2 - scale(10), screen.height / 2 },
                { screen.width * 0.2 + scale(10), screen.height / 2 },
                { screen.width * 0.2 - scale(10), screen.height / 2 },
                { screen.width * 0.2 + scale(10), screen.height / 2 } },
            start = 0,
            duration = 500,
        },
    })
    sleep(550)

    -- 总有滑动不到底的情况，滑动2次

    for i = 1, 4 do
        if not wait(function()
                if findOne("生息演算干员费用够列表1") then
                    local p = point["沙洲遗闻敌袭1部署列表" .. i]
                    log(p)
                    deploy(screen.width - scale(210), p[1], p[2], 4)
                    return true
                end
                if not findOne("生命值") then
                    log(462)
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

Tales_within_the_sand.生息关卡进入 = function(关卡)
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

Tales_within_the_sand.下一天 = function()
    log("下一天")
    Tales_within_the_sand.掉线状态判断()

    if not appear("生息底栏烹饪按钮", 5) then
        return
    end
    if not findOne("生息演算消磨时间") then
        tap("生息演算右上角生息日")
    end
    if not wait(function()
            if findOne("生息演算消磨时间") then tap("生息演算消磨时间") end
            if findOne("生息演算跳过当日确认") then tap("生息演算跳过当日确认") end
            if findOne("沙洲遗闻奇遇标签") then tap("沙洲遗闻奇遇标签") end
            if findOne("生息演算进入下一天") then tap("生息演算进入下一天") end
            if findOne("生息演算完成生存周期") then tap("沙洲遗闻开启今日") end
            appearTap("沙洲遗闻开启今日", .1)
            if findOne("沙洲遗闻开启今日") then
                if not wait(function()
                        tap("沙洲遗闻开启今日")
                        if not findOne("沙洲遗闻开启今日") then return true end
                    end, 7) then
                    return false
                end
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
    ssleep(.2)
end

Tales_within_the_sand.商店购买 = function()
    if not findAny({ "生息演算主页进入", "生息演算繁荣馈赠判断" }) then
        Tales_within_the_sand.生息跳转()
    end
    log("生息商店购买")
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
        log("未找到商店")
        return
    end
    local 物品横间距, 物品纵间距 = point["商店物品间隔"][1], point["商店物品间隔"][2]
    回到商店主页()
    t = os.time()
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
                            if findOne("商店购买页面") then return true end
                        end, 1.8) then
                    end
                    if findOne("沙洲遗闻商店界面") then
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
                            if not findOne("商店购买页面") then return true end
                        end, 5) then
                    end
                    --disappear("正在提交反馈至神经", network_timeout)
                    if findOne("商店购买页面") then
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
