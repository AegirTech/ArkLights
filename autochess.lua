-- ===========================================
--               卫戍协议
-- ===========================================

autochess = {}

-- 平时坐标(拖拽前/放技能视角)
-- map1[x][y]:x=列(0起,左到右),y=行(0起,上到下),来源 res/maps/act3autochess_m01.json
local map1 = {
    [0] = { [0] = { 434, 213 }, [1] = { 418, 285 }, [2] = { 401, 362 }, [3] = { 382, 444 }, [4] = { 362, 532 }, [5] = { 340, 627 }, [6] = { 317, 719 } },
    [1] = { [0] = { 530, 213 }, [1] = { 517, 285 }, [2] = { 502, 362 }, [3] = { 487, 444 }, [4] = { 471, 532 }, [5] = { 454, 627 }, [6] = { 435, 719 } },
    [2] = { [0] = { 625, 213 }, [1] = { 615, 285 }, [2] = { 604, 362 }, [3] = { 593, 444 }, [4] = { 580, 532 }, [5] = { 567, 627 }, [6] = { 553, 719 } },
    [3] = { [0] = { 721, 213 }, [1] = { 714, 285 }, [2] = { 706, 362 }, [3] = { 698, 444 }, [4] = { 690, 532 }, [5] = { 681, 627 }, [6] = { 671, 719 } },
    [4] = { [0] = { 816, 213 }, [1] = { 812, 285 }, [2] = { 808, 362 }, [3] = { 804, 444 }, [4] = { 799, 532 }, [5] = { 794, 627 }, [6] = { 789, 719 } },
    [5] = { [0] = { 911, 213 }, [1] = { 911, 285 }, [2] = { 910, 362 }, [3] = { 909, 444 }, [4] = { 908, 532 }, [5] = { 908, 627 }, [6] = { 907, 719 } },
    [6] = { [0] = { 1007, 213 }, [1] = { 1009, 285 }, [2] = { 1012, 362 }, [3] = { 1015, 444 }, [4] = { 1018, 532 }, [5] = { 1021, 627 }, [6] = { 1025, 719 } },
    [7] = { [0] = { 1102, 213 }, [1] = { 1108, 285 }, [2] = { 1114, 362 }, [3] = { 1120, 444 }, [4] = { 1127, 532 }, [5] = { 1135, 627 }, [6] = { 1143, 719 } },
    [8] = { [0] = { 1197, 213 }, [1] = { 1206, 285 }, [2] = { 1216, 362 }, [3] = { 1226, 444 }, [4] = { 1236, 532 }, [5] = { 1248, 627 }, [6] = { 1261, 719 } },
    [9] = { [0] = { 1293, 213 }, [1] = { 1305, 285 }, [2] = { 1317, 362 }, [3] = { 1331, 444 }, [4] = { 1346, 532 }, [5] = { 1361, 627 }, [6] = { 1378, 719 } },
    [10] = { [0] = { 1388, 213 }, [1] = { 1403, 285 }, [2] = { 1419, 362 }, [3] = { 1437, 444 }, [4] = { 1455, 532 }, [5] = { 1475, 627 }, [6] = { 1496, 719 } },
}

--拖拽后坐标(放置干员视角)
-- map2[x][y]:x=列(0起,左到右),y=行(0起,上到下),来源 res/maps/act3autochess_m01.json
local map2 = {
    [0] = { [0] = { 402, 264 }, [1] = { 380, 350 }, [2] = { 357, 445 }, [3] = { 332, 547 }, [4] = { 305, 658 }, [5] = { 275, 781 }, [6] = { 243, 906 } },
    [1] = { [0] = { 513, 264 }, [1] = { 496, 350 }, [2] = { 478, 445 }, [3] = { 459, 547 }, [4] = { 437, 658 }, [5] = { 414, 781 }, [6] = { 388, 906 } },
    [2] = { [0] = { 625, 264 }, [1] = { 612, 350 }, [2] = { 599, 445 }, [3] = { 585, 547 }, [4] = { 569, 658 }, [5] = { 552, 781 }, [6] = { 533, 906 } },
    [3] = { [0] = { 736, 264 }, [1] = { 728, 350 }, [2] = { 720, 445 }, [3] = { 711, 547 }, [4] = { 701, 658 }, [5] = { 690, 781 }, [6] = { 678, 906 } },
    [4] = { [0] = { 848, 264 }, [1] = { 844, 350 }, [2] = { 841, 445 }, [3] = { 837, 547 }, [4] = { 833, 658 }, [5] = { 828, 781 }, [6] = { 823, 906 } },
    [5] = { [0] = { 959, 264 }, [1] = { 960, 350 }, [2] = { 962, 445 }, [3] = { 963, 547 }, [4] = { 965, 658 }, [5] = { 966, 781 }, [6] = { 968, 906 } },
    [6] = { [0] = { 1071, 264 }, [1] = { 1076, 350 }, [2] = { 1083, 445 }, [3] = { 1089, 547 }, [4] = { 1096, 658 }, [5] = { 1104, 781 }, [6] = { 1113, 906 } },
    [7] = { [0] = { 1182, 264 }, [1] = { 1192, 350 }, [2] = { 1203, 445 }, [3] = { 1215, 547 }, [4] = { 1228, 658 }, [5] = { 1242, 781 }, [6] = { 1258, 906 } },
    [8] = { [0] = { 1294, 264 }, [1] = { 1308, 350 }, [2] = { 1324, 445 }, [3] = { 1341, 547 }, [4] = { 1360, 658 }, [5] = { 1381, 781 }, [6] = { 1403, 906 } },
    [9] = { [0] = { 1405, 264 }, [1] = { 1424, 350 }, [2] = { 1445, 445 }, [3] = { 1468, 547 }, [4] = { 1492, 658 }, [5] = { 1519, 781 }, [6] = { 1548, 906 } },
    [10] = { [0] = { 1517, 264 }, [1] = { 1540, 350 }, [2] = { 1566, 445 }, [3] = { 1594, 547 }, [4] = { 1624, 658 }, [5] = { 1657, 781 }, [6] = { 1693, 906 } },
}

--待部署区卡片卡位1~10:map1 格子[x,y],右到左
local 待部署区 = {
    [1] = { 9, 6 },
    [2] = { 8, 6 },
    [3] = { 7, 6 },
    [4] = { 6, 6 },
    [5] = { 5, 6 },
    [6] = { 4, 6 },
    [7] = { 3, 6 },
    [8] = { 2, 6 },
    [9] = { 1, 6 },
    [10] = { 0, 6 },
}
--装备区箱子卡位1~5:map1 格子[x,y],右到左
local 装备区 = { [1] = { 8, 5 }, [2] = { 7, 5 }, [3] = { 6, 5 }, [4] = { 5, 5 }, [5] = { 4, 5 }, }

--每个商店等级对应的卡位，固定是最左侧装备+剩余位置干员
local 商店卡片数量 = { 4, 5, 5, 5, 5, 6 }

