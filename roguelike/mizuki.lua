-- ===========================================
--               水月肉鸽相关
-- ===========================================

-- 水月肉鸽导航
mizuki_navigation = function()
    -- 先导航到水月_常规行动
    if not findOne("水月_常规行动") then
        path.跳转("首页")

        tap("面板作战")
        if not appear("主页") then return false end

        -- if not wait(function()
        --   if findOne("主题曲界面") then return true end
        --   tap("主题曲")
        -- end, 5) then return false end

        if not wait(function()
                if findOne("集成战略_查看全部主题") then return true end
                tap("集成战略")
            end, 5) then
            return false
        end

        if not wait(function()
                if checkPointColor(mizuki_point.等待开始页面标题) then
                    return true
                end
                tap("进入主题")
            end, 5) then
            return false
        end
    end
    log("常规行动选中")
    return true
end

-- 水月肉鸽助战
mizuki_help_fight = function(reflashNum)
    reflashNum = reflashNum or 0
    single_man_operation = false
    if reflashNum > 3 then
        log("助战刷新次数超过3次")
        return false
    end
    -- if not findOne("确认招募") then return end
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
        stop("找不到助战干员", 'cur')
    end

    local name2point = table.reduce(operator, function(a, c)
        a[c.text] = c
        return a
    end, {})

    local order = {
        { "羽毛笔", 0, 1 },
        { "海沫", 0, 1 },
        { "煌", 0, 2 },
        { "百炼嘉维尔", 99, 2 }
    }
    local best = table.findv(order, function(x) return name2point[x[1]] end)
    if not best then
        log.warn("助战也找不到所需干员")
        tapUntilCheckedPointColor(mizuki_point.刷新助战, mizuki_point.刷新助战中, 5)
        reflashNum = reflashNum + 1
        ssleep(3)
        return mizuki_help_fight(reflashNum)
    end
    reflashNum = 0
    if best[1] == "羽毛笔" or best[1] == "海沫" then
        single_man_operation = true
    end
    zl_skill_times = best[2]
    zl_skill_idx = best[3]
    -- log("best", best)
    -- if not best then return point.战略助战干员列表1, 0, 1 end
    local p = name2point[best[1]]
    p = { p.l, p.t }
    tap(p)
    disappear("战略助战界面", 5)
    return wait(function()
        if checkPointColor(mizuki_point.初始招募进度条) then
            log("助战选择完成")
            return true
        end
        tap("开包skip")
        tap("战略助战确认")
        -- 需要等待ui加载
        ssleep(0.5)
    end, 5)
end

-- 水月肉鸽重启
mizuki_restart = function(msg)
    toast(msg)
    mizuki_fight_time = mizuki_fight_time + 1
    -- if not restart_game_check(zl_restart_interval) then
    if not request_memory_clean() then
        path.水月与深蓝之树前瞻投资()
    else
        path.跳转("首页")
    end
end

