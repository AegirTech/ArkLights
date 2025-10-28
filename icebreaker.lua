-- 促融共竞通用函数
ib = {}
local 角色编队作业 = { 72362, 72363, 72341 }
local 关卡作业 = {
    ["IG-1"] = 72364,
    ["IG-2"] = 72367,
    ["IG-3"] = 72373,
    ["IG-4"] = 72374,
    ["IG-5"] = 72375,
    ["IG-6"] = 72376,
    ["IG-7"] = 72377,
    ["IG-8"] = 72422,
    ["IG-9"] = 72423,
    ["IG-10"] = 72424,
    ["IG-11"] = 72425,
    ["IG-12"] = 72426,
    ["IG-13"] = 72427,
    ["IG-14"] = 72428,

    ["IG-EX-1"] = 72364,
    ["IG-EX-2"] = 72367,
    ["IG-EX-3"] = 72373,
    ["IG-EX-4"] = 72374,
    ["IG-EX-5"] = 72375,
    ["IG-EX-6"] = 72376,
    ["IG-EX-7"] = 72377,
    ["IG-EX-8"] = 72422,
    ["IG-EX-9"] = 72423,
    ["IG-EX-10"] = 72424,
    ["IG-EX-11"] = 72425,
    ["IG-EX-12"] = 72426,
    ["IG-EX-13"] = 72427,
    ["IG-EX-14"] = 72428,

    -- ["IG-S-1"] = 49120,
    ["IG-S-2"] = 72378,
    -- ["IG-S-3"] = 49147,
}

import_room_id = function()
    local data = getClipboard():trim()
    if not data or #data == 0 then return end
    if not string.finds(data, { "房间编号" }) then return end
    toast("已自动填写房间编号")
    extra_crgj_room = data
    ui.setEditText("extra_crgj_room", extra_crgj_room)
end

ib.start = function()
    if findOne("ib_选择项目红") and ib_grouping_method == 1 then
        log("已经建好房间")
    elseif findOne("ib_准备就绪") and ib_grouping_method == 1 then
        log("已经加入房间")
    else
        path.跳转("首页")
        ssleep(.2)
        tap("面板活动")
        appear("ib_主页", 10)
        if ib_auto_team_format then
            if ib_team_role > 0 then
                ib.auto_team_formation(角色编队作业[ib_team_role])
            end
        end
        wait(function()
            tap("ib_主页")
            ssleep(0.3)
            if findOne("ib_加入") then return true end
        end, 10)
    end

    if ib_grouping_method == 1 then
        log("开始创建房间")
        wait(function()
            tap("ib_发起")
            ssleep(0.3)
            if findOne("ib_选择项目红", .9) then return true end
        end, 10)
        wait(function()
            tap("ib_选择项目")
            ssleep(0.3)
            if findOne("ib_随机项目", .9) then return true end
        end, 10)
        if ib_difficulty == 1 then
            ssleep(0.3)
            tap("ib_高级赛")
            ssleep(0.3)
        elseif ib_difficulty == 2 then
            ssleep(0.3)
            tap("ib_特级赛")
            ssleep(0.3)
        end
        wait(function()
            if ib_object_id == 0 then
                tap("ib_随机项目")
            elseif ib_object_id <= 9 then
                tap("ib_项目列表" .. ib_object_id)
            else
                gesture({
                    {
                        point = { { scale(990), scale(907) }, { scale(990), scale(100) } },
                        start = 0,
                        duration = 500,
                    },
                })
                sleep(1000)
                tap("ib_项目列表" .. ib_object_id)
            end
            ssleep(0.3)
            if findOne("ib_进入备赛灰") or findOne("ib_进入备赛红") then return true end
        end, 10)
        tap("ib_复制房间号")
        ssleep(1)
    end
    never_end_wrapper(ib.促融共竞循环())
end

