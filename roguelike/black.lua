-- 黑流树海
-- ===========================================
--               界园肉鸽相关
-- ===========================================


hlsh = {}

hlsh.跳转 = function()
    zl_eight_daily()

    local in_fight_return = ''
    local restart = function()
        toast(in_fight_return or '重开')
        restartapp(appid)
        ssleep(3)
        if not request_memory_clean() then
            path.黑流树海()
        else
            path.跳转("首页")
        end
    end
    --判断是否在其他界面
    local jumpout
    if findOne("战略返回") then path.fallback.战略返回() end
    if findOne("暂停中") and findOne("生命值") then restartapp(appid) end

    if findOne("黑流树海_信息丢失") then
        if not wait(function()
                if findOne("黑流树海_常规行动") then return true end
                tap("新战略确认")
                ssleep(.5)
            end, 10) then
            log.debug()
            return
        end
    end

    if findAny({ "界园_主页干员详情", "界园_主页干员详情蓝色" }) then
        log.debug()
        back()
        ssleep(.5)
    end


    -- 先导航到常规行动
    zl_navigation('黑流树海_常规行动', '黑流树海_进入主题')

    log("黑流树海进入done")

    --肉鸽 等级源石锭检查
    黑流树海完成 = zl_level_coin_inquire('黑流树海_常规行动', '黑流树海_等级检测范围', '黑流树海_源石锭检测范围')
    if 黑流树海完成 then
        return
    end

    -- 放弃探索
    if findAny({ "黑流树海_放弃本次探索", "黑流树海_信息丢失" }) then
        if not wait(function()
                if not findOne("黑流树海_信息丢失") then return true end
                tap("新战略确认")
            end, 5) then
            log.debug()
            return
        end
        if not wait(function()
                if findOne("返回确认界面") then return true end
                tap("黑流树海_放弃本次探索")
            end, 5) then
            log.debug()
            -- 无法直接放弃的情况 不处理
            if not appear("黑流树海_常规行动", 5) then
                log.debug()
                return
            end
            if not wait(function()
                    if findOne("黑流树海_常规行动") then return true end
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

                -- 处理肉鸽赠送干员页面
                if findAny({ "界园_主页干员详情", "界园_主页干员详情蓝色" }) then
                    log.debug()
                    back()
                    ssleep(.5)
                end

                tap("新战略确认")
                if findOne("黑流树海_常规行动") and not findOne("黑流树海_放弃本次探索") then
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
                log.debug()
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
    log("跳转完毕")
end

hlsh.战斗后领取 = function()
    local drop_page = false
    if not wait(function()
            if findOne("黑流树海_战略帮助") then return true end
            if not drop_page then tap("战略确认") end
            if findOne("黑流树海_战略帮助") then drop_page = true end
            if zl_only_coin then
                local x = findAny({ "黑流树海_领取完成" })
                log.debug(x)
                tap(x)
                if not wait(function()
                        tap(findAny({ "黑流树海_领取完成" }))
                        if findAny({ "战略返回", "黑流树海_战略帮助" }) then return true end
                    end, 2) then
                end
            end
            local x = appear({
                "黑流树海_源石锭领取", "黑流树海_藏品领取", "黑流树海_零件领取", "黑流树海_护盾领取", "黑流树海_零件确认领取", "黑流树海_零件叉叉"
            })
            log.debug(x)
            tap(x)

            -- 误触到招募券处理
            if findOne("确认招募") then
                -- 放弃招募
                log("招募流程")
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
            if findAny({ "黑流树海_常规行动", "黑流树海_战略帮助" }) and not findOne("确认招募") then
                return true
            end
        end, 30) then
        return false
    end
    return true
end

hlsh.招募处理 = function()
    log.debug()
    appear("黑流树海_右上角希望")
    wait(function()
        if findOne("黑流树海_沉沦树海进入") then return true end
        if findOne("黑流树海_战略帮助") then return true end
        local tj = appear({ "黑流树海_近卫招募卷", "黑流树海_辅助招募卷", "黑流树海_医疗招募卷" })
        log.debug(tj, "招募")
        if not tj then
            log.debug("没有招募卷")
            return
        else
            if tj == "黑流树海_辅助招募卷" or tj == "黑流树海_医疗招募卷" then
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
                        if findOne("黑流树海_右上角希望") then return true end
                    end, 10) then
                    return
                end
            elseif tj == "黑流树海_近卫招募卷" then
                ssleep(.1)
                log.debug()
                log('招募近卫')
                if not wait(function()
                        tap("黑流树海_近卫招募卷")
                        tap("招募说明关闭")
                        if not findOne("黑流树海_右上角希望") and not findOne("战略返回") then
                            return true
                        end
                        ssleep(0.2)
                    end, 10) then
                end
                disappear({ "黑流树海_右上角希望", "战略返回" })
                if not wait(function()
                        if findAny({ "黑流树海_右上角希望" }) then
                            log.debug()
                            return true
                        end
                        if findOne("返回确认界面") then
                            log.debug()
                            tap("左取消")
                            disappear("返回确认界面")
                            ssleep(.5)
                        end
                        log.debug(zl_best_operator)
                        local idx = str2int(zl_best_operator, -1)

                        if idx >= 1 and idx <= 12 then
                            -- 指定
                            tap("近卫招募列表" .. (zl_best_operator or 1))
                            findTap("确认招募")
                            tap("开包skip")
                        elseif idx == -1 then
                            -- 助战自动
                            zl_help_fight(0, '黑流树海_右上角希望', "黑流树海")
                        else
                            stop("请设置近卫干员序号(1~12)", '', true, false)
                        end
                    end, 120) then
                    return
                end
            end
        end
    end, 300)
