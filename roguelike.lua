-- 肉鸽通用函数
zl = {}
-- 萨卡兹肉鸽函数
sarkaz = {}
sarkaz.跳转 = function()
    if findOne("萨卡兹_戛然而止") then
        log('萨卡兹_戛然而止')
        wait(function()
            if findAny({ "萨卡兹_常规行动", "面板" }) then return true end
            tap("新战略确认")
        end, 15)
        return
    end

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
    if findOne("战略返回") then path.fallback.战略返回其他肉鸽() end
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
end

zl.招募干员 = function(干员, 肉鸽白名单)
    log("肉鸽招募干员", 干员)
    log(肉鸽白名单)
    local 被招募干员
    appear("确认招募", 3)
    ssleep(1)
    if type(干员) == "string" then
        for j = 1, 5 do --页
            for i = 0, 7 do
                point.肉鸽干员识别范围 = { scale(936 + 585 * math.floor(i / 4)), scale(259 + 205 * (i % 4)), scale(1125 +
                    585 * math.floor(i / 4)), scale(294 + 205 * (i % 4)) }
                被招募干员 = correctCharName(ocro("肉鸽干员识别范围"))
                log(i, 被招募干员)
                if table.includes(肉鸽白名单, 被招募干员) then
                    --tap("近卫招募列表" .. (i + 1))
                    if table.includes(肉鸽队员, 被招募干员) then
                        table.insert(肉鸽队员, 被招募干员)
                    elseif 被招募干员 == "维什戴尔" then
                        招募开局干员 = 1
                    end
                    return (i + 1)
                end
            end
            ssleep(.5)
            zl.招募翻页()
        end
    end
    return 1
end

zl.招募翻页 = function(left, nodelay)
    local duration
    local finger
    local delay
    if left then
        local x1 = scale(600)
        local x2 = scale(10000 / 720 * 1080)
        local y1 = scale(533)
        duration = 400
        finger = { { point = { { x1, y1 }, { x2, y1 } }, duration = duration } }
        delay = 750
    else
        local x = scale(616)
        local y = scale(533)
        local y2 = scale(900)
        --修改x2坐标
        local x2 = scale(1200)
        local x3 = scale(1695)
        local y3 = scale(452)
        local slids = 50
        local slidd = 200
        local taps = slids + slidd + 150
        local tapd = 200
        local downd = taps + 100
        duration = downd
        finger = {
            { point = { { x, y }, { x, y2 } },    start = 0,     duration = downd },
            { point = { { x2, y }, { x2, y3 } },  start = slids, duration = slidd },
            { point = { { x3, y3 }, { x3, y3 } }, start = taps,  duration = tapd },
        }
        delay = 250
    end
    log(JsonEncode(finger))
    gesture(finger)
    sleep(duration + (nodelay and 0 or delay))
    return nodelay and delay or 0
end

zl.选择干员 = function(idx)
    if not wait(function()
            if findAny({ "萨卡兹_初始招募", "战略返回" }) then
                log(26)
                return true
            end
            if findOne("返回确认界面") then
                log(27)
                -- 虽然不知道会不会走这儿
                tap("左取消")
                disappear("返回确认界面")
                -- 不等会怎么样呢，有时会闪
                ssleep(.5)
            end
            log(idx)
            if idx >= 1 and idx <= 12 then
                -- 指定
                tap("近卫招募列表" .. idx)
                findTap("确认招募")
                tap("开包skip")
            elseif idx == -1 then
                -- 助战自动
                zl_help_fight(0, '萨卡兹_初始招募')
            else
                stop("请设置近卫干员序号(1~12)", '', true, false)
            end
        end, 120) then
        return
    end
end

sarkaz.关卡刷新 = function()
    appear("萨卡兹_出发前往", 1)
    appear("萨卡兹_出发前往2", 1)
    log("关卡刷新")
    ssleep(0.1)
    if findOne("萨卡兹_出发前往不期而遇") then return true end
    local po = find_color("萨卡兹_刷新按钮范围", "FCFCF9", 1, 0.95)
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
    log("刷新按钮位置", po, findAny({ "萨卡兹_出发前往紧急作战", "萨卡兹_出发前往普通作战" }))
    if po and findAny({ "萨卡兹_出发前往紧急作战", "萨卡兹_出发前往普通作战" }) then
        log("开始刷新")
        tap(po)
        appearTap("萨卡兹_刷新确认")
        disappear("萨卡兹_刷新确认")
    end
    if findOne("萨卡兹_出发前往不期而遇") then return true end
    return false