ib.促融共竞循环 = function()
    local 关卡名
    local looping = {
        ib_加入 = function()
            if ib_grouping_method == 1 then return end
            tap("ib_加入")
            appear("ib_输入框", 2)
            input("ib_输入框", extra_crgj_room)
            ssleep(.5)
            tap("ib_输入确认")
            ssleep(0.5)
            tap("ib_加入")
            ssleep(1.5)
        end,
        ib_选择项目红 = function()
            if ib_grouping_method == 0 then return end
            wait(function()
                tap("ib_选择项目")
                ssleep(0.3)
                if findOne("ib_随机项目", .9) then return true end
            end, 10)
            log("选择难度", ib_difficulty)
            if ib_difficulty == 1 then
                ssleep(0.3)
                tap("ib_高级赛")
                ssleep(0.3)
            elseif ib_difficulty == 2 then
                ssleep(0.3)
                tap("ib_特级赛")
                ssleep(0.3)
            end
            log("选择项目", ib_object_id)
            wait(function()
                if ib_object_id == 0 then
                    tap("ib_随机项目")
                elseif ib_object_id <= 9 then
                    tap("ib_项目列表" .. ib_object_id)
                else
                    gesture({
                        {
                            point = { { scale(990), scale(907) }, { scale(990), scale(100) } },
                            start = 0,
                            duration = 500,
                        },
                    })
                    sleep(1000)
                    tap("ib_项目列表" .. ib_object_id)
                end
                ssleep(0.3)
                if findOne("ib_进入备赛灰") then return true end
            end, 10)
        end,
        ib_准备参赛 = function()
            tap("ib_准备参赛")
            disappear("ib_准备参赛", 5)
        end,
        ib_下一步确认配置 = function()
            tap("ib_下一步确认配置")
            disappear("ib_准备参赛", 5)
        end,
        ib_准备就绪 = function()
            tap("ib_准备就绪")
            disappear("ib_准备就绪", 5)
        end,
        ib_干员协调页面 = function()
            tap("ib_干员拿取")
            ssleep(1)
        end,
        ib_倒计时 = function()
            if ib_team_role == 0 then return end
            if not wait(function()
                    关卡名 = ocro("ib_关卡名识别范围")
                    ssleep(1)
                    log(关卡名)
                    if 关卡作业[关卡名] then
                        log("关卡名匹配成功")
                        if ib_team_role == 3 then
                            log("重复刷ig-7")
                            ib.battle(72341)
                            return true
                        else
                            ib.battle(关卡作业[关卡名])
                            return true
                        end
                    end
                    if findOne("ib_下一步") or findOne("ib_返回房间") then return false end
                end, 240) then
                return
            end
        end,
        ib_下一步 = function()
            tap("ib_下一步")
            ssleep(2)
        end,
        ib_返回房间 = function()
            log(ib_auto_like)
            if ib_auto_like then
                ssleep(1)
                tap("ib_点赞")
            end
            tap("ib_返回房间")
            ssleep(1)
        end,
        ib_关卡内部顶部标识 = function()
            if agree_cost_request_automaticlly and findOne("ib_费用请求同意") then
                tap("ib_费用请求同意")
            end
            if findOne("ib_二倍速开启") then
                ssleep(3)
                return
            end
            if not wait(function()
                    if findOne("ib_二倍速开启") then return end
                    tap("ib_二倍速")
                    ssleep(1)
                end, 5) then
            end
            ssleep(3)
        end,
        start黄框 = function()
            ib.start()
        end
    }
    log("促融共竞循环开始")
    auto(looping, nil, 0, nil, false)
end

ib.auto_team_formation = function(作业名, 是否自带)
    print("prts作战开始", homework)
    local 干员名单 = ""
    local 群组 = {}
    local 队员技能 = {}
    local 无限放技能干员 = {}
    local 技能指定次数干员 = {}
    local 作业 = loadHomework(作业名, 是否自带, true)
    print(作业)
    print("读取作业成功")
    local processSkillData = function(oper)
        if table.findk(oper, "skill_usage") then
            if oper["skill_usage"] == 1 then
                table.insert(无限放技能干员, oper["name"])
            elseif oper["skill_usage"] == 2 then
                技能指定次数干员[oper["name"]] = { oper["skill_times"] or 1, 0 }
            end
        end

        if table.findk(oper, "skill") then
            队员技能[oper["name"]] = oper["skill"]
        end
    end
    local groups = 作业["groups"]
    if groups and #groups > 0 then
        for _, group in ipairs(groups) do
            群组[group["name"]] = group["opers"]
            for _, oper in ipairs(group["opers"]) do
                processSkillData(oper)
            end
            if table.findk(group, "skill") then
                for _, oper in ipairs(group["opers"]) do
                    队员技能[oper["name"]] = group["skill"]
                end
            end
        end
    end

    for _, oper in ipairs(作业["opers"]) do
        processSkillData(oper)
    end
    log("读取群组成功")
    if not findOne("ib_主页") then
        path.跳转("首页")
        tap("面板活动2")
        appear("ib_主页", 10)
    end
    if ib.自动编队(作业["opers"], 群组) == false then return false end
    releaseCapture()
end

