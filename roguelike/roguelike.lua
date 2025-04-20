-- 肉鸽通用函数
zl = {}

--开始之前检测一下，有没有其他肉鸽未结束探索
zl.放弃未结束的肉鸽探索 = function()
    path.跳转("首页")

    tap("面板作战")
    if not appear("主页") then return false end

    if not wait(function()
            if findOne("主题曲界面") then return true end
            tap("主题曲")
        end, 5) then
        return false
    end

    if not wait(function()
            if findOne("在长期探索") then return true end
            tap("集成战略")
        end, 5) then
        return false
    end

    local jump = true
    toast('检测是否有未结束的肉鸽探索')
    if not wait(function()
            if findAny({ "傀影_探索中", "水月_探索中", "萨米_探索中", "萨卡兹_探索中" }) then
                log('还有探索没有结束')
                tap({ scale(279), scale(501) })
                jump = false
                return true
            end
        end, 3, .1) then
        return false
    end
    disappear('在长期探索')
    ssleep(2)
    local rougelike_list = { "傀影_放弃本次探索", "水月_放弃本次探索", "萨米_放弃本次探索", "萨卡兹_放弃本次探索" }
    local p = findAny(rougelike_list) or 'nil'
    local pp = p:match("^(.-)_")
    log(pp)
    zl_abandon_explore(pp)
    path.跳转("首页")
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
                    return (i + 1), 被招募干员
                end
            end
            ssleep(.5)
            zl.招募翻页()
        end
    end
    return 0, 0
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
        local y3 = scale(310)
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

zl.map_swipe = function(left)
    if left then
        gesture({
            {
                point = { { scale(300), scale(116) }, { 1000000, scale(116) } },
                start = 0,
                duration = 250,
            },
        })
        sleep(250)
    else
        gesture({
            {
                point = { { scale(1842), scale(116) }, { scale(1842 - 1350), scale(116) } },
                start = 0,
                duration = 200,
            },
        })
        sleep(250)
    end
end

zl.shop_get_coin = function()
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

--通用的  肉鸽的第一次作战编队 直接引用就可以
zl.first_edit_team = function()
    if not wait(function()
            if findOne("快捷编队") then return true end
            tap("进入")
        end, 10) then
        return false
    end

    if not wait(function()
            if findOne("确认招募") then return true end
            tap("快捷编队")
        end, 10) then
        return false
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
        return false
    end

    if not wait(function()
            if not findOne("确认招募") then return true end
            tap("确认招募")
        end, 10) then
        return false
    end

    if not appear("快捷编队") then return false end
    return true
end

--肉鸽作战名字检测 type是肉鸽类型，是作战关卡名字检测的范围
zl.fight_name_ocr = function(rogueType)
    local rogueType = rogueType or '萨卡兹'
    local fight1ocr = {}
    --zl_fight_name 这个可修改替换为不同肉鸽的作战关卡名字
    log('rogueType: ', rogueType)
    if rogueType == '萨卡兹' then
        zl_fight_name = {
            ["坏邻居"] = { "坏", "邻", "居" },
            ["安全检查"] = { "安", "全", "检", "熔", "炉" },
            ["夺路而逃"] = { "夺", "路", "逃" },
            ["公害"] = { "公", "害" }
        }
    elseif rogueType == '萨米' then
        zl_fight_name = {
            ["待宰的兽群"] = { "待", "宰", "兽", '群' },
            ["死囚之夜"] = { "囚", "死" },
            ["度假村冤魂"] = { "度", "假", "村", "冤", "魂" },
            ["事不过四"] = { "事", "过", "四" },
            ["苔手"] = { "苔", "手" },
        }
    elseif rogueType == '水月' then
        zl_fight_name = {
            ["蓄水池"] = { "池", "水", "池" },
            ["虫群横行"] = { "虫", "群", "横", "行" },
            ["射手部队"] = { "射", "手", "部", "队" },
            ["共生"] = { "共", "生" },
            ["互助"] = { "互", "助" },
        }
    end
    print(zl_fight_name)
    if not wait(function()
            fight1ocr = ocr(rogueType .. "_作战检测范围")
            if #fight1ocr > 1 then
                log("4880", 4880, fight1ocr)
                local fight1 = fight1ocr[2].text

                for name, chars in pairs(zl_fight_name) do
                    if fight1:includes(chars) then
                        now_fight_name = name
                        return true
                    end
                end

                log("不知道什么作战：" .. fight1)
                return
            end
        end, 5, .2) then
        findTap('战略退出')
        return false
    end

    return true
