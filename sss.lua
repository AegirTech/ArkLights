-- sss.lua — MAA保全派驻协议(type=="SSS")支持
-- 协议文档: MAA docs/zh-cn/protocol/sss-schema.md (stages[].strategies 策略引擎 + draw_as_possible + DrawCard/CheckIfStartOver)
-- 已知限制(对齐MAA自身实现程度):
--   1. equipment(战术装备A/B变体)、drops(增调优先级选择)、buff按名匹配:MAA未实现或需新点位,这里降级为确认默认装备/放弃增调/默认元件序号
--   2. 作业stages[n].stage_name须与本地maps包文件名一致,否则loadMap报"地图数据读取失败"
--   3. actions条件字段仅支持kills/costs,cost_changes/cooling/elapsed_time出现时告警忽略

sss = {}

-- MAA职业名(中英文) → 项目卡片识别职业名(获取费用列表的cmpColor分类)
local ROLE_MAP = {
    Pioneer = "先锋", Warrior = "近卫", Tank = "重装", Sniper = "狙击",
    Caster = "术师", Medic = "医疗", Support = "辅助", Special = "特种",
    Drone = "召唤物",
    先锋 = "先锋", 近卫 = "近卫", 重装 = "重装", 狙击 = "狙击", 术师 = "术师",
    医疗 = "医疗", 辅助 = "辅助", 特种 = "特种", 装置 = "召唤物", 召唤物 = "召唤物",
}

-- MAA部署方向名 → 项目DIRECTION_MAP的键
local DIR_MAP = {
    Left = "Left", Right = "Right", Up = "Up", Down = "Down", None = "None",
    左 = "Left", 右 = "Right", 上 = "Up", 下 = "Down", 无 = "None",
}

-- action等待卡牌的超时保护(ms),超过后跳过该action防止整局卡死
local ACTION_WAIT_TIMEOUT = 120000

-- 格子坐标是否在地图数据范围内(部署用地图数据1,点击/技能用地图数据0)
local function 格子有效(location, 放置)
    local 数据 = 放置 and 地图数据1 or 地图数据0
    local 行 = 数据 and 数据[location[2] + 1]
    return 行 ~= nil and 行[location[1] + 1] ~= nil
end

-- 战斗中状态标志(prts.lua中为文件局部变量,此处自备一份)
local BATTLE_STATES = { "作战中", "暂停中", "作战中2", "顶部目标生命值" }

-- 校验并规范化作业(就地修改):职业/方向名中文化,补默认值,告警不支持的用法
local function 解析作业()
    processGroupsAndOperatorsSSS()
    local stages = 作业["stages"]
    if type(stages) ~= "table" or #stages == 0 then
        stop("SSS作业缺少stages字段", '', true, true)
    end
    if 作业["drops"] and #作业["drops"] > 0 then
        log.warn("SSS drops增调优先级暂不支持自动选择,战斗中遇到增调将放弃", JsonEncode(作业["drops"]))
    end
    for _, stage in ipairs(stages) do
        stage["draw_as_possible"] = stage["draw_as_possible"] == true
        stage["retry_times"] = stage["retry_times"] or 0
        for _, 指令 in ipairs(stage["actions"] or {}) do
            if 指令["cost_changes"] or 指令["cooling"] or 指令["elapsed_time"] then
                log.warn("SSS action条件字段cost_changes/cooling/elapsed_time不支持,忽略", 指令["type"])
            end
        end
        for _, 策略 in ipairs(stage["strategies"] or {}) do
            if not 策略["location"] then
                log.warn("SSS策略缺少location,禁用该策略")
                策略["all_deployed"] = true
            end
            local tool_men = {}
            for role, count in pairs(strategy["tool_men"] or {}) do
                local 项目职业 = ROLE_MAP[role]
                if 项目职业 then
                    tool_men[项目职业] = (tool_men[项目职业] or 0) + (tonumber(count) or 0)
                else
                    log.warn("SSS策略职业无法识别,忽略", role)
                end
            end
            策略["tool_men"] = tool_men
            策略["direction"] = DIR_MAP[strategy["direction"]] or "Right"
            策略["all_deployed"] = false
        end
    end
end

-- 策略工具人剩余总数
local function 工具人剩余数(策略)
    local 剩余 = 0
    for _, count in pairs(策略["tool_men"]) do
        剩余 = 剩余 + count
    end
    return 剩余
end

