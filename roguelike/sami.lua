-- ===========================================
--               萨米肉鸽相关
-- ===========================================

path.探索者的银淞止境前瞻投资 = function(lighter)
    --ssleep(.1)
    log('start 探索')
    if findOne("萨米_风雪蔽目") then
        wait(function()
            if findAny({ "萨米_常规行动", "面板" }) then return true end
            tap("战略确认")
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
            path.探索者的银淞止境前瞻投资(true)
        else
            path.跳转("首页")
        end
    end

    --判断是否在其他界面
    local jumpout
    if findOne("战略返回") then path.fallback.战略返回其他肉鸽() end
    if findOne("暂停中") and findOne("生命值") then restartapp(appid) end

    --通用  先导航到常规行动
    zl_navigation('萨米_常规行动', '探索者的银淞止境进入主题')

    --通用 肉鸽 等级源石锭检查
    萨米肉鸽完成 = zl_level_coin_inquire('萨米_常规行动', '萨米_等级检测范围', '萨米_源石锭检测范围')
    if 萨米肉鸽完成 then
        return
    end

    --通用  放弃探索
    if not zl_abandon_explore('萨米') then return end
    if jumpout then return end

    --通用 开始探索之前看看是否等级满了，放弃行动后回到首页再截个图
    zl_level_coin_enough()

    --点天赋
    -- if lighter and not lighter_enough and not zl_disable_lighter then
    -- end


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
            tap("战略确认")
            tap("继续探索")
        end, 5) then
        -- 初始选难度
        --zl_more_experience = true
        -- tap("战略难度列表" .. (zl_more_experience and "2" or "1"))
        return
    end
    if jumpout then return end

    -- 开始探索 一路按到 招募干员
    local first_time_see_first_card = 0
    if not wait(function(reset_wait_start_time)
            if findOne("萨米_初始招募") then return true end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
            tap("战略确认")
            tap("战略确认")
            tap("战略确认")
            if findOne("萨米_指挥分队") then
                if first_time_see_first_card == 0 then
                    first_time_see_first_card = time()
                end
                if time() - first_time_see_first_card > 2000 then
                    tap("萨米_指挥分队1")
                    appear("萨米_指挥分队确认", 1)
                    ssleep(.5)
                    tap("萨米_指挥分队确认")
                    disappear("萨米_指挥分队确认")
                    first_time_see_first_card = 0
                end
            else
                first_time_see_first_card = 0
            end
        end, 10) then
        return
    end

    --不知道这块什么用的 傀影的有这块，就留着了
    if not wait(function(reset_wait_start_time)
            if findOne("萨米_初始招募") then return true end
            tap("近卫招募券")
        end, 10) then
        return
    end

    --放弃辅助
    if not zl_放弃招募辅助('萨米') then return end

    --招募近卫
    if not zl_招募近卫('萨米') then return end

    --招募医疗
    if not zl_招募医疗('萨米') then return end

    if not appear("萨米_初始招募") then return end
    log(2698)
    -- 进入探索 必须分为两段，否则产生位移

    if not wait(function()
            if not findOne("萨米_初始招募") then return true end
            tap("萨米_进入探索")
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
            if time() - xtime > 2 * 1000 then
                xtime = time()
                tap("招募说明关闭")
                ssleep(.5)
            end
        end, 15) then
        return
    end

    --延迟一会，否则会产生位移，
    --未做线路优化  后续的延迟可以拿来后续做线路优化的筛选
    --其实只要优化出  走下面还是走上面就可以
    --目前默认选择上面的线路
    ssleep(1)

    ::fight_first::
    log("准备进入第一关作战")
    if not wait(function()
            tap("萨米_第一次作战上")
            if not findOne('萨米_密文版') then return true end
        end) then
        toast("无法进入作战")
        zl_repos_path("萨米_放弃本次探索")
        goto fight_first
    end


    --检查作战关卡名字
    if not zl_fight_name_ocr('萨米') then return end
    toast(now_fight_name)
    ssleep(.5)

    --通用的  肉鸽的第一次作战编队 直接引用就可以
    if not zl_first_edit_team() then return end

    ::sami_fight::
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
    zl_deploy2(point.萨米作战关卡[now_fight_name])

    appear("生命值")

    local last_time_see_life = time()
    local skill_times = 0
    local zl_level = zl_level or -1
    if not wait(function()
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
            if p and skill_times < zl_skill_times then
                skill_times = skill_times + 1
                tap({ p[1], p[2] + scale(150) })
                -- appear("技能ready", 5)
                appear("生命值蓝", 5)
                ssleep(0.5)
                wait(function()
                    tap("开技能")
                    if disappear("生命值蓝", 1) then return true end
                end)
                ssleep(2) --开完技能延迟一会，不然像送葬人这种会马上关闭了
            end
        end, 300) then
        return restartapp(appid)
    end

    appear({ "战略返回", "萨米_联系中断", '萨米_风雪蔽目' }, 30)
    if findOne("萨米_风雪蔽目") then
        log('风雪蔽目界面，准备返回')
        return
    end
    if findOne("萨米_联系中断") then
        tap("战略确认")
        appear('萨米_风雪蔽目', 8)
        return
    end
    if not findOne("战略返回") then return end

    if not zl_fight_after_sami() then
        log("未能完成战斗后拾取")
        return false
    end
    log("完成一次战斗")

    ::fight_select::
    log('在选择节点界面')
    local idxs = -1
    local idxs, maxIndex = zl_selection_node(0, '萨米')
    --如果maxIndex是1 2 则是战斗关卡   3 4 是不期而遇
    if not idxs then return end
    if idxs > 0 then
        log(idxs, maxIndex)
        tap(point['萨米_关卡节点坐标列表' .. idxs])
        ssleep(.5)
    end

    if maxIndex == 1 or maxIndex == 2 then
        --进入战斗
        log("进入战斗")
        --识别关卡名字
        if not zl_fight_name_ocr('萨米') then return end
        toast(now_fight_name)
        ssleep(.5)

        --进入编队界面
        if not wait(function()
                if findOne("快捷编队") then return true end
                tap("进入")
            end, 10) then
            return
        end

        goto sami_fight
    elseif maxIndex == 3 or maxIndex == 4 then
        --进入不期而遇
        log("进入不期而遇")
        disappear('萨米_密文版')
        wait(function()
            tap("进入")
        end, 2)
        if not wait(function()
                if findOne("萨米_密文版") then return true end
                tap("战略确认")
            end, 10) then
            --return
        end

        --判断不期而遇事件，并处理
        log('处理不期而遇事件')
        if not wait(function()
                local x = function()
                    local incident
                    if not wait(function()
                            incident = ocr("萨米_不期而遇事件名字检测")
                            if incident[1] then return true end
                            tap('战略确认')
                            if findOne("萨米_战略帮助") then return true end
                        end, 5) then
                        return false
                    end
                    if not incident[1] then return false end
                    local str = incident[1].text
                    log('事件名字：', str)
                    if string.finds(str, { "沼泽", '田', '昏黑' }) then
                        if zl_event_solve(3, '萨米_战略帮助') then return true end
                    elseif string.finds(str, { '田' }) then
                        if zl_event_solve(2, '萨米_战略帮助') then return true end
                    elseif string.finds(str, { "萨米之语", '随到随取', '定期' }) then
                        if zl_event_solve(1, '萨米_战略帮助') then return true end
                    end
                end
                if x() then return true end
                if findOne("萨米_战略帮助") then return true end
            end, 30) then
            return false
        end
        goto fight_select
    end

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
        appear('萨米_常规行动', 5)
    end

    -- 商店
    disappear('萨米_密文版')
    wait(function()
        tap("进入")
    end, 2)

    if not zl_skip_coin then zl_shop_coin() end
    if zl_only_coin then
        log('只是投币，准备退出')
        findTap('战略退出')
        appear('萨米_放弃本次探索', 3)
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