end

zl.招募近卫 = function(type)
    local rogue_tpye = type or ''
    log('招募近卫')
    if not wait(function()
            tap(rogue_tpye .. '_' .. "近卫招募券")
            tap("招募说明关闭")
            if not findOne(rogue_tpye .. '_' .. "初始招募") and findOne("确认招募") then
                return true
            end
        end, 10) then
        return false
    end

    if not wait(function()
            if findAny({ rogue_tpye .. '_' .. "初始招募", "战略返回" }) then
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
                zl_help_fight(0, rogue_tpye .. '_' .. '初始招募', rogue_tpye)
            else
                stop("请设置近卫干员序号(1~12)", '', true, false)
            end
        end, 120) then
        return false
    end
    return true
end

zl.招募医疗 = function(type)
    local rogue_tpye = type or ''
    if not single_man_operation then
        log("招募医疗")
        if not wait(function()
                if findOne("确认招募") then return true end
                if findOne("剿灭说明") then tap("剿灭说明") end
                tap(rogue_tpye .. '_' .. "医疗招募券")
                tap("招募说明关闭")
            end, 10) then
            return false
        end
        appear('战略助战')
        if not wait(function()
                if findAny({ rogue_tpye .. '_' .. "初始招募", "战略返回" }) then
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
            end, 120) then
            return false
        end
    else
        log("不招募医疗")
        if not wait(function()
                if findOne("确认招募") then return true end
                if findOne("剿灭说明") then tap("剿灭说明") end
                tap(rogue_tpye .. '_' .. "医疗招募券")
                tap("招募说明关闭")
            end, 10) then
            return false
        end

        if not wait(function()
                tap("放弃招募")
                if findOne("剿灭说明") then tap("剿灭说明") end
                if not findOne("确认招募") then return true end
            end, 10) then
            return false
        end

        if not wait(function()
                tap("右右确认")
                if findOne("剿灭说明") then tap("剿灭说明") end
                if findOne(rogue_tpye .. '_' .. "初始招募") then return true end
            end, 10) then
            return false
        end
    end
    return true
end

zl.放弃招募辅助 = function(type)
    local rogue_tpye = type or ''
    -- 第二人，这里三步带了 剿灭说明 处理
    if not wait(function()
            if findOne("确认招募") then return true end
            if findOne("剿灭说明") then tap("剿灭说明") end
            tap(rogue_tpye .. '_' .. "辅助招募券")
            tap("招募说明关闭")
        end, 10) then
        return false
    end

    if not wait(function()
            tap("放弃招募")
            if findOne("剿灭说明") then tap("剿灭说明") end
            if not findOne("确认招募") then return true end
        end, 10) then
        return false
    end

    if not wait(function()
            tap("右右确认")
            if findOne("剿灭说明") then tap("剿灭说明") end
            if findOne(rogue_tpye .. '_' .. "初始招募") then return true end
        end, 10) then
        return false
    end
    return true
end