ib.自动编队 = function(干员, 群组)
    local 编入数量 = 0
    local 未编入 = {}
    local 未编入干员 = {}
    local 干员类别 = { "PIONEER", "WARRIOR", "TANK", "SNIPER", "CASTER", "MEDIC", "SPECIAL", "SUPPORT" }
    local 未编入数量 = 0

    local 干员职业 = JsonDecode(readFile("character_type_list.json"))
    log("读取干员职业成功")
    local printChar = function(t)
        for _, i in ipairs(t) do
            print("需要干员", i["name"], ",职业", 干员职业[i["name"]])
        end
    end
    if not wait(function()
            if findOne("ib_高顺位快捷编队") then return true end
            tap("ib_编队")
            ssleep(1)
        end, 5) then
        return
    end
    appear("ib_高顺位快捷编队", 3)
    if not wait(function()
            if findOne("ib_编队清空选择") then return true end
            tap("ib_高顺位快捷编队")
            sleep(10)
        end, 5) then
        return
    end
    if not wait(function()
            if findOne("ib_无干员选中") then return true end
            tap("ib_编队清空选择")
        end, 5) then
        return
    end
    if not findOne("职业选择") then
        tap("职业选择")
        appear("职业选择", 2)
    end
    if not findOne("等级降序") then
        tap("等级降序")
        appear("等级降序", 2)
    end
    local choseChar = function(干员, 是否群组)
        local 记录未编入数量
        local group_selected = 0
        if 是否群组 then
            记录未编入数量 = 未编入数量
        end
        --8个职业
        for i = 1, 8 do
            local 干员名字字符串 = ""
            local 干员目录 = {}
            for _, item in ipairs(干员) do
                if 干员职业[item["name"]] == 干员类别[i] then
                    干员名字字符串 = 干员名字字符串 .. item["name"]
                    table.insert(干员目录, item["name"] .. item["skill"])
                end
            end
            if 干员名字字符串 ~= "" and group_selected == 0 then
                if not findOne("普通作战编队列表" .. i) then
                    tap("普通作战编队列表" .. i)
                    appear("普通作战编队列表" .. i)
                    sleep(200)
                end
                --print(干员目录)
                未编入 = ib.选择干员(干员目录, "待编队干员", 是否群组)

                未编入数量 = 未编入数量 + 未编入[1]
                if 是否群组 and 未编入[1] == 0 then
                    group_selected = 1
                    未编入数量 = 记录未编入数量
                    编入数量 = 编入数量 + 1
                end
                if 未编入数量 == 1 and 未编入干员[1] == nil then
                    print(i, 未编入[2])
                    未编入干员 = { i, 未编入[2] }
                elseif 是否群组 == nil and 未编入数量 > 1 then
                    log("缺少干员超过1个")
                    exitScript()
                end
                if not 是否群组 then 编入数量 = #干员目录 + 编入数量 end
            end
            if i == 8 then
                if not findOne("职业选择all") then
                    tap("职业选择all")
                    appear("职业选择all", 2)
                    sleep(300)
                end
            end
            --print("编入数量", 编入数量)
        end
    end

    printChar(干员)
    choseChar(干员)
    for _, group in pairs(群组) do
        printChar(group)
        choseChar(group, 1)
    end
    tap("编队确认")
    appear("ib_高顺位快捷编队", 3)
    log(未编入干员)
    -- 增加选择风格
    back()
    if 未编入数量 >= 1 then
        log("编队未完成，需要手动编队")
        sleep(1000)
        --有时候会在编队界面卡主 一直返回不了主页
        wait(function()
            back()
        end, 3, .3)
        ssleep(1)
        path.跳转("首页")
        return false
    end
    -- if 未编入数量 == 1 then
    --     Call 编入支援干员(未编入干员,1)
    -- end
end