-- 在待部署区找策略所需职业、可部署、非核心/非行动干员的卡
-- 返回:排位,职业;第三返回值为true表示有匹配职业卡但费用没转好(MAA语义:本帧等待)
local function 找工具人卡(策略, 排除集合)
    local 上限 = math.min(#职业列表, #坐标列表, 干员列表 and #干员列表 or 0)
    local 有卡未就绪 = false
    for i = 1, 上限 do
        local 职业 = 职业列表[i]
        if 职业 and (策略["tool_men"][职业] or 0) > 0 then
            local 名字 = 干员列表[i]
            if not (名字 and 排除集合[名字]) then
                local 坐标 = 坐标列表[i]
                if 坐标 and canDeployOperator(坐标) then
                    return i, 职业
                end
                有卡未就绪 = true
            end
        end
    end
    return nil, nil, 有卡未就绪
end

-- 策略帧:对应MAA check_and_do_strategy,每帧最多部署一人,返回本帧是否有过部署
local function 执行策略帧(策略们, 排除集合, 已部署干员)
    local 阻塞格子 = {}
    for _, 策略 in ipairs(策略们) do
        local 格子键 = 策略["location"][1] .. "," .. 策略["location"][2]
        if not 策略["all_deployed"] and not 阻塞格子[格子键] then
            if 策略["core"] and 已部署干员[策略["core"]] then
                策略["all_deployed"] = true --核心已上过战场(含死亡),策略完成
            elseif not 格子有效(策略["location"], true) then
                log.warn("SSS策略location超出地图数据,禁用该策略", 策略["core"])
                策略["all_deployed"] = true
            else
                local 剩余 = 工具人剩余数(策略)
                if 剩余 == 0 and not 策略["core"] then
                    策略["all_deployed"] = true --无core且无工具人的空策略
                elseif 剩余 > 0 then
                    local 排位, 职业, 有卡未就绪 = 找工具人卡(策略, 排除集合)
                    if 排位 then
                        local 名字 = 干员列表[排位]
                        部署操作(排位, { location = 策略["location"], direction = 策略["direction"] })
                        策略["tool_men"][职业] = 策略["tool_men"][职业] - 1
                        if 名字 then
                            已部署干员[名字] = 策略["location"]
                            if not table.search(无限放技能干员, 名字) then
                                table.insert(无限放技能干员, 名字) --MAA工具人skill_usage=Possibly,好了就放
                            end
                        end
                        if not 策略["core"] and 工具人剩余数(策略) == 0 then
                            策略["all_deployed"] = true
                        end
                        return true
                    elseif 有卡未就绪 then
                        return false --有匹配职业但费用没转好,等待
                    end
                end
                if 策略["core"] then
                    if 剩余 == 0 then
                        local 核心排位 = table.search(干员列表 or {}, 策略["core"])
                        if 核心排位 and 坐标列表[核心排位] then
                            if canDeployOperator(坐标列表[核心排位]) then
                                部署操作(核心排位, { location = 策略["location"], direction = 策略["direction"] })
                                策略["all_deployed"] = true
                                已部署干员[策略["core"]] = 策略["location"]
                                return true
                            end
                            阻塞格子[格子键] = true
                            return false --核心在手但费用没转好,等待
                        end
                    end
                    阻塞格子[格子键] = true --核心未抽到或工具人未部署完,阻塞同格后续策略
                end
                --无core策略:放行,继续检查下一条
            end
        end
    end
    return false
end

-- 点一下"调配干员"按钮(MAA SSSDrawCard),按钮消失(牌抽完)返回false
local function 抽卡一次()
    if findOne("保全调配干员") then
        log("SSS抽卡")
        tap("保全抽卡")
        sleep(300)
        return true
    end
    return false
end

-- 放弃重开:暂停菜单 → 放弃行动 → 确认(同path.lua重开流程)
local function 放弃重开()
    log.warn("SSS放弃重开")
    tap("面板设置", true)
    if not wait(function()
            if findOne("放弃行动") then return true end
            tap("面板设置", true)
            sleep(300)
        end, 5) then
        log.warn("放弃重开:未找到放弃行动按钮")
        return
    end
    tap("放弃行动")
    sleep(300)
    tap("右确认")
    sleep(1000)
end

-- CheckIfStartOver(检查重开):干员不在待部署区/战场或职业数量不足时放弃重开
local function 检查重开(指令, 已部署干员)
    干员列表 = 识别未部署干员()
    识别未部署干员数量()
    点战斗()
    if 指令["name"] then
        if 已部署干员[指令["name"]] or table.search(干员列表 or {}, 指令["name"]) then
            return
        end
        log.warn("检查重开:干员不在待部署区或战场", 指令["name"])
        放弃重开()
    elseif 指令["tool_men"] then
        for role, count in pairs(指令["tool_men"]) do
            local 职业 = ROLE_MAP[role]
            local 实际 = 0
            if 职业 then
                for _, v in ipairs(职业列表 or {}) do
                    if v == 职业 then 实际 = 实际 + 1 end
                end
            end
            if 实际 < (tonumber(count) or 0) then
                log.warn("检查重开:职业数量不足", role, 实际, count)
                放弃重开()
                return
            end
        end
    end
end

-- 在待部署区找action要部署的卡(名字或群组成员)
local function 找部署卡(指令)
    local 排位 = table.search(干员列表 or {}, 指令["name"])
    if 排位 then return 排位 end
    local 群组干员 = 群组[指令["name"]]
    if 群组干员 then
        for _, v in ipairs(群组干员) do
            排位 = table.search(干员列表 or {}, v["name"])
            if 排位 then return 排位 end
        end
    end
end

-- 执行SSS作业的copilot action,返回false表示暂时无法执行(等待),其他表示已执行
local function 执行指令(指令, 已部署干员)
    local 类型 = 指令["type"]
    if 类型 == "Deploy" or 类型 == "deploy" or 类型 == "部署" then
        if not 指令["location"] or not 格子有效(指令["location"], true) then
            log.warn("Deploy指令location缺失或超出地图数据,跳过", 指令["name"])
            return true
        end
        local 排位 = 找部署卡(指令)
        if not 排位 then return false end
        if not (坐标列表[排位] and canDeployOperator(坐标列表[排位])) then return false end
        local 名字 = 干员列表[排位]
        部署操作(排位, 指令)
        if 名字 then 已部署干员[名字] = 指令["location"] end
        点战斗()
        return true
    elseif 类型 == "Retreat" or 类型 == "retreat" or 类型 == "撤退" then
        local 坐标 = 指令["location"] or 已部署干员[指令["name"]]
        if not 坐标 or not 格子有效(坐标) then
            log.warn("撤退指令无法确定有效位置", 指令["name"])
        else
            撤退干员(坐标)
            点战斗()
        end
        return true
    elseif 类型 == "Skill" or 类型 == "skill" or 类型 == "技能" then
        local 坐标 = 指令["location"] or 已部署干员[指令["name"]]
        if not 坐标 or not 格子有效(坐标) then
            log.warn("技能指令无法确定有效位置", 指令["name"])
        else
            释放坐标技能(坐标)
            点战斗()
        end
        return true
    elseif 类型 == "SpeedUp" or 类型 == "二倍速" then
        加速()
        return true
    elseif 类型 == "SkillUsage" or 类型 == "技能用法" then
        if 指令["skill_usage"] == 0 then
            table.removev(无限放技能干员, 指令["name"])
        else
            table.insert(无限放技能干员, 指令["name"])
        end
        return true
    elseif 类型 == "DrawCard" or 类型 == "drawcard" or 类型 == "调配干员" or 类型 == "抽卡" or 类型 == "抽牌" or 类型 == "调配" then
        抽卡一次()
        return true
    elseif 类型 == "CheckIfStartOver" or 类型 == "checkifstartover" or 类型 == "检查重开" then
        检查重开(指令, 已部署干员)
        return true
    elseif 类型 == "Click" or 类型 == "click" or 类型 == "CLICK" or 类型 == "点击" then
        执行点击指令(指令)
        return true
    elseif 类型 == "Swipe" or 类型 == "swipe" or 类型 == "SWIPE" or 类型 == "滑动" then
        执行滑动指令(指令)
        return true
    elseif 类型 == "Output" or 类型 == "打印" or 类型 == "BulletTime" or 类型 == "子弹时间" then
        return true
    elseif 类型 == "MoveCamera" or 类型 == "移动镜头" then
        log.warn("SSS作业MoveCamera暂不支持,跳过")
        return true
    else
        log.warn("SSS作业未知指令类型,跳过", 类型)
        return true
    end
end

-- 单层战斗主循环(stage为已规范化的作业stages[n])
sss.保全战斗 = function(stage)
    local actions = stage["actions"] or {}
    local strategies = stage["strategies"] or {}
    local 是否剿灭图 = (地图类型 == 2 or 地图类型 == 3) and 2 or 1
    local cost = 0
    local wave = 0
    local wavetxt
    local action下标 = 1
    local action等待起始 = time()
    local 已部署干员 = {}
    -- 行动干员集合:actions里Deploy用到的干员(含群组成员),策略引擎不得挪用
    local 排除集合 = {}
    for _, 策略 in ipairs(strategies) do
        if 策略["core"] then 排除集合[策略["core"]] = true end
    end
    for _, 指令 in ipairs(actions) do
        if 指令["type"] == "Deploy" or 指令["type"] == "deploy" or 指令["type"] == "部署" then
            if 指令["name"] then 排除集合[指令["name"]] = true end
            local 群组干员 = 群组[指令["name"]]
            if 群组干员 then
                for _, v in ipairs(群组干员) do 排除集合[v["name"]] = true end
            end
        end
    end
    -- 释放坐标技能会改写这些全局,初始化防止nil运算报错
    波数依赖 = {}
    波数依赖命令数 = 0
    波数依赖顺序 = 0
    技能未就绪 = 0

    local do_strategy = createDoStrategy(已部署干员, DELAYED_SKILLS, "技能名称范围", 0)
    local sleep_and_do_strategy = createSleepAndDoStrategy(do_strategy, false)

    点暂停(1)
    加速()
    干员列表 = 识别未部署干员()
    local 下排干员数量 = 识别未部署干员数量()

    while true do
        点战斗()
        cost = tonumber(获得cost(cost) or cost) or cost
        wavetxt = 获得敌人数(是否剿灭图) or 0
        local number = tonumber(string.match(wavetxt, "%d+")) or 0
        if number and number - wave < 5 then wave = number end
        log("SSS当前cost", cost, "已击败敌人数", wave)

        -- 卡片同步
        local 数量变化 = 识别未部署干员数量() - 下排干员数量
        if 数量变化 ~= 0 then
            更新未部署干员(数量变化)
            下排干员数量 = 识别未部署干员数量()
        end
        if 干员列表 == nil or #干员列表 ~= #职业列表 then
            干员列表 = 识别未部署干员()
            下排干员数量 = 识别未部署干员数量()
        end

        if findAny(STORY_DIALOGS) then
            tap("剧情中")
            log("跳过无按钮剧情")
            appear("作战中", 2)
            加速()
        end

        -- 当前action(顺序执行一次,条件不满足时策略引擎在后台继续跑)
        if action下标 <= #actions then
            local 指令 = actions[action下标]
            指令["kills"] = 指令["kills"] or 0
            指令["costs"] = 指令["costs"] or 0
            if wave >= 指令["kills"] and cost >= 指令["costs"] then
                if 指令["pre_delay"] then
                    log("SSS前置延时")
                    sleep_and_do_strategy(指令["pre_delay"])
                end
                local 执行结果 = 执行指令(指令, 已部署干员)
                if 执行结果 ~= false then
                    action下标 = action下标 + 1
                    action等待起始 = time()
                    local delay = 指令["post_delay"] or 指令["rear_delay"]
                    if delay then
                        sleep_and_do_strategy(delay)
                    end
                elseif time() - action等待起始 > ACTION_WAIT_TIMEOUT then
                    log.warn("SSS action等待超时,跳过", 指令["type"], 指令["name"])
                    action下标 = action下标 + 1
                    action等待起始 = time()
                end
            end
        end

        -- 策略引擎:每帧最多部署一人
        执行策略帧(strategies, 排除集合, 已部署干员)

        -- 战斗中增调弹窗(v1同层间行为:放弃,drops优先级暂不支持)
        if findOne("保全增调干员") then
            log("SSS战斗中增调,放弃")
            tap("保全增调干员")
            ssleep(.3)
            tap("保全放弃调用")
            ssleep(.3)
        end

        -- 自动抽卡
        if stage["draw_as_possible"] then
            抽卡一次()
        end

        do_strategy()

        点战斗()
        sleep(75)

        if findOne("跳过剧情") then
            path.跳过剧情()
            log("跳过剧情")
            appear("作战中", 3)
            加速()
        end
        sleep(450)

        if not findAny(BATTLE_STATES) then
            sleep(500)
            if findAny(STORY_DIALOGS) then
                tap("剧情中")
                tap({ scale(1040), scale(384) })
                tap({ scale(1306), scale(608) })
                log("跳过无按钮剧情")
                appear("作战中", 2)
                加速()
            elseif findAny(BATTLE_STATES) then
            else
                if appear("剧情中6", 3) then
                    wait(function()
                        tap("点cost")
                        ssleep(.3)
                        if findAny(BATTLE_STATES) then return true end
                    end, 30)
                else
                    log("SSS战斗结束")
                    break
                end
            end
        end
    end
end

-- MAA保全派驻协议入口(作业已由auto_sss加载到全局"作业"且type=="SSS")
sss.自动保全 = function(需要编队, 是否续打)
    log("MAA保全派驻协议流程开始")
    解析作业()

    if not 是否续打 then
        if not wait(function()
                if findOne("开始保全作战", 0.9) then
                    tap("开始保全作战")
                    sleep(10)
                end
                if findOne("选择导能元件") then return true end
            end, 5) then
            log.warn("进入保全失败")
            return
        end
        -- buff:数字为元件序号;MAA语义为元件名,按名匹配需OCR点位,暂用默认第3个
        local 导能元件序号 = tonumber(作业["buff"])
        if not 导能元件序号 then
            if 作业["buff"] then log.warn("SSS buff为元件名,按名选择暂不支持,使用默认第3个元件") end
            导能元件序号 = 3
        end
        tap("导能元件列表" .. 导能元件序号)
        if not appear("导能元件确认选择蓝", 2) then return false end
        sleep(100)
        tap("导能元件确认选择蓝")
        if not appear("选择战术装备", 3) then return false end
        sleep(100)
        -- equipment:对齐MAA行为(仅解析不消费),确认默认战术装备
        if 作业["equipment"] then log("SSS equipment按MAA行为忽略,确认默认战术装备") end
        tap("导能元件确认选择蓝")
        disappear("正在提交反馈至神经", network_timeout)
        sleep(100)

        if not appear("保全快捷编队", 3) then return false end
        if 需要编队 == true then
            if 保全自动编队(作业["opers"] or {}, 群组) == false then return false end
            releaseCapture()
        end

        if not appear("导能元件确认选择蓝", 3) then
            log("选人出现错误,没有选满")
            return false
        else
            tap("导能元件确认选择蓝")
            ssleep(4)
        end
        wait(function()
            tap("隐秘战线教程关闭")
        end, 2)
    end

    local 层尝试次数 = {}
    for _ = 1, 6 do
        local 当前层数 = tonumber(utf8.right(ocro("保全层数范围"), 1) or 1)
        local stage = 作业["stages"][当前层数]
        if not stage then
            stop("SSS作业stages缺少第" .. 当前层数 .. "层配置", '', true, true)
        end
        -- retry_times:每层尝试次数=retry_times+1,超过放弃整局(MAA "Can't win, run!")
        if (层尝试次数[当前层数] or 0) >= (stage["retry_times"] or 0) + 1 then
            log.warn("第" .. 当前层数 .. "层尝试次数已达上限,放弃整局")
            return false
        end
        层尝试次数[当前层数] = (层尝试次数[当前层数] or 0) + 1
        log("SSS当前层数" .. 当前层数, stage["stage_name"], "第" .. 层尝试次数[当前层数] .. "次尝试")
        local status, 地图数据 = pcall(loadMap, stage["stage_name"])
        if not status then
            stop("地图数据读取失败,请去测试功能内更新地图包", '', true, true)
        end
        地图数据0 = 地图数据[1] --放技能坐标
        地图数据1 = 地图数据[2] --放置干员坐标
        地图类型 = 地图数据[3] --1普通,2剿灭,3保全,4肉鸽,5悖论模拟
        训练地图 = 地图数据[4]

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
                log.warn("进入保全失败")
                return
            end
        end
        ssleep(.3)
        if appear("开始行动保全", 15) then
            if not wait(function()
                    tap("开始行动保全")
                    ssleep(.3)
                    if disappear("开始行动保全") then return true end
                end, 15) then
                log.warn("进入保全失败")
                return
            end
            handleCardChange(true)
        end
        sleep(1000)
        log("SSS抄作业")
        sss.保全战斗(stage)

        if not wait(function()
                tap("隐秘战线教程关闭")
                ssleep(2)
                if findOne("开始行动保全") then return true end
            end, 15) then
            --失败/放弃后可能停在结算确认画面,兜底点一次确认
            log("SSS层结算等待超时,尝试点击确认")
            tap("右确认")
            wait(function()
                tap("隐秘战线教程关闭")
                ssleep(2)
                if findOne("开始行动保全") then return true end
            end, 15)
        end
        ssleep(1)
    end
    log("SSS全部层数完成")
    return true
end
