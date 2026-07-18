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
    -- 还没修
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

hlsh.战斗开始 = function()
    -- 还没修

    --检查作战关卡名字
    log.debug()
    if not zl.fight_name_ocr("界园") then return end
    toast(now_fight_name)
    ssleep(1)
    if not wait(function()
            if findOne("快捷编队") then return true end
            tap("界园_作战_进入")
        end, 5) then
        log.debug("无法进入")
        zl_repos_path('界园_放弃探索')
    end
    log.debug()
    if not wait(function()
            if findOne("确认招募") then return true end
            tap("快捷编队")
        end, 10) then
        return
    end
    log.debug()
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
    log.debug()
    if not wait(function()
            if not findOne("确认招募") then return true end
            tap("确认招募")
        end, 10) then
        return
    end

    if not appear("快捷编队") then return end
    log.debug()
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
    log.debug()
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
    log.debug()
    -- 部署干员到关卡位置 只部署一个人的
    zl_deploy(point.界园_作战关卡[now_fight_name], 1)

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

    exit()

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

    local 路线结果 = {}
    local 最优路线
    local 最优得分 = -100
    for i = 1, 4 do
        local 线路得分 = 0
        local ocr范围 = "黑流树海地图" .. 地图序号 .. "线路" .. str(i) .. "OCR范围"
        local 待ocr列表 = point[ocr范围]
        if not 待ocr列表 then
            goto continue
        end
        for j = 1, #待ocr列表 do
            local ocr范围 = 待ocr列表[j]
            local ocr结果 = ocrex_ret(ocr范围, true)
            log.debug("ocr范围", ocr范围, "ocr结果", ocr结果)
            if string.finds(ocr结果, { "作战" }) then
                线路得分 = 线路得分 - 10
            elseif string.finds(ocr结果, { "凶" }) then
                线路得分 = 线路得分 - 10
            elseif string.finds(ocr结果, { "诡" }) then
                线路得分 = 线路得分 + 5
            end
        end
        log.debug("线路", i, "得分", 线路得分)
        路线结果[i] = 线路得分
        if 线路得分 > 最优得分 then
            最优得分 = 线路得分
            最优路线 = i
        end
        ::continue::
    end
    log.debug("地图", 地图序号, "路线结果", 路线结果, "最优路线", 最优路线, "最优得分", 最优得分)

    local 缩放函数 = function()
        wait(function()
            if findOne("黑流树海放大镜加号") then return true end
            tap("黑流树海放大镜减号")
            appear("黑流树海放大镜加号", 0.5)
            if appear("黑流树海放大镜加号", 0.5) then return true end
        end, 10)
    end

    log("准备进入第一关作战")
    local 右上角取样 = sample("投币提示")
    ssleep(.5)
    if not wait(function()
            tap("萨卡兹_第一列_作战列表" .. 第一列关卡)
            if findOne('界园_作战页面加载') then return true end
            if not findOne(右上角取样) then
                log.debug()
                ssleep(0.5)
                return true
            end
        end, 10) then
        log.debug("无法进入")
        zl_repos_path('界园_放弃探索')
    end
    log.debug()
    if zl_skip_fight and not zl_big_map then
        sui.放弃作战()
    else
        sui.战斗开始()
    end
    log.debug()
    local r = appear({ "战略返回", '界园_戛然而止', '界园_戛然而止2', "界园_作战失败结算" }, 30)
    if r ~= "战略返回" then
        -- back()
        if not appear("界园_常规行动", 5) then
            log.debug("无法返回常规行动")
            restart()
            return
        end
        return
    end
    if not findOne("战略返回") then return end

    if not zl_skip_fight and not sui.战斗后领取() then
        log.warn("未能完成战斗后拾取")
        return false
    end

    if zl_big_map and zl_skip_fight and not sui.战斗后领取() then
        log.warn("未能完成战斗后拾取")
        return false
    end

    log("完成战斗")

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
            log.warn("未能进入作战列表")
            return false
        end
    end

    if 界园路线选择结果[1][2] == "作战" then
        log("准备进入第2关作战")
        ssleep(.5)
        if zl_skip_fight and zl_big_map then
            sui.放弃作战()
        else
            sui.战斗开始()
        end
        appear({ "战略返回", '界园_戛然而止', '界园_戛然而止2', "界园_作战失败结算" }, 30)
        if findAny({ "界园_戛然而止", "界园_戛然而止2" }) then
            log('戛然而止界面，准备返回')
            return
        end
        if findOne("界园_作战失败结算") then
            作战结算返回()
            if not appear("界园_常规行动", 5) then
                log.debug("无法返回常规行动")
                return
            end
            return
        end
        if not findOne("战略返回") then return end
        if not zl_skip_fight and not sui.战斗后领取() then
            log.warn("未能完成战斗后拾取")
            return false
        end
        if zl_big_map and zl_skip_fight and not sui.战斗后领取() then
            log.warn("未能完成战斗后拾取")
            return false
        end
        log("完成战斗")
    else
        sui.不期而遇处理()
    end

    appear("黑流树海_右上角希望")

    -- 第三列商店
    local 商店关卡寻找 = function()
        log('商店关卡寻找')
        local po = find_color("界园_商店关卡查找_列范围", "039D54", 2, 0.95)
        log("商店关卡位置", po)
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
        log.warn("第二层退出返回失败")
        back()
        return
    end
    return
