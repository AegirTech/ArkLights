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

--待部署区卡片槽位1~10:map1 格子[x,y],右到左
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
--装备区箱子槽位1~5:map1 格子[x,y],右到左
local 装备区 = { [1] = { 8, 5 }, [2] = { 7, 5 }, [3] = { 6, 5 }, [4] = { 5, 5 }, [5] = { 4, 5 }, }

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

local 近战格子 = { { 8, 1 }, { 8, 2 } }
local 远程格子 = { { 7, 2 }, { 8, 3 }, { 6, 2 }, { 7, 1 }, { 6, 1 } }
--补位格子:老版盲拿策略用过的中路格(去掉重复的4,2),近战/远程格都满后用来把部署位填满到8个
local 补位格子 = { { 4, 4 }, { 3, 3 }, { 3, 2 }, { 4, 2 }, { 3, 1 }, { 4, 3 }, { 3, 4 }, { 4, 1 } }
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
    ssleep(1)
    if appear("阿米娅", 3) then
        if not path.卫戍协议教程() then
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
-- 每回合识别卡栏布局(极速L1=4卡/L2-5=5卡/L6=6卡,槽位左起1-6,见 point.卫戍协议商店槽位列表):
-- 名称OCR查 autochess_data.json 的盟约、character_type_list.json 的职业,名字对不上时OCR盟约区兜底。
-- 优先级:核心盟约干员尽量多买(没部署位就放待部署区攒盟约层数) > 重装最多2个 > 近卫补位;
-- 近战职业(PIONEER/WARRIOR/TANK/SPECIAL)放近战格,其余放远程格,部署一律朝右。
-- 三个同名干员自动合成2星,已部署的同名1星会被撤下来,2星落在待部署区,合成后立刻重新部署。
-- 升本只到4本:确认生效但校验可能失效,靠"总共最多尝试3次=最多+3本"兜底;
-- 刷新费1,回合结束金币清零,所以每回合尽量把金币花光。
local meleeJobs = { PIONEER = true, WARRIOR = true }
local borderOn = "3F8E7F"         --卡边框亮色=可购买
local borderOff = "50706A"        --卡边框灰色=买不起
local borderGold = "CE9644"       --已拥有干员的金色发光边框(实测约206,150,68),同样可购买(买它推进合成)
local borderGoldBright = "E2B25A" --金光偏亮态兜底
local borderSelected = "128E74"   --卡被选中待确认的边框色(18,142,116),再点一次才真正购买
local borderEmpty = "454545"      --空槽位灰板色(69,69,69),比无槽位的深色背景(约27,32,34)亮
local benchLimit = 8              --待部署区货架共10格,留2格余量
local refreshLimit = 8            --每回合刷新次数上限,防止异常死循环

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

local readLevel = function()
    for levelIndex = 1, 6 do
        if findOne("卫戍协议商店等级列表" .. levelIndex) then
            return levelIndex
        end
    end
end

--槽位(左起1-6)边框比色:亮=可购买,灰=已购/买不起,都不是=空槽
local slotColor = function(slotIndex, borderColor)
    local slotPoint = point["卫戍协议商店槽位列表" .. slotIndex]
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

--槽位是否存在:有卡(亮/灰边框)或空槽灰板,都比"无槽位"的深色背景亮
local slotExists = function(slotIndex)
    return slotBuyable(slotIndex) or slotColor(slotIndex, borderOff) or slotColor(slotIndex, borderEmpty)
end

--当前卡栏布局:6卡=槽位1存在,5卡=槽位2存在,否则4卡
--(升级只加空槽不加卡,不能用"有卡"判;:1本=4卡/2-5本=5卡/6本=6卡)
local detectCardCount = function()
    if slotExists(1) then return 6 end
    if slotExists(2) then return 5 end
    return 4
end

--商店右上"剩余可放置角色:N";OCR偶尔丢数字,重试几次
local readRemaining = function()
    for _ = 1, 3 do
        local count = ocrNumber("卫戍协议商店剩余可放置列表1")
        if count then return count end
        ssleep(.2)
    end