--肉鸽挑选节点，改关卡类型和坐标位置，可以适应其他肉鸽
zl.selection_node = function(select_number, rogueType)
    local rogueType = rogueType or '萨卡兹'
    local select_number = select_number or 0
    local paths = { -1, -1, -1, -1, -1 }
    --紧急 普通 普通2 不期  商店 ，越在后面优先级越高
    --有时候普通战斗关卡有两种颜色好像（  都放进来好了
    if rogueType == '萨卡兹' then
        关卡类型 = { "822E2E", "7268A9", "5B528D", "2E757F", "115340" }
    elseif rogueType == '萨米' then
        关卡类型 = { "994649", "7268A9", "468C9A", "4890A2", "2B6D5B" }
    elseif rogueType == '水月' then
        --紧急B35480 普通856BE2 兴致盎然 得偿所愿和商店一样 地区委托0EC6C8 不期而遇1ECBCE  商店149D81
        关卡类型 = { "B35480", "856BE2", "0EC6C8", "1ECBCE", "149D81" }
    end

    if select_number > 3 then
        log('校准线路次数超过3次，放弃本次探索重新来')
        back()
        path.跳转("首页")
    end
    if not wait(function()
            local current = time()
            if findOne_interval > 0 and current - findOne_last_time > findOne_interval then
                findOne_last_time = time()
                keepCapture()
            end

            -- 遍历关卡类型
            for i = 1, #point[rogueType .. '_关卡节点坐标列表'] do
                local xx = point[rogueType .. '_关卡节点坐标列表' .. i]
                local path_pos = xx[1] .. "|" .. xx[2]
                for j = 1, #关卡类型 do
                    local path_pos_color = path_pos .. "|" .. 关卡类型[j]
                    --print(path_pos_color)
                    local res = cmpColorEx(path_pos_color, 0.9)
                    if res == 1 then
                        print(rogueType, path_pos_color)
                        paths[i] = j
                    end
                end
            end
            -- print(paths)
            --找到的话就退出，至少会是1，如果没有找到则是{ -1, -1, -1, -1, -1 }
            for _, v in ipairs(paths) do
                if v > 0 then return true end
            end
        end, 3, .05) then
        log('找不到节点，重新校准路线')
        if not zl_repos_path(rogueType .. '_放弃本次探索') then return end
        return zl.selection_node(select_number + 1, rogueType)
    end

    --print(paths)
    local findMaxCoordinate = function(coords) --五个坐标里面取出权重最大的那个
        local maxCoord = coords[1]
        local maxIndex = 1
        for i = 2, #coords do
            if coords[i] > maxCoord then
                maxCoord = coords[i]
                maxIndex = i
            end
        end
        return maxIndex
    end

    local maxIndex = findMaxCoordinate(paths)
    --print("最大坐标的索引是：" .. maxIndex)
    if maxIndex ~= 0 and maxIndex ~= nil then
        --print("最大坐标的索引是：" .. maxIndex.."权重值为："..全部路径权重[maxIndex])
        return maxIndex, paths[maxIndex]
    else
        return -1, -1
    end
end

--不期而遇事件处理
zl_event_solve = function(xx, 战略帮助)
    --local 事件处理 = function(xx)
    local 战略帮助 = 战略帮助 or "战略帮助"
    local xx = xx or 1
    log('不期而遇事件处理：' .. xx)
    if not wait(function(reset_wait_start_time)
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            if findOne(战略帮助) then return true end
            tap("不期而遇选项点击列表" .. xx)
        end, 8, .05) then
        return false
    end
    return true
end

