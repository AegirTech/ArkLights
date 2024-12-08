local 是否保全图 = 0

--编入信赖队员会加大ocr次数数量,会有可能闪退,先禁用
local 添加低信赖 = false

fetchMaps = function()
    local path = getWorkPath() .. '/maps.zip'
    local extract_path = getWorkPath() .. '/maps'
    toast("开始更新地图,大概耗时10s左右,请等待完成提示")
    ui.setButton("map_online", "联网更新地图包(正在下载)")
    if download_from_alist("maps.zip", getWorkPath()) then
        unZip(path, extract_path)
        toast("地图包更新成功")
        ui.setButton("map_online", "联网更新地图包(下载完成)")
    else
        log("地图包版本获取失败,请稍后再试")
        ui.setButton("map_online", "联网更新地图包(下载失败，请重试)")
    end
end

fetchLocalMaps = function()
    local path = "mnt/sdcard/Pictures/maps.zip"
    if not fileExist(path) then
        toast("本地地图包不存在,请检查后重试")
        ssleep(2)
        exit()
    end
    toast("开始更新地图包")
    local extract_path = getWorkPath() .. '/maps'
    unZip(path, extract_path)
    log("本地更新地图成功")
    exit()
end

--加载地图格子数据
loadMap = function(关卡名)
    return JsonDecode(readFile(getWorkPath() .. '/maps/' .. 关卡名 .. ".json"))
end

--- 加载作业
--- @param levelName string 关卡名字
--- @param isLocal boolean 是否自带
loadHomework = function(levelName, isLocal)
    local levelName = levelName or ''
    if isLocal then --自带的作业,比如肉鸽的
        return JsonDecode(readFile(levelName .. ".json"))
    else
        local maaCode = levelName or ''
        print("读取MAA作业站作业", maaCode, "并自动点赞")
        local url = 'https://prts.maa.plus/copilot/get/' .. maaCode
        ::重试::
        local ret, code = httpGet(url)
        -- log(ret)
        local status, data = pcall(JsonDecode, ret)
        if not status then
            toast("未解析到作业,15s后重试")
            ssleep(15)
            goto 重试
        end
        local x = get(data, 'data', 'content')
        local levelInfo = JsonDecode(x)
        local ret, code = httpPost('https://prts.maa.plus/copilot/rating',
            JsonEncode({ rating = "Like", id = tonumber(maaCode), }), 30,
            "Content-Type: application/json")
        log(maaCode, ret)
        return levelInfo
    end
end

-- 辅助作战，手打时自动放技能
auto_skill = function()
    --特殊fix，部分蠢蛋技能需要限制使用次数
    local skillMaxUseTimes = { 横扫架势 = 1, 我无 = 5, 雪境生存法则 = 1, 玲珑 = 1 }

    --特殊fix，部分蠢蛋技能充值太快
    local skillCd = { 异刃斩 = 5, RMA长钉 = 5, 辉煌裂片 = 5, 除恶 = 2, 我无 = 3, 自走车出击！ = 3, 解构与爆破 = 5 }

    local skillUseTimes = {}
    local skillArray = {}
    local skillFind
    local sameSkillInterval
    local blackList = { { -1, -1 } }
    local timeTick = os.time()

    local skillRelease = function()
        log("try skillRelease")
        wait(function()
            local p = findOne("技能ready")
            if p then
                tap({ p[1] - 20, p[2] - 50 })
            else
                tap("开技能")
            end
            if disappear("生命值蓝", 1) then
                return true
            else
                tap("点cost")
                disappear("生命值蓝", 1)
            end
        end)
    end

    local isInBlackList = function(tb1, tb2)
        if tb2 and #tb2 > 0 then
            for _, v in ipairs(tb2) do
                if math.abs(tb1[1] - v[1]) + math.abs(tb1[2] - v[2]) < 20 then
                    return true
                end
            end
        end
    end


    while true do
        --skillFind1 = findOne("技能亮",0.93)
        skillFindAll = findOnes("技能亮", 0.93)
        --[===[        if skillFind then
			log(skillFind)
			log(skillFindAll)
        end]===]

        startBattle = findOne("开始行动")
        --startBattle = false
        if startBattle then
            blackList = { { -1, -1 } }
            skillArray = {}
            skillUseTimes = {}
            --log("重新开始战斗，清理")
        end
        --log(skillFindAll)
        for i = 1, #skillFindAll do
            skillFind = { skillFindAll[i]["x"], skillFindAll[i]["y"] }
            -- log(skillFind)

            -- xy坐标 + 此次找到的时间戳 + 技能最低冷却间隔默认10s
            local skillUse = { skillFind[1], skillFind[2], os.time(), 10 }

            -- 时间差
            local usedTimeGap = -1
            -- 查到的下标
            local findIndex = 0

            for i = 1, #skillArray do
                --计算坐标绝对值差
                local dx = skillArray[i][1] - skillUse[1]
                local dy = skillArray[i][2] - skillUse[2]
                --log("坐标差")
                --log(math.abs(dx) + math.abs(dy))
                if math.abs(dx) + math.abs(dy) < 10 then
                    --log("搜索到历史使用记录")
                    findIndex = i
                    usedTimeGap = skillUse[3] - skillArray[i][3]
                    skillUse[4] = skillArray[i][4]
                    --log("使用时间差")
                    --log(usedTimeGap)
                    goto searchResult
                end
            end

            ::searchResult::

            if isInBlackList(skillFind, blackList) then
                --print("干员已被禁用")
                goto continue
            end

            if usedTimeGap ~= -1 and usedTimeGap < skillUse[4] then
                print("技能CD中，忽略本次查找到的结果")
                goto continue
            end

            tap({ skillFind[1], skillFind[2] + scale(140) })
            -- appear("技能ready", 5)
            ssleep(0.1)
            appear("生命值蓝", 5)
            --ocr 干员技能名字
            local skillName = ocr("技能名称范围")

            --查不到技能就点就完事了
            if skillName and #skillName > 0 then
                --print (blackList,skillFind)
                local skill = skillName[1]["text"]

                -- 有特殊CD时间的，塞进去
                if skillCd[skill] then
                    skillUse[4] = skillCd[skill]
                end

                -- 记一次技能使用
                if not skillUseTimes[skill] then
                    skillUseTimes[skill] = 1
                else
                    skillUseTimes[skill] = skillUseTimes[skill] + 1
                end

                -- 判定此次使用后使用次数是否超限
                if skillMaxUseTimes[skill]
                    and skillUseTimes[skill] >= skillMaxUseTimes[skill] then
                    --print("禁用技能")
                    --print(skill)
                    table.insert(blackList, skillFind)
                end
            end
            --使用技能
            skillRelease()

            -- 存入使用记录
            if findIndex == 0 then
                --log("新增使用记录")
                table.insert(skillArray, skillUse)
            else
                skillArray[findIndex] = skillUse
            end

            ::continue::
        end
        ssleep(0.3)
    end
    exit()
end

