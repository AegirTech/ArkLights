-- ===========================================
--               界园肉鸽相关
-- ===========================================


sui = {}

sui.跳转 = function()
    zl_eight_daily()

    local in_fight_return = ''
    local restart = function()
        toast(in_fight_return or '重开')
        restartapp(appid)
        ssleep(3)
        if not request_memory_clean() then
            path.界园前瞻投资()
        else
            path.跳转("首页")
        end
    end

    local 作战结算返回 = function()
        log("界园_作战失败，准备返回")
        wait(function()
            if findOne("界园_常规行动") then
                ssleep(3)
                if findOne("界园_常规行动") then
                    return true
                end
            end
            if findAny({
                    "面板", "活动公告返回", "签到返回", "签到返回黄",
                    "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
                }) then
                return true
            end
            tap("新战略确认")
        end, 20)
    end

    --判断是否在其他界面
    local jumpout
    if findOne("战略返回") then path.fallback.战略返回() end
    if findOne("暂停中") and findOne("生命值") then restartapp(appid) end
    if findOne("界园_每层通宝确认") then
        if not wait(function()
                if findOne("界园_常规行动") then return true end
                findTap("界园_每层通宝确认")
                tap('战略返回')
                tap("新战略确认")
                ssleep(0.3)
            end, 5) then
            return restart()
        end
    end
    if findAny({ "界园_主页干员详情", "界园_主页干员详情蓝色" }) then back() end
    if findOne("界园_作战失败结算") then
        return 作战结算返回()
    end
    -- 先导航到常规行动
    zl_navigation('界园_常规行动', '界园_进入主题')

    --肉鸽 等级源石锭检查
    界园肉鸽完成 = zl_level_coin_inquire('界园_常规行动', '界园_等级检测范围', '界园_源石锭检测范围')
    if 界园肉鸽完成 then
        return
    end

    -- 放弃探索
    if findOne("界园_戛然而止") then
        if not findOne("界园_放弃探索") then
            if not wait(function()
                    if not findOne("界园_戛然而止") then return true end
                    tap("界园_探索开始")
                end, 5) then
                return
            end
            if not wait(function()
                    if findOne("界园_常规行动") then return true end
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
        else
            if not wait(function()
                    if findOne("返回确认界面") then return true end
                    tap("界园_放弃探索")
                end, 5) then
                log(2608)
                -- 无法直接放弃的情况 不处理
                if not appear("界园_常规行动", 5) then
                    log(2609)
                    return
                end

                if not wait(function()
                        if findOne("界园_常规行动") then return true end
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
        end
        if not wait(function(reset_wait_start_time)
                if findOne("正在提交反馈至神经") then
                    reset_wait_start_time()
                end
                if findOne("返回确认界面") then
                    tap("右右确认")
                    return
                end

                if findAny({ "界园_主页干员详情", "界园_主页干员详情蓝色" }) then
                    log(2634)
                    back()
                    ssleep(.5)
                end

                tap("新战略确认")
                if findOne("界园_常规行动") and not findOne("界园_放弃探索") then
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
            if findAny({ "界园_主页干员详情", "界园_主页干员详情蓝色" }) then
                log(2690)
                back()
                ssleep(.5)
            end
            if time() - t > 2 * 1000 then --第一次时候，需要选择难度等级
                ssleep(1)
                t = time()
                log('选择一次难度等级')
                tap({ scale(1759), scale(567) })
            end
            ssleep(.8)
        end, 60) then
        -- 初始选难度
        tap('难度选择确认')

        return
    end
    if jumpout then return end
    log("跳转界园完毕")
end

sui.点天赋 = function()
    if not wait(function()
            tap("战略确认")
            tap("界园_进入天学识页面")
            if findOne("界园_学识页面") then return true end
            ssleep(.5)
        end, 20) then
        return
    end

    ssleep(.5)
    local y坐标 = { scale(300), scale(489), scale(692) }
    local 开始x坐标 = scale(130)

    for i = 1, 3 do
        local ty = y坐标[i]
        log("开始x坐标", 开始x坐标, "ty", ty)
        while 开始x坐标 < (screen.width - scale(100)) do
            log("点击坐标", 开始x坐标, ty)
            local 点击前采样 = sample("界园_学识", 0.5)
            tap({ 开始x坐标, ty })
            ssleep(.5)
            if not findOne(点击前采样) then
                appearTap("界园_学识升级按钮", 2)
            end
            开始x坐标 = 开始x坐标 + scale(70)
            if findOne("界园_学识数量不足") then
                log("学识数量不足，退出")
                return
            end
        end
        开始x坐标 = scale(130)
    end
end

sui.战斗后领取 = function()
    local drop_page = false
    if not wait(function()
            if not drop_page then tap("战略确认") end
            if findOne("界园_战略帮助") then drop_page = true end
            if zl_only_coin then
                local x = findAny({ "界园_不要了列表1", "界园_不要了列表2" })
                log(2516, x)
                tap(x)
                if not wait(function()
                        tap(findAny({ "界园_不要了确认列表1", "界园_不要了确认列表2" }))
                        if findAny({ "战略返回", "界园_战略帮助" }) then return true end
                    end, 2) then
                end
            end
            local x = appear({
                "界园_源石锭收下", "界园_通宝收下",
                "界园_招募卷收下", "界园_通宝收下2",
            })
            log(2555, x)
            tap(x)
            if x == "界园_通宝收下2" then
                appearTap("界园_通宝交换左", 5)
                disappear("界园_通宝交换左")
            end

            findTap("通宝替换确认")

            -- 误触到招募券处理
            if findOne("确认招募") then
                -- 放弃招募
                if zl_only_coin then
                    if not wait(function()
                            if not findOne("确认招募") then return true end
                            tap("放弃招募")
                        end, 5) then
                        return
                    end

                    if not wait(function()
                            if findOne("编队") then return true end
                            tap("右右确认")
                        end, 5) then
                        return
                    end
                else
                    -- 招募
                    if findOne("确认招募") then
                        local start_time = time()
                        if not wait(function()
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
                                tap("近卫招募列表" .. 1)
                                findTap("确认招募")
                                tap("开包skip")
                                findTap("通宝替换确认")
                            end, 10) then
                            return
                        end
                    end
                end
            end

            if findOne("放弃招募") and not findOne("确认招募") then
                if not wait(function()
                        if not findOne("放弃招募") then return true end
                        tap("放弃招募")
                    end, 5) then
                    return
                end
                if not wait(function()
                        if findOne("编队") then return true end
                        tap("右右确认")
                    end, 5) then
                    return
                end
            end

            if not findOne("战略返回") then
                if not appear({ "战略返回", "界园_战略帮助" }) then
                    tap("战略确认")
                end
            end
            -- if disappear("战略返回",0.5) then return true end
            if findAny({ "界园_常规行动", "界园_战略帮助" }) and not findOne("确认招募") then
                return true
            end
        end, 30) then
        return false
    end
    return true
end

sui.招募处理 = function()
    log(1090)
    -- 第2人
    for i = 1, 2 do
        local tj = appear({ "界园_辅助招募卷", "界园_医疗招募卷" })
        log(1091, tj, "不招募")
        if not tj then
            log(1094, "没有招募卷")
            break
        end
        if not wait(function()
                tap(tj)
                tap("招募说明关闭")
                if findOne("确认招募") then return true end
            end, 10) then
            return
        end
        appear('战略助战')
        if not wait(function()
                tap("放弃招募")
                if findOne("剿灭说明") then tap("剿灭说明") end
                if not findOne("确认招募") then return true end
            end, 10) then
            return
        end

        if not wait(function()
                tap("右右确认")
                if findOne("剿灭说明") then tap("剿灭说明") end
                if findOne("肉鸽_右上角希望") then return true end
            end, 10) then
            return
        end
    end
    ssleep(.1)
    log(1095)
    log('招募近卫')
    if not wait(function()
            tap("界园_近卫招募卷")
            tap("招募说明关闭")
            if not findOne("肉鸽_右上角希望") and not findOne("战略返回") then
                return true
            end
            ssleep(0.2)
        end, 10) then
    end
    disappear({ "肉鸽_右上角希望", "战略返回" })
    if not wait(function()
            if findAny({ "肉鸽_右上角希望" }) then
                log(26)
                return true
            end
            if findOne("返回确认界面") then
                log(27)
                tap("左取消")
                disappear("返回确认界面")
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
                zl_help_fight(0, '肉鸽_右上角希望', "界园")
            else
                stop("请设置近卫干员序号(1~12)", '', true, false)
            end
        end, 120) then
        return
    end
end

sui.不招募 = function()
    appear("肉鸽_右上角希望")
    for i = 1, 3 do
        local tj = appear({ "界园_辅助招募卷", "界园_近卫招募卷", "界园_医疗招募卷" })
        log(1091, tj, "不招募")
        if not tj then
            log(1094, "没有招募卷")
            return
        end
        if not wait(function()
                tap(tj)
                tap("招募说明关闭")
                if findOne("确认招募") then return true end
            end, 10) then
            return
        end
        appear('战略助战')
        if not wait(function()
                tap("放弃招募")
                if findOne("剿灭说明") then tap("剿灭说明") end
                if not findOne("确认招募") then return true end
            end, 10) then
            return
        end

        if not wait(function()
                tap("右右确认")
                if findOne("剿灭说明") then tap("剿灭说明") end
                if findOne("肉鸽_右上角希望") then return true end
            end, 10) then
            return
        end
    end
end

sui.不期而遇处理 = function(战略帮助)
    local 战略帮助 = 战略帮助 or "界园_战略帮助"
    log("进入不期而遇")
    disappear("界园_战略帮助")
    if not wait(function()
            if findOne("界园_不期而遇加载完成") then return true end
            tap("战略确认")
        end, 15) then
        return --减少重启次数
    end

    --判断不期而遇事件，并处理
    log('处理不期而遇事件')
    local ocr次数 = 0
    if not wait(function()
            local x = function()
                local incident
                local t = time()
                if not wait(function()
                        if ocr次数 % 2 == 0 then
                            incident = ocrex("界园_不期而遇关卡ocr范围")
                        else
                            incident = ocr("界园_不期而遇关卡ocr范围")
                        end
                        ocr次数 = ocr次数 + 1
                        if time() - t > 1000 then --不期而遇事件，偶尔下面的 '√' 会一直存在，间隔点击一次
                            t = time()
                            if not findOne('萨米_希望源石锭界面') then
                                tap({ scale(960), scale(935) }) --更上面一点，防止误触
                            end
                        end
                        if incident[1] then return true end
                        if findOne(战略帮助) then return true end
                        ssleep(.3)
                    end, 8) then
                    return false
                end
                if not incident[1] then return false end
                local str = incident[1].text
                log('事件名字：', str)
                if findOne('萨卡兹_不期而遇确认') then tap("萨卡兹_不期而遇确认点击") end
                if string.finds(str, { "地", "地镇" }) then -- 二选第一个 或者 三选第二个
                    if zl_event_solve(8, 战略帮助) then return true end
                elseif string.finds(str, { "食", "餐", "廊", "来者", "不拒" }) then -- 三选第三个 如 饕餮廊
                    if zl_event_solve(4, 战略帮助) then return true end
                elseif string.finds(str, { "偏安", "安", "师", "女", "相会", "会", }) then -- 二选第二个 或者1选1
                    if zl_event_solve(2, 战略帮助) then return true end
                elseif string.finds(str, { "护鸭", "金刚", "金则" }) then -- 二选第二个 或者3选2
                    if zl_event_solve(5, 战略帮助) then return true end
                elseif string.finds(str, { "传讯", }) then -- 三选第一个
                    if zl_event_solve(7, 战略帮助) then return true end
                elseif string.finds(str, { "路", "味" }) then -- 四选第一个
                    if zl_event_solve(10, 战略帮助) then return true end
                end
                ssleep(.5)
            end
            if x() then return true end
            if findOne(战略帮助) then return true end
        end, 30) then
        return false
    end
end

sui.战斗开始 = function()
    --检查作战关卡名字
    log(3306)
    if not zl.fight_name_ocr("界园") then return end
    toast(now_fight_name)
    ssleep(1)
    if not wait(function()
            if findOne("快捷编队") then return true end
            tap("界园_作战_进入")
        end, 5) then
        log(3302, "无法进入")
        zl_repos_path('界园_放弃探索')
    end
    log(3307)
    if not wait(function()
            if findOne("确认招募") then return true end
            tap("快捷编队")
        end, 10) then
        return
    end
    log(3309)
    if not wait(function()
            if findOne("攻击范围") and
                (zl_skill_idx ~= 2 or zl_skill_idx == 2 and findOne("战略二技能")) then
                --tap("近卫招募列表2") --第2个干员
                --ssleep(.2)
                --tap("近卫招募列表3") --第3个干员
                --会把二战新招募的干员带上，如果招募了高费的导致下错人
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
    log(3312)
    if not wait(function()
            if not findOne("确认招募") then return true end
            tap("确认招募")
        end, 10) then
        return
    end

    if not appear("快捷编队") then return end
    log(3319)
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
    log(3390)
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
    log(3394)
    -- 部署干员到关卡位置 只部署一个人的
    zl_deploy(point.界园_作战关卡[now_fight_name], 1)

    appear("生命值")
    log(3395)
    local last_time_see_life = time()
    local skill_times = 0
    if not wait(function()
            if findOne("返回确认界面") then tap("左取消") end
            if findOne("暂停中") then
                tap("开包skip")
                disappear("暂停中")
            end
            if findOne("生命值") then last_time_see_life = time() end
            -- 超过3秒没看到生命值
            if time() - last_time_see_life > 5000 then
                tap("战略确认")
                log(3396, "超过3秒没看到生命值")
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
            ssleep(0.5)
        end, 300) then
        log(3399)
        return restartapp(appid)
    end
    log(3400)
end

sui.放弃作战 = function()
    --检查作战关卡名字
    ssleep(1)
    if not wait(function()
            if findOne("快捷编队") then return true end
            tap("界园_作战_进入")
        end, 5) then
        log(3302, "无法进入")
        zl_repos_path('界园_放弃探索')
    end

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
            findTap("界园_无干员进入")
            if findOne("单选确认框") then return true end
            if findOne("生命值") then return true end
        end, 60) then
        return
    end

    if not findOne("生命值") then return end
    log(3307)
    -- 退出游戏，等待回到主线
    if not wait(function()
            tap("界园_左上角退出游戏")
            ssleep(0.5)
            if findOne("界园_放弃游戏") then
                log(3309)
                tap("界园_放弃游戏")
                return true
            end
        end, 60) then
        return
    end

    if not wait(function()
            if findOne("肉鸽_右上角希望") then return true end
            tap("右确认")
            ssleep(1)
        end, 60) then
        return
    end
end

path.界园前瞻投资 = function()
    log('start 界园')
    -- 肉鸽每8小时做日常
    sui.跳转()

    -- 开始探索 一路按到 招募干员
    -- if not wait(function(reset_wait_start_time)
    --         if findOne("界园_招募界面") then return true end
    --         if findOne("正在提交反馈至神经") then reset_wait_start_time() end
    --         tap("新战略确认")
    --         ssleep(.3)
    --     end, 10) then
    --     return
    -- end

    if not appear("肉鸽_右上角希望", 10) then
        return
    end

    local x_position = str2int(zl_team_position_sui, 1)
    while x_position > 4 do
        ssleep(0.5)
        path.swip_hd_shop(false, scale(1704))
        ssleep(0.5)
        x_position = x_position - 4
    end
    local t_position = zl_team_position_sui == str(x_position) and zl_team_position_sui or str(x_position)

    if not wait(function(reset_wait_start_time)
            if findOne("界园_选择招募一阶段完成") then return true end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
            tap('萨卡兹_蓝图分队位置列表' .. t_position)
            ssleep(1)--太快了直接选错招募券组合
        end, 10) then
        return
    end
    local page = nil
    if not zl_only_coin then
        -- 会出额外藏品
        log(1056)
        if appear("界园_额外藏品选择页面", 5) and not appear("界园_选择招募卷阶段", 0.5) then
            log(10562)
            ssleep(0.2)
            appear("界园_藏品选择横线", 5)
            ssleep(0.1)
            page = sample("界园进度")
            local best = 2
            for i = 1, 3 do
                local fret = find_color("界园_藏品范围" .. i, "C82A36", 0, 0.8)
                log(1057, i, fret)
                local fretb = find_color("界园_藏品范围" .. i, "28BFE5")
                log(1058, fretb)
                if not fret and fretb then
                    best = i
                    log(1059, best)
                end
            end
            if not wait(function(reset_wait_start_time)
                    if findOne("界园_选择招募卷阶段") then return true end
                    if not findOne(page) then return true end
                    tap('界园_藏品点击列表' .. best)
                    tap('界园_藏品点击列表' .. best)
                    ssleep(0.5)
                end, 10) then
            end
        end
    end

    ssleep(0.5)
    if not wait(function(reset_wait_start_time)
            -- if findOne("界园_选择招募二阶段") then return true end
            if findOne("界园_选择招募最后阶段") then return true end
            if findAny({
                    "战略助战", "放弃招募", "剿灭说明",
                }) then
                return true
            end
            tap("界园_下一步")
            ssleep(0.1)
        end, 10) then
    end
    -- if not wait(function(reset_wait_start_time)
    --         if findOne("界园_近卫招募组合") then return true end
    --         if findOne("正在提交反馈至神经") then reset_wait_start_time() end
    --         tap("界园_近卫招募组合")
    --         ssleep(0.5)
    --     end, 10) then
    --     return
    -- end
    ssleep(0.5)
    log(1064)
    if not wait(function(reset_wait_start_time)
            if findOne("肉鸽_右上角希望") then
                ssleep(1)
                if findOne("肉鸽_右上角希望") then
                    return true
                end
            end
            findTap("招募说明关闭")
            if findAny({
                    "战略助战", "放弃招募", "剿灭说明",
                }) then
                tap("放弃招募")
                if findOne("剿灭说明") then tap("剿灭说明") end
                disappear("放弃招募")
                if not wait(function()
                        tap("右右确认")
                        if findOne("剿灭说明") then tap("剿灭说明") end
                        if findOne("肉鸽_右上角希望") then return true end
                        if findAny({
                                "界园_近卫招募卷", "界园_医疗招募卷",
                            }) then
                            return true
                        end
                    end, 10) then
                    return
                end
            end
            ssleep(.1)
        end, 10) then
        return
    end
    log(1065)
    -- if not wait(function(reset_wait_start_time)
    --         if findOne("界园_招募界面") then return true end
    --         appearTap("界园_近卫招募组合", 5)
    --         appearTap("界园_近卫招募确认", 5)
    --         ssleep(1)
    --     end, 15) then
    --     return
    -- end
    if zl_skip_fight and not zl_big_map then
        sui.不招募()
    else
        sui.招募处理()
    end

    log(2698)
    if not appear({ "肉鸽_右上角希望", "界园_进入探索", "界园_每层通宝确认" }, 20) then return end
    -- 进入探索 必须分为两段，否则产生位移
    if not wait(function()
            if not findOne("肉鸽_右上角希望") then return true end
            tap("界园_进入探索")
        end, 15) then
        return
    end
    ssleep(2)

    log(2700)
    --点击进入探索之后，有一段时间的加载界面，需要点击
    local xtime = time()
    if not wait(function()
            if findOne("界园_战略帮助") then return true end
            tap("战略确认")
            findTap("界园_每层通宝确认")
            appear("肉鸽_右上角希望", 0.3)
            --第一次会弹出‘战略帮助’那个界面
            if time() - xtime > 3 * 1000 then
                xtime = time()
                tap("招募说明关闭")
            end
        end, 40) then -- 这次肉鸽动画时间很长
        return
    end
    ssleep(0.5) -- 右边第三列有概率加载过慢

    local 界园路线选择结果 = {}
    local 第二列数量 = 0
    local 节点判断 = function(x)
        第二列数量 = x
        log(300, 第二列数量)
        local strx = str(x)
        for i = 1, x do
            if findOne("界园_第2列_不期而遇" .. strx .. "_列表" .. i) then
                table.insert(界园路线选择结果, { i, "不期而遇" })
            else
                local ret = ocrex_ret("界园_第2列_关卡名ocr" .. strx .. "_列表" .. i)
                if string.finds(ret, { "得", "所", "愿" }) then
                    table.insert(界园路线选择结果, { i, "得偿所愿" })
                end
            end
        end
    end
    if findOne("界园_第二列存在3节点") then
        节点判断(3)
    else
        节点判断(2)
    end
    log(界园路线选择结果)
    if #界园路线选择结果 == 0 then
        if zl_fight_more then
            界园路线选择结果 = {
                { 1, "作战" },
            }
        else
            toast("第二列没有不期而遇")
            return
        end
    end
    local 第一列关卡 = 1
    if 第二列数量 == 3 then
        if 界园路线选择结果[1][1] == 2 then
            if not findOne("界园_第一列1第二列2是否连接") then
                第一列关卡 = 2
            end
        elseif 界园路线选择结果[1][1] == 3 then
            第一列关卡 = 2
        end
    else
        第一列关卡 = 界园路线选择结果[1][1]
    end

    log("准备进入第一关作战")
    local 右上角取样 = sample("投币提示")
    ssleep(.5)
    if not wait(function()
            tap("萨卡兹_第一列_作战列表" .. 第一列关卡)
            if findOne('界园_作战页面加载') then return true end
            if not findOne(右上角取样) then
                log(3209)
                ssleep(0.5)
                return true
            end
        end, 10) then
        log(3301, "无法进入")
        zl_repos_path('界园_放弃探索')
    end
    log(3305)
    if zl_skip_fight and not zl_big_map then
        sui.放弃作战()
    else
        sui.战斗开始()
    end
    --有时光之末但没点《扩园篇》天赋
    log(1055)
    local r = appear({ "战略返回", '界园_戛然而止', "界园_作战失败结算" }, 30)
    if r ~= "战略返回" then
        作战结算返回()
        if not appear("界园_常规行动", 5) then
            log(3303, "无法返回常规行动")
            restart()
            return
        end
        return
    end
    if not findOne("战略返回") then return end

    if not zl_skip_fight and not sui.战斗后领取() then
        log("未能完成战斗后拾取")
        return false
    end

    if zl_big_map and not sui.战斗后领取() then
        log("未能完成战斗后拾取")
        return false
    end
    
    log("完成战斗")

    if not wait(function()
            if findAny({ "界园_不期而遇_进入", "界园_得偿所愿_进入", "界园_作战页面加载" , "界园_紧急作战页面加载"}) then return true end
            if 第二列数量 == 3 then
                tap("萨卡兹_3节点_作战列表" .. str(界园路线选择结果[1][1]))
            else
                tap("萨卡兹_2节点_作战列表" .. str(界园路线选择结果[1][1]))
            end
        end, 10) then
        return false
    end

    -- 第二列是不期而遇/得偿所愿
    log("第二步", 界园路线选择结果)
    log("第二步", 界园路线选择结果[1], 界园路线选择结果[1][2])
    if 界园路线选择结果[1][2] == "不期而遇" or 界园路线选择结果[1][2] == "得偿所愿" then
        --进入不期而遇
        if not wait(function()
                if not findOne("界园_不期而遇_进入") and not findOne("界园_得偿所愿_进入") then return true end
                findTap("界园_不期而遇_进入")
                findTap("界园_得偿所愿_进入")
            end, 10) then
            log("未能进入作战列表")
            return false
        end
    end

    if 界园路线选择结果[1][2] == "作战" then
        log("准备进入第2关作战")
        ssleep(.5)
        sui.战斗开始()
        appear({ "战略返回", '界园_戛然而止', "界园_作战失败结算" }, 30)
        if findOne("界园_戛然而止") then
            log('戛然而止界面，准备返回')
            return
        end
        if findOne("界园_作战失败结算") then
            作战结算返回()
            if not appear("界园_常规行动", 5) then
                log(3303, "无法返回常规行动")
                return
            end
            return
        end
        if not findOne("战略返回") then return end
    else
        sui.不期而遇处理()
    end


    appear("肉鸽_右上角希望")

    --点了《扩园篇》天赋
    if zl_big_map then
        zl_fight_more = true 
        local 界园路线选择结果 = {}
        local 第二列数量 = 0
        local 节点判断 = function(x)
            第二列数量 = x
            log(300, 第二列数量)
            local strx = str(x)
            for i = 1, x do
                if findOne("界园_第2列_不期而遇" .. strx .. "_列表" .. i) then
                    table.insert(界园路线选择结果, { i, "不期而遇" })
                else
                    local ret = ocrex_ret("界园_第2列_关卡名ocr" .. strx .. "_列表" .. i)
                    if string.finds(ret, { "得", "所", "愿" }) then
                        table.insert(界园路线选择结果, { i, "得偿所愿" })
                    end
                end
            end
        end
        if findOne("界园_第二列存在3节点") then
         节点判断(3)
        else
          节点判断(2)
        end
        log(界园路线选择结果)
        if #界园路线选择结果 == 0 then
            if zl_fight_more then
                界园路线选择结果 = {
                    { 1, "作战" },
                }
            else
                toast("第二列没有不期而遇")
            end
        end
        local 第一列关卡 = 1
        if 第二列数量 == 3 then
            if 界园路线选择结果[1][1] == 2 then
                if not findOne("界园_第一列1第二列2是否连接") then
                    第一列关卡 = 2
                end
            elseif 界园路线选择结果[1][1] == 3 then
                第一列关卡 = 2
            end
        else
            第一列关卡 = 界园路线选择结果[1][1]
        end

        if not wait(function()
                if findAny({ "界园_不期而遇_进入", "界园_得偿所愿_进入", "界园_作战页面加载", "界园_紧急作战页面加载" }) then return true end
                if 第二列数量 == 3 then
                    tap("萨卡兹_3节点_作战列表" .. str(界园路线选择结果[1][1]))
                else
                    tap("萨卡兹_2节点_作战列表" .. str(界园路线选择结果[1][1]))
                end
            end, 10) then
            return false
        end

        -- 第二列是不期而遇/得偿所愿
        log("第二步", 界园路线选择结果)
        log("第二步", 界园路线选择结果[1], 界园路线选择结果[1][2])
        if 界园路线选择结果[1][2] == "不期而遇" or 界园路线选择结果[1][2] == "得偿所愿" then
            --进入不期而遇
            if not wait(function()
                    if not findOne("界园_不期而遇_进入") and not findOne("界园_得偿所愿_进入") then return true end
                    findTap("界园_不期而遇_进入")
                    findTap("界园_得偿所愿_进入")
                end, 10) then
                log("未能进入作战列表")
                return false
            end
        end

        if 界园路线选择结果[1][2] == "作战" then
            log("准备进入第2关作战")
            ssleep(.5)
            if zl_skip_fight then
                sui.放弃作战()
            else
                sui.战斗开始()
            end
            --有时光之末而且点《扩园篇》天赋
            appear({ "战略返回", '界园_戛然而止', "界园_作战失败结算" }, 30)
            if findOne("界园_戛然而止") then
                log('戛然而止界面，准备返回')
                return
            end
            if findOne("界园_作战失败结算") then
                作战结算返回()
                if not appear("界园_常规行动", 5) then
                    log(3303, "无法返回常规行动")
                    return
                end
                return
            end
            if not findOne("战略返回") then return end
        else
            sui.不期而遇处理()
        end

            log(1055)
        local r = appear({ "战略返回", '界园_戛然而止', "界园_作战失败结算" }, 30)
        if r ~= "战略返回" then
            作战结算返回()
            if not appear("界园_常规行动", 5) then
                log(3303, "无法返回常规行动")
                restart()
                return
            end
            return
        end
        if not findOne("战略返回") then return end

        if not zl_skip_fight and not sui.战斗后领取() then
            log("未能完成战斗后拾取")
            return false
        end
        log("完成战斗")
    end

    appear("肉鸽_右上角希望")

    -- 第三列商店
    local 商店关卡寻找 = function()
        log('商店关卡寻找')
        local po = find_color("界园_商店关卡查找_列范围", "039D54", 2, 0.95)
        log("不期而遇关卡位置", po)
        if po then
            wait(function()
                tap({ po[1], po[2] - scale(20) })
                if findOne("界园_商店进入") then return true end
            end, 20)
            return true
        end
    end

    -- 商店
    商店关卡寻找()

    if not wait(function()
            if findAny({ "诡意行商投资", "诡意行商离开" }) then return true end
            tap("界园_商店进入")
            ssleep(0.2)
            if findOne("肉鸽弹出窗口") then
                tap("左取消")
                ssleep(0.2)
            end
        end, 5) then
    end

    --投币
    if not zl_skip_coin then zl_shop_coin() end
    if zl_only_coin then
        log('只是投币，准备退出')
        findTap('战略退出')
        appear('界园_放弃探索', 3)
        return true
    end
    --购买商品
    if not zl_not_buy_jy then
        if not wait(function()
                if findOne("诡意行商离开") then return true end
                tap("开包skip")
            end, 5) then
            return
        end
        for i = 1, 10 do if not zl_shop_buy() then break end end
    end

    wait(function()
        if not findOne("战略返回") then return true end
        tap("诡意行商离开")
    end, 15)

    -- 第四列 误入奇境
    appearTap("界园_第四列_关卡坐标")
    if appear("界园_误入奇境_进入") then
        tap("界园_误入奇境_进入")
    else
        log("没有入口")
        return
    end

    sui.不期而遇处理("界园_每层通宝确认")

    if not wait(function()
            tap("界园_每层通宝确认")
            tap("招募说明关闭")
            if findOne("界园_烛火界面") then return true end
            ssleep(0.5)
        end, 10) then
        return
    end
    if not wait(function()
            tap("界园_剩余烛火")
            if appear("界园_烛火离开", 1) then
                tap("界园_烛火离开")
                disappear("界园_烛火离开")
                tap("右确认")
                return true
            end
            ssleep(0.5)
        end, 20) then
        return
    end

    if not wait(function()
            findTap("界园_每层通宝确认")
            ssleep(0.3)
            findTap('战略返回')
            if findAny({ "界园_常规行动" }) then return true end
            ssleep(0.5)
        end, 45) then
        log("第二层退出返回失败")
        back()
        return
    end
    return
end

sui.招募并记录干员 = function(干员, 肉鸽白名单)
    local idx, name = zl.招募干员(干员, 肉鸽白名单)
    log(idx, name)
    if table.findk(肉鸽参数["operators"], name) then
        肉鸽参数["operators"][name] = 肉鸽参数["operators"][name] + 1
    end
    zl.选择干员(idx)
end

sui.普通作战1 = function()
    log('界园肉鸽')
    -- 大地图数据
    横向间隔 = scale(675)
    纵向间隔 = scale(91)
    第1列横坐标 = scale(524)
    第1行纵坐标 = scale(191)
    节点类型 = {
        作战 = 1,
        ["%作战"] = 1,
        x作战 = 1,
        X作战 = 1,
        紧急作战 = 2,
        ["%紧急作战"] = 2,
        x紧急作战 = 2,
        X紧急作战 = 2,
        险路恶敌 = 3,
        安全屋 = 4,
        诡意行商 = 5,
        不期而遇 = 6,
        失与得 = 7,
        误入奇境 = 8,
        指点迷津 = 9,
        先行一步 = 10,
        狭路相逢 = 11,
    }
    --局内数据
    节点评分 = {
        [1] = 2, --作战
        [2] = 3, -- 紧急作战
        [3] = 2,
        [4] = 1,
        [5] = 5,
        [6] = 1,
        [7] = 0,
        [8] = 15,
        [9] = 10,
        [10] = 2,
        [11] = 1
    }
    初始分队 = 1
    初始小队 = 2
    初始队员 = { "维什戴尔", "谷米", "卡达" }
    到达层数 = 0
    肉鸽商品评分 = {}
    大地图 = {}
    当前通宝 = {
        花 = {},
        衡 = {},
        厉 = {},
    }
    已存招募券 = {}
    钱盒内通宝 = {
        花 = {},
        衡 = {},
        厉 = {},
    }
    肉鸽参数 = {
        hp = 0,
        hope = 0,
        floor = 0,
        collection = {},
        operators = {
            维什戴尔 = 1,
            谷米 = 1,
            卡达 = 1,
            --[[ 电弧 = 1,
            酒神 = 1,
            罗小黑 = 1,
            清流 = 1, ]]
        },
        ticket = 2,
    }
    --第五层暂停 = ReadUIConfig("第五层暂停")
    招募开局干员 = 0
    肉鸽白名单 = { "维什戴尔", "古米", "卡达", "电弧", "酒神", "新约能天使" }
    肉鸽队员 = {}
    sui.跳转()

    -- 开始探索 一路按到 招募干员
    -- local first_time_see_first_card = 0
    local 分队位置 = 初始分队
    if 分队位置 > 4 then
        log("需要翻", 分队位置 // 4, "页")
        for i = 1, 分队位置 // 4 do
            ssleep(0.5)
            path.swip_hd_shop(false, scale(1704))
            ssleep(0.5)
        end
    end

    local tapx = scale(258) + scale(414) * (分队位置 % 4 - 1)
    local tapy = scale(904)
    if not wait(function(reset_wait_start_time)
            if findOne("界园_选择招募组合") then return true end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
            tap({ tapx, tapy })
            ssleep(.8)
        end, 10) then
        return
    end

    log("初始招募")
    if not wait(function(reset_wait_start_time)
            if findOne("界园_初始招募") then return true end
            tap("界园_稳扎稳打分队")
            ssleep(.8)
        end, 10) then
        return
    end
    log('招募狙击')
    if not wait(function()
            tap("界园_医疗招募券")
            tap("招募说明关闭")
            if findOne("确认招募") then return true end
            ssleep(.2)
        end, 10) then
        return
    end
    log('招募维什戴尔')
    sui.招募并记录干员("维什戴尔", 肉鸽白名单)

    -- 第2人
    --[[ if not wait(function(reset_wait_start_time)
            if findOne("界园_初始招募") then return true end
            tap("界园_近卫招募券")
        end, 10) then
        return
    end ]]

    log('招募第二个人')
    if not wait(function()
            tap("界园_近卫招募券")
            tap("招募说明关闭")
            if findOne("确认招募") then return true end
            ssleep(.2)
        end, 10) then
        return
    end
    log('招募古米')
    sui.招募并记录干员("古米", 肉鸽白名单)
    --ssleep(1)
    -- 第3人
    log('招募第三个人')
    if not wait(function()
            tap("界园_近卫招募券")
            tap("招募说明关闭")
            if findOne("确认招募") then return true end
            ssleep(.2)
        end, 10) then
        return
    end
    log('招募卡达')
    sui.招募并记录干员("卡达", 肉鸽白名单)
    log(肉鸽参数["operators"])
    if not appear("界园_初始招募") then return end
    log(2698)
    -- 进入探索 必须分为两段，否则产生位移
    if not wait(function()
            if not findOne("界园_初始招募") then return true end
            tap("界园_进入探索")
        end, 5) then
        return
    end

    log(2700)
    --点击进入探索之后，有一段时间的加载界面，需要点击
    local xtime = time()
    if not wait(function()
            if findOne("战略返回") then return true end
            if findOne("界园_每层通宝确认") then return true end
            tap("战略确认")
            --第一次会弹出‘战略帮助’那个界面
            if time() - xtime > 3 * 1000 then
                xtime = time()
                tap("招募说明关闭")
            end
        end, 20) then
        return
    end

    if findOne("界园_每层通宝确认") then
        当前通宝 = sui.判断投出通宝()
        tap("界园_每层通宝确认")
    end
    ssleep(0.5) -- 右边第三列有概率加载过慢
    local best_path = sui.判断路径()
    zl.重置大地图()
    local 当前列 = 1
    log(best_path[当前列][1])
    tap({ 第1列横坐标, 第1行纵坐标 + 纵向间隔 * best_path[当前列][1] })
    local 当前节点类型 = 大地图[best_path[当前列][1]][当前列]["NodeType"]
    log(当前节点类型)
    ssleep(1)
    if 当前节点类型 == 1 then
        local 作战名 = sui.作战名ocr校正(ocro("界园_作战检测范围"))
        log(作战名)
    end
end

sui.判断投出通宝 = function()
    log("判断投出通宝")
    local ret = ocrex("界园_掷出通宝ocr范围")
    ret = sui.通宝ocr校正(ret)
    -- 处理每个字符串并分类存储
    local 已投出通宝 = {
        花 = {},
        衡 = {},
        厉 = {},
    }

    for i = 1, #ret do
        local text = ret[i]["text"]
        local prefix, content

        -- 尝试匹配三种情况
        for _, p in ipairs({ "花", "衡", "厉" }) do
            if text:sub(1, #p) == p then
                prefix = p
                -- 去除前缀和可能的"-"
                content = text:sub(#p + 1):gsub("^%-", "")
                break
            end
        end

        -- 如果找到匹配的前缀，存入对应表
        if prefix and 已投出通宝[prefix] then
            table.insert(已投出通宝[prefix], content)
        end
    end
    log(已投出通宝)
    return 已投出通宝
end

sui.通宝ocr校正 = function(t)
    for i = 1, #t do
        -- 匹配t[i]["text"]最开头的"花"/"衡"/"厉"字符位置,并去掉该位置左侧的字符
        t[i]["text"] = (function(s)
            local p = math.min(s:find("花") or math.huge, s:find("衡") or math.huge, s:find("厉") or math.huge)
            return p ~= math.huge and s:sub(p) or s
        end)(t[i]["text"])
        --[[ local 原文本 = (t[i]["text"])
    print(原文本)
    if 替换[原文本] then
        t[i]["text"] = 替换[原文本]
    elseif 原文本:match("^白面.*$") then
    end ]]
        print(t[i]["text"])
    end
    return t
end

sui.判断楼层 = function()
    local floor = 1
    local str = ocro("界园_楼层ocr范围")
    if string.finds(str, { "洪", "陆", "楼" }) then
        floor = 1
    elseif string.finds(str, { "山", "水", "阁" }) then
        floor = 2
    elseif string.finds(str, { "云", "瓦", "亭" }) then
        floor = 3
    elseif string.finds(str, { "汝", "吾", "门" }) then
        floor = 4
    elseif string.finds(str, { "见", "字", "祠" }) then
        floor = 5
    elseif string.finds(str, { "始", "末", "陵" }) then
        floor = 6
    elseif string.finds(str, { "是", "非", "境" }) then
        floor = 0
    end
    log("当前楼层:", floor)
    sleep(50)
    return floor
end

sui.判断血量 = function()
    local str = ocro("界园_血量ocr范围")
    log("判断血量", str)
    sleep(50)
    return str
end
sui.判断希望 = function()
    local str = ocro("界园_希望ocr范围") or 0
    log("判断希望", str)
    sleep(50)
    return str
end
sui.判断源石锭 = function()
    local str = ocro("界园_局内源石锭ocr范围") or 0
    log("判断局内源石锭", str)
    sleep(50)
    return str
end
sui.判断票数 = function()
    local str = ocro("界园_票ocr范围") or 0
    str = str2int(str, 0)
    log("判断票数", str)
    sleep(50)
    return str
end
sui.判断路径 = function()
    log("判断路径")
    local floor = sui.判断楼层()
    local 总列数 = { 4, 5, 5, 5, 5, 5, 5 } -- 每一层的列数
    大地图 = zl.创建大地图二维数组(7, 总列数[floor], 0)
    local 起始行号 = sui.第1列判断()
    for i = 2, 总列数[floor] - 1 do
        zl.大地图右滑()
        起始行号 = sui.第2列判断(i, 起始行号, i == 总列数[floor] - 1)
    end
    log(大地图)
    local path, score = zl.find_best_path(大地图, 节点评分)
    if path then
        log("找到最佳路径", path, "总分", score)
        return path
    else
        log("未找到最佳路径")
        return {}
    end
end

sui.判断通路 = function(列, 起始行号1, 起始行号2, 偏移坐标)
    log("判断第", 列, "列通路")
    --log(大地图)
    local 查找通路 = function(横坐标, 起始行号)
        local 通路行号 = {}
        for i = 起始行号, 8 - 起始行号, 2 do
            local 上界 = scale(74) + i * scale(91)
            local 下界 = scale(142) + 上界
            local BY = 上界
            while BY < 下界 do
                local _, intY = findMultiColor(横坐标, BY, 横坐标 + 1, 下界, "FFFFFF", "0|3|FFFFFF", 0, 0.95)
                if intY < 0 then break end
                BY = intY + scale(9)
                table.insert(通路行号, i)
            end
        end
        return 通路行号
    end
    local 出路横坐标 = scale(760) - 偏移坐标 --+ (列 - 1) * 横向间隔
    local 入路横坐标 = scale(1100) - 偏移坐标 --+ (列 - 1) * 横向间隔

    local 出路 = 查找通路(出路横坐标, 起始行号1)
    local 入路 = 查找通路(入路横坐标, 起始行号2)
    log(出路, 入路)
    if #出路 == #入路 then
        for i = 1, #出路 do
            --log(出路[i], 列)
            table.insert(大地图[出路[i]][列]["NextNode"], { 入路[i], 列 + 1 })
        end
    else
        log("通路判断失败")
    end
end
sui.第1列判断 = function()
    local 起始行号 = 1
    local 第2列起始行号 = 1
    -- 判断第1列起始行号
    for i = 1, 4 do
        if cmpColor(第1列横坐标, 第1行纵坐标 + i * 纵向间隔, "9C6EBC|9C6EBC", 0.85) == 1
            and cmpColor(第1列横坐标 - scale(36), 第1行纵坐标 - scale(49) + i * 纵向间隔, "9E6CD6|9C6EBC", 0.85) == 1 then
            起始行号 = i
            break
        end
    end
    log(起始行号)
    -- 判断第2列起始行号
    for i = 1, 4 do
        if cmpColor(第1列横坐标 + 横向间隔, 第1行纵坐标 + i * 纵向间隔, "2D2D2E", 0.85) == 1
            and cmpColor(第1列横坐标 + 横向间隔 - scale(36), 第1行纵坐标 - scale(49) + i * 纵向间隔, "5E5E5E", 0.85) == 1 then
            第2列起始行号 = i
            break
        end
    end
    log(第2列起始行号)
    -- 判断节点类型
    for i = 起始行号, 8 - 起始行号, 2 do
        if cmpColor(第1列横坐标, 第1行纵坐标 + i * 纵向间隔, "9C6EBC", 0.85) == 1
            and cmpColor(第1列横坐标 - scale(36), 第1行纵坐标 - scale(49) + i * 纵向间隔, "9E6CD6", 0.85) == 1 then
            大地图[i][1] = {
                NodeType = 节点类型["作战"],
                NextNode = {},
            }
        elseif cmpColor(第1列横坐标, 第1行纵坐标 + i * 纵向间隔, "9C6EBC", 0.85) == 1
            and cmpColor(第1列横坐标 - scale(36), 第1行纵坐标 - scale(49) + i * 纵向间隔, "9E6CD6", 0.85) == 1 then
            大地图[i][1] = {
                NodeType = 节点类型["不期而遇"],
                NextNode = {},
            }
        end
    end
    sui.判断通路(1, 起始行号, 第2列起始行号)
    return 第2列起始行号
end
sui.第2列判断 = function(列, 起始行号, 是否最后一列)
    log("第2列判断", 起始行号)
    local 第2列起始行号 = 1
    -- 判断偏移坐标
    local intX = findMultiColor(scale(251), 第1行纵坐标 + 起始行号 * 纵向间隔, scale(535), 第1行纵坐标 + 起始行号 * 纵向间隔 + 1, "32272A",
        scale(65) .. "|0|31272A", 0, 0.95)
    local 偏移坐标 = scale(431) - intX
    local 第一列横坐标 = scale(524) - 偏移坐标
    log(起始行号)
    -- 判断节点类型
    for i = 起始行号, 8 - 起始行号, 2 do
        point["节点类型ocr范围"] = { 第一列横坐标 + scale(65), scale(174) + i * 纵向间隔, 第一列横坐标 + scale(210), scale(202) + i * 纵向间隔 }
        local str = ocro("节点类型ocr范围")
        log(str)
        大地图[i][列] = {
            NodeType = 节点类型[str],
            NextNode = {},
        }
    end

    -- 判断第2列起始行号
    for i = 1, 4 do
        if cmpColor(第1列横坐标 + 横向间隔, 第1行纵坐标 + i * 纵向间隔, "2D2D2E", 0.85) == 1
            and cmpColor(第1列横坐标 + 横向间隔 - scale(36), 第1行纵坐标 - scale(49) + i * 纵向间隔, "5E5E5E", 0.85) == 1 then
            第2列起始行号 = i
            break
        end
    end
    log(第2列起始行号)
    sui.判断通路(列, 起始行号, 第2列起始行号, 偏移坐标)
    if 是否最后一列 then
        -- 判断节点类型
        for i = 第2列起始行号, 8 - 第2列起始行号, 2 do
            point["节点类型ocr范围"] = { 第一列横坐标 + 横向间隔 + scale(65), scale(174) + i * 纵向间隔, 第一列横坐标 + 横向间隔 + scale(210), scale(202) +
            i * 纵向间隔 }
            local str = ocro("节点类型ocr范围")
            log(str)
            大地图[i][列 + 1] = {
                NodeType = 节点类型[str],
                NextNode = {}
            }
        end
    end
    return 第2列起始行号
end

sui.进入作战 = function()
    local 作战名 = sui.作战名ocr校正(ocro("界园_作战检测范围"))
    log(作战名)
    if not wait(function()
            if findOne("快捷编队") then return true end
            tap("进入节点")
            ssleep(.2)
        end, 5) then
        log(3302, "无法进入")
        --zl_repos_path('界园_放弃探索')
    end
end

sui.作战名ocr校正 = function(t)
    if t == nil then return end
    local 替换 = {
        ["狡三窟"] = "狡鼷三窟",
    }

    local 原文本 = t
    --print(原文本)
    if 替换[原文本] then
        t = 替换[原文本]
        -- elseif 原文本:match("^白面.*$") then
        --     t = "白面鸮"
        -- elseif 原文本:find("纯") and 原文本:find("艾雅法拉") then
        --     t = "纯烬艾雅法拉"
        -- elseif 原文本:find("默") and 原文本:find("德克萨斯") then
        --     t = "缄默德克萨斯"
        -- elseif 原文本:find("荒芜") and 原文本:find("拉普") then
        --     t = "荒芜拉普兰德"
    end
    return t
end