end

sarkaz.肉鸽选路 = function()
    log("肉鸽选路")
    local arr = {}
    local arr1 = {}
    local 地图名
    local 有路 = false

    keepCapture()

    for j = 1, 0, -1 do
        if 有路 == false then
            for i = 0, 6 do
                log(i, j)
                arr[i] = -1
                log(scale(541 + 675 * j), scale(1090 - 818 + 91 * i))
                log(getColor(scale(541 + 675 * j), scale(1090 - 818 + 91 * i)))
                if cmpColor(scale(541 + 675 * j), scale(1090 - 818 + 91 * i), "054EDE|066AC7|C2C00B|0F98D0|D09404|789512", 0.95) > 0 then -- BOSS
                    arr[i] = 0
                elseif cmpColor(scale(541 + 675 * j), scale(1090 - 818 + 91 * i), "6643A9", 0.95) > 0 then                                -- BOSS
                    arr[i] = 0
                elseif cmpColor(scale(541 + 675 * j), scale(1090 - 818 + 91 * i), "823131", 0.95) > 0 then                                -- 紧急
                    arr[i] = 1
                elseif cmpColor(scale(541 + 675 * j), scale(1090 - 818 + 91 * i), "5B528D", 0.95) > 0 then                                -- 普通
                    arr[i] = 2
                elseif cmpColor(scale(541 + 675 * j), scale(1090 - 818 + 91 * i), "2D757F", 0.95) > 0 then                                -- 不期而遇
                    arr[i] = 3
                elseif cmpColor(scale(541 + 675 * j), scale(1090 - 818 + 91 * i), "7A631F", 0.95) > 0 then                                -- 去伪存真
                    arr[i] = 4
                elseif cmpColor(scale(541 + 675 * j), scale(1090 - 818 + 91 * i), "244882", 0.95) > 0 then                                -- 安全的角落
                    arr[i] = 5
                elseif cmpColor(scale(541 + 675 * j), scale(1090 - 818 + 91 * i), "10513F", 0.95) > 0 then                                -- 商店
                    arr[i] = 6
                end
                if arr[i] > -1 then
                    log(i, j, arr[i])
                    -- 右边右路就返回,右边没路说明到达新一层
                    有路 = true
                    选路位置 = j
                end
            end
        end
    end
    releaseCapture()
    log("选路位置", 选路位置)

    if 选路位置 == 0 then
        到达层数 = 到达层数 + 1
        log(到达层数)
    end

    arr1 = shallowCopy(arr)
    table.sort(list, function(a, b) return a[1] < b[1] end)
    log(arr)
    log(arr1)
    肉鸽选路 = arr[0]

    toast("到达第" .. 到达层数 .. "层,选择节点" .. 节点(arr[0]))


    for i = 0, 6 do
        if arr1[i] == arr[0] then
            tap(scale(541 + 675 * 选路位置), 838 - 102 * i)
            ssleep(.5)
            break
        end
    end
end

