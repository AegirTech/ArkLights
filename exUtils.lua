-- ===========================================
--          额外工具类函数
-- 请所有贡献者在此处添加额外需要的函数
--
-- 函数命名规范推荐
--  1. 工具 --> 小驼峰
--  2. 类path函数 --> 下划线
--  3. 禁止重载utils.lua中已有的函数，避免污染
--
-- 函数注解
--  请在函数上方添加注解，尽可能的说明函数用途
-- ===========================================


-- 以字符串格式找色
findOneStr = function(x, confidence)
    -- 每5秒确认游戏在前台
    -- if (time() - findOne_game_up_check_last_time > 5000) then
    --     findOne_game_up_check_last_time = time()
    --     wait_game_up()
    -- end

    confidence = confidence or default_findcolor_confidence

    if type(x) == "string" then
        -- 控制截图频率
        local current = time()
        if findOne_interval > 0 and current - findOne_last_time > findOne_interval then
            findOne_last_time = time()
            keepCapture()
        end

        local pos

        if cmpColorEx(x, confidence) == 1 then
            pos = { str2int(x:match("^(%d+)|"), 0), str2int(x:match("^%d+|(%d+)|"), 0) }
        end

        return pos
    end
end

-- 单点找色
checkPointColor = function(pInfo, confidence)
    -- 每5秒确认游戏在前台
    -- if (time() - findOne_game_up_check_last_time > 5000) then
    --     findOne_game_up_check_last_time = time()
    --     wait_game_up()
    -- end

    confidence = confidence or default_findcolor_confidence

    -- 控制截图频率
    local current = time()
    if findOne_interval > 0 and current - findOne_last_time > findOne_interval then
        findOne_last_time = time()
        keepCapture()
    end

    if type(pInfo) == "table" then
        colorStr = pInfo[1] .. "|" .. pInfo[2] .. "|" .. pInfo[3]
    elseif type(pInfo) == "string" then
        colorStr = pInfo
    end

    -- 比色
    if cmpColorEx(colorStr, confidence) == 1 then
        return true
    else
        return false
    end
end

-- 等待单点颜色出现
waitUntilFindColor = function(pInfo, time)
    local time = time or 5
    return wait(function()
        if checkPointColor(pInfo) then
            return true
        end
    end, time)
end

-- 持续点击直到找到指定颜色
tapUntilCheckedPointColor = function(pTap, pInfo, msg, sleep, time)
    log(msg)
    local sleep = sleep or 0
    local time = time or 5
    if wait(function()
            if checkPointColor(pInfo) then
                log(msg, "成功")
                return true
            end
            tap({ pTap[1], pTap[2] })
            ssleep(sleep)
        end, time) then
        return true
    else
        log("持续点击直到找到指定颜色失败")
        return false
    end
end

doIfCheckedColor = function(pInfo, func, time)
    time = time or 15
    if checkPointColor(pInfo) then
        wait(function()
            return func()
        end, time)
    end
end

tapIfCheckedColor = function(pTap, pInfo)
    doIfCheckedColor(pInfo,
        function()
            tap({ pTap[1], pTap[2] })
            return true
        end)
end

-- 新deploy3 原deploy3有计算bug
-- src: 从右数第几个干员
-- dst: 目标位置，格式{x,y,direction} direction: 上1 右2 下3 左4
-- total: 当前有几个干员，不同干员数影响干员位置
nDeploy3 = function(src, dst, total)
    total = total or 1
    local max_op_width = scale(178) --  in loose mode, each operator's width
    local x1
    if total * max_op_width > screen.width then
        -- tight
        max_op_width = screen.width // total
        x1 = src * max_op_width - max_op_width // 2
    else
        -- loose
        -- x1 = screen.width - (total - src) * max_op_width - max_op_width // 2
        x1 = screen.width - src * max_op_width + max_op_width // 2
    end
    deploy(x1, dst[1], dst[2], dst[3])