end

hlsh.招募并记录干员 = function(t)
    if not t then return end
    if t.name then
        zl.招募翻页(1)
        if page > 0 then
            for i = 1, page do
                zl.招募翻页()
            end
        end
        if table.findk(肉鸽参数["operators"], name) then
            肉鸽参数["operators"][name] = {
                name = t.name,
                level = t.level,
                elite = t.elite,
            }
        end
    end
    zl.选择干员(t.index)
end

hlsh.招募指定干员 = function(干员, 肉鸽白名单)
    local name, idx, elite, level = zl.查找指定干员(干员, 肉鸽白名单)
    log(name, idx)
    if name and name ~= 0 then
        肉鸽参数["operators"][name] = {
            name = name,
            level = level,
            elite = elite,
        }
    end
    zl.选择干员(idx)
end

hlsh.普通作战1 = function()
    log('界园肉鸽')
    sui.recruit_info = zl.加载干员招募评分("sui")
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
            维什戴尔 = {},
            谷米 = {},
            卡达 = {},
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
    sui.招募指定干员("维什戴尔", 肉鸽白名单)

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
    sui.招募指定干员("古米", 肉鸽白名单)
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
    sui.招募指定干员("卡达", 肉鸽白名单)
    log(肉鸽参数["operators"])
    --if not appear("界园_初始招募") then return end
    log.debug()
    -- 进入探索 必须分为两段，否则产生位移
    if not wait(function()
            if findOne("界园_投出通宝确认") then return true end
            tap("界园_进入探索")
            ssleep(.5)
        end, 25) then
        return
    end
    ssleep(1)
    if findOne("界园_投出通宝确认") then
        当前通宝 = sui.判断投出通宝()
        tap("界园_投出通宝确认")
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
        if 作战名 then
            if not wait(function()
                    if findOne("快捷编队") then return true end
                    tap("界园_作战_进入")
                    ssleep(.5)
                end, 5) then
            end
        end
        zl.快捷编队()
    end
end

hlsh.进入作战 = function()
    local 作战名 = sui.作战名ocr校正(ocro("界园_作战检测范围"))
    log(作战名)
    if not wait(function()
            if findOne("快捷编队") then return true end
            tap("进入节点")
            ssleep(.2)
        end, 5) then
        log.debug("无法进入")
        --zl_repos_path('界园_放弃探索')
    end
end

hlsh.作战名ocr校正 = function(t)
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