end


local correctName = function(name)
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

--名字匹配 autochess_data 干员 key:先全等,再包含匹配(OCR 常掉字)
local matchOperator = function(data, name)
    if name and data.ops[name] then return name end
    if name and #name >= 3 then --1个汉字=3字节
        for opKey in pairs(data.ops) do
            if #opKey >= 3 and (opKey:find(name, 1, true) or name:find(opKey, 1, true)) then
                return opKey
            end
        end
    end
end

--读卡:亮/金光边框才细读;名称必须读到(金光/动画可能让单次 OCR 为空,等一会重试);
--名字对上 JSON 直接拿盟约/职业,否则 OCR 盟约区兜底;failedSlots 里的槽位跳过
local readCard = function(data, slotIndex, failedSlots)
    local card = { slot = slotIndex, buyable = not failedSlots[slotIndex] and slotBuyable(slotIndex) }
    if not card.buyable then return card end
    local name = ""
    for _ = 1, 4 do
        name = correctName(ocro("卫戍协议商店名称列表" .. slotIndex))
        if name ~= "" then break end
        ssleep(.5)
    end
    if name == "" then log("识别:槽位" .. slotIndex .. "名称多次OCR为空") end
    card.name = name
    local opName = matchOperator(data, name)
    if opName then
        local info = data.ops[opName]
        card.kind = "op"
        card.opName = opName
        card.level = info.level
        card.bonds = info.bonds or {}
        card.prof = data.prof[opName]
    else
        local bondText = ocrText("卫戍协议商店盟约列表" .. slotIndex)
        card.bonds = {}
        for bondName in pairs(data.bonds) do
            if bondText:find(bondName, 1, true) then card.bonds[bondName] = true end
        end
        if data.prof[name] then
            card.kind = "op"
            card.prof = data.prof[name]
        elseif next(card.bonds) then
            card.kind = "op" --有盟约字样但职业未知:只敢上架攒层数,不敢部署
        elseif data.items[name] then
            card.kind = "item"
        else
            card.kind = "unknown"
        end
    end
    if card.kind == "op" then
        card.core = card.bonds[coreBond] == true
        if card.prof then card.melee = meleeJobs[card.prof] == true end
    end
    return card
end

--state.cells:按格子下标记录 {name=干员名, star=1/2, prof=职业} 或 false=空
--state.cellKinds:每格类别('近'/'远'/'补'),近战/远程干员优先同类格,满了用补位格凑满8个部署位
local findFreeCell = function(state, wantMelee)
    local wantKind = wantMelee and '近' or '远'
    for cellIndex = 1, #state.cells do
        if not state.cells[cellIndex] and state.cellKinds[cellIndex] == wantKind then return cellIndex end
    end
    for cellIndex = 1, #state.cells do
        if not state.cells[cellIndex] and state.cellKinds[cellIndex] == '补' then return cellIndex end
    end
end

local fieldTanks = function(state)
    local tankCount = 0
    for _, unit in ipairs(state.cells) do
        if unit and unit.prof == "TANK" then tankCount = tankCount + 1 end
    end
    return tankCount
end

--场上同名1星数量(合成计数用,2星不参与1星三合一)
local fieldSameCount = function(state, name)
    local sameCount = 0
    for _, unit in ipairs(state.cells) do
        if unit and unit.star == 1 and unit.name == name then sameCount = sameCount + 1 end
    end
    return sameCount
end

local benchTotal = function(state)
    local benchCount = 0
    for _, amount in pairs(state.bench1) do benchCount = benchCount + amount end
    for _, amount in pairs(state.bench2) do benchCount = benchCount + amount end
    return benchCount
end

