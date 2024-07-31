-- ===========================================
--               萨卡兹肉鸽相关
-- ===========================================

-- 萨卡兹肉鸽函数
sarkaz = {}

--萨卡兹战略重启
sarkaz.restart = function(in_fight_return)
    local in_fight_return = in_fight_return or ''
    toast(in_fight_return or '重开')
    ssleep(3)
    if not request_memory_clean() then
        path.萨卡兹的无终奇语前瞻投资(true)
    else
        path.跳转("首页")
    end
end

sarkaz.不期而遇处理 = function()
    log("进入不期而遇")
    appear('萨卡兹_不期而遇节点出现')

    wait(function()
        tap("萨卡兹_不期而遇节点出现")
        if not findOne("萨卡兹_不期而遇节点出现") then return true end
    end, 3, .4)
    local t = time()
    if not wait(function()
            tap("战略确认")
            if time() - t > 1 * 600 and findOne("萨卡兹_思维混乱确认红") then
                t = time()
                tap({ scale(821), scale(577) }) --本次不再提醒 的位置
                ssleep(.2)
                tap("萨卡兹_思维混乱确认红") -- 处理可能出现的思维负载
            end
            if not findOne("萨米_战略帮助") and findOne('战略返回') then return true end
        end, 5) then
        -- 检查是否出现思维负荷阻滞
        if findOne('萨卡兹_思维负荷阻滞') then
            log('萨卡兹_思维负荷阻滞')
            tap({ scale(50), scale(20) })
            appear('战略返回')
        end
        return sarkaz.restart('进入不期而遇出错, 可能误点到了什么')
    end

    local event, incident, startTime = nil, nil, time()
    if not wait(function()
            if findOne("萨卡兹_战略帮助") then return false end
            incident = ocr("萨卡兹_不期而遇事件名字检测")
            if time() - startTime > 700 then
                startTime = time()
                log(366)
                if not findOne('萨米_希望源石锭界面') then tap("萨卡兹_不期而遇确认点击") end
            end

            if not incident[1] then
                event = ''
            else
                event = incident[1].text or ''
            end
            --只有识别到下面的字符串才做返回
            if string.finds(event, { "萨米", "维", "女士", '相', '黑', '解', '故事', '高空', '不散', '虫', '之店' }) then return true end
        end, 8, .1) then
        log('不能检测到事件')
        return false
    end

    local str = incident[1].text
    log('事件名字：', str)

    -- 处理界面操作
    if findOne("萨卡兹_思维界面") then tap("萨卡兹_思维返回") end
    if findOne('萨卡兹_不期而遇确认') then tap("萨卡兹_不期而遇确认点击") end


    if string.finds(str, { "虫", '故事', '之店' }) then
        return zl_event_solve(3, "萨卡兹_战略帮助")
    elseif string.finds(str, { '解', '高空', '不散' }) then
        return zl_event_solve(2, "萨卡兹_战略帮助")
    elseif string.finds(str, { "萨米", "维", "女士" }) then
        return zl_event_solve(1, "萨卡兹_战略帮助")
    elseif string.finds(str, { '相', '黑' }) then
        return zl_event_solve(5, "萨卡兹_战略帮助")
    end

    return true
end

--手机适配的时候，之前那个zl_shop_buy有点不适用
sarkaz.商店购物 = function()
    local p = appear(point["萨卡兹_战略商品列表"], 1)
    p = findAny(point["萨卡兹_战略商品列表"])
    if not p then return end
    if not wait(function()
            local x, y = point[p]:match("(%d+)" .. coord_delimeter .. "(%d+)")
            tap({ tonumber(x) - scale(111), tonumber(y) - scale(100) })
            if disappear(p, 1) then return true end
        end) then
        return
    end

    disappear("诡意行商离开", 1)
    if not wait(function(reset_wait_start_time)
            tap("诡意行商确认投资")
            if findOne("诡意行商离开") then return true end
            if findOne("确认招募") then
                local start_time = time()
                if not wait(function(reset_wait_start_time2)
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
                        if findOne("正在提交反馈至神经") then
                            reset_wait_start_time()
                            reset_wait_start_time2()
                        end
                        tap("近卫招募列表" .. 1)
                        findTap("确认招募")
                        tap("开包skip")
                    end, 10) then
                    return
                end
            end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
        end, 10) then
        return
    end
    return true