end

hlsh.不期而遇处理 = function(战略帮助)
    local 战略帮助 = 战略帮助 or "黑流树海_战略帮助"
    log("进入不期而遇")
    tap("黑流树海_空白出发前往")
    disappear("黑流树海_战略帮助")
    if not wait(function()
            if findOne("黑流树海_右上角希望") then return true end
            tap("战略确认")
        end, 20) then
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
                            incident = ocrex("黑流树海_不期而遇关卡ocr范围")
                        else
                            incident = ocr("黑流树海_不期而遇关卡ocr范围")
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
                if string.finds(str, { "擒与缚", "与缚", "线人" }) then -- 二选第一个 或者 三选第二个 擒与缚
                    if zl_event_solve(8, 战略帮助) then return true end
                elseif string.finds(str, { "沉寂", "之屋", "临时", "中介所", "鸭托邦", "鸭", '湖中仙女', "湖中", "黑", "杠杆", "呼吸" }) then -- 三选第三个 如 沉寂之屋  临时中介所
                    if zl_event_solve(4, 战略帮助) then return true end
                elseif string.finds(str, { "洞中宝", "洞", "泪之", "和平", "桑尼", "多尼", "邀请" }) then -- 二选第二个 或者1选1  洞中宝
                    if zl_event_solve(2, 战略帮助) then return true end
                elseif string.finds(str, { "思乡", "心切", "乡", "传奇团伙", "传奇" }) then -- 二选第二个 或者3选2  思乡心切
                    if zl_event_solve(5, 战略帮助) then return true end
                elseif string.finds(str, { "沉重", "契约", "无人", "商店", "金色", "险路", "尽头" }) then -- 三选第一个  沉重的契约
                    if zl_event_solve(7, 战略帮助) then return true end
                elseif string.finds(str, { "货从口出", "口出", "血" }) then -- 四选第一个
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

