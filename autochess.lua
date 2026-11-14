-- ===========================================
--               卫戍协议
-- ===========================================

autochess = {}

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
                swipe_slow(point["卫戍协议待部署区列表1"], point["卫戍协议格子列表6"])
                deploy0(point["卫戍协议格子列表6"], "上")
                -- 放第二个人
                swipe_slow(point["卫戍协议待部署区列表1"], point["卫戍协议格子列表2"])
                deploy0(point["卫戍协议格子列表2"], "右确认")
            end
            if findOne("卫戍协议教程放装备黄点") then
                log("发现教程放装备黄点")
                swipe_slow(point["卫戍协议装备区列表1"], point["卫戍协议格子列表6"])
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
                    tap("卫戍协议购买列表" .. j)
                    ssleep(.2)
                    tap("卫戍协议购买列表" .. j)
                    ssleep(.8)
                    swipe_slow(point["卫戍协议待部署区列表1"], point["卫戍协议格子列表" .. (j + i * 3 - 3)])
                    deploy0(point["卫戍协议格子列表" .. (j + i * 3 - 3)], 方向[j + i * 3 - 3])
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