end

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

    萨卡兹路线 = sarkaz.分支选择()
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
    if zl_get_coin then zl.shop_get_coin() end

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

sarkaz.分支选择 = function()
    local 第一列 = {}
    local 第二列 = {}
    local 第三列 = {}
    local 第一列选择 = 0
    local 第二列选择 = 0
    local 第三列选择 = 0
    -- 第一列关卡判断
    for i = 1, 2 do
        if findOne("萨卡兹_第一列_不期而遇_列表" .. i) then
            table.insert(第一列, "不期而遇")
        else
            table.insert(第一列, "作战")
        end
    end
    log("第1列")
    log(第一列)

    -- 第二列关卡判断
    log("第2列")
    local 第二列分支_数目 = 0
    local 第二列分支_来源上 = false
    local 第二列分支_来源下 = false
    if findOne("萨卡兹_第二列_中间分支_来源上") then
        第二列分支_来源上 = true
    end
    if findOne("萨卡兹_第二列_中间分支_来源下") then
        第二列分支_来源下 = true
    end
    log(第二列分支_来源上, 第二列分支_来源下)
    if (not 第二列分支_来源上) and (not 第二列分支_来源下) then --2列
        第二列分支_数目 = 2
        for i = 1, 2 do
            if findOne("萨卡兹_第二列_不期而遇2_列表" .. i) then
                table.insert(第二列, "不期而遇")
            else
                local ox = find_color("萨卡兹_第二列_紧急作战2_查找列表" .. i, "DADADA")
                if ox then
                    table.insert(第二列, "紧急作战")
                else
                    table.insert(第二列, "作战")
                end
            end
        end
    else
        第二列分支_数目 = 3
        for i = 1, 3 do
            if findOne("萨卡兹_第二列_不期而遇3_列表" .. i) then
                table.insert(第二列, "不期而遇")
            else
                local ox = find_color("萨卡兹_第二列_紧急作战3_查找列表" .. i, "DADADA")
                if ox then
                    table.insert(第二列, "紧急作战")
                else
                    table.insert(第二列, "作战")
                end
            end
        end
    end
    log(第二列分支_数目)
    log(第二列)

    -- 第三列关卡判断
    -- 似乎没必要 第三列基本全是不期而遇
    -- 如果是三列 就默认全部是直线 不考虑分支（懒得写了）
    -- 如果是二三都为2列 也默认全部是直线
    log("第3列")
    local 第三列分支_数目 = 2
    local po = find_color("萨卡兹_第三列_三条分支寻找范围", "FEFEFE")
    if po then
        第三列分支_数目 = 3
    end
    if 第三列分支_数目 == 3 then
        for i = 1, 3 do
            if findOne("萨卡兹_第三列_不期而遇3_列表" .. i) then
                table.insert(第三列, "不期而遇")
            else
                local ox = find_color("萨卡兹_第三列_紧急作战3_查找列表" .. i, "DADADA")
                if ox then
                    table.insert(第三列, "紧急作战")
                else
                    table.insert(第三列, "作战")
                end
            end
        end
    else
        for i = 1, 2 do
            if findOne("萨卡兹_第三列_不期而遇2_列表" .. i) then
                table.insert(第三列, "不期而遇")
            else
                local ox = find_color("萨卡兹_第三列_紧急作战2_查找列表" .. i, "DADADA")
                if ox then
                    table.insert(第三列, "紧急作战")
                else
                    table.insert(第三列, "作战")
                end
            end
        end
    end
    log(第三列分支_数目)
    log(第三列)
    local 第三列分支_32连接下 = false
    local 第三列分支_32连接上 = false
    if 第二列分支_数目 == 3 and 第三列分支_数目 == 2 then
        local po = find_color("萨卡兹_第三列_32_中间分支连接下查找范围", "FEFEFE")
        if po then
            第三列分支_32连接下 = true --找到则是连接的第三条分支的第二个
        end

        local po = find_color("萨卡兹_第三列_32_中间分支连接上查找范围", "FEFEFE")
        if po then
            第三列分支_32连接上 = true --找到则是连接的第三条分支的第二个
        end
    end
    log(第三列分支_32连接上, 第三列分支_32连接下)
    local 第三列分支_23连接下 = false
    local 第三列分支_23连接上 = false
    if 第二列分支_数目 == 2 and 第三列分支_数目 == 3 then
        local po = find_color("萨卡兹_第三列_23_中间分支连接下查找范围", "FEFEFE")
        if po then
            第三列分支_23连接下 = true --找到则是连接的第三条分支的第二个
        end

        local po = find_color("萨卡兹_第三列_23_中间分支连接上查找范围", "FEFEFE")
        if po then
            第三列分支_23连接上 = true --找到则是连接的第三条分支的第二个
        end
    end
    log(第三列分支_23连接上, 第三列分支_23连接下)

    -- 生成路线图
    local skz_map = {}
    local function checkCondition(i, j, k, branch2, branch3)
        if branch2 and branch3 then
            return { { 1, 1, 1 }, { 1, 2, 2 }, { 2, 3, 2 } }
        elseif branch2 and not branch3 then
            return { { 1, 1, 1 }, { 1, 2, 2 }, { 1, 3, 2 } }
        elseif not branch2 and branch3 then
            return { { 1, 1, 1 }, { 1, 2, 1 }, { 1, 3, 2 } }
        elseif not branch2 and not branch3 then
            return { { 1, 1, 1 }, { 2, 2, 1 }, { 1, 3, 2 } }
        end
        return {}
    end

    for i, v in ipairs(第一列) do
        for j, w in ipairs(第二列) do
            for k, x in ipairs(第三列) do
                if 第二列分支_数目 == 第三列分支_数目 then
                    if 第二列分支_数目 == 2 then
                        if i == j and j == k then
                            table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                        end
                    else
                        if 第二列分支_来源上 then
                            if i == 1 and j == k and (j == 1 or 2) then
                                table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                            end
                            if i == 2 and j == 3 and k == 3 then
                                table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                            end
                        end
                        if 第二列分支_来源下 then
                            if i == 2 and j == k and (j == 2 or 3) then
                                table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                            end
                            if i == 1 and j == 1 and k == 1 then
                                table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                            end
                        end
                    end
                else
                    if 第二列分支_数目 == 2 and 第三列分支_数目 == 3 then
                        local 条件组合 = {
                            { 第三列分支_23连接下, { { 1, 1, 1 }, { 2, 2, 2 }, { 2, 2, 3 } } },
                            { 第三列分支_23连接上, { { 1, 1, 1 }, { 1, 1, 2 }, { 2, 2, 3 } } }
                        }
                        -- 遍历每个条件组合并插入数据到 skz_map
                        for _, 条件 in ipairs(条件组合) do
                            local 第三列条件, 值组合 = table.unpack(条件)
                            if 第三列条件 then
                                for _, 值 in ipairs(值组合) do
                                    local a, b, c = table.unpack(值)
                                    if i == a and j == b and k == c then
                                        table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                                    end
                                end
                            end
                        end
                    else
                        -- 相反就是 第二列 3 第三列 2
                        local 条件组合 = {
                            { 第三列分支_32连接下, 第二列分支_来源上, { { 1, 1, 1 }, { 1, 2, 2 }, { 2, 3, 2 } } },
                            { 第三列分支_32连接下, 第二列分支_来源下, { { 1, 1, 1 }, { 2, 2, 2 }, { 2, 3, 2 } } },
                            { 第三列分支_32连接上, 第二列分支_来源上, { { 1, 1, 1 }, { 1, 2, 1 }, { 2, 3, 2 } } },
                            { 第三列分支_32连接上, 第二列分支_来源下, { { 1, 1, 1 }, { 2, 2, 1 }, { 2, 3, 2 } } }
                        }
                        -- 遍历每个条件组合并插入数据到 skz_map
                        for _, 条件 in ipairs(条件组合) do
                            local 第三列条件, 第二列条件, 值组合 = table.unpack(条件)
                            if 第三列条件 then
                                if 第二列条件 then
                                    for _, 值 in ipairs(值组合) do
                                        local a, b, c = table.unpack(值)
                                        if i == a and j == b and k == c then
                                            table.insert(skz_map, { { i, v }, { j, w }, { k, x } })
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    log(skz_map)

    local function find_best_route(routes)
        local best_score = 50
        local best_route = nil
        for _, route in ipairs(routes) do
            local score = 0
            for rx, segment in ipairs(route) do
                if segment[2] == "紧急作战" then
                    score = score + 8
                elseif segment[2] == "不期而遇" then
                    if rx == 1 then
                        -- score = score + 1
                        -- 在第一列优先
                    else
                        score = score + 2
                    end
                elseif segment[2] == "作战" then
                    if rx == 1 then
                        score = score + 1
                    end
                    score = score + 3
                end
            end
            log(score, route)
            if score < best_score then
                best_score = score
                best_route = route
            end
        end
        log(best_score, route)
        return best_route
    end
    local best_route = find_best_route(skz_map)
    if not best_route then
        log("没有满足条件的路线")
        -- best_route = skz_map[1]
        best_route = { { 1, 第一列[1] }, { 1, 第二列[1] }, { 1, 第三列[1] } }
    end
    log(best_route)
    best_route[1][3] = 2
    best_route[2][3] = 第二列分支_数目
    best_route[3][3] = 第三列分支_数目
    return best_route