ib.选择干员 = function(干员目录, 字典, 是否群组, 群组需要数量)
    local 需要干员数 = #干员目录
    local 已选择 = {}
    local selected = 0
    local 干员组, 技能组 = {}, {}
    local 群组需要数量 = 群组需要数量 or 1
    log(需要干员数, "群组需要数量", 群组需要数量)
    for i = 1, #干员目录 do
        干员组[i] = string.sub(干员目录[i], 1, string.len(干员目录[i]) - 1)
        技能组[i] = tonumber(string.sub(干员目录[i], -1)) or 1
    end
    local 找干员 = function(识别结果)
        for i = 1, 需要干员数 do
            -- print "需要干员", i, 干员组[i]
            if 已选择[i] == nil then
                print(干员组[i], "未编入")
                for _, 结果 in ipairs(识别结果) do
                    --print(结果)
                    if 结果["text"] == 干员组[i] then
                        if 字典 == "待编队干员" then
                            tap({ 结果["l"] + scale(100), 结果["b"] - scale(100) })
                        end
                        --加一个appear出现角色选择的蓝框
                        print(干员组[i], "正在编入,选择", 技能组[i], "技能")
                        sleep(300)
                        选择技能(技能组[i])
                        已选择[i] = 1
                        selected = selected + 1
                        break
                    end
                end
                print("已选择", selected, "个干员")
                if 是否群组 and selected >= 群组需要数量 then break end
            else
                print(干员组[i], "已编入")
            end
        end
    end
    print(干员组, 技能组)
    keepCapture()
    for i = 1, 18 do
        print("识别上")
        local 识别结果 = 干员名ocr校正(ocrex("ib_上排干员范围"))
        找干员(识别结果)
        if 是否群组 and selected >= 群组需要数量 then return { 0 } end
        print("识别下")
        识别结果 = 干员名ocr校正(ocrex("ib_下排干员范围"))
        找干员(识别结果)
        print("已选择", selected, "个干员")
        if 是否群组 and selected >= 群组需要数量 then return { 0 } end
        if selected < 需要干员数 then
            print("下一页搜索")
            swipe_next_page()
            keepCapture()
        else
            return { 0 }
        end
    end

    local notselected = 0
    for i = 1, 需要干员数 do
        if 已选择[i] == nil then
            print("干员", 干员组[i], "未选择")
            notselected = notselected + 1
        end
    end
    if notselected == 1 then
        return { notselected, 干员组[i] }
    elseif notselected > 1 then
        log("2名干员缺失")
        return { notselected }
    end
end

ib.部署干员 = function(干员排位)
    local 指令 = 部署[部署顺序]
    ib.部署操作(干员排位, 指令)
    部署顺序 = 部署顺序 + 1
    if 部署顺序 <= #部署 then
        return 部署[部署顺序]
    end
end

ib.部署操作 = function(干员排位, 指令)
    print("点战斗，部署第" .. 干员排位 .. "位干员")
    local 地图坐标 = 地图数据1[指令["location"][2] + 1][指令["location"][1] + 1]
    --direction: 上1 右2 下3 左4
    local directions = {
        Left = 4,
        Right = 2,
        Up = 1,
        Down = 3,
        None = 2
    }
    local direction = directions[指令["direction"]]
    if 指令["location"][2] <= 2 then 地图坐标[2] = 地图坐标[2] + 10 end
    if 指令["location"][1] == 2 then 地图坐标[1] = 地图坐标[1] - 2 end
    deploy(坐标列表[干员排位][1], scale(地图坐标[1]), scale(地图坐标[2]), direction, 1)

    table.remove(干员列表, 干员排位)
    table.remove(费用列表, 干员排位)
    if table.search(技能指定次数干员, 干员列表[干员排位]) then
        print("重置释放次数", 技能指定次数干员[干员列表[干员排位]])
        技能指定次数干员[干员列表[干员排位]][2] = 0
    end
    table.remove(职业列表, 干员排位)
    sleep(200)
end

--[[ local 识别未部署干员数量 = function()
    local 干员数 = 0
    local BX = scale(1900)
    坐标列表 = {}
    while true do
        local intX = findMultiColor(scale(19), scale(896), BX, scale(896), "000000",
            scale(5) ..
            "|" ..
            scale(-5) ..
            "|000000|" ..
            scale(5) ..
            "|" .. scale(4) .. "|000000|" .. scale(4) .. "|" ..
            scale(-7) .. "|FFFFFF-808080|" .. scale(6) .. "|0|FFFFFF-808080", 2, 0.95)
        if intX < 0 then
            break
        else
            BX = intX - scale(40)
            干员数 = 干员数 + 1
            坐标列表[干员数] = { intX, scale(896) }
        end
    end
    return 干员数
end ]]

ib.战斗识别干员 = function()
    local ret = ocrex("ib_战斗中干员名字范围")
    if #ret == 1 then
        ret = 干员名ocr校正(ret)
        return ret[1]["text"]
    end
end

ib.识别未部署干员 = function()
    local 干员列表 = 获取费用列表()
    releaseCapture()
    -- print("_1378", 干员列表)
    local 干员数 = #干员列表
    -- print("待部署干员" .. 干员数 .. "名")
    if 干员数 > 0 then
        local 干员名字表 = {}
        for 序号, 干员 in pairs(干员列表) do
            tap({ 干员[3], 干员[4] })
            appear(生命值蓝, 0.3)
            local 干员名字 = ib.战斗识别干员()
            if 干员名字 then
                干员[1] = 干员名字
            end
            if (干员数 >= 11 and (序号 == 3 or 序号 == 4 or 序号 == 5)) or (干员数 >= 12 and (序号 == 5 or 序号 == 6 or 序号 == 7)) then
                -- 因为人太多点开之后会偏移漏掉,点回去
                tap({ 干员[3], 干员[4] })
                disappear(生命值蓝, 0.3)
                sleep(20)
            end
            -- print("干员" .. 干员[1] .. ",cost" .. 干员[2])
            table.insert(干员名字表, 干员[1])
            BX, BY = 干员[3], 干员[4]
        end
        tap({ BX, BY })
        sleep(200)
        return 干员名字表
    end
