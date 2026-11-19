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

--格子列表1~9 对应的 map2 格子[x,y](第一回合1~3,第二回合4~6,第三回合7~9)
local 格子序号 = { { 4, 4 }, { 3, 3 }, { 3, 2 }, { 4, 2 }, { 3, 1 }, { 4, 3 }, { 3, 4 }, { 4, 1 }, { 4, 2 } }

local 近战格子 = { { 8, 1 }, { 8, 3 } }
local 远程格子 = { { 7, 2 }, { 7, 3 }, { 7, 1 }, { 6, 1 }, { 8, 2 } }
local 医疗格子 = { { 6, 2 } }

local coreBond = "精准"

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

autochess.卫戍协议循环 = function()
    log("卫戍协议循环")
    local lose = false

    if not findOne("卫戍协议首页") then
        autochess.卫戍协议进入()
    end
    if not appear("卫戍协议首页", 5) then return end
    if findOne("卫戍协议放弃模拟") then
        goto relink
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
            lose = true
            break
        end
    end
    if lose == true then
        goto return_to_home_page
    end
    appear("卫戍协议战斗准备就绪", 60)
    tap("卫戍协议战斗返回")
    ssleep(.5)
    tap("卫戍协议金币清零确定")
    ssleep(8)
    ::relink::
    appear("卫戍协议放弃模拟", 60)
    ssleep(.5)
    tap("卫戍协议放弃模拟")
    ssleep(.5)
    tap("卫戍协议金币清零确定")
    ::return_to_home_page::
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

-- ===== 极速模拟商店识别购买/部署(2026-11-15) =====
-- 每回合识别卡栏布局(极速L1=4卡/L2-5=5卡/L6=6卡,卡位右起1-6,见 point.卫戍协议商店卡位列表):
-- 名称OCR查 autochess_data.json 的盟约、character_type_list.json 的职业,名字对不上时OCR盟约区兜底。
-- 优先级:核心盟约新名字尽量多买多部署(没部署位才落待部署区攒购买进度) > 重装最多2个 > 近卫补位;
-- 精准盟约要买≥3个不同名字的干员:新名字优先部署,凑齐三人后同名副本也往场上部署(待部署区干员没有作用);
-- 近战职业(PIONEER/WARRIOR/TANK/SPECIAL)放近战格,医疗(MEDIC)放医疗格,其余放远程格,部署一律朝右。
-- 三个同名干员自动合成2星:2星自动落到场上第一个部署的同名1星位置(其余同名1星撤下),场上没有同名1星时才落待部署区;
-- 合成后商店自动刷新一次出现"3选1"(卡位右起1-3,暂无标定素材,按readCard同逻辑识别名称),选evaluate最优的一个并部署。
-- 升本只到4本:确认生效但校验可能失效,靠"总共最多尝试3次=最多+3本"兜底;
-- 刷新费1,回合结束金币清零,每回合一直刷新直到刷新按钮变灰(买不起),把金币花光。

local 近战职业 = { WARRIOR = true, TANK = true }
local 远程职业 = { SNIPER = true, CASTER = true, SUPPORT = true }
local 医疗职业 = { MEDIC = true }
local borderOn = "3F8E7F"         --卡边框亮色=可购买
local borderOff = "50706A"        --卡边框灰色=买不起
local borderGold = "CE9644"       --已拥有干员的金色发光边框(实测约206,150,68),同样可购买(买它推进合成)
local borderGoldBright = "E2B25A" --金光偏亮态兜底
local borderSelected = "128E74"   --卡被选中待确认的边框色(18,142,116),再点一次才真正购买
local borderEmpty = "454545"      --空卡位灰板色(69,69,69),比无卡位的深色背景(约27,32,34)亮
local waitingZoneLimit = 8        --待部署区共10格,留2格余量

