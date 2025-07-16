-- ===========================================
--               界园肉鸽相关
-- ===========================================


sui = {}

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
                "界园_招募卷收下",
            })
            log(2555, x)
            tap(x)

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
    appear("界园_招募界面")
    ssleep(0.5)
    appear("肉鸽_右上角希望")
    ssleep(1)
    log('招募近卫')
    if not wait(function()
            tap("近卫招募券")
            tap("招募说明关闭")
            if not findOne("肉鸽_右上角希望") and not findOne("战略返回") then
                return true
            end
            ssleep(0.2)
        end, 10) then
        return
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
    ssleep(.1)
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
            if findOne("肉鸽_右上角希望") then
                -- if findAny({ "", "战略返回" }) then
                log(26)
                return true
            end
            if findOne("返回确认界面") then
                log(27)
                tap("左取消")
                disappear("返回确认界面")
                ssleep(.5)
            end
            tap("近卫招募列表" .. 1)
            findTap("确认招募")
            tap("开包skip")
        end, 10) then
        return
    end
    ssleep(.1)
    -- 第3人
    log('招募医疗')
    if not wait(function()
            tap("界园_医疗招募券")
            tap("招募说明关闭")
            if findOne("确认招募") then return true end
        end, 10) then
        return
    end
    appear('战略助战')
    if not wait(function()
            if findOne("肉鸽_右上角希望") then
                --if findAny({ "萨米_初始招募", "战略返回" }) then
                log(26)
                return true
            end
            if findOne("返回确认界面") then
                log(27)
                tap("左取消")
                disappear("返回确认界面")
                ssleep(.5)
            end
            tap("近卫招募列表" .. 1)
            findTap("确认招募")
            tap("开包skip")
        end, 10) then
        return
    end
end

