萨卡兹_蓝图分队 = function()
    log('start skz')
    if findOne("萨卡兹_戛然而止") then
        log('萨卡兹_戛然而止')
        wait(function()
            if findAny({ "萨卡兹_常规行动", "面板" }) then return true end
            tap("新战略确认")
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
            path.萨卡兹的无终奇语前瞻投资(true)
        else
            path.跳转("首页")
        end
    end

    --判断是否在其他界面
    local jumpout
    if findOne("战略返回") then path.fallback.战略返回() end
    if findOne("暂停中") and findOne("生命值") then restartapp(appid) end

    -- 先导航到常规行动
    zl_navigation('萨卡兹_常规行动', '萨卡兹的无终奇语进入主题')

    --肉鸽 等级源石锭检查
    zl_level_coin_inquire('萨卡兹_常规行动', '萨卡兹_等级检测范围', '萨卡兹_源石锭检测范围')

    -- 放弃探索
    if findOne("萨卡兹_放弃本次探索") then
        if not wait(function()
                if findOne("返回确认界面") then return true end
                tap("萨卡兹_放弃本次探索")
            end, 5) then
            log(2608)
            -- 无法直接放弃的情况 不处理
            if not wait(function()
                    if not findOne("萨卡兹_常规行动") then return true end
                    tap("萨卡兹_继续探索")
                    ssleep(.5)
                    log(2613)
                end, 5) then
                return
            end

            if not wait(function()
                    if findOne("萨卡兹_常规行动") then return true end
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
                if findOne("萨卡兹_常规行动") and not findOne("萨卡兹_放弃探索") then
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
        end, 15) then
        -- 初始选难度
        tap('萨米_难度选择确认')

        return
    end
    if jumpout then return end
    log(2650)
    -- 开始探索 一路按到 招募干员
    -- local first_time_see_first_card = 0

    local tapy = scale(904)
    local tapx = scale(258) + scale(414) * (tonumber(zl_blueprint_position) - 1)
    if not wait(function(reset_wait_start_time)
            if findOne("萨卡兹_初始招募") then return true end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
            tap({ tapx, tapy })
            tap({ tapx, tapy })
            tap({ tapx, tapy })
        end, 10) then
        return
    end

    if not wait(function(reset_wait_start_time)
            if findOne("萨卡兹_初始招募") then return true end
            tap("萨卡兹_近卫招募券")
        end, 10) then
        return
    end

    log('招募近卫')
    if not wait(function()
            tap("近卫招募券")
            tap("招募说明关闭")
            if not findOne("萨卡兹_初始招募") and findOne("确认招募") then
                return true
            end
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
            if findOne("萨卡兹_初始招募") then return true end
        end, 10) then
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
            tap("放弃招募")
            if findOne("剿灭说明") then tap("剿灭说明") end
            if not findOne("确认招募") then return true end
        end, 10) then
        return
    end

    if not wait(function()
            tap("右右确认")
            if findOne("剿灭说明") then tap("剿灭说明") end
            if findOne("萨卡兹_初始招募") then return true end
        end, 10) then
        return
    end

    --ssleep(1)
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
            tap("放弃招募")
            if findOne("剿灭说明") then tap("剿灭说明") end
            if not findOne("确认招募") then return true end
        end, 10) then
        return
    end

    if not wait(function()
            tap("右右确认")
            if findOne("剿灭说明") then tap("剿灭说明") end
            if findOne("萨卡兹_初始招募") then return true end
        end, 10) then
        return
    end


    if not appear("萨卡兹_初始招募") then return end
    log(2698)
    -- 进入探索 必须分为两段，否则产生位移
    if not wait(function()
            if not findOne("萨卡兹_初始招募") then return true end
            tap("萨卡兹_进入探索")
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
            if time() - xtime > 3 * 1000 then
                xtime = time()
                tap("招募说明关闭")
            end
        end, 15) then
        return
    end

    appear("萨卡兹_进入后判断", 5)
    ssleep(0.5) -- 右边第三列有概率加载过慢
    sx = { scale(1761), scale(846) }
    oricol = getColor(sx[1], sx[2])
    if not wait(function()
            if getColor(sx[1], sx[2]) ~= oricol then
                return true
            end
            tap("萨卡兹_第一列_作战列表1")
        end, 5) then
        return
    end

    关卡刷新 = function()
        appear("萨卡兹_出发前往", 1)
        appear("萨卡兹_出发前往2", 1)
        log("关卡刷新")
        ssleep(0.1)
        --if not findOne("萨卡兹_出发前往紧急作战") and not findOne("萨卡兹_出发前往普通作战") then return end
        local po = find_color("萨卡兹_刷新按钮范围", "FCFCF9", 1, 0.95)
        if not findOne("萨卡兹_出发前往紧急作战") and not findOne("萨卡兹_出发前往普通作战") then
            return
        end
        log("刷新按钮位置", po)
        if po then
            log("开始刷新")
            tap(po)
            appearTap("萨卡兹_刷新确认")
            disappear("萨卡兹_刷新确认")
        end
        wait(function()
            if find_color("萨卡兹_刷新按钮范围", "FCFCF9|6A6A6A") then return end
            ssleep(0.1)
        end, 1.2)
        po = find_color("萨卡兹_刷新按钮范围", "FCFCF9", 1, 0.95)
        log("刷新按钮位置", po)
        if po and findAny({ "萨卡兹_出发前往紧急作战", "萨卡兹_出发前往普通作战" }) then
            log("开始刷新")
            tap(po)
            appearTap("萨卡兹_刷新确认")
            disappear("萨卡兹_刷新确认")
        end
    end
    -- ssleep(100)
    关卡刷新()
    ssleep(0.5)
    if not wait(function()
            if findOne("萨卡兹_作战列表2选中") then
                return true
            end
            tap("萨卡兹_第一列_作战列表2")
            appear("萨卡兹_作战列表2选中")
        end, 5) then
        return
    end
    ssleep(0.15)
    关卡刷新()

    -- 思绪过多,丢掉一个
    if findOne("萨卡兹_思维负荷红") then
        tap("萨卡兹_收起负荷干员")
        appear("萨卡兹_等待负荷干员列表出现", 2)
        tap("萨卡兹_第一个思绪")
        appearTap("萨卡兹_思绪舍弃", 1)
        ssleep(.5)
        appearTap("萨卡兹_收起负荷干员", 1.5)
        appear("萨卡兹_待编入负荷干员", 1)
    end
    ssleep(0.3)
    wait(function()
        tap({ scale(134), scale(504) })
        ssleep(0.1)
    end, 1)
    ssleep(1)

    -- 分支选择 返回每一列行数

    萨卡兹路线 = 萨卡兹_分支选择()
    log("路线选择", 萨卡兹路线)
    log('在选择节点界面')

    if 萨卡兹路线[1][2] ~= "不期而遇" then
        log("第一列不存在不期而遇")
        return zl_repos_path('萨卡兹_放弃本次探索')
    end

    sx = { scale(1761), scale(846) }
    oricol = getColor(sx[1], sx[2])
    if not wait(function()
            if getColor(sx[1], sx[2]) ~= oricol then
                return true
            end
            tap("萨卡兹_第一列_作战列表" .. 萨卡兹路线[1][1])
        end, 5) then
        return
    end
    table.remove(萨卡兹路线, 1)
    ssleep(.5)
    appear("萨卡兹_不期而遇判断", 3)
    不期而遇处理 = function()
        --判断不期而遇事件，并处理
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
            toast('进入不期而遇出错,可能误点到了什么')
            return restartapp(appid)
        end

        log('处理不期而遇事件')
        if not wait(function()
                local x = function()
                    local incident
                    local t = time()
                    if not wait(function()
                            incident = ocr("萨卡兹_不期而遇事件名字检测")
                            if time() - t > 1000 then --不期而遇事件，偶尔下面的 '√' 会一直存在，间隔点击一次
                                t = time()
                                log(366)
                                if not findOne('萨米_希望源石锭界面') then tap("萨卡兹_不期而遇确认点击") end
                            end
                            if incident[1] then return true end
                            if findOne("萨卡兹_战略帮助") then return true end
                        end, 8) then
                        return false
                    end
                    if not incident[1] then return false end
                    local str = incident[1].text
                    log('事件名字：', str)
                    if findOne("萨卡兹_思维界面") then tap("萨卡兹_思维返回") end
                    if findOne('萨卡兹_不期而遇确认') then tap("萨卡兹_不期而遇确认点击") end
                    if string.finds(str, { "虫" }) then
                        if zl_event_solve(3, "萨卡兹_战略帮助") then return true end
                    elseif string.finds(str, { '相遇', '解', '故事', '高空', '不散' }) then
                        if zl_event_solve(2, "萨卡兹_战略帮助") then return true end
                    elseif string.finds(str, { "萨米", "维", "女士" }) then
                        if zl_event_solve(1, "萨卡兹_战略帮助") then return true end
                    end
                end
                if x() then return true end
                if findOne("萨卡兹_战略帮助") then return true end
            end, 30) then
            return false
        end
    end

    不期而遇处理()
    ssleep(0.5)
    if findOne("萨卡兹_思维界面") then tap("萨卡兹_思维返回") end
    if not wait(function()
            if findOne("战略返回") then return true end
            if findOne("萨卡兹_思维界面") then tap("萨卡兹_思维返回") end
        end, 3) then
    end

    -- 第二列
    不期而遇关卡寻找 = function()
        log('不期而遇关卡寻找')
        local po = find_color("萨卡兹_不期而遇关卡查找_列范围", "378892")
        if po then
            iwait(function()
                tap(po)
                ssleep(0.1)
            end, 0.6)
            return true
        end
    end

    sx = { scale(1761), scale(846) }
    oricol = getColor(sx[1], sx[2])
    log("每列节点", 萨卡兹路线[1][3])
    log(萨卡兹路线)
    if not wait(function()
            if getColor(sx[1], sx[2]) ~= oricol then
                return true
            end
            tap("萨卡兹_" .. 萨卡兹路线[1][3] .. "节点_作战列表" .. 萨卡兹路线[1][1])
        end, 5) then
        return
    end
    if 萨卡兹路线[1][2] ~= "不期而遇" then
        ssleep(0.5)
        关卡刷新()
        ssleep(1)
        if not findOne("萨卡兹_不期而遇判断") then
            不期而遇关卡寻找()
            if not findOne("萨卡兹_不期而遇判断") then
                return zl_repos_path('萨卡兹_放弃本次探索')
            end
        end
    end
    table.remove(萨卡兹路线, 1)
    ssleep(.5)
    appear("萨卡兹_不期而遇判断", 3)
    不期而遇处理()

    ssleep(0.5)
    if findOne("萨卡兹_思维界面") then tap("萨卡兹_思维返回") end
    if not wait(function()
            if findOne("战略返回") then return true end
            if findOne("萨卡兹_思维界面") then tap("萨卡兹_思维返回") end
        end, 3) then
    end

    -- 第三列
    sx = { scale(1761), scale(846) }
    oricol = getColor(sx[1], sx[2])
    log("每列节点", 萨卡兹路线[1][3])
    log(萨卡兹路线)
    if not wait(function()
            if getColor(sx[1], sx[2]) ~= oricol then
                return true
            end
            tap("萨卡兹_" .. 萨卡兹路线[1][3] .. "节点_作战列表" .. 萨卡兹路线[1][1])
        end, 5) then
        return
    end
    if 萨卡兹路线[1][2] ~= "不期而遇" then
        关卡刷新()
        if not findOne("萨卡兹_不期而遇判断") then
            不期而遇关卡寻找()
            if not findOne("萨卡兹_不期而遇判断") then
                return zl_repos_path('萨卡兹_放弃本次探索')
            end
        end
    end
    table.remove(萨卡兹路线, 1)
    ssleep(.5)
    appear("萨卡兹_不期而遇判断", 3)
    不期而遇处理()

    ssleep(0.5)
    if findOne("萨卡兹_思维界面") then tap("萨卡兹_思维返回") end
    if not wait(function()
            if findOne("战略返回") then return true end
            if findOne("萨卡兹_思维界面") then tap("萨卡兹_思维返回") end
        end, 3) then
    end

    -- 商店
    sx = { scale(1761), scale(846) }
    oricol = getColor(sx[1], sx[2])
    if not wait(function()
            if findOne("萨卡兹_商店进入") then
                return true
            end
            tap("萨卡兹_地图商店坐标")
        end, 5) then
        return
    end
    ssleep(.5)

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

    return goto_next_level()
end
