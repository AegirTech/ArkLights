-- ===========================================
--               生息演算
--               沙洲遗闻
-- ===========================================
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
        log("未找到主页，从头开始")
        Tales_within_the_sand.生息跳转()
    end
    if not findOne("生息演算未结算_反") then
        log("存在未结算")
        tap("生息演算主页进入")
        Tales_within_the_sand.删除存档()
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
    if not wait(function()
            if findOne("生息演算_公告弹窗") then
                tap("生息演算_公告弹窗关闭")
            end
            if findAny({ "生息演算_主页导航", "生息演算_游戏主页", "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
                    "手机验证码登录", "生息演算_游戏设置页面", "生息演算_游戏设置弹窗", "主页长期探索", "主页长期探索_生息演算", "生息演算主页进入" }) then
                return true
            end
        end, 60) then
        restartapp(appid)
        captureqqimagedeliver("INFO", "即将重启游戏", "导航失败", true)
    end
    path.跳转("首页")
    -- Tales_within_the_sand.掉线状态判断()
    tap("面板作战")
    -- disappear("主页", 3)
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

Tales_within_the_sand.开始演算 = function()
    log("开始演算")
    if findOne("生息演算主页进入") then
        tap("生息演算主页进入")
    end
    -- 剧情部分
    Tales_within_the_sand.会聚之地()
    appear("生息底栏烹饪按钮", 3)
    Tales_within_the_sand.掉线状态判断()
    if sand_missions then
        if not appear("生息底栏烹饪按钮", 10) then
            return 沙洲遗闻()
        end
        -- 重置地图位置
        if not wait(function()
                tap("生息演算左上角返回")
                if findOne("生息演算主页进入") then return true end
            end, 5) then
        end
        if not wait(function()
                if findOne("生息底栏烹饪按钮") then return true end
                tap("生息演算主页进入")
                ssleep(0.3)
            end, 5) then
        end
        Tales_within_the_sand.生息演算奇遇节点()
    end
    Tales_within_the_sand.掉线状态判断()

    if sand_checkpoint then
        if not appear("生息底栏烹饪按钮", 10) then
            return 沙洲遗闻()
        end
        -- 重置地图位置
        if not wait(function()
                tap("生息演算左上角返回")
                if findOne("生息演算主页进入") then return true end
            end, 5) then
        end
        if not wait(function()
                if findOne("生息底栏烹饪按钮") then return true end
                tap("生息演算主页进入")
                ssleep(0.3)
            end, 5) then
        end

        -- 进入任意一个关卡
        Tales_within_the_sand.生息关卡进入("生息演算灌木区")
        if not appear("生息底栏烹饪按钮", 10) then
            return 沙洲遗闻()
        end

        Tales_within_the_sand.掉线状态判断()

        -- 重置地图位置
        if not wait(function()
                tap("生息演算左上角返回")
                if findOne("生息演算主页进入") then return true end
            end, 5) then
        end
        if not wait(function()
                if findOne("生息底栏烹饪按钮") then return true end
                tap("生息演算主页进入")
                ssleep(0.3)
            end, 5) then
        end
        Tales_within_the_sand.生息关卡进入("生息演算捕猎区")
    end

    -- 检查
    if not appear("生息底栏烹饪按钮", 10) then
        return 沙洲遗闻()
    end

    -- 结算
    Tales_within_the_sand.下一天至结算()

    -- 退出活动重开
    if appear("生息底栏烹饪按钮", 5) then
        Tales_within_the_sand.删除存档()
    else
        -- 次数统计
        All_count = All_count or 0
        All_count = All_count + 1
        return 沙洲遗闻()
    end
    log("结束演算")

    -- 重开
    return 沙洲遗闻()
    -- ssleep(1000)
end