hlsh.诡意行商处理 = function()
    if not wait(function()
            if findAny({ "诡意行商投资", "诡意行商离开" }) then return true end
            tap("黑流树海_空白出发前往")
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
        appear('黑流树海_放弃本次探索', 3)
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
end

hlsh.战斗开始 = function()
    --检查作战关卡名字
    if not zl.fight_name_ocr("黑流树海") then return end
    toast(now_fight_name)
    ssleep(1)
    if not wait(function()
            if findOne("快捷编队") then return true end
            tap("黑流树海_作战出发前往")
        end, 5) then
        log.debug("无法进入")
        zl_repos_path('黑流树海_放弃本次探索')
    end

    log.debug()
    -- 只带一个干员 点了天赋会带一个机械师
    if findOne("肉鸽编队开始游戏第二存在干员") then
        wait(function()
            tap("肉鸽编队开始游戏第一干员")
            if findOne("肉鸽编队左侧等级") then return true end
        end, 5)

        wait(function()
            tap("肉鸽编队页面第一干员")
            ssleep(0.5)
            if not findOne("肉鸽编队左侧等级") then return true end
        end, 5)

        wait(function()
            if not findOne("确认招募") then return true end
            if findOne("快捷编队") then return true end
            tap("确认招募")
            ssleep(0.5)
        end, 5)
    end
    --if not wait(function()
    -- if findOne("攻击范围") and
    --     (zl_skill_idx ~= 2 or zl_skill_idx == 2 and findOne("战略二技能")) then
    --     --tap("近卫招募列表2") --第2个干员
    --     --ssleep(.2)
    --     --tap("近卫招募列表3") --第3个干员
    --     --会把二战新招募的干员带上，如果招募了高费的导致下错人
    --     return true
    --

    -- tap("近卫招募列表1")
    -- if not appear("攻击范围", 1) then return end
    -- if zl_skill_idx == 2 then
    --     tap("战略二技能")
    --     if not appear("战略二技能", 1) then return end
    -- end
    --    end, 10) then
    --    return
    --end
    if zl_skill_idx == 2 and not findOne("肉鸽编队开始游戏第一干员切换二技能被选中") then
        wait(function()
            tap("肉鸽编队开始游戏第一干员切换二技能")
            if appear("肉鸽编队开始游戏第一干员切换二技能被选中", 0.5) then return true end
        end, 5)
    end

    log.debug()
    -- if not wait(function()
    --         if not findOne("确认招募") then return true end
    --         tap("确认招募")
    --     end, 10) then
    --     return
    -- end

    if not appear("快捷编队") then return end
    log("开始作战前")
    -- 开始游戏
    if not wait(function()
            tap("确认招募")
            if not findOne("快捷编队") then return true end
            if findTap("黑流树海_绿确认右") then
                ssleep(0.5)
            end
            -- 出现过在这儿卡死的
            if not disappear("正在提交反馈至神经", network_timeout) then
                restartapp(appid)
                return true
            end
        end, 10) then
        return
    end
    log.debug()
    -- 等待加载游戏界面
    if not wait(function()
            if findOne("单选确认框") then return true end
            if findOne("生命值") then return true end
            findTap("黑流树海_绿确认右")
        end, 60) then
        return
    end

    if not findOne("生命值") then return end

    -- 需要等等才能点两倍速
    appearTap("两倍速", 3)
    log.debug()
    -- 部署干员到关卡位置 只部署一个人的
    log("部署干员到关卡位置", now_fight_name, point.黑流树海_作战关卡[now_fight_name])
    zl_deploy(point.黑流树海_作战关卡[now_fight_name], 1)

    appear("生命值")
    log.debug()
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
                log.debug("超过3秒没看到生命值")
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
        log.debug()
        return restartapp(appid)
    end
    log.debug()
end

path.黑流树海 = function()
    log('start 黑流树海')
    -- 肉鸽每8小时做日常
    hlsh.跳转()

    local x_position = str2int(zl_team_position_hlsh, 1)
    while x_position > 4 do
        ssleep(0.5)
        path.swip_hd_shop(false, scale(1704))
        ssleep(0.5)
        x_position = x_position - 4
    end
    local t_position = zl_team_position_hlsh == str(x_position) and zl_team_position_hlsh or str(x_position)

    if not wait(function(reset_wait_start_time)
            findTap("黑流树海_开局藏品确认")
            -- if findOne("黑流树海_选择招募一阶段完成") then return true end
            if findOne("肉鸽第三近卫分队") then return true end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
            if findOne("黑流树海_选择支援页面") then return true end
            tap('萨卡兹_蓝图分队位置列表' .. t_position)
            ssleep(0.5) --太快了直接选错招募券组合
        end, 20) then
        return
    end

    local page = nil
    -- 会出额外藏品
    log.debug()
    if appear("黑流树海_选择支援页面", 0.5) then
        log.debug()
        ssleep(0.2)
        appear("界园_藏品选择横线", 5)
        ssleep(0.1)
        page = sample("界园进度")
        local best = 2
        for i = 1, 3 do
            local fret = find_color("黑流树海_藏品范围" .. i, "D13464", 0, 0.8) -- 红色
            log.debug(i, fret)
            local fretb = find_color("黑流树海_藏品范围" .. i, "38D0D4")
            log.debug(fretb)
            if not fret and fretb then
                best = i
                log.debug(best)
            end
        end
        if not wait(function(reset_wait_start_time)
                if findOne("黑流树海_选择招募最后阶段") then return true end
                if not findOne(page) then return true end
                tap('黑流树海_藏品点击列表' .. best)
                tap('黑流树海_藏品点击列表' .. best)
                ssleep(0.5)
            end, 10) then
        end
    end

    -- ssleep(0.5)
    if not wait(function(reset_wait_start_time)
            -- if findOne("界园_选择招募二阶段") then return true end
            if findOne("黑流树海_选择招募最后阶段") then return true end
            if findAny({
                    "战略助战", "放弃招募", "剿灭说明",
                }) then
                return true
            end
            tap("肉鸽第三近卫分队")
            ssleep(0.1)
            tap("黑流树海_肉鸽近卫分队确认")
            ssleep(0.1)
        end, 10) then
    end
    ssleep(0.5)
    log.debug()
    if not wait(function(reset_wait_start_time)
            findTap("招募说明关闭")
            if findAny({ "黑流树海_近卫招募卷", "黑流树海_医疗招募卷", "黑流树海_辅助招募卷", "黑流树海_右上角希望", "黑流树海_选择招募最后阶段" }) then
                return true
            end
            if findAny({
                    "战略助战", "放弃招募", "剿灭说明",
                }) then
                tap("放弃招募")
                if findOne("剿灭说明") then tap("剿灭说明") end
                if findAny({ "黑流树海_近卫招募卷", "黑流树海_右上角希望", "黑流树海_选择招募最后阶段" }) then
                    return true
                end
                disappear("放弃招募", 0.1)
                if not wait(function()
                        tap("右右确认")
                        ssleep(.1)
                        if findOne("剿灭说明") then tap("剿灭说明") end
                        if findAny({ "黑流树海_近卫招募卷", "黑流树海_右上角希望", "黑流树海_选择招募最后阶段" }) then
                            return true
                        end
                    end, 10) then
                    return true
                end
            end
            ssleep(.1)
        end, 10) then
        return
    end

    hlsh.招募处理()

    log.debug()
    if not appear({ "黑流树海_右上角希望", "黑流树海_沉沦树海进入", "黑流树海_战略帮助" }, 20) then return end
    -- 进入探索 必须分为两段，否则产生位移
    if not wait(function()
            if not findOne("黑流树海_右上角希望") then return true end
            if findOne("黑流树海_战略帮助") then return true end
            tap("黑流树海_沉沦树海进入")
        end, 15) then
        return
    end
    ssleep(2)

    log.debug()

    --点击进入探索之后，有一段时间的加载界面，需要点击
    local xtime = time()
    if not wait(function()
            if findOne("黑流树海_战略帮助") then return true end
            tap("战略确认")
            appear("黑流树海_右上角希望", 0.3)
            --第一次会弹出‘战略帮助’那个界面
            if time() - xtime > 3 * 1000 then
                xtime = time()
                tap("招募说明关闭")
            end
        end, 10) then -- 这次肉鸽动画时间很长
        return
    end
    ssleep(0.5) -- 右边第三列有概率加载过慢

    -- 判断地图
    log("开始判断地图")
    local 地图序号 = appear({ "黑流树海地图列表1", "黑流树海地图列表2", "黑流树海地图列表3", "黑流树海地图列表4", "黑流树海地图列表5" }, 10, 0.1)
    log("黑流树海地图", 地图序号)

    if 地图序号 == "黑流树海地图列表1" or 地图序号 == "黑流树海地图列表2" then
        地图序号 = "1"
    elseif 地图序号 == "黑流树海地图列表3" or 地图序号 == "黑流树海地图列表4" then
        地图序号 = "2"
    elseif 地图序号 == "黑流树海地图列表5" then
        地图序号 = "3"
    else
        log.error("未识别地图序号")
        return
    end

    local 最优路线 = 1
    local 最优得分 = -100
    local map = {}

    for i = 1, 4 do
        local xmap = {}
        local 线路得分 = 0
        local 待ocr列表 = point["黑流树海地图" .. 地图序号 .. "线路" .. str(i) .. "OCR范围"]
        if not 待ocr列表 then
            goto continue
        end
        for j = 1, #待ocr列表 do
            local ocr范围 = 待ocr列表[j]
            local ocr结果 = ocrex_ret(ocr范围, true)
            log.debug("ocr范围", ocr范围, "ocr结果", ocr结果)
            if string.finds(ocr结果, { "作战" }) then
                线路得分 = 线路得分 - 10
                table.insert(xmap, "作战")
            elseif string.finds(ocr结果, { "凶" }) then
                线路得分 = 线路得分 - 10
                table.insert(xmap, "作战")
            elseif string.finds(ocr结果, { "诡" }) then
                线路得分 = 线路得分 + 5
                table.insert(xmap, "非作战")
            else
                table.insert(xmap, "空坐标")
            end
        end
        log.debug("线路", i, "得分", 线路得分)
        if 线路得分 > 最优得分 then
            最优得分 = 线路得分
            最优路线 = i
            map = shallowCopy(xmap)
        end
        ::continue::
    end

    table.insert(map, 1, "作战")
    if 地图序号 == "3" then
        table.insert(map, "非作战")
    end

    table.insert(map, "尽头")
    log.debug("地图", 地图序号, map, "最优路线", 最优路线, "最优得分", 最优得分)

    local 缩放函数 = function()
        wait(function()
            if findOne("黑流树海放大镜加号") then return true end
            tap("黑流树海放大镜减号")
            appear("黑流树海放大镜加号", 0.5)
            if appear("黑流树海放大镜加号", 0.5) then return true end
        end, 10)
    end
    local 关卡坐标 = point["黑流树海地图" .. 地图序号 .. "关卡列表" .. str(最优路线)]
    for i = 1, #map do
        local node = map[i]
        log.debug("当前节点", i, node)
        缩放函数()
        ssleep(0.2)
        tap(关卡坐标[i])
        if node == "作战" then
            log("点击作战")
            if not appear("黑流树海_作战页面出现", 5) then
                log.debug("无法进入")
                return
            end
            hlsh.战斗开始()
            log.debug()
            hlsh.战斗后领取()
        elseif node == "非作战" or node == "空坐标" then
            log("黑流树海_非作战")
            if not zl.fight_name_ocr("黑流树海") then return end
            toast(now_fight_name)
            if string.finds(now_fight_name, { "不期而遇", "林间空地", "得偿所愿", "安全的角落" }) then
                hlsh.不期而遇处理()
            elseif now_fight_name == "诡意行商" then
                hlsh.诡意行商处理()
            else
                log.debug("未知非作战事件", now_fight_name)
                --pass
            end
        elseif node == "尽头" then
            log("黑流树海_尽头")
            hlsh.不期而遇处理()
        end
    end

    if not wait(function()
            ssleep(0.3)
            findTap('战略返回')
            if findAny({ "黑流树海_常规行动" }) then return true end
            ssleep(0.5)
        end, 45) then
        log.warn("第二层退出返回失败")
        back()
        return
    end
    return
end