auto_prts = function(作业名, 需要编队, 是否自带)
    --local t = os.clock()
    local 技能未就绪 = 0
    local homework = 作业名
    print("prts作战开始", homework)
    local 干员名单 = ""
    --print(作业路径)
    --local 职业 = { "先锋", "近卫", "重装", "医疗", "术师", "狙击", "特种", "辅助", "召唤物", "all" }
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

    --print("无限放技能干员", 无限放技能干员)
    --print("技能指定次数干员", 技能指定次数干员)

    --print(地图)
    log(作业["stage_name"])
    local status, 地图数据 = pcall(loadMap, 作业["stage_name"])
    if not status then
        stop("地图数据读取失败,请去测试功能内更新地图包", '', true, true)
    end
    地图数据0 = 地图数据[1] --放技能坐标
    地图数据1 = 地图数据[2] --放置干员坐标
    地图类型 = 地图数据[3] --地图类型,主要用来区别杀敌数位置:1普通，2剿灭, 3保全, 4肉鸽, 5悖论模拟
    训练地图 = 地图数据[4] --是否是教学关0否,1是
    log("读取地图数据成功", "地图类型", 地图类型, "训练地图", 训练地图)

    if 需要编队 == true and 训练地图 == 0 then
        if 地图类型 == 5 then
            tap("悖论模拟界面")
            local 悖论模拟选技能 = function()
                if not wait(function()
                        if findOne("悖论模拟选择技能") then return true end
                    end, 3) then
                    log("低星干员无技能,跳过选择技能")
                    return
                end
                if 作业["opers"][1]["skill"] == 1 then
                    tap("悖论模拟技能1")
                    sleep(400)
                    tap("悖论模拟技能1")
                elseif 作业["opers"][1]["skill"] == 2 then
                    tap("悖论模拟技能2")
                    sleep(400)
                    tap("悖论模拟技能2")
                elseif 作业["opers"][1]["skill"] == 3 then
                    tap("悖论模拟技能3")
                    sleep(400)
                    tap("悖论模拟技能3")
                end
            end
            悖论模拟选技能()
        else
            if 自动编队(作业["opers"], 群组) == false then return false end
        end
        releaseCapture()
    end
    if findOne("开始行动保全") then
        tap("开始行动保全")
        是否保全图 = 1
        local 换牌数 = 0
        repeat
            if findOne("保全换牌") == true then
                干员列表 = 获取费用列表()
                for _, i in ipairs(干员列表) do
                    if i[1] == "特种" or i[1] == "辅助" or i[1] == "医疗" or i[1] == "召唤物" then
                        tap({ scale(i[3]), scale(i[4]) })
                        换牌数 = 换牌数 + 1
                        sleep(50)
                        if 换牌数 > 3 then
                            break
                        end
                    end
                end
                tap("开始行动保全")
                break
            end
            sleep(500)
        until false
    end
    if 地图类型 ~= 5 and not wait(function()
            local p = findAny({ "开始行动红按钮", "开始行动突袭", "开始行动演习", "开始行动肉鸽", "开始行动悖论模拟", "开始行动磨难" })
            print(p)
            if p then
                tap(p)
                -- TODO 2秒太慢 => 一开始就用0秒, 2秒内增加至2秒
                return disappear(p, 5)
            end
        end, 10) then
        return
    end
    if not wait(function()
            --[===[if findOne(肉鸽返回) == true then
	tap(肉鸽返回[1], 肉鸽返回[2])
	elseif findOne(肉鸽开始行动) == true then
	tap(肉鸽开始行动[1], 肉鸽开始行动[2])
	else]===]
            if findOne("跳过剧情") then
                print("跳过剧情")
                path.跳过剧情()
                sleep(3000)
            elseif findOne("战斗中剧情对话") then
                wait(function()
                    tap("点cost")
                    ssleep(.3)
                    if findOne("作战中") or findOne("暂停中") or findOne("作战中2") then return true end
                end, 30)
            elseif findOne("作战中") then
                return true
            end
        end, 120) then
        return
    end
    print("抄作业")
    抄作业(作业, tonumber(地图类型))

    if not wait(function()
            --[===[if findOne(肉鸽返回) == true then
	tap(肉鸽返回[1], 肉鸽返回[2])
	elseif findOne(肉鸽开始行动) == true then
	tap(肉鸽开始行动[1], 肉鸽开始行动[2])
	else]===]
            if findOne("跳过剧情") then
                path.跳过剧情()
            elseif findOne("作战中") then
                return true
            end
        end, 5) then
        return
    end
    sleep(3000)
end

auto_sss = function(作业名, 需要编队, 是否自带)
    ------------------------init部分
    local 技能未就绪 = 0
    local homework = 作业名
    print("prts作战开始", homework)
    local 干员名单 = ""
    --local 职业 = { "先锋", "近卫", "重装", "医疗", "术师", "狙击", "特种", "辅助", "召唤物", "all" }
    群组 = {}
    部署 = {}
    队员技能 = {}
    无限放技能干员 = {}
    技能指定次数干员 = {}
    作业 = loadHomework(作业名, 是否自带)
    print(作业)
    print("读取作业成功")
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
            群组[group["name"]]["qty_reqd"] = group["qty_reqd"] or 1
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
    log("读取群组成功")
    log(groups)
    log(作业["stage_name"])

    ------------------------init部分完毕

    if not wait(function()
            if findOne("开始保全作战", 0.9) then
                tap("开始保全作战")
                sleep(10)
            end
            if findOne("选择导能元件") then return true end
        end, 5) then
        log("进入保全失败")
        return
    end
    local 导能元件 = tonumber(作业["buff"]) or 3 --默认用第三个元件
    tap("导能元件列表" .. 导能元件)
    if not appear("导能元件确认选择蓝", 2) then return false end
    sleep(100)
    tap("导能元件确认选择蓝")
    if not appear("选择战术装备", 3) then return false end
    sleep(100)
    local 战术装备 = 作业["equipment"]
    log(战术装备)
    for i = 1, 8 do
        if 战术装备[i] ~= "A" or not findOne("战术装备列表" .. i, 0.9) then
            tap("战术装备列表" .. i)
            sleep(50)
        end
    end
    tap("导能元件确认选择蓝")
    disappear("正在提交反馈至神经", network_timeout)
    sleep(100)

    if not appear("保全快捷编队", 3) then return false end
    if 需要编队 == true then
        if 保全自动编队(作业["opers"], 群组, 作业["tool_men"], 作业["blacklist"]) == false then return false end
        releaseCapture()
    end

    if not appear("导能元件确认选择蓝", 3) then
        log("选人出现错误,没有选满")
        return false
    else
        tap("导能元件确认选择蓝")
        ssleep(4)
    end
    toast('等待2S 跳过教程')
    wait(function()
        tap("隐秘战线教程关闭")
    end, 2)

    for i = 1, 6 do
        local 当前层数 = tonumber(utf8.right(ocro("保全层数范围"), 1) or 1)
        i = 当前层数
        log("当前层数" .. 当前层数, 作业["stages"][当前层数]["stage_name"])
        local status, 地图数据

        status, 地图数据 = pcall(loadMap, 作业["stages"][当前层数]["stage_name"])
        if not status then
            stop("地图数据读取失败,请去测试功能内更新地图包", '', true, true)
        end
        地图数据0 = 地图数据[1] --放技能坐标
        地图数据1 = 地图数据[2] --放置干员坐标
        地图类型 = 地图数据[3] --地图类型,主要用来区别杀敌数位置:1普通，2剿灭, 3保全, 4肉鸽, 5悖论模拟
        训练地图 = 地图数据[4] --是否是教学关0否,1是
        log("读取地图数据成功", "地图类型", 地图类型, "训练地图", 训练地图)
        tap("开始行动保全")
        ssleep(1)
        if 当前层数 > 1 then
            if not wait(function()
                    if findOne("开始行动保全") then return true end
                    if findOne("保全增调干员") then
                        tap("保全增调干员")
                        ssleep(.3)
                        tap("保全放弃调用")
                        ssleep(.3)
                    end
                    if findOne("导能配件甄选") then
                        tap("导能配件甄选列表" .. (作业["buff_upgrade"] or 1))
                        ssleep(.3)
                        tap("保全放弃调用")
                        ssleep(.3)
                    end
                    ssleep(.3)
                end, 15) then
                log("进入保全失败")
                return
            end
        end
        if findOne("开始行动保全") then
            tap("开始行动保全")
            是否保全图 = 1
            local 换牌数 = 0
            while true do
                if findOne("保全换牌") then
                    干员列表 = 获取费用列表()
                    for _, i in ipairs(干员列表) do
                        if i[1] == "特种" or i[1] == "辅助" or i[1] == "医疗" or i[1] == "召唤物" then
                            tap({ scale(i[3]), scale(i[4]) })
                            换牌数 = 换牌数 + 1
                            sleep(50)
                            if 换牌数 > 3 then
                                break
                            end
                        end
                    end
                    tap("保全换牌")
                    break
                end
                sleep(500)
            end
        end
        sleep(1000)
        print("抄作业")
        保全抄作业(作业["stages"][当前层数], tonumber(地图类型))

        if not wait(function()
                tap("隐秘战线教程关闭")
                ssleep(2)
                if findOne("开始行动保全") then return true end
            end, 15) then
            return
        end
        ssleep(1)
    end
