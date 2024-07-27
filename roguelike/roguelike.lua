-- 肉鸽通用函数
zl = {}

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
                    return (i + 1)
                end
            end
            ssleep(.5)
            zl.招募翻页()
        end
    end
    return 1
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
        local y3 = scale(452)
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

zl_shop_get_coin = function()
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

require("mizuki")
require("sarkaz")
require("sami")
path.探索者的银淞止境 = never_end_wrapper(path.探索者的银淞止境前瞻投资)