Tales_within_the_sand.掉线状态判断 = function()
    if findOne("生息演算_其他界面1") then
        return 沙洲遗闻()
    end
    if findOne("主页长期探索_生息演算") then
        tap("主页长期探索_生息演算")
        return 沙洲遗闻()
    end
    if findAny({ "生息演算会聚之地判断", }) then
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
                if findOne("生息底栏烹饪按钮") then
                    return true
                end
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
    if not findAny({ "生息演算主页进入", "生息底栏烹饪按钮", }) then
        -- 未知页面
        restartapp(appid)
        path.跳转("首页")
        return 沙洲遗闻()
    end
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
    -- local nn = ocr("生息演算代币范围")
    -- if not nn then
    --     return false
    -- end

    local nx = 0
    local handle = createOcr()
    if handle ~= nil then
        local text = ocrTextEx(handle, point["生息演算代币范围"][1],
            point["生息演算代币范围"][2],
            point["生息演算代币范围"][3],
            point["生息演算代币范围"][4])
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
        releaseOcr(handle)
    else
        return false
    end

    -- local nx = str2int(get(nn, 1, "text"))
    --繁荣度和上一次一样的话，记录
    if prosperity_temp == nx then
        Prosperity_same_number = Prosperity_same_number + 1
    else
        Prosperity_same_number = 0
    end
    prosperity_temp = nx
    All_count = All_count or 0
    -- 连续5次没有繁荣增长,认为已打满,防止部分客户提前消耗了代币,无法打到82500,导致无法提前结束,释放设备
    if nx > 120000 then
        nx = 0 -- 识别错误
    end
    if sand_distrust_ocr and nx >= 112500 then
        log("代币数量大于112500")
        if cloud_get_task then
            log("云控上报")
            captureqqimagedeliver("INFO", "生息任务结束1", "生息任务执行次数" .. All_count .. "繁荣值" .. nx, true)
            releaseDeviceByTaskInfo()
        else
            log("非云控")
            stop("生息演算任务完成,任务执行次数" .. All_count .. "繁荣值" .. nx, '', true, false)
        end
        return true
    end

    if sand_noincrease_stop and Prosperity_same_number > 5 then
        log("连续5次未增加")
        if cloud_get_task then
            log("云控上报")
            captureqqimagedeliver("INFO", "生息任务结束2", "生息任务执行次数" .. All_count .. "繁荣值" .. nx, true)
            releaseDeviceByTaskInfo()
        else
            log("非云控")
            stop("生息演算任务完成,总运行次数" .. All_count .. "繁荣值" .. nx, '', true, false)
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

Tales_within_the_sand.生息关卡进入 = function(关卡)
    Tales_within_the_sand.掉线状态判断()
    log(关卡)
    if not appear(关卡, 3) then
        return
    end
    tap(关卡)
    -- 进入关卡
    if not wait(function()
            appearTap("生息演算进入关卡", 0.1)
            appearTap("生息演算开始行动", 0.1)
            appearTap("生息演算开始行动红色确认", 0.1)
            if findOne("生息演算关卡左上角退出") then
                return true
            end
        end, 10) then
    end

    -- 退出关卡
    if not wait(function()
            if findOne("生息底栏烹饪按钮") then
                return true
            end
            appearTap("生息演算关卡左上角退出", 0.1)
            -- tap("生息演算_全局_返回")
            tap("生息演算_确认按钮")

            if findOne("生息演算主页进入") then
                return true
            end

            if findOne("生息底栏烹饪按钮") then
                return true
            end
        end, 30) then
    end
end

Tales_within_the_sand.会聚之地 = function()
    log("会聚之地")
    -- 等待加载到会聚之地
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

Tales_within_the_sand.下一天至结算 = function()
    log("下一天至结算")
    Tales_within_the_sand.掉线状态判断()
    if not appear("生息底栏烹饪按钮", 5) then
        return
    end
    t = os.time()
    while true do
        if os.time() - t > 30 then -- 防止超时
            log("超时")
            break
        end
        local m = 0
        if not findOne("生息演算消磨时间") then
            tap("生息演算右上角生息日")
        end
        appearTap("生息演算消磨时间", 0.1)
        appearTap("生息演算跳过当日确认", 0.1)
        appearTap("生息演算跳过当日确认", 0.1)
        appearTap("生息演算进入下一天", 0.1)
        appearTap("生息演算下一天_勾", 0.1)
        appearTap("生息演算第四天_开启", 0.1)
        if findOne("生息演算总结页面") then
            m = m + 1
        end
        if findOne("生息演算总结页面2") then
            m = m + 1
        end
        if findOne("生息演算总结页面2") then
            m = m + 1
        end
        if m > 1 then
            break
        end

        if findOne("生息演算主页进入") then
            break
        end
        if findOne("生息演算_其他界面1") then
            return true
        end
    end
    if not wait(function()
            if findOne("生息底栏烹饪按钮") then
                return true
            end
            tap("生息演算总结页面")
            tap("生息演算_确认按钮")
            tap("生息演算第四天_开启")
            if findOne("生息演算主页进入") then
                return true
            end
            if findOne("生息演算_其他界面1") then
                return true
            end
        end, 30) then
    end
    log("下一天至结算结束")