end

ib.释放坐标技能 = function(坐标) --相比较原函数去掉了暂停点击
    local 地图坐标 = {}
    print("释放技能,格子坐标", 坐标[1], 坐标[2])
    local 地图坐标 = 地图数据0[坐标[2] + 1][坐标[1] + 1]
    appear("作战中", 0.5)
    if 坐标[2] <= 1 then
        tap({ scale(地图坐标[1]), scale(地图坐标[2]) })
        sleep(500)
        for i = 1, 6 do
            if findOne("技能ready") then
                sleep(30)
                local p = findOne("技能ready")
                tap({ p[1] - 20, p[2] - 50 })
                技能未就绪 = 0
                波数依赖顺序 = 波数依赖顺序 + 1
                sleep(200)
                tap("点cost")
                sleep(100)
                break
            elseif findOne("开技能") then
                sleep(30)
                tap("开技能")
                技能未就绪 = 0
                波数依赖顺序 = 波数依赖顺序 + 1
                sleep(200)
                tap("点cost")
                sleep(100)
                break
            else
                tap("点cost")
                sleep(100)
                技能未就绪 = 技能未就绪 + 1
                if 技能未就绪 > 25 then
                    技能未就绪 = 0
                    波数依赖顺序 = 波数依赖顺序 + 1
                end
            end
            sleep(200)
        end
        sleep(250)
    else
        for i = 1, 6 do
            keepCapture()
            local intX, intY = 查找技能(地图坐标[1], 地图坐标[2])
            print(intX, intY)
            if intX > -1 then
                tap({ scale(地图坐标[1]), scale(地图坐标[2]) })
                sleep(100)
                keepCapture()
                if findOne("技能ready") then
                    sleep(30)
                    local p = findOne("技能ready")
                    tap({ p[1] - 20, p[2] - 50 })
                else
                    tap("开技能")
                end
                releaseCapture()
                sleep(100)
                技能未就绪 = 0
                波数依赖顺序 = 波数依赖顺序 + 1
                break
            else
                技能未就绪 = 技能未就绪 + 1
                if 技能未就绪 > 40 then
                    技能未就绪 = 0
                    波数依赖顺序 = 波数依赖顺序 + 1
                end
            end
            sleep(300)
        end
    end
    sleep(200)
    if 波数依赖顺序 <= 波数依赖命令数 then
        return 波数依赖[波数依赖顺序]
    end
end

ib.当前阶段 = function()
    local ret
    ret = ocro("ib_阶段识别范围")
    return ret
end

ib.战斗识别干员 = function()
    point["战斗中干员名字范围"] = { scale(20), scale(275), scale(318), scale(318) }
    local ret = ocrex("战斗中干员名字范围")
    if #ret == 1 then
        ret = 干员名ocr校正(ret)
        return ret[1]["text"]
    end
end

ib.撤退干员 = function(坐标)
    print("撤退干员,格子坐标", 坐标[1], 坐标[2])
    local 地图坐标 = 地图数据0[坐标[2] + 1][坐标[1] + 1]

    --if findOne("子弹时间", 0.85) then
    --    地图坐标 = 地图数据1[坐标[2] + 1][坐标[1] + 1]
    --end
    sleep(10)
    print(坐标[1], 坐标[2], "实际坐标", scale(地图坐标[1]), scale(地图坐标[2]))
    tap({ scale(地图坐标[1]), scale(地图坐标[2]) })
    tap("点撤退")
    sleep(300)
    tap("点cost")
    sleep(200)
    releaseCapture()
    --
end

ib.点暂停 = function(a)
    if a then
        tap("剧情中")
        ssleep(.1)
    else
        if findOne("ib_关卡内部顶部标识") then keyPress(4) end
    end
end

ib.战斗 = function()
    if findOne("暂停中") then keyPress(4) end
end