sarkaz.蓝图速通 = function()
    log('start skz spdrun')
    初始队员 = { "维什戴尔", "谷米", "卡达" }
    到达层数 = 0
    肉鸽商品评分 = {}
    肉鸽参数 = {
        hp = 0,
        hope = 0,
        floor = 0,
    }
    --第五层暂停 = ReadUIConfig("第五层暂停")
    招募开局干员 = 0
    肉鸽白名单 = { "维什戴尔", "古米", "卡达", "玛恩纳", "澄闪", "异客", "苏苏洛" }
    肉鸽队员 = {}
    sarkaz.跳转()

    -- 肉鸽每8小时做日常

    -- 开始探索 一路按到 招募干员
    -- local first_time_see_first_card = 0

    local tapy = scale(904)
    local tapx = scale(258) + scale(414) * (tonumber(zl_blueprint_position) - 1)
    if not wait(function(reset_wait_start_time)
            if findOne("萨卡兹_初始招募") then return true end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
            tap({ tapx, tapy })
            ssleep(.2)
        end, 10) then
        return
    end
    log("初始招募")
    if not wait(function(reset_wait_start_time)
            if findOne("萨卡兹_初始招募") then return true end
            tap("萨卡兹_医疗招募券")
        end, 10) then
        return
    end


    log('招募狙击')
    if not wait(function()
            tap("萨卡兹_医疗招募券")
            tap("招募说明关闭")
            if findOne("确认招募") then return true end
        end, 10) then
        return
    end
    log('招募维什戴尔')
    local idx = zl.招募干员("维什戴尔", 肉鸽白名单)
    log(idx)
    zl.选择干员(idx)

    -- 第2人
    if not wait(function(reset_wait_start_time)
            if findOne("萨卡兹_初始招募") then return true end
            tap("萨卡兹_近卫招募券")
        end, 10) then
        return
    end


    log('招募狙击')
    if not wait(function()
            tap("萨卡兹_近卫招募券")
            tap("招募说明关闭")
            if findOne("确认招募") then return true end
        end, 10) then
        return
    end
    log('招募古米')
    local idx = zl.招募干员("古米", 肉鸽白名单)
    zl.选择干员(idx)
    --ssleep(1)
    -- 第3人
    log('招募医疗')
    if not wait(function()
            tap("萨卡兹_近卫招募券")
            tap("招募说明关闭")
            if findOne("确认招募") then return true end
        end, 10) then
        return
    end
    log('招募卡达')
    local idx = zl.招募干员("卡达", 肉鸽白名单)
    zl.选择干员(idx)


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
    -- ssleep(100)
    sarkaz.关卡刷新()
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
    sarkaz.关卡刷新()

    -- 思绪过多,丢掉一个
    if findOne("萨卡兹_思维负荷红") then
        findTap("萨卡兹_思维负荷红")
        local t = time()
        if not wait(function()
                if time() - t > 1000 then
                    t = time()
                    tap('招募说明关闭') --第一次加载会有这个弹窗
                end
                if findOne('萨卡兹_点击负荷干员') then return true end
            end, 6, .2) then
            return false
        end
        if not wait(function()
                local x = appear({
                    "萨卡兹_第一个思绪", "萨卡兹_思绪舍弃"
                })
                log(2575, x)
                tap(x)
                if x == "萨卡兹_思绪舍弃" then appear('萨卡兹_第一个思绪') end
                if not findOne("萨卡兹_第一个思绪") then return true end
            end, 10, .2) then
            return false
        end
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

        if not zl_不期而遇处理_萨卡兹() then return false end
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
        local po = find_color("萨卡兹_不期而遇关卡查找_列范围", "2D747E")
        log("不期而遇关卡位置", po)
        if po then
            wait(function()
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
        sarkaz.关卡刷新()
        ssleep(1)
        if not findOne("萨卡兹_不期而遇判断") then
            不期而遇关卡寻找()
            if not findOne("萨卡兹_不期而遇判断") then
                --第二列没有刷新出不期而遇，直接返回放弃探索
                toast('没有刷新出不期而遇，准备放弃')
                findTap('战略退出')
                disappear('战略退出')
                appear('萨卡兹_常规行动')
                return
                --return zl_repos_path('萨卡兹_放弃本次探索')
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
        sarkaz.关卡刷新()
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

    -- 取钱
    if zl_get_coin then zl_shop_get_coin() end

    if zl_only_coin then
        log('只是投币，准备退出')
        findTap('战略返回')
        -- back()
        --appear('萨卡兹_放弃本次探索', 3)
        --只投币的话 会马上退出，有时候退出投资了，投资提示还没消失，会退出又进来，重复而卡住一段时间
        if not wait(function()
                if not findOne('战略返回') then tap({ scale(1720), scale(498) }) end
                if findOne('返回确认界面') then return true end
            end, 10, .1) then
            return
        end
        if not wait(function()
                if findOne("返回确认界面") then
                    tap("右右确认")
                end
                if findOne('萨卡兹_戛然而止') then return true end
            end, 10, .1) then
            return
        end
        return true
    end

    --购买商品  后续做起来  蓝图分队刷等级可能更快，所以需要把购买商品留下来
    if not wait(function()
            if findOne("诡意行商离开") then return true end
            tap("开包skip")
        end, 5) then
        return
    end
    for i = 1, 10 do if not zl_shop_buy() then break end end

    return goto_next_level()
end

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
    if findOne("战略返回") then path.fallback.战略返回其他肉鸽() end
    if findOne("暂停中") and findOne("生命值") then restartapp(appid) end

    -- 先导航到常规行动
    zl_navigation('萨卡兹_常规行动', '萨卡兹的无终奇语进入主题')

    --肉鸽 等级源石锭检查
    萨卡兹肉鸽完成 = zl_level_coin_inquire('萨卡兹_常规行动', '萨卡兹_等级检测范围', '萨卡兹_源石锭检测范围')
    if 萨卡兹肉鸽完成 then
        return
    end

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
    -- ssleep(100)
    sarkaz.关卡刷新()
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
    sarkaz.关卡刷新()

    -- 思绪过多,丢掉一个
    if findOne("萨卡兹_思维负荷红") then
        findTap("萨卡兹_思维负荷红")
        local t = time()
        if not wait(function()
                if time() - t > 1000 then
                    t = time()
                    tap('招募说明关闭') --第一次加载会有这个弹窗
                end
                if findOne('萨卡兹_点击负荷干员') then return true end
            end, 6, .2) then
            return false
        end
        if not wait(function()
                local x = appear({
                    "萨卡兹_第一个思绪", "萨卡兹_思绪舍弃"
                })
                log(2575, x)
                tap(x)
                if x == "萨卡兹_思绪舍弃" then appear('萨卡兹_第一个思绪') end
                if not findOne("萨卡兹_第一个思绪") then return true end
            end, 10, .2) then
            return false
        end
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

        if not zl_不期而遇处理_萨卡兹() then return false end
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
        local po = find_color("萨卡兹_不期而遇关卡查找_列范围", "2D747E")
        log("不期而遇关卡位置", po)
        if po then
            wait(function()
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
        sarkaz.关卡刷新()
        ssleep(1)
        if not findOne("萨卡兹_不期而遇判断") then
            不期而遇关卡寻找()
            if not findOne("萨卡兹_不期而遇判断") then
                --第二列没有刷新出不期而遇，直接返回放弃探索
                toast('没有刷新出不期而遇，准备放弃')
                findTap('战略退出')
                disappear('战略退出')
                appear('萨卡兹_常规行动')
                return
                --return zl_repos_path('萨卡兹_放弃本次探索')
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
        sarkaz.关卡刷新()
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

    -- 取钱
    if zl_get_coin then zl_shop_get_coin() end

    if zl_only_coin then
        log('只是投币，准备退出')
        findTap('战略返回')
        -- back()
        --appear('萨卡兹_放弃本次探索', 3)
        --只投币的话 会马上退出，有时候退出投资了，投资提示还没消失，会退出又进来，重复而卡住一段时间
        if not wait(function()
                if not findOne('战略返回') then tap({ scale(1720), scale(498) }) end
                if findOne('返回确认界面') then return true end
            end, 10, .1) then
            return
        end
        if not wait(function()
                if findOne("返回确认界面") then
                    tap("右右确认")
                end
                if findOne('萨卡兹_戛然而止') then return true end
            end, 10, .1) then
            return
        end
        return true
    end

    --购买商品  后续做起来  蓝图分队刷等级可能更快，所以需要把购买商品留下来
    if not wait(function()
            if findOne("诡意行商离开") then return true end
            tap("开包skip")
        end, 5) then
        return
    end
    for i = 1, 10 do if not zl_shop_buy() then break end end

    return goto_next_level()
end

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
        in_fight_return = "无法进入作战"
        toast(in_fight_return)
        zl_repos_path("萨米_放弃本次探索")
        goto fight_first
    end


    --检查作战关卡名字
    if not zl_fight_name_ocr('萨米') then return end
    toast(now_fight_name)
    ssleep(.5)

    --通用的  肉鸽的第一次作战编队 直接引用就可以
    zl_first_edit_team()

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
    local idxs, maxIndex = zl_selection_node_skz(0, '萨米')
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

zl_shop_get_coin = function()
    if not wait(function()
            tap({ scale(244), scale(536) })
        end, 2) then
    end
    log('诡意行商取钱开始')
    if not appear("诡意行商投资", 1) then return true end
    if not wait(function()
            if findOne("诡意行商余额提取") then return true end
            tap("诡意行商投资")
        end) then
        return
    end
    if not wait(function()
            if findOne("诡意行商余额提取页面") then return true end
            tap("诡意行商余额提取")
        end) then
        return
    end

    wait(function(reset_wait_start_time)
        -- 不能投情况
        if not findOne("诡意行商余额提取页面") then
            tap("诡意行商余额提取")
            appear("诡意行商余额提取页面")
        end
        if findOne("正在提交反馈至神经") then
            reset_wait_start_time()
        end
        tap("诡意行商余额提取")
        appear("诡意行商余额提取页面")
        tap("诡意行商确认提取")
    end, 10)
end

path.探索者的银淞止境 = never_end_wrapper(path.探索者的银淞止境前瞻投资)