end

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
        log("助战也找不到所需干员")
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
                    select_fight = matrixOcr(mizuki_point.水月关卡标题坐标1[1],
                        mizuki_point.水月关卡标题坐标1[2],
                        mizuki_point.水月关卡标题坐标1[3],
                        mizuki_point.水月关卡标题坐标1[4],
                        "FFFFFF", 0.90)
                    if select_fight ~= nil then
                        log(select_fight)
                        return true
                    end
                    -- 不期而遇/地区委托/诡异行商
                    select_fight = matrixOcr(mizuki_point.水月关卡标题坐标2[1],
                        mizuki_point.水月关卡标题坐标2[2],
                        mizuki_point.水月关卡标题坐标2[3],
                        mizuki_point.水月关卡标题坐标2[4],
                        "FFFFFF", 0.90)
                    if select_fight ~= nil then
                        log(select_fight)
                        return true
                    end
                    -- 紧急战斗识别区域
                    select_fight = matrixOcr(mizuki_point.水月关卡标题坐标3[1],
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
        log("关卡判决器未传入参数")
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
        log("骰子处理器未找到投骰子确认")
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
                log("已进入不期而遇")
                return true
            end
        end, 5) then
        return false
    end

    if not wait(function()
            setDict(0, "水月_不期而遇.txt") -- 字库需要放到资源文件中
            useDict(0)
            select_unexpect = matrixOcr(unexpect_area[1], unexpect_area[2],
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
                    log("不期而遇识别失败")
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
        log("未能完成战斗后拾取")
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
        log(2873)
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
            log("未找到任何商品")
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

-- 沙中之火 导航
sandfire_navigation = function()
    log("沙中之火 导航")
    -- if not checkPointColor(sandfire_point.奖励) and not checkPointColor(sandfire_point.进入演算开启状态) then

    -- end
    path.跳转("首页")

    tap(global_point.活动2)
    if not appear("主页") then return false end

    if not tapUntilCheckedPointColor(global_point.面板主活动, sandfire_point.奖励) then return false end

    if not checkPointColor(sandfire_point.进入演算开启状态) then return false end

    return true
end

-- 沙中之火 检查放弃
sandfire_check_giveup = function()
    waitUntilFindColor(sandfire_point.进入演算开启状态)
    ssleep(0.5)
    log("沙中之火 检查放弃")
    if checkPointColor(sandfire_point.放弃区域) then
        log("需要放弃")
        wait(function()
            if not checkPointColor(sandfire_point.放弃快进) then
                tap({ sandfire_point.放弃区域[1], sandfire_point.放弃区域[2] })
                tap(sandfire_point.放弃确认)
            else
                log("沙中之火 放弃完成")
                tap({ sandfire_point.放弃快进[1], sandfire_point.放弃快进[2] })
                if checkPointColor(sandfire_point.进入演算开启状态) then
                    return true
                end
            end
        end, 5)
    else
        log("沙中之火 检查放弃完成")
        if checkPointColor(sandfire_point.进入演算开启状态) then
            return true
        end
    end
end

-- 沙中之火 编队初始化
sandfire_init_fight_group = function()
    log("等待初始化干员")
    tapUntilCheckedPointColor(sandfire_point.进入演算, sandfire_point.初始化选择干员, "等待初始化干员"
    , 0.1)
    tapUntilCheckedPointColor(sandfire_point.初始化选择干员, sandfire_point.干员卡空白区域4)
    log("选择第一个干员")
    tapUntilCheckedPointColor(sandfire_point.干员卡空白区域1, sandfire_point.干员卡技能白条, "选择干员"
    , 0.1)
    log("选择确认")
    tapUntilCheckedPointColor(sandfire_point.干员选择确认, sandfire_point.干员卡外部区域1)
    log("全队补充")
    tapUntilCheckedPointColor(sandfire_point.全队补充, sandfire_point.退出, "全队补充", 0.1, 30)
    waitUntilFindColor(sandfire_point.退出)
    log("初始化完成")
end

-- 沙中之火 缩放地图
sandfir_zoom_map = function()
    showControlBar(false)
    tapUntilCheckedPointColor(sandfire_point.缩放地图, sandfire_point.缩放地图进度, "缩放地图", 0.2, 10)
    showControlBar(true)
end

-- 沙中之火 进入作战
sandfir_enter_fight = function()
    sandfir_zoom_map()
    if not wait(function()
            return tapUntilCheckedPointColor(sandfire_point.作战关卡, sandfire_point.作战信息, "选择作战",
                0.3)
        end, 5) then
        -- exit()
        return false
    end
    return true
end

-- 沙中之火 关卡内作战（退出）
sandfir_fight = function()
    if not sandfir_enter_fight() then
        return false
    end

    tapUntilCheckedPointColor(sandfire_point.作战开始, sandfire_point.开始行动)
    tapUntilCheckedPointColor(sandfire_point.开始行动, sandfire_point.作战暂停, "等待作战暂停出现", 0.3,
        30)
    tapUntilCheckedPointColor(sandfire_point.作战暂停, sandfire_point.作战已暂停, "按出暂停", 0.3, 10)
    tapUntilCheckedPointColor(sandfire_point.离开作战, sandfire_point.确认离开, "按出离开", 0.3, 10)
    -- if not wait(function()
    --     tap(sandfire_point.离开作战)
    --     ssleep(0.3)
    --     if checkPointColor(sandfire_point.确认离开) and checkPointColor(sandfire_point.取消确认离开)
    --         and checkPointColor(sandfire_point.离开当前区域) then
    --         return true
    --     end
    -- end, 10) then
    --     -- exit()
    --     return false
    -- end
    tapUntilCheckedPointColor(sandfire_point.确认离开, sandfire_point.行动结束)
    tapUntilCheckedPointColor(sandfire_point.结算空白区域, sandfire_point.驻扎地)
    return sandfir_next()
end

-- 沙中之火 下一天
sandfir_next = function()
    if not wait(function()
            if checkPointColor(sandfire_point.跳过) then
                tap({ sandfire_point.跳过[1], sandfire_point.跳过[2] })
            end
            if checkPointColor(sandfire_point.取消进入下一关) then
                tap({ sandfire_point.取消进入下一关[1], sandfire_point.取消进入下一关[2] })
            end
            if checkPointColor(sandfire_point.驻扎地) then
                return true
            end
        end, 10) then
        return false
    end
    if checkPointColor(sandfire_point.下一天紧急) then
        return true
    end
    if checkPointColor(sandfire_point.下一天激活) then
        tapUntilCheckedPointColor(sandfire_point.下一天, sandfire_point.下一天未激活, "进入下一天", 0.1, 30)
        local jumpout = false
        wait(function()
            tap(sandfire_point.下一天)
            if checkPointColor(sandfire_point.下一天紧急) then
                jumpout = true
                return true
            end
            if checkPointColor(sandfire_point.取消进入下一关) then
                return true
            end
        end, 30)
        if jumpout then
            return true
        end
        -- tapUntilCheckedPointColor(sandfire_point.下一天, sandfire_point.取消进入下一关, "点出下一天取消确认"
        --     , 0.3, 30)
        tapUntilCheckedPointColor(sandfire_point.取消进入下一关, sandfire_point.退出, "取消下一天", 0.3, 5)
        return sandfir_fight()
    end
    return sandfir_fight()
end

-- 沙中之火 点击奖励
sandfir_get_reward = function()
    log("检查每15分钟领奖励")
    if not sandfir_timer or time() - sandfir_timer > 900 * 1000 then
        -- 进入奖励页面
        tapUntilCheckedPointColor(sandfire_point.奖励, sandfire_point.奖励页面)

        -- 检查领完没
        if checkPointColor(sandfire_point.奖励已领完) then
            stop("等级已满，演算生息结束", '', true, true)
        end

        -- 领取奖励
        if not tapUntilCheckedPointColor(sandfire_point.一键领取变灰, sandfire_point.一键领取变灰, "领取奖励"
            , 0, 3) then
            tapUntilCheckedPointColor(sandfire_point.跳过皮肤, sandfire_point.一键领取变灰)
        end

        -- 检查领完没
        if checkPointColor(sandfire_point.奖励已领完) then
            stop("等级已满，演算生息结束", '', true, true)
        end

        sandfir_timer = time()
        return true
        -- -- 并非首次
        -- if zl_no_waste_last_time then
        --     zl_no_waste_last_time = nil
        -- end

        -- -- 首次
        -- if zl_no_waste then
        --     zl_no_waste_last_time = time()
        --     return false
        -- end

        -- zl_no_waste_last_time = time()
    else
        return false
    end
end

-- 游戏自动更新，需要有root权限
-- 检查游戏版本是否是最新
-- 地址 https://ak-conf.hypergryph.com/config/prod/official/Android/version
-- 返回格式 {"resVersion":"23-05-04-12-38-30-79f56b","clientVersion":"2.0.01"}
game_check_version = function(pkg)
    --log("su root sh -c dumpsys package " .. pkg .. " | grep versionName")
    local current_version = exec("su root sh -c 'dumpsys package " .. pkg .. " | grep versionName'")
    current_version = current_version:match("versionName=([^%s]+)")
    if current_version == nil then
        log("未安装" .. pkg)
        return true
    end
    current_version = string.gsub(current_version, "%.", "")
    local ret = httpGet("https://ak-conf.hypergryph.com/config/prod/official/Android/version")
    local status
    status, ret = pcall(JsonDecode, ret)
    if not status then
        return
    end
    latestVersion = string.gsub(get(ret, 'clientVersion'), "%.", "")
    latestVersion = latestVersion or current_version
    if math.abs(current_version - latestVersion) < 5 then -- 鹰角有时候偷偷更新导致版本号不一致
        log(pkg .. "已安装最新版本", latestVersion)
        return true
    else
        log(pkg .. "非最新版,当前版本", current_version, "最新版", latestVersion)
        return false
    end
end

--获取b服下载链接
get_bilibili_url = function()
    local url = "https://line1-h5-pc-api.biligame.com/game/detail/gameinfo?game_base_id=101772"
    local ret = httpGet(url)
    local status
    status, ret = pcall(JsonDecode, ret)
    ret = get(ret, 'data', 'android_download_link2')
    if type(ret) == 'string' and #ret > 0 then
        return ret
    end
    return nil
end

--更新游戏
auto_update_game = function()
    if not root_mode then
        log("无root权限，跳过游戏更新")
        return
    end
    log("开始检查游戏更新")
    log('使用方式' .. auto_update_mode .. '更新游戏客户端，更新 ' .. auto_update_game_select)
    if (auto_update_game_select ~= 2) and game_check_version("com.hypergryph.arknights") == false then
        toast("官服更新开始")
        local url = "https://ak.hypergryph.com/downloads/android_lastest"
        if auto_update_mode == 0 then
            install_game(parse_download_url(url))  --使用curl下载并安装
        else
            install_game2(parse_download_url(url)) --用自带的更新
        end
    end
    if (auto_update_game_select ~= 1) and game_check_version("com.hypergryph.arknights.bilibili") == false then
        toast("b服更新开始")
        if auto_update_mode == 0 then
            install_game(get_bilibili_url())  --使用curl下载并安装
        else
            install_game2(get_bilibili_url()) --用自带的更新
        end
    end
end

--下载并安装游戏
-- install_game = function(url)
--     console.show()
--     os.execute("mkdir " .. getWorkPath() .. '/apk/')
--     downloadpath = getWorkPath() .. '/apk/arknights.apk'
--     log("开始下载", url, downloadpath)
--     if downloadFile(url, downloadpath, function(process)
--             if process % 5 == 0 then toast("下载进度：" .. process .. "%") end
--         end) == 0 then --下载进度
--         --使用root权限安装
--         exec("su root sh -c 'pm install -r " .. downloadpath .. "'")
--         --删除apk
--         exec("su root rm -rf " .. downloadpath)
--         --log("install finish",downloadpath)
--     else
--         log("下载失败，请检查网络连接")
--     end
--     console.dismiss()
-- end

-- 使用curl下载并安装
install_game = function(url)
    console.show()
    -- exec("mkdir " .. getWorkPath() .. '/apk/')

    local downloadpath = "/storage/emulated/0/" .. package .. '/arknights.apk'
    local log_file = "/storage/emulated/0/" .. package .. '/log/curl.log'
    local curlCommand = curlpath .. ' -C - -o "' .. downloadpath .. '" "' .. url .. '" > "' .. log_file .. '" 2>&1 &'
    if (folder_exists("/data/user/0/com.hypergryph.arknights/files/AB")) then
        exec("su root sh -c 'rm -rf /data/user/0/com.hypergryph.arknights/files/'")
    end
    log("开始下载", url, downloadpath)
    log(curlCommand)
    exec(curlCommand)
    ssleep(2)
    while true do
        local file = io.open(log_file, "r")
        local log_file = file:read("*a")
        file:close()
        if string.find(log_file, " 100 ") then
            log("下载完成")
            break
        end
        ssleep(3)
    end
    ssleep(2)
    --使用root权限安装
    exec("su root sh -c 'pm install -r " .. downloadpath .. "'")
    --删除apk
    exec("su root rm -rf " .. downloadpath)
    log("安装完成", downloadpath)
    console.dismiss()
end

--用懒人自带的下载并安装游戏
install_game2 = function(url)
    console.show()
    os.execute("mkdir " .. getWorkPath() .. '/apk/')
    downloadpath = getWorkPath() .. '/apk/arknights.apk'
    log("开始下载", url, downloadpath)
    if downloadFile(url, downloadpath, function(process)
            if process % 5 == 0 then toast("下载进度：" .. process .. "%") end
        end) == 0 then --下载进度
        --使用root权限安装
        exec("su root sh -c 'pm install -r " .. downloadpath .. "'")
        --删除apk
        exec("su root rm -rf " .. downloadpath)
        --log("install finish",downloadpath)
    else
        log("下载失败，请检查网络连接")
    end
    console.dismiss()
end

--删除安卓系统download文件夹中的部分文件(速通会误点下载导致下载一堆客户端)
delele_download_file = function()
    --exec("su root rm -rf /sdcard/Download/*.apk")
    exec("su -c 'find /sdcard/download -name \"*arknights*.apk\" -exec rm {} \\;'") --官服
    exec("su -c 'find /sdcard/download -name \"*mrfz*.apk\" -exec rm {} \\;'")      --b服
    exec("su -c 'find /sdcard/download -name \"*crdownload\" -exec rm {} \\;'")     --浏览器未下载完成文件
end

-- 解析官服重定向地址
parse_download_url = function(url)
    local http = require("socket.http")
    local url = url
    local response, code, headers, status = http.request {
        url = url,
        method = "GET",
        redirect = false -- 禁用自动重定向 防止直接开始下载
    }
    if code == 302 then
        local redirect = headers.location
        return redirect
    end
end

-- 对b服数据库执行sqlite命令
bilibili_database_parse = function(command)
    if sqlite3path == nil or fileExist(sqlite3path) == false then
        sqlite3path = "sqlite3"
    end
    local command = [[su root sh -c "]] ..
        sqlite3path .. [[ /data/user/0/com.hypergryph.arknights.bilibili/databases/users.db ']] .. command .. [['"]]
    log(command)
    ret = exec(command)
    return ret
end

-- 设置自动登录账户的uid
bilibili_set_login_uid = function(uid)
    if uid == nil then
        log("uid为空")
        return false
    end
    local command = string.format("UPDATE users SET last_login = CASE WHEN uid = '%d' THEN 1 ELSE 0 END;", uid)
    local ret = bilibili_database_parse(command)
    log(ret)
    return ret
end

-- 获取自动登录账户的uid，也就是当前登录的账户，返回uid
bilibili_get_lastlogin_uid = function()
    local command = "SELECT uid FROM users WHERE last_login = 1;"
    return bilibili_database_parse(command)
end

-- 判断账户在数据库中是否存在
bilibili_is_uid_exist = function(uid)
    if uid == nil then
        log("uid为空")
        return false
    end
    local command = string.format("SELECT COUNT(*) FROM users WHERE uid=%d;", uid)
    if tonumber(bilibili_database_parse(command)) == 1 then
        return true
    else
        return false
    end
end

-- 返回官服所有账户的登录数据
official_get_user_cache = function()
    exec2(string.format(
        [[su root sh -c "cp '/data/user/0/com.hypergryph.arknights/shared_prefs/HypergryphSdkPreferences.xml' '%s'"]],
        getWorkPath() .. "/HypergryphSdkPreferences.xml"))
    setFilePremission(getWorkPath() .. "/HypergryphSdkPreferences.xml", nil)
    local file = io.open(getWorkPath() .. "/HypergryphSdkPreferences.xml", "r")
    local xml = file:read("*a")
    file:close()
    log(xml)
    return xml:match("<string%s+name=\"USER_CACHE\">(.-)</string>")
end

-- 返回最后登录的账户，string
official_get_last_login = function()
    local data = official_get_user_cache()
    data = data:gsub('&quot;', '"')
    data = JsonDecode(data)
    data = JsonEncode({ data[1] })
    data = data:gsub('"', '&quot;')
    return data
end

-- 设置官服登录账户
official_set_login_user = function(data)
    data = data or ""
    if data == "" then
        log("data为空")
        return false
    end
    exec2(string.format(
        [[su root sh -c "cp '/data/user/0/com.hypergryph.arknights/shared_prefs/HypergryphSdkPreferences.xml' '%s'"]],
        getWorkPath() .. "/HypergryphSdkPreferences.xml"))
    setFilePremission(getWorkPath() .. "/HypergryphSdkPreferences.xml", nil)
    local file = io.open(getWorkPath() .. "/HypergryphSdkPreferences.xml", "r+")
    local xml = file:read("*a")
    xml = xml:gsub("<string%s+name=\"USER_CACHE\">.-</string>", '<string name="USER_CACHE">' .. data .. '</string>')
    log(xml)
    file:seek("set", 0)
    file:write(xml)
    file:close()
    exec2(string.format(
        [[su root sh -c "cp '%s' '/data/user/0/com.hypergryph.arknights/shared_prefs/HypergryphSdkPreferences.xml'"]],
        getWorkPath() .. "/HypergryphSdkPreferences.xml"))
    return true
end

exec2 = function(command)
    local file = io.popen(command)
    local ret = file:read("*a")
    file:close()
    return ret
end

-- 保存自定义配置
save_local_config = function(filename, key, value)
    local value = value or ""
    local filePath = getWorkPath() .. "/" .. filename .. ".json"
    local Config = {}
    local file = io.open(filePath, "r")
    if file then
        local json = file:read("*a")
        Config = JsonDecode(json)
        file:close()
    end
    Config[key] = value
    file = io.open(filePath, "w")
    if file then
        local json = JsonEncode(Config)
        file:write(json)
        file:close()
        return true
    else
        return false
    end
end

-- 读取自定义配置
read_local_config = function(filename, key)
    local filePath = getWorkPath() .. "/" .. filename .. ".json"
    local file = io.open(filePath, "r")
    if file then
        local json = file:read("*a")
        local config = JsonDecode(json)
        file:close()
        return config[key]
    else
        return nil
    end
end

setFilePremission = function(filename, premission)
    if premission == nil then premission = 777 end
    exec('su root sh -c "chmod ' .. premission .. ' ' .. filename .. '"')
end

curl_post = function(url, headers, postData, timeout, arguments)
    local curlCommand = string.format("%s -X POST '%s'", curlpath, url)
    if headers then
        for k, v in pairs(headers) do
            local header = string.format("-H '%s: %s'", k, v)
            curlCommand = string.format("%s %s", curlCommand, header)
        end
    end
    if postData then
        curlCommand = string.format("%s -d '%s'", curlCommand, postData)
    end
    timeout = timeout or 5
    curlCommand = string.format("%s -m %s", curlCommand, timeout)
    if arguments then
        curlCommand = string.format("%s %s", curlCommand, arguments)
    end
    log(curlCommand)
    return exec2(curlCommand)
end

curl_get = function(url, headers, timeout, arguments)
    local curlCommand = string.format("%s -X GET '%s'", curlpath, url)
    if headers then
        for k, v in pairs(headers) do
            local header = string.format("-H '%s: %s'", k, v)
            curlCommand = string.format("%s %s", curlCommand, header)
        end
    end
    timeout = timeout or 5
    curlCommand = string.format("%s -m %s", curlCommand, timeout)
    if arguments then
        curlCommand = string.format("%s %s", curlCommand, arguments)
    end
    log(curlCommand)
    return exec2(curlCommand)
end

curl_custom = function(command)
    local curlCommand = curlpath .. " " .. command
    return exec2(curlCommand)
end

folder_exists = function(folderpath)
    local ret = exec2(string.format([[su root sh -c 'if [ -d "%s" ]; then echo "true"; else echo "false"; fi']],
        folderpath))
    if string.find(ret, "true") then
        return true
    else
        return false
    end
end

file_exists = function(filepath)
    local ret = exec2(string.format([[su root sh -c 'if [ -f "%s" ]; then echo "true"; else echo "false"; fi']], filepath))
    if string.find(ret, "true") then
        return true
    else
        return false
    end
end

copy_files = function(s, d)
    exec(string.format([[su root sh -c 'cp -r "%s" "%s"']], s, d))
end

-- 从字符串中提取数字，返回table
extractNumbers = function(str)
    local pattern = "%d+"
    local numbers = {}
    for number in string.gmatch(str, pattern) do
        table.insert(numbers, tonumber(number))
    end
    return numbers
end

-- 点击并判断前后颜色是否改变 默认比较点击位置
tap_cmpcolor = function(x, colorposition, confidence, wait_time)
    if type(x) == "string" and not x:find(coord_delimeter) then
        x = point[x]
        if type(x) == "string" then
            local p = x:find(coord_delimeter)
            local q = x:find(coord_delimeter, p + 1)
            x = map(tonumber, { x:sub(1, p - 1), x:sub(p + 1, q - 1) })
        end
    end
    if type(x) ~= "table" then return false end
    local wait_time = wait_time or 0.1
    local confidence = confidence or default_findcolor_confidence
    local colorposition = colorposition or x
    local oricol = getColor(colorposition[1], colorposition[2])
    tap(x)
    ssleep(wait_time)
    return (not compareColor(colorposition[1], colorposition[2], string.format("#%s", oricol), confidence))
end

contains_character = function(str, table)
    for _, char in ipairs(table) do
        if string.find(str, char) then
            return char
        end
    end
    return nil
end

find_color = function(v, color, dir, condifence)
    local color = color or "000000"
    if v == nil then v = { 0, 0, 0, 0 } end
    if v == true then return true end
    if type(v) == "function" then return v() end
    if type(v) == "string" and not v:find(coord_delimeter) then v = point[v] end
    if type(v) == "string" and v:find(coord_delimeter) then return nil end
    if #v ~= 4 then return nil end
    local dir = dir or 1
    -- 0: 表示从左上向右下；
    -- 1: 表示从中心往四周查找；
    -- 2: 表示从右下向左上查找；
    -- 3: 表示从左下向右上查找；
    -- 4：表示从右上向左下查找
    local condifence = condifence or default_findcolor_confidence
    local index, x, y = findColor(v[1], v[2], v[3], v[4], color, dir, condifence)
    -- log("find_color", v, index, x, y)
    if x > -1 and y > -1 then
        return { x, y }
    else
        return nil
    end
end

getCaptchaBox = function()
    if findOne("滑块验证节点") then
        local box = findOne("滑块验证节点")
        log("box", box)
        if not box then return end
        box = box.bounds
        return box
    end
    if findOne("captcha") then
        local box = findOne("captcha")
        log("box", box)
        if not box then return end
        box = box.bounds
        return box
    end
end

trySolveSlipCaptcha = function()
    if not use_jfbym and not use_free_server_captcha then trySolveCapture() end
    if not findOne("captcha") then return end
    if use_free_server_captcha then
        trySolveCaptureFreeServer(getCaptchaBox())
        if not disappear("captcha", 5) then trySolveCaptureFreeServer(getCaptchaBox()) end --免费模型，多尝试几次 准确率大概98%
    else
        SolveSlipCaptcha(jfbym_token, getCaptchaBox())
        if not disappear("captcha", 5) then
            SolveSlipCaptcha(jfbym_token, getCaptchaBox())
        end
    end
    if not appear("realgame", 5) then
        jfbym_report()
        local msg =
        "请在2分钟内手动滑动验证码，超时将暂时跳过该账号"
        toast(msg)
        captureqqimagedeliver("WARN", "触发图灵测试",
            table.join(qqmessage, ' ') .. ' ' .. msg)
        if not appear("realgame", 120) then
            back()
            if not appear("realgame", 5) then closeapp(appid) end
            stop("验证码", 'next')
        end
    end
end

-- 滑块验证码使用 https://console.jfbym.com/
SolveSlipCaptcha = function(token, rect)
    if not rect then return end
    if not token then return end
    local img = getWorkPath() .. "/Captcha.jpg"
    snapShot(img, rect.l, rect.t, rect.r, rect.b)
    local img_base64 = base64(img)
    local data = {
        extra = false,
        token = token,
        type = "22222",
        image = img_base64,
    }
    local res, code = httpPost("http://api.jfbym.com/api/YmServer/customApi", JsonEncode(data),
        30, "Content-Type: application/json;charset=UTF-8")
    local distance = 0
    local status, data = pcall(JsonDecode, res)
    data = data or {}
    if get(data, "code") ~= 10000 then
        return
    end
    unique_code = get(data, "data", "unique_code") or ""
    distance = tonumber(get(data, "data", "data")) or 0
    log(distance)
    if distance == 0 then return end
    local sx, sy = scale(702), scale(686)
    --  修正偏移
    distance = distance + scale(5)
    log(sx, sy)
    -- 用于模拟滑动轨迹
    gesture({
        {
            point = {
                { sx,                                        sy }, { sx + distance, sy },
                { sx + distance + scale(math.random(5, 20)), sy - scale(math.random(80, 150)) },
                { sx + distance + scale(math.random(5, 20)), sy },
                { sx + distance + scale(math.random(5, 20)), sy - scale(math.random(80, 150)) },
                { sx + distance + scale(math.random(5, 20)), sy },
                { sx + distance - scale(math.random(5, 20)), sy - scale(math.random(80, 150)) },
                { sx + distance - scale(math.random(5, 20)), sy },
                { sx + distance - scale(math.random(5, 20)), sy - scale(math.random(80, 150)) },
                { sx + distance - scale(math.random(5, 20)), sy }, { sx + distance, sy - scale(math.random(80, 150)) },
                { sx + distance, sy }, { sx + distance, sy - scale(math.random(80, 150)) },
                { sx + distance, sy }, { sx + distance, sy - scale(math.random(80, 150)) },
                { sx + distance, sy },
            },
            start = 0,
            duration = 1000,
        },
    })
    ssleep(1.5) -- 等待验证码关闭或者重试
end

jfbym_report = function()
    if not unique_code then return end
    local data = { unique_code = unique_code, token = jfbym_token }
    local ret, code = httpPost("http://api.jfbym.com/api/YmServer/refundApi",
        JsonEncode(data), 30,
        "Content-Type: application/json;charset=UTF-8")
    log(ret, code)
end

--使用部署的客户端免费打码官服滑块验证码
trySolveCaptureFreeServer = function(rect)
    log("free solve")
    keepCapture()
    local node = findOne("captcha")
    if not node then
        log('3576 not found captcha')
        return
    end

    if not rect then return end
    local img = getWorkPath() .. "/Captcha.jpg"
    snapShot(img, rect.l, rect.t, rect.r, rect.b)

    local img_base64 = base64(img)
    local url = "http://124.222.39.231:8899/yolo_new/"
    local param = "img=" .. encodeUrl(img_base64)

    log("图鉴准备发送")
    local ret, code = httpPost(url, param)
    local status, ret = pcall(JsonDecode, ret)
    --ret数据出问题时候
    if not status then return end
    log(ret)
    local distance = ret.target[1].距离
    local distance = str2int(distance, 0)
    log("distance:", distance)
    if distance < 0 then
        log(distance, "图片信息错误")
        releaseCapture() -- 释放捕获状态
        return false
    end
    log("滑动前检测")

    keepCapture()
    local node = findOne("captcha")
    if not node then
        log('图片寻找失败，不执行任何操作')
        releaseCapture() -- 释放捕获状态
        return
    end

    log("准备开始滑动")
    gesture({
        {
            point = { { scale(460), scale(480) }, { distance + scale(460), scale(480) } },
            start = 0,
            duration = 600,
        },
    })
    log("滑动结束")
    ssleep(2)        -- 等待验证码关闭或者重试
    releaseCapture() -- 释放捕获状态
end


-- 去除sb懒人新版广告
remove_lr_ad = function()
    local ad = string.gsub(getWorkPath(), "assistdir/[0-9a-f]+/root", "") .. "files/adcache"
    if root_mode then
        exec("su root sh -c 'rm -rf " .. ad .. "'")
        exec("su root sh -c 'mkdir " .. ad .. "'")
        setFilePremission(ad, "000")
    else
        delfile(ad)
    end
end

-- 给定需要导航的活动坐标，判断是否已经三星通关，需要滑动后判断
fight_perfect_pass = function(tap_coordinate)
    -- 宽200 高50 00B2FF
    area = { tap_coordinate[1] - scale(130), tap_coordinate[2] - scale(50), tap_coordinate[1] + scale(130),
        tap_coordinate[2] + scale(50) }
    log(area)
    local count, b, g, r = 0, 0, 0, 0
    keepCapture()
    for y = area[2], area[4], 1 do
        for x = area[1], area[3], 1 do
            ori_color = getPixelColor(x, y)
            b, g, r = colorToRGB(ori_color)
            if r >= 0 and r <= 8 and g >= 134 and g <= 178 and b >= 198 and b <= 255 then
                count = count + 1
            end
        end
    end
    releaseCapture()
    local x = count / scale(scale(1300))
    log(count, x)
    if math.abs(x - 1) <= 0.03 then
        return true
    else
        return false
    end
end

int_is_in_range = function(ori, target, range)
    if math.abs(ori - target) <= range then
        return true
    else
        return false
    end
end

get_cpu_arch = function()
    return exec("getprop ro.product.cpu.abi")
end

--隐秘战线导航
hidden_front_navigation = function()
    log('准备导航到 隐秘战线')

    --启动脚本在 隐秘战线里面时候，path.跳转("首页")会出不去，额外弄个
    if findOne("隐秘战线暂时离开") then
        --已经在小队选择界面时候退出
        ssleep(.2)
        if findOne("隐秘战线小队选择") then return true end
        if not wait(function()
                tap("隐秘战线暂时离开")
                tap("隐秘战线重新开始")
                if findOne("隐秘战线重新开始确认") then return true end
            end, 5, .2) then
            return
        end
        if not wait(function()
                tap("隐秘战线重新开始确认")
                ssleep(.3)
                if findOne("隐秘战线小队选择") then return true end
            end, 5) then
            return
        end
        return true
    end

    path.跳转("首页")
    tap("面板作战")
    if not appear("主页") then return end
    if not wait(function()
            if findOne("主题曲界面") then return true end
            tap("主题曲")
        end) then
        return
    end
    wait(function()
        tap("作战主线章节列表" .. 8)
        if not findOne("主题曲界面") then return true end
    end)

    if not wait(function()
            tap("隐秘战线在第14章入口")
            tap('隐秘战线前置章节剧情跳过')
            if findOne("隐秘战线暂时离开") then return true end
        end, 6) then
        return
    end
    --if appear("隐秘战线教程关闭", 3) then tap("隐秘战线教程关闭") end

    toast('等待2S 跳过教程')
    wait(function()
        tap("隐秘战线教程关闭")
    end, 2)

    ssleep(.5)
    --如果上一次有记录残留，重新开始
    if not findOne("隐秘战线小队选择") then
        if not wait(function()
                tap("隐秘战线暂时离开")
                ssleep(.2)
                tap("隐秘战线重新开始")
                ssleep(.2)
                if findOne("隐秘战线重新开始确认") then return true end
            end, 5) then
            return
        end
        if not wait(function()
                tap("隐秘战线重新开始确认")
                ssleep(.3)
                tap("隐秘战线教程关闭")
                if findOne("隐秘战线小队选择") then return true end
            end, 5) then
            return
        end

        --有时候教程是在重新开始后才出现,部分机子延迟不一样，多等待一会
        ssleep(1)
        tap("隐秘战线教程关闭")
    end

    log('导航成功')
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
    if 肉鸽类型 == '萨米' or 肉鸽类型 == '水月' then
        order = {
            { "百炼嘉维尔", 99, 2 },
            { "圣约送葬人", 99, 2 },
            { "乌尔比安", 99, 1 },
            { "羽毛笔", 99, 2 },
            { "海沫", 99, 2 },
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
        if findOne("萨卡兹_希望源石锭界面") then return true end
        --if findAny({ 初始招募界面, '确认招募' }) then return true end
        if findOne("战略助战确认界面") then tap("战略助战确认") end
        if not findOne("战略助战确认界面") then tap("开包skip") end
    end, 10)
end

--肉鸽挑选节点，改关卡类型和坐标位置，可以适应其他肉鸽
function zl_selection_node_skz(select_number, rogueType)
    local rogueType = rogueType or '萨卡兹'
    local select_number = select_number or 0
    local paths = { -1, -1, -1, -1, -1 }
    --紧急 普通 普通2 不期  商店 ，越在后面优先级越高
    --有时候普通战斗关卡有两种颜色好像（  都放进来好了
    if rogueType == '萨卡兹' then
        关卡类型 = { "822E2E", "7268A9", "5B528D", "2E757F", "115340" }
    elseif rogueType == '萨米' then
        关卡类型 = { "994649", "7268A9", "468C9A", "4890A2", "2B6D5B" }
    end
    --local 萨米关卡类型 = { "943E40", "7268A9", "468C9A", "4890A2", "246757" }
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
            for i = 1, #关卡类型 do
                local xx = point[rogueType .. '_关卡节点坐标列表' .. i]
                local path_pos = xx[1] .. "|" .. xx[2]
                for j = 1, #关卡类型 do
                    local path_pos_color = path_pos .. "|" .. 关卡类型[j]
                    --print(path_pos_color)
                    local res = cmpColorEx(path_pos_color, 0.9)
                    if res == 1 then
                        print(path_pos_color)
                        paths[i] = j
                    end
                end
            end
            --print(paths)
            --找到的话就退出，判断和是不是大于0，如果没有找到则是{0,0,0,0,0}
            --找到的话，至少会是1
            local paths_sum = 0
            for i = 1, #paths do
                paths_sum = paths_sum + paths[i]
                if paths_sum > 0 then
                    --print(paths_sum)
                    return true
                end
            end
        end, 3, .05) then
        log('找不到节点，重新校准路线')
        if not zl_repos_path(rogueType .. '_放弃本次探索') then return end
        return zl_selection_node(select_number + 1, rogueType)
    end


    --print(paths)
    function findMaxCoordinate(coords) --五个坐标里面取出权重最大的那个
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

--萨卡兹肉鸽战斗后拾取战利品
zl_fight_after_skz = function()
    local drop_page = false
    if not wait(function()
            if not drop_page then tap("战略确认") end
            if findOne("萨卡兹_战略帮助") then drop_page = true end
            if zl_only_coin and findOne("萨卡兹_不要了") then
                tap("萨卡兹_不要了")
                if not wait(function()
                        tap("萨卡兹_不要了确认")
                        if findAny({ "战略返回", "萨卡兹_战略帮助" }) then return true end
                    end, 2) then
                end
            end
            local x = appear({
                "萨卡兹_收藏品拾取", "萨卡兹_招募券收下", "萨卡兹_源石锭收下",
                "萨卡兹_思绪收下", --好像还有地雷收下的我没有收录
            })
            log(2555, x)
            tap(x)

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
                if not appear({ "战略返回", "萨卡兹_战略帮助" }) then
                    tap("战略确认")
                end
            end
            -- if disappear("战略返回",0.5) then return true end
            if findAny({ "萨卡兹_常规行动", "萨卡兹_战略帮助" }) and not findOne("确认招募") then
                return true
            end
        end, 30) then
        return false
    end
    return true
end

--萨米肉鸽战斗后拾取战利品
zl_fight_after_sami = function()
    local drop_page = false
    if not wait(function()
            if not drop_page then tap("战略确认") end
            if findOne("萨米_战略帮助") then drop_page = true end
            local x = appear({
                "萨米_目标生命拾取", "萨米_收藏品拾取", "萨米_招募券拾取",
                "萨米_源石锭拾取", '萨米_道具收下', '萨米_密文版拿走',
                '萨米_密文版拾取', "萨米_密文版选择左", "萨米_已领取所有奖励"
            })
            log(2555, x)
            tap(x)
            if x == '萨米_密文版拾取' then
                -- wait(function()
                --     if tap("萨米_已领取所有奖励") then return true end
                --     tap("萨米_密文版选择左")
                -- end, 5)
                appear('萨米_密文版选择左', 1)
                findTap('萨米_密文版选择左')
            end

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
                if not appear({ "战略返回", "萨米_战略帮助" }) then
                    tap("战略确认")
                end
            end
            if findAny({ "萨米_常规行动", "萨米_战略帮助" }) and not findOne("确认招募") then
                return true
            end
        end, 20) then
        return false
    end
    return true
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
            tap("萨卡兹_不期而遇选项点击列表" .. xx)
        end, 15) then
        return false
    end
    return true
end

string.finds = function(x, targetStr)
    local targetStr = targetStr or {}
    for _, v in ipairs(targetStr) do
        if string.find(x, v, 1, true) then
            log(x, ' find ', v)
            return true
        end
    end
    return false
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
                    point = { { screen.width * 0.1,   scale(800) },
                        { screen.width * 0.9,             scale(800) },
                        { screen.width * 0.9 - scale(10), scale(800) },
                        { screen.width * 0.9 + scale(10), scale(800) } },
                    start = 0,
                    duration = 500,
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

zl_招募近卫 = function(type)
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

zl_招募医疗 = function(type)
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

zl_放弃招募辅助 = function(type)
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

--通用的  肉鸽的第一次作战编队 直接引用就可以
zl_first_edit_team = function()
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
zl_fight_name_ocr = function(rogueType)
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


zl_不期而遇处理_萨卡兹 = function()
    log('处理不期而遇事件')
    if not wait(function()
            local function x()
                local incident
                local t = time()
                if not wait(function()
                        incident = ocr("萨卡兹_不期而遇事件名字检测")
                        if time() - t > 1000 then
                            t = time()
                            log(366)
                            if not findOne('萨米_希望源石锭界面') then tap("萨卡兹_不期而遇确认点击") end
                        end
                        return incident[1] or findOne("萨卡兹_战略帮助")
                    end, 8) then
                    return false
                end
                if not incident[1] then return false end
                local str = incident[1].text
                log('事件名字：', str)
                if findOne("萨卡兹_思维界面") then tap("萨卡兹_思维返回") end
                if findOne('萨卡兹_不期而遇确认') then tap("萨卡兹_不期而遇确认点击") end
                if string.finds(str, { "虫" }) then
                    return zl_event_solve(3, "萨卡兹_战略帮助")
                elseif string.finds(str, { '相遇', '解', '故事', '高空', '不散' }) then
                    return zl_event_solve(2, "萨卡兹_战略帮助")
                elseif string.finds(str, { "萨米", "维", "女士" }) then
                    return zl_event_solve(1, "萨卡兹_战略帮助")
                end
            end
            return x() or findOne("萨卡兹_战略帮助")
        end, 30) then
        return false

        --用1处理的事件
        --'高空坠物', '驮兽旅行家', '竣工仪式'

        --用2处理的事件
        --         '在故事', '不请自来', '巴别塔雇员', '魂灵', '热门景点',
        -- '未来猎手', '绝境', '相遇', '阴魂', '卫国前夜', '价高者得',
        -- '解惑', '前瞻', '深坑', '变换',
        -- '敬虔之人', '好心的女士', '疤痕国际', '沉默拳王',
        -- '离去者的庭院', '温暖余韵',

        --用3处理的事件
        --'造物', '刀口舔血', '淡然面对', '修正时代', '虫卡', '聚思成塔', '失落财宝', '解读变迁'
    end
    return true
end