end

sarkaz.蓝图分队 = function()
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
            if time() - t > 2 * 1000 and findOne('萨卡兹_选择一次难度等级') then --第一次时候，需要选择难度等级
                ssleep(1)
                t = time()
                log('选择一次难度等级')
                tap('萨卡兹_选择一次难度等级')
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

    --local tapy = scale(904)
    --local tapx = scale(258) + scale(414) * (tonumber(zl_blueprint_position) - 1)
    if not wait(function(reset_wait_start_time)
            if findOne("萨卡兹_初始招募") then return true end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
            tap('萨卡兹_蓝图分队位置列表' .. zl_blueprint_position)
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
            tap("进入古堡")
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

    萨卡兹路线 = sarkaz.分支选择()
    log("路线选择", 萨卡兹路线)
    log('在选择节点界面')

    if 萨卡兹路线[1][2] ~= "不期而遇" then
        log("第一列不存在不期而遇")
        return sarkaz.restart("第一列不存在不期而遇")
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
    -- 不期而遇处理 = function()
    --     --判断不期而遇事件，并处理
    --     log("进入不期而遇")
    --     appear('萨卡兹_不期而遇节点出现')
    --     wait(function()
    --         tap("萨卡兹_进入")
    --         tap("萨卡兹_思维混乱确认红") --偶尔有情况 思维负载太多了，第一第二个节点都是作战时候，第三个节点有概率出现
    --     end, 2)
    --     if not wait(function()
    --             if not findOne("萨米_战略帮助") then return true end
    --             tap("战略确认")
    --         end, 5) then
    --         restart('进入不期而遇出错,可能误点到了什么') --减少重启次数
    --         return false
    --     end

    --     if not zl_不期而遇处理_萨卡兹() then return false end
    --     return true
    -- end

    if not sarkaz.不期而遇处理() then return end --有时候出错就重开
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
    if not sarkaz.不期而遇处理() then return end --有时候出错就重开

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
    if not sarkaz.不期而遇处理() then return end --有时候出错就重开

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
    if zl_get_coin then zl.shop_get_coin() end

    if zl_only_coin then
        log('只是投币，准备退出')
        findTap('战略返回')
        -- back()
        --appear('萨卡兹_放弃本次探索', 3)
        --只投币的话 会马上退出，有时候退出投资了，投资提示还没消失，会退出又进来，重复而卡住一段时间
        if not wait(function()
                if not findOne('战略返回') then tap('萨卡兹_只投资放弃本次探索') end
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
    for i = 1, 10 do if not sarkaz.商店购物() then break end end

    return goto_next_level()
end

path.萨卡兹的无终奇语前瞻投资 = function()
    if zl_blueprint then
        sarkaz.蓝图分队()
        return
    end
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

    -- 开始探索 一路按到 招募干员
    -- local first_time_see_first_card = 0

    if not wait(function(reset_wait_start_time)
            if findOne("萨卡兹_初始招募") then return true end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
            tap("新战略确认")
            tap("新战略确认")
            tap("新战略确认")
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
            log(28, zl_best_operator)
            local idx = str2int(zl_best_operator, -1)

            if idx >= 1 and idx <= 12 then
                -- 指定
                tap("近卫招募列表" .. (zl_best_operator or 1))
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
            if findOne("萨卡兹_希望源石锭界面") then
                -- if findAny({ "", "战略返回" }) then
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
            tap("近卫招募列表" .. 1)
            findTap("确认招募")
            tap("开包skip")
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
            if findOne("萨卡兹_希望源石锭界面") then
                --if findAny({ "萨米_初始招募", "战略返回" }) then
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
            tap("近卫招募列表" .. 1)
            findTap("确认招募")
            tap("开包skip")
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
    ssleep(0.5) -- 右边第三列有概率加载过慢
    -- 分支选择 返回每一列行数
    萨卡兹路线 = sarkaz.分支选择()
    log("路线选择", 萨卡兹路线)
    -- if debug_mode then
    --     ssleep(5)
    -- end
    --延迟一会，否则会产生位移，可以拿来后续做线路优化的筛选
    --目前默认选择上面的线路
    ssleep(1)
    findTap("萨卡兹_待编入负荷干员")
    local t = time()
    if not wait(function()
            findTap("萨卡兹_点击负荷干员")
            if time() - t > 1500 then
                t = time()
                tap('招募说明关闭') --第一次加载会有这个弹窗
            end
            if findOne('萨卡兹_等待负荷干员列表出现') then return true end
        end, 10, .3) then
        return false
    end
    ssleep(1)
    for i = 1, #point['萨卡兹_选项负荷干员列表'] do
        tap('萨卡兹_选项负荷干员列表' .. i)
        ssleep(.1)
    end
    tap("萨卡兹_等待负荷干员列表出现")
    disappear('萨卡兹_等待负荷干员列表出现')
    ssleep(.5)
    tap("萨卡兹_收起负荷干员")
    ::fight_first::
    log("准备进入第一关作战")
    ssleep(.5)
    if not 萨卡兹路线[1] then return end --有时候值为空会出错
    local 第一列 = 萨卡兹路线[1][1]
    table.remove(萨卡兹路线, 1)
    if not wait(function()
            -- tap("萨卡兹_第一次作战上")
            tap("萨卡兹_第一列_作战列表" .. 第一列)
            if findOne('萨卡兹_第一次作战被点击') then return true end
        end, 5) then
        -- in_fight_return = "无法进入第一关"
        zl_repos_path('萨卡兹_放弃本次探索')
        goto fight_first
    end

    --检查作战关卡名字
    if not zl_fight_name_ocr() then return end
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


    ::fight_trusteeship::
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

    appear({ "战略返回", "萨卡兹_联系中断", '萨卡兹_戛然而止' }, 30)
    if findOne("萨卡兹_戛然而止") then
        log('戛然而止界面，准备返回')
        return
    end
    if findOne("萨卡兹_联系中断") then
        log('重启')
        tap('战略确认')
        appear('萨卡兹_戛然而止')
        ssleep(1) --减少重启次数
        --restartapp(appid)
        return
    end
    if not findOne("战略返回") then return end

    if not zl_fight_after_skz() then
        log("未能完成战斗后拾取")
        return false
    end
    log("完成一次战斗")

    ::fight_select::
    log('在选择节点界面')
    log(萨卡兹路线)
    if next(萨卡兹路线) == nil then
        -- local idxs = -1
        -- local idxs, maxIndex = zl_selection_node()
        -- --如果maxIndex是1 2 则是战斗关卡   3 4 是不期而遇
        -- if idxs > 0 then
        --     log(idxs, maxIndex)
        --     tap(point.萨卡兹关卡节点坐标[idxs])
        --     ssleep(.5)
        -- end

        -- 最后为商店
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
        maxIndex = 5
    else
        sx = { scale(1761), scale(846) }
        oricol = getColor(sx[1], sx[2])
        log("每列节点", 萨卡兹路线[1][3])
        log(萨卡兹路线)
        if not wait(function()
                if getColor(sx[1], sx[2]) ~= oricol then
                    return true
                end
                tap("萨卡兹_" .. 萨卡兹路线[1][3] .. "节点_作战列表" .. 萨卡兹路线[1][1])
            end, 5, .2) then
            return
        end
        if 萨卡兹路线[1][2] == "不期而遇" then
            maxIndex = 4
        else
            maxIndex = 1
        end
        table.remove(萨卡兹路线, 1)
        ssleep(.5)
    end

    if maxIndex <= 3 then
        --进入战斗
        --检测作战关卡名字
        zl_fight_name_ocr()

        log("进入战斗")
        if not wait(function()
                if findOne("快捷编队") then return true end
                tap("萨卡兹_进入")
            end, 10) then
            return
        end
        goto fight_trusteeship
    elseif maxIndex == 4 then
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
                    elseif string.finds(str, { '解', '故事', '高空', '不散' }) then
                        if zl_event_solve(2, "萨卡兹_战略帮助") then return true end
                    elseif string.finds(str, { '相遇', "萨米", "维", "女士" }) then
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