sui.不招募 = function()
    ssleep(0.5)
    appear("肉鸽_右上角希望")
    log('不招募近卫')
    if not wait(function()
            tap("近卫招募券")
            tap("招募说明关闭")
            if not findOne("肉鸽_右上角希望") and not findOne("战略返回") then
                return true
            end
            ssleep(0.2)
        end, 10) then
        return
    end
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
    ssleep(.1)
    -- 第2人
    log('不招募辅助')
    if not wait(function()
            tap("萨卡兹_辅助招募券")
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
    ssleep(.1)
    -- 第3人
    log('不招募医疗')
    if not wait(function()
            tap("界园_医疗招募券")
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
    if not wait(function()
            local x = function()
                local incident
                local t = time()
                if not wait(function()
                        incident = ocr("界园_不期而遇关卡ocr范围")
                        if time() - t > 1000 then --不期而遇事件，偶尔下面的 '√' 会一直存在，间隔点击一次
                            t = time()
                            if not findOne('萨米_希望源石锭界面') then
                                tap({ scale(960), scale(935) }) --更上面一点，防止误触
                            end
                        end
                        if incident[1] then return true end
                        if findOne(战略帮助) then return true end
                    end, 8) then
                    return false
                end
                if not incident[1] then return false end
                local str = incident[1].text
                log('事件名字：', str)
                if findOne('萨卡兹_不期而遇确认') then tap("萨卡兹_不期而遇确认点击") end
                if string.finds(str, { "暂时没有这个" }) then -- 二选第一个 或者 三选第二个
                    if zl_event_solve(8, 战略帮助) then return true end
                elseif string.finds(str, { "食", "来者", "不拒" }) then -- 三选第三个 如 饕餮廊
                    if zl_event_solve(4, 战略帮助) then return true end
                elseif string.finds(str, { "偏安", "安", "师", "女", "相会", "会", "地", "地镇" }) then -- 二选第二个 或者1选1
                    if zl_event_solve(2, 战略帮助) then return true end
                elseif string.finds(str, { "护鸭", "金刚", "金则" }) then -- 二选第二个 或者3选2
                    if zl_event_solve(5, 战略帮助) then return true end
                elseif string.finds(str, { "传讯", }) then -- 三选第一个
                    if zl_event_solve(7, 战略帮助) then return true end
                elseif string.finds(str, { "路" }) then -- 四选第一个
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

    -- 部署干员到关卡位置 只部署一个人的
    zl_deploy(point.界园_作战关卡[now_fight_name], 1)

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
            ssleep(0.5)
        end, 300) then
        return restartapp(appid)
    end
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
    appearTap("界园_无干员进入", 5)
    -- 等待加载游戏界面
    if not wait(function()
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
    zl_eight_daily()

    local in_fight_return = ''
    local restart = function()
        toast(in_fight_return or '重开')
        ssleep(3)
        if not request_memory_clean() then
            path.界园前瞻投资()
        else
            path.跳转("首页")
        end
    end

    --判断是否在其他界面
    local jumpout
    if findOne("战略返回") then path.fallback.战略返回() end
    if findOne("暂停中") and findOne("生命值") then restartapp(appid) end
    if findOne("界园_每层通宝确认") then tap("界园_每层通宝确认") end

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
            if findOne("界园_主页干员详情") then
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
            ssleep(0.8)
        end, 10) then
        return
    end

    if not wait(function(reset_wait_start_time)
            if findOne("界园_招募界面") then return true end
            tap("界园_下一步")
            ssleep(1)
        end, 10) then
        return
    end
    if zl_skip_fight then
        sui.不招募()
    else
        sui.招募处理()
    end

    if not appear("肉鸽_右上角希望") then return end
    log(2698)

    -- 进入探索 必须分为两段，否则产生位移
    if not wait(function()
            if not findOne("肉鸽_右上角希望") then return true end
            tap("界园_进入探索")
        end, 15) then
        return
    end

    log(2700)
    --点击进入探索之后，有一段时间的加载界面，需要点击
    local xtime = time()
    if not wait(function()
            if findOne("战略返回") then return true end
            tap("战略确认")
            findTap("界园_每层通宝确认")
            appear("肉鸽_右上角希望", 0.3)
            --第一次会弹出‘战略帮助’那个界面
            if time() - xtime > 3 * 1000 then
                xtime = time()
                tap("招募说明关闭")
            end
        end, 35) then -- 这次肉鸽动画时间很长
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
                local ret = ocr_ret("界园_第2列_关卡名ocr" .. strx .. "_列表" .. i)
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
    if #界园路线选择结果 == 0 and not zl_fight_more then
        toast("第二列没有不期而遇")
        return
    else
        界园路线选择结果 = {
            { 1, "作战" },
        }
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
    ssleep(.5)
    if not wait(function()
            tap("萨卡兹_第一列_作战列表" .. 第一列关卡)
            if findOne('界园_作战页面加载') then return true end
        end, 10) then
        log(3301, "无法进入")
        zl_repos_path('界园_放弃探索')
    end

    if zl_skip_fight then
        sui.放弃作战()
    else
        sui.战斗开始()
    end

    appear({ "战略返回", '界园_戛然而止' }, 30)
    if findOne("界园_戛然而止") then
        log('戛然而止界面，准备返回')
        return
    end
    if not findOne("战略返回") then return end

    if not sui.战斗后领取() then
        log("未能完成战斗后拾取")
        return false
    end
    log("完成战斗")

    if not wait(function()
            if findAny({ "界园_不期而遇_进入", "界园_得偿所愿_进入", "界园_作战页面加载" }) then return true end
            if 第二列数量 == 3 then
                tap("萨卡兹_3节点_作战列表" .. str(界园路线选择结果[1][1]))
            else
                tap("萨卡兹_2节点_作战列表" .. str(界园路线选择结果[1][1]))
            end
        end, 5) then
        return false
    end

    -- 第二列是不期而遇/得偿所愿
    if 界园路线选择结果[1][2] == "不期而遇" then
        --进入不期而遇
        if not wait(function()
                if not findOne("界园_不期而遇_进入") then return true end
                tap("界园_不期而遇_进入")
            end, 5) then
            log("未能进入作战列表")
            return false
        end
    elseif 界园路线选择结果[1][2] == "得偿所愿" then
        if not wait(function()
                if not findOne("界园_得偿所愿_进入") then return true end
                tap("界园_得偿所愿_进入")
            end, 5) then
            log("未能进入作战列表2")
            return false
        end
    end

    if 界园路线选择结果[1][2] == "作战" then
        log("准备进入第2关作战")
        ssleep(.5)
        sui.战斗开始()
    else
        sui.不期而遇处理()
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
            -- if not findOne("战略帮助") then return true end
            if findAny({ "诡意行商投资", "诡意行商离开" }) then return true end
            tap("界园_商店进入")
        end, 3) then
        return zl_repos_path('界园_放弃探索')
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
    if not wait(function()
            if findOne("诡意行商离开") then return true end
            tap("开包skip")
        end, 5) then
        return
    end
    for i = 1, 10 do if not zl_shop_buy() then break end end

    wait(function()
        if not findOne("战略返回") then return true end
        tap("诡意行商离开")
    end, 10)

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
            if findOne("界园_每层通宝确认") then return true end
            ssleep(0.5)
        end, 10) then
        return
    end
    if not wait(function()
            tap("界园_剩余烛火")
            if findOne("界园_每层通宝确认") then return true end
            if appear("界园_烛火离开", 1) then
                tap("界园_烛火离开")
                disappear("界园_烛火离开")
                tap("右确认")
                return true
            end
            ssleep(0.5)
        end, 10) then
        return
    end

    if not wait(function()
            tap("界园_每层通宝确认")
            if findAny({ "界园_战略帮助" }) then return true end
            ssleep(0.5)
        end, 10) then
        return
    end
    appear('战略返回')
    findTap('战略返回')
    if not wait(function()
            findTap("界园_每层通宝确认")
            findTap('战略返回')
            if findAny({ "界园_常规行动", "界园_戛然而止" }) then return true end
            ssleep(0.5)
        end, 10) then
        return
    end
    return
end
