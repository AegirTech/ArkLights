-- ===========================================
--               界园肉鸽相关
-- ===========================================


jieyuan = {}

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
        end

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
            if time() - t > 2 * 1000 then --第一次时候，需要选择难度等级
                ssleep(1)
                t = time()
                log('选择一次难度等级')
                tap({ scale(1759), scale(567) })
            end
        end, 60) then
        -- 初始选难度
        tap('难度选择确认')

        return
    end
    if jumpout then return end

    -- 开始探索 一路按到 招募干员
    if not wait(function(reset_wait_start_time)
            if findOne("界园_选择招募二阶段") then return true end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
            tap("新战略确认")
        end, 10) then
        return
    end

    log('招募近卫')
    if not wait(function()
            tap("近卫招募券")
            tap("招募说明关闭")
            if not findOne("肉鸽_右上角希望") then
                return true
            end
        end, 10) then
        return
    end

    if not wait(function()
            if findAny({ "肉鸽_右上角希望", "战略返回" }) then
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
                zl_help_fight(0, '肉鸽_右上角希望')
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

    if not appear("肉鸽_右上角希望") then return end
    log(2698)

    -- 进入探索 必须分为两段，否则产生位移
    if not wait(function()
            if not findOne("肉鸽_右上角希望") then return true end
            tap("界园_进入探索")
        end, 5) then
        return
    end

    log(2700)
    --点击进入探索之后，有一段时间的加载界面，需要点击
    local xtime = time()
    if not wait(function()
            if findOne("战略返回") then return true end
            tap("战略确认")
            tap("界园_每层通宝确认")
            appear("肉鸽_右上角希望", 1.5)
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
    if not 界园路线选择结果 then
        log("第二列没有不期而遇")
        return
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

    -- 目前写到这里了

    ::fight_first::
    log("准备进入第一关作战")
    ssleep(.5)
    if not wait(function()
            tap("萨卡兹_第一列_作战列表" .. 第一列关卡)
            if findOne('界园_作战页面加载') then return true end
        end, 5) then
        -- in_fight_return = "无法进入第一关"
        zl_repos_path('界园_放弃探索')
        goto fight_first
    end

    --检查作战关卡名字
    if not zl.fight_name_ocr() then return end
    toast(now_fight_name)
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

    -- 部署干员到关卡位置
    zl_deploy(point.萨卡兹_作战关卡[now_fight_name])

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
        end, 300) then
        return restartapp(appid)
    end

    appear({ "战略返回", '界园_戛然而止' }, 30)
    if findOne("界园_戛然而止") then
        log('戛然而止界面，准备返回')
        return
    end
    if not findOne("战略返回") then return end

    if not zl_fight_after_skz() then
        log("未能完成战斗后拾取")
        return false
    end
    log("完成战斗")

    -- 第二列是不期而遇/得偿所愿
    if 界园路线选择结果[1][2] == "不期而遇" then
        --进入不期而遇
        log("进入不期而遇")
        appear('萨卡兹_不期而遇节点出现')
        wait(function()
            tap("萨卡兹_进入")
            tap("萨卡兹_思维混乱确认红") --偶尔有情况 思维负载太多了，第一第二个节点都是作战时候，第三个节点有概率出现
        end, 2)
        if not wait(function()
                if not findOne("萨米_战略帮助") then return true end
                tap("战略确认")
            end, 15) then
            return sarkaz.restart('进入不期而遇出错,可能误点到了什么') --减少重启次数
        end

        --判断不期而遇事件，并处理
        log('处理不期而遇事件')
        if not wait(function()
                local x = function()
                    local incident
                    local t = time()
                    if not wait(function()
                            incident = ocr("萨卡兹_不期而遇事件名字检测")
                            if time() - t > 1000 then --不期而遇事件，偶尔下面的 '√' 会一直存在，间隔点击一次
                                t = time()
                                if not findOne('萨米_希望源石锭界面') then
                                    tap({ scale(960), scale(935) }) --更上面一点，防止误触
                                end
                            end
                            if incident[1] then return true end
                            if findOne("萨卡兹_战略帮助") then return true end
                        end, 8) then
                        return false
                    end
                    if not incident[1] then return false end
                    local str = incident[1].text
                    log('事件名字：', str)
                    if findOne('萨卡兹_不期而遇确认') then tap("萨卡兹_不期而遇确认点击") end
                    if string.finds(str, { "虫" }) then
                        if zl_event_solve(3, "萨卡兹_战略帮助") then return true end
                    elseif string.finds(str, { '故事', '高空', '不散' }) then
                        if zl_event_solve(2, '相遇', "萨卡兹_战略帮助") then return true end
                    elseif string.finds(str, { '解', '惑', "萨米", "维", "女士" }) then
                        if zl_event_solve(1, "萨卡兹_战略帮助") then return true end
                    end
                end
                if x() then return true end
                if findOne("萨卡兹_战略帮助") then return true end
            end, 30) then
            return false
        end

        -- 检查是否点到思维界面
        ssleep(0.5)
        if findOne("萨卡兹_思维界面") then tap("萨卡兹_思维返回") end
        if not wait(function()
                if findOne("战略返回") then return true end
                if findOne("萨卡兹_思维界面") then tap("萨卡兹_思维返回") end
            end, 3) then
        end

        goto fight_select
    end

    if 界园路线选择结果[1][2] == "得偿所愿" then
    end

    -- 第三列商店
    if not wait(function()
            if findOne("萨卡兹_商店进入") then
                return true
            end
            tap("萨卡兹_地图商店坐标")
        end, 5) then
        return
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
            tap("萨卡兹_思维混乱确认红") --偶尔有情况 思维负载太多了，第一第二个节点都是作战时候，第三个节点有概率出现
        end, 3) then
        return zl_repos_path('萨卡兹_放弃本次探索')
    end

    --check_goods()

    --投币

    if not zl_skip_coin then zl_shop_coin() end
    if zl_only_coin then
        log('只是投币，准备退出')
        findTap('战略退出')
        appear('萨卡兹_放弃本次探索', 3)
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

    -- 第四列 误入奇境

    return goto_next_level()
end