--map 数据是 1080p 基线坐标,point 体系由 convert_coords 全表换算,map1/map2 需自行 scale
for _, m in ipairs({ map1, map2 }) do
    for _, col in pairs(m) do
        for y, p in pairs(col) do
            col[y] = { scale(p[1]), scale(p[2]) }
        end
    end
end

--待部署区/装备区存的是 map1 格子索引,解析成已换算的实际坐标
for _, t in ipairs({ 待部署区, 装备区 }) do
    for i, xy in ipairs(t) do
        t[i] = map1[xy[1]][xy[2]]
    end
end

--无ocr版随意放置格子
local 格子序号 = { { 4, 4 }, { 3, 3 }, { 3, 2 }, { 4, 2 }, { 3, 1 }, { 4, 3 }, { 3, 4 }, { 4, 1 }, { 4, 2 } }


-- ===== 极速模拟商店识别购买/部署 =====
-- 每回合识别卡栏布局(极速L1=4卡/L2-5=5卡/L6=6卡,卡位右起1-6,见 point.卫戍协议商店卡位列表):
-- 名称OCR查 autochess_data.json 的盟约、character_type_list.json 的职业,名字对不上时OCR盟约区兜底。
-- 优先级:核心盟约新名字尽量多买多部署(没部署位才落待部署区攒购买进度) > 重装最多2个 > 近卫补位;
-- 核心部署格按类型(近/远/医)三级选取:空位 > 顶替非核心 > 该类全是核心且新卡4级以上时,顶替3级及以下等级最低(同级星级低)的核心;
-- 精准盟约要买≥3个不同名字的干员:新名字优先部署,凑齐三人后同名副本也往场上部署(待部署区干员没有作用);
-- 近战职业(PIONEER/WARRIOR/TANK/SPECIAL)放近战格,医疗(MEDIC)放医疗格,其余放远程格,部署一律朝右。
-- 三个同名干员自动合成2星:2星自动落到场上最左上方部署的同名1星位置(其余同名1星撤下),场上没有同名1星时才落待部署区;
-- 合成后商店自动刷新一次出现"3选1"(卡位右起1-3,暂无标定素材,按readCard同逻辑识别名称),选evaluate最优的一个并部署。
-- 升本只到4本:确认生效但校验可能失效,靠"总共最多尝试3次=最多+3本"兜底;
-- 刷新费1,回合结束金币清零,每回合一直刷新直到刷新按钮变灰(买不起)把金币花光;或刷新后所有干员都不可买也提前收手。
local 近战格子 = { { 8, 1 }, { 8, 3 } }
local 远程格子 = { { 7, 2 }, { 7, 3 }, { 7, 1 }, { 6, 1 }, { 8, 2 } }
local 医疗格子 = { { 6, 2 } }
local coreBond = "精准"
local 近战职业 = { WARRIOR = true, TANK = true }
local 远程职业 = { SNIPER = true, CASTER = true, SUPPORT = true }
local 医疗职业 = { MEDIC = true }
local badgeList = { "FF9C1B", "8CE0CC" } --角标颜色:黄色,彩色
local badgeGold = "7C5201"               --价格徽章ring金色=可购买(实测(124,82,1),80帧抖动±3,不动画)
local badgeGray = "7F7E7B"               --价格徽章ring灰色=买不起(实测(127,126,123));
--卡边框金光是~0.5s闪烁动画(亮态黄白扫光,暗态露出底层边框),不能作可买依据
local borderSelected = "128E74"          --卡被选中待确认的边框色(18,142,116),再点一次才真正购买
local borderEmpty = "454545"             --空卡位灰板色(69,69,69),比无卡位的深色背景(约27,32,34)亮
local waitingZoneLimit = 8               --待部署区共10格,留2格余量