--肉鸽借助战
--reflashNum重新定位初始，初始给0
--初始招募界面 例如'放弃本次探索' '萨米_放弃本次探索'
--肉鸽类型  例如  '萨卡兹'  '萨米'  '水月'
zl_help_fight = function(reflashNum, 初始招募界面, 肉鸽类型)
    local 招募界面 = 初始招募界面 or '放弃本次探索'
    local 肉鸽类型 = 肉鸽类型 or '默认'
    reflashNum = reflashNum or 0
    single_man_operation = true
    if reflashNum > 8 then
        log("助战刷新次数超过8次")
        return false
    end
    if not wait(function()
            if findOne("战略助战界面") then return true end
            tap("战略助战")
        end, 5) then
        return
    end

    local operator
    if not wait(function()
            operator = ocr("战略助战干员范围")
            if #operator > 3 then return true end
        end, 5) then
        return false
    end

    local name2point = table.reduce(operator, function(a, c)
        a[c.text] = c
        return a
    end, {})

    --不同肉鸽试用的助战组不一样  感觉萨米和水月可以用一套的

    log('肉鸽类型: ', 肉鸽类型)
    if 肉鸽类型 == '萨米' then
        order = {
            { "百炼嘉维尔", 99, 2 },
            { "圣约送葬人", 99, 2 },
            { "乌尔比安", 99, 1 },
            { "羽毛笔", 99, 2 },
            { "海沫", 99, 2 },
        }
    elseif 肉鸽类型 == '水月' then
        order = {
            { "百炼嘉维尔", 99, 2 },
            { "圣约送葬人", 99, 2 },
            { "乌尔比安", 99, 1 },
            --{ "羽毛笔", 99, 2 },
            --{ "海沫", 99, 2 },
        }
    else
        order = {
            { "百炼嘉维尔", 99, 2 },
            { "圣约送葬人", 99, 2 },
            { "煌", 99, 1 }, --辅助，医疗这些都得开技能，也能不开
            { "耀骑士临光", 99, 1 },
            { "乌尔比安", 99, 1 },
        }
    end

    local best = table.findv(order, function(x) return name2point[x[1]] end)
    if not best then
        log("助战找不到所需干员，准备刷新", reflashNum)
        appear('肉鸽刷新助战蓝', 30)
        tap("肉鸽刷新助战蓝")
        reflashNum = reflashNum + 1
        ssleep(2) --偶尔有机子卡死，给多一点延迟，稳！
        return zl_help_fight(reflashNum, 招募界面, 肉鸽类型)
    end
    -- log("best", best)
    -- if not best then return point.战略助战干员列表1, 0, 1 end
    local p = name2point[best[1]]
    p = { p.l, p.t }
    tap(p)
    disappear("战略助战界面", 5)
    toast('再次判断助战干员')
    --再判断一次是否符号招募要求
    local target_operator = { '羽毛', '送葬', '圣', '嘉维尔', '海沫', '煌', '骑士', '临光', '比安' }
    if not wait(function()
            local target_best = ocr('战略助战确认干员范围')
            if target_best[1] then
                for _, v in ipairs(target_operator) do
                    if string.find(target_best[1].text, v, 1, true) then
                        log('符合的干员名字')
                        return true
                    end
                end
            end
            log(target_best.text)
            if target_best.text == best[1] then return true end
        end, 3, .2) then
        log('点击的助战干员名字不符合: ')
        reflashNum = reflashNum + 1
        tap({ 141, 54 })
        ssleep(2) --偶尔有机子卡死，给多一点延迟，稳！
        return zl_help_fight(reflashNum, 招募界面, 肉鸽类型)
    end
    reflashNum = 0
    --默认为单人助战，如果是以下干员则再去招募个医疗
    if best[1] == "百炼嘉维尔" or best[1] == '乌尔比安' then
        single_man_operation = false
    end
    zl_skill_times = best[2]
    zl_skill_idx = best[3]
    --招募界面出来之后的，‘初始招募’界面色点
    local 初始招募界面 = 初始招募界面 or "初始招募"
    wait(function()
        if findAny({ "萨卡兹_希望源石锭界面", '水月_希望源石锭钥匙界面' }) then return true end
        if findOne("战略助战确认界面") then tap("战略助战确认") end
        if not findOne("战略助战确认界面") then tap("开包skip") end
    end, 10)
end

-- 集成战略干员摆放 摆放三个人， 写的有点乱 可以优化
zl_deploy = function(deploy_table)
    for i = 1, 3 do
        if not wait(function()
                if findOne("干员费用够列表1") then return true end
                if not findOne("生命值") then
                    log("没找到生命值，继续等待")
                end
            end, 30) then
            return false
        end
        if i > 3 then i = 3 end
        wait(function()
            tap("干员费用够列表1")
            disappear("干员费用够列表1", 0.5)
            local deploy_point = { scale(deploy_table[i][1]), scale(deploy_table[i][2]), deploy_table[i][3] }
            nDeploy3(1, deploy_point, 4 - i)

            wait(function()
                if findOne("生命值") then return true end
                tap("开始行动1")
            end)

            if i == 1 then
                if not appear("干员部署_黄", 5) then return true end
            elseif i == 2 then
                if not appear("干员部署_2蓝", 8) then return true end
            elseif i == 3 then
                if not appear("干员部署_蓝", 5) then return true end
            end
        end, 20)
    end