end

自动编队 = function(干员, 群组)
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

    appear("快捷编队", 3)
    if not wait(function()
            if findOne("编队清空选择") then return true end
            tap("快捷编队")
            sleep(10)
        end, 5) then
        return
    end
    if not wait(function()
            if findOne("无干员选中") then return true end
            tap("编队清空选择")
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
                未编入 = 选择干员(干员目录, "待编队干员", 是否群组)

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
                if not findOne("职业选择") then
                    tap("职业选择")
                    appear("职业选择", 2)
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


    if 编入数量 < 10 and 添加低信赖 then
        if not findOne("普通作战编队自定义排序") then
            tap("普通作战编队自定义排序")
            appear("普通作战编队自定义排序", 2)
        end
        if not findOne("普通作战编队信赖升序") then
            tap("普通作战编队信赖升序")
            sleep(10)
            tap("普通作战编队信赖升序")
            sleep(10)
        end
        if not findOne("职业选择") then
            tap("普通作战编队自定义排序关闭")
            appear("职业选择", 2)
        end
        print("编入低信赖干员")
        for i = 编入数量, 9 do
            tap({ scale(740 + math.floor(i / 2) * 217), scale(1080 - 754 + (i % 2) * 421) })
        end
    end
    tap("编队确认")
    appear("快捷编队", 3)
    print(未编入干员)
    if 未编入数量 >= 1 then
        log("编队未完成，需要手动编队")
        sleep(1000)
        path.跳转("首页")
        return false
    end
    -- if 未编入数量 == 1 then
    --     Call 编入支援干员(未编入干员,1)
    -- end
end

保全自动编队 = function(干员, 群组)
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

    appear("保全快捷编队", 3)
    if not wait(function()
            if findOne("编队清空选择") then return true end
            tap("保全快捷编队")
            sleep(10)
        end, 5) then
        return
    end
    if not wait(function()
            if findOne("无干员选中") then return true end
            tap("编队清空选择")
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
        local 群组需要数量 = 1
        if 是否群组 then
            记录未编入数量 = 未编入数量
            群组需要数量 = 干员["qty_reqd"]
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
                未编入 = 选择干员(干员目录, "待编队干员", 是否群组, 群组需要数量)

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
                if not findOne("职业选择") then
                    tap("职业选择")
                    appear("职业选择", 2)
                    sleep(300)
                end
            end
            --print("编入数量", 编入数量)
        end
    end

    printChar(干员)
    choseChar(干员)
    for name, group in pairs(群组) do
        log(name)
        if string.finds(name, { "工具人" }) then
            if not findOne("稀有度升序", 0.9) then
                tap("稀有度升序")
                sleep(50)
                tap("稀有度升序")
                appear("等级降序", 2)
            end
        else
            if not findOne("等级降序") then
                tap("等级降序")
                appear("等级降序", 2)
            end
        end
        printChar(group)
        choseChar(group, 1)
    end

    tap("编队确认")
    appear("保全快捷编队", 3)
    print(未编入干员)
    if 未编入数量 >= 1 then
        log("编队未完成，需要手动编队")
        sleep(1000)
        path.跳转("首页")
        return false
    end
    -- if 未编入数量 == 1 then
    --     Call 编入支援干员(未编入干员,1)
    -- end
end

选择干员 = function(干员目录, 字典, 是否群组, 群组需要数量)
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
                            tap({ 结果["r"] - 100, 结果["b"] - 200 })
                        else
                            tap({ 结果["r"] - 100, 结果["b"] - 200 }) --肉鸽?
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
        local 识别结果 = 干员名ocr校正(ocrex("上排干员范围"))
        找干员(识别结果)
        if 是否群组 and selected >= 群组需要数量 then return { 0 } end
        print("识别下")
        识别结果 = 干员名ocr校正(ocrex("下排干员范围"))
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

swipe_next_page = function(left, nodelay)
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
        local x = scale(600)
        local y = scale(533)
        local y2 = scale(900)
        --修改x2坐标，滑动两个位置是1035 滑动三个位置是1252 滑动四个位置1470
        local x2 = scale(1252)
        local x3 = scale(1695)
        local y3 = scale(952)
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
    --log(JsonEncode(finger))
    gesture(finger)
    sleep(duration + (nodelay and 0 or delay))
    return nodelay and delay or 0
end

选择技能 = function(a)
    --print("选择技能", a)
    if a == 3 then
        gesture({
            {
                point = { { scale(103), screen.height * 0.95 }, { scale(103), screen.height / 2 } },
                start = 0,
                duration = 500,
            },
        })
        sleep(300)
        tap("选择三技能")
    elseif a == 1 then
        tap("选择一技能")
        sleep(30)
    else
        local intY = scale(403)
        keepCapture()
        for i = 1, a do
            local ret, intX, intY = findColor(scale(13), scale(1078), scale(14), intY + scale(i * 157), "121212", 0, 0.85) --找左上角黑点
            --print(ret,intX, intY, i)
            if i == a and intX > -1 then
                tap({ intX, intY })

                sleep(30)
            end
        end
    end
end
--[===[
function 识别肉鸽地图()

if findOne(肉鸽战斗进入) or findOne(肉鸽boss作战进入) then
TURING.Pixel_FromScreen(770, 1330, 822, 1554) -- 需要修改的地方！
elseif findOne(肉鸽紧急作战进入) then
TURING.Pixel_FromScreen(826, 1335, 876, 1559) -- 需要修改的地方！
end

TURING.Filter_Rotate(270)
TURING.Filter_Binaryzation("0-180")
TURING.Incise_ScopeAisle(10, 10)
print(TURING.Lib_Load(GetTempDir() .. "肉鸽地图名.lib")) -- 识别字库路径可自行更换！！！

return TURING.OCR(80)
end

function 识别待编队干员(字典)
local t = TickCount()
print(turing.Version())

TURING.Pixel_FromScreen(573, 639, 604, 1589)
TURING.Filter_Rotate(270)
TURING.Filter_Binaryzation("0-199")
TURING.Incise_ScopeAisle(8, 3)
-- 识别字库路径可自行更换！！！
print("加载条数", TURING.Lib_Load(临时目录 .. "待编队干员.lib", 字典))
local 识别结果 = TURING.OCR(70, 2, 50)
t = TickCount() - t
print(t, 识别结果)

TURING.Pixel_FromScreen(157, 639, 188, 1589)
TURING.Filter_Rotate(270)
TURING.Filter_Binaryzation("0-199")
TURING.Incise_ScopeAisle(8, 3)
-- 识别字库路径可自行更换！！！
-- print(字典)
print(TURING.Lib_Load(临时目录 .. "待编队干员.lib", 字典))
识别结果 = TURING.OCR(70, 2, 50)
t = TickCount() - t
print(t, 识别结果)
end

function 识别支援干员(a)
for i = 0, 8 do
TURING.Pixel_FromScreen(840 - 298 * math.floor(i / 3), 261 + 678 * (i % 3), 902 - 298 * math.floor(i / 3), 437 + 678 * (i % 3)) -- 需要修改的地方！
TURING.Filter_Rotate(270)
TURING.Filter_Binaryzation("0-172")
TURING.Incise_ScopeAisle(10, 1)
TURING.Lib_Load(GetTempDir() .. "肉鸽干员.lib", a) -- 识别字库路径可自行更换！！！
if TURING.OCR(85) == a then
local 识别支援干员 = {840 - 298 * math.floor(i / 3), 785 + 678 * (i % 3)}
return 识别支援干员
end
end
end

function 编入支援干员(数组, 方式)
print("编入支援干员")
local 干员类型 = 数组[1]
local 干员 = 数组[2]
local 识别结果, b64, 结果
local 选到干员 = false
print(干员类型, 干员)
-- tap 769,1653 -- 支援加号
sleep(1500)
tap(882 - 干员类型 * 114, 86) -- 干员类别
sleep(800)
-- Swipe 720, 255,725, 1610 -- 滑动到左边
-- sleep 1000
for _ = 1, 25 do
for i = 0, 7 do
if 方式 == 1 then
TURING.Pixel_FromScreen(188, 204 + 208 * i, 230, 376 + 208 * i)
TURING.Filter_Rotate(270)
TURING.Filter_Binaryzation("0-178")
TURING.Incise_ScopeAisle(10, 10)
-- TURING.Pixel_Preview()
TURING.Lib_Load(GetTempDir() .. "支援干员.lib", 干员)
结果 = TURING.OCR(80)
end
print(i, 结果)
if 识别结果   then
if 结果 == 干员 then
tap(245, 281 + 208 * i)
sleep(1000)
选到干员 = true
end
end
end

if 选到干员 then
break
else
tap(1021, 1765)
sleep(1500)
end
end
end
]===]

抄作业 = function(作业, maptype)
    -- local 慢放 = 需要慢放干员
    if maptype == 4 then
        local 行动下标 = {}
        local 操作
        local 行动 = 作业["actions"]
        for i = 1, #行动 do
            操作 = 行动[i]
            --print(操作)
            if 操作["type"] == "Deploy" or 操作["type"] == "SkillUsage" then
                if 操作["kills"] or 操作["cost"] then
                    break
                else
                    table.insert(部署, 操作)
                    table.insert(行动下标, i)
                end
            end
        end
        波数依赖 = 作业["actions"]
        for i = #行动下标, 1, -1 do
            table.remove(波数依赖, 行动下标[i])
        end

        波数依赖命令数 = #波数依赖
    else
        --maa普通作战兼容模式
        部署 = 作业["actions"]
        波数依赖命令数 = 0
        波数依赖 = { "无命令" }
    end

    local 是否剿灭图 = (maptype == 2 or maptype == 3) and 2 or 1
    print(maptype, "是否剿灭图", 是否剿灭图)
    部署顺序 = 1
    部署命令数 = #部署
    波数依赖顺序 = 1
    print(部署命令数, 波数依赖命令数)

    local cost = 0, wave, wavetxt
    local cost依赖命令, wave依赖命令
    local 部署指令, 等待cost, 需要cost
    local wave依赖指令, wave部署, wave干员信息, 地图坐标
    local 下排干员数量, 数量变化, 差值
    local 需要, 找到
    local 已部署干员 = {}
    local 操作后, 部署后
    local 延迟消失技能 = { "爆裂黎明", "黄昏", "灯火不灭", "饱和复仇", }

    if findOne("剧情中3") then
        tap("剧情中")
        print("跳过无按钮剧情")
        appear("作战中", 2)
        加速()
    end

    点暂停(1)
    加速()
    干员列表 = 识别未部署干员()
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
                local intX, intY = findMultiColor(scale(地图坐标[1] - 10), scale(地图坐标[2] - 180), scale(地图坐标[1] + 10),
                    scale(地图坐标[2] - 80), "EBA22F-101010", scale(-21) .. "|" .. scale(-21) ..
                    "|F6A516-101010|" .. scale(5) .. "|" .. scale(-10) .. "|280500-101010|" .. scale(21) .. "|"
                    .. scale(-21) .. "|E4932E-101010|" .. scale(-6) .. "|" .. scale(-8) .. "|2E1501-101010",
                    0, 0.87)
                if intX > -1 then
                    print("干员" .. k .. "技能就绪,实际坐标", scale(地图坐标[1]), scale(地图坐标[2]))
                    tap({ scale(地图坐标[1]), scale(地图坐标[2]) })
                    sleep(30)
                    点暂停()
                    appear("暂停中", 0.5)
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
                        点战斗()
                        sleep(150)
                        if skill_name ~= nil and table.includes(延迟消失技能, skill_name) then sleep(400) end
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
        点战斗()
        cost = tonumber(获得cost() or cost) or cost

        wavetxt = 获得敌人数(是否剿灭图)
        --print("当前波次", wavetxt)
        local number = tonumber(string.match(wavetxt, "%d+"))
        if number and number - wave < 5 then wave = number end

        print("当前cost", cost, "已击败敌人数", wave)

        if 部署顺序 <= 部署命令数 then
            部署指令 = 部署[部署顺序]
            print("部署指令", 部署指令)
            部署指令["kills"] = 部署指令["kills"] or 0
            部署指令["costs"] = 部署指令["costs"] or 0
            if 部署指令["pre_delay"] then
                print("前置延时")
                sleep_and_do_strategy(部署指令["pre_delay"])
            end
            if findAny({ "剧情中", "剧情中2", "剧情中3", "剧情中4", "生息演算剧情上", "生息演算剧情下" }) then
                tap("剧情中")
                print("跳过无按钮剧情")
                appear("作战中", 2)
                加速()
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
                        print("111")
                        for i, v in ipairs(群组[部署指令["name"]]) do
                            干员排位 = table.search(干员列表, v["name"])
                            if 干员排位 ~= nil then
                                已部署干员[v["name"]] = 部署指令["location"]
                                需要cost = 坐标列表[干员排位]
                                找到 = true
                                break
                            end
                        end
                        if not 找到 and 训练地图 == 0 then
                            部署顺序 = 部署顺序 + 1
                        end
                    else
                        print("未找到干员,干员列表", 干员列表)
                        if 训练地图 == 0 then 部署顺序 = 部署顺序 + 1 end
                    end
                    --干员是否可部署
                    if #需要cost > 1 and (cmpColor(需要cost[1] + scale(5), 需要cost[2], "FFFFFF", 0.95) == 1 or cmpColor(需要cost[1] + scale(5), 需要cost[2] - scale(20), "FFFFFF", 0.95) == 1) then
                        部署指令 = 部署干员(干员排位)
                        下排干员数量 = 下排干员数量 - 1
                        点战斗()
                    end
                elseif 部署指令["type"] == "Retreat" or 部署指令["type"] == "Retreat" or 部署指令["type"] == "撤退" then
                    if not 部署指令["location"] then
                        部署指令["location"] = 已部署干员[部署指令["name"]]
                    end
                    撤退干员(部署指令["location"])
                    点战斗()
                    部署顺序 = 部署顺序 + 1
                elseif 部署指令["type"] == "Skill" or 部署指令["type"] == "skill" or 部署指令["type"] == "技能" then
                    波数依赖顺序 = 部署顺序
                    波数依赖[波数依赖顺序] = 部署指令
                    波数依赖命令数 = 波数依赖顺序
                    部署顺序 = 部署顺序 + 1
                elseif 部署指令["type"] == "SpeedUp" then
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
                elseif 训练地图 == 0 then
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
                加速()
                波数依赖顺序 = 波数依赖顺序 + 1
            else
                if wave >= wave依赖指令["kills"] and cost >= wave依赖指令["costs"] then
                    -- If 操作时间戳1 <> 波数依赖顺序 Then
                    --     操作前延时 = TickCount()
                    --     操作时间戳1 = 波数依赖顺序
                    -- End If


                    if wave依赖指令["type"] == "Skill" or wave依赖指令["type"] == "skill" or wave依赖指令["type"] == "技能" then
                        if wave依赖指令["location"] then
                            wave依赖指令 = 释放坐标技能(wave依赖指令["location"])
                        elseif 已部署干员[wave依赖指令["name"]] then
                            wave依赖指令 = 释放坐标技能(已部署干员[wave依赖指令["name"]])
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
                                部署操作(干员排位, wave依赖指令)
                                已部署干员[wave依赖指令["name"]] = wave依赖指令["location"]
                                下排干员数量 = 下排干员数量 - 1
                                点战斗()
                                波数依赖顺序 = 波数依赖顺序 + 1
                            end
                        elseif table.search(群组, wave依赖指令["name"]) == true then
                            print(干员列表)
                            for i, v in ipairs(群组[wave依赖指令["name"]]) do
                                干员排位 = table.search(干员列表, v["name"])
                                print(v["name"], "群组内干员排位", 干员排位)
                                if 干员排位 > -1 then
                                    需要 = 费用列表(干员排位)
                                    部署操作(干员排位, wave依赖指令)
                                    已部署干员[v["name"]] = wave依赖指令["location"]
                                    下排干员数量 = 下排干员数量 - 1
                                    点战斗()
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
                        撤退干员(wave依赖指令["location"])
                        点战斗()
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
        点战斗()
        sleep(75)
        if findOne("跳过剧情") then
            path.跳过剧情()
            print("跳过剧情")
            appear("作战中", 3)
            加速()
        end


        if not (findOne("作战中") or findOne("暂停中") or findOne("作战中2")) then
            sleep(500)
            if findAny({ "剧情中", "剧情中2", "剧情中3", "剧情中4", "生息演算剧情上", "生息演算剧情下" }) then
                tap("剧情中")
                --迷宫饭适配
                tap({ scale(1040), scale(384) })
                tap({ scale(1306), scale(608) })
                print("跳过无按钮剧情")
                appear("作战中", 2)
                加速()
            elseif findAny({ "作战中", "暂停中", "作战中2" }) then
            else
                --snapShot("/mnt/sdcard/test"..os.time()..".png")
                if appear("战斗中剧情对话", 3) then
                    wait(function()
                        tap("点cost")
                        ssleep(.3)
                        if findAny({ "作战中", "暂停中", "作战中2" }) then return true end
                    end, 30)
                else
                    print("结束抄作业")
                    break
                end
            end
        end
    end
end

保全抄作业 = function(作业, maptype)
    -- local 慢放 = 需要慢放干员

    --maa普通作战兼容模式
    部署 = 作业["actions"]
    波数依赖命令数 = 0
    波数依赖 = { "无命令" }

    local 是否剿灭图 = (maptype == 2 or maptype == 3) and 2 or 1
    print(maptype, "是否剿灭图", 是否剿灭图)
    部署顺序 = 1
    波数依赖顺序 = 1
    print(#部署, 波数依赖命令数)

    local cost = 0, wave, wavetxt
    local cost依赖命令, wave依赖命令
    local 部署指令, 等待cost, 需要cost
    local wave依赖指令, wave部署, wave干员信息, 地图坐标
    local 下排干员数量, 数量变化, 差值
    local 需要, 找到
    local 已部署干员 = {}
    createTransposedArray = function(originalArray)
        local rows = #originalArray    -- 原数组的行数
        local cols = #originalArray[1] -- 原数组的列数
        local transposedArray = {}     -- 创建一个新的空数组
        -- 初始化新数组的行
        for i = 1, cols do
            transposedArray[i] = {}
        end
        -- 填充新数组
        for i = 1, rows do
            for j = 1, cols do
                transposedArray[j][i] = {
                    name = "无",
                    终端 = false,
                    核心 = false,
                    times = 0,
                }
            end
        end
        return transposedArray
    end
    local 已部署格子 = createTransposedArray(地图数据0)
    log(已部署格子)
    local 操作后, 部署后
    local 延迟消失技能 = { "爆裂黎明", "黄昏", "灯火不灭", "饱和复仇", }

    if findOne("剧情中3") then
        tap("剧情中")
        print("跳过无按钮剧情")
        appear("作战中", 2)
        加速()
    end

    点暂停(1)
    加速()
    干员列表 = 识别未部署干员()
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
                local intX, intY = findMultiColor(scale(地图坐标[1] - 10), scale(地图坐标[2] - 180), scale(地图坐标[1] + 10),
                    scale(地图坐标[2] - 80), "EBA22F-101010", scale(-21) .. "|" .. scale(-21) ..
                    "|F6A516-101010|" .. scale(5) .. "|" .. scale(-10) .. "|280500-101010|" .. scale(21) .. "|"
                    .. scale(-21) .. "|E4932E-101010|" .. scale(-6) .. "|" .. scale(-8) .. "|2E1501-101010",
                    0, 0.87)
                if intX > -1 then
                    print("干员" .. k .. "技能就绪,实际坐标", scale(地图坐标[1]), scale(地图坐标[2]))
                    tap({ scale(地图坐标[1]), scale(地图坐标[2]) })
                    sleep(30)
                    点暂停()
                    appear("暂停中", 0.5)
                    sleep(300)
                    keepCapture()
                    local p = findOne("技能ready")
                    local skill_name = ocro("技能名称范围")
                    log(1491)
                    if p then
                        tap({ p[1] - 20, p[2] - 50 })
                    else
                        tap("开技能")
                    end
                    sleep(300)
                    releaseCapture()
                    if not findOne("子弹时间", 0.85) then
                        if 技能指定次数干员[k] then 技能指定次数干员[k][2] = 技能指定次数干员[k][2] + 1 end
                        点战斗()
                        sleep(550)
                        --if skill_name ~= nil and table.includes(延迟消失技能, skill_name) then sleep(400) end
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
        点战斗()
        cost = tonumber(获得cost() or cost) or cost

        wavetxt = 获得敌人数(是否剿灭图)
        --print("当前波次", wavetxt)
        local number = tonumber(string.match(wavetxt, "%d+"))
        if number and number - wave < 5 then wave = number end

        print("当前cost", cost, "已击败敌人数", wave)

        if 部署顺序 <= #部署 then
            部署指令 = 部署[部署顺序]
            部署指令["kills"] = 部署指令["kills"] or 0
            部署指令["costs"] = 部署指令["costs"] or 0
            local 行 = 部署指令["location"][1]
            local 列 = 部署指令["location"][2]
            print("部署指令", 行, 列, 部署顺序, 部署指令)
            if 部署指令["pre_delay"] then
                print("前置延时")
                sleep_and_do_strategy(部署指令["pre_delay"])
            end
            if findAny({ "剧情中", "剧情中2", "剧情中3", "剧情中4", "生息演算剧情上", "生息演算剧情下" }) then
                tap("剧情中")
                print("跳过无按钮剧情")
                appear("作战中", 2)
                加速()
            end
            if wave >= 部署指令["kills"] and cost >= 部署指令["costs"] then
                if 干员列表 and (部署指令["type"] == "Deploy" or 部署指令["type"] == "deploy" or 部署指令["type"] == "部署") then
                    local 需要cost = {}
                    干员排位 = table.search(干员列表, 部署指令["name"])
                    print(部署指令["name"], "在第", 干员排位)
                    if 群组[部署指令["name"]] then
                        local 找到 = false
                        local 移到最后 = true
                        print("群组部署命令", 部署指令["name"])
                        if 已部署格子[行][列]["终端"] and 已部署格子[行][列]["times"] > 5 then
                            print("行", 行, "列", 列, 已部署格子[行][列]["终端"], 已部署格子[行][列]["times"])
                            移到最后 = false
                            goto 跳过检测
                        end
                        if string.finds(部署指令["name"], { "终端" }) and 已部署格子[行][列]["times"] < 5 then
                            print("行", 行, "列", 列, 已部署格子[行][列]["times"])
                            goto 跳过检测
                        end
                        if string.finds(部署指令["name"], { "工具人" }) and 已部署格子[行][列]["times"] >= 4 then
                            移到最后 = false
                            goto 跳过检测
                        end

                        for i, v in ipairs(群组[部署指令["name"]]) do
                            干员排位 = table.search(干员列表, v["name"])
                            if 干员排位 ~= nil then
                                已部署干员[v["name"]] = 部署指令["location"]
                                已部署格子[行][列]["name"] = v["name"]
                                需要cost = 坐标列表[干员排位]
                                找到 = true
                                break
                            end
                        end
                        ::跳过检测::
                        if 移到最后 then table.insert(部署, 部署[部署顺序]) end
                        if not 找到 then
                            -- 将当前指令移至最后并跳过
                            部署顺序 = 部署顺序 + 1
                        end
                    else
                        print("未找到干员,干员列表", 干员列表)
                        if 训练地图 == 0 then 部署顺序 = 部署顺序 + 1 end
                    end
                    --干员是否可部署
                    if #需要cost > 1 and (cmpColor(需要cost[1] + scale(5), 需要cost[2], "FFFFFF", 0.95) == 1 or cmpColor(需要cost[1] + scale(5), 需要cost[2] - scale(20), "FFFFFF", 0.95) == 1) then
                        部署指令 = 部署干员(干员排位)
                        下排干员数量 = 下排干员数量 - 1
                        log(已部署格子[行][列])
                        if string.finds(部署指令["name"], { "终端" }) then
                            已部署格子[行][列]["终端"] = true
                        elseif string.finds(部署指令["name"], { "核心" }) then
                            已部署格子[行][列]["核心"] = true
                        end
                        已部署格子[行][列]["times"] = 已部署格子[行][列]["times"] + 1
                        点战斗()
                    end
                elseif 部署指令["type"] == "Retreat" or 部署指令["type"] == "Retreat" or 部署指令["type"] == "撤退" then
                    if not 部署指令["location"] then
                        部署指令["location"] = 已部署干员[部署指令["name"]]
                    end
                    撤退干员(部署指令["location"])
                    点战斗()
                    部署顺序 = 部署顺序 + 1
                elseif 部署指令["type"] == "Skill" or 部署指令["type"] == "skill" or 部署指令["type"] == "技能" then
                    波数依赖顺序 = 部署顺序
                    波数依赖[波数依赖顺序] = 部署指令
                    波数依赖命令数 = 波数依赖顺序
                    部署顺序 = 部署顺序 + 1
                elseif 部署指令["type"] == "SpeedUp" then
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
                elseif 训练地图 == 0 then
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
            local 行 = wave依赖指令["location"][1]
            local 列 = wave依赖指令["location"][2]
            if wave依赖指令["type"] == "SpeedUp" then
                加速()
                波数依赖顺序 = 波数依赖顺序 + 1
            else
                if wave >= wave依赖指令["kills"] and cost >= wave依赖指令["costs"] then
                    -- If 操作时间戳1 <> 波数依赖顺序 Then
                    --     操作前延时 = TickCount()
                    --     操作时间戳1 = 波数依赖顺序
                    -- End If


                    if wave依赖指令["type"] == "Skill" or wave依赖指令["type"] == "skill" or wave依赖指令["type"] == "技能" then
                        if wave依赖指令["location"] then
                            wave依赖指令 = 释放坐标技能(wave依赖指令["location"])
                        elseif 已部署干员[wave依赖指令["name"]] then
                            wave依赖指令 = 释放坐标技能(已部署干员[wave依赖指令["name"]])
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
                                部署操作(干员排位, wave依赖指令)
                                已部署干员[wave依赖指令["name"]] = wave依赖指令["location"]
                                已部署格子[行][列]["name"] = wave依赖指令["name"]
                                已部署格子[行][列]["times"] = 已部署格子[行][列]["times"] + 1
                                下排干员数量 = 下排干员数量 - 1
                                点战斗()
                                波数依赖顺序 = 波数依赖顺序 + 1
                            end
                        elseif table.search(群组, wave依赖指令["name"]) == true then
                            print(干员列表)
                            for i, v in ipairs(群组[wave依赖指令["name"]]) do
                                干员排位 = table.search(干员列表, v["name"])
                                print(v["name"], "群组内干员排位", 干员排位)
                                if 干员排位 > -1 then
                                    需要 = 费用列表(干员排位)
                                    部署操作(干员排位, wave依赖指令)
                                    已部署干员[v["name"]] = wave依赖指令["location"]
                                    已部署格子[行][列]["name"] = v["name"]
                                    已部署格子[行][列]["times"] = 已部署格子[行][列]["times"] + 1
                                    下排干员数量 = 下排干员数量 - 1
                                    点战斗()
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
                        撤退干员(wave依赖指令["location"])
                        点战斗()
                        波数依赖顺序 = 波数依赖顺序 + 1
                        wave依赖指令 = 波数依赖[波数依赖顺序]
                    end
                end
            end
        end
        do_strategy()

        差值 = 识别未部署干员数量()
        print("差值", 差值)
        if 差值 < 9 then
            releaseCapture()
            if findOne("保全调配干员") then
                print("抽卡")
                tap("保全抽卡")
                sleep(300)
                for i = 1, 9 - 差值 do
                    if findOne("保全调配干员") then
                        print("抽卡")
                        tap("保全抽卡")
                        sleep(300)
                    end
                end
                sleep(1100)
            end
        end

        数量变化 = 识别未部署干员数量() - 下排干员数量
        print("下排干员数量", 下排干员数量, "数量变化", 数量变化)

        if 数量变化 ~= 0 then
            更新未部署干员(数量变化)
            下排干员数量 = 识别未部署干员数量()
        end
        点战斗()
        sleep(75)
        if findOne("跳过剧情") then
            path.跳过剧情()
            print("跳过剧情")
            appear("作战中", 3)
            加速()
        end


        if not (findOne("作战中") or findOne("暂停中") or findOne("作战中2")) then
            sleep(500)
            if findAny({ "剧情中", "剧情中2", "剧情中3", "剧情中4", "生息演算剧情上", "生息演算剧情下" }) then
                tap("剧情中")
                --迷宫饭适配
                tap({ scale(1040), scale(384) })
                tap({ scale(1306), scale(608) })
                print("跳过无按钮剧情")
                appear("作战中", 2)
                加速()
            elseif findAny({ "作战中", "暂停中", "作战中2" }) then
            else
                --snapShot("/mnt/sdcard/test"..os.time()..".png")
                if appear("战斗中剧情对话", 3) then
                    wait(function()
                        tap("点cost")
                        ssleep(.3)
                        if findAny({ "作战中", "暂停中", "作战中2" }) then return true end
                    end, 30)
                else
                    print("结束抄作业")
                    break
                end
            end
        end
    end
end

部署干员 = function(干员排位)
    local 指令 = 部署[部署顺序]
    部署操作(干员排位, 指令)
    部署顺序 = 部署顺序 + 1
    if 部署顺序 <= #部署 then
        return 部署[部署顺序]
    end
end

部署操作 = function(干员排位, 指令)
    点战斗()
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
    deploy(坐标列表[干员排位][1], scale(地图坐标[1]), scale(地图坐标[2]), direction)

    table.remove(干员列表, 干员排位)
    table.remove(费用列表, 干员排位)
    if 是否保全图 == 1 and 职业列表[干员排位] == "辅助" then
        点战斗()
        sleep(500)
        点暂停()
        sleep(500)
    end
    if table.search(技能指定次数干员, 干员列表[干员排位]) then
        print("重置释放次数", 技能指定次数干员[干员列表[干员排位]])
        技能指定次数干员[干员列表[干员排位]][2] = 0
    end
    table.remove(职业列表, 干员排位)
    sleep(50)
end

识别未部署干员数量 = function()
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
end

识别未部署干员 = function()
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
            local 干员名字 = 战斗识别干员()
            if 干员名字 then
                干员[1] = 干员名字
            end
            if 干员数 >= (12 - 是否保全图) and (序号 == 4 or 序号 == 5) then
                -- 因为人太多点开之后会偏移漏掉,点回去
                tap({ 干员[3], 干员[4] })
                disappear(生命值蓝, 0.3)
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

更新未部署干员 = function(数量变化)
    if math.abs(数量变化) > 1 or 干员列表 == nil or #干员列表 ~= #职业列表 then
        干员列表 = 识别未部署干员()
        return
    end
    local 旧费用列表, 旧职业列表
    local 坐标, 识别结果, 更新
    local 更新列表
    旧职业列表 = shallowCopy(职业列表)
    旧费用列表 = shallowCopy(费用列表)
    更新列表 = 获取费用列表()
    print("更新未部署干员")
    print("费用列表", 费用列表)
    print("职业列表", 职业列表)

    if 数量变化 > 0 then
        print("干员增加", 数量变化)
        for _ = 1, 数量变化 do
            print("旧费用列表", 旧费用列表)
            print("旧职业列表", 旧职业列表)
            print("旧干员列表", 干员列表)

            for i = 1, #费用列表 do
                if 旧费用列表[i] ~= 费用列表[i] or 旧职业列表[i] ~= 职业列表[i] then
                    --if table.search(旧职业列表,职业列表[i]) then return 识别未部署干员() end
                    坐标 = 坐标列表[i]
                    tap({ 坐标[1], 坐标[2] })
                    sleep(400)
                    识别结果 = 战斗识别干员()
                    print("第", i, "位干员需要更新,是", 识别结果)
                    if table.search(干员列表, 识别结果) then
                        tap({ 坐标[1], 坐标[2] })
                        sleep(300)
                        干员列表 = 识别未部署干员()
                        print("更新后干员列表", 干员列表)
                        return
                    end
                    if 识别结果 then
                        table.insert(旧费用列表, i, 费用列表[i])
                        table.insert(旧职业列表, i, 职业列表[i])
                        table.insert(干员列表, i, 识别结果)
                        print("更新后干员列表", 干员列表)
                        -- end
                    else
                        table.insert(旧费用列表, i, 费用列表[i])
                        table.insert(旧职业列表, i, 职业列表[i])
                        更新 = 更新列表[i]
                        print("更新", 更新[1])
                        table.insert(干员列表, i, 更新[1])
                        print("更新后干员列表", 干员列表)
                    end
                    tap({ 坐标[1], 坐标[2] })
                    sleep(300)
                    break
                end
            end
        end
    elseif 数量变化 < 0 then
        print("干员减少", 数量变化)
        for _ = 1, math.abs(数量变化) do
            -- 旧费用列表 = clone(费用列表)
            -- 更新列表 = 获取费用列表()
            print(旧费用列表)
            print(旧职业列表)
            -- print(费用列表)
            print(干员列表)
            for i = #费用列表, 1, -1 do
                if 旧费用列表[i] ~= 费用列表[i] or 旧职业列表[i] ~= 职业列表[i] then
                    table.remove(干员列表, i)
                    table.remove(旧费用列表, i)
                    table.remove(旧职业列表, i)
                    print("干员列表", 干员列表)
                    break
                end
            end
        end
    end
end

移动相机 = function(delta)
    print("移动相机", delta[1], delta[2])

    local number = tonumber(string.match(获得敌人数(1), "%d+"))


    -- 还没转场的时候
    if number ~= 0 then
        wait_until_end(false)
    end

    wave = 0

    m_camera_shift[1] = m_camera_shift[1] + delta[1]
    m_camera_shift[2] = m_camera_shift[2] + delta[2]

    calc_tiles_info(m_stage_name, -m_camera_shift[1], m_camera_shift[2])
    return update_deployment(true)
end


获取费用列表 = function()
    local 干员数 = 0
    local 干员列表 = {}
    local BX = scale(1900)

    费用列表 = {}
    职业列表 = {}
    点暂停()

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
            BX = intX - 40
            干员数 = 干员数 + 1
            --print(intX)
            point["干员费用范围"] = { intX - scale(18), scale(906), intX + scale(25), scale(932) }
            --二值化("FFFFFF-404040|7E7E7E-202020")
            --不识别试试能不能降低性能消耗
            --local ret = ocrex("干员费用范围")
            local 干员cost = 999 --灰色识别不到
            --[[if ret ~= {} and #ret ~= 0 then
			干员cost = tonumber(ret[1].text) or 999
			end]]
            --print(干员cost)
            local 干员职业 = "未识别干员"
            if cmpColor(intX - scale(20), scale(896), "FFD800", 0.85) == 1 then -- 黄
                if cmpColor(intX - scale(27), scale(912), "292929", 0.9) == 1 then
                    干员职业 = "重装"
                elseif cmpColor(intX - scale(26), scale(907), "292929", 0.9) == 1 then
                    干员职业 = "先锋"
                else
                    干员职业 = "近卫"
                end
            elseif cmpColor(intX - scale(20), scale(896), "B11722", 0.85) == 1 then -- 红
                if cmpColor(intX - scale(52), scale(930), "292929", 0.9) == 1 then
                    干员职业 = "狙击"
                else
                    干员职业 = "术师"
                end
            elseif cmpColor(intX - scale(20), scale(896), "0098DC", 0.85) == 1 then -- 蓝
                if cmpColor(intX - scale(41), scale(930), "292929", 0.9) == 1 then
                    干员职业 = "医疗"
                else
                    干员职业 = "辅助"
                end
            elseif cmpColor(intX - scale(20), scale(896), "8FC31F", 0.85) == 1 then -- 绿
                干员职业 = "特种"
            elseif cmpColor(intX - scale(20), scale(896), "888888", 0.85) == 1 then -- 灰
                干员职业 = "召唤物"
            end
            --print(干员职业)
            干员列表[干员数] = { 干员职业, 干员cost, intX, scale(1026) }
            费用列表[干员数] = 干员cost
            职业列表[干员数] = 干员职业
        end
    end

    return 干员列表
end

获得敌人数 = function(a)
    local ret
    if use_local_dictionary then
        ret = TURING.图灵识别({ { 屏幕范围 = point["敌人数范围" .. a] }, { { 二值化 = { "41-166" } } }, { 范围投影 = { 1, 1 } }, { 六十四进制字库数组 = { 杀敌数字库(screen.height) } }, { 0 } })
    else
        ret = ocro("敌人数范围" .. a)
    end
    return ret
end

获得cost = function()
    local ret
    if use_local_dictionary then
        ret = TURING.图灵识别({ { 屏幕范围 = point["cost范围"] }, { { 二值化 = { "0-100" } } }, { 范围投影 = { 2, 1 } }, { 六十四进制字库数组 = { cost字库(screen.height) } }, { 0 } })
    else
        ret = ocro("cost范围")
    end
    return ret
end

战斗识别干员 = function()
    point["战斗中干员名字范围"] = { scale(20 - 12 * 是否保全图), scale(275 - 是否保全图 * 118), scale(318), scale(318 - 是否保全图 * 118) }
    local ret = ocrex("战斗中干员名字范围")
    if #ret == 1 then
        ret = 干员名ocr校正(ret)
        return ret[1]["text"]
    end
end

--[===[查找技能=function ()
local 技能表 = {}
local t

技能表 = Image.FindMultiColor(182, 167, 1080, 1740, "EBA22F-101010","-21|-21|F6A516-101010|5|-10|280500-101010|21|-21|E4932E-101010|-6|-8|2E1501-101010", 0, 0.9)
local 下标 = #技能表
print("找到", 下标, "就绪技能")
点战斗()
t = time()
for i = 1, 下标 do
技能表[i][1] = 技能表[i][1] - 155
技能表[i][2] = 技能表[i][2] - 20
tap(技能表[i][1], 技能表[i][2])
sleep(200)
技能表[i][3] = 战斗识别干员(1)
tap(560, 1828)
sleep(200)
print("干员" .. 技能表[i][3] .. "技能准备就绪,坐标:" .. 技能表[i][1], 技能表[i][2])
end

if findOne("战斗中") == true then
tap("作战中")
end
print("耗时" .. time() - t)
return 技能表
end]===]

释放技能 = function(干员)
    local 技能表 = {}
    local t
    ---还没改

    --[===[技能表 = Image.FindMultiColor(167,182, 1740,1080, "EBA22F-101010","-21|-21|F6A516-101010|5|-10|280500-101010|21|-21|E4932E-101010|-6|-8|2E1501-101010", 0, 0.9)
	local 下标 = #技能表
	print(下标 + 1 .. "个技能准备好了")
	if 下标 > -1 then
	点战斗()
	t = TickCount()
	for i = 1, 下标 do
	技能表[i][1] = 技能表[i][1] - 155
	技能表[i][2] = 技能表[i][2] - 20
	if i > 1 and math.abs(技能表[i][1] - 技能表[i - 1][1]) < 20 and math.abs(技能表[i][2] - 技能表[i - 1][2]) < 20 then
	-- Do nothing if the coordinates are too close to the previous skill
	else
	tap(技能表[i][1], 技能表[i][2])
	sleep(350)
	技能表[i][3] = 战斗识别干员()
	if 干员 == "all" then
	tap(465, 1271)
	sleep(100)
	tap(296, 1814)
	技能未就绪 = 0
	elseif 技能表[i][3] == 干员 then
	tap(465, 1271)
	sleep(100)
	tap(296, 1814)
	技能未就绪 = 0
	波数依赖顺序 = 波数依赖顺序 + 1
	break
	elseif 技能表[i][3] == "桃金娘" then
	tap(465, 1271)
	技能未就绪 = 0
	sleep(100)
	tap(296, 1814)
	break
	else
	tap(296, 1814)
	技能未就绪 = 技能未就绪 + 1
	if 技能未就绪 > 40 then
	技能未就绪 = 0
	波数依赖顺序 = 波数依赖顺序 + 1
	end
	sleep(100)
	end
	end
	sleep(50)
	end
	if 干员 == "all" then
	波数依赖顺序 = 波数依赖顺序 + 1
	end
	end]===]
    波数依赖顺序 = 波数依赖顺序 + 1
    if 波数依赖顺序 <= 波数依赖命令数 then
        return 波数依赖[波数依赖顺序]
    end
end

释放坐标技能 = function(坐标)
    local 地图坐标 = {}
    点战斗()

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
                sleep(100)
                tap("点cost")
                break
            elseif findOne("开技能") then
                sleep(30)
                tap("开技能")
                技能未就绪 = 0
                波数依赖顺序 = 波数依赖顺序 + 1
                sleep(100)
                tap("点cost")
                sleep(100)
                break
            else
                tap("点cost")
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
            local intX, intY = findMultiColor(scale(地图坐标[1] - 10), scale(地图坐标[2] - 180), scale(地图坐标[1] + 10),
                scale(地图坐标[2] - 80), "EBA22F-101010",
                scale(-21) ..
                "|" ..
                scale(-21) ..
                "|F6A516-101010|" ..
                scale(5) ..
                "|" ..
                scale(-10) ..
                "|280500-101010|" ..
                scale(21) .. "|" .. scale(-21) .. "|E4932E-101010|" .. scale(-6) .. "|" .. scale(-8) .. "|2E1501-101010",
                0, 0.87)
            print(intX, intY)
            if intX > -1 then
                tap({ scale(地图坐标[1]), scale(地图坐标[2]) })
                点暂停()
                appear("暂停中", 0.5)
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
                点战斗()
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

撤退干员 = function(坐标)
    print("撤退干员,格子坐标", 坐标[1], 坐标[2])
    local 地图坐标 = 地图数据0[坐标[2] + 1][坐标[1] + 1]
    点战斗()
    --if findOne("子弹时间", 0.85) then
    --    地图坐标 = 地图数据1[坐标[2] + 1][坐标[1] + 1]
    --end
    sleep(10)
    print(坐标[1], 坐标[2], "实际坐标", scale(地图坐标[1]), scale(地图坐标[2]))
    tap({ scale(地图坐标[1]), scale(地图坐标[2]) })
    点暂停()
    sleep(500)
    tap("点撤退")
    sleep(300)
    tap("点cost")
    sleep(150)
    releaseCapture()
    --点战斗()
end

点暂停 = function(a)
    if a then
        if not wait(function()
                if findOne("暂停中") then return true end
                tap("剧情中")
                ssleep(.1)
            end, 20) then
            return
        end
    else
        if findOne("作战中") then keyPress(4) end
    end
end

点战斗 = function()
    if findOne("暂停中") then keyPress(4) end
end

加速 = function(a)
    if a then
        if not wait(function()
                if findOne("暂停中") then return true end
                tap("剧情中")
                ssleep(.1)
            end, 20) then
            return
        end
    else
        if findOne("一倍速") then tap("两倍速") end
    end
end

进子弹时间 = function()
    if not findOne("子弹时间", 0.85) then tap("右下角干员") end
end

干员名ocr校正 = function(t)
    local 替换 = {
        ["森"] = "森蚺",
        ["铜"] = "锏",
        ["白面鸭"] = "白面鸮",
        ["3"] = "山",
        ["白面鸦"] = "白面鸮",
        ["白面鹗"] = "白面鸮",
        ["0"] = "山",
        ["E"] = "山",
        ["1"] = "山",
        ["T"] = "山",
        ["任"] = "山",
        ["灰"] = "灰烬",
        ["灰烟"] = "灰烬",
        ["委"] = "黍",
        ["默德克萨斯"] = "缄默德克萨斯",
        ["翎羽羽"] = "翎羽",
        ["纯烟艾雅法拉"] = "纯烬艾雅法拉",
        ["纯艾雅法拉"] = "纯烬艾雅法拉",
        ["林纯艾雅法拉"] = "纯烬艾雅法拉",
        ["哞"] = "吽",
        ["子"] = "孑",
        ["墨键"] = "黑键",
        ["巡巡林者"] = "巡林者",
        ["愧影"] = "傀影",
        ["狮蜴"] = "狮蝎",
        ["圣约送葬"] = "圣约送葬人",
        ["霸叶"] = "霜叶",
        ["灰亳"] = "灰毫",
        ["势"] = "芬",
        ["淫灭之相"] = "湮灭之相",
    }

    if t == nil or #t == 0 then return "" end
    for i = 1, #t do
        local 原文本 = (t[i]["text"])
        --print(原文本)
        if 替换[原文本] then
            t[i]["text"] = 替换[原文本]
        elseif 原文本:match("^白面.*$") then
            t[i]["text"] = "白面鸮"
        elseif 原文本:find("纯") and 原文本:find("艾雅法拉") then
            t[i]["text"] = "纯烬艾雅法拉"
        elseif 原文本:find("默") and 原文本:find("德克萨斯") then
            t[i]["text"] = "缄默德克萨斯"
        elseif 原文本:find("荒芜") and 原文本:find("拉普") then
            t[i]["text"] = "荒芜拉普兰德"
        end
        -- 去除开头的书名号
        t[i]["text"] = t[i]["text"]:gsub("^《", "")
        --开头和结尾的半角引号替换成全角
        t[i]["text"] = t[i]["text"]:gsub("^\"(.-)\"$", "“%1”")

        --print(t[i]["text"])
    end

    return t
end