ib.抄作业 = function(作业, maptype)
    -- local 慢放 = 需要慢放干员

    --maa普通作战兼容模式
    部署 = 作业["actions"]
    波数依赖命令数 = 0
    波数依赖 = { "无命令" }

    local 是否剿灭图 = (maptype == 2 or maptype == 3) and 2 or 1
    print(maptype, "是否剿灭图", 是否剿灭图)
    部署顺序 = 1
    部署命令数 = #部署
    波数依赖顺序 = 1
    print(部署命令数, 波数依赖命令数)

    local cost = 0
    local wave = 1, wavetxt
    local cost依赖命令, wave依赖命令
    local 部署指令, 等待cost, 需要cost
    local wave依赖指令, wave部署, wave干员信息, 地图坐标
    local 下排干员数量, 数量变化, 差值
    local 需要, 找到
    local 已部署干员 = {}
    local 操作后, 部署后
    local 延迟消失技能 = { "爆裂黎明", "黄昏", "灯火不灭", "饱和复仇", }

    --点暂停(1)
    干员列表 = ib.识别未部署干员()
    下排干员数量 = 识别未部署干员数量()

    --自动释放技能
    local do_strategy = function()
        --print("无限放技能干员", 无限放技能干员)
        --print("技能指定次数干员")
        for k, v in pairs(技能指定次数干员) do print(k, v) end

        for k, v in pairs(已部署干员) do
            if table.search(无限放技能干员, k) or (技能指定次数干员[k] and 技能指定次数干员[k][2] < 技能指定次数干员[k][1]) then
                地图坐标 = 地图数据0[v[2] + 1][v[1] + 1]
                print("干员" .. k .. "实际坐标", scale(地图坐标[1]), scale(地图坐标[2]))
                local intX, intY = 查找技能(地图坐标[1], 地图坐标[2])
                if intX > -1 then
                    print("干员" .. k .. "技能就绪,实际坐标", scale(地图坐标[1]), scale(地图坐标[2]))
                    tap({ scale(地图坐标[1]), scale(地图坐标[2]) })
                    sleep(30)
                    sleep(300)
                    keepCapture()
                    local p = findOne("技能ready")
                    local skill_name = ocro("技能名称范围")
                    if p then
                        tap({ p[1] - 20, p[2] - 50 })
                    else
                        tap("开技能")
                    end
                    sleep(300)
                    releaseCapture()
                    if not findOne("子弹时间", 0.85) then
                        if 技能指定次数干员[k] then 技能指定次数干员[k][2] = 技能指定次数干员[k][2] + 1 end

                        sleep(150)
                        if skill_name ~= nil and table.includes(延迟消失技能, skill_name) then sleep(1100) end
                    else
                        tap("点cost")
                        --sleep(50)
                    end
                    sleep(50)
                end
            end
        end
    end

    --等待时需要自动释放技能
    local sleep_and_do_strategy = function(delay)
        local start = os.time()
        local time = ((delay - 1) / 1000)
        --print(start, time)
        while os.time() - start < time do
            keepCapture()
            do_strategy()
            sleep(50)
        end
        releaseCapture()
        --print(os.time())
    end

    while true do
        cost = tonumber(获得cost(cost) or cost) or cost
        wavetxt = ib.当前阶段() or 1
        print("当前阶段", wavetxt)
        --将wavetxt最后转为数字
        local number = tonumber(string.sub(wavetxt, -1)) or 1
        if (number - wave) == 1 then
            --转阶段,取消二倍速
            tap("ib_二倍速")
            ssleep(.8)
            干员列表 = ib.识别未部署干员()
            下排干员数量 = 识别未部署干员数量()
        end
        wave = number
        print("当前cost", cost, "当前阶段", wave)

        if 部署顺序 <= 部署命令数 then
            部署指令 = 部署[部署顺序]
            print("部署指令", 部署指令)
            部署指令["kills"] = 部署指令["kills"] or 0
            部署指令["costs"] = 部署指令["costs"] or 0
            if 部署指令["pre_delay"] then
                print("前置延时")
                sleep_and_do_strategy(部署指令["pre_delay"])
            end
            if wave >= 部署指令["kills"] and cost >= 部署指令["costs"] then
                if 干员列表 and (部署指令["type"] == "Deploy" or 部署指令["type"] == "deploy" or 部署指令["type"] == "部署") then
                    local 需要cost = {}
                    干员排位 = table.search(干员列表, 部署指令["name"])
                    print(部署指令["name"], "在第", 干员排位)
                    if 干员排位 then
                        已部署干员[部署指令["name"]] = 部署指令["location"]
                        需要cost = 坐标列表[干员排位]
                        print("干员列表", 干员列表)
                    elseif 群组[部署指令["name"]] then
                        local 找到 = false
                        for i, v in ipairs(群组[部署指令["name"]]) do
                            干员排位 = table.search(干员列表, v["name"])
                            if 干员排位 ~= nil then
                                已部署干员[v["name"]] = 部署指令["location"]
                                需要cost = 坐标列表[干员排位]
                                找到 = true
                                break
                            end
                        end
                        if not 找到 then
                            部署顺序 = 部署顺序 + 1
                        end
                    else
                        print("未找到干员,干员列表", 干员列表)
                        部署顺序 = 部署顺序 + 1
                    end
                    --干员是否可部署
                    if #需要cost > 1 and (cmpColor(需要cost[1] + scale(5), 需要cost[2], "FFFFFF", 0.95) == 1 or cmpColor(需要cost[1] + scale(5), 需要cost[2] - scale(20), "FFFFFF", 0.95) == 1) then
                        部署指令 = ib.部署干员(干员排位)
                        下排干员数量 = 下排干员数量 - 1
                    end
                elseif 部署指令["type"] == "Retreat" or 部署指令["type"] == "Retreat" or 部署指令["type"] == "撤退" then
                    if not 部署指令["location"] then
                        部署指令["location"] = 已部署干员[部署指令["name"]]
                    end
                    ib.撤退干员(部署指令["location"])

                    部署顺序 = 部署顺序 + 1
                elseif 部署指令["type"] == "Skill" or 部署指令["type"] == "skill" or 部署指令["type"] == "技能" then
                    波数依赖顺序 = 部署顺序
                    波数依赖[波数依赖顺序] = 部署指令
                    波数依赖命令数 = 波数依赖顺序
                    部署顺序 = 部署顺序 + 1
                elseif 部署指令["type"] == "SpeedUp" then
                    if not findOne("ib_二倍速开启") then
                        tap("ib_二倍速")
                    end
                    部署顺序 = 部署顺序 + 1
                elseif 部署指令["type"] == "BulletTime" then
                    部署顺序 = 部署顺序 + 1
                elseif 部署指令["type"] == "SkillUsage" then
                    if 部署指令["skill_usage"] == 1 then
                        table.insert(无限放技能干员, 部署指令["name"])
                    elseif 部署指令["skill_usage"] == 0 then
                        table.removev(无限放技能干员, 部署指令["name"])
                    end
                    部署顺序 = 部署顺序 + 1
                elseif 部署指令["type"] == "Output" then
                    部署顺序 = 部署顺序 + 1
                elseif 部署指令["type"] == "MoveCamera" then
                    移动相机(部署指令["distance"])
                    部署顺序 = 部署顺序 + 1
                else
                    print("跳过指令")
                    部署顺序 = 部署顺序 + 1
                end
                if 部署指令 and 部署指令["post_delay"] then
                    sleep_and_do_strategy(部署指令["post_delay"])
                elseif 部署指令 and 部署指令["rear_delay"] then
                    sleep_and_do_strategy(部署指令["rear_delay"])
                end
            end
        end
        if 波数依赖顺序 <= 波数依赖命令数 then
            wave依赖指令 = 波数依赖[波数依赖顺序]
            wave依赖指令["kills"] = wave依赖指令["kills"] or 0
            wave依赖指令["costs"] = wave依赖指令["costs"] or 0
            if wave依赖指令["type"] == "SpeedUp" then
                if not findOne("ib_二倍速开启") then
                    tap("ib_二倍速")
                end
                波数依赖顺序 = 波数依赖顺序 + 1
            else
                if wave >= wave依赖指令["kills"] and cost >= wave依赖指令["costs"] then
                    -- If 操作时间戳1 <> 波数依赖顺序 Then
                    --     操作前延时 = TickCount()
                    --     操作时间戳1 = 波数依赖顺序
                    -- End If
                    if wave依赖指令["type"] == "Skill" or wave依赖指令["type"] == "skill" or wave依赖指令["type"] == "技能" then
                        if wave依赖指令["location"] then
                            wave依赖指令 = ib.释放坐标技能(wave依赖指令["location"])
                        elseif 已部署干员[wave依赖指令["name"]] then
                            wave依赖指令 = ib.释放坐标技能(已部署干员[wave依赖指令["name"]])
                        else
                            wave依赖指令 = 释放技能(wave依赖指令["name"])
                        end
                    elseif wave依赖指令["type"] == "Deploy" or wave依赖指令["type"] == "deploy" or wave依赖指令["type"] == "部署" then
                        干员排位 = table.findk(干员列表, wave依赖指令["name"])
                        print(wave依赖指令["name"], "干员排位", 干员排位)
                        if 干员排位 > -1 then
                            需要 = 费用列表(干员排位)
                            print(需要)
                            if cost >= 需要 then
                                ib.部署操作(干员排位, wave依赖指令)
                                已部署干员[wave依赖指令["name"]] = wave依赖指令["location"]
                                下排干员数量 = 下排干员数量 - 1

                                波数依赖顺序 = 波数依赖顺序 + 1
                            end
                        elseif table.search(群组, wave依赖指令["name"]) == true then
                            print(干员列表)
                            for i, v in ipairs(群组[wave依赖指令["name"]]) do
                                干员排位 = table.search(干员列表, v["name"])
                                print(v["name"], "群组内干员排位", 干员排位)
                                if 干员排位 > -1 then
                                    需要 = 费用列表(干员排位)
                                    ib.部署操作(干员排位, wave依赖指令)
                                    已部署干员[v["name"]] = wave依赖指令["location"]
                                    下排干员数量 = 下排干员数量 - 1

                                    break
                                end
                            end
                            波数依赖顺序 = 波数依赖顺序 + 1
                        else
                            波数依赖顺序 = 波数依赖顺序 + 1
                        end
                        wave依赖指令 = 波数依赖[波数依赖顺序]
                    elseif wave依赖指令["type"] == "Retreat" or wave依赖指令["type"] == "retreat" or wave依赖指令["type"] == "撤退" then
                        if not wave依赖指令["location"] then
                            wave依赖指令["location"] = 已部署干员[wave依赖指令["name"]]
                        end
                        ib.撤退干员(wave依赖指令["location"])

                        波数依赖顺序 = 波数依赖顺序 + 1
                        wave依赖指令 = 波数依赖[波数依赖顺序]
                    end
                end
            end
        end
        do_strategy()

        数量变化 = 识别未部署干员数量() - 下排干员数量
        print("下排干员数量", 下排干员数量, "数量变化", 数量变化)

        if 数量变化 ~= 0 then
            更新未部署干员(数量变化)
            下排干员数量 = 识别未部署干员数量()
        end

        sleep(75)
        releaseCapture()
        if findOne("跳过剧情") then
            path.跳过剧情()
            print("跳过剧情")
            appear("ib_关卡内部顶部标识", 3)
        end
        if findOne("ib_费用请求同意") then
            tap("ib_费用请求同意")
        end
        if findOne("生命值蓝") then
            tap("点cost")
        end
        if findOne("ib_返回房间") or findOne("ib_下一步") then
            log("结束抄作业")
            break
        end
    end