end

-- 集成战略干员摆放 摆放两个人的
zl_deploy2 = function(deploy_table)
    local number = 2
    if single_man_operation then number = 1 end
    for i = 1, number do
        if not wait(function()
                if findOne("干员费用够列表1") then return true end
                if not findOne("生命值") then
                    log("没找到生命值，继续等待")
                end
            end, 30) then
            return false
        end
        wait(function()
            tap("干员费用够列表1")
            disappear("干员费用够列表1", 0.5)
            local deploy_point = { scale(deploy_table[i][1]), scale(deploy_table[i][2]), deploy_table[i][3] }
            nDeploy3(1, deploy_point, 4 - i)

            wait(function()
                if findOne("生命值") then return true end
                tap("开始行动1")
            end)

            if i == 1 then
                if disappear("干员部署_黄", 4) then return true end
            elseif i == 2 then
                if disappear("干员部署_2蓝", 2) then return true end
            end
        end, 20)
    end
end

-- 肉鸽重新校准路径
zl_repos_path = function(放弃本次探索)
    local 放弃本次探索 = 放弃本次探索 or '放弃本次探索'
    findTap("战略返回")
    local t = time()
    if not wait(function()
            if findOne(放弃本次探索) then return true end
            if time() - t > 1 * 1000 then --有时候前面战略返回点击了也不会退出，间隔1s再点击一次
                t = time()
                tap("战略返回")
            end
        end, 10) then
        log('超时未找到等待开始页面标题,准备结束')
        return path.跳转('首页')
    end
    local t = time()
    wait(function()
        tap({ scale(1708), scale(900) }) --采用固定的坐标，一直点击直到出现 '战略返回'
        if time() - t > 1 * 1000 then    --有时候前面战略返回点击了也不会退出，间隔1s再点击一次
            t = time()
            tap("战略确认")
        end
        if findOne("战略返回") then return true end
    end, 5)
end

--1常规行动，也就是肉鸽主界面   2,在点击肉鸽列表的时候，选择的肉鸽
--zl_navigation('萨米_常规行动', '探索者的银淞止境进入主题')
--zl_navigation('水月_常规行动', '水月与深蓝之树进入主题')
--zl_navigation('常规行动', '傀影与猩红孤钻')
zl_navigation = function(常规行动, 需要点击的肉鸽)
    local 常规行动 = 常规行动 or '常规行动'
    local 需要点击的肉鸽 = 需要点击的肉鸽 or '傀影与猩红孤钻'
    -- 省略跳转
    if findOne(常规行动) then return true end

    path.跳转("首页")

    tap("面板作战")
    if not appear("主页") then return false end

    if not wait(function()
            if findOne("在长期探索") then return true end
            tap("集成战略")
        end, 5) then
        return false
    end

    if not wait(function()
            if findOne("在长期探索") then
                tap("查看全部主题")
                disappear('查看全部主题')
            end
            if findOne("选择集成战略列表界面") then return true end
        end, 10) then
        return
    end

    appear('选择集成战略列表界面')
    ssleep(1) --太快了停顿一会，稳!
    if not wait(function()
            log('滑动')
            --if not findOne("选择集成战略列表界面") then return true end --防止滑动出错
            gesture({
                {
                    point = { { screen.width * 0.3,   screen.height * 0.95 },
                        { screen.width * 0.8,             screen.height * 0.95 },
                        { screen.width * 0.8 - scale(10), screen.height * 0.95 },
                        { screen.width * 0.8 + scale(10), screen.height * 0.95 } },
                    start = 0,
                    duration = 800,
                },
            })

            ssleep(1.5)
            if appear('傀影与猩红孤钻', 2) then return true end
            --作为定位，是否滑到了最左边
        end, 10) then
        return zl_navigation(常规行动, 需要点击的肉鸽)
    end

    if not wait(function()
            --if not findOne("选择集成战略列表界面") then return true end --防止出错
            if findOne(常规行动) then return true end
            tap(需要点击的肉鸽)
        end, 15) then
        return zl_navigation(常规行动, 需要点击的肉鸽)
    end

    log('导航成功')
    return true