--购买优先级:1=核心盟约可部署 2=重装补位(场上≤2) 3=近卫补位 4=核心盟约上架(攒层数/攒合成)
local evaluate = function(card, state, benchCount)
    if card.kind ~= "op" then return end
    if card.core then
        if card.melee == true then
            local cellIndex = findFreeCell(state, true)
            if cellIndex and (card.prof ~= "TANK" or fieldTanks(state) < 2) then return 1, "deploy", cellIndex end
        elseif card.melee == false then
            local cellIndex = findFreeCell(state, false)
            if cellIndex then return 1, "deploy", cellIndex end
        end
        if benchCount < benchLimit then return 4, "bench" end
        return
    end
    if card.prof == "TANK" and fieldTanks(state) < 2 then
        local cellIndex = findFreeCell(state, true)
        if cellIndex then return 2, "deploy", cellIndex end
    end
    if card.prof == "WARRIOR" then
        local cellIndex = findFreeCell(state, true)
        if cellIndex then return 3, "deploy", cellIndex end
    end
end

--贪心规划:在占位快照上反复挑当前最优(priority 小者优先,同级取高档),直到没有可买
local buildPlan = function(cards, state)
    local simCells = {}
    for cellIndex = 1, #state.cells do simCells[cellIndex] = state.cells[cellIndex] end
    local sim = { cells = simCells, cellKinds = state.cellKinds }
    local benchCount = benchTotal(state)
    local candidates = {}
    for _, card in ipairs(cards) do
        if card.buyable then candidates[#candidates + 1] = card end
    end
    local plan = {}
    while #candidates > 0 do
        local best, bestIndex, bestPriority
        for candidateIndex, card in ipairs(candidates) do
            local priority, action, cellIndex = evaluate(card, sim, benchCount)
            if priority and (not bestPriority or priority < bestPriority or (priority == bestPriority and (card.level or 0) > (best.card.level or 0))) then
                best, bestIndex, bestPriority =
                { priority = priority, action = action, cellIndex = cellIndex, card = card }, candidateIndex, priority
            end
        end
        if not best then break end
        local bestCard = best.card
        if best.action == "deploy" then
            sim.cells[best.cellIndex] = { name = bestCard.opName or bestCard.name, star = 1, prof = bestCard.prof }
        else
            benchCount = benchCount + 1
        end
        plan[#plan + 1] = best
        table.remove(candidates, bestIndex)
    end
    return plan
end

--买卡:双击卡位购买(单击只是选中,隔久了再点会变成取消),买后槽位清空成灰板(NO INFO);
--用槽位边框状态判定:变空槽板=已买;还是亮/金光=没买成(再双击),变灰=金币不够了
local buyCard = function(card)
    local slotIndex = card.slot
    local slotPoint = point["卫戍协议商店槽位列表" .. slotIndex]
    local clickPos = { slotPoint[1] + scale(116), scale(930) }
    for _ = 1, 4 do
        tap(clickPos)
        clickPoint(clickPos[1], clickPos[2]) --第二击用裸点击紧跟,保证构成双击(tap内含GC间隔太久会被当成取消)
        ssleep(1)
        if not slotHasCard(slotIndex) and not slotColor(slotIndex, borderSelected) then
            log("购买:" ..
            tostring(card.name) .. (card.core and "(核心)" or "") .. (card.prof and "[" .. card.prof .. "]" or ""))
            return true
        end
        if slotColor(slotIndex, borderOff) then
            log("购买转灰(金币不足?):" .. tostring(card.name))
            return false
        end
    end
    log("购买失败:" .. tostring(card.name))
    return false
end

--从货架拖一个干员到目标格并朝右:依次试货架格(新买的/合成2星落位不固定)。
--朝向确认(deploy0)必须紧跟拖拽——拖完不立刻定朝向干员不算真正落下,剩余数也不会变;
--deploy0 后再用"剩余可放置数-1"校验,没变就试下一个货架格;扫两轮(刚买的干员落架有动画,第一轮可能扑空)
local dragDeploy = function(tile, beforeCount)
    for attempt = 1, 2 do
        for shelf = 1, #待部署区 do
            swipe_slow(待部署区[shelf], tile)
            deploy0(tile, "右")
            ssleep(.4)
            local afterCount = readRemaining()
            if not beforeCount or not afterCount then
                return true --校验不可用只能信任
            end
            if afterCount == beforeCount - 1 then
                return true
            end
        end
        if attempt == 1 then
            log("部署第一轮未拖到,等落架动画后再试")
            ssleep(1)
        end
    end
    return false
end

--买到的干员入货架并检查三合一;发生合成时场上同名1星全部撤下、货架出现2星,返回true=有2星待部署
local addAndMerge = function(state, name)
    state.bench1[name] = (state.bench1[name] or 0) + 1
    local fieldSame = fieldSameCount(state, name)
    if state.bench1[name] + fieldSame < 3 then return false end
    for cellIndex, unit in ipairs(state.cells) do
        if unit and unit.star == 1 and unit.name == name then state.cells[cellIndex] = false end
    end
    state.bench1[name] = state.bench1[name] - (3 - fieldSame)
    if state.bench1[name] <= 0 then state.bench1[name] = nil end
    state.bench2[name] = (state.bench2[name] or 0) + 1
    log("合成:" .. name .. "→2星")
    return true
end

--2星合成后立刻部署到同类空格(撤格腾出的空位优先可用);没空格就留在货架等后续
local deployStar2 = function(state, card)
    local wantMelee = card.melee == true
    local cellIndex = findFreeCell(state, wantMelee)
    if not cellIndex then return end
    local tile = state.cellPoints[cellIndex]
    ssleep(1) --等合成撤人动画
    local beforeCount = readRemaining()
    if dragDeploy(tile, beforeCount) then
        local name = card.opName or card.name
        state.cells[cellIndex] = { name = name, star = 2, prof = card.prof }
        state.bench2[name] = (state.bench2[name] or 1) - 1
        if state.bench2[name] <= 0 then state.bench2[name] = nil end
        log("部署2星:" .. tostring(card.name))
    end
end

--执行规划:返回 "progress" 有购买 / "none" 没买成 / "changed" 卡栏异常需重识别
local execute = function(plan, state, failedSlots)
    local bought = false
    for _, pick in ipairs(plan) do
        local card = pick.card
        local ok, changed = buyCard(card)
        if changed then return "changed" end
        if ok then
            bought = true
            local name = card.opName or card.name
            if addAndMerge(state, name) then
                deployStar2(state, card) --三合一:2星在货架,立刻部署
            elseif pick.action == "deploy" and not state.deployBroken then
                local cellIndex = pick.cellIndex
                if state.cells[cellIndex] then
                    --合成撤人后原格可能被2星占用,重找空格(同类优先,补位兜底)
                    cellIndex = findFreeCell(state, card.melee == true)
                end
                if cellIndex then
                    local beforeCount = readRemaining() --买完再读基准(合成会改变剩余数)
                    if beforeCount == 0 then
                        --部署位已满,干员留在货架(不算失败)
                    elseif dragDeploy(state.cellPoints[cellIndex], beforeCount) then
                        state.cells[cellIndex] = { name = name, star = 1, prof = card.prof }
                        state.bench1[name] = (state.bench1[name] or 1) - 1
                        if state.bench1[name] <= 0 then state.bench1[name] = nil end
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

--升本(只到4本);升级卡同样是双击购买(单击只是选中,隔久了再点会取消)。
--每次尝试只打一对双击=至多+1本,总尝试≤3次=至多+3本,等级保证不超过4本;
--本数用LEVEL图标罗马数字读出校准(读不出时全靠次数上限兜底)
local upgrade = function(state, cardCount)
    if state.level >= 4 or (state.upgradeTries or 0) >= 3 then return false end
    local upgradeIdx = cardCount - 3
    if upgradeIdx < 1 or upgradeIdx > 3 then return false end
    if not findOneStr(point["卫戍协议升级可付列表" .. upgradeIdx]) then return false end
    state.upgradeTries = (state.upgradeTries or 0) + 1
    local uiLevel = readLevel(upgradeIdx)
    if uiLevel and uiLevel ~= state.level then
        log("本数校准:" .. state.level .. "→" .. uiLevel)
        state.level = uiLevel
        if state.level >= 4 then return false end
    end
    tap("卫戍协议升级按钮列表" .. upgradeIdx)
    local buttonPos = point["卫戍协议升级按钮列表" .. upgradeIdx]
    clickPoint(buttonPos[1], buttonPos[2]) --第二击裸点击紧跟,保证构成双击
    ssleep(.8)
    local newCardCount = detectCardCount()
    if newCardCount > cardCount then
        state.level = 2 --只有1→2本会加卡槽
        log("升本到2本")
        return true
    end
    local newLevel = readLevel(upgradeIdx)
    if newLevel and newLevel > state.level then
        state.level = newLevel
        log("升本到" .. newLevel .. "本")
        return true
    end
    log("升本点击未生效,当前" .. state.level .. "本")
    return false
end

--槽位状态签名(亮/灰/空槽/背景),用于判定刷新是否生效
local makeSignature = function(cardCount)
    local sigParts = {}
    for slotIndex = 7 - cardCount, 6 do
        sigParts[#sigParts + 1] = slotBuyable(slotIndex) and "1" or
        (slotColor(slotIndex, borderOff) and "2" or (slotColor(slotIndex, borderEmpty) and "3" or "0"))
    end
    return table.concat(sigParts)
end

--刷新商店(费1);刷新后槽位签名或首个亮槽卡名会变(全亮商店签名可能巧合相同,以卡名为准),
--没刷动(金币不足)时两者都不变
local refresh = function(state, cardCount, cards)
    if state.refreshCount >= refreshLimit then return false end
    local refreshCost = ocrNumber("卫戍协议刷新价格") or 1
    local gold = ocrNumber("卫戍协议货币")
    if gold and gold < refreshCost + 1 then return false end --还剩的钱至少要能买最便宜的卡
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
        if makeSignature(cardCount) ~= prevSig then
            log("刷新第" .. state.refreshCount .. "次")
            return true
        end
        if checkSlot and ocro("卫戍协议商店名称列表" .. checkSlot) ~= oldName then
            log("刷新第" .. state.refreshCount .. "次")
            return true
        end
    end
    log("刷新无效(金币不足?)")
    return false
end

--模拟一轮商店:升本到 4 本→按优先级买/部署→刷新循环,金币花光或上限到就收手
autochess.商店购买 = function(state, data)
    state.round = (state.round or 0) + 1

    --关闭遗留的详情面板(面板打开时全屏变暗,所有比色会失效);点面板外区域只关面板不动选中态
    tap({ 960, 400 })
    ssleep(.5)

    --等商店阶段就绪:准备就绪按钮出现(槽位可能被上一轮买空,不能用槽位有卡判)
    if not wait(function()
            if findOne("卫戍协议战斗准备就绪") then return true end
        end, 20) then
        log("商店卡栏未出现")
        return
    end

    --记录可放置上限;若战斗后场上干员未保留(被清场)则重置占位跟踪
    local remaining = readRemaining()
    if remaining then
        if not state.maxDeploy then state.maxDeploy = remaining end
        local fieldCount = 0
        for _, unit in ipairs(state.cells) do if unit then fieldCount = fieldCount + 1 end end
        if fieldCount > 0 and remaining >= state.maxDeploy then
            log("场上干员未保留,重置部署跟踪")
            state.bench1, state.bench2 = {}, {}
            for cellIndex = 1, #state.cells do state.cells[cellIndex] = false end
        end
    end

    --用升级卡 LEVEL 图标校准本数(防确认生效但校验失败导致的等级漂移)
    local roundLevel = readLevel(detectCardCount() - 3)
    if roundLevel and roundLevel ~= state.level then
        log("本数校准:" .. state.level .. "→" .. roundLevel)
        state.level = roundLevel
    end

    if findFreeCell(state, true) == nil and findFreeCell(state, false) == nil and benchTotal(state) >= benchLimit then
        log("商店已满载,跳过购买")
        return
    end

    local failedSlots = {}
    for _ = 1, 25 do
        local cardCount = detectCardCount()
        if state.level < 4 and upgrade(state, cardCount) then
            failedSlots = {}  --升本可能加卡槽,重新识别
        else
            tap({ 960, 400 }) --关闭详情面板(上次购买的选中态会打开面板并变暗全屏)
            ssleep(.3)
            local cards = {}
            for slotIndex = 7 - cardCount, 6 do
                cards[#cards + 1] = readCard(data, slotIndex, failedSlots)
            end
            local result = "none"
            local plan = buildPlan(cards, state)
            if #plan > 0 then
                result = execute(plan, state, failedSlots)
                if result == "changed" then failedSlots = {} end
            end
            if result == "none" then
                if state.refreshCount < refreshLimit and refresh(state, cardCount, cards) then
                    failedSlots = {}
                else
                    log("商店收手:本回合刷新" .. state.refreshCount .. "次")
                    return
                end
            end
        end
    end
    log("商店动作步数用尽")
end

autochess.卫戍协议循环1 = function()
    log("卫戍协议循环")
    local lost = false
    local settleShots = 0 --上一轮结算页截图计数(仅诊断用)

    --购买识别数据:盟约(autochess_data.json)/职业(character_type_list.json),读不到时退化成纯OCR盟约识别
    --(声明需在goto之前,否则goto relink会跳进局部变量作用域)
    local data = { ops = {}, items = {}, prof = {}, bonds = {} }
    local readOk, readRet = pcall(JsonDecode, readFile("autochess_data.json"))
    if readOk and readRet then
        data.ops = readRet.operators or {}
        data.items = readRet.items or {}
        for _, v in pairs(data.ops) do
            for bondName in pairs(v.bonds or {}) do data.bonds[bondName] = true end
        end
    end
    readOk, readRet = pcall(JsonDecode, readFile("character_type_list.json"))
    if readOk and readRet then data.prof = readRet end
    --state:回合内共享状态;cells=各部署格{name,star,prof}(false=空),
    --cellPoints/cellKinds=各格坐标与类别(近/远/补),bench1/bench2=货架上1星/2星干员数量
    local state = { level = 1, refreshCount = 0, cells = {}, cellPoints = {}, cellKinds = {}, bench1 = {}, bench2 = {} }
    local initCells = function(points, kind)
        for _, point in ipairs(points) do
            state.cellPoints[#state.cellPoints + 1] = map2[point[1]][point[2]]
            state.cellKinds[#state.cellKinds + 1] = kind
            state.cells[#state.cells + 1] = false
        end
    end
    initCells(近战格子, '近')
    initCells(远程格子, '远')
    initCells(补位格子, '补')

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
            local shopOk, shopErr = pcall(autochess.商店购买, state, data)
            if not shopOk then log("商店购买异常:" .. tostring(shopErr)) end
            --点准备就绪开战:点击可能被悬浮窗等吞掉,按钮消失(进入战斗)且连续两次确认才算开战
            --不能用槽位有卡判:最后一张卡可能已被买空
            local buttonGone = 0
            wait(function()
                if findOne("卫戍协议战斗准备就绪") then
                    buttonGone = 0
                    tap("卫戍协议战斗准备就绪")
                    ssleep(.5)
                    if appear("卫戍协议金币清零确定") then
                        tap("卫戍协议金币清零勾")
                        ssleep(.1)
                        tap("卫戍协议金币清零确定")
                    end
                else
                    buttonGone = buttonGone + 1
                    if buttonGone >= 2 then return true end
                end
            end, 25)
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