--多段文本拼接(盟约区可能分多行),单元素识别用 ocro 取第一段
local ocrText = function(pointKey)
    if not pointKey then return "" end
    local segments = {}
    for _, segment in ipairs(ocrex(pointKey) or {}) do
        segments[#segments + 1] = segment.text or ""
    end
    return (table.concat(segments):gsub("[%s　]+", ""))
end

--单元素数字识别(货币/刷新费/剩余可放置数)
local ocrNumber = function(pointKey)
    local text = ocro(pointKey)
    return text and text ~= "" and tonumber((text:gsub("%D", ""))) or nil
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

--卡位(右起1-6)边框比色:亮=可购买,灰=已购/买不起,都不是=空槽
local slotColor = function(slotIndex, borderColor)
    local slotPoint = point["卫戍协议商店卡位列表" .. slotIndex]
    if not slotPoint then return false end
    return findOneStr(slotPoint[1] .. "|" .. slotPoint[2] .. "|" .. borderColor) ~= nil
end

local slotBuyable = function(slotIndex)
    --金光=已拥有同名干员,可买且推进合成;两个金色色调兜底
    return slotColor(slotIndex, borderOn) or slotColor(slotIndex, borderGold) or slotColor(slotIndex, borderGoldBright)
end

local slotHasCard = function(slotIndex)
    return slotBuyable(slotIndex) or slotColor(slotIndex, borderOff)
end

--卡位是否存在:有卡(亮/灰边框)或空槽灰板,都比"无卡位"的深色背景亮
local slotExists = function(slotIndex)
    return slotBuyable(slotIndex) or slotColor(slotIndex, borderOff) or slotColor(slotIndex, borderEmpty)
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
        log()
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

--state.已部署格子:按格子下标记录 {name=干员名, star=1/2, prof=职业} 或 false=空
--state.已部署格子Kinds:每格类别('近战格子'/'远程格子'/'医疗格子'),干员按职业进对应部署格,没有同类空格就不部署
local findFree格子 = function(state, wantKind)
    for 格子Index = 1, #state.已部署格子 do
        if not state.已部署格子[格子Index] and state.已部署格子Kinds[格子Index] == wantKind then return 格子Index end
    end
end

-- 优先找同 kind 的空格；没有空格时，找同 kind 上非核心单位占用的格子顶替
local findDeploy格子 = function(state, wantKind)
    local freeIndex = findFree格子(state, wantKind)
    if freeIndex then return freeIndex, false end
    for 格子Index = 1, #state.已部署格子 do
        local oper = state.已部署格子[格子Index]
        if oper and state.已部署格子Kinds[格子Index] == wantKind and oper.core ~= true then
            return 格子Index, true
        end
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

--购买优先级:1=核心新名字部署 2=重装补位(场上≤2)/凑齐三人后同名核心补场 3=非核心补位(重装/近卫/医疗/远程等,
--优先把8个格子部署满) 4=核心新名字上架 5=同名核心上架(攒合成)
local evaluate = function(card, state, waitingZoneCount)
    local fielded, coreDistinct = fieldCoreNames(state)

    if card.core then
        local 格子Index, overwrite = findDeploy格子(state, card.格子Kind)
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
            sim.已部署格子[best.格子Index] = { name = bestCard.name, star = 1, prof = bestCard.prof, core = bestCard.core }
        else
            waitingZoneCount = waitingZoneCount + 1
        end
        plan[#plan + 1] = best
        table.remove(candidates, bestIndex)
    end
    return plan
end


--买卡:双击卡位购买(单击只是选中,隔久了再点会变成取消),买后卡位清空成灰板(NO INFO);
--购买成功判定:关掉详情面板后比对待部署区占用,多出一格=已落位,返回落位格位(后续部署直接从这里拖);
--卡位还是亮/金光=没买成(再双击),变灰=金币不足;待部署区始终没+1视为失败
local buyCard = function(card)
    local slotIndex = card.slot
    local slotPoint = point["卫戍协议商店卡位列表" .. slotIndex]
    local clickPos = { slotPoint[1] + scale(116), scale(930) }
    local before = waitingZoneRecognize()
    if slotColor(slotIndex, borderOff) then
        log("购买转灰(金币不足):" .. card.name)
        return false
    end
    tap(clickPos)
    ssleep(.5)
    tap(clickPos)
    ssleep(1)

    local landingGrid = waitingZoneRecognize()
    if landingGrid - before == 1 then
        log("购买:" .. card.name .. (card.core and "(核心)" or "") ..
            (card.prof and "[" .. card.prof .. "]" or "") .. " 落位格" .. landingGrid)
        return true, landingGrid
    else
        log("购买失败:" .. card.name)
        return false
    end
end

--单次拖拽并验证落位:待部署区该格位变空(拖走了)或剩余可放置数-1;都不可用只能信任
local deployBought = function(from, tile, direction)
    local direction = direction or "右"
    local from = from or waitingZoneRecognize()
    log("开始部署第", from, "个干员")
    swipe_slow(待部署区[from], tile)
    deploy0(tile, direction)
    ssleep(.4)
    if waitingZoneRecognize() == from - 1 then
        log.debug("部署成功")
    end
    return true --校验不可用只能信任
end

--买到的干员入待部署区并检查三合一;合成时场上第一个部署(rank最小)的同名1星原地变2星、其余同名1星撤下,
--返回"field"=2星已自动落场无需拖拽 / "waitingZone"=场上没有同名1星,2星落待部署区需要拖部署 / nil=没合成
local addAndMerge = function(state, card)
    local name = card.name
    state.waitingZone1[name] = (state.waitingZone1[name] or 0) + 1
    local fieldSame = fieldSameCount(state, name)
    if state.waitingZone1[name] + fieldSame < 3 then return nil end
    local firstGrid
    for 格子Index, oper in ipairs(state.已部署格子) do
        if oper and oper.star == 1 and oper.name == name and (not firstGrid or oper.rank < state.已部署格子[firstGrid].rank) then
            firstGrid = 格子Index
        end
    end
    state.waitingZone1[name] = state.waitingZone1[name] - (3 - fieldSame)
    if state.waitingZone1[name] <= 0 then state.waitingZone1[name] = nil end
    if firstGrid then
        local keepRank = state.已部署格子[firstGrid].rank
        for 格子Index, oper in ipairs(state.已部署格子) do
            if oper and oper.star == 1 and oper.name == name and 格子Index ~= firstGrid then
                state.已部署格子[格子Index] = false
            end
        end
        state.已部署格子[firstGrid] = { name = name, star = 2, prof = card.prof, core = card.core, rank = keepRank }
        log("合成:" .. name .. "→2星(自动落场)")
        return "field"
    end
    state.waitingZone2[name] = (state.waitingZone2[name] or 0) + 1
    log("合成:" .. name .. "→2星(待部署区)")
    return "waitingZone"
end

--2星落在待部署区(场上没有同名1星时)才需要拖部署:部署到同类空格;没空格就留在待部署区等后续
local deployStar2 = function(state, card)
    local 格子Index = findFree格子(state, card.格子Kind)
    if not 格子Index then return end
    local tile = state.已部署格子Points[格子Index]
    ssleep(1) --等合成撤人动画
    if deployBought(nil, tile) then
        local name = card.name
        state.rank = (state.rank or 0) + 1
        state.已部署格子[格子Index] = { name = name, star = 2, prof = card.prof, core = card.core, rank = state.rank }
        state.waitingZone2[name] = (state.waitingZone2[name] or 1) - 1
        if state.waitingZone2[name] <= 0 then state.waitingZone2[name] = nil end
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
        local before = waitingZoneRecognize()
        tap(clickPos)
        ssleep(.5)
        tap(clickPos)
        ssleep(1)
        log("三选一:" .. tostring(card.name) .. (card.core and "(核心)" or ""))
        local landingGrid
        for _ = 1, 4 do
            landingGrid = newwaitingZoneSlot(before)
            if landingGrid then break end
            ssleep(.5)
        end
        local merge = addAndMerge(state, card)
        if merge == "waitingZone" then
            deployStar2(state, card)
        elseif merge == nil and pick.action == "deploy" and not state.deployBroken then
            local 格子Index = pick.格子Index
            if state.已部署格子[格子Index] then
                格子Index = findFree格子(state, card.格子Kind)
            end
            if 格子Index then
                if deployBought(landingGrid, state.已部署格子Points[格子Index]) then
                    state.rank = (state.rank or 0) + 1
                    state.已部署格子[格子Index] = {
                        name = card.name,
                        star = 1,
                        prof = card.prof,
                        core = card.core,
                        rank = state
                            .rank
                    }
                    state.waitingZone1[card.name] = (state.waitingZone1[card.name] or 1) - 1
                    if state.waitingZone1[card.name] <= 0 then state.waitingZone1[card.name] = nil end
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
        local ok, landingGrid = buyCard(card)
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
                    if pick.overwrite and occupied.core ~= true and occupied.star == 1 then
                        -- 顶替非核心一星：允许直接覆盖，被顶掉的单位去向见下面说明
                        local old = occupied
                        -- 例如退回待部署区：
                        -- state.waitingZone1[old.name] = (state.waitingZone1[old.name] or 0) + 1
                    else
                        -- 核心/2星占位，或合成导致的占位：重找同类空格
                        格子Index = findFree格子(state, card.格子Kind)
                    end
                end

                if 格子Index then
                    if deployBought(landingGrid, state.已部署格子Points[格子Index]) then
                        state.rank = (state.rank or 0) + 1
                        state.已部署格子[格子Index] = {
                            name = name,
                            star = 1,
                            prof = card.prof,
                            core = card.core,
                            rank = state.rank,
                        }
                        state.waitingZone1[name] = (state.waitingZone1[name] or 1) - 1
                        if state.waitingZone1[name] <= 0 then state.waitingZone1[name] = nil end
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

--卡位状态签名(亮/灰/空槽/背景),用于判定刷新是否生效
local makeSignature = function(cardCount)
    local sigParts = {}
    for slotIndex = 1, cardCount - 1 do
        sigParts[slotIndex] = slotBuyable(slotIndex) and "1" or
            (slotColor(slotIndex, borderOff) and "2" or (slotColor(slotIndex, borderEmpty) and "3" or "0"))
    end
    return table.concat(sigParts)
end

--刷新商店(费1):一直点刷新,直到刷新按钮变灰(买不起)为止,不做硬次数限制;
--刷没刷动仍用"卡位签名或首个亮槽卡名变化"判定(全亮商店签名可能巧合相同,以卡名为准);
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
        if makeSignature(cardCount) ~= prevSig then
            log("刷新第" .. state.refreshCount .. "次")
            return true
        end
        if checkSlot and ocro("卫戍协议商店名称列表" .. checkSlot) ~= oldName then
            log("刷新第" .. state.refreshCount .. "次")
            return true
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

autochess.卫戍协议循环1 = function()
    log("卫戍协议循环")
    local lost = false
    local settleShots = 0 --上一轮结算页截图计数(仅诊断用)

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
    --state:回合内共享状态;格子=各部署格{name,star,prof,core,rank}(false=空),rank=部署次序(合成2星要落"第一个部署的同名干员"位置),
    --格子Points/格子Kinds=各格坐标与类别(近/远/医),waitingZone1/waitingZone2=待部署区上1星/2星干员数量
    local state = { level = 1, refreshCount = 0, rank = 0, 已部署格子 = {}, 已部署格子Points = {}, 已部署格子Kinds = {}, waitingZone1 = {}, waitingZone2 = {} }
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
        goto relink
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

    for roundNo = 1, 9 do
        if appear("卫戍协议战斗准备就绪", 65) then
            ssleep(.1)
            log("第" .. roundNo .. "回合")
            state.refreshCount = 0

            ssleep(1) --等卡栏展开动画
            local shopOk, shopErr = pcall(autochess.商店购买, state, data, roundNo)
            if not shopOk then log("商店购买异常:" .. tostring(shopErr)) end

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
            log("卫戍协议战斗失败")
            lost = true
            break
        end
    end
    if lost == true then
        goto return_to_home_page
    end
    --最后一轮打完boss战较久,先安静等战斗结束,再周期点屏幕中央推进"卫戍完成"等中间画面,
    --出现结算页"返回主页"就点它(会自动结算掉模拟,不用再放弃);周期存截图便于排查卡在哪个画面
    ssleep(150)
    settleShots = 0
    if wait(function()
            if findOne("卫戍协议结算返回主页") then
                tap("卫戍协议结算返回主页")
                return true
            end
            tap({ 960, 540 })
            settleShots = settleShots + 1
            snapShot("/sdcard/pictures/结算" .. settleShots .. ".png")
            ssleep(1)
        end, 180) then
        ssleep(3)
        goto return_to_home_page
    end
    log("未等到通关结算页,按中途退出处理")
    tap("卫戍协议战斗返回")
    ssleep(.5)
    tap("卫戍协议金币清零确定")
    ssleep(8)
    ::relink::
    appear("卫戍协议放弃模拟", 60)
    ssleep(.5)
    tap("卫戍协议放弃模拟")
    ssleep(.5)
    tap("卫戍协议金币清零确定")
    ::return_to_home_page::
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

autochess.卫戍协议刷角标 = function()
    log("卫戍协议刷角标开始")
    local lose = false

    if not findOne("卫戍协议首页") then
        autochess.卫戍协议进入()
    end
    if not appear("卫戍协议首页", 5) then return end
    if findOne("卫戍协议放弃模拟") then
        return
    end

    if not wait(function()
            if findOne("卫戍协议个人模拟") then return true end
            tap("卫戍协议个人模拟")
            ssleep(.1)
        end, 2) then
        return false
    end
    tap("卫戍协议独立模拟按钮")
    disappear("卫戍协议首页", 3)
    appear("卫戍协议开始模拟", 3)

    -- 难度选择

    for i = 1, 100 do
        tap("卫戍协议最下面")
        if findOne("卫戍协议规程登记1") then
            break
        end
        ssleep(0.05)
    end
    if not findOne("卫戍协议规程登记1") then
        log("未找到规程登记1")
        return
    end

    appear("卫戍协议开始模拟", 3)
    ssleep(.2)
    tap("卫戍协议开始模拟")

    if not wait(function()
            if findOne("卫戍协议选择分队") then return true end
            tap("卫戍协议准备就绪")
        end, 10, 1) then
    end
    ssleep(.5)

    -- 寻找没有角标的分队
    local find_first_team = function()
        local mubiao = "FF9C1B"
        local x = 1114
        local y = 127
        local px = 210
        local py = 210
        for sx = 0, 3 do
            for sy = 0, 3 do
                local l = scale(x + sx * px)
                local t = scale(y + sy * py)
                local b = scale(y + sy * py + 55)
                local r = scale(x + sx * px + 55)
                if not find_color({ l, t, r, b }, mubiao, 1, 90 / 100) then
                    -- log.debug("color not found", sx, sy)
                    log("第", sy + 1, "行第", sx + 1, "列没有角标")
                    return math.abs((l + r) / 2), math.abs((t + b) / 2)
                else
                    log("第", sy + 1, "行第", sx + 1, "列有角标")
                    log(l, t, r, b)
                end
                -- log.debug("color", sx, sy, color)
            end
        end
    end

    local team_x, team_y = find_first_team()
    if not find_first_team then
        log("没有找到没有角标的分队1")
        tap("卫戍协议分队中间")
        ssleep(.1)
        team_x, team_y = find_first_team()
        if not find_first_team then
            log("没有找到没有角标的分队2")
            return
        end
    end

    tap(team_x, team_y)

    ssleep(2)
    wait(function()
        tap("卫戍协议准备就绪")
    end, 5, 1)
    ssleep(10)
    appear("卫戍协议战斗准备就绪", 40)
    log("卫戍协议进入第一回合战斗")
    exit()

    if lose == true then
        return
    end

    -- 结束模拟
    if appear("卫戍协议放弃模拟", 2) then
        ssleep(.5)
        tap("卫戍协议放弃模拟")
        ssleep(.5)
    end
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