end

-- 肉鸽每8小时做日常
zl_eight_daily = function()
    if not zl_no_waste_last_time or time() - zl_no_waste_last_time > 8 * 3600 *
        1000 then
        -- 并非首次
        if zl_no_waste_last_time then
            zl_no_waste_last_time = nil
            restart_account()
            -- saveConfig("hideUIOnce", "true")
            -- save_extra_mode(extra_mode, extra_mode_multi)
            -- restartPackage()
        end
        -- 首次
        if zl_no_waste then
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end

        zl_no_waste_last_time = time()
    end
end

--肉鸽 等级源石锭检查
zl_level_coin_inquire = function(常规行动, 等级检测范围, 源石锭检测范围)
    if zl_disable_inspect_level then return end
    local 常规行动 = 常规行动 or '常规行动'
    local 等级检测范围 = 等级检测范围 or '等级检测范围'
    local 源石锭检测范围 = 源石锭检测范围 or '源石锭检测范围'
    if zl_level_enough then
        if zl_no_waste then
            -- todo
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end
        log("结束zl_level")
        return true
        -- stop("肉鸽结束", '', false, true)
    end

    if zl_coin_enough then
        if zl_no_waste then
            -- todo
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end
        log("结束zl_coin")
        return true
        -- stop("肉鸽结束", '', false, true)
    end

    -- 检测等级 ，输入检测范围的名字
    --例如   zl_number_check()
    local zl_number_check = function(检测范围)
        --if not (str2int(zl_max_level, 0) > 0) then return end
        local 检测范围 = 检测范围 or {}
        if not findOne(常规行动) then return end
        local prex = -1
        local ans = wait(function()
            ssleep(.5)
            local r = ocro(检测范围)
            log("4126", r)
            -- if x == nil or type(x) ~= "string" or #x == 0 then
            --     return 0
            -- end
            if not r then r = "" end
            x = str2int(r:match("%d+"), -1)
            log("4127", type(x), x)
            if x >= 0 and x <= 999 then return x end
            prex = x
        end, 0.7) --给点检测时间
        return ans
    end

    local zl_level = zl_number_check(等级检测范围) or -1
    toast('等级:' .. zl_level)
    if not zl_level_enough and zl_level == str2int(zl_max_level, 10000) then
        zl_level_enough = true
        captureqqimagedeliver("INFO", "肉鸽任务完成", table.join(qqmessage,
                ' ') .. " " ..
            (zl_level or '') .. "等级已满")
        log("等级已满")
        return true
    end

    local zl_coin = zl_number_check(源石锭检测范围) or -1
    if zl_coin == 999 then zl_skip_coin = true end --源石锭999的话跳过投币，避免浪费时间
    toast('源石锭:' .. zl_coin)
    if not zl_coin_enough and zl_coin >= str2int(zl_max_coin, 10000) then
        zl_coin_enough = true
        captureqqimagedeliver("INFO", "肉鸽任务完成", table.join(qqmessage,
                ' ') .. " " ..
            (zl_coin or '') .. "源石锭已满")
        log("源石锭已满")
        return true
    end

    -- 等级/源石锭 阶段性通知
    if not zl_captcha_time or time() - zl_captcha_time > 3600 * 1000 then
        zl_captcha_time = time()
        local info = ''
        if str2int(zl_max_level, 0) > 0 then
            info = info .. zl_level .. '/' .. zl_max_level .. ' '
        end
        if str2int(zl_max_coin, 0) > 0 then
            info = info .. zl_coin .. '/' .. zl_max_coin
        end
        captureqqimagedeliver("INFO", "肉鸽任务推送",
            table.join(qqmessage, ' ') .. " " .. info)
    end
end