end

Tales_within_the_sand.商店购买 = function()
    if not findAny({ "生息演算主页进入", "生息演算繁荣馈赠判断" }) then
        Tales_within_the_sand.生息跳转()
    end
    log("生息商店购买")
    appear("生息演算繁荣馈赠", 1)
    if not wait(function()
            if findOne("生息演算繁荣馈赠判断") then return true end
            appearTap("生息演算繁荣馈赠", 0.1)
        end, 5) then
    end

    disappear("正在提交反馈至神经", network_timeout)

    -- 防止各种掉帧等导致卡在领取等页面
    local 回到商店主页 = function()
        if not wait(function()
                if findOne("生息演算繁荣馈赠判断") then return true end
                tap("商店顶栏")
                ssleep(0.2)
            end, 10) then
            return
        end
    end

    local 向左滑动 = function()
        gesture({
            {
                point = { { screen.width * 0.95, screen.height / 2 }, { screen.width * 0.95 - point["商店滑动距离"][1], screen.height / 2 } },
                start = 0,
                duration = 1500,
            },
        }) -- 滑动大约3个商品的距离
    end

    log("111")
    if not findOne("生息演算繁荣馈赠判断") then
        log("未找到商店")
        return
    end
    local 初始物品, 物品横间距, 物品纵间距 = point["商店初始物品"], point["商店物品间隔"][1], point["商店物品间隔"][2]
    回到商店主页()
    t = os.time()
    while true do
        if os.time() - t > 5 * 60 then -- 任务总时长5分钟
            log("商店任务超时")
            return
        end
        for x = 0, 2 do -- 3*3商品进行购买
            for y = 0, 2 do
                local gt = 0
                ::startshop::
                local sx = { 初始物品[1] + x * 物品横间距, 初始物品[2] + y * 物品纵间距 }
                log(x, y, sx[1], sx[2])
                回到商店主页()
                -- ssleep(1000)
                ssleep(0.5)
                if not findOne("生息演算繁荣馈赠判断") then
                    log("商店任务结束")
                    return
                end -- 防止跳到其他页面
                -- 点击商品，进入购买页面判断
                if not wait(function()
                        tap(sx)
                        if findOne("商店购买页面") then return true end
                    end, 1) then
                end
                if findOne("生息演算繁荣馈赠判断") then
                    log("未能进入商品，大概是售空了吧~")
                    goto continue
                end

                -- 点击购买
                if not wait(function()
                        appearTap("生息演算繁荣馈赠商店最多", 0.1)
                        ssleep(0.2)
                        appearTap("生息演算繁荣馈赠支付", 0.1)
                        if not findOne("商店购买页面") then return true end
                    end, 3) then
                end

                if findOne("商店购买页面", 1) then
                    log("购买失败，大抵是没钱了吧~")
                    return true
                end

                disappear("正在提交反馈至神经", network_timeout)

                if x == 0 and y == 1 and gt < 7 then
                    gt = gt + 1
                    goto startshop -- 针对信物修复
                end

                ::continue::
                回到商店主页()
                log("开始下一个商品")
            end
        end
        回到商店主页()
        ssleep(1)
        if not findOne("生息演算繁荣馈赠判断") then return end -- 防止跳到其他页面
        local sx = { screen.width * 0.8, screen.height * 0.5 }
        local oricol = getColor(sx[1], sx[2])
        向左滑动()
        ssleep(3)
        if getColor(sx[1], sx[2]) == oricol then
            log("大概滑动到底了吧~")
            return true
        end
    end
    return true
end