end

ib.battle = function(作业名, 是否自带)
    --local t = os.clock()
    local 技能未就绪 = 0
    local homework = 作业名
    print("prts作战开始", homework)
    local 干员名单 = ""
    群组 = {}
    部署 = {}
    队员技能 = {}
    无限放技能干员 = {}
    技能指定次数干员 = {}
    作业 = loadHomework(作业名, 是否自带)
    print(作业)
    print("读取作业成功")
    --local 地图 = 作业["stage_name"]

    --构建技能相关数据
    local processSkillData = function(oper)
        if table.findk(oper, "skill_usage") then
            if oper["skill_usage"] == 1 then
                table.insert(无限放技能干员, oper["name"])
            elseif oper["skill_usage"] == 2 then
                技能指定次数干员[oper["name"]] = { oper["skill_times"] or 1, 0 }
            end
        end

        if table.findk(oper, "skill") then
            队员技能[oper["name"]] = oper["skill"]
        end
    end

    local groups = 作业["groups"]
    if groups and #groups > 0 then
        for _, group in ipairs(groups) do
            群组[group["name"]] = group["opers"]
            for _, oper in ipairs(group["opers"]) do
                processSkillData(oper)
            end
            if table.findk(group, "skill") then
                for _, oper in ipairs(group["opers"]) do
                    队员技能[oper["name"]] = group["skill"]
                end
            end
        end
    end

    for _, oper in ipairs(作业["opers"]) do
        processSkillData(oper)
    end
    --text = string.sub(text, 1, -2) .. "}"
    --print(text)

    log("读取群组成功")
    log(作业["stage_name"])
    local status, 地图数据 = pcall(loadMap, 作业["stage_name"])
    if not status then
        stop("地图数据读取失败,请去【自动作战】页内更新地图包", '', true, true)
    end
    地图数据0 = 地图数据[1] --放技能坐标
    地图数据1 = 地图数据[2] --放置干员坐标
    地图类型 = 地图数据[3] --地图类型,主要用来区别杀敌数位置:1普通，2剿灭, 3保全, 4肉鸽, 5悖论模拟
    log("读取地图数据成功", "地图类型", 地图类型)

    if not wait(function()
            if findOne("ib_战斗目标横幅") then
                disappear("ib_战斗目标横幅", 5)
                ssleep(5)
                return true
            end
        end, 30) then
        return
    end
    print("抄作业")
    ib.抄作业(作业, 地图类型)

    if not wait(function()
            if findOne("跳过剧情") then
                path.跳过剧情()
            elseif findOne("ib_下一步") then
                return true
            end
        end, 5) then
        return
    end
    sleep(3000)
end