--肉鸽放弃探索
zl_abandon_rougelike = function(常规行动, 继续探索, 放弃探索)
    -- 放弃探索
    local 常规行动 = 常规行动 or '常规行动'
    local 继续探索 = 继续探索 or "萨米_继续探索"
    local 放弃探索 = 放弃探索 or "萨米_放弃本次探索"
    if findOne(放弃探索) then
        if not wait(function()
                if findOne("返回确认界面") then return true end
                tap(放弃探索)
            end, 5) then
            log(2608)
            -- 无法直接放弃的情况 不处理
            if not wait(function()
                    if not findOne(常规行动) then return true end
                    tap(继续探索)
                    ssleep(.5)
                    log(2613)
                end, 5) then
                return false
            end

            if not wait(function()
                    if findOne(常规行动) then return true end
                    -- 第一次数据更新处理
                    if findAny({
                            "面板", "活动公告返回", "签到返回", "签到返回黄",
                            "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
                        }) then
                        jumpout = true
                        return true
                    end
                    tap("战略确认")
                end, 5) then
                return false
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
                tap("战略确认")
                if findOne(常规行动) and not findOne(放弃探索) then
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
end

--肉鸽购买所需收藏品
zl_shop_check_goods = function()
    if type(zl_need_goods) ~= 'string' or #zl_need_goods:trim() == 0 then
        return
    end
    local need_goods = zl_need_goods:filterSplit()
    local goods1 = table.join(map(function(x) return x.text end,
        ocr("战略第一行商品范围")))
    local goods2 = table.join(map(function(x) return x.text end,
        ocr("战略第二行商品范围")))
    local goods = table.join({ goods1, goods2 })
    if goods:includes(need_goods) then
        stop("已遇到所需商品" .. goods, '', true, true)
    end
    log("未找到商品", goods, need_goods)
end

--肉鸽购买商店
zl_shop_buy = function()
    local p = appear(point["战略商品列表"], 1)
    p = findAny(point["战略商品列表"])
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

zl_shop_coin = function()
    -- if not appear("诡意行商投资", 1) then return goto_next_level() end
    if not appear("诡意行商投资", 1) then return true end
    if not wait(function()
            if findOne("诡意行商投币") then return true end
            tap("诡意行商投资")
        end) then
        return
    end
    if not wait(function()
            if findOne("诡意行商投资入口") then return true end
            tap("诡意行商投币")
        end) then
        return
    end

    local coin_no_notification = sample("投币提示")

    wait(function(reset_wait_start_time)
        -- 不能投情况
        if not findOne("诡意行商投资入口") then return true end
        if findOne("正在提交反馈至神经") then
            reset_wait_start_time()
        end
        if not findOne(coin_no_notification) then reset_wait_start_time() end
        tap("诡意行商确认投资")
    end, 6)
end

--肉鸽等级满了，放弃行动后回到首页再截个图
zl_level_coin_enough = function()
    if zl_level_enough or zl_coin_enough then
        captureqqimagedeliver("INFO", "肉鸽行动结束",
            table.join(qqmessage, ' ') .. " 放弃行动后")

        wait(function(reset_wait_start_time)
            if not disappear("常规行动") then return true end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            tap("战略确认")
        end, 5)
        return
    end
end

--肉鸽初始放弃探索
zl_abandon_explore = function(type)
    local rogue_tpye = type or ''
    -- 放弃探索
    if findOne(rogue_tpye .. "_放弃本次探索") then
        if not wait(function()
                if findOne("返回确认界面") then return true end
                tap(rogue_tpye .. "_放弃本次探索")
            end, 5) then
            log(2608)
            -- 无法直接放弃的情况 不处理
            if not wait(function()
                    if not findOne(rogue_tpye .. "_常规行动") then return true end
                    tap(rogue_tpye .. "_继续探索")
                    ssleep(.5)
                    log(2613)
                end, 5) then
                return
            end

            if not wait(function()
                    if findOne(rogue_tpye .. "_常规行动") then return true end
                    -- 第一次数据更新处理
                    if findAny({
                            "面板", "活动公告返回", "签到返回", "签到返回黄",
                            "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
                        }) then
                        jumpout = true
                        return true
                    end
                    tap("战略确认")
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
                tap("战略确认")
                if findOne(rogue_tpye .. "_常规行动") and not findOne(rogue_tpye .. "_放弃探索") then
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
            return false
        end
    end
    return true
end

-- 最后require,不然会找不到函数
require("mizuki")
require("sarkaz")
require("sami")