--多段文本拼接(盟约区可能分多行),单元素识别用 ocro 取第一段
local ocrText = function(pointKey)
    if not pointKey then return "" end
    local segments = {}
    for _, segment in ipairs(ocrex(pointKey) or {}) do
        segments[#segments + 1] = segment.text or ""
    end
    return (table.concat(segments):gsub("[%s　]+", ""))
end

local findNoBadgeTeam = function()
    local n = autochess_badeg_goal or 0
    local text = { "黄色", "彩色" }
    local x = 1114
    local y = 286
    local dx = 210
    local dy = 210
    for col = 0, 3 do
        for row = 0, 3 do
            local l = scale(x + row * dx)
            local t = scale(y + col * dy)
            local b = scale(y + col * dy + 55)
            local r = scale(x + row * dx + 55)

            if find_color({ l, t, r, b }, badgeList[2], 1, 0.9) then
                log("第", col + 1, "行第", row + 1, "列有", text[2], "角标")
            elseif n == 0 and find_color({ l, t, r, b }, badgeList[1], 1, 0.9) then
                log("第", col + 1, "行第", row + 1, "列有", text[1], "角标")
            else
                log("第", col + 1, "行第", row + 1, "列没有", text[n + 1], "角标")
                return math.abs((l + r) / 2), math.abs((t + b) / 2)
            end
        end
    end
    return nil, nil
end

-- 获取商店等级
local readLevel = function(beginLevel)
    beginLevel = beginLevel or 1
    for levelIndex = beginLevel, 6 do
        if appear("卫戍协议商店等级列表" .. levelIndex, 0.5) then
            return levelIndex
        end
    end
    return beginLevel
end

--卡位(右起1-6)边框比色:亮=可购买,灰=已购/买不起,都不是=空槽(现仅用于空槽灰板判定)
local slotColor = function(slotIndex, borderColor)
    local slotPoint = point["卫戍协议商店卡位列表" .. slotIndex]
    if not slotPoint then return false end
    return findOneStr(slotPoint[1] .. "|" .. slotPoint[2] .. "|" .. borderColor) ~= nil
end

--价格徽章比色(卡顶八边形价格框,见 point.卫戍协议商店徽章列表):金=可购买,灰=买不起。
--可买判定不用卡边框:已拥有卡的边框金光是~0.5s闪烁动画(亮态黄白扫光色与任何标定色调不符,暗态露出底层边框),
--单点单次比色对已拥有卡是掷硬币(2026-11-22 连拍实测),徽章颜色稳定无此问题
local badgeColor = function(slotIndex, color)
    local badgePoint = point["卫戍协议商店徽章列表" .. slotIndex]
    if not badgePoint then return false end
    return findOneStr(badgePoint[1] .. "|" .. badgePoint[2] .. "|" .. color) ~= nil
end

local slotBuyable = function(slotIndex)
    return badgeColor(slotIndex, badgeGold)
end

local slotHasCard = function(slotIndex)
    return slotBuyable(slotIndex) or badgeColor(slotIndex, badgeGray)
end

--卡位是否存在:有卡(价格徽章金/灰)或空槽灰板,都比"无卡位"的深色背景亮
local slotExists = function(slotIndex)
    return slotHasCard(slotIndex) or slotColor(slotIndex, borderEmpty)
end

local 卫戍协议干员ocr校正 = function(name)
    if not name or name == "" then return name end
    local nameFixes = {
        ["野鬘"] = "野鬃",
        ["灰亳"] = "灰毫",
        ["墨键"] = "黑键",
        ["愧影"] = "傀影",
        ["狮蜴"] = "狮蝎",
        ["霸叶"] = "霜叶",
        ["翎羽羽"] = "翎羽",
        ["哞"] = "吽",
        ["哗"] = "吽",
        ["子"] = "孑",
        ["委"] = "黍",
        ["铜"] = "锏",
        ["势"] = "芬",
        ["纯烟艾雅法拉"] = "纯烬艾雅法拉",
        ["纯艾雅法拉"] = "纯烬艾雅法拉",
        ["缄默德克萨斯"] = "缄默德克萨斯",
        ["圣约送葬"] = "圣约送葬人",
    }
    if nameFixes[name] then return nameFixes[name] end
    --开头两个汉字相同(OCR把首字重复了)则去掉第一个,如"琴琴柳"→"琴柳"
    if #name >= 9 and name:sub(1, 3) == name:sub(4, 6) and name ~= "苏苏洛" then
        return name:sub(4)
    end
    return name
end

--名字匹配干员 key:先全等,再包含匹配(OCR 常掉字)
local matchOperator = function(data, name)
    if name and data.operators[name] then return name end
    if name and #name >= 3 then --1个汉字=3字节
        for opKey in pairs(data.operators) do
            if #opKey >= 3 and (opKey:find(name, 1, true) or name:find(opKey, 1, true)) then
                return opKey
            end
        end
    end
end

--盟约区OCR对已知盟约名:池外干员(JSON里只有职业)和JSON读不到时的兜底识别
local ocrBonds = function(data, slotIndex)
    local bonds = {}
    local bondText = ocrText("卫戍协议商店盟约列表" .. slotIndex)
    for bondName in pairs(data.bonds) do
        if bondText:find(bondName, 1, true) then bonds[bondName] = true end
    end
    return bonds
end

--读卡(只识别不判断):名称必须读到(金光/动画可能让单次 OCR 为空,等一会重试);
--名字对上 JSON 直接拿盟约/职业(池外干员补OCR盟约),否则OCR盟约区;能否购买/分类/部署格等判断在 analyzeCard
local readCard = function(data, slotIndex)
    local card = {}
    local name = ""
    for _ = 1, 4 do
        name = 卫戍协议干员ocr校正(ocro("卫戍协议商店名称列表" .. slotIndex))
        if name ~= "" then break end
        ssleep(.5)
    end
    if name == "" then log.debug("识别:卡位" .. slotIndex .. "名称多次OCR为空") end
    card.name = name
    local opName = matchOperator(data, name)
    if opName then
        local info = data.operators[opName]
        card.name = opName
        card.level = info.level
        card.prof = info.prof
        card.bonds = info.bonds or ocrBonds(data, slotIndex)
    else
        card.bonds = ocrBonds(data, slotIndex)
    end
    return card
end

--职业→部署格:近战职业归近战格,医疗职业归医疗格,其余(远程职业/先锋/特种/池外未知)归远程格
local 格子KindOf = function(prof)
    if 近战职业[prof] then return '近战格子' end
    if 远程职业[prof] then return '远程格子' end
    if 医疗职业[prof] then return '医疗格子' end
    return '远程格子'
end

--卡片判断(readCard 只带识别结果,判断在这里补):能否购买(failedSlots 卡位直接跳过,不做名称OCR)、
--是否核心盟约、职业对应部署格;卡栏最后一位固定是装备(循环里不读),其余卡位都是干员,无需分类;
--skipBuyable=跳过边框比色(3选1的卡背景与商店不同,暂无标定素材,只按名称识别)
local analyzeCard = function(data, slotIndex, failedSlots, skipBuyable)
    if not skipBuyable and (failedSlots[slotIndex] or not slotBuyable(slotIndex)) then
        return { slot = slotIndex, buyable = false }
    end
    local card = readCard(data, slotIndex)
    card.slot = slotIndex
    card.buyable = true
    card.core = card.bonds[coreBond] == true
    card.格子Kind = 格子KindOf(card.prof)
    return card
end

--待部署区占用快照:1=该站位有干员等待部署;顺带记录实测色便于标定排查
local waitingZoneRecognize = function()
    for i = 10, 1, -1 do
        if findOne("卫戍协议待部署区存在干员列表" .. i, .88) then
            return i
        end
    end
    return 0
end

--待部署区逐格占用快照:记录1~10每格是否有干员。三合一会在中间腾出空位,新卡不一定落在占用末尾,
--所以定位新卡要按"哪一格从空变成有"来判,不能只看waitingZoneRecognize的末尾下标
local waitingZoneSlots = function()
    local slots = {}
    for i = 1, 10 do
        slots[i] = findOne("卫戍协议待部署区存在干员列表" .. i, .88) ~= nil
    end
    return slots
end

--新卡落位:与买卡/拿卡前的快照比,从1往10找第一个新出现的格位
--(三合一消失的干员腾出的空位,由新卡按"最靠前"补入)
local waitingZoneNewSlot = function(before)
    for i = 1, 10 do
        if not before[i] and findOne("卫戍协议待部署区存在干员列表" .. i, .88) then return i end
    end
end

--待部署区逐格登记:探针只能看出"有没有人",合成时要定位2星占哪一格,就得记下每张卡落在哪格。
--游戏规则:2星占三张同名1星里最靠前的格位,三选一补入的是合成腾出的另一个空位(按取卡前后快照差异找)
local waitingZonePut = function(state, slot, name, star)
    state.waitingZoneSlots[slot] = { name = name, star = star }
end

local waitingZoneDrop = function(state, slot)
    state.waitingZoneSlots[slot] = nil
end

--待部署区里同名指定星级的格位,按格位升序(最靠前的在前)
local waitingZoneSameSlots = function(state, name, star)
    local slots = {}
    for slot, v in pairs(state.waitingZoneSlots) do
        if v.name == name and v.star == star then slots[#slots + 1] = slot end
    end
    table.sort(slots)
    return slots
end

--state.已部署格子:按格子下标记录 {name=干员名, star=1/2, prof=职业} 或 false=空
--state.已部署格子Kinds:每格类别('近战格子'/'远程格子'/'医疗格子'),干员按职业进对应部署格,没有同类空格就不部署
local findFree格子 = function(state, wantKind)
    for 格子Index = 1, #state.已部署格子 do
        if not state.已部署格子[格子Index] and state.已部署格子Kinds[格子Index] == wantKind then return 格子Index end
    end
end

-- 同 kind 选部署格(按近/远/医分类):1.空位 2.没有空位则顶替非核心干员 3.该类全是核心且新卡4级以上,
-- 则顶替3级及以下里等级最低(同级取星级低)的核心
local findDeploy格子 = function(state, card)
    local wantKind = card.格子Kind
    local freeIndex = findFree格子(state, wantKind)
    if freeIndex then return freeIndex, false end
    for 格子Index = 1, #state.已部署格子 do
        local oper = state.已部署格子[格子Index]
        if oper and state.已部署格子Kinds[格子Index] == wantKind and oper.core ~= true then
            return 格子Index, true
        end
    end
    if (card.level or 0) >= 4 then
        local weakIndex
        for 格子Index = 1, #state.已部署格子 do
            local oper = state.已部署格子[格子Index]
            if oper and oper.core and oper.level and oper.level <= 3 and state.已部署格子Kinds[格子Index] == wantKind then
                local worst = weakIndex and state.已部署格子[weakIndex]
                if not worst
                    or oper.level < worst.level
                    or (oper.level == worst.level and oper.star < worst.star) then
                    weakIndex = 格子Index
                end
            end
        end
        if weakIndex then return weakIndex, true end
    end
end

--场上是否还有空部署格(近战/远程/医疗任一)
local anyFree格子 = function(state)
    for 格子Index = 1, #state.已部署格子 do
        if not state.已部署格子[格子Index] then return true end
    end
end

local fieldTanks = function(state)
    local tankCount = 0
    for _, oper in ipairs(state.已部署格子) do
        if oper and oper.prof == "TANK" then tankCount = tankCount + 1 end
    end
    return tankCount
end

--场上同名1星数量(合成计数用,2星不参与1星三合一)
local fieldSameCount = function(state, name)
    local sameCount = 0
    for _, oper in ipairs(state.已部署格子) do
        if oper and oper.star == 1 and oper.name == name then sameCount = sameCount + 1 end
    end
    return sameCount
end

--场上已部署的核心(精准)干员不同名集合与数量:精准盟约要买≥3个不同名字的干员,
--新名字优先部署;凑齐三人后同名副本也上场,没凑齐前同名副本只落待部署区(不占部署格)
local fieldCoreNames = function(state)
    local names, count = {}, 0
    for _, oper in ipairs(state.已部署格子) do
        if oper and oper.core and not names[oper.name] then
            names[oper.name] = true
            count = count + 1
        end
    end
    return names, count
end

--顶替放行判定:非核心一星,或3级及以下核心(4级以上新核心的顶替目标,见findDeploy格子)
local replaceable = function(oper)
    return oper ~= nil and (oper.core ~= true and oper.star == 1
        or oper.core == true and oper.level and oper.level <= 3)
end

--购买优先级:1=核心新名字部署 2=重装补位(场上≤2)/凑齐三人后同名核心补场 3=非核心补位(重装/近卫/医疗/远程等,
--优先把8个格子部署满) 4=核心新名字上架 5=同名核心上架(攒合成)
local evaluate = function(card, state, waitingZoneCount)
    local fielded, coreDistinct = fieldCoreNames(state)

    if card.core then
        local 格子Index, overwrite = findDeploy格子(state, card)
        local deployable = 格子Index ~= nil

        if not fielded[card.name] then
            if deployable then return 1, "deploy", 格子Index, overwrite end
            if waitingZoneCount < waitingZoneLimit then return 4, "waitingZone" end
            return
        end

        if coreDistinct >= 3 and deployable then return 2, "deploy", 格子Index, overwrite end
        if waitingZoneCount < waitingZoneLimit then return 5, "waitingZone" end
        return
    end

    if card.格子Kind then
        local 格子Index = findFree格子(state, card.格子Kind)
        if 格子Index and (card.prof ~= "TANK" or fieldTanks(state) < 2) then
            return 3, "deploy", 格子Index
        end
    end
end

--贪心规划:在占位快照上反复挑当前最优(priority 小者优先,同级取高档),直到没有可买
local buildPlan = function(cards, state)
    local sim格子 = {}
    for 格子Index = 1, #state.已部署格子 do sim格子[格子Index] = state.已部署格子[格子Index] end
    local sim = { 已部署格子 = sim格子, 已部署格子Kinds = state.已部署格子Kinds }
    local waitingZoneCount = waitingZoneRecognize()
    local candidates = {}
    for _, card in ipairs(cards) do
        if card.buyable then candidates[#candidates + 1] = card end
    end
    local plan = {}
    while #candidates > 0 do
        local best, bestIndex, bestPriority
        for candidateIndex, card in ipairs(candidates) do
            local priority, action, 格子Index, overwrite = evaluate(card, sim, waitingZoneCount)
            if priority and (not bestPriority or priority < bestPriority or (priority == bestPriority and (card.level or 0) > (best.card.level or 0))) then
                best, bestIndex, bestPriority =
                    { priority = priority, action = action, 格子Index = 格子Index, card = card, overwrite = overwrite, },
                    candidateIndex,
                    priority
            end
        end
        if not best then break end
        local bestCard = best.card
        if best.action == "deploy" then
            sim.已部署格子[best.格子Index] = {
                name = bestCard.name,
                star = 1,
                prof = bestCard.prof,
                core = bestCard.core,
                level = bestCard.level
            }
        else
            waitingZoneCount = waitingZoneCount + 1
        end
        plan[#plan + 1] = best
        table.remove(candidates, bestIndex)
    end
    return plan
end


--买卡:双击卡位购买(单击只是选中,隔久了再点会变成取消),买后卡位清空成灰板(NO INFO);
--购买成功判定:比对待部署区占用快照,新出现一格=已落位,返回落位格位(后续部署直接从这里拖);
--新卡补的是最靠前的空位(三合一可能留下中间空位,不一定在占用末尾);
--三合一时新卡被合成吃掉、没有新格,此时卡位已不是可购买状态也算买成,落位交给addAndMerge处理(成功时不返回landingGrid);
--卡位还是亮/金光=没买成(再双击),变灰=金币不足;待部署区始终没多出一格视为失败
local buyCard = function(card, state)
    local slotIndex = card.slot
    local slotPoint = point["卫戍协议商店卡位列表" .. slotIndex]
    local clickPos = { slotPoint[1] + scale(116), scale(930) }
    local beforeSlots = waitingZoneSlots()
    --这张买完就凑满三张同名1星?与addAndMerge合成条件同款算法
    local merging = state and (state.waitingZone1Star[card.name] or 0) + fieldSameCount(state, card.name) >= 2
    log("待部署区1星数量", state.waitingZone1Star[card.name], "场上数量", fieldSameCount(state, card.name), "判断", merging)
    if badgeColor(slotIndex, badgeGray) then
        log("购买转灰(金币不足):" .. card.name)
        return false
    end
    tap(clickPos)
    ssleep(.5)
    tap(clickPos)
    ssleep(1)

    local landingGrid = waitingZoneNewSlot(beforeSlots)
    if landingGrid then
        waitingZonePut(state, landingGrid, card.name, 1)
        log("购买:" .. card.name .. (card.core and "(核心)" or "") ..
            (card.prof and "[" .. card.prof .. "]" or "") .. " 落位格" .. landingGrid)
        return true, landingGrid
    elseif merging then
        log("购买:" .. card.name .. "(三合一,新卡被合成消耗)")
        return true
    else
        log("购买失败:" .. card.name)
        return false
    end
end

--单次拖拽并验证落位:待部署区该格位变空(拖走了)或剩余可放置数-1;都不可用只能信任
local deployBought = function(state, from, tile, direction)
    local direction = direction or "右"
    local from = from or waitingZoneRecognize()

    log("开始部署第", from, "个干员")
    swipe_slow(待部署区[from], tile)
    deploy0(tile, direction)
    ssleep(.4)
    if waitingZoneRecognize() == from - 1 then
        log.debug("部署成功")
    elseif findOne("卫戍协议待部署区存在干员列表" .. from) then --应该要写成开关的
        log.debug("尝试卖掉")
        swipe_slow(待部署区[from], point["卫戍协议右下角"])
        ssleep(.4)
    end
    waitingZoneDrop(state, from) --不管拖去部署还是卖掉,这格都空了
    return true                  --校验不可用只能信任
end

--买到的干员入待部署区并检查三合一;合成时场上最左上方部署的同名1星原地变2星、其余同名1星撤下,
--返回"field"=2星已自动落场无需拖拽 / "waitingZone"=场上没有同名1星,2星落待部署区需要拖部署 / nil=没合成
local addAndMerge = function(state, card)
    local name = card.name
    state.waitingZone1Star[name] = (state.waitingZone1Star[name] or 0) + 1
    local fieldSame = fieldSameCount(state, name)
    log("待部署区1星数量", state.waitingZone1Star[name], "场上数量", fieldSame)
    if state.waitingZone1Star[name] + fieldSame < 3 then return end
    --选位:最左上方部署的同名1星(Points={x,y},先比y取上排,同排再比x取最左)
    local firstGrid
    for 格子Index, oper in ipairs(state.已部署格子) do
        if oper and oper.star == 1 and oper.name == name then
            if not firstGrid then
                firstGrid = 格子Index
            else
                local pos, bestPos = state.已部署格子Points[格子Index], state.已部署格子Points[firstGrid]
                if pos[2] < bestPos[2] or (pos[2] == bestPos[2] and pos[1] < bestPos[1]) then firstGrid = 格子Index end
            end
        end
    end
    state.waitingZone1Star[name] = state.waitingZone1Star[name] - (3 - fieldSame)
    if state.waitingZone1Star[name] <= 0 then state.waitingZone1Star[name] = nil end
    --逐格登记同步:合成吃掉待部署区consumed张同名1星,最靠前的那格留给2星;
    --场上有同名1星时2星落场不占待部署区,待部署区被吃掉的格全部清掉
    local consumed = 3 - fieldSame
    local sameSlots = waitingZoneSameSlots(state, name, 1)
    if firstGrid then
        for k = 1, math.min(consumed, #sameSlots) do waitingZoneDrop(state, sameSlots[k]) end
        local keepRank = state.已部署格子[firstGrid].rank
        for 格子Index, oper in ipairs(state.已部署格子) do
            if oper and oper.star == 1 and oper.name == name and 格子Index ~= firstGrid then
                state.已部署格子[格子Index] = false
            end
        end
        state.已部署格子[firstGrid] = {
            name = name,
            star = 2,
            prof = card.prof,
            core = card.core,
            level = card.level,
            rank = keepRank
        }
        log("合成:" .. name .. "→2星(自动落场)")
        return "field"
    end
    if #sameSlots > 0 then
        waitingZonePut(state, sameSlots[1], name, 2)
        for k = 2, math.min(consumed, #sameSlots) do waitingZoneDrop(state, sameSlots[k]) end
    end
    state.waitingZone2Star[name] = (state.waitingZone2Star[name] or 0) + 1
    log("合成:" .. name .. "→2星(待部署区)")
    return "waitingZone"
end

--2星落在待部署区(场上没有同名1星时)才需要拖部署:部署到同类空格;没空格就留在待部署区等后续
local deployStar2 = function(state, card)
    local 格子Index = findFree格子(state, card.格子Kind)
    if not 格子Index then return end
    local tile = state.已部署格子Points[格子Index]
    ssleep(1) --等合成撤人动画
    --2星占的是同名1星里最靠前的那格(逐格登记),不能直接取占用末尾;登记格已空/没有登记时退回旧逻辑
    local from = waitingZoneSameSlots(state, card.name, 2)[1]
    if from and not findOne("卫戍协议待部署区存在干员列表" .. from, .88) then
        log("2星登记格" .. from .. "已空,退回占用末尾")
        from = nil
    end
    from = from or waitingZoneRecognize()
    if deployBought(state, from, tile) then
        local name = card.name
        state.rank = (state.rank or 0) + 1
        state.已部署格子[格子Index] = {
            name = name,
            star = 2,
            prof = card.prof,
            core = card.core,
            level = card.level,
            rank = state.rank
        }
        state.waitingZone2Star[name] = (state.waitingZone2Star[name] or 1) - 1
        if state.waitingZone2Star[name] <= 0 then state.waitingZone2Star[name] = nil end
        log("部署2星:" .. tostring(card.name))
    end
end

--2星合成后商店自动刷新一次出现"3选1":卡位右起1-3为可选干员(背景略不同,暂无标定素材,按readCard同逻辑读名称)。
--选evaluate最优的一个双击拿走(落待部署区),再走合成检查+部署;拿走的干员凑满三合一同样自动落场并会再出3选1
local choose = function(state, data)
    for _ = 1, 3 do
        ssleep(2) --等合成动画+自动刷新+3选1出现
        local options = {}
        for slotIndex = 1, 3 do
            options[slotIndex] = analyzeCard(data, slotIndex, {}, true) --3选1背景不同,跳过边框比色只按名称识别
        end
        log(options)
        local plan = buildPlan(options, state)
        local pick = plan[1] or { card = options[1] } --三个都不值得买时也随便选一个,别让3选1卡住商店
        local card = pick.card
        local slotPoint = point["卫戍协议商店卡位列表" .. card.slot]
        local clickPos = { slotPoint[1] + scale(116), scale(930) }
        local beforeSlots = waitingZoneSlots()
        tap(clickPos)
        ssleep(.5)
        tap(clickPos)
        ssleep(1)
        log("三选一:" .. tostring(card.name) .. (card.core and "(核心)" or ""))
        local merge = addAndMerge(state, card)
        --落位:三合一腾出的空位由最靠前的补上,不一定是占用末尾,按快照差异找新出现的格子;
        --合成时新卡被吃掉不会有新格,且merge分支用不到landingGrid,不用等
        local landingGrid
        if not merge then
            for _ = 1, 4 do
                landingGrid = waitingZoneNewSlot(beforeSlots)
                if landingGrid then break end
                ssleep(.5)
            end
            if landingGrid then waitingZonePut(state, landingGrid, card.name, 1) end
        end
        if merge == "waitingZone" then
            deployStar2(state, card)
        elseif merge == nil and pick.action == "deploy" and not state.deployBroken then
            local 格子Index = pick.格子Index
            local occupied = state.已部署格子[格子Index]
            if occupied and not (pick.overwrite and replaceable(occupied)) then
                格子Index = findFree格子(state, card.格子Kind) --3选1只放行顶替(非核心一星/弱核心),其余占位重找同类空格
            end
            if 格子Index then
                if deployBought(state, landingGrid, state.已部署格子Points[格子Index]) then
                    state.rank = (state.rank or 0) + 1
                    state.已部署格子[格子Index] = {
                        name = card.name,
                        star = 1,
                        prof = card.prof,
                        core = card.core,
                        level = card.level,
                        rank = state
                            .rank
                    }
                    state.waitingZone1Star[card.name] = (state.waitingZone1Star[card.name] or 1) - 1
                    if state.waitingZone1Star[card.name] <= 0 then state.waitingZone1Star[card.name] = nil end
                else
                    log("三选一部署失败:" .. tostring(card.name))
                    state.deployBroken = true
                end
            end
        end
        if not merge then break end --拿走的干员没触发合成,不会再出3选1
    end
end

--执行规划:返回 "progress" 有购买 / "none" 没买成 / "changed" 卡栏异常需重识别
local execute = function(plan, state, data, failedSlots)
    local bought = false
    log("plan:", plan)
    for _, pick in ipairs(plan) do
        local card = pick.card
        local ok, landingGrid = buyCard(card, state)
        if ok then
            bought = true
            local name = card.name
            local merge = addAndMerge(state, card)
            if merge then
                --2星合成:场上没有同名1星时2星落待部署区需要拖部署;商店随后自动刷新一次出现3选1,
                --剩余计划的卡位已被刷新作废,处理完3选1就返回让外层重新扫描
                if merge == "waitingZone" then
                    deployStar2(state, card)
                end
                choose(state, data)
                return "progress"
            elseif pick.action == "deploy" and not state.deployBroken then
                local 格子Index = pick.格子Index
                local occupied = state.已部署格子[格子Index]

                if occupied then
                    if pick.overwrite and replaceable(occupied) then
                        -- 顶替非核心一星/弱核心(3级及以下)：允许直接覆盖，被顶掉的单位去向见下面说明
                        local old = occupied
                        -- 例如退回待部署区：
                        -- state.waitingZone1Star[old.name] = (state.waitingZone1Star[old.name] or 0) + 1
                    else
                        -- 核心/2星占位，或合成导致的占位：重找同类空格
                        格子Index = findFree格子(state, card.格子Kind)
                    end
                end

                if 格子Index then
                    if deployBought(state, landingGrid, state.已部署格子Points[格子Index]) then
                        state.rank = (state.rank or 0) + 1
                        state.已部署格子[格子Index] = {
                            name = name,
                            star = 1,
                            prof = card.prof,
                            core = card.core,
                            level = card.level,
                            rank = state.rank,
                        }
                        state.waitingZone1Star[name] = (state.waitingZone1Star[name] or 1) - 1
                        if state.waitingZone1Star[name] <= 0 then state.waitingZone1Star[name] = nil end
                    else
                        log("部署失败:" .. tostring(card.name))
                        state.deployBroken = true
                    end
                end
            end
        else
            failedSlots[card.slot] = true
        end
    end
    return bought and "progress" or "none"
end

-- 升级商店
local upgradeShop = function(currentLevel)
    tap("卫戍协议商店等级列表" .. currentLevel)
    ssleep(.5)
    tap("卫戍协议商店等级列表" .. currentLevel)
    ssleep(.5)
    return currentLevel + 1
end

--卡位状态签名(徽章金/徽章灰/空槽/背景),用于判定刷新是否生效(徽章颜色稳定,无金光闪烁噪声)
local makeSignature = function(cardCount)
    local sigParts = {}
    for slotIndex = 1, cardCount - 1 do
        sigParts[slotIndex] = slotBuyable(slotIndex) and "1" or
            (badgeColor(slotIndex, badgeGray) and "2" or (slotColor(slotIndex, borderEmpty) and "3" or "0"))
    end
    return table.concat(sigParts)
end

--刷新商店(费1):一直点刷新,直到刷新按钮变灰(买不起)为止,不做硬次数限制;
--刷没刷动仍用"卡位签名或首个亮槽卡名变化"判定(全亮商店签名可能巧合相同,以卡名为准);
--刷新生效后若所有干员卡位都不可买(刷不出买得起的卡),按钮没灰也返回false收手;
--刷不动且按钮没变灰(比色失效兜底)时两者都不变,返回false收手
local refresh = function(state, cardCount, cards)
    local prevSig = makeSignature(cardCount)
    local checkSlot, oldName
    for _, card in ipairs(cards) do
        if card.buyable and card.name and card.name ~= "" then
            checkSlot, oldName = card.slot, card.name
            break
        end
    end
    for _ = 1, 2 do
        tap("卫戍协议刷新按钮")
        state.refreshCount = state.refreshCount + 1
        ssleep(.8)
        if findOne("卫戍协议刷新按钮灰") then
            log("刷新按钮已灰,停止刷新(本回合共" .. state.refreshCount .. "次)")
            return false
        end
        local newSig = makeSignature(cardCount)
        if newSig ~= prevSig or (checkSlot and ocro("卫戍协议商店名称列表" .. checkSlot) ~= oldName) then
            log("刷新第" .. state.refreshCount .. "次")
            for slotIndex = 1, cardCount - 1 do --最后一位固定是装备,只看干员卡位
                if slotBuyable(slotIndex) then return true end
            end
            log("刷新后所有干员都不可买,停止刷新(本回合共" .. state.refreshCount .. "次)")
            return false
        end
    end
    log("刷新无效(按钮未灰但卡栏没变)")
    return false
end

--模拟一轮商店:升本到 4 本→按优先级买/部署→刷新循环,刷新按钮变灰(金币花光)就收手
autochess.商店购买 = function(state, data, round)
    log(state)
    state.level = readLevel(state.level) or state.level
    local cardCount = 商店卡片数量[state.level]
    log.debug("商店等级: ", state.level, "卡片数量", cardCount)
    if round == 1 then --后续要写成判断金额再升级更加智能一些
        upgradeShop(1)
        state.level = upgradeShop(2)
    elseif round == 2 then
        state.level = upgradeShop(3)
        -- elseif round == 4 then
        --     state.level = upgradeShop(4)
    end

    if not anyFree格子(state) and waitingZoneRecognize() >= waitingZoneLimit then
        log("商店已满载,跳过购买")
        return
    end

    local failedSlots = {}
    for _ = 1, 25 do
        ssleep(.3)
        local cards = {}
        for slotIndex = 1, cardCount - 1 do --最后一位固定是装备,其余都是干员
            cards[slotIndex] = analyzeCard(data, slotIndex, failedSlots)
        end
        log("cards:", cards)
        local _, coreCount = fieldCoreNames(state)
        log.debug("场上精准不同名:" .. coreCount .. "/3")
        local result = "none"
        local plan = buildPlan(cards, state)
        if #plan > 0 then
            result = execute(plan, state, data, failedSlots)
            if result == "changed" then failedSlots = {} end
        end
        if result == "none" then
            if refresh(state, cardCount, cards) then
                failedSlots = {}
            else
                log("商店收手:本回合刷新" .. state.refreshCount .. "次")
                return
            end
        end
    end
    log("商店动作步数用尽")
end

autochess.卫戍协议进入 = function()
    path.跳转("首页")
    ssleep(.2)
    tap("面板作战")
    if not appear("主页") then return false end
    if not wait(function()
            if findOne("终端卫戍协议选中") then return true end
            tap("终端卫戍协议入口")
        end, 5) then
        return false
    end
    if not wait(function()
            if findOne("卫戍协议首页") then return true end
            tap("终端卫戍协议进入")
            ssleep(.2)
        end, 25) then
        return false
    end
    log("卫戍协议进入成功")
    --ssleep(1)
    if appear("阿米娅", 1) then
        if not autochess.卫戍协议教程() then
            return false
        end
        autochess.自动借人()
    end
end

autochess.卫戍协议教程 = function()
    log("卫戍协议教程")
    if not wait(function()
            if findOne("卫戍协议选配助战") or findOne("卫戍协议借助战") then return true end
            if findOne("卫戍协议准备就绪") then
                tap("卫戍协议战斗准备就绪")
                ssleep(.3)
                if findOne("卫戍协议金币清零确定") then
                    tap("卫戍协议金币清零勾")
                    ssleep(.1)
                    tap("卫戍协议金币清零确定")
                end
            end
            if findOne("卫戍协议教程放人黄点") then
                log("发现教程放人黄点")
                -- 放第一个人
                swipe_slow(待部署区[1], map2[4][3])
                deploy0(map2[4][3], "上")
                -- 放第二个人
                swipe_slow(待部署区[1], map2[3][3])
                deploy0(map2[3][3], "右")
            end
            if findOne("卫戍协议教程放装备黄点") then
                log("发现教程放装备黄点")
                swipe_slow(装备区[1], map2[4][3])
            end
            tap("卫戍协议右下角")
            ssleep(.1)
            tap("卫戍协议物资调配处")
            ssleep(.1)
            tap("卫戍协议准备就绪")
            ssleep(.1)
            tap("卫戍协议物资调配处第一个干员")
            ssleep(.1)
            tap("卫戍协议物资调配处道具")
            ssleep(.1)
            for i = 1, #point.卫戍协议教程列表 do
                tap("卫戍协议教程列表" .. i)
                ssleep(.1)
            end
            tap("卫戍协议战斗准备就绪")
            ssleep(.1)
            tap("卫戍协议战斗准备就绪")
            ssleep(.1)
            tap("卫戍协议战斗准备就绪")
            ssleep(.1)
            tap("卫戍协议战斗准备就绪")
            ssleep(.1)
        end, 60 * 18, 1) then --教程大概10分钟
        log("尝试过教程失败，卡住超过了10s，准备重启游戏")
        exec('su root am force-stop  ' .. appid)
        return false
    end
    return true
end

autochess.借人 = function()
    local res = findOne("卫戍协议去借用")
    log.debug("去借用识别结果", res)
    while findOne("卫戍协议去借用") do
        local res = findOne("卫戍协议去借用")
        log.debug("去借用识别结果", res)
        wait(function()
            tap(res)
            log.info("点击去借用")
            appear("卫戍协议借人更新", 2)
            ssleep(3)
            disappear("正在提交反馈至神经", network_timeout)
            if findOne("卫戍协议借人空") then
                back()
            else
                tap("卫戍协议借人空")
                ssleep(3)
                disappear("正在提交反馈至神经", network_timeout)
                return true
            end
        end, 30, .5)
    end
    return true
end

autochess.自动借人 = function()
    if not findOne("卫戍协议首页") then
        autochess.卫戍协议进入()
    end
    if not appear("卫戍协议首页", 5) then return end
    ssleep(.2)
    tap("卫戍协议物资调配处")
    disappear("卫戍协议首页", 3)
    appear("卫戍协议选配助战", 3)
    ssleep(.2)
    tap("卫戍协议选配助战")
    disappear("卫戍协议选配助战", 3)
    ssleep(.2)
    for i = 1, 10 do
        autochess.借人()
        swipe_slow(point["卫戍协议借人翻页起点"], point["卫戍协议借人翻页终点"], 0.5)
    end
end

autochess.卫戍协议放弃 = function()
    appear("卫戍协议放弃模拟", 60)
    ssleep(.5)
    tap("卫戍协议放弃模拟")
    ssleep(.5)
    tap("卫戍协议金币清零确定")
    if not wait(function()
            tap("卫戍协议准备就绪")
            ssleep(2)
            disappear("正在提交反馈至神经", network_timeout)
            if findOne("卫戍协议首页") then
                log("卫戍协议一轮循环结束")
                return true
            end
        end, 30, 1) then
        log("可能是卡住了,点一下返回首页")
        tap("卫戍协议准备就绪")
    end
end

autochess.卫戍协议奖励 = function()
    if not findOne("卫戍协议首页") then
        autochess.卫戍协议进入()
    end
    if not appear("卫戍协议首页", 5) then return end
    ssleep(.2)
    if findOne("卫戍协议关键目标红点") then
        tap("卫戍协议关键目标")
        appear("卫戍协议奖励一键领取", 2)
        tap("卫戍协议奖励一键领取")
        appear("获得物资", 5)
        ssleep(.1)
        tap("卫戍协议奖励一键领取")
        log("卫戍协议奖励已领取")
    else
        return
    end
end

autochess.卫戍协议循环 = function()
    log("卫戍协议循环")

    if not findOne("卫戍协议首页") then
        autochess.卫戍协议进入()
    end
    if not appear("卫戍协议首页", 5) then return end
    if findOne("卫戍协议放弃模拟") then
        return autochess.卫戍协议放弃()
    end
    if findOne("卫戍协议等级max") then
        log("卫戍协议等级已满")
        captureqqimagedeliver("INFO", "卫戍协议等级已满", "卫戍协议等级已满")
        return true
    end
    if not wait(function()
            if findOne("卫戍协议个人模拟") then return true end
            tap("卫戍协议个人模拟")
            ssleep(.1)
        end, 2) then
        return false
    end

    tap("卫戍协议极速模拟")
    disappear("卫戍协议首页", 3)
    appear("卫戍协议开始模拟", 3)
    ssleep(.2)
    tap("卫戍协议开始模拟")

    if not wait(function()
            if findOne("卫戍协议选择分队") then return true end
            tap("卫戍协议准备就绪")
        end, 10, 1) then
    end
    ssleep(.5)
    tap("卫戍协议选择血最多分队")
    ssleep(2)
    wait(function()
        tap("卫戍协议准备就绪")
    end, 5, 1)
    ssleep(10)
    appear("卫戍协议战斗准备就绪", 40)
    log("卫戍协议进入第一回合战斗")

    for i = 1, 8 do
        if appear("卫戍协议战斗准备就绪", 65) then
            ssleep(.1)
            log("第" .. i .. "回合")
            if i == 1 or i == 2 or i == 3 then
                local 方向 = { "上", "右", "右", "上", "右", "上", "右", "右", "上" }
                for j = 1, 3 do
                    local n = j + i * 3 - 3
                    local 格子 = map2[格子序号[n][1]][格子序号[n][2]]
                    tap("卫戍协议购买列表" .. j)
                    ssleep(.2)
                    tap("卫戍协议购买列表" .. j)
                    ssleep(.8)
                    swipe_slow(待部署区[1], 格子)
                    deploy0(格子, 方向[n])
                    ssleep(.2)
                end
            end
            tap("卫戍协议战斗准备就绪")
            ssleep(.5)
            if appear("卫戍协议金币清零确定") then
                tap("卫戍协议金币清零勾")
                ssleep(.1)
                tap("卫戍协议金币清零确定")
            end
            ssleep(15)
        end
        if findOne("卫戍协议返回主页") then
            log("卫戍协议战斗失败")
            ssleep(.2)
            tap("卫戍协议返回主页")
            return true
        end
    end
    appear("卫戍协议战斗准备就绪", 60)
    tap("卫戍协议战斗返回")
    ssleep(.5)
    tap("卫戍协议金币清零确定")
    ssleep(8)
    autochess.卫戍协议放弃()
end

autochess.卫戍协议通关循环 = function()
    log("卫戍协议尝试通关循环")

    --购买识别数据:盟约/干员/装备(autochess_data.json),职业(character_type_list.json)并入干员信息,
    --TRAP/TOKEN是装置召唤物丢弃,池外真干员只留职业;读不到时退化成纯OCR盟约识别
    --(声明需在goto之前,否则goto relink会跳进局部变量作用域)
    local data = { operators = {}, items = {}, bonds = {} }
    local readOk, readRet = pcall(JsonDecode, readFile("autochess_data.json"))
    if readOk and readRet then
        data.operators = readRet.operators or {}
        data.items = readRet.items or {}
        for _, v in pairs(data.operators) do
            for bondName in pairs(v.bonds or {}) do data.bonds[bondName] = true end
        end
    end
    readOk, readRet = pcall(JsonDecode, readFile("character_type_list.json"))
    if readOk and readRet then
        for opName, prof in pairs(readRet) do
            if prof ~= "TRAP" and prof ~= "TOKEN" then
                local info = data.operators[opName]
                if info then
                    info.prof = prof
                else
                    data.operators[opName] = { prof = prof }
                end
            end
        end
    end

    local state = { -- state:回合内共享状态
        level = 1, -- 商店等级
        refreshCount = 0, -- 刷新次数
        rank = 0, -- 部署次序
        已部署格子 = {}, -- 已经部署的格子站位
        已部署格子Points = {}, -- 各格坐标
        已部署格子Kinds = {}, -- 各格坐标与类别(近/远/医)
        waitingZone1Star = {}, -- 待部署区1星
        waitingZone2Star = {}, -- 待部署区2星
        waitingZoneSlots = {} -- 待部署区逐格: [格位]={name,star},定位合成后2星的位置
    }
    local init格子 = function(points, kind)
        for _, point in ipairs(points) do
            state.已部署格子Points[#state.已部署格子Points + 1] = map2[point[1]][point[2]]
            state.已部署格子Kinds[#state.已部署格子Kinds + 1] = kind
            state.已部署格子[#state.已部署格子 + 1] = false
        end
    end
    init格子(近战格子, '近战格子')
    init格子(远程格子, '远程格子')
    init格子(医疗格子, '医疗格子')

    if not findOne("卫戍协议首页") then
        autochess.卫戍协议进入()
    end
    if not appear("卫戍协议首页", 5) then return end
    if findOne("卫戍协议放弃模拟") then
        return autochess.卫戍协议放弃()
    end
    if findOne("卫戍协议等级max") then
        log("卫戍协议等级已满")
        captureqqimagedeliver("INFO", "卫戍协议等级已满", "卫戍协议等级已满")
        return true
    end
    if not wait(function()
            if findOne("卫戍协议个人模拟") then return true end
            tap("卫戍协议个人模拟")
            ssleep(.1)
        end, 2) then
        return false
    end

    tap("卫戍协议极速模拟")
    disappear("卫戍协议首页", 3)
    appear("卫戍协议开始模拟", 3)
    ssleep(.2)
    tap("卫戍协议开始模拟")
    appear("卫戍协议准备就绪", 10)
    ssleep(.2)
    tap("卫戍协议准备就绪")
    disappear("卫戍协议准备就绪", 3)
    appear("卫戍协议选择分队", 10)
    ssleep(.4)
    log("寻找没有角标的分队")
    local team_x, team_y = findNoBadgeTeam()
    if not team_x then
        log("第一页没有找到没有角标的分队")
        tap("卫戍协议分队滚动条中间")
        ssleep(.5)
        team_x, team_y = findNoBadgeTeam()
        if not team_x then
            log("第二页没有找到没有角标的分队")
            tap("卫戍协议分队滚动条下面")
            ssleep(.5)
            team_x, team_y = findNoBadgeTeam()
            if not team_x then
                log("第三页没有找到没有角标的分队")
            end
        end
    end

    if team_x and team_y then
        tap({ team_x, team_y })
    else
        tap("卫戍协议选择血最多分队")
    end
    ssleep(2)
    wait(function()
        tap("卫戍协议准备就绪")
    end, 5, .8)
    ssleep(10)
    appear("卫戍协议战斗准备就绪", 40)
    log("卫戍协议进入第一回合战斗")

    for roundNo = 1, 9 do
        if appear("卫戍协议战斗准备就绪", 65) then
            ssleep(.1)
            log("第" .. roundNo .. "回合")
            state.refreshCount = 0

            ssleep(1) --等卡栏展开动画
            local shopOk, shopErr = pcall(autochess.商店购买, state, data, roundNo)
            if not shopOk then
                log("商店购买异常:" .. tostring(shopErr))
            end

            wait(function()
                tap("卫戍协议战斗准备就绪")
                ssleep(.5)
                if appear("卫戍协议金币清零确定") then
                    tap("卫戍协议金币清零勾")
                    ssleep(.1)
                    tap("卫戍协议金币清零确定")
                end
            end, 4, 0.3)
            ssleep(15)
        end
        if findOne("卫戍协议返回主页") then
            ssleep(.2)
            tap("卫戍协议结算返回主页")
            ssleep(1)
            return true
        end
    end

    if wait(function()
            if findOne("卫戍协议结算返回主页") then
                ssleep(.2)
                tap("卫戍协议结算返回主页")
                ssleep(.5)
            end
            if findOne("卫戍协议首页") then return true end
        end, 120, 1) then
        return true
    end
    log("未等到通关结算页,按中途退出处理")
    tap("卫戍协议战斗返回")
    ssleep(.5)
    tap("卫戍协议金币清零确定")
    ssleep(8)
    return autochess.卫戍协议放弃()
end
