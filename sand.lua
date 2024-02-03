-- ===========================================
--               生息演算
--               沙洲遗闻
-- ===========================================

沙洲遗闻 = function()
    log("沙洲遗闻开始")
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
        生息跳转()
    end
    if findOne("生息演算未结算") then
        log("存在未结算")
        tap("生息演算主页进入")
        删除存档()
    end
    掉线状态判断()
    if 检查代币数量() then
        return true
    end
    开始演算()
end

生息跳转 = function()
    path.跳转("首页")
    tap("面板作战")
    disappear("主页", 3)
    tap("主页长期探索")
    if not wait(function()
            tap("主页长期探索")
            appear("主页长期探索_生息演算", 3)
            tap("主页长期探索_生息演算")
            if findOne("生息演算主页进入") then return true end
        end, 5) then
        log(55)
        path.跳过剧情()
    end
    if findOne("生息演算主页进入") then return true end
    log(1)
end

开始演算 = function()
    log("开始演算")
    if findOne("生息演算主页进入") then
        tap("生息演算主页进入")
    end
    -- 剧情部分
    会聚之地()
    appear("生息底栏烹饪按钮", 3)
    掉线状态判断()
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
        生息演算奇遇节点()
    end
    掉线状态判断()

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
        生息关卡进入("生息演算灌木区")

        if not appear("生息底栏烹饪按钮", 10) then
            return 沙洲遗闻()
        end

        掉线状态判断()

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
        生息关卡进入("生息演算捕猎区")
    end

    -- 检查
    if not appear("生息底栏烹饪按钮", 10) then
        return 沙洲遗闻()
    end

    -- 结算
    下一天至结算()

    -- 退出活动重开
    if appear("生息底栏烹饪按钮", 5) then
        删除存档()
    else
        return 沙洲遗闻()
    end
    log("结束演算")

    -- 重开
    return 沙洲遗闻()
    -- ssleep(1000)
end

开始演算_新手教程跳过 = function()

end

掉线状态判断 = function()
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
        return path.生息沙洲遗闻()
    end
    if findOne("生息演算开始行动") then
        tap("生息演算_全局_返回")
        return path.生息沙洲遗闻()
    end
    if findAny({
            "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
            "手机验证码登录",
        }) then
        return path.生息沙洲遗闻()
    end
    if not findAny({ "生息演算主页进入", "生息底栏烹饪按钮", }) then
        -- 未知页面
        return path.生息沙洲遗闻()
    end
end

删除存档 = function()
    log("删除存档")
    掉线状态判断()
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
        删除存档()
    end
end

检查代币数量 = function()
    log("获取代币数量")
    if not findOne("生息演算主页进入") then
        return false
    end
    local nn = ocr("生息演算代币范围")
    if not nn then
        return false
    end

    local nx = str2int(get(nn, 1, "text"))
    if nx > 80000 then
        log("代币数量大于80000")
        return true
    end
end

生息演算地图缩放 = function(min)
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

生息演算奇遇节点 = function()
    掉线状态判断()
    生息演算地图缩放(true)
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

生息关卡进入 = function(关卡)
    掉线状态判断()
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
        end, 5) then
    end

    -- 退出关卡
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
end

会聚之地 = function()
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

下一天至结算 = function()
    log("下一天至结算")
    掉线状态判断()
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
    end
    if not wait(function()
            if findOne("生息底栏烹饪按钮") then
                return true
            end
            tap("生息演算总结页面")
            tap("生息演算_确认按钮")
            tap("生息演算第四天_开启")
        end, 30) then
    end
    log("下一天至结算结束")
end