-- 水月肉鸽认知塑造
mizuki_cognition = function()
    mizuki_fight_time = 0
    local f = function()
        local pos_cognition = mizuki_point.认知塑造界面[1] .. "|" ..
            mizuki_point.认知塑造界面[2] .. "|" ..
            mizuki_point.认知塑造界面[3]
        -- 进入认知塑造
        log("进入认知塑造")
        if not wait(function()
                tap({ mizuki_point.认知塑造[1], mizuki_point.认知塑造[2] })
                sleep(100)
                if findOneStr(pos_cognition) then return true end
            end, 5) then
            return
        end

        sleep(100)

        -- 缩放
        log("缩放")
        local finger = {
            {
                point = { { 0, 0 }, { screen.width // 2, screen.height // 2 } },
                duration = duration,
            }, {
            point = {
                { screen.width,      screen.height },
                { screen.width // 2, screen.height // 2 },
            },
            duration = duration,
        },
        }
        gesture(finger)
        sleep(300)

        -- 创建坐标
        local pos_up = mizuki_point.认知塑造节点升级[1] .. "|" ..
            mizuki_point.认知塑造节点升级[2] .. "|" ..
            mizuki_point.认知塑造节点升级[3]
        local pos_uped = mizuki_point.认知塑造节点已升级[1] .. "|" ..
            mizuki_point.认知塑造节点已升级[2] .. "|" ..
            mizuki_point.认知塑造节点已升级[3]
        local pos_lock = mizuki_point.认知塑造节点未解锁[1] .. "|" ..
            mizuki_point.认知塑造节点未解锁[2] .. "|" ..
            mizuki_point.认知塑造节点未解锁[3]

        -- 确认是否已满
        log("确认是否已满")
        tap(mizuki_point.认知塑造节点列表[#mizuki_point.认知塑造节点列表])
        ssleep(1)
        if findOneStr(pos_uped) then
            log("认知塑造已满")
            lighter_enough = true
            return true
        end

        -- 升级
        log("升级")
        for i = 1, #mizuki_point.认知塑造节点列表 do
            local flag = false
            if not wait(function()
                    tap(mizuki_point.认知塑造节点列表[i])
                    sleep(100)

                    if findOneStr(pos_lock) then
                        flag = true
                        return true
                    end

                    if findOneStr(pos_up) then
                        tap({
                            mizuki_point.认知塑造节点升级[1],
                            mizuki_point.认知塑造节点升级[2],
                        })
                    end

                    if findOneStr(pos_uped) then return true end
                end, 3) then
                break
            end
            if flag then break end
        end
    end
    f()
    return true
end

-- 水月肉鸽作战选择器
mizuki_fight_select = function()
    local select_fight = nil
    if not wait(function()
            setDict(0, "水月.txt") -- 字库需要放到资源文件中
            useDict(0)
            if not wait(function()
                    -- 战斗
                    select_fight = ocr(mizuki_point.水月关卡标题坐标1[1],
                        mizuki_point.水月关卡标题坐标1[2],
                        mizuki_point.水月关卡标题坐标1[3],
                        mizuki_point.水月关卡标题坐标1[4],
                        "FFFFFF", 0.90)
                    if select_fight ~= nil then
                        log(select_fight)
                        return true
                    end
                    -- 不期而遇/地区委托/诡异行商
                    select_fight = ocr(mizuki_point.水月关卡标题坐标2[1],
                        mizuki_point.水月关卡标题坐标2[2],
                        mizuki_point.水月关卡标题坐标2[3],
                        mizuki_point.水月关卡标题坐标2[4],
                        "FFFFFF", 0.90)
                    if select_fight ~= nil then
                        log(select_fight)
                        return true
                    end
                    -- 紧急战斗识别区域
                    select_fight = ocr(mizuki_point.水月关卡标题坐标3[1],
                        mizuki_point.水月关卡标题坐标3[2],
                        mizuki_point.水月关卡标题坐标3[3],
                        mizuki_point.水月关卡标题坐标3[4],
                        "FFFFFF", 0.90)
                    if select_fight ~= nil then
                        log(select_fight)
                        return true
                    end
                end, 5) then
                log("关卡识别错误")
                return mizuki_restart("关卡识别错误")
            end

            if #select_fight > 1 then
                if select_fight:includes({ "排", "反", "应" }) then
                    select_fight = "排异反应"
                elseif select_fight:includes({ "启", "示" }) then
                    select_fight = "启示"
                elseif select_fight:includes({ "大", "的", "呼", "唤" }) then
                    select_fight = "大群的呼唤"
                elseif select_fight:includes({ "掷", "出", "骰", "子" }) then
                    select_fight = "掷出骰子"
                elseif select_fight:includes({ "虫", "群", "横" }) then
                    select_fight = "虫群横行"
                    -- 蓄水池
                elseif select_fight:includes({ "蓄", "水", "池" }) then
                    select_fight = "蓄水池"
                    -- 共生
                elseif select_fight:includes({ "共", "生" }) then
                    select_fight = "共生"
                elseif select_fight:includes({ "互", "助" }) then
                    select_fight = "互助"
                elseif select_fight:includes({ "射", "手", "部", "队" }) then
                    select_fight = "射手部队"
                    -- 不期而遇
                elseif select_fight:includes({ "不", "期", "而", "遇" }) then
                    select_fight = "不期而遇"
                    -- 地区委托
                elseif select_fight:includes({ "地", "区", "委", "托" }) then
                    select_fight = "地区委托"
                    -- 诡异行商
                elseif select_fight:includes({ "诡", "异", "行", "商" }) then
                    select_fight = "诡异行商"
                    -- 得偿所愿
                elseif select_fight:includes({ "得", "偿", "所", "愿" }) then
                    select_fight = "得偿所愿"
                    -- 兴致盎然
                elseif select_fight:includes({ "兴", "致", "盎", "然" }) then
                    select_fight = "兴致盎然"
                else
                    log("不知道什么作战：" .. select_fight)
                    return
                end
                log("作战: " .. select_fight)
                return true
            end
        end, 5) then
        stop("不知道第一个作战是什么", 'cur')
        return
    end

    return select_fight
end

-- 水月肉鸽干员放置
mizuki_deploy = function(deploy_table)
    for i = 1, #deploy_table, 1 do
        if not wait(function()
                if findOne("干员费用够列表1") then return true end
                if not findOne("生命值") then
                    log("没找到生命值，继续等待")
                end
            end, 30) then
            return false
        end

        wait(function()
            tap("水月_干员费用够列表1")
            disappear("水月_干员费用够列表1", 0.5)
            nDeploy3(1, deploy_table[i], 4 - i)

            wait(function()
                if findOne("生命值") then return true end
                tap("开始行动1")
            end)

            if not appear("水月_干员费用够列表" .. 4 - i, 5) then return true end
        end, 20)
        if single_man_operation then break end
    end
end

-- 水月肉鸽重新校准路径
mizuki_repos_path = function()
    findTap("战略返回")
    local tgha_pos = mizuki_point.天光海岸[1] .. "|" ..
        mizuki_point.天光海岸[2] .. "|" ..
        mizuki_point.天光海岸[3]
    log("tgha_pos: ", tgha_pos)
    if not wait(function()
            if checkPointColor(mizuki_point.等待开始页面标题) then
                log("找到等待开始页面标题")
                return true
            end
        end, 5) then
        mizuki_restart("超时未找到等待开始页面标题")
    end
    wait(function()
        tap(mizuki_point.继续探索)
        if findOneStr(tgha_pos) then
            log("重置成功")
            return true
        end
    end, 5)
end

-- 水月肉鸽路径选择器
mizuki_path_selecter = function()
    local path_count = 0
    wait(function()
        local current = time()
        if findOne_interval > 0 and current - findOne_last_time > findOne_interval then
            findOne_last_time = time()
            -- log(500)
            -- releaseCapture()
            keepCapture()
        end
        -- 检查此次分支关卡数量
        for i = 1, 5 do
            local path_pos = mizuki_point.水月关卡坐标[i][1] .. "|" ..
                mizuki_point.水月关卡坐标[i][2]
            -- log("正在检测第" .. i .. "个路径")
            -- log("path_pos: ", path_pos)
            -- 关卡等级判断
            for k, t in ipairs({ "846BDE", "AC4F79", "131314", "17C7C8", "199B81" }) do
                local path_pos_color = path_pos .. "|" .. t
                local res = cmpColorEx(path_pos_color, 0.95)
                if res == 1 then
                    -- log("path_pos_color: ", path_pos_color)
                    if i < 4 then
                        path_count = 4 - i
                        return true
                    elseif i == 4 then
                        path_count = 2
                        return true
                    elseif i == 5 then
                        path_count = 1
                        return true
                    end
                end
            end
        end
    end, 5)
    log("当前分支数量 ", path_count)
    if path_count == 0 then
        log("没有找到路径")
        mizuki_repos_path()
        return mizuki_path_selecter()
    end
    return path_count
end

-- 水月肉鸽关卡类型判断器
mizuki_level_type = function(count)
    local res = {}
    local level = {}
    local currentDetectionTypeColor = nil

    -- 关卡坐标
    if count == 3 then
        level = {
            mizuki_point.水月关卡坐标[1], mizuki_point.水月关卡坐标[3],
            mizuki_point.水月关卡坐标[5],
        }
    elseif count == 2 then
        level = {
            mizuki_point.水月关卡坐标[2], mizuki_point.水月关卡坐标[4],
        }
    elseif count == 1 then
        level = { mizuki_point.水月关卡坐标[3] }
    end

    -- 关卡类型
    count = math.tointeger(count)
    for i = 1, count do
        -- log("第".. i .."个关卡类型判断")
        wait(function()
            for t, v in ipairs({
                "关卡等级_不期而遇", "关卡等级_普通",
                "关卡等级_行商", "关卡等级_紧急", "关卡等级_未选择",
            }) do
                currentDetectionTypeColor = mizuki_point[v]
                local pos = level[i][1] .. "|" .. level[i][2] .. "|" ..
                    currentDetectionTypeColor
                local ans = cmpColorEx(pos, 0.95)
                if ans == 1 then
                    res[i] = { level = t, pos = level[i] }
                    --  x偏移77 y偏移-114
                    local pos_key = level[i][1] + mizuki_point.偏移[1] .. "|" ..
                        level[i][2] - mizuki_point.偏移[2] .. "|FFFFFFF"
                    local ans_key = cmpColorEx(pos_key, 0.8)
                    if ans_key == 1 then
                        res[i]["key"] = true
                        log("第" .. i .. "个 " .. v .. " 有钥匙")
                    else
                        res[i]["key"] = false
                        log("第" .. i .. "个 " .. v)
                    end
                    return true
                end
            end
        end, 3)
    end

    -- log(res)
    return res
end

-- 水月肉鸽关卡判决器
mizuki_level_selecter = function(input_info)
    local info = input_info
    -- log("关卡判决器",info)

    if info == nil then
        log.warn("关卡判决器未传入参数")
        return false
    end

    -- 选择排序 info
    for i = 1, #info do
        local min = i
        for j = i + 1, #info do
            if info[j].level < info[min].level then min = j end
        end
        info[i], info[min] = info[min], info[i]
    end

    for i = 1, #info do
        if info[i].key then info[i], info[#info] = info[#info], info[i] end
    end

    -- 非单人作战的情况下尝试打紧急
    if not single_man_operation then
        -- 排序后检查是否只有紧急
        if info[1] ~= nil then
            if info[1].level == 4 then
                log("只有紧急, 重试")
                mizuki_restart("只有紧急, 重试")
                return false
            end
        end
    end

    -- 检查全是钥匙
    local key_count = 0
    local flag = false

    for k, v in pairs(info) do
        if not info[k].key then
            if wait(function()
                    tap(info[k].pos)
                    if waitUntilFindColor(mizuki_point.选中关卡, 1) then return true end
                end, 3) then
                log("进入关卡准备界面")
                flag = true
                break
            end
        else
            key_count = key_count + 1
        end
    end

    if flag then return true end

    if key_count == #info then
        log("全有钥匙, 重试")
        mizuki_restart("全有钥匙, 重试")
        return false
    end

    mizuki_repos_path()
    return mizuki_level_selecter(input_info)
end

-- 水月肉鸽骰子处理器(只处理必定出现的情况)
mizuki_dice_solve = function()
    ssleep(1)
    local pos = mizuki_point.投骰子确认[1] .. "|" ..
        mizuki_point.投骰子确认[2] .. "|" ..
        mizuki_point.投骰子确认[3]

    if not wait(function()
            if findOneStr(pos) then
                log("点击骰子确认")
                tap({ mizuki_point.投骰子确认[1], mizuki_point.投骰子确认[2] })
                return true
            end
        end, 10) then
        log.warn("骰子处理器未找到投骰子确认")
        return false
    end

    if not wait(function()
            if not findOne("战略帮助") then
                log("点击骰子确认 2次确认")
                tap({ mizuki_point.投骰子确认[1], mizuki_point.投骰子确认[2] })
            else
                return true
            end
        end, 10) then
        return false
    end

    log("骰子处理完成")
    return true
end

-- 水月肉鸽不期而遇处理器
mizuki_unexpect_solve = function()
    local select_unexpect = nil
    local unexpect_tag = mizuki_point.左侧标记[1] .. "|" ..
        mizuki_point.左侧标记[2] .. "|" ..
        mizuki_point.左侧标记[3]
    local unexpect_area = mizuki_point.不期而遇范围

    if not wait(function()
            -- 进入不期而遇
            log("尝试进入不期而遇")
            tap(mizuki_point.进入)
            if findOneStr(unexpect_tag, 0.9) then
                log.warn("已进入不期而遇")
                return true
            end
        end, 5) then
        return false
    end

    if not wait(function()
            setDict(0, "水月_不期而遇.txt") -- 字库需要放到资源文件中
            useDict(0)
            select_unexpect = ocr(unexpect_area[1], unexpect_area[2],
                unexpect_area[3], unexpect_area[4],
                "008AFF-215682", 0.90)
            if select_unexpect ~= nil then
                log(select_unexpect)
                return true
            end
        end, 5) then
        return false
    end

    if not wait(function()
            if #select_unexpect > 1 then
                -- 继承
                if select_unexpect:includes({ "继", "承" }) then
                    select_unexpect = "继承"
                    -- 噬尘扩散
                elseif select_unexpect:includes({ "噬", "尘", "扩", "散" }) then
                    select_unexpect = "噬尘扩散"
                    -- 天灾信使
                elseif select_unexpect:includes({ "天", "灾", "信", "使" }) then
                    select_unexpect = "天灾信使"
                    -- 悬高之葬
                elseif select_unexpect:includes({ "悬", "高", "之", "葬" }) then
                    select_unexpect = "悬高之葬"
                    -- 阴云如聚
                elseif select_unexpect:includes({ "阴", "云", "如", "聚" }) then
                    select_unexpect = "阴云如聚"
                    -- 远销海外
                elseif select_unexpect:includes({ "远", "销", "海", "外" }) then
                    select_unexpect = "远销海外"
                    -- 重返家园
                elseif select_unexpect:includes({ "重", "返", "家", "园" }) then
                    select_unexpect = "重返家园"
                    -- 狗眼婆娑
                elseif select_unexpect:includes({ "狗", "眼", "婆", "娑" }) then
                    select_unexpect = "狗眼婆娑"
                    -- 海嗣学者
                elseif select_unexpect:includes({ "嗣", "学", "者" }) then
                    select_unexpect = "海嗣学者"
                    -- 狂徒妄念
                elseif select_unexpect:includes({ "狂", "徒", "妄", "念" }) then
                    select_unexpect = "狂徒妄念"
                    -- 开端
                elseif select_unexpect:includes({ "开", "端" }) then
                    select_unexpect = "开端"
                else
                    log.warn("不期而遇识别失败")
                    return
                end
                log("不期而遇: " .. select_unexpect)
                return true
            end
        end, 5) then
        stop("不知道不期而遇是什么", 'cur')
        return false
    end

    -- local pos = mizuki_point[select_unexpect][1] .."|" .. mizuki_point[select_unexpect][2] .. "|" .. mizuki_point[select_unexpect][3]
    local pos_2 = {
        mizuki_point[select_unexpect][1], mizuki_point[select_unexpect][2],
    }
    local dicePos = mizuki_point.投骰子确认[1] .. "|" ..
        mizuki_point.投骰子确认[2] .. "|" ..
        mizuki_point.投骰子确认[3]

    if not wait(function()
            if not findOne("战略帮助") then
                log("点击选项")
                tap(pos_2)
                tap(pos_2)
                tap(pos_2)
                tap(pos_2)
                tap(pos_2)
                ssleep(0.1)
                -- 处理投骰子
                if select_unexpect == "重返家园" and findOneStr(dicePos) then return mizuki_dice_solve() end
                return false
            else
                return true
            end
        end, 5) then
        return false
    end

    log("不期而遇处理完成")
    return true
end

-- 水月地区委托处理器
mizuki_entrust_solve = function()
    local pos = mizuki_point.左侧清单[1] .. "|" ..
        mizuki_point.左侧清单[2] .. "|" ..
        mizuki_point.左侧清单[3]
    log("尝试进入地区委托")

    if not wait(function()
            if not findOneStr(pos) then
                tap(mizuki_point.进入)
            else
                return true
            end
        end, 5) then
        return false
    end
    log("成功进入地区委托")

    if not wait(function()
            if not findOne("战略帮助") then
                tap({ mizuki_point.关闭终端[1], mizuki_point.关闭终端[2] })
                ssleep(0.1)
            else
                return true
            end
        end, 5) then
        return false
    end
    log("地区委托完成")
    return true
end

-- 水月得偿所愿处理器
mizuki_wish_solve = function()
    local pos = mizuki_point.左侧标记[1] .. "|" ..
        mizuki_point.左侧标记[2] .. "|" ..
        mizuki_point.左侧标记[3]
    log("尝试进入得偿所愿")

    if not wait(function()
            if not findOneStr(pos) then
                tap(mizuki_point.进入)
            else
                return true
            end
        end, 5) then
        return false
    end
    log("成功进入得偿所愿")

    if not wait(function()
            if not findOne("战略帮助") then
                tap({ mizuki_point.消失的习俗[1], mizuki_point.消失的习俗[2] })
                ssleep(0.1)
                mizuki_dice_solve()
            else
                return true
            end
        end, 5) then
        return false
    end
    log("得偿所愿完成")
    return true
end

-- 水月兴致盎然处理器
mizuki_interesting_solve = function()
    local pos = mizuki_point.左侧标记[1] .. "|" ..
        mizuki_point.左侧标记[2] .. "|" ..
        mizuki_point.左侧标记[3]
    log("尝试进入兴致盎然")

    if not wait(function()
            if not findOneStr(pos) then
                tap(mizuki_point.进入)
            else
                return true
            end
        end, 5) then
        return false
    end
    log("成功进入兴致盎然")

    if not wait(function()
            if not findOne("战略帮助") then
                tap({ mizuki_point.现买现印[1], mizuki_point.现买现印[2] })
                ssleep(0.1)
            else
                return true
            end
        end, 5) then
        return false
    end
    log("兴致盎然完成")
    return true
end

-- 水月肉鸽托管战斗
mizuki_fight = function(firstFight)
    local now_fight = mizuki_fight_select()

    -- 不期而遇
    if now_fight == "不期而遇" then
        log("跳转到不期而遇")
        return mizuki_unexpect_solve()
    end

    -- 诡异行商
    if now_fight == "诡异行商" then
        log("跳转到诡异行商")
        return mizuki_buy()
    end

    -- 地区委托
    if now_fight == "地区委托" then
        log("跳转到地区委托")
        return mizuki_entrust_solve()
    end

    -- 得偿所愿
    if now_fight == "得偿所愿" then
        log("跳转到得偿所愿")
        return mizuki_wish_solve()
    end

    -- 兴致盎然
    if now_fight == "兴致盎然" then
        log("跳转到兴致盎然")
        mizuki_interesting_solve()
        return true
    end

    if not wait(function()
            if findOne("快捷编队") then return true end
            tap("进入")
        end, 10) then
        return false
    end

    if firstFight then
        if not wait(function()
                if findOne("确认招募") then return true end
                tap("快捷编队")
            end, 10) then
            return false
        end

        if not wait(function()
                if findOne("攻击范围") and
                    (zl_skill_idx ~= 2 or zl_skill_idx == 2 and
                        findOne("战略二技能")) then
                    if not single_man_operation then tap("近卫招募列表2") end
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
    end

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
        return false
    end

    -- 游戏界面
    if not wait(function()
            if findOne("单选确认框") then return true end
            if findOne("生命值") then return true end
        end, 30) then
        return false
    end

    if not findOne("生命值") then return false end

    -- 需要等等才能点两倍速
    appearTap("两倍速", 3)

    -- 部署干员到关卡位置
    mizuki_deploy(mizuki_point.deploy[now_fight])

    appear("生命值")

    local last_time_see_life = time()
    local skill_times = 0
    if not wait(function()
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
                tap({ p[1], p[2] + scale(200) })
                -- appear("技能ready", 5)
                appear("生命值蓝", 5)
                ssleep(0.5)
                wait(function()
                    tap("开技能")
                    if disappear("生命值蓝", 1) then return true end
                end)
            end
        end, 300) then
        return restartapp(appid)
    end

    appear({ "战略返回", "浪离灯熄" }, 30)
    if checkPointColor(mizuki_point.浪离灯熄) then
        mizuki_restart("战斗死亡")
        return false
    end
    if not findOne("战略返回") then return false end

    if not mizuki_after_fight() then
        log.warn("未能完成战斗后拾取")
        return false
    end
    log("完成一次战斗")
    return true
end

-- 水月肉鸽战斗后拾取
mizuki_after_fight = function()
    local getTheBooty = function(x)
        if checkPointColor(x) then tap({ x[1], x[2] }) end
    end
    if not wait(function()
            tap("战略确认")
            getTheBooty(mizuki_point["已领取所有奖励"])
            getTheBooty(mizuki_point["源石锭"])
            getTheBooty(mizuki_point["招募券"])
            getTheBooty(mizuki_point["收藏品"])
            getTheBooty(mizuki_point["目标生命"])
            getTheBooty(mizuki_point["投掷次数"])
            getTheBooty(mizuki_point["漂流秘匣"])

            -- 误触到招募券处理
            if findOne("确认招募") then
                -- 放弃招募
                if not zl_more_experience then
                    if not wait(function()
                            if not findOne("确认招募") then return true end
                            tap("放弃招募")
                        end, 5) then
                        return
                    end

                    if not wait(function()
                            if findOne("编队") then return true end
                            tap("右右确认")
                        end, 5) then
                        return
                    end
                else
                    -- 招募
                    if findOne("确认招募") then
                        local start_time = time()
                        if not wait(function()
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
                                tap("近卫招募列表" .. 1)
                                findTap("确认招募")
                                tap("开包skip")
                            end, 10) then
                            return
                        end
                    end
                end
            end

            if not findOne("战略返回") then
                if not appear({ "战略返回", "水月_战略帮助" }) then
                    tap("战略确认")
                end
            end
            -- if disappear("战略返回",0.5) then return true end
            if findAny({ "水月_常规行动", "水月_战略帮助" }) and
                not findOne("确认招募") then
                return true
            end

            if findOne("战略返回") and checkPointColor(mizuki_point.战略帮助) and not findOne("确认招募") then return true end
        end, 30) then
        return false
    end

    -- if not appear("战略返回", 5) then return end

    if not checkPointColor(mizuki_point.战略帮助) then
        log.debug()
        return false
    end
    log("完成拾取")
    return true
end

-- 水月肉鸽前往下一层
mizuki_goto_next_level = function()
    local pos = mizuki_point.投骰子确认[1] .. "|" ..
        mizuki_point.投骰子确认[2] .. "|" ..
        mizuki_point.投骰子确认[3]
    -- 去第二层
    log("诡意行商准备离开")
    if not wait(function()
            if findOneStr(pos) then return true end
            tap("诡意行商离开")
        end, 10) then
        return false
    end

    -- 处理投骰子
    log("处理诡意行商离开后的投骰子")
    if not mizuki_dice_solve() then return false end

    log("完成一轮")
    mizuki_restart("完成一轮")
    return true
end

-- 水月肉鸽行商购买
mizuki_buy = function()
    -- exit()
    local check_goods = function()
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

    local buy = function()
        log("正在购买")
        local p = appear(point["战略商品列表"], 1)
        p = findAny(point["战略商品列表"])
        if not p then
            log.warn("未找到任何商品")
            return
        end
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

    local coin = function()
        -- if not appear("诡意行商投资", 1) then return goto_next_level() end
        if not appear("诡意行商投资", 1) then
            log("本次无投币")
            return true
        end
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

        -- 超时改为60秒，有时会出现上限极高情况
        wait(function(reset_wait_start_time)
            -- 不能投情况
            if not findOne("诡意行商投资入口") then return true end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            if not findOne(coin_no_notification) then reset_wait_start_time() end

            -- 6秒后，如果底部投币提示没有，那就说明投币结束
            -- 能投但币不够或者已投满
            -- if time() - coin_start_time > 6000 and findOne(coin_no_notification) then
            --   return true
            -- end
            tap("诡意行商确认投资")
        end, 6)
    end

    if not wait(function()
            -- if not findOne("战略帮助") then return true end
            if findAny({ "诡意行商投资", "诡意行商离开" }) then
                log("处于行商商店中")
                return true
            end
            tap("进入")
        end, 3) then
        -- check_goods()
        -- goto_next_level()
        return false
    end

    log("检查商品")
    check_goods()

    if not zl_skip_coin then
        log("开始投币")
        coin()
    end

    if zl_more_experience then
        if not wait(function()
                if findOne("诡意行商离开") then return true end
                tap("开包skip")
            end, 5) then
            return
        end
        for i = 1, 10 do if not buy() then break end end
    end

    return mizuki_goto_next_level()
end

-- 水月肉鸽 从选择关卡开始处理
mizuki_start_from_select = function()
    -- 水月肉鸽当前分支数量
    mizuki_now_path_count = mizuki_path_selecter()

    mizuki_now_level_info = mizuki_level_type(mizuki_now_path_count)

    if not mizuki_level_selecter(mizuki_now_level_info) then
        log("进入选择的关卡时出现错误")
        return flase
    end

    if not mizuki_fight() then return flase end

    return true
end

path.水月与深蓝之树前瞻投资_旧 = function()
    mizuki_fight_time = mizuki_fight_time or 10
    log("开始水月肉鸽")
    log("检查浪离灯熄")
    if checkPointColor(mizuki_point.浪离灯熄) then
        wait(function()
            if findAny({ "水月_常规行动", "面板" }) then return true end
            if checkPointColor(mizuki_point.等待开始页面标题) then
                return true
            end
            tap({ 630, 597 })
        end, 30)
        -- return
    end

    -- 每8小时做日常
    log("检查每8小时做日常")
    if not zl_no_waste_last_time or time() - zl_no_waste_last_time > 8 * 3600 *
        1000 then
        -- 并非首次
        if zl_no_waste_last_time then
            log("非首次8小时日常")
            zl_no_waste_last_time = nil
            setControlBar()
            restart_account()
            -- saveConfig("hideUIOnce", "true")
            -- save_extra_mode(extra_mode, extra_mode_multi)
            -- restartPackage()
        end

        -- 首次
        if zl_no_waste then
            log("首次做日常")
            setControlBar()
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
            running = "水月与深蓝之树"
            zl_no_waste_last_time = time()
            -- mizuki_navigation()
            -- return false
        end

        zl_no_waste_last_time = time()
    end

    local in_fight_return = ''

    local jumpout
    log("检查是否在关内")
    if findOne("战略返回") then
        tap("战略返回")
        appear("水月_常规行动", 2)
    end

    log("检查是否在暂停")
    if findOne("暂停中") and findOne("生命值") then
        restartapp(appid)
        return false
    end

    log("导航到水月肉鸽")
    if mizuki_navigation() then
        log("水月肉鸽导航成功")
    else
        log.warn("水月肉鸽导航失败")
        return false
    end

    log("检查等级")
    if zl_level_enough then
        if zl_no_waste then
            -- todo
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end
        stop("等级已满，肉鸽结束", '', false, true)
        return false
    end

    log("检查投币")
    if zl_coin_enough then
        if zl_no_waste then
            -- todo
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end
        stop("投币已满，肉鸽结束", '', false, true)
        return false
    end

    -- 检测等级
    local zl_level_check = function()
        if not (str2int(zl_max_level, 0) > 0) then return false end
        if not checkPointColor(mizuki_point.等待开始页面标题) then
            log.warn("未找到水月常规行动")
            return false
        end

        -- if not wait(function()
        --   if not findOne("水月_常规行动") then return true end
        --   tap("战略等级入口")
        -- end) then return end

        log("开始识别等级")

        local x = nil

        local handle = createOcr()
        if handle ~= nil then
            local text = ocrTextEx(handle, mizuki_point.战略等级[1],
                mizuki_point.战略等级[2],
                mizuki_point.战略等级[3],
                mizuki_point.战略等级[4])
            if text ~= nil then
                text = text:gsub(" ", "")
                text = text:gsub("O", "0")
                text = text:gsub("l", "1")
                x = str2int(text:match("%d+"))
                log("识别结果：" .. text)
                log("战略等级：" .. x)
            else
                x = -1
            end
            releaseOcr(handle)
        end

        -- if x == 125 and not findOne("战略等级" .. x) then return end
        if x >= 0 and x <= 155 then
            log("识别等级成功")
            return x
        else
            log.warn("识别等级失败")
            return false
        end
    end

    log("检测等级")
    local zl_level = zl_level_check() or -1
    log("等级：" .. zl_level .. "/" .. zl_max_level)
    if not zl_level_enough and zl_level == str2int(zl_max_level, 10000) then
        zl_level_enough = true
        captureqqimagedeliver("INFO", "肉鸽任务完成",
            table.join(qqmessage, ' ') .. " " ..
            (zl_level or '') .. "等级已满")
    end

    -- 检测源石锭
    local zl_coin_check = function()
        if not (str2int(zl_max_coin, 0) > 0) then return end
        if str2int(zl_max_coin, 0) >= 1000 then return end

        if not checkPointColor(mizuki_point.等待开始页面标题) then
            log.warn("未找到水月常规行动")
            return false
        end

        if not wait(function()
                if not checkPointColor(mizuki_point.等待开始页面标题) then return true end
                tap(mizuki_point.战略源石锭入口)
            end) then
            return
        end

        local prex = -1
        local ans = wait(function()
            ssleep(.5)
            -- if not findOne("水月_常规行动") then return 0 end
            local x = ocr("战略源石锭") or {}
            log.debug(x)
            x = (x[1] or {}).text or ""
            x = number_ocr_correct(x)
            x = str2int(x:match("[^%d](%d+)$"), -1)
            log.debug(x)
            if x >= 0 and x == prex then return x end
            -- if x >= 0 then return x end
            prex = x
        end, 5)
        wait(function()
            tap("返回")
            if waitUntilFindColor(mizuki_point.等待开始页面标题) then return true end
        end, 5)
        if ans ~= nil and type(ans) == "number" then
            ans = ans % 1000
        end
        return ans
    end

    log("检测源石锭")
    local zl_coin = zl_coin_check() or -1
    log("源石锭：" .. zl_coin .. "/" .. zl_max_coin)
    if not zl_coin_enough and zl_coin >= str2int(zl_max_coin, 10000) then
        zl_coin_enough = true
        captureqqimagedeliver("INFO", "肉鸽任务完成",
            table.join(qqmessage, ' ') .. " " .. (zl_coin or '') ..
            "源石锭已满")
    end

    -- 等级/源石锭 阶段性通知
    log("等级/源石锭 阶段性通知")
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

    -- 放弃探索
    log("检测放弃探索")
    if checkPointColor(mizuki_point.放弃探索) then
        if not wait(function()
                if findOne("返回确认界面") then return true end
                tap("放弃本次探索")
            end, 5) then
            log.debug()
            -- 无法直接放弃的情况 不处理
            if not wait(function()
                    if not checkPointColor(mizuki_point.等待开始页面标题) then return true end
                    tap("继续探索")
                    ssleep(.5)
                    log.debug()
                end, 5) then
                return
            end

            if not wait(function()
                    if checkPointColor(mizuki_point.等待开始页面标题) then return true end
                    -- 第一次数据更新处理
                    if findAny({
                            "面板", "活动公告返回", "签到返回", "签到返回黄",
                            "开始唤醒", "bilibili_framelayout_only",
                        }) then
                        jumpout = true
                        return true
                    end
                    log("放弃探索")
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
                if not checkPointColor(mizuki_point.放弃探索) then
                    return true
                end
                -- 第一次数据更新处理
                if findAny({
                        "面板", "活动公告返回", "签到返回", "签到返回黄",
                        "开始唤醒", "bilibili_framelayout_only",
                    }) then
                    jumpout = true
                    return true
                end
            end, 30) then
            return false
        end
    end
    if jumpout then
        log("水月强制跳出1")
        return false
    end

    -- 等级满了，放弃行动后回到首页再截个图
    if zl_level_enough or zl_coin_enough then
        -- wait(function(reset_wait_start_time)
        --   if not findOne("水月_常规行动") then return true end
        --   tap("战略确认")
        -- end,5)

        captureqqimagedeliver("INFO", "肉鸽行动结束",
            table.join(qqmessage, ' ') .. " 放弃行动后")

        wait(function(reset_wait_start_time)
            if checkPointColor(mizuki_point.等待开始页面标题) then return true end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            tap("战略确认")
        end, 5)
        return false
        -- return path.fallback.签到返回()
    end

    -- 点认知塑造后继续
    -- if not lighter_enough and not zl_disable_lighter and mizuki_fight_time >= 10 then
    --     if mizuki_cognition() then
    --         return path.水月与深蓝之树前瞻投资()
    --     end
    -- end

    log("开始探索")
    if not wait(function(reset_wait_start_time)
            if findOne("战略返回") then return true end
            -- 第二次数据更新处理
            if findAny({
                    "面板", "活动公告返回", "签到返回", "签到返回黄",
                    "开始唤醒", "bilibili_framelayout_only",
                }) then
                jumpout = true
                return true
            end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            tap("战略确认")
            tap("继续探索")
        end, 20) then
        -- 初始选难度
        tap("战略难度列表" .. (zl_more_experience and "2" or "1"))
        -- 点认知塑造后继续
        if not lighter_enough and not zl_disable_lighter then
            if mizuki_cognition() then
                return path.水月与深蓝之树前瞻投资()
            end
        end
        return false
    end
    if jumpout then
        log("水月强制跳出2")
        return false
    end

    -- 选择分队
    log("选择分队")
    tapUntilCheckedPointColor(mizuki_point.指挥分队,
        mizuki_point.招募组合进度条,
        "点击近卫分队", 0.5)

    log("选择招募")
    tapUntilCheckedPointColor(mizuki_point.取长补短,
        mizuki_point.初始招募进度条,
        "点击取长补短")

    log("开始选人")
    log("不招辅助")
    if not wait(function()
            if findOne("确认招募") then return true end
            if findOne("剿灭说明") then tap("剿灭说明") end
            tap("辅助招募券")
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
            -- if findOne("水月_初始招募") then return true end
            if checkPointColor(mizuki_point.初始招募进度条) then return true end
        end, 10) then
        return false
    end

    log("招募近卫")
    if not wait(function()
            tap("近卫招募券")
            tap("招募说明关闭")
            -- if not findOne("水月_初始招募") and findOne("确认招募") then
            --     return true
            -- end
            if not checkPointColor(mizuki_point.初始招募进度条, 0.98) and findOne("确认招募") then
                return true
            end
        end, 10) then
        return false
    end

    if not waitUntilFindColor(mizuki_point.选择助战按钮) then return false end

    if not wait(function()
            if findAny({ "水月_初始招募", "战略返回" }) then
                log.debug()
                return true
            end
            if findOne("返回确认界面") then
                log.debug()
                -- 虽然不知道会不会走这儿
                tap("左取消")
                disappear("返回确认界面")
                -- 不等会怎么样呢，有时会闪
                ssleep(.5)
            end
            log.debug(zl_best_operator)
            local idx = str2int(zl_best_operator, -1)

            if idx >= 1 and idx <= 12 then
                -- 指定
                tap("近卫招募列表" .. (zl_best_operator or 1))
                findTap("确认招募")
                tap("开包skip")
            elseif idx == -1 then
                -- 助战自动
                mizuki_help_fight()
            else
                stop("请设置近卫干员序号(1~12)", '', true, false)
            end
        end, 10) then
        return false
    end

    if not single_man_operation then
        log("招募医疗")
        if not wait(function()
                tap("医疗招募券")
                tap("招募说明关闭")
                if not checkPointColor(mizuki_point.初始招募进度条, 0.98) and findOne("确认招募") then
                    return true
                end
            end, 10) then
            return false
        end

        if not waitUntilFindColor(mizuki_point.选择助战按钮) then return false end

        if not wait(function()
                if checkPointColor(mizuki_point.偏左战略返回) then
                    log("医疗干员选完")
                    return true
                end
                if findOne("返回确认界面") then
                    log.debug()
                    -- 虽然不知道会不会走这儿
                    tap("左取消")
                    disappear("返回确认界面")
                    -- 不等会怎么样呢，有时会闪
                    ssleep(.5)
                end

                -- 借用近卫坐标
                tap("近卫招募列表" .. 1)
                findTap("确认招募")
                tap("开包skip")
            end, 10) then
            return false
        end
    else
        log("不招募医疗")
        if not wait(function()
                tap("医疗招募券")
                tap("招募说明关闭")
                if not checkPointColor(mizuki_point.初始招募进度条, 0.98) and findOne("确认招募") then
                    return true
                end
            end, 10) then
            return false
        end

        if not waitUntilFindColor(mizuki_point.选择助战按钮) then return false end

        if not wait(function()
                if checkPointColor(mizuki_point.偏左战略返回) then
                    log("医疗干员选完")
                    return true
                end
                if findOne("返回确认界面") then
                    log.debug()
                    -- 虽然不知道会不会走这儿
                    tap("右右确认")
                    disappear("返回确认界面")
                    -- 不等会怎么样呢，有时会闪
                    ssleep(.5)
                end

                findTap("确认招募")
                tap("开包skip")
            end, 10) then
            return false
        end
    end

    -- 选医疗干员的时候可能点太快已经进地图了
    -- todo 处理没有进地图的情况 手动再点一下

    -- 检查是否进入水月正式作战
    if not waitUntilFindColor(mizuki_point.天光海岸) then return false end

    log("进入第一关作战")
    if not wait(function()
            tap(mizuki_point.第一关)
            tap(mizuki_point.第一关)
            tap(mizuki_point.第一关)
            if waitUntilFindColor(mizuki_point.选中关卡) then return true end
        end) then
        in_fight_return = "无法进入作战"
        return mizuki_restart("无法进入作战")
    end

    local firstFight = true
    -- 第一关作战
    if not mizuki_fight(firstFight) then
        log("第一关作战出现问题")
        return flase
    end

    for i = 1, 4 do if not mizuki_start_from_select() then break end end
end

--水月肉鸽战斗后拾取战利品
mizuki_fight_after = function()
    local drop_page = false
    if not wait(function()
            if not drop_page then tap("战略确认") end
            if findOne("水月_战略帮助") then drop_page = true end
            local x = appear({
                "水月_源石锭收下", "水月_投资次数收下", "水月_招募券收下",
                "水月_目标生命收下", '水月_收藏品收下', '水月_用武器砸'
            })
            log.debug(x)
            tap(x)
            -- if x == '萨米_密文版拾取' then
            --     appear('萨米_密文版选择左', 1)
            --     findTap('萨米_密文版选择左')
            -- end

            -- 误触到招募券处理
            if findOne("确认招募") then
                -- 放弃招募
                if zl_only_coin then
                    if not wait(function()
                            if not findOne("确认招募") then return true end
                            tap("放弃招募")
                        end, 5) then
                        return
                    end

                    if not wait(function()
                            if findOne("编队") then return true end
                            tap("右右确认")
                        end, 5) then
                        return
                    end
                else
                    -- 招募
                    if findOne("确认招募") then
                        local start_time = time()
                        if not wait(function()
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
                                tap("近卫招募列表" .. 1)
                                findTap("确认招募")
                                tap("开包skip")
                            end, 10) then
                            return
                        end
                    end
                end
            end

            if not findOne("战略返回") then
                if not appear({ "战略返回", "水月_战略帮助" }) then
                    tap("战略确认")
                end
            end
            if findAny({ "水月_常规行动", "水月_战略帮助" }) and not findOne("确认招募") then
                return true
            end
        end, 20) then
        return false
    end
    return true
end

--水月不期而遇处理
--水月_骰子确认
mizuki_event_solve = function()
    --判断不期而遇事件，并处理
    log('水月 处理不期而遇事件')
    --水月的事件处理，需要点击骰子，所以单独弄
    local zl_event_solve = function(xx)
        local xx = xx or 1
        local tttap = time()
        log('不期而遇事件处理：' .. xx)
        if not wait(function(reset_wait_start_time)
                if time() - tttap > 1.5 * 1000 and findOne('水月_骰子确认') then
                    tap('水月_骰子确认')
                    tttap = time()
                end
                if findOne("正在提交反馈至神经") then
                    reset_wait_start_time()
                end
                if findOne('水月_战略帮助') then return true end
                tap("水月_不期而遇选项点击列表" .. xx)
            end, 15, .2) then
            return false
        end
        return true
    end
    if not wait(function()
            local x = function()
                local incident
                if not wait(function()
                        incident = ocr("水月_不期而遇事件名字检测")
                        if incident[1] then return true end
                        tap('战略确认')
                        if findOne("水月_战略帮助") then return true end
                    end, 5, .3) then
                    return false
                end
                if not incident[1] then return false end
                local str = incident[1].text
                log('事件名字：', str)
                if string.finds(str, { '郁金香' }) then
                    if zl_event_solve(4, '水月_战略帮助') then return true end
                elseif string.finds(str, { '狂徒妄念', '家园' }) then
                    if zl_event_solve(3, '水月_战略帮助') then return true end
                elseif string.finds(str, { '开端', '海外', '学者', '扩散', '狗眼', '现买' }) then
                    if zl_event_solve(2, '水月_战略帮助') then return true end
                elseif string.finds(str, { '继承', '如聚', '天灾', '悬高' }) then
                    if zl_event_solve(1, '水月_战略帮助') then return true end
                end
            end
            if x() then return true end
            if findOne("水月_战略帮助") then return true end
        end, 30) then
        return false
    end
    return true
end

path.水月与深蓝之树前瞻投资 = function()
    log('水月与深蓝之树前瞻投资 start')
    if findOne("水月_浪离灯熄") then
        wait(function(reset_wait_start_time)
            if not disappear({ "水月_常规行动", "面板" }, 1) then
                return true
            end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            tap("战略确认")
        end, 15)
        return
    end

    -- 肉鸽每8小时做日常
    zl_eight_daily()

    local in_fight_return = ""
    local restart = function()
        toast(in_fight_return or "重开")
        ssleep(2)
        if not request_memory_clean() then
            path.水月与深蓝之树前瞻投资(true)
        else
            path.跳转("首页")
        end
    end
    local jumpout
    if findOne("战略返回") then path.fallback.战略返回其他肉鸽() end
    if findOne("暂停中") and findOne("生命值") then restartapp(appid) end

    --通用  先导航到常规行动
    zl_navigation('水月_常规行动', '水月与深蓝之树进入主题')

    --通用 肉鸽 等级源石锭检查
    -- 水月肉鸽完成 = zl_level_coin_inquire('水月_常规行动', '水月_等级检测范围', '水月_源石锭检测范围')
    -- if 水月肉鸽完成 then
    --     return
    -- end

    --通用  放弃探索
    if not zl_abandon_explore('水月') then return end
    if jumpout then return end

    -- 等级满了，放弃行动后回到首页再截个图
    if zl_level_enough or zl_coin_enough then
        captureqqimagedeliver("INFO", "肉鸽行动结束", table.join(qqmessage, " ") .. " 放弃行动后")
        wait(function(reset_wait_start_time)
            if not disappear("水月_常规行动") then
                return true
            end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            tap("战略确认")
        end, 5)
        return
    end
    log.debug()

    -- 开始探索
    local tt = time()
    if not wait(function(reset_wait_start_time)
            if findOne("战略返回") then return true end
            -- 第二次数据更新处理
            if time() - tt > 1000 and findOne("水月_难度确认") then --间隔点击一次，第一次作战需要选择难度
                tap("水月_难度确认")
                disappear("水月_难度确认")
                tt = time()
            end
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
        return
    end
    if jumpout then return end

    local first_time_see_first_card = 0
    if not wait(function(reset_wait_start_time)
            if findOne("水月_初始招募") then
                return true
            end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            tap("战略确认")
            tap("战略确认")
            tap("战略确认")
            if findOne("水月_指挥分队") then
                if first_time_see_first_card == 0 then
                    first_time_see_first_card = time()
                end
                if time() - first_time_see_first_card > 2000 then
                    tap("水月_指挥分队1")
                    appear("水月_指挥分队确认", 1)
                    ssleep(0.5)
                    tap("水月_指挥分队确认")
                    disappear("水月_指挥分队确认")
                    first_time_see_first_card = 0
                end
            else
                first_time_see_first_card = 0
            end
        end, 10) then
        return
    end

    --放弃辅助
    if not zl.放弃招募辅助('水月') then return end

    --招募近卫
    if not zl.招募近卫('水月') then return end

    --招募医疗
    if not zl.招募医疗('水月') then return end

    if not appear("水月_初始招募") then return end
    log.debug()

    -- 进入探索 必须分为两段，否则产生位移
    if not wait(function()
            if not findOne("水月_初始招募") then return true end
            tap("进入古堡")
        end, 5) then
        return
    end
    log.debug()
    -- if not appear("战略帮助", 10) then return end

    --点击进入探索之后，有一段时间的加载界面，需要点击
    local xtime = time()
    if not wait(function()
            if findOne("战略返回") then return true end
            tap("战略确认")
            --第一次会弹出‘战略帮助’那个界面
            if time() - xtime > 1.5 * 1000 then
                xtime = time()
                tap("招募说明关闭")
                ssleep(.5)
            end
        end, 15) then
        return
    end

    --延迟一会，否则会产生位移，
    --未做线路优化  后续的延迟可以拿来后续做线路优化的筛选
    --其实只要优化出  第一关走下面还是走上面就可以
    --目前默认选择上面的线路
    ssleep(1)

    if not wait(function()
            tap("水月_第一次作战上")
            if appear("水月_战斗进入前界面", 1) then
                return true
            end
        end, 5) then
        in_fight_return = "无法进入第一次作战"
        return restart(in_fight_return)
    end

    --检查作战关卡名字
    if not zl.fight_name_ocr('水月') then return end
    toast(now_fight_name)
    if now_fight_name == '互助' then
        return restart('互助 打不过溜了溜了')
    end
    ssleep(.5)

    --通用的  肉鸽的第一次作战编队 直接引用就可以
    zl.first_edit_team()

    ::mizuki_fight::
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
    zl_deploy2(point.水月作战关卡[now_fight_name])

    appear("生命值")

    local last_time_see_life = time()
    local skill_times = 0
    local zl_level = zl_level or -1
    local jump = false
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
                log('5s未发现')
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
                wait(function()
                    tap("开技能")
                    if disappear("生命值蓝", 1) then return true end
                end)
                ssleep(2) --开完技能延迟一会，不然像送葬人这种会马上关闭了
            end
        end, 300) then
        return restartapp(appid)
    end

    appear({ "战略返回", "水月_浪离灯熄", '水月_联系中断' }, 20)
    if findOne("水月_浪离灯熄") then
        log('浪离灯熄界面，准备返回')
        return
    end
    if findOne("水月_生态谱系") then
        log('水月_生态谱系')
        wait(function()
            tap("战略确认")
            if findOne("水月_常规行动") then return true end
        end, 8)

        return
    end
    if findOne("水月_联系中断") then
        log('水月_联系中断')
        tap("战略确认")
        appear({ "水月_浪离灯熄", '水月_常规行动' }, 8)
        return
    end
    if not findOne("战略返回") then return end

    if not mizuki_fight_after() then return restart("未能完成战斗后拾取") end

    log("完成一次战斗")

    ::fight_select_mizuki::
    log('在选择节点界面')
    local idxs = -1
    local idxs, maxIndex = zl.selection_node(0, '水月')
    --如果maxIndex是1 2 则是战斗关卡   3 4 是不期而遇
    if not idxs then return end
    log('idxs:', idxs, ' maxIndex:', maxIndex)
    if idxs > 0 then
        log(idxs, maxIndex)
        tap(point['水月_关卡节点坐标列表' .. idxs])
        ssleep(.5)
    end

    if maxIndex == 1 or maxIndex == 2 then
        --进入战斗
        log("进入战斗")
        --识别关卡名字
        if not zl.fight_name_ocr('水月') then return end
        toast(now_fight_name)
        if now_fight_name == '互助' then
            return restart('互助 打不过溜了溜了')
        end
        ssleep(.5)

        --进入编队界面
        if not wait(function()
                if findOne("快捷编队") then return true end
                tap("进入")
            end, 10) then
            return
        end

        goto mizuki_fight
    elseif maxIndex == 3 or maxIndex == 4 then
        --进入不期而遇
        log("进入不期而遇")
        ssleep(0.5)
        wait(function()
            tap("进入")
            if not findOne("水月_战略帮助") then return true end
        end, 2)

        if not mizuki_event_solve() then return end

        goto fight_select_mizuki
    elseif maxIndex == 5 and idxs ~= 3 then
        log('得偿所愿这些')
        ssleep(.5)
        wait(function()
            tap('进入')
        end, 3, .3)
        if findOne("水月_战略帮助") then
            return restart('钥匙不足，准备重开')
        end
        --如果钥匙够，那么是进入看事件，需要去到不期而遇事件处理那里，解决这个事件
        if not mizuki_event_solve() then return end
        goto fight_select_mizuki
    elseif idxs == 3 and maxIndex == 5 then
        log('准备进入商店')

        local goto_next_level = function()
            local tt = time()
            wait(function()
                if not findOne("战略返回") then return true end
                if time() - tt > 1.5 * 1000 then
                    tap("水月_骰子确认")
                    tt = time()
                end
                tap("诡意行商离开")
            end, 10)
            wait(function()
                if findOne("战略返回") then
                    tap("战略返回")
                    ssleep(1)
                    if findOne("水月_常规行动") then return true end
                end
                tap("水月_骰子确认")
                tap("水月_进入第二层中间点击位置")
            end, 15, .1)

            -- local tt = time()
            -- wait(function()
            --     if findOne("战略返回") then return true end
            --     if time() - tt > 1.5 * 1000 then
            --         tap("水月_骰子确认")
            --         tt = time()
            --     end
            --     tap("诡意行商离开")
            -- end, 10)
            -- appear('战略返回')
            -- findTap('战略返回')
            -- appear('水月_常规行动', 5)
        end

        -- 商店
        wait(function()
            tap("进入")
        end, 2)

        if not zl_skip_coin then zl_shop_coin() end
        if zl_only_coin then
            log('只是投币，准备退出')
            findTap('战略退出')
            appear('水月_放弃本次探索', 3)
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
end
