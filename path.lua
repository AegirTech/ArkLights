path = {}

-- base 只在跳转时使用，如果在任务中间需要登录失效，则当前任务超时后，下一任务的跳转会重新登录。
-- base 应覆盖尽可能多的corner case。
-- wait_game_up 每5秒执行一次，保证游戏在前台，别点到其他应用。
-- wait_game_up 有必要在游戏中自动亮屏吗：有
-- wait_game_up 有必要在切出游戏后回到游戏吗：有
-- wait_game_up 有必要做B服界面跳转吗：没有。做了之后，退出账号难实现

path.base = {
    -- 匹配图色后，点击首点所在的“重试登录”按钮。
    B服登录被取消弹窗 = "B服登录被取消弹窗",
    面板 = function()
        login_error_times = 0
        return true
    end,
    下载资源确认 = "下载资源确认",
    资源下载确定 = "资源下载确定",
    适龄提示界面 = function() return path.base["start黄框"]() end,
    start黄框 = function()
        -- reset login history on app restart
        login_times = 0
        table.remove(login_time_history or {})

        wait(function()
            tap("适龄提示")
            ssleep(0.3)
            tap("保持配音")
            ssleep(0.3)
            tap("保持配音确定")
            ssleep(0.3)
            tap("start黄框")
            ssleep(0.3)
            local ttp = find_color("选择语音确认范围", "1B6789", nil, 0.95)
            if ttp then tap(ttp) end
        end)
    end,
    start黄框暗 = function() return path.base["start黄框"]() end,
    启动卡黑屏界面 = function() --生路版本更新后，yj客户端偶尔在启动时候会黑屏卡住
        log('启动游戏卡屏界面检测')
        if not 启动界面卡住的时间 then
            启动界面卡住的时间 = time()
            log('检测到卡黑屏的时间 ' .. 启动界面卡住的时间)
        end
        --第二个号启动时候，应该距离上一个号超过了60s，把时间重置一下
        if time() - 启动界面卡住的时间 > 60 * 1000 then
            log('重置卡屏时间')
            启动界面卡住的时间 = time()
        end
        if time() - 启动界面卡住的时间 > 20 * 1000 then
            log.warn('检测该界面停留超过10s')
            if findOne('启动卡黑屏界面') then
                toast('启动界面卡住超过了10s，准备重启游戏界面' .. appid)
                exec('su root am force-stop  ' .. appid)
                --restartapp(appid)
                启动界面卡住的时间 = time()
            end
        else
            log(time() - 启动界面卡住的时间)
        end
        ssleep(.1)
    end,
    账号登录 = function() tap("账号登录") end,
    开始唤醒 = function()
        if log_login_to_cloud == true then
            cloud.addLog("INFO", "开始登录", "正在尝试登录", "")
        end
        check_login_frequency()
        wait(function()
            tap("开始唤醒")
            disappear("开始唤醒")
        end, 5)
    end,
    手机验证码登录 = disable_game_up_check_wrapper(function()
        if appid ~= oppid then return end
        if log_login_to_cloud == true then
            cloud.addLog("INFO", "开始登录", "正在尝试登录", "")
        end
        if not username or #username == 0 or not password or #password == 0 then
            -- 单账号直接停，多账号跳过
            stop("账号或密码为空", account_idx and 'next' or '')
        end
        快速切号功能状态 = false
        if #username > 0 then
            log.debug()
            if not wait(function()
                    tap("账号左侧")
                    tap("账号")
                    if appear('inputbox', 1) then return true end
                end, 10) then
                return
            end
            log.debug()
            if not wait(function()
                    wait(function() input("inputbox", username) end, 1)
                    log.debug()
                    tap("okbutton")
                    -- appear("手机验证码登录")
                    if appear("手机验证码登录", 1) and not findOne("okbutton") then
                        return true
                    end
                    log.debug()
                end, 3) then
                return
            end
            log.debug()
        end
        if not appear("手机验证码登录", 1) then return end

        if #password > 0 then
            log.debug()
            if not wait(function()
                    tap("账号左侧")
                    tap("密码")
                    -- if disappear("手机验证码登录", 1) then return true end
                    if appear('inputbox', 1) then return true end
                end, 10) then
                return
            end
            log.debug()
            -- if not appear('inputbox') then return end
            -- ssleep(1) -- 等待输入法弹出
            -- ssleep(.5) -- 等待输入法弹出
            if not wait(function()
                    wait(function() input("inputbox", password) end, 1)
                    log.debug()
                    tap("okbutton")
                    -- appear("手机验证码登录")
                    if appear("手机验证码登录", 1) and not findOne("okbutton") then
                        return true
                    end
                    log.debug()
                end, 3) then
                return
            end
            log.debug()
            -- appear("手机验证码登录")
        end

        log.debug()
        if not appear("手机验证码登录", 1) then return end
        log.debug()

        -- local login_error_times = 0
        wait(function(reset_wait_start_time)
            tap("登录")
            local p = appear({
                "captcha", "密码不能为空", "单选确认框", "注册协议",
            }, 2)
            log(p)
            if p == "注册协议" then return true end
            if p == 'captcha' then
                trySolveSlipCaptcha()
                appear("单选确认框")
            end
            if p == "密码不能为空" or p == "单选确认框" then
                return true
            end
        end, 4)
        if findTap("单选确认框") then
            log("login_error_times", login_error_times)
            login_error_times = (login_error_times or 0) + 1
        end
        -- 两次，第一次可能是数据更新
        if login_error_times > 1 then
            stop("单选确认框，密码错误？", account_idx and 'next' or '')
        end
        if log_login_to_cloud == true then
            cloud.addLog("INFO", "登录成功", "已成功登录至游戏", "")
        end
    end),
    正在释放神经递质 = function()
        if not disappear("正在释放神经递质", 1800, 1) then
            stop("正在释放神经递质超半小时", 'cur')
        end
    end,
    接管作战 = function()
        -- 开始计时
        fight_start_time = fight_start_time or time()
        local elapsed = time() - fight_start_time
        local fight_type = get_fight_type(cur_fight)
        log("接管作战")
        -- 一般20分钟，剿灭40分钟
        local fight_timeout = (table.includes({ "剿灭" }, fight_type) and elapsed >
                40 * 60 * 1000) or
            (not table.includes({ "剿灭" }, fight_type) and
                elapsed > 20 * 60 * 1000)
        log.debug(fight_timeout)
        -- 超时跳过当前关
        if fight_timeout then
            local info = table.join(qqmessage, ' ') .. " [" .. cur_fight ..
                "] 代理超时"
            captureqqimagedeliver("WARN", "代理超时", info, true)
            fight_start_time = nil
            clean_fight(cur_fight)
            restartapp(appid)
            return
        end

        -- 超时15分钟后重启游戏
        if not wait(function()
                if not findOne("接管作战") then return true end
                -- log(126)
                --if findOne("跳过剧情") then path.跳过剧情() end
                if findOne("暂停中") and not disappear("暂停中", 5) then
                    tap("开包skip")
                    disappear("暂停中")
                end
                ssleep(3)
            end, 20 * 60) then
            return restartapp(appid)
        end
        -- log(127)

        -- if not disappear("接管作战", 8 * 60 * 60, 1) then
        --       stop("接管作战超8小时")
        --     end

        -- this calllback only works for 主线、资源、剿灭
        local unfinished

        local first_time_see_zero_star
        local zero_star
        local see_end
        local see_jm_record_change
        local unexpect_return
        local home
        local normal

        if not wait(disable_log_wrapper(function()
                if findOne("行动结束") then see_end = true end
                if copy_homework and findOne("返回") then return true end
                if findOne("行动结束") and findOne("零星代理") then
                    first_time_see_zero_star = first_time_see_zero_star or time()
                    -- 实测560秒，给两倍
                    if time() - first_time_see_zero_star > 1200 then zero_star = true end
                end

                if findOne("开始行动") and findOne("代理指挥开") then
                    log.debug()
                    normal = true
                    return true
                end

                if findOne("接管作战") then
                    unfinished = true
                    return true
                end

                if findOne("剿灭接管作战") and
                    not disappear("剿灭接管作战", 5) then
                    captureqqimagedeliver("INFO", "剿灭作战",
                        table.join(qqmessage, ' ') .. " [" .. cur_fight ..
                        "]剿灭接管作战", true)
                    tap("剿灭接管作战")
                    ssleep(2)
                    tap("面板设置", true)
                    ssleep(2)
                    tap("剿灭放弃行动")
                    -- ssleep(2)
                    -- tap("右确认")
                    appear("剿灭记录确认", 60)
                end

                if findOne("剿灭记录确认") and
                    not disappear("剿灭记录确认", 5) then
                    captureqqimagedeliver("INFO", "剿灭作战",
                        table.join(qqmessage, ' ') .. " [" .. cur_fight ..
                        "]剿灭记录确认", true)
                    tap("剿灭记录确认")
                    see_jm_record_change = true
                end

                -- 战斗记录未同步
                if findOne("返回确认界面") and
                    not disappear("返回确认界面", 5) then
                    tap("左取消")
                    unexpect_return = true
                end

                -- 掉线
                if findAny({
                        "开始唤醒", "bilibili_framelayout_only", "framelayout_only",
                        "手机验证码登录",
                    }) then
                    home = true
                    log.debug()
                    return true
                end

                tap("开始行动1")

                appear({ "开始行动", "接管作战" }, 1)
            end), 60) then
            -- if findOne("跳过剧情2") and not disappear("跳过剧情2", 10) then
            path.跳过剧情()
            -- end

            return
        end

        if unfinished then return path.base.接管作战() end
        -- 清除计时
        fight_start_time = nil

        log("回到首页")
        log("代理结束", cur_fight, "失败次数", fight_failed_times[cur_fight])
        log.debug(first_time_see_zero_star, zero_star)
        log("zero_star", zero_star)
        log("see_end", see_end)
        log("home", home)
        log("normal", normal)
        if zero_star or not see_end or home then
            log.warn("代理失败返回首页")

            if not qqnotify_nofailedfight then
                local info = table.join(qqmessage, ' ') .. " [" .. cur_fight ..
                    "] 代理失败" .. (home and "(掉线或抢登)" or '')
                -- (zero_star and 'zero_star' or '') ..
                -- (see_end and 'see_end' or '') ..
                -- (normal and 'normal' or '')
                captureqqimagedeliver("WARN", "代理失败", info, true)
            end
            -- 一次代理失败直接认为无效：不行，因为可能是掉线造成的失败
            fight_failed_times[cur_fight] = max(0, fight_failed_times[cur_fight] or 0)
            log.debug()
            return path.跳转("首页")
        end

        if see_jm_record_change then
            fight_failed_times[cur_fight] = 99
            return path.跳转("首页")
        end
        battle_times = battle_times or 1
        for i = 1, battle_times do
            table.insert(fight_history, cur_fight)
        end

        fight_times = (fight_times or 0) + 1
        if fight_times >= max_fight_times then
            fight_times = 0
            restartapp(appid)
            return path.跳转("首页")
        end

        log.debug(fight_times, repeat_fight_mode)
        if repeat_fight_mode then return path.开始游戏('') end

        -- current fight success
        log.debug(cur_fight, fight_tick, fight)
        pre_fight = cur_fight
        fight_failed_times[cur_fight] = -3
        -- if same fight or same page fight
        log.debug()
        if fight == nil or #fight == 0 then
            log.warn("fight is empty, return to home")
            return
        end

        fight_tick = fight_tick + battle_times - 1
        local next_fight_tick = fight_tick % #fight + 1 -- 多倍代理次数
        local next_fight = fight[next_fight_tick]
        log(fight_tick, cur_fight, next_fight)

        if table.includes({ "剿灭" }, get_fight_type(cur_fight)) then
            jmfight_times = (jmfight_times or 0) + 1
            if jmfight_times >= max_jmfight_times then clean_jmfight() end
            -- if appear("全权委托", 1) then
            --   wait(function()
            --     tap("全权委托")
            --     if disappear("全权委托", 1) and not disappear("开始行动", 1) then
            --       return true
            --     end
            --   end, 30)
            -- end
            -- 剿灭必须回主页
            -- if not appear("主页") then back() end
            return path.跳转("首页")
        elseif next_fight == cur_fight then
            fight_tick = next_fight_tick
            pre_fight = nil
            if not request_memory_clean() then
                return path.开始游戏(next_fight)
            else
                return path.跳转("首页")
            end
        elseif same_page_fight(cur_fight, next_fight) then
            if not wait(function()
                    if not findOne("开始行动") then return true end
                    tap("主页右侧")
                end, 20) then
                return
            end

            -- TODO how to ignore this sleep
            -- ssleep(.5)
            -- 只有主线与物资芯片会存在same_page_fight，
            -- 物资芯片的appear是完备的

            local x = get_fight_type(cur_fight)
            -- if x == "物资芯片" then
            --   appear("作战列表" .. cur_fight, .5)
            if x == "主线" then
                local x0 = cur_fight
                local chapter = x0:find("-")
                chapter = x0:sub(1, chapter - 1)
                chapter = chapter:sub(chapter:find("%d"))
                local chapter_index = tonumber(chapter) + 1
                appear("当前进度列表" .. chapter_index, .5)
            else
                log("unexpected same page fight wait")
                ssleep(.5)
            end
        end
    end,

    bilibili_framelayout_only = function()
        if log_login_to_cloud == true then
            cloud.addLog("INFO", "开始登录", "正在尝试登录", "")
        end
        auto(path.bilibili_login, nil, 0, default_auto_timeout_second, true)
        if log_login_to_cloud == true then
            cloud.addLog("INFO", "登录成功", "已成功登录至游戏", "")
        end
        if new_change_account_plan then 快速切号功能状态 = false end
    end,

    framelayout_only = function()
        if log_login_to_cloud == true then
            cloud.addLog("INFO", "开始登录", "正在尝试登录", "")
        end
        auto(path.login, nil, 0, default_auto_timeout_second, true)
        if log_login_to_cloud == true then
            cloud.addLog("INFO", "登录成功", "已成功登录至游戏", "")
        end
        if new_change_account_plan then 快速切号功能状态 = false end
    end,

}

path.bilibili_login = {
    B服登录被取消弹窗 = "B服登录被取消弹窗",
    b服年度报告 = function()
        tap("b服年度报告")
        ssleep(0.5)
        tap("b服年度报告关闭")
    end,
    同意协议 = function() return path.fallback.同意协议() end,
    活动公告返回 = function() return path.fallback.活动公告返回() end,
    同意并继续 = function()
        local p = findNode(point["同意并继续"])
        if p then
            clickNodeFalse(p)
            disappear("同意并继续")
        end
    end,
    captcha = function() trySolveSlipCaptcha() end,
    bgame = true,
    bilibili_license_ok = function() tap("bilibili_license_ok") end,
    bilibili_phone_inputbox = function()
        -- 把输入法关了
        wait(function()
            if findOne("bilibili_account_login") then return true end
            tap("返回")
        end, 5)
        local tos = findOne("bilibili_tos")
        if tos then tap({ tos.bounds.l + scale(5), tos.bounds.t + scale(5) }) end
        tap("bilibili_account_login")
        appear("bilibili_username_inputbox")
    end,
    bilibili_username_inputbox = disable_game_up_check_wrapper(function()
        log.debug()
        -- 把输入法关了
        wait(function()
            if findOne("bilibili_login") then return true end
            tap("返回")
        end, 5)
        if username and #username > 0 and password and #password > 0 then
            wait(function() input("bilibili_username_inputbox", username) end, 1)
            wait(function() input("bilibili_password_inputbox", password) end, 1)
        else
            stop("账号或密码为空", account_idx and 'next' or '')
        end
        快速切号功能状态 = false
        tap("bilibili_login")
        disappear("bilibili_login", 15)
        tap("bilibili_login")
        disappear("bilibili_login", 5)
        login_error_times = (login_error_times or 0) + 1

        if login_error_times > 2 then
            -- if not appear({"bilibili_change2", "captcha", {text = "存储"}}, 15) then

            stop("B服登录密码错误或设备数量超限",
                account_idx and 'next' or '')
        end
        -- 小米
        -- appearTap({text = "存储"}, 1)

        appear({
            "bilibili_change2", "captcha", "B服安全验证",
            "B服安全验证320DPI",
        })
    end),
    bilibili_oneclicklogin = function()
        tap("bilibili_oneclicklogin")
        appear({ "bilibili_ok", "bilibili_change2" }, 5)
    end,
    bilibili_ok = function()
        tap("bilibili_ok")
        appear("bgame", 5)
    end,
    bilibili_other = function()
        tap("bilibili_other")
        appear("bilibili_phone_inputbox")
    end,
    bilibili_change2 = function()
        check_login_frequency()
        disappear("bilibili_change2", 10)
        log.debug()
    end,

    B服安全验证320DPI = function()
        return path.bilibili_login.B服安全验证()
    end,
    B服安全验证 = disable_game_up_check_wrapper(function()
        log("开始B服安全验证流程")
        -- if bilibili_captcha_times > 1 and findOne("B服刷新验证") then
        --     tap("B服刷新验证")
        --     ssleep(1)
        -- end
        path.bilibili_login.B服等待验证码弹窗加载()
        log.debug('B服弹窗已加载')
        -- 这段有点屎，不应该放在主流程里，但是为了兼容先不动他
        local box = findOne("B服安全验证框")
        -- log("box", box)
        if not box then
            log("B服安全验证流程", "B服安全验证框未找到")
            return
        end
        box = box.bounds

        -- log("b服打码")
        local choices = {}
        if use_captcha_aunly and type(cloud_captcha_token) == "string" and #cloud_captcha_token > 10 then
            table.insert(choices, 3)
        end
        if use_captcha_free2 and type(cloud_captcha_server2) == "string" and #cloud_captcha_server2 > 4 then
            table.insert(choices, 4)
        end
        if use_captcha and captcha_username then
            table.insert(choices, 1)
        end
        log.debug('choices', choices)
        local choice_map = {}
        choice_map[1] = "图鉴"
        choice_map[3] = "Aunly"
        choice_map[4] = "自选B服打码"
        bilibili_captcha_cloud_times = 0
        for _, choice in ipairs(choices) do
            log("B服安全验证流程", "当前尝试打码方式: " .. choice_map[choice])
            if bilibili_captcha_cloud_times > 0 then
                log("第二次登录，尝试刷新验证码")
                path.bilibili_login.B服验证码刷新()
                path.bilibili_login.B服等待验证码弹窗加载()
                ssleep(0.3)
            end
            if trySolvePointSelectionCapture(box, choice) then
                log("B服安全验证流程", "当前尝试打码方式: " .. choice_map[choice] .. " 平台认为打码成功，等待提交验证")
                break
            else
                -- 平台打码失败，需要刷新验证码
                log("B服安全验证流程", "当前尝试打码方式: " .. choice_map[choice] .. " 平台打码失败，非提交失败，刷新后重试")
                bilibili_captcha_cloud_times = (bilibili_captcha_cloud_times or 0) + 1
                if bilibili_captcha_cloud_times > 3 then
                    log("B服安全验证流程", "当前尝试打码方式: " .. choice_map[choice] .. " 平台打码失败超过3次，跳过")
                    stop("B服安全验证平台打码失败3次", account_idx and 'next' or '')
                end
                path.bilibili_login.B服验证码刷新()
            end
        end
        ssleep(0.4)

        log("B服安全验证流程", "点选已完成，正在提交打码结果")
        if not wait(function()
                local ft = findAny({
                    "B服安全验证提交", "B服安全验证提交320DPI",
                    "B服安全验证确认按钮",
                })
                tap(ft)
            end, 2) then
            log.warn("未找到b服提交按钮1")
            findTap("B服安全验证提交320DPI")
            tapIfCheckedColor({ 823, 605, "539FFE" }, { 823, 605, "539FFE" }, { 692, 552, "539FFE" })
        end

        log("B服安全验证流程", "已点击提交，等待服务返回结果")

        -- 出现失败字样，说明验证码错误，等待自动刷新
        if appear({ "B服安全验证失败", "B服安全验证失败320DPI" }) then
            log("B服安全验证流程", "游戏认为打码失败，正在上报失败并等待自动刷新验证码")
            cloud.captcha_report()
            jfbym_report()
            ttshitu_report()
            ssleep(1.0)
            -- 检查是否超过次数
            if (bilibili_captcha_times or 0) > 5 then
                back()
                stop("B服安全验证5次失败", account_idx and 'next' or '')
            end
            path.bilibili_login.B服验证码失败计数()
        end

        wait(function()
            if not findAny({ "B服安全验证提交", "B服安全验证提交320DPI", "B服安全验证确认按钮", }) then
                -- 这个log是阿点写的 不知道什么意思
                log.warn("B服安全验证提交未找到，可能提交成功")
                return true
            end
            ssleep(2)
            back()
        end, 4)

        log("B服安全验证流程", "安全验证流程结束")
    end),
    B服验证码失败计数 = function()
        bilibili_captcha_times = (bilibili_captcha_times or 0) + 1
    end,
    -- 该方法需保证刷新后图片已完全加载
    B服验证码刷新 = function(no_count)
        log("B服安全验证流程", "当前重试次数: " .. (bilibili_captcha_times or 0))
        log("B服安全验证流程", "正在刷新B服验证码")
        if findTap("B服刷新验证") then
            tap("B服刷新验证")
            ssleep(2)
        end
        -- 刷新完成后等待加载出图
        local img_b_main = findOne("B服验证码_请在下图依次点击")
        if img_b_main ~= nil then
            if appear({ "B服安全验证提交", "B服安全验证提交320DPI", "B服安全验证确认按钮" }, 5) then
                if disappear("B服验证码_二值化主体", 10) then
                    ssleep(.2)
                    log("B服安全验证流程", "刷新后验证码已加载")
                    return true
                end
            end
        end
    end,
    B服等待验证码弹窗加载 = function()
        if not appear({ "B服安全验证提交", "B服安全验证提交320DPI", "B服安全验证确认按钮" }, 5) then
            log("B服安全验证流程", "等待节点识别加载失败")
            if not checkPointColor({ 823, 605, "BAD9FF" }) then
                log("B服安全验证流程", "弹窗加载失败")
                return false
            end
        end
        log("B服安全验证流程", "弹窗已加载")
        return true
    end,
}

path.bilibili_login_change = update(path.bilibili_login, {
    bilibili_oneclicklogin = false,
    bilibili_username_inputbox = true,
    bilibili_change2 = function()
        if not wait(function()
                findTap("bilibili_change2")
                -- if appear({"bilibili_change", "bilibili_account_login"}, .5) then
                if appear({ "bilibili_change", "bilibili_phone_inputbox" }, 1) then
                    return true
                end
            end, 5) then
            -- B服卡登录
            restartapp(appid)
        end
    end,
    bilibili_change = function()
        log.info("start login bili")
        tap("bilibili_change")
        -- appear("bilibili_account_login")
        appear("bilibili_phone_inputbox")
    end,
}, nil, true)

path.login = {
    b服年度报告 = function()
        tap("b服年度报告")
        ssleep(0.5)
        tap("b服年度报告关闭")
    end,
    同意协议 = function() return path.fallback.同意协议() end,
    活动公告返回 = function() return path.fallback.活动公告返回() end,

    阅读并同意 = function()
        local p = findNode(point["阅读并同意"])
        if p then
            clickNodeFalse(p)
            disappear("阅读并同意")
        end
    end,
    同意并继续 = function()
        local p = findNode(point["同意并继续"])
        if p then
            clickNodeFalse(p)
            disappear("同意并继续")
        end
    end,
    captcha = function() trySolveSlipCaptcha() end,
    ogame = true,
    username_inputbox = disable_game_up_check_wrapper(function()
        log.debug(login_time_history)

        -- 把输入法关了
        wait(function()
            if findOne("password_login") then path.login.password_login() end
            if findOne("login") then return true end
            tap("返回")
        end, 3)

        if findOne("password_login") then
            --再次检查
            path.login.password_login()
        end

        -- 存在两个输入框时，输入帐密
        if findOne("username_inputbox") then
            log.debug()
            local input_box = findNodes(point["username_inputbox"])
            if type(input_box) == 'table' and #input_box == 2 then
                if not username or #username == 0 or not password or #password == 0 then
                    -- 单账号直接停，多账号跳过
                    stop("账号或密码为空", account_idx and 'next' or '')
                end
                wait(function() nodeLib.setText(input_box[1], username) end, 1)
                wait(function() nodeLib.setText(input_box[2], password) end, 1)
                log.debug()
                -- 同意登录
                local checkbox = findNodes(point["login_checkbox"])
                if type(checkbox) == 'table' and checkbox[#checkbox].checked == false then
                    clickNodeFalse(checkbox[#checkbox])
                end
            end
        end

        login_error_times = (login_error_times or 0) + 1
        if login_error_times > 2 then
            stop("官服登录密码错误或设备数量超限",
                account_idx and 'next' or '')
        end

        ssleep(.5) -- checkbox 需要延时
        log.debug(login_time_history)
        -- if debug_mode then ssleep(1000) end
        -- 开始唤醒时已经check了
        -- check_login_frequency()
        tap("login")
        -- -- 多点一次登录
        -- if not disappear("login") then
        --   tap("login")
        -- end
        wait(function()
            if findNode(point["防沉迷"]) then stop("防沉迷跳过", account_idx and 'next' or '') end
        end, 2)
        disappear("login")
        appear({ "captcha", "B服安全验证", "B服安全验证320DPI" })
    end),

    login_switch = disable_game_up_check_wrapper(function()
        check_login_frequency()
        tap("login")
        wait(function()
            if findNode(point["防沉迷"]) then stop("防沉迷跳过", account_idx and 'next' or '') end
        end, 2)
        disappear("login")
        appear({ "captcha", "B服安全验证", "B服安全验证320DPI" })
    end),

    password_login = function()
        clickNodeFalse(findOne("password_login"))
        disappear("password_login")
    end,

    B服安全验证320DPI = function()
        return path.bilibili_login.B服安全验证()
    end,
    B服安全验证 = function() return path.bilibili_login.B服安全验证() end,
}

path.login_change = update(path.login, {

    username_inputbox = true,
    login_switch = function()
        clickNodeFalse(findOne("login_switch"))
        disappear("login_switch")
    end,
}, nil, true)

path.fallback = {
    同意协议 = function()
        -- findTap({text = "下一步"})

        -- ssleep(1)
        local p = findOne("同意协议")
        if p ~= nil then
            local left, top = p.bounds.l, p.bounds.t
            tap({ left - scale(10), top + scale(10) })
        end
        ssleep(1)
        findTap({ text = "下一步" })
    end,

    未来序曲 = function()
        -- "188|529|F3C4A2,1368|199|FF793F,1356|918|393939"
        local w = scale(1370 - 1920 // 2) + screen.width // 2

        for h = 199, 918, 50 do
            h = scale(h - 1080 // 2) + screen.height // 2
            tap({ w, h })
            ssleep(.5)
        end
        tap("未来序曲领取")
        tap("未来序曲领取2")
        ssleep(1)
        back()
        if not appear("面板") then tap("开包skip") end
    end,
    产业合作洽谈会 = function()
        ssleep(1)
        wait(function() tap("产业合作洽谈会策略") end, 2)
        wait(function()
            tap('返回')
            back()
            if appear("面板", 1) then return true end
        end, 5)
        path.跳转('首页')
        -- back()
        -- disappear("产业合作洽谈会")
    end,
    月饼 = function()
        ssleep(1)
        wait(function() tap("月饼右") end, 2)
        wait(function() tap("月饼确认") end, 2)
    end,
    庆祝完结页面 = function()
        wait(function()
            tap("庆祝完结领取确认")
            if not appear("面板") then tap("开包skip") end
            findTap("右上角关闭白色")
            if appear("面板") then return true end
        end, 15)
    end,
    -- 主题曲已开放 = function()
    --   tap("主题曲已开放")
    --   ssleep(1)
    --   tap("主题曲已开放")
    --   ssleep(1)
    --   tap("主题曲已开放")
    --   ssleep(1)
    --   back()
    -- end,
    注册协议 = function()
        tap("注册协议1")
        ssleep(.5)
        tap("注册协议2")
    end,
    可露希尔 = function()
        for k, v in pairs(point.可露希尔右列表) do tap(v) end
        for k, v in pairs(point.可露希尔左列表) do tap(v) end
        tap("返回")
        if appear("可露希尔", 5) then
            ssleep(1)
            return path.fallback.可露希尔()
        end
    end,
    阿米娅 = function()
        for k, v in pairs(point.阿米娅右列表) do tap(v) end
        for k, v in pairs(point.阿米娅左列表) do tap(v) end
        -- 教程
        if not wait(function()
                tap("卫戍协议物资调配处")
                ssleep(.2)
                tap("卫戍协议准备就绪")
                ssleep(.2)
                tap("卫戍协议物资调配处第一个干员")
                ssleep(.2)
                tap("卫戍协议物资调配处道具")
                ssleep(.2)
                if findOne("教程关闭") or findOne("卫戍协议物资调配处道具") then return true end
            end, 20, .5) then
            toast("教程卡住了")
        end
        tap("返回")
        if appear("阿米娅", 5) then
            ssleep(1)
            return path.fallback.阿米娅()
        end
    end,
    阿米娅2 = function() return path.fallback.阿米娅() end,
    覆巢之下主页 = function() tap("返回") end,
    全权委托 = function()
        wait(function()
            tap("全权委托")
            if not findOne("主页") then tap("开始行动蓝") end
            ssleep(1)

            if not findOne("全权委托") and findOne("代理指挥开") and
                findOne("主页") then
                return true
            end
        end, 30)
    end,
    开始行动活动 = function()
        tap("返回")
        appear("主页")
    end,
    线索传递界面 = function() tap("线索传递返回") end,
    查看谢幕表 = function() tap("战略确认") end,
    我知道了 = function() tap("我知道了") end,
    剿灭提示 = function() tap("左上角返回") end,
    获得物资 = function() tap("返回") end,
    战略返回 = function()
        tap("战略返回")
        appear("常规行动", 2)
    end,
    战略返回其他肉鸽 = function()
        tap("战略返回")
        --其他很多地方用到上面的战略返回，怕改有点问题，所以额外加一个
        appear({ '萨卡兹_常规行动', "萨米_常规行动", "水月_常规行动" }, 2)
    end,
    断罪返回 = function()
        tap("断罪返回")
        disappear("断罪返回")
    end,
    签到返回黄 = function() return path.fallback.签到返回() end,
    回坑返回 = function() return path.fallback.签到返回() end,
    签到返回 = function()
        local x
        local last_time_tap_return = time()
        local start_time = time()
        if not wait(function()
                -- 曾出现 返回确认 误判为 活动公告返回
                -- 返回确认3按back太快弹不出来
                if findOne("侧边栏收起") then
                    log.debug()
                    tap("侧边栏收起")
                    ssleep(0.5)
                end

                local timeout = min(2, (time() - start_time + 1000) / 1000 * 2 / 10)
                log.debug(timeout)
                -- timeout = 0
                x = appear({
                    "返回确认", "返回确认3", "主题曲已开放", "回归返回",
                    'start黄框', 'start黄框暗',
                }, timeout)
                -- disappear("开始行动", min(2, (time() - start_time) / 1000 * 2 / 2))
                if x then return true end
                back()

                -- 每两秒按下返回，处理限时活动中领到干员/皮肤
                if time() - last_time_tap_return > 5000 then
                    -- TODO:按返回在获得物资界面没用
                    tap("返回")
                    last_time_tap_return = time()
                end
                -- 干员/皮肤界面用返回键没用，这时按基建右上角
            end, 30) then
            auto_total_timeout_hook()
            stop("返回键30秒超时", 'cur')
        end
        if x then return tap(path.fallback[x]) end
    end,
    获得塔罗牌页面 = function()
        wait(function()
            if not findOne("获得塔罗牌页面") then return true end
            tap("塔罗牌关闭")
        end, 3)
        ssleep(0.5)
    end,
    争锋频道首页 = function()
        tap("争锋频道回到游戏首页")
        ssleep(0.6)
    end,
    争锋频道返回2 = function()
        tap("争锋频道返回2")
        ssleep(0.6)
    end,
    怪猎二期返回 = function()
        tap("怪猎二期返回")
        ssleep(0.6)
    end,
    怪猎一期返回 = function()
        tap("怪猎一期返回")
        ssleep(0.6)
    end,
    回归返回 = function()
        tap("回归返回")
        ssleep(1)
        return path.fallback.签到返回()
    end,
    活动公告返回 = function()
        if not wait(function()
                if disappear("活动公告返回", 1) then return true end
                back()
            end, 5) then
            return restartapp(appid)
        end
        return path.fallback.签到返回()
    end,
    抽签返回 = function()
        for u = scale(300), screen.width - scale(300), 200 do
            tap({ u, screen.height // 2 })
        end
        tap("确定抽取")
        return path.fallback.签到返回()
    end,
    活动签到返回 = function()
        if findOne("电影签到返回") then
            tap("电影签到观看")
            if not wait(function()
                    if findOne("电影签到返回") then return true end
                    if findOne("跳过剧情") then path.跳过剧情() end
                end, 6) then
                return
            end
            if findOne("电影签到返回") then
                back()
            end
            return path.fallback.签到返回()
        end
        if findOne("国家图书馆领取") then
            tap("国家图书馆领取")
            return path.fallback.签到返回()
        end

        ssleep(0.5) -- 等待签到界面加载
        for u = screen.width // 2 + scale(730 - 1920 // 2), screen.width // 2 + scale(1730 - 1920 // 2), scale(100) do
            tap({ u, scale(560) })
            ssleep(0.1) --部分设备点太快没有响应
        end
        for v = screen.height // 2 + scale(180 - 1080 // 2), screen.height // 2 + scale(950 - 1080 // 2), scale(100) do
            tap({ screen.width // 2, v })
            ssleep(0.1)
        end
        return path.fallback.签到返回()
    end,
    生日设置返回 = function()
        tap("生日设置返回按钮")
        ssleep(.3)
    end,
    国庆签到返回 = function() return path.fallback.活动签到返回() end,
    活动签到返回20261101 = function() return path.fallback.活动签到返回() end,
    返回确认 = function()
        log.debug()
        leaving_jump = false
        if not wait(function()
                if findOne("进驻总览") then zoom() end
                if not findOne("返回确认") then return true end

                -- 宽屏上有误判
                if findOne("活动公告返回") then
                    path.fallback.活动公告返回()
                    return true
                end

                if stay_in_dorm_once then
                    back()
                    -- 必须等待
                    if disappear("返回确认", .5) and not appear("进驻总览", 1) then
                        -- 解决灯泡激活状态的死循环
                        tap("基建右上角")
                    end
                else
                    tap("右确认")
                end
            end, 60) then
            return restartapp(appid)
        end
        stay_in_dorm_once = false

        if appear("进驻总览", 1) then leaving_jump = true end
    end,
    返回确认2 = "右确认",
    返回确认3 = function()
        wait(function()
            if findAny({
                    "面板", "开始唤醒", "bilibili_framelayout_only",
                    "framelayout_only", "活动公告返回",
                }) then
                return true
            end
            tap("左取消")
        end, 5)
    end,
    单选确认框 = "右确认",
    剿灭说明 = function()
        tap("基建右上角")
        ssleep(1)
        -- if not wait(function()
        --   if findOne("主页") then return true end
        --   tap("基建右上角")
        -- end, 5) then stop(208) end
    end,
    行动结束 = function()
        tap("行动结束")
        -- if not wait(function()
        --   if findOne("开始行动") and findOne("代理指挥开") then
        --     return true
        --   end
        --   findTap("行动结束")
        -- end, 10) then stop(217) end
    end,
    限时幸运签 = function()
        if findTap("促融共竞目标板领取") then
            disappear("促融共竞目标板领取", 3)
            ssleep(.5)
            tap("右确认")
            return path.fallback.签到返回()
        end
        -- 存在好友邀请的红点
        if findTap("促融共竞组队红") then
            if not wait(function()
                    tap("促融共竞组队红")
                    ssleep(.5)
                    if findOne("促融共竞查看邀请") then return true end
                end, 5) then
                return path.fallback.签到返回()
            end
            wait(function()
                tap("促融共竞查看邀请")
                ssleep(.5)
                if not findOne("促融共竞查看邀请") then return true end
            end, 5)

            wait(function()
                back()
                ssleep(1)
                if findOne("促融共竞查看邀请") then return true end
            end, 5)
            return path.fallback.签到返回()
        end
        tapAll(point.限时幸运签列表)
        ssleep(.25)
        tap("限时幸运签抽取")
        disappear("限时幸运签", 10)
        return path.fallback.签到返回()
    end,
    七周年限时幸运签 = function()
        tapAll(point.限时幸运签列表)
        ssleep(.25)
        tap("限时幸运签抽取")
        disappear("七周年限时幸运签", 10)
        return path.fallback.签到返回()
    end,
    限时幸运签20261101 = function()
        tapAll(point.限时幸运签列表)
        ssleep(.25)
        tap("限时幸运签抽取")
        disappear("限时幸运签20261101", 10)
        return path.fallback.签到返回()
    end,
    夏日嘉年华赠送活动一20260801 = function()
        ssleep(1)
        tap('夏日嘉年华赠送活动一20260801')
        return path.fallback.签到返回()
    end,
    夏日嘉年华赠送活动二20260801 = function()
        ssleep(1)
        tap('夏日嘉年华赠送活动二20260801')
        return path.fallback.签到返回()
    end,
    鸣羽颂新领取 = function()
        wait(function()
            tap("鸣羽颂新领取")
        end, 2, .2)
        return path.fallback.签到返回()
    end,
    国家图书馆领取 = function()
        tap("国家图书馆领取")
        return path.fallback.签到返回()
    end,
    -- 新春限时签到2025 = function()
    --     wait(function()
    --         if findAny({ "新春限时签到_签到界面", "面板" }) then
    --             return true
    --         else
    --             tap("新春限时签到_收下祝福")
    --         end
    --     end, 2)
    --     wait(function()
    --         if findAny({ "新春限时签到_签到界面", "面板" }) then return true end
    --         tap("开包skip")
    --     end, 2)
    --     wait(function()
    --         for h = 200, 951, 150 do
    --             if findOne("新春限时签到_签到界面") then
    --                 tap({ scale(1300), scale(h) })
    --                 ssleep(.5)
    --             end
    --         end
    --         tap("开包skip")
    --         if findAny({ "新春限时签到_签到界面", "面板" }) then return true end
    --     end, 10)
    -- end,
    -- 新年祝福返回 = function()
    --     wait(function()
    --         --tap("新年祝福签到")
    --         if not findOne("新年祝福奖励领取界面") then tap("新年祝福签到") end
    --     end, 1.5)
    --     wait(function()
    --         if findAny({ "新年祝福返回", "面板" }) then return true end
    --         tap("开包skip")
    --     end, 2)
    --     wait(function()
    --         for h = 200, 951, 150 do
    --             if findOne("新年祝福返回") then
    --                 tap({ scale(1300), scale(h) })
    --                 ssleep(.5)
    --             end
    --         end
    --         tap("开包skip")
    --         if findAny({ "新年祝福返回", "面板" }) then return true end
    --     end, 10)
    -- end,
    -- 战备支援签到返回 = function()  --有误判
    --     wait(function()
    --         tap("战备支援签到")
    --         ssleep(.2)
    --     end, 1)
    --     wait(function()
    --         tap("战备支援签到返回")
    --         ssleep(.2)
    --         tap("开包skip")
    --         if not appear("面板") then tap("开包skip") end
    --         if appear("面板", 1) then return true end
    --     end, 5)
    -- end,
    寻访赠送十连领取 = function()
        tap("寻访赠送十连领取")
        ssleep(.5)
        return path.fallback.签到返回()
    end,
    端午签到返回 = function()
        wait(function()
            tap("端午签到左")
            ssleep(.2)
            tap("端午签到中")
            ssleep(.2)
        end, 1)
        wait(function()
            tap("端午签到返回")
            if appear("面板", 1) then return true end
        end, 5)
    end,
    祈愿牌返回 = function()
        -- "158|157|92928A,728|577|876E3D,1016|619|B38375"
        for w = 237, 1092 + 100, 225 do
            w = screen.width // 2 + scale(w - 1920 // 2)
            for h = 237, 865 + 100, 225 do
                tap({ w, scale(h) })
                ssleep(.1)
                tap("祈愿牌确认")
                ssleep(.1)
            end
            -- if not findOne("祈愿牌返回") then break end
        end
        -- ssleep(.5)
        -- tap("祈愿牌确认")
        -- ssleep(.25)
        -- disappear("祈愿牌确认", 10)
        return path.fallback.签到返回()
    end,

    五周年专享月卡返回 = function()
        wait(function()
            tap("五周年专享月卡领取")
        end, 2)
        return path.fallback.签到返回()
    end,
    回望泰拉限时登录签到界面 = function()
        wait(function()
            tap("回望泰拉限时登录领取")
        end, 2)
        return path.fallback.签到返回()
    end,
    -- 小马宝莉签到领取界面 = function()
    --     wait(function()
    --         tap("小马宝莉签到领取")
    --         tap('小马宝莉签到领取二')
    --     end, 2)
    --     return path.fallback.签到返回()
    -- end,
    春节签到2026返回 = function()
        --右边一列签到
        wait(function()
            for h = 200, 951, 150 do
                if findOne("春节签到2026返回") then
                    tap({ scale(1300), scale(h) })
                    ssleep(.5)
                end
            end
            tap("开包skip")
            if findAny({ "春节签到2026返回", "面板" }) then return true end
        end, 10)
        return path.fallback.签到返回()
    end,
    春节签到2026 = function()
        wait(function()
            tap("春节签到2026收下祝福")
        end, 2)
        return path.fallback.签到返回()
    end,
    限时开放许可 = function()
        wait(function() tap("开始作业") end, 1)
        wait(function()
            if findOne("面板") then return true end
            tap("开包skip")
        end, 10)
        -- disappear("面板", 1)
    end,
    感谢庆典返回 = function()
        wait(function() tap("感谢典点击领取") end, 1)
        wait(function()
            if findOne("面板") then return true end
            tap("开包skip")
        end, 10)
        -- disappear("面板", 1)
    end,
    愚人节剧情检测 = function()
        if not wait(function()
                if findOne("愚人节窗口关闭") then return true end
                path.跳过剧情()
                ssleep(.5)
            end, 15) then
            return
        end
    end,
    愚人节窗口关闭 = function()
        tap("愚人节窗口关闭")
    end,

    相谈室活动左上角返回 = function()
        tap("相谈室活动左上角返回")
        ssleep(.3)
    end,
    返回 = function()
        -- 基建内返回太快会卡
        local x = appear({
            "返回确认", "返回确认2", "返回确认3", "活动公告返回",
            "签到返回", "签到返回黄", "活动签到返回",
            "抽签返回", "战略返回", '限时开放许可', "限时幸运签",
            "线索传递界面", "阿米娅", "可露希尔", "生日设置返回", "愚人节剧情检测", "愚人节窗口关闭",
            -- "新春限时签到2025"
            '五周年专享月卡返回', '回望泰拉限时登录签到',
            --'小马宝莉签到领取'
            --"新年祝福返回", "国庆签到返回", '感谢庆典返回',
        }, .1)
        log.debug(x)
        if x then return tap(path.fallback[x]) end
        -- back()
        tap("返回")
    end,
    返回3 = function()
        -- 只有邮件与设置界面有白色返回
        tap("返回3")
        -- disappear("返回3", .5)
    end,
}

path.限时活动 = function(retry)
    -- if 1 then return end

    -- 只包含主页红点
    retry = retry or 0
    if retry > 10 then return end
    path.跳转("首页")
    log.debug("第" .. retry .. "次")

    local p = findAny({
        "面板限时活动", "面板限时活动2", "面板限时活动3",
        "面板限时活动4", "面板限时活动5", "面板限时活动6",
    })
    if p then
        tap(p, true)
        appear({
            '活动签到返回', '抽签返回', '限时开放许可',
            "限时幸运签", "月饼", '产业合作洽谈会',
            '红包', "祈愿牌返回", '五周年专享月卡返回',
            "生日设置返回", '国庆签到返回', '感谢庆典返回',
            "春节签到2026",
            "七周年限时幸运签", "限时幸运签20261101",
            '回望泰拉限时登录签到',
            --'小马宝莉签到领取',
            '夏日嘉年华赠送活动一20260801', '夏日嘉年华赠送活动二20260801',
        })
        if findOne('红包') then
            wait(function()
                if not findOne("红包") then return true end
                tap("红包")
            end, 5)
            ssleep(1)
            tap("红包")
            back()
        end
        if findOne('特别公开招募前往') then
            back()
            return
        end
    elseif findOne("面板赠送一次") and not disable_free_draw then
        tap("面板干员寻访")
        if not appear("赠送一次") then tap("寻访右") end
        if not appear("赠送一次") then tap("寻访右") end
        if not appear("赠送一次") then return end
        ssleep(.5)
        if not wait(function()
                if not findOne("赠送一次") then return true end
                tap("寻访一次")
                disappear("赠送一次", 1)
            end, 10) then
            return
        end
        if not appear("返回确认界面") then return end
        if not wait(function()
                if not findOne("返回确认界面") then return true end
                tap("右右确认")
            end, 2) then
            return
        end

        local last_time_see_home = time()
        if not wait(function()
                if findOne("主页") then last_time_see_home = time() end
                if time() - last_time_see_home > 1000 then return true end
                tap("开包skip")
            end, 15) then
            return
        end

        if cloud.enabled() then
            ssleep(1)
            captureqqimagedeliver("INFO", "活动单抽结果",
                "已成功使用每日单抽")
        end

        -- appear("主页", 2)
        -- disappear("主页", 10)
        if not wait(function()
                if findOne("主页") then return true end
                tap("开包skip")
            end, 15) then
            return
        end
    end
    log.debug()
    path.跳转("首页")
    log.debug()
    -- 需要点时间才能找到 面板限时活动2 与 单抽
    if not wait(function()
            if notify_sub_expire and not 月卡到期状态 and findAny({ "月卡即将到期", "月卡即将到期2" }) then
                captureqqimagedeliver("WARN", "月卡到期提醒", "月卡即将到期，请及时续费")
                log("月卡到期提醒发送")
                月卡到期状态 = true
            end
            if not findOne("面板") then return true end
            if findAny({
                    "面板限时活动", "面板限时活动2", "面板限时活动3",
                    "面板限时活动4", "面板限时活动5", "面板限时活动6",
                    "面板赠送一次",
                }) then
                return true
            end
        end, 1) then
        return
    end
    return path.限时活动(retry + 1)
end

path.账户数据保存 = function()
    if not root_mode then
        return
    end
    if new_change_account_plan and 快速切号功能状态 == false then
        log("未查询到保存的登录数据或数据已经失效", username)
        log(account_data)
        account_data[username] = {}
        if appid == "com.hypergryph.arknights" then
            local user_token = official_get_last_login()
            if user_token then
                log("官服登录保存登录数据ing")
                user_token = encodeBase64(user_token)
                account_data[username]["hyper"] = true
                account_data[username]["token"] = user_token
            end
        elseif appid == "com.hypergryph.arknights.bilibili" then
            local userid = bilibili_get_lastlogin_uid()
            if userid then
                log("b服登录保存userid", userid)
                account_data[username]["bili"] = true
                account_data[username]["userid"] = userid
            end
        end
    end
    save_local_config()
    return true
end

path.邮件收取 = function()
    if qqnotify_beforemail then
        path.跳转("首页")

        -- if disappear("面板", 1) then return path.邮件收取() end
        -- if findOne("正在提交反馈至神经") then return path.邮件收取() end
        captureqqimagedeliver("INFO", "邮件收取前",
            table.join(qqmessage, ' ') .. " 邮件收取前")
    end

    path.跳转("邮件")
    登录完成状态 = true
    local state = sample("邮件提示")
    if not wait(function()
            tap("收取所有邮件")
            if not findOne(state) then return true end
        end, 10) then
        return
    end

    -- 卡在邮件的获取
    local start_time = time()
    local last_time_tap_return = time()

    wait(function()
        local timeout = min(2, (time() - start_time) / 1000 * 2 / 10)
        -- local timeout = 0
        if appear({
                "开始唤醒", "账号登录", "返回确认3",
                "bilibili_framelayout_only", "framelayout_only",
            }, timeout) then
            return true
        end
        back()

        -- 每5秒按下返回，处理限时活动中领到干员/皮肤
        if time() - last_time_tap_return > 5000 then
            -- TODO:按返回在获得物资界面没用
            tap("返回", true)
            last_time_tap_return = time()
        end
    end, 30)
end

path.基建收获 = function()
    -- jump with zoom too
    path.跳转("基建")
    local x
    local max_retry = 5
    for i = 1, max_retry do
        x = appear({
            "正在提交反馈至神经", "基建灯泡蓝", "基建灯泡蓝2",
            "基建收获线索提示",
        }, 3)
        -- 没看到灯泡或线索提示
        if not x then
            log.debug()
            leaving_jump = true
            return
        end
        if table.includes({
                "基建收获线索提示", "正在提交反馈至神经",
            }, x) then
            disappear(x, 5)
            if i >= max_retry then
                log('unknown 140')
                return
            end
        else
            break
        end
    end

    log.debug()
    wait(function()
        if not findOne("进驻总览") then return true end
        tap("点击全部收取2")
        ssleep(.1)
        tap(x)
        ssleep(.1)
    end, 10)
    log.debug()

    --20260804 基建问题 循环执行太快 可能基建误点到干员修整
    wait(function()
        log.debug()
        if findAny({ "小蓝圈", "基建收获干员休整", "进驻总览", "训练室完成小蓝圈", "会客室线索小蓝圈" }) then return true end
        log.debug()
        tap("点击全部收取2")
        ssleep(.2)
    end, 10, .5)
    log(findAny({ "小蓝圈", "基建收获干员休整", "进驻总览" }))
    log.debug()

    if false and findOne("小蓝圈") and findOne("训练室") then
        tap("点击全部收取2")
        ssleep(.2)
        log.debug()
        zoom()
        if not wait(function()
                tap("训练室")
                log.debug()
                disappear("训练室", 1)
                if not findAny({ "进驻信息", "进驻信息选中" }) then
                    return true
                end
            end, 5) then
            return
        end

        -- if not appear({"进驻信息", "进驻信息选中"}) then return end

        if not wait(function(reset_wait_start_time)
                tap("贸易站进度")
                if findOne("正在提交反馈至神经") then
                    reset_wait_start_time()
                end
                if not findOne("主页") then return true end
            end, 5) then
            return
        end

        if not wait(function()
                tap("训练室")
                if findOne("隐藏") and findOne("返回") and
                    findAny({ "进驻信息", "进驻信息选中" }) then
                    return true
                end
            end, 5) then
            return
        end
        return
    end

    -- 回到进驻总览
    if not wait(function()
            if findOne("进驻总览") then return true end
            tap("基建右上角")
        end, 5) then
        return
    end

    leaving_jump = true
end

-- 跳转至由面板可到达的界面
-- 注意 从好友 以及 到采购中心的跳转
-- TODO 从好友跳转失败时有5秒等待
path.跳转 = function(x, disable_quick_jump, disable_postprocess)
    -- 存在嵌套跳转，加载开头应该可以？
    if prev_jump == "基建" and x ~= "基建" and collect_beforeleaving and
        not_first_time_jump then
        path.基建收获()
    end

    if findAny({ "生息演算_游戏设置页面", "生息演算_游戏设置弹窗", }) then
        back()
    end

    if findAny({ "喀兰贸易活动返回" }) then
        back()
    end

    -- 生息演算页面适配
    if extra_mode == "生息沙洲遗闻" and findOne("生息底栏烹饪按钮") then
        log("生息")
        if not wait(function()
                if not findOne("生息底栏烹饪按钮") then return true end
                tap("生息演算_全局_返回")
            end, 5) then
        end
    end


    if findOne("相谈室活动左上角返回") then
        wait(function()
            if not findOne("相谈室活动左上角返回") then return true end
            tap("相谈室活动左上角返回")
        end, 3)
    end

    if findOne("获得塔罗牌页面") then
        wait(function()
            if not findOne("获得塔罗牌页面") then return true end
            tap("塔罗牌关闭")
        end, 3)
        disappear("塔罗牌关闭", 3)
        ssleep(.5)
    end
    if hd_nickname == "SR" then
        if findOne('塔罗牌x') then
            wait(function()
                tap('塔罗牌x')
            end, 3, .2)
        else
            log('未找到 塔罗牌x')
        end
    else
        log('不是活动 SR')
    end
    -- if findOne("争锋频道首页") then
    --     back()
    --     ssleep(0.5)
    -- end

    -- 退出基建前截图
    if prev_jump == "基建" and x ~= "基建" and qqnotify_beforeleaving and
        not_first_time_jump then
        path.跳转("基建")
        captureqqimagedeliver("INFO", "基建离开前",
            table.join(qqmessage, ' ') .. " " .. "基建离开前")
    end

    not_first_time_jump = true

    local sign = {
        好友 = "个人名片",
        基建 = "进驻总览",
        公开招募 = function()
            return findOne("公开招募") and findOne("公开招募箭头")
        end,
        首页 = "面板",
        干员 = "干员界面",
        采购中心 = "可露希尔推荐",
        任务 = function()
            return findAny({ "任务第一个", "任务第一个2" })
        end,
        终端 = "主页",
        邮件 = function() return findOne("邮件信封") and findOne("返回3") end,
    }
    local plain = {
        邮件 = "面板邮件",
        好友 = "面板好友",
        干员 = "面板干员",
        基建 = "面板基建",
        公开招募 = "面板公开招募",
        首页 = nil,
        采购中心 = "面板采购中心",
        任务 = "面板任务",
        终端 = "面板作战",
    }
    local timeout = 20

    local target = sign[x]
    local home_target = x == "邮件" and "首页" or x

    -- direct quit
    if findOne(target) then
        log("before zoom", x)
        if x == "基建" and not disable_postprocess then zoom() end
        prev_jump = x
        repeat_fight_mode = false
        leaving_jump = false
        return true
    end

    log.debug(x, home_target)

    local bypass = function(t)
        log("bypass 基建返回确认", prev_jump)
        if prev_jump == "基建" and appear({ "返回确认", t }) == "返回确认" then
            if not wait(function()
                    if not findOne("返回确认") then return true end
                    tap("右确认")
                end, 5) then
                return
            end
        end
        log("bypass 基建返回确认", "end")
        return true
    end

    local p
    p = update(path.base, {
        面板 = function()
            p["主页"] = nil
            tap(plain[x])
            log.debug()
            if x == "基建" and appear("语音资源未下载", 1) then
                tap("左取消")
            end
            appear({
                target, "活动公告返回", "签到返回", "签到返回黄",
                "活动签到返回", "国庆签到返回", "抽签返回",
                "单选确认框", "返回3", "阿米娅", "生日设置返回",
                -- "新春限时签到2025"
            }, timeout)
            log.debug()
        end,
        主页 = function()
            if not wait(function()
                    local y = findAny({ "主页" })
                    tap(y)
                    -- TODO we can make this faster, gain .5s mostly
                    -- jump from 宿舍 to others
                    -- TODO .5 => .1 failed
                    if not y or disappear(y, .5) then
                        -- not y 表示 当前主页列表正在展开、收缩或停止，这时
                        if table.includes({ "任务", "好友", "首页", "干员" }, home_target) then
                            ssleep(.2)
                        end
                        log(home_target)
                        -- 一直按直到出现新状态
                        tap("主页列表" .. home_target)
                        tap("主页列表" .. home_target)

                        wait(function()
                            if not findAny({ "返回", "返回2" }) or
                                findAny({ "主页", "返回确认", "返回确认2" }) then
                                return true
                            end
                            tap("主页列表" .. home_target)
                        end, .5)

                        return true
                    end
                end, 5) then
                return
            end

            if not bypass(sign[home_target]) then return end
            log('wait appear', sign[home_target], timeout)
            local first_time_see_home
            if not wait(function()
                    if findOne(sign[home_target]) then
                        p["主页"] = nil
                        return true
                    end

                    if findOne("返回") then
                        -- log(458)
                        if not first_time_see_home then
                            first_time_see_home = time()
                        elseif (time() - first_time_see_home) > 1000 then
                            p["主页"] = nil
                            return true -- we see 返回 for some time, but target still not appear
                        end
                    else
                        first_time_see_home = nil
                    end
                end, timeout) then
                p["主页"] = nil
                return
            end
        end,
    })
    if x == prev_jump and x ~= "首页" or disable_quick_jump then p.主页 = nil end
    p[target] = function()
        if prev_jump == "基建" and x == "基建" and not leaving_jump then
            tap('返回')
            if not disappear(target, 1) then
                log("found804", target)
                return true
            end
            return
        end

        -- leaving_jump is true means we don't need to wait 1 seconds to ensure current state is 进驻总览
        -- leaving_jump will be true if the previous state is 返回确认, and we slow tap 返回 (0.5s interval)
        -- leaving_jump will be also true if previous job confirm it
        log("leaving_jump", leaving_jump)
        local t = very_slow_state_check and 10 or 1
        if not disappear(target, (prev_jump == "基建" and x == "基建" and
                not leaving_jump) and t or 0) then
            leaving_jump = false
            log("found", target)
            return true
        end
    end

    stay_in_dorm_once = x == "基建"

    -- 1分钟跳转失败
    log.debug(target, x)
    auto(p, path.fallback, 0, default_auto_timeout_second, true)
    log.debug()

    -- post processing especially for 基建
    if x == "基建" and not disable_postprocess then zoom() end

    -- 进入基建后截图
    if prev_jump ~= "基建" and x == "基建" and qqnotify_afterenter and
        not_first_time_jump then
        captureqqimagedeliver("INFO", "基建进入后",
            table.join(qqmessage, ' ') .. " " .. "基建进入后")
    end

    prev_jump = x

    -- disable repeat fight after any jump complete
    repeat_fight_mode = false
    log.debug()
end

start_time = parse_time("202101010400")

-- 对于单个用户的不同任务
update_state = function()
    car_checked = false

    启动界面卡住的时间 = nil
    基建黑屏卡住时间 = nil
    基建白屏卡住时间 = nil

    月卡到期状态 = false

    登录完成状态 = false

    save_token = false

    -- 禁用重复刷模式
    repeat_fight_mode = false
    pre_fight = nil

    -- 作战统计
    fight_history = {}
    --作战计数器
    fight_tick = 0
    no_success_one_loop = 0
    prev_jump = "基建"
    not_first_time_jump = false

    update_state_last_day = 0
    update_state_last_week = 0
    communication_enough = false
    jmfight_enough = false
    zero_san = false
    zero_san_hit = 0
    username_typed = false

    first_time_swipe = true
    jmfight_times = 0
    no_friend = false
    cur_fight = ''
    fight_failed_times = {}
    fight_hard_mode = {}
    zero_san = false
    login_error_times = 0
    login_times = 0
    login_time_history = {}

    local day = (parse_time() - start_time) // (24 * 3600)
    if day == update_state_last_day then return end
    communication_enough = false
    update_open_time()

    local week = (parse_time() - start_time) // (7 * 24 * 3600)
    if week == update_state_last_week then return end
    jmfight_enough = false
end

path.副手换人 = function()
    -- toast("副手换人还没修，等5秒提示消失")
    -- ssleep(5)
    -- if 1 then return end
    if only_change_assistant_at_Monday and tonumber(os.date("%w")) ~= 1 then return end
    path.跳转("基建")

    if not wait(function()
            if not findOne("进驻总览") or not findOne("缩放结束") then
                return true
            end
            tap("控制中枢")
        end, 5) then
        return
    end
    if not appear({ "进驻信息", "进驻信息选中" }) then return end
    if not wait(function()
            if not findAny({ "进驻信息", "进驻信息选中" }) then return true end
            tap("基建副手")
        end, 5) then
        return
    end

    for i = 1, 5 do
        if not wait(function()
                tap("基建副手列表" .. i)
                if findOne("副手确认蓝") then return true end
            end, 5) then
            return
        end

        if not wait(function()
                tap("干员选择列表7")
                if appear("副手第七干员选中", 1) then return true end
            end, 5) then
            return
        end

        if not wait(function()
                if not findOne("副手确认蓝") and findOne("基建副手简报") then
                    return true
                end
                tap("副手确认蓝")
            end, 5) then
            return
        end

        if not wait(function()
                tap("基建副手列表" .. i)
                if findOne("副手确认蓝") then return true end
            end, 5) then
            return
        end

        if not wait(function()
                tap("干员选择列表7")
                if appear("副手第七干员选中", 1) then return true end
            end, 5) then
            return
        end

        if not wait(function()
                tap("干员选择列表" .. (i + 1))
                if disappear("副手第七干员选中", 1) then return true end
            end, 5) then
            return
        end

        if not wait(function()
                if not findOne("副手确认蓝") and findOne("基建副手简报") then
                    return true
                end
                tap("副手确认蓝")
            end, 5) then
            return
        end
    end
end

sample = function(v)
    local ans = ''
    for _, p in pairs(point[v .. "采样列表"]) do
        p = point[p]
        ans = ans .. p[1] .. coord_delimeter .. p[2] .. coord_delimeter ..
            getColor(p[1], p[2]) .. point_delimeter
    end
    point.sample = ans:sub(1, #ans - #point_delimeter)
    rfl.sample = point2region(point.sample)
    first_point.sample = { rfl.sample[1], rfl.sample[2] }
    return "sample"
end

path.宿舍清空 = function()
    local f
    f = function(i)
        path.跳转("基建")

        if not wait(function()
                if not findOne("进驻总览") or not findOne("缩放结束") then
                    return true
                end
                tap("宿舍列表" .. i)
            end) then
            return
        end

        if not appear({ "进驻信息", "进驻信息选中" }, 5) then
            log.debug()
            return
        end
        path.基建确认进入设施()

        tap("清空选择")
        if not wait(function()
                if findOne("干员未选中") and findOne("第一干员未选中") then
                    return true
                end
                tap("清空选择")
            end, 5) then
            return
        end

        if not wait(function(reset_wait_start_time)
                if findAny({ "隐藏", "进驻信息", "进驻信息选中" }) then
                    return true
                end
                if findOne("正在提交反馈至神经") then
                    reset_wait_start_time()
                end
                tap("确认蓝")
            end, 5) then
            return
        end
    end
    for i = 1, 4 do f(i) end
end

path.宿舍换班 = function()
    local f
    local fiammetta_used = false
    f = function(i)
        if not wait(function()
                if findAny({ "筛选" }) then return true end
                if findOne("职业选择") then
                    ssleep(.5)
                    tap('职业选择')
                    ssleep(.5)
                end
                tap("宿舍列表" .. i)
            end) then
            return
        end


        local 进入宿舍并清空干员 = function()
            path.基建确认进入设施()

            tap("清空选择")
            if not wait(function()
                    if findOne("干员未选中") and findOne("第一干员未选中") then
                        return true
                    end
                    tap("清空选择")
                end, 5) then
                return
            end
        end
        local 确认干员选择 = function()
            if not wait(function(reset_wait_start_time)
                    if findAny({ "隐藏", "基建总览非工作区", "总览换班锁定编辑" }) then
                        return true
                    end
                    if findOne("正在提交反馈至神经") then
                        reset_wait_start_time()
                    end
                    tap("确认蓝")
                    ssleep(.8)
                    if findOne("正在提交反馈至神经") then
                        reset_wait_start_time()
                    end
                end, 5) then
                return
            end
        end

        log.debug()
        进入宿舍并清空干员()
        local operator
        -- 根据心情阈值选择
        operator = {}
        discoverWithOcr(operator, {}, 1, true)
        operator = table.filter(operator, function(x)
            return math.abs(x[3]) < shift_min_mood + 1
        end)
        log.debug(operator, shift_min_mood)
        if i < 4 and not not_use_ocr and fiammetta_used == false then
            local char_after_fiammetta
            if table.any(operator,
                    function(x)
                        if table.includes({ "可露希尔", "清流", "但书" }, x[6]) then
                            char_after_fiammetta = x[4]
                            return true
                        end
                    end) then
                tap(char_after_fiammetta)
                ssleep(.2)
                if not findOne("基建心情降序", .85) then tap("基建心情降序") end
                ssleep(.2)
                -- 取消选择需要被换心情的干员,防止识别错误
                tap("干员选择列表1")
                ssleep(.2)
                log.debug()
                if chooseOperator("肥鸭") then
                    ssleep(.4)
                    tap("干员选择列表1") -- 这时候是肥鸭,干员,需要把他们换个顺序
                    ssleep(.2)
                    tap("基建心情降序")
                    ssleep(.2)
                    -- 取消选择
                    tap("清空选择")
                    ssleep(.2)
                    -- 重置顺序为干员,肥鸭
                    tap("干员选择列表2")
                    ssleep(.1)
                    tap("干员选择列表1")
                    ssleep(.1)
                    确认干员选择()
                    ssleep(.2)
                    fiammetta_used = true
                    isCharExsit["肥鸭"] = true
                    log.debug()
                    if not wait(function()
                            if findOne("筛选") then return true end
                            tap("宿舍列表" .. i)
                        end) then
                        return
                    end
                    进入宿舍并清空干员()
                    operator = {}
                    discover(operator, {}, 1, true)
                    log.debug(operator, shift_min_mood)
                    operator = table.filter(operator, function(x)
                        return math.abs(x[3]) < shift_min_mood + 1
                    end)
                else
                    fiammetta_used = true -- 找不到也当做用过了
                    ssleep(.1)
                    log.warn("未找到满心情菲亚梅塔")
                    if findOne("基建心情降序", .85) then tap("基建心情降序") end
                    ssleep(.3)
                end
            end
        end

        operator = map(function(x) return x[4] end, operator)
        operator = table.slice(operator, 1, 5)

        -- operator = table.slice(table.extend(operator, map(
        --                                       function(x)
        --     return "干员选择列表" .. x
        --   end, range(1, 5))), 1, 5)

        --log(820, operator)

        if #operator > 0 and not wait(function()
                if not findOne("干员未选中") then return true end
                -- 慢机仍会漏换， miui13也是
                -- 加了心情检测这儿还要等？
                ssleep(0.25)
                -- tapAll(operator)
                for _, v in pairs(operator) do
                    tap(v)
                    training_check_time = training_check_time or 0.15
                    ssleep(training_check_time)
                    if disable_training_shift and is_training() then -- 训练室干员跳过
                        tap(v)
                    end
                end
                disappear("干员未选中", 2)
            end, 5) then
            return
        end

        log.debug(#operator)

        确认干员选择()
    end
    path.跳转("基建")
    if not wait(function()
            if findOne("基建总览工作区") then return true end
            tap("进驻总览")
            ssleep(.2)
            if findOne("教程关闭") then
                tap("教程关闭")
                ssleep(.2)
            end
        end, 10) then
        return
    end
    if not wait(function()
            if findOne("基建总览非工作区") then return true end
            tap("基建总览非工作区")
            ssleep(.5)
        end, 10) then
        return
    end
    for i = 1, 4 do f(i) end
end

path.基建信息获取new = function()
    dormitoryCapacity = 0
    dormitoryLevelSum = 0
    dormitoryNum = 0
    goldStationNum = 0
    tradingStationNum = 0
    powerStationNum = 0
    virtralPowerStationNum = powerStationNum
    totalStationLevel = 0

    dormitoryStation = {}
    dormitoryLevel = {}
    powerStation = {}
    powerStationLevel = {}
    tradingStation = {}
    tradingStationLevel = {}
    manufacturingStation = {}
    manufacturingStationLevel = {}

    isCharExsit = {} -- 跨设施组合验证
    path.跳转("基建")
    if not wait(function()
            if findOne("基建总览工作区") then return true end
            tap("进驻总览")
            ssleep(.2)
            if findOne("教程关闭") then
                tap("教程关闭")
                ssleep(.2)
            end
        end, 10) then
        return
    end
    ssleep(.2)
    基建卡片数据 = {}
    -- 数据实例 {{{x,y,名称,等级,},{卡片2数据}},{第二页},{第三页}}
    for i = 1, 5 do
        -- 基建卡片数据[i] = {}
        local start_x = scale(920)
        local start_y = scale(161)
        local end_y = screen.height - scale(200)
        local is_jcard = false
        local 是否已经记录 = false

        for j = start_y, end_y, 2 do
            if (not is_jcard) and compareColor(start_x, j, "#313131", default_findcolor_confidence) then
                is_jcard = true
                local 卡片名称ocr范围 = { scale(649), j, scale(814), j + scale(60) }
                local 卡片名称 = ocr(卡片名称ocr范围)
                卡片名称 = 卡片名称[1].text
                local name2card = {
                    ["客室"] = "会客室",
                    ["宿舍"] = "宿舍",
                    ["制造"] = "制造站",
                    ["贸易"] = "贸易站",
                    ["电"] = "发电站",
                    ["控制"] = "控制中枢",
                    ["公"] = "办公室",
                    ["训练"] = "训练室",
                    ["加工"] = "加工站"
                }
                for 关键字, 新名称 in pairs(name2card) do
                    if string.finds(卡片名称, { 关键字 }) then
                        卡片名称 = 新名称
                        break
                    end
                end

                local 获取等级信息 = function(基建卡片name)
                    local 基建数据 = {
                        制造站 = { "#FFCC00", 784 },
                        贸易站 = { "#33CCFF", 784 },
                        发电站 = { "#CCFF66", 784 },
                        办公室 = { "#FFFFFF", 784 },
                        控制中枢 = { "#FFFFFF", 822 },
                        训练室 = { "#FFFFFF", 784 },
                        加工站 = { "#FFFFFF", 784 },
                        会客室 = { "#FFFFFF", 784 },
                        宿舍 = { "#FFFFFF", 765 },
                    }
                    local start_y_c = j + scale(36)
                    local start_x_c = 基建数据[基建卡片name][2]
                    local end_x_c = start_x_c + scale(85)
                    local is_find_node = false
                    local card_level = 0
                    for k = start_x_c, end_x_c, 1 do
                        if (not is_find_node) and compareColor(k, start_y_c, 基建数据[基建卡片name][1],
                                default_findcolor_confidence) then
                            card_level = card_level + 1
                            is_find_node = true
                        end
                        if is_find_node and not (compareColor(k, start_y_c, 基建数据[基建卡片name][1],
                                default_findcolor_confidence)) then
                            is_find_node = false
                        end
                    end
                    return card_level
                end

                local card_level = 获取等级信息(卡片名称)
                log(start_x, j, 卡片名称, card_level)
                基建卡片数据[卡片名称] = 基建卡片数据[卡片名称] or {}
                table.insert(基建卡片数据[卡片名称], { start_x, j + scale(10), i, card_level })
            end
            if is_jcard and (not compareColor(start_x, j, "#313131", default_findcolor_confidence)) then
                is_jcard = false
            end
        end
        log(基建卡片数据)
        ssleep(1000)

        path.基建总览翻页()
    end
    -- path.基建总览翻页()
end

path.基建总览翻页_new = function()
    local flipd = 150
    local flips = 50
    local duration = flipd + flips + 50
    local x1 = screen.width - scale(1280 - 500)
    local x2 = x1 + scale(100)
    local x3 = screen.width - 1
    local y1 = scale(150)
    local y2 = screen.height * 0.82
    local paths = {
        { point = { { x1, y1 }, { x3, y1 } }, duration = duration },
        { point = { { x1, y2 }, { x2, y2 } }, duration = flipd,   start = flips },
    }
    -- sleep(100)
    gesture(paths)
    sleep(duration + 50)
    -- 可能还是需要按下
    tap("入驻干员右侧")
    sleep(100)
end

-- 各站数量与等级，直接全局变量
path.基建信息获取 = function(retry)
    dormitoryCapacity = 0
    dormitoryLevelSum = 0
    dormitoryNum = 0
    goldStationNum = 0
    tradingStationNum = 0
    powerStationNum = 0
    virtralPowerStationNum = powerStationNum
    totalStationLevel = 0

    dormitoryStation = {}
    dormitoryLevel = {}
    powerStation = {}
    powerStationLevel = {}
    tradingStation = {}
    tradingStationLevel = {}
    manufacturingStation = {}
    manufacturingStationLevel = {}

    isCharExsit = {} -- 跨设施组合验证

    path.跳转("基建")
    -- 再执行一次
    zoom()
    local type2color = {
        制造站 = "#FFCC00",
        贸易站 = "#33CCFF",
        发电站 = "#CCFF66",
    }
    local f
    keepCapture()
    f = function(i)
        local x, y = table.unpack(point["基建列表" .. i])
        local station, stationLevel
        for type, color in pairs(type2color) do
            if type == "制造站" then
                station = manufacturingStation
                stationLevel = manufacturingStationLevel
            elseif type == "贸易站" then
                station = tradingStation
                stationLevel = tradingStationLevel
            elseif type == "发电站" then
                station = powerStation
                stationLevel = powerStationLevel
            end

            -- 检测kernel，因为可能被条纹挡住
            if (compareColor(x, y, color, default_findcolor_confidence) or
                    compareColor(x - scale(5), y - scale(10), color,
                        default_findcolor_confidence) or
                    compareColor(x - scale(5), y + scale(10), color,
                        default_findcolor_confidence) or
                    compareColor(x + scale(5), y + scale(10), color,
                        default_findcolor_confidence) or
                    compareColor(x - scale(5), y - scale(10), color,
                        default_findcolor_confidence)) then
                table.insert(station, { x, y })
                table.insert(stationLevel, 3)

                for j = 0, 2 do
                    local x, y = table.unpack(point["基建等级列表" .. i * 3 - j])
                    -- log(973,x,y)
                    if (compareColor(x, y, color, default_findcolor_confidence) or
                            compareColor(x - scale(1), y - scale(3), color,
                                default_findcolor_confidence) or
                            compareColor(x - scale(1), y + scale(3), color,
                                default_findcolor_confidence) or
                            compareColor(x + scale(1), y + scale(3), color,
                                default_findcolor_confidence) or
                            compareColor(x - scale(1), y - scale(3), color,
                                default_findcolor_confidence)) then
                        stationLevel[#stationLevel] = 3 - j
                        break
                    end
                end

                break
            end
        end
    end

    for i = 1, 9 do f(i) end

    f = function(i)
        local color = '#FFFFFF'
        local stationLevel
        stationLevel = dormitoryLevel
        for j = 0, 4 do
            local x, y = table.unpack(point["宿舍等级列表" .. i * 5 - j])
            if (compareColor(x, y, color, default_findcolor_confidence) or
                    compareColor(x - scale(1), y - scale(3), color,
                        default_findcolor_confidence) or
                    compareColor(x - scale(1), y + scale(3), color,
                        default_findcolor_confidence) or
                    compareColor(x + scale(1), y + scale(3), color,
                        default_findcolor_confidence) or
                    compareColor(x - scale(1), y - scale(3), color,
                        default_findcolor_confidence)) then
                table.insert(stationLevel, 5 - j)
                break
            end
        end
    end

    for i = 1, 4 do f(i) end

    dormitoryNum = #dormitoryLevel
    dormitoryCapacity = dormitoryNum * 5
    dormitoryLevelSum = table.sum(dormitoryLevel)

    -- powerStationLevel = map(function() return 3 end, powerStation)
    powerStationNum = #powerStation
    virtralPowerStationNum = powerStationNum
    -- tradingStationLevel = map(function() return 3 end, tradingStation)
    tradingStationNum = #tradingStation

    -- manufacturingStationLevel = map(function() return 3 end, manufacturingStation)
    manufacturingStationNum = #manufacturingStation

    -- 控制中枢与右侧满设施 按其他站等级情况近似
    totalStationLevel = table.sum(table.cat({
        dormitoryLevel, powerStationLevel, manufacturingStationLevel,
        tradingStationLevel,
    }))
    totalStationLevel = totalStationLevel +
        math.round((5 + 15) * totalStationLevel / (47))

    log("totalStationLevel", totalStationLevel)
    -- exit()

    releaseCapture()
    log(powerStation, tradingStation, manufacturingStation, dormitoryStation)
    log.debug(tradingStationLevel, manufacturingStationLevel, powerStationLevel,
        dormitoryLevel)
    local retry = retry or 0
    if retry > 2 then return end
    if tradingStationLevel == {} or manufacturingStationLevel == {} or powerStationLevel == {} then
        log("基建信息获取可能出错")
        return path.基建信息获取(retry + 1)
    end
    if #tradingStationLevel + #manufacturingStationLevel + #powerStationLevel < 9 then
        log.warn("基建信息获取可能失败2")
        return path.基建信息获取(retry + 3)
    end
end

---@param trading any 是否是贸易站
path.制造换班 = function(trading)
    -- if not debug then return end
    local station_color = trading and "#33CCFF" or "#FFCC00"
    local type
    local good
    local good2type = {
        经验站 = "作战记录",
        赤金站 = "贵金属",
        源石站 = "源石",
        芯片站 = "芯片",
        开采协力 = "源石",
        龙门商法 = "贵金属",
    }
    local station = trading and tradingStation or manufacturingStation
    local stationLevel = trading and tradingStationLevel or
        manufacturingStationLevel
    path.跳转("基建")
    -- 进入制造站
    if not wait(function()
            if not findOne("进驻总览") or not findOne("缩放结束") then
                return true
            end
            tap(station[1])
        end) then
        return
    end

    if not appear({ "进驻信息", "进驻信息选中" }, 5) then return end

    wait(function()
        if trading and findAny({ "未进驻设施列表1", "贸易站设施列表1" }) then return true end
        if not trading and findAny({ "未进驻设施列表1", "制造站设施列表1" }) then return true end
        tap("贸易站进度")
    end, 5)
    ssleep(.2)

    local f
    f = function(i, station, stationLevel)
        -- local x, y = table.unpack(point["基建列表" .. i])
        -- -- 检测kernel，因为可能被条纹挡住
        -- if not (compareColor(x, y, station_color, default_findcolor_confidence) or
        --   compareColor(x - scale(5), y - scale(10), station_color,
        --                default_findcolor_confidence) or
        --   compareColor(x - scale(5), y + scale(10), station_color,
        --                default_findcolor_confidence) or
        --   compareColor(x + scale(5), y + scale(10), station_color,
        --                default_findcolor_confidence) or
        --   compareColor(x - scale(5), y - scale(10), station_color,
        --                default_findcolor_confidence)) then
        --   log("skip", i)
        --   return
        -- end

        if not wait(function()
                if trading and findOne("贸易站设施列表" .. i) then return true end
                if not trading and findOne("制造站设施列表" .. i) then return true end
                tap(station)
                ssleep(.5)
            end, 8) then
            return
        end

        local 制造站换班短路 = function()
            ssleep(.3)
            for i = 1, stationLevel do
                if findOne("制造站缺人列表" .. i) then return end
            end
            local text = ocro("制造站效率ocr范围")
            log("制造站效率", text)
            local value = tonumber(string.sub(text, 2))
            if not value then return end
            log(value / stationLevel, manu_shift_short_circuit_threshold)
            if value / stationLevel > manu_shift_short_circuit_threshold then
                log("当前制造站满员并且效率高于阈值，跳过换班")
                return true
            end
        end

        if manu_shift_short_circuit and not not_use_ocr and not trading and not isCharExsit["歌蕾蒂娅"] then
            if 制造站换班短路() then return end
        end

        local chip2book_needed = false
        -- 制造站需要确认产品类型
        if not trading then
            good = findAny({ "赤金站", "源石站", "芯片站", "经验站" })
            if good == '芯片站' and findOne("芯片站已完成") then
                good = "赤金站"
                chip2book_needed = true
            end
            -- 确认类型
            -- 计算赤金站数量，用于贸易站技能计算
            if good == "赤金站" then goldStationNum = goldStationNum + 1 end
            log.debug(good)
            if not good then
                log("not support", i)
                return
            end
            type = good2type[good]
            log.debug(type)
            if not disappear("制造站补货通知", 10) then return end

            -- 制造站进入干员列表
            if not wait(function()
                    if findOne("确认蓝") then return true end
                    tap("设施列表第二个干员")
                end, 5) then
                return
            end
        end

        -- 贸易站需要确认产品类型
        if trading then
            good = findAny({ "龙门商法", "开采协力" }) or "龙门商法"

            -- 确认类型
            log.debug(good)
            if not good then
                log("not support", i)
                return
            end
            type = good2type[good]
            log.debug(type)
            if not disappear("制造站补货通知", 10) then return end

            -- 贸易站进入干员列表
            if not wait(function()
                    if findOne("确认蓝") then return true end
                    tap("设施列表第一个干员")
                end, 5) then
                return
            end
        end

        local start_time = time()
        if not wait(function()
                if findOne("干员未选中") and findOne("第一干员未选中") then
                    return true
                end
                if time() - start_time > 1000 then
                    tap("干员选择列表1")
                    start_time = time()
                end
                tap("清空选择")
            end, 5) then
            log.debug()
            return
        end

        log.debug(tradingStationLevel, manufacturingStationLevel, powerStationLevel,
            dormitoryLevel)

        local stationType = trading and "贸易站" or "制造站"
        chooseOperator(stationType, type, stationLevel, tradingStationNum,
            virtralPowerStationNum, dormitoryCapacity, dormitoryLevelSum,
            goldStationNum, totalStationLevel)

        wait(function(reset_wait_start_time)
            tap("确认蓝")
            if trading and findOne("贸易站设施列表" .. i, .9) then return true end
            if not trading and findOne("制造站设施列表" .. i, .9) then return true end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
        end, 5)

        -- 源石站补货
        if good == "源石站" then
            wait(function()
                tap("制造站最多")
                if findOne("制造站执行更改") then return true end
            end, 10)
            wait(function()
                ssleep(.2)
                tap("制造站执行更改")
                if disappear("制造站执行更改", 1) then return true end
            end, 10)
        end

        -- 芯片换经验
        if chip2book_needed then
            local chip2book = function()
                if not wait(function()
                        tap("芯片站")
                        if not findOne("制造站设施列表1") then return true end
                    end, 5) then
                    return
                end

                if not wait(function()
                        tap("芯片站选赤金类")
                        if findOne("芯片站选赤金") then return true end
                    end, 5) then
                    return
                end

                if not wait(function()
                        tap("芯片站选赤金")
                        if findOne("制造站执行更改") then return true end
                    end, 5) then
                    return
                end

                if not wait(function()
                        tap("制造站最多")
                        tap("制造站执行更改")
                        if not findOne("制造站设施列表1") then return true end
                    end, 5) then
                    return
                end

                if not wait(function(reset_wait_start_time)
                        tap("右确认")
                        if appear("制造站设施列表1", 1) then return true end
                        if findOne("正在提交反馈至神经") then
                            reset_wait_start_time()
                        end
                    end, 5) then
                    return
                end

                return true
            end
            chip2book()
        end
    end

    -- 找到所有制造站

    for i = 1, #station do f(i, point["制造贸易站左侧列表" .. i], stationLevel[i]) end
end

path.贸易换班 = function()
    return path.制造换班(true)
end

path.总览换班 = function()
    path.跳转("基建")
    if not wait(function()
            if findOne("基建总览工作区") then return true end
            tap("进驻总览")
            ssleep(.2)
            if findOne("教程关闭") then
                tap("教程关闭")
                ssleep(.2)
            end
        end, 10) then
        return
    end

    path.控制中枢换班()
    log.debug()

    path.跳转("基建")
    if not wait(function()
            if findOne("基建总览工作区") then return true end
            tap("进驻总览")
            ssleep(.2)
        end, 10) then
        return
    end
    path.会客厅换班(nil, true)
    ssleep(.2)

    if not wait(function()
            if findOne("基建总览非工作区") then return true end
            tap("基建总览非工作区")
            ssleep(.5)
        end, 10) then
        return
    end
    log.debug()

    if appearTap("总览换班锁定编辑", 1.5) then
        ssleep(.5)
        appearTap("总览换班锁定清空", 3)
        ssleep(.5)
        tap("总览换班锁定确认")
    end

    wait(function()
        if findOne("总览换班锁定编辑") then return true end
        tap("总览换班锁定确认")
        ssleep(.5)
    end, 3)

    appear("基建总览非工作区")
    if not wait(function()
            if findOne("基建干员休整灰") and findOne("基建总览非工作区") then
                ssleep(.5) -- 稍微等banner消失
                return true
            end
            tap("基建干员休整")
            ssleep(.2)
            disappear("正在释放神经递质", 5)
        end, 10) then
        return
    end

    local f2 = function() -- 迷迭香配套换班,换上塑心爱丽丝车尔尼
        -- 进入最后一间宿舍
        log.debug("迷迭香宿舍换班")
        if not wait(function()
                if findOne("确认蓝") then return true end
                if findOne("基建总览非工作区") then
                    tap("宿舍列表4")
                end
            end, 10) then
            return
        end

        if not findOne("确认蓝") then return true end
        local limit = findOne("清空选择") and 5 or 1
        tap("清空选择")
        if not wait(function()
                if findOne("干员未选中") and findOne("第一干员未选中") then
                    return true
                end
                tap("清空选择")
            end, 5) then
            return
        end

        local stationType = "宿舍"

        ssleep(.2)
        tap("基建技能排序")
        ssleep(.2)
        tap("基建换班筛选")
        wait(function()
            if findOne("基建换班筛选弹出窗口") then
                ssleep(.1)
                tap("基建换班筛选未进驻")
                return true
            end
        end, 5)
        ssleep(.2)
        chooseOperator(stationType)
        ssleep(.2)
        tap("基建心情排序")
        ssleep(.2)
        tap("基建心情排序")
        ssleep(.2)
        local start_time = time()

        if not wait(function()
                if findOne("干员未选中") and findOne("第一干员未选中") then
                    return true
                end
                if time() - start_time > 1000 then
                    tap("干员选择列表1")
                    start_time = time()
                end
                tap("清空选择")
            end, 5) then
            log.debug()
            return
        end

        log("limit", limit)

        local operator = {}
        discover(operator, {}, 1, true)
        log.debug(operator)
        operator = table.filter(operator, function(x) return x[3] >= 0 end)
        operator = map(function(x) return x[4] end, operator)
        operator = table.slice(operator, 1, limit)

        if not wait(function()
                if not findOne("干员未选中") then return true end

                -- 不得不等，不然不按序
                -- 不用等，因为加了异格检测需要时间？
                ssleep(0.25)
                tapAll(operator)
                disappear("干员未选中", 2)
            end, 5) then
            return
        end

        if not wait(function(reset_wait_start_time)
                if findAny({ "基建总览非工作区", "基建总览干员休整" }) then return true end
                tap("确认蓝")
                ssleep(.8) --点太快点到休整就白换了
                if findOne("正在提交反馈至神经") then
                    reset_wait_start_time()
                end
            end, 3) then
            return
        end
    end

    local 总次数 = 0

    -- local first_look = false
    -- if disable_control_shift and disable_meeting_shift then first_look = true end
    local f = function()
        -- 0.1 是 从干员列表退出后 取消连续点击 保证滑动手势有效
        -- 0.5 是 首次进入界面时 需要多点时间
        if 总次数 > 5 then return end
        -- local timeout = (first_look and .5 or .25)
        local timeout = .25
        local p
        log.debug("普通宿舍换班")
        总次数 = 总次数 + 1
        -- first_look = false
        -- 至少做两次"入驻干员"检测，慢机只靠timeout不够可能，强制加一次
        if not appear("入驻干员", timeout) and findOne("基建总览非工作区") and
            not findOne("入驻干员") then
            log("无需入驻干员")
            return
        end

        local last_time_see_plus = time()
        if not wait(function()
                if findOne("确认蓝") then return true end
                if findOne("基建总览非工作区") then
                    p = findOne("入驻干员")
                    if p then
                        tap(p)
                        last_time_see_plus = time()
                    elseif time() - last_time_see_plus > 5000 then
                        return true
                    end
                end
            end, 10) then
            return
        end

        if not findOne("确认蓝") then return true end

        tap("基建换班筛选")
        wait(function()
            if findOne("基建换班筛选弹出窗口") then
                ssleep(.1)
                tap("基建换班筛选未进驻")
                return true
            end
        end, 5)
        ssleep(.2)
        wait(function()
            if findOne("基建心情升序") then
                return true
            end
            tap("基建心情排序")
        end, 5)

        tap("清空选择")
        ssleep(.2)
        --选前5
        local operator = map(function(x) return "干员选择列表" .. x end,
            range(1, 5))

        if #operator > 0 and not wait(function()
                if not findOne("干员未选中") then return true end
                ssleep(0.25)
                -- tapAll(operator)
                for _, v in pairs(operator) do
                    tap(v)
                    training_check_time = training_check_time or 0.15
                    ssleep(training_check_time)
                    if disable_training_shift and is_training() then -- 训练室干员跳过
                        log("训练室干员跳过")
                        tap(v)
                    end
                end
                disappear("干员未选中", 2)
            end, 5) then
            return
        end

        if not wait(function(reset_wait_start_time)
                if not findOne("确认蓝") then return true end
                tap("确认蓝")
                ssleep(1) --点太快点到休整就白换了
                if findOne("正在提交反馈至神经") then
                    reset_wait_start_time()
                end
            end, 5) then
            return true
        end
        ssleep(1)
        return true
    end
    appear("基建总览非工作区", .2)
    for i = 1, 4 do
        if findOne("基建总览非工作区") then
            ssleep(.5)
        elseif findOne("确认蓝") then
            back()
            ssleep(1)
            if not appear("基建总览非工作区", 3) then
                table.insert(qqmessage, "总览换班失败")
                return
            end
        else
            table.insert(qqmessage, "总览换班失败2")
            return
        end
        if i == 4 and (isCharExsit["迷迭香"] or isCharExsit["絮雨"] or isCharExsit["鸿雪"]) then
            f2()
        else
            if findOne("宿舍未满员列表" .. i) then
                log.debug("换第" .. i .. "间宿舍")
                wait(function()
                    if findOne("确认蓝") then return true end
                    tap("宿舍未满员列表" .. i)
                    ssleep(.5)
                end, 5)
                f()
            end
        end
        log.debug()
        appear("基建总览非工作区", 3)
        if findOne("确认蓝") then
            back()
            appear("基建总览非工作区", 3)
        end
    end
end

path.重置控制中枢位置 = function()
    if appear({ "基建总览非工作区", "基建总览工作区" }, 2) then
        ssleep(.15)
        tap("返回")
        if not appear("进驻总览", 5) then return end
        if not wait(function()
                if findOne("基建总览工作区") then return true end
                tap("进驻总览")
                ssleep(.2)
                if findOne("教程关闭") then
                    tap("教程关闭")
                    ssleep(.2)
                end
            end, 10) then
            return
        end
    else
        return
    end
end

path.基建确认进入设施 = function()
    if not wait(function()
            if findOne("筛选") then return true end
            if findOne("职业选择") then
                ssleep(.5)
                tap('职业选择')
                ssleep(.5)
            end
            if findOne("进驻信息选中") then
                wait(function()
                    if findOne("筛选") then return true end
                    if findOne("职业选择") then
                        ssleep(.5)
                        tap('职业选择')
                        ssleep(.5)
                    end
                    tap("进驻第一人")
                end, 2)
            elseif findOne("进驻信息") then
                tap("进驻信息")
                ssleep(.2)
                wait(function()
                    if findOne("筛选") then return true end
                    if findOne("职业选择") then
                        ssleep(.5)
                        tap('职业选择')
                        ssleep(.5)
                    end
                    tap("进驻第一人")
                end, 3)
            end
        end, 7) then
        return
    end
end

path.基建总览翻页 = function()
    local flipd = 150
    local flips = 50
    local duration = flipd + flips + 50
    local x1 = screen.width - scale(1280 - 500)
    local x2 = x1 + scale(100)
    local x3 = screen.width - 1
    local y1 = scale(150)
    local y2 = screen.height - scale(300)
    local paths = {
        { point = { { x1, y1 }, { x3, y1 } }, duration = duration },
        { point = { { x1, y2 }, { x2, y2 } }, duration = flipd,   start = flips },
    }
    -- sleep(100)
    gesture(paths)
    sleep(duration + 50)
    -- 可能还是需要按下
    tap("入驻干员右侧")
    -- 不用的话，大分辨率还是有可能出现错过加号
    sleep(100)
end

path.基建换班 = function()
    -- TODO 掉线需要重跑而非继续
    path.基建信息获取()
    path.宿舍换班()
    path.发电站换班()
    path.办公室换班()
    path.跳转("基建")
    if not wait(function()
            if findOne("基建总览工作区") then return true end
            tap("进驻总览")
            ssleep(.2)
            if findOne("教程关闭") then
                tap("教程关闭")
                ssleep(.2)
            end
        end, 10) then
        return
    end
    path.控制中枢换班(1)
    -- path.会客厅换班()
    path.制造换班()
    path.贸易换班()
    path.总览换班()
    path.回收站换班()
end

path.控制中枢换班 = function(force_change)
    return path.会客厅换班("控制中枢", force_change)
end

path.发电站换班 = function()
    local station_color = "#CCFF66"
    local type
    local good
    local p
    local f = function(i, station, stationLevel)
        path.跳转("基建")
        -- 进入发电站
        if not wait(function()
                if not findOne("进驻总览") or not findOne("缩放结束") then
                    return true
                end
                tap(station)
            end) then
            return
        end

        if not appear({ "进驻信息", "进驻信息选中" }, 5) then return end
        path.基建确认进入设施()

        if not wait(function()
                if findOne("干员未选中") and findOne("第一干员未选中") then
                    return true
                end
                tap("第一干员未选中")
                ssleep(.5)
            end, 7) then
            log("发电站超时")
            return
        end

        log.debug(tradingStationLevel, manufacturingStationLevel, powerStationLevel,
            dormitoryLevel)

        local stationType = "发电站"
        chooseOperator(stationType, type, stationLevel, tradingStationNum,
            virtralPowerStationNum, dormitoryCapacity, dormitoryLevelSum,
            goldStationNum, totalStationLevel)

        wait(function(reset_wait_start_time)
            tap("确认蓝")
            if findAny({ "进驻信息", "进驻信息选中", "基建总览工作区" }) then
                return true
            end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
        end, 5)
    end
    wait(function()
        tap("基建总览工作区")
        ssleep(.2)
        if findOne("基建总览工作区") then return true end
    end, 5)
    ssleep(.2)
    for i = 1, 4 do
        path.基建总览翻页()
        p = findOne("基建总览发电站")
        log(p)
        if p then break end
    end
    local f1 = function(i, station, stationLevel)
        -- 进入发电站
        if not wait(function()
                if findOne("筛选") then return true end
                tap(station)
            end) then
            return
        end

        path.基建确认进入设施()

        if not wait(function()
                if findOne("干员未选中") and findOne("第一干员未选中") then
                    return true
                end
                tap("第一干员未选中")
                ssleep(.5)
            end, 7) then
            log("发电站超时")
            return
        end

        log.debug(tradingStationLevel, manufacturingStationLevel, powerStationLevel,
            dormitoryLevel)

        local stationType = "发电站"
        chooseOperator(stationType, type, stationLevel, tradingStationNum,
            virtralPowerStationNum, dormitoryCapacity, dormitoryLevelSum,
            goldStationNum, totalStationLevel)

        wait(function(reset_wait_start_time)
            if findOne("基建总览工作区") then return true end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            tap("确认蓝")
            ssleep(.8)
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
        end, 5)
    end
    -- 所有制造站位置
    local station = powerStation
    if p then
        f = f1
        for i = 1, #powerStation do
            station[i] = { p[1] + scale(376), --标志到第一个干员的横坐标差值
                p[2] + i * scale(238) - scale(100) }
        end
    end

    local stationLevel = powerStationLevel

    local f2

    for i = 1, #station do f(i, station[i], stationLevel[i]) end
end

path.办公室换班 = function(stationType)
    --if 1 then return end
    stationType = stationType or "办公室"
    local p = stationType
    path.跳转("基建")
    ssleep(0.5)
    -- 进办公室
    if not wait(function()
            if not findOne("进驻总览") or not findOne("缩放结束") then
                return true
            end
            tap(p)
        end) then
        log.debug()
        return
    end

    path.基建确认进入设施()

    if not wait(function()
            if findOne("确认蓝") then return true end
            tap("制造站进度")
        end, 10) then
        log.debug()
        return
    end
    ssleep(.5)
    -- 如果第一个干员被选中,取消选择
    if not wait(function()
            if findOne("干员未选中") and findOne("第一干员未选中") then
                return true
            end
            tap("第一干员未选中")
            ssleep(.5)
        end, 7) then
        log("发电站超时")
        return
    end

    chooseOperator(stationType, type, stationLevel, tradingStationNum,
        virtralPowerStationNum, dormitoryCapacity, dormitoryLevelSum,
        goldStationNum, totalStationLevel)

    if not wait(function(reset_wait_start_time)
            if findAny({ "进驻信息", "进驻信息选中", "基建总览工作区" }) then
                return true
            end
            tap("确认蓝")
            ssleep(.8)
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
        end, 3) then
        log.debug()
        return
    end
end

path.训练室换班 = function(stationType, char_type, target_level)
    stationType = stationType or "训练室"

    -- 训练室内换班
    appear("干员技能专精页面", 3)
    if not wait(function()
            if findOne("筛选") then return true end
            if findOne("职业选择") then
                ssleep(.5)
                tap('职业选择')
                ssleep(.5)
            end
            tap("选择陪练干员")
            ssleep(.2)
        end, 5) then
        return
    end

    path.基建确认进入设施()

    if not wait(function()
            if findOne("干员未选中") and findOne("第一干员未选中") then
                return true
            end
            tap("第一干员未选中")
            ssleep(.5)
        end, 7) then
        log("训练室超时")
        return
    end

    chooseOperator(stationType, char_type, target_level, tradingStationNum,
        virtralPowerStationNum, dormitoryCapacity, dormitoryLevelSum,
        goldStationNum, totalStationLevel)

    if not wait(function(reset_wait_start_time)
            tap("确认蓝")
            if findAny({ "隐藏", "进驻信息", "进驻信息选中" }) then
                return true
            end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
        end, 3) then
        return
    end
end

path.加工站选人 = function(stationType, material_id, material_level)
    --根据需要合成的材料换人,而不是总体基建效率
    stationType = stationType or "加工站"
    if not appear("加工站", 2) then return end
    if not wait(function()
            if findOne("确认蓝") then return true end
            if findOne("职业选择") then
                ssleep(.5)
                tap('职业选择')
                ssleep(.5)
            end
            tap("加工站换人")
            ssleep(.3)
        end, 3) then
        return
    end

    path.基建确认进入设施()

    if not wait(function()
            if findOne("干员未选中") and findOne("第一干员未选中") then
                return true
            end
            tap("第一干员未选中")
            ssleep(.5)
        end, 7) then
        log("加工站超时")
        return
    end

    chooseOperator(stationType, material_id, material_level, tradingStationNum,
        virtralPowerStationNum, dormitoryCapacity, dormitoryLevelSum,
        goldStationNum, totalStationLevel)

    if not wait(function(reset_wait_start_time)
            if findAny({ "加工站", "开始加工" }) then
                return true
            end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
            tap("加工站确认蓝")
            ssleep(.2)
        end, 3) then
        return
    end
    return true
end

-- 2025基建更新之后改为在基建总览换班
path.会客厅换班 = function(stationType, force_change)
    stationType = stationType or "会客厅"
    log.debug(stationType)

    -- 检查是否缺人，不缺不换
    if not force_change and not appear("入驻干员" .. stationType, .5) and findOne("基建总览工作区") and
        not findOne("入驻干员" .. stationType) then
        log("无入驻干员")
        return
    end

    -- 进干员列表
    if not wait(function()
            if findOne("确认蓝") then return true end
            tap("进驻总览" .. stationType)
        end, 10) then
        return
    end

    -- 清空选择
    local start_time = time()
    if not wait(function()
            if findOne("干员未选中") and findOne("第一干员未选中") then
                return true
            end
            if time() - start_time > 1000 then
                tap("干员选择列表1")
                start_time = time()
            end
            tap("清空选择")
        end, 5) then
        log.debug()
        return
    end

    chooseOperator(stationType, type, stationLevel, tradingStationNum,
        virtralPowerStationNum, dormitoryCapacity, dormitoryLevelSum,
        goldStationNum, totalStationLevel)

    if not wait(function(reset_wait_start_time)
            tap("确认蓝")
            ssleep(.5)
            if findAny({ "撤下干员", "基建总览工作区" }) then return true end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
        end, 3) then
        return
    end
end

path.回收站换班 = function(stationType)
    stationType = stationType or "回收站"
    p = stationType
    path.跳转("基建")
    ssleep(0.5)
    -- 进回收站
    if not wait(function()
            if not findOne("进驻总览") or not findOne("缩放结束") then
                return true
            end
            tap(p)
        end) then
        log.debug()
        return
    end

    path.基建确认进入设施()
    -- 进干员列表
    if not wait(function()
            if findOne("确认蓝") then return true end
            tap("制造站进度")
        end, 10) then
        return
    end

    -- 清空选择
    local start_time = time()
    if not wait(function()
            if findOne("干员未选中") and findOne("第一干员未选中") then
                return true
            end
            if time() - start_time > 1000 then
                tap("干员选择列表1")
                start_time = time()
            end
            tap("清空选择")
        end, 5) then
        log.debug()
        return
    end

    -- 图标不够，会出现空集，暂时不做判断直接选前两个
    -- chooseOperator(stationType, type, stationLevel, tradingStationNum,
    --     virtralPowerStationNum, dormitoryCapacity, dormitoryLevelSum,
    --     goldStationNum, totalStationLevel)

    tap("干员选择列表1")
    tap("干员选择列表2")


    if not wait(function(reset_wait_start_time)
            tap("确认蓝")
            ssleep(.5)
            if findAny({ "撤下干员", "基建总览工作区" }) then return true end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
        end, 3) then
        return
    end
end

path.贸易站加速 = function()
    path.跳转("基建")
    local station
    for i = 1, #point.基建左侧列表 do
        local x, y = table.unpack(point["基建左侧列表" .. i])
        log(x, y, default_findcolor_confidence)
        log(type(default_findcolor_confidence))
        if compareColor(x, y, "#33CCFF", default_findcolor_confidence) then -- 贸易站
            station = x .. coord_delimeter .. y .. coord_delimeter .. "#33CCFF"
            point.station = station
            rfl.station = true
            break
        end
    end
    log.debug()
    if not station then return end
    log(station)
    if not wait(function()
            if not findOne("进驻总览") or not findOne("缩放结束") then
                return true
            end
            tap("station")
        end, 5) then
        return
    end

    wait(function()
        if findAny({ "贸易站设施列表1", "未进驻设施列表1" }) then
            return true
        end
        tap("贸易站进度")
    end, 5)

    good = findAny({ "龙门商法", "开采协力" }) or "龙门商法"

    log.debug(good)
    if not good then
        log.warn("未进入")
        return
    end
    if not disappear("制造站补货通知", 10) then return end
    log.debug()

    local 无人机使用完毕 = false
    local f = function()
        if not wait(function()
                if findOne("无人机加速") then return true end
                tap("贸易站第一订单加速")
            end, 10) then
            return
        end

        -- appear("无人机加速加", .5)
        if findOne("无人机加速不可点击") then
            无人机使用完毕 = true
            log("无人机使用完毕")
            return
        end
        wait(function()
            if not findOne("无人机加速加") then return true end
            tap("无人机加速最大")
        end)
        if not wait(function()
                if not findOne("无人机加速确定2") then return true end
                tap("无人机加速确定2")
                ssleep(.8)
                disappear("正在提交反馈至神经", network_timeout)
            end, 6) then
            return
        end
        return true
    end
    local start_time = os.time()
    while not 无人机使用完毕 do
        -- for i = 1, 5 do
        local px = appear({ "贸易站第一订单加速", "贸易站第一可交付", "贸易站第一不可交付" }, 5)
        log(px)
        if px == "贸易站第一不可交付" then
            log("贸易站材料缺少")
            accelerate_trading = false
            return path.制造加速()
        end
        if px == "贸易站第一可交付" then
            tap("贸易站第一可交付")
            appear("贸易站第一订单加速", 5)
        end
        -- if i > 2 and px ~= "贸易站第一可交付" then
        --     log("无人机使用完毕")
        --     return true
        -- end
        appear("贸易站第一订单加速", 5)
        tap("贸易站第一订单加速")
        f()
        log.debug()
        appear({ "贸易站第一订单加速", "贸易站第一可交付", "贸易站第一不可交付" }, 2.5)
        ssleep(1)
        if os.time() - start_time > 60 * 2 then
            log("贸易站超时")
            back()
            return
        end
    end
    back()
end

---@param only any 不从基建跳转仅仅加速
path.制造加速 = function(only)
    if not only and accelerate_trading then
        return path.贸易站加速()
    end
    if not only then
        path.跳转("基建")
        local station
        for i = 1, #point.基建左侧列表 do
            local x, y = table.unpack(point["基建左侧列表" .. i])
            log(x, y, default_findcolor_confidence)
            log(type(default_findcolor_confidence))
            if compareColor(x, y, "#FFCC00", default_findcolor_confidence) then
                station = x .. coord_delimeter .. y .. coord_delimeter .. "#FFCC00"
                point.station = station
                rfl.station = true
                break
            end
        end
        log.debug()
        if not station then return end
        log(station)
        if not wait(function()
                if not findOne("进驻总览") or not findOne("缩放结束") then
                    return true
                end
                tap("station")
            end, 5) then
            return
        end
    end
    -- if not appear({"进驻信息", "进驻信息选中"}) then return end
    if not wait(function()
            if findOne("制造站加速") then return true end
            tap("制造站进度")
        end, 10) then
        return
    end
    -- if not appear("制造站加速") then return end

    if not wait(function()
            if findOne("无人机加速") then return true end
            tap("制造站加速")
        end, 10) then
        return
    end

    -- appear("无人机加速加", .5)
    wait(function()
        if not findOne("无人机加速加") then return true end
        tap("无人机加速最大")
    end)
    if not wait(function()
            if findOne("制造站加速") then return true end
            tap("无人机加速确定")
        end, 5) then
        return
    end
    if only then
        disappear("正在提交反馈至神经", network_timeout)
    end
    tap("制造站收取")
end

path.线索交流 = function()
    path.跳转("基建")
    log.debug()
    local f

    if not wait(function()
            if not findOne("进驻总览") or not findOne("缩放结束") then
                return true
            end
            tap("会客厅")
            disappear("进驻总览", 2)
        end, 5) then
        return
    end
    if not appear({ "进驻信息", "会客室点开线索" }) then return end
    if not wait(function()
            if findAny({ "线索传递", "本次线索交流活动" }) then return true end
            tap("会客室点开线索")
        end, 10) then
        return
    end

    log.debug()

    -- 进入可控状态
    if not wait(function()
            -- if not findOne("线索传递") then return true end
            if findAny({ "线索布置展开", "本次线索交流活动" }) then
                return true
            end
            -- tapCard("线索布置列表1")
            tap("线索布置5")
        end, 10) then
        return
    end

    log.debug()

    -- 回到线索主界面，处理交流结束情况
    if not wait(function()
            if findOne("线索传递") then return true end
            tap("解锁线索上")
            if findOne("本次线索交流活动") then
                -- log("find本次线索交流活动")
                tap("返回")
                -- 只能用返回必须等待
                disappear("本次线索交流活动", .5)
            end
        end, 10) then
        return
    end

    log.debug()

    -- 等待前一任务的通知消失
    appear("接收线索白", 5)
    appear("线索传递", 5)
    log.debug()

    -- 接收线索
    wait(function()
        log.debug()
        if not findOne("线索传递") then return true end
        -- TODO 暂时妥协这0.5秒，丢失率太高
        if not appear("接收线索有", .5) then return true end
        if not wait(function()
                tap("接收线索有")
                if disappear("线索传递", 1) then return true end
            end, 5) then
            return true
        end
        log.debug()
        if not appear("接收线索", 5) then return true end
        wait(function() tap("全部收取") end, 1)
        log.debug()
        if not wait(function()
                if findOne("线索传递") then return true end
                tap("解锁线索上")
            end, 5) then
            return true
        end
        log.debug()
    end, 10)
    if not appear("线索传递") then return end

    log.debug()

    -- 信用奖励，已满则传递线索
    f = function(retry)
        log.debug()
        if retry > 10 or no_friend then return true end

        -- 进入信用奖励界面
        if not wait(function()
                if findOne("信用奖励返回") then return true end
                tap("信用奖励有")
            end, 10) then
            return
        end

        log.debug()

        -- 已满则传递，并循环
        if not appear("未达线索上限", .5) then
            log("信用已满, 返回")
            tap("返回")
            appear("线索传递")
            clue_unlocked = false
            if findOne("线索快速置入") then
                tap("线索快速置入")
                disappear("线索快速置入", 2)
            end
            if findOne("解锁线索") and not disable_clue_unlock then
                clue_unlocked = true
            end
            -- path.线索布置()
            log.debug(clue_unlocked)
            if not clue_unlocked then path.线索传递() end
            path.线索布置()
            return f(retry + 1)
        end

        log.debug()

        -- 未满则收取奖励
        if findOne("信用奖励领取") then
            if not wait(function()
                    if findOne("线索传递") then return true end
                    tap("信用奖励领取")
                end, 5) then
                return
            end
        else
            tap("返回")
        end

        -- 确保回到线索界面，退出
        if not appear("线索传递") then return end
        return true
    end
    if not f(0) then return end
    if not appear("线索传递") then return end
    path.线索布置()
    path.会客室信用收集()
end

-- tap with offset -50,50
tapCard = function(k)
    local x, y = point[k]:match("(%d+)" .. coord_delimeter .. "(%d+)")
    tap({ tonumber(x) - scale(50), tonumber(y) + scale(50) })
end

path.会客室信用收集 = function()
    -- 每周1 做
    if get_day_of_week() ~= 1 then return end

    log("会客室信用收集")
    path.跳转("基建")

    if not wait(function()
            if not findOne("进驻总览") or not findOne("缩放结束") then
                return true
            end
            tap("会客厅")
            disappear("进驻总览", 2)
        end, 5) then
        return
    end
    log.debug()
    if not appear({ "进驻信息", "会客室点开信用家具" }) then return end
    if not wait(function()
            if findOne("会客室点开信用家具变黄") then return true end
            tap("会客室点开信用家具")
        end, 10) then
        return
    end

    local ret = find_color("会客室信用家具查找范围", "FFE30A", 0, 0.9)
    if not ret then return end
    log.debug(ret)
    if not wait(function()
            if findOne("会客室信用右上角橙") then return true end
            tap(ret)
            ssleep(.5)
        end, 5) then
        log.debug()
        return
    end
    log.debug()
    if findOne("会客室信用领取橙") then
        tap("会客室信用领取橙")
    end
end

path.线索布置 = function()
    -- internal
    log.debug()
    if not findOne("线索传递") then
        log.warn("线索布置未找到线索传递")
        return
    end
    log.debug()

    if disable_clue_unlock then
        path.线索传递()
        ssleep(5)
        path.线索传递()
        return
    end
    log.debug()
    if findOne("线索快速置入") then
        tap("线索快速置入")
        disappear("线索快速置入", 2)
    end

    -- 在左侧判断，不会右侧提示挡住
    wait(function()
        if findOne("线索布置展开") and disappear("线索布置白列表5", 1) then
            return true
        end
        tap("线索布置5")
    end, 5)

    log.debug()
    if true then
        for i = 1, 7 do
            if findOne("线索布置左列表" .. i) then
                p = "线索布置左列表" .. i

                wait(function()
                    if findOne("线索布置白列表" .. i) then return true end
                    tapCard(p)
                end, 2)
                if not wait(function()
                        tap("线索接收库")
                        if not findOne(p) then return true end
                        if findOne("线索接收库空") then
                            tap("线索库全部")
                            appear("线索库全部")
                            return true
                        end
                        tap("线索库列表1")
                        tap("线索库列表1")
                        ssleep(.5)
                    end, 20) then
                    return
                end
                if not wait(function()
                        if not findOne(p) then return true end
                        tap("线索库列表1")
                        tap("线索库列表1")
                        disappear(p, 5)
                    end, 20) then
                    return
                end
            end
        end
        log.debug()
        if not wait(function()
                if findOne("线索传递") then return true end
                tap("解锁线索上")
            end, 10) then
            return
        end
    end

    -- 只送线索
    log("disable_clue_unlock", disable_clue_unlock)
    -- exit()

    if findOne("解锁线索") and not disable_clue_unlock then
        clue_unlocked = true
        log.debug()
        wait(function() tap("解锁线索") end, .5)

        if not appear({ "进驻信息", "进驻信息选中" }, 5) then
            return path.线索交流()
        end
        log.debug()
        if not wait(function()
                if findOne("线索传递") then return true end
                tap("制造站进度")
            end, 10) then
            return path.线索交流()
        end
        log.debug()
        return path.线索布置()
    end
end

path.线索传递 = function()
    -- internal
    log.debug()
    disappear("正在提交反馈至神经", network_timeout)
    if not findTap("线索传递") then return end

    appear({ "线索传递数字列表8", "正在提交反馈至神经" })
    disappear("正在提交反馈至神经", network_timeout)
    if not appear("线索传递数字列表8", 10) then return end
    if not appear("线索传递有好友", .5) then
        no_friend = true
        wait(function()
            if findOne("线索传递") then return true end
            tap("线索传递返回")
        end, 10)
        return
    end

    for i = 1, 8 do
        if not wait(function()
                if findOne("线索传递数字列表" .. i) then return true end
                tap("线索传递数字列表" .. i)
            end, 5) then
            return
        end
        log.debug()
        if findOne("线索传递数字重复") and findOne("线索列表1") then
            break
        end
        log.debug()
    end

    if not wait(function()
            if not findOne("线索列表1") or findOne("线索按下列表1") then
                return true
            end
            tap("线索列表1")
        end, 5) then
        stop(1098)
    end

    local f = function(random)
        local idx
        if random then
            idx = 1 -- 有人只有一个好友
        else
            for col = 1, 7 do
                for row = 1, 4 do
                    if cmpColor(scale(1230 + col * 65), scale(row * 225 - 80), "EB701D", 0.9) == 1 then
                        idx = row
                        break
                    end
                end
                if idx then break end
            end
        end
        if idx then
            log("线索传递", idx, point.传递列表[idx])

            tap(point.传递列表[idx])

            wait(function()
                if findOne("线索传递") then return true end
                tap("线索传递返回")
            end, 10)
            return true
        end
    end
    if not wait(function()
            if f() then return true end
            if not appear({ "线索传递右白", "线索传递右白2" }, .5) then
                f(true)
                return true
            end
            local state = sample("好友")
            log(state, point['sample'])
            tap("线索传递右白")
            disappear(state, .5)
        end, 30) then
        stop(1146)
    end
end

path.任务收集 = function()
    path.跳转("任务")
    log.debug()
    appear({ "任务未选中列表2", "任务有列表2", "任务无列表2" })
    for _ = 1, #point.任务有列表 do
        local p = appear(point.任务有列表, 0.5)
        if not p then break end

        log.debug(p)
        -- nagivate to tab
        if not wait(function()
                if findOne("收集全部", .9) or findOne("特勤任务一键领取") then return true end
                tap(p)
            end, 10, .1) then
            return
        end

        -- 判定是否有剩余红点
        local remain = findAny(table.subtract(point.任务有列表, { p }))

        -- tap collect
        if not wait(function()
                if not findTap("收集全部") and not findTap("特勤任务一键领取") then return true end
            end, 5) then
            return
        end

        -- wait for popup
        disappear(p, network_timeout)
        if disappear("主页") then
            if not wait(function()
                    tap(p)
                    if findOne("主页") and findOne("返回") then return true end
                end, 10) then
                return
            end

            -- 等待剩余红点出现
            if remain then appear(point.任务有列表) end
        end
    end
end

path.信用购买 = function()
    path.跳转("采购中心")
    if not wait(function()
            if findAny({ "信用交易所列表1", "信用交易所已购列表1" }) then
                return true
            end
            tap("信用交易所2")
        end, 10) then
        return
    end

    if findOne("收取信用有") then
        local f = function()
            if not wait(function()
                    if not findOne("信用交易所横线") then return true end
                    tap("收取信用有")
                end, 5) then
                return
            end

            if not wait(function()
                    if findOne("信用交易所横线") then return true end
                    tap("收取信用有")
                end, 5) then
                return
            end

            -- 危机合约期间启用
            if during_crisis_contract and disappear("信用交易所横线", 1) then
                if not wait(function()
                        if findOne("信用交易所横线") then return true end
                        tap("收取信用有")
                    end, 5) then
                    return
                end
            end
        end
        f()
    end

    -- 等待前一个任务的提示完全消失
    if findOne("信用不足") then
        -- 1秒内不出现才ok，应对多个通知消失情况
        if not wait(function()
                if not appear("信用不足", 1) then return true end
            end, 10) then
            return
        end
    end

    local f
    local order = {}
    f = function()
        local i = 0

        tap("收取信用有")
        if not wait(function()
                if findOne("信用交易所横线") then return true end
                tap("收取信用有")
            end, 5) then
            return
        end

        log.debug()
        if not appear({
                "信用交易所列表" .. 5, "信用交易所已购列表" .. 5,
            }) then
            return
        end
        -- if not appear({
        --   "信用交易所列表" .. i, "信用交易所已购列表" .. i,
        -- }) then return end
        log.debug()

        -- if not findOne("信用交易所列表" .. i) then
        --   log(845, i)
        --   return
        -- end

        -- 获取遗漏物品
        for _, j in pairs(order) do
            if findOne("信用交易所列表" .. j) then
                i = j
                break
            end
        end

        -- 全买完了或者有问题
        if i == 0 then return end

        if not wait(function()
                if not findOne("信用交易所横线") then return true end
                tap("信用交易所列表" .. i)
                -- 快速点击物品将导致购买界面消失
                disappear("信用交易所横线", 1)
            end, 5) then
            return
        end

        if not wait(function()
                if findAny({ "信用交易所横线", "信用不足" }) then
                    return true
                end
                findTap("购买物品")
            end, 5) then
            return
        end

        -- 有可能进皮肤界面
        if findOne("信用不足") and findOne("主页") then
            log.warn("信用不足")
            return true
        end

        log.debug()
        disappear("信用交易所横线", 5)
        log.debug()

        if not wait(function()
                if findOne("信用交易所横线") then return true end
                tap("信用交易所2")
            end, 5) then
            log.debug()
            return
        end
    end

    -- 按优先级排
    if type(low_priority_goods) == 'string' and type(high_priority_goods) ==
        'string' and (#low_priority_goods > 0 or #high_priority_goods > 0) then
        keepCapture()
        local first_want = {}
        local last_want = {}
        local low_goods = low_priority_goods:filterSplit()
        local high_goods = high_priority_goods:filterSplit()
        log("low_goods", low_goods)
        log("high_goods", high_goods)
        for i, v in pairs(point.信用交易所列表) do
            local x, y = point[v]:match("(%d+)|(%d+)")
            x = str2int(x, 0)
            y = str2int(y, 0)
            point.t = { x - scale(105), y, x + scale(105), y + scale(46) }
            local r = ocr("t")
            if #r > 0 and r[1].text:includes(high_goods) then
                table.insert(first_want, i)
            elseif #r > 0 and r[1].text:includes(low_goods) then
                table.insert(last_want, i)
            else
                table.insert(order, i)
            end
        end
        order = table.extend(first_want, order)
        table.extend(order, last_want)
        releaseCapture()
    else
        order = range(1, 10)
    end

    log.debug("信用物品排序", order)
    -- exit()
    for _, i in pairs(order) do if f() then break end end
    -- for _, i in pairs(range(20)) do if f() then break end end
end

path.swip_ticket_shop = function(left, nodelay)
    --采购商店滑动,滑动三个商品的距离
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
        local x = scale(600) --滑动容器内较左侧
        local y = scale(533)
        local y2 = scale(900)
        --修改x2坐标，x+滑动距离1143
        local x2 = scale(1743) --不可超出1920
        local x3 = scale(1695) --不会点到物品
        local y3 = scale(1038)
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

path.swip_hd_shop = function(left, swip_dis, nodelay)
    --活动商店滑动,滑动三个商品的距离
    local duration
    local finger
    local delay
    local swip_dis = swip_dis or 1550
    if left then
        local x1 = scale(600)
        local x2 = scale(10000 / 720 * 1080)
        local y1 = scale(533)
        duration = 400
        finger = { { point = { { x1, y1 }, { x2, y1 } }, duration = duration } }
        delay = 750
    else
        local x = scale(64) --滑动容器内较左侧
        local y = scale(533)
        local y2 = scale(900)
        --修改x2坐标，x+滑动距离,两个物品1031,三个物品1550
        local x2 = scale(swip_dis + x) --不可超出1920
        local x3 = scale(1751)         --不会点到物品
        local y3 = scale(164)
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

path.采购中心商店 = function()
    if not green_ticket_shop and not yellow_ticket_shop and not red_ticket_shop then return end

    local yellow_ticket_shop_good_need = {}
    local red_ticket_shop_good_need = {}

    local buy_good = function(good)
        if not findOne(good) then
            log.warn("没有" .. good)
            return
        end

        if not wait(function()
                tap(good)
                ssleep(.1)
                if findOne("购买物品面板") then return true end
            end, 5) then
        end
        -- 点击购买
        if not wait(function()
                if findOne("购买物品面板") then
                    tap("凭证交易所商品最多")
                    ssleep(0.3)
                    tap("凭证交易所支付")
                    ssleep(0.3)
                end
                disappear("正在提交反馈至神经", network_timeout)

                if findOne("凭证交易所进入") then return true end
                if not findOne("购买物品面板") then return true end
            end, 6) then
        end
        ssleep(0.8)
        -- 购买后判断
        if not findOne("获得物资", .9) and findOne("购买物品面板") then
            log.warn("购买失败，大概是没钱了吧~")
            return true
        end
        disappear("正在提交反馈至神经", network_timeout)
        if not wait(function()
                if findOne("获得物资", .9) then
                    ssleep(0.2)
                    tap("获得物资")
                    ssleep(0.2)
                    return true
                end
            end, 7, .1) then
            tap("获得物资")
            ssleep(0.2)
        end
        ssleep(.2)
    end

    path.跳转("采购中心")
    if not wait(function()
            if findOne("凭证交易所进入确认") then return true end
            tap("凭证交易所进入")
        end, 5) then
        return
    end
    disappear("正在提交反馈至神经", network_timeout)
    appear("绿票商店选中", 3)
    ssleep(0.5)
    if findOne("绿票第1层确认") then
        if green_ticket_shop_1 == true then
            for i = 1, 7 do
                appear("绿票第1层确认", 3)
                buy_good("凭证交易所购买列表" .. 1)
                if findOne("绿票第2层确认") then break end
            end
        end
    end
    ssleep(0.5)
    log("绿票商店第一层已买完")

    if green_ticket_shop_2 == true or green_ticket_shop_3 == true then
        tap("绿票第2层确认")
        appear("绿票第2层确认", 4)
        if green_ticket_shop_2 == true and
            findOne("绿票第2层寻访凭证") then
            buy_good("凭证交易所购买列表" .. 2)
        end
        ssleep(0.5)
        appear("绿票第2层确认", 4)
        if green_ticket_shop_3 == true then
            if findOne("绿票第2层招聘许可列表1") then
                buy_good("凭证交易所购买列表" .. 2)
            elseif findOne("绿票第2层招聘许可列表2") then
                buy_good("凭证交易所购买列表" .. 6)
            end
        end
    end

    for i = 1, #yellow_ticket_shop_good do
        if _G["yellow_ticket_shop_" .. i] == true then
            if i == 1 then
                for j = 1, 5 do
                    table.insert(yellow_ticket_shop_good_need, "黄票商店寻访凭证")
                end
            elseif i == 2 then
                for j = 1, 5 do
                    table.insert(yellow_ticket_shop_good_need, "黄票商店中中坚寻访凭证")
                end
            elseif i == 3 then
                for j = 1, 4 do
                    table.insert(yellow_ticket_shop_good_need, "黄票商店模组数据块")
                end
            end
        end
    end
    log(yellow_ticket_shop_good_need)

    for i = 1, #red_ticket_shop_good do
        if _G["red_ticket_shop_" .. i] == true then
            if i == 1 then
                table.insert(red_ticket_shop_good_need, "模组数据块")
            elseif i == 2 then
                table.insert(red_ticket_shop_good_need, "干员")
            end
        end
    end
    log(red_ticket_shop_good_need)

    local 指定商店购买 = function(good_need)
        if #good_need == 0 then
            return
        end

        for k, v in pairs(good_need) do
            -- 点击商品
            tap("商店顶栏")
            ssleep(0.1)
            if not wait(function()
                    tap(v)
                    ssleep(.5)
                    if findOne("购买物品面板") then return true end
                end, 5) then
            end

            if findOne("凭证交易所进入") then
                log.warn("未能进入商品，大概是售空了吧~")
                goto continue
            end

            -- 点击购买
            if not wait(function()
                    if findOne("购买物品面板") then
                        tap("凭证交易所商品最多")
                        ssleep(0.5)
                        tap("凭证交易所支付")
                    end
                    ssleep(1)
                    -- tap("商店顶栏")
                    if findOne("凭证交易所进入") then return true end
                    if not findOne("购买物品面板") then return true end
                end, 3) then
            end
            disappear("正在提交反馈至神经", network_timeout)
            -- 购买后判断
            if findOne("购买物品面板") then
                log.warn("购买失败，大抵是没钱了吧~")
                return true
            end
            ::continue::
        end
    end

    local 黄票商店购买 = function()
        if not yellow_ticket_shop then return end
        if #yellow_ticket_shop_good_need == 0 then return end
        if not wait(function()
                if findOne("黄票商店选中") then
                    return true
                end
                tap("黄票商店选中")
            end, 10) then
            return
        end
        if appear("黄票商店选中") then
            log("黄票")
            指定商店购买(yellow_ticket_shop_good_need)
        end
    end

    local 红票商店购买 = function()
        if not red_ticket_shop then return end
        if #red_ticket_shop_good_need == 0 then return end

        -- DCBB0C
        if not wait(function()
                if findOne("红票商店选中") then
                    return true
                end
                tap("红票商店选中")
                ssleep(.5)
            end, 10) then
            return
        end
        disappear("正在提交反馈至神经", network_timeout)
        ssleep(.5)
        if not appear("红票商店面板", 1.5) then return end
        if table.search(red_ticket_shop_good_need, "模组数据块") then
            local p
            for i = 0, 3 do
                p = findOne("红票商店模组")
                log("模组位置", p)
                if p then
                    break
                end
                path.swip_ticket_shop()
                ssleep(1.5)
            end
            if not p then return end

            if not wait(function()
                    tap(p)
                    ssleep(.5)
                    if findOne("购买物品面板") then
                        return true
                    end
                end, 5) then
            end
            if findOne("凭证交易所进入") then
                log.warn("未能进入商品，大概是售空了吧~")
                return
            end
            -- 点击购买
            if not wait(function()
                    if findOne("购买物品面板") then
                        tap("凭证交易所商品最多")
                        ssleep(0.5)
                        tap("凭证交易所支付")
                        -- tap("商店顶栏")
                    end
                    ssleep(1)
                    if findOne("凭证交易所进入") then return true end
                    if not findOne("购买物品面板") then return true end
                end, 3) then
            end
            if findOne("购买物品面板") then
                log.warn("购买失败，大抵是没钱了吧~")
                return true
            end
            disappear("正在提交反馈至神经", network_timeout)
            appearTap("获得物资", 3)
        end
        if table.search(red_ticket_shop_good_need, "干员") then
            local red_ticket_shop_char = { "云迹", "菲莱", "跃跃", "折光", "石英", "雪绒", "布丁", "蜜莓", "伊桑", "微风" }
            local char_exist = true
            local ret
            while char_exist do
                ssleep(.5)
                ret = ocrex("红票商店干员范围")
                --print(JsonEncode(ret))
                if ret and #ret ~= 0 then
                    if table.search(red_ticket_shop_char, ret[1]["text"]) then
                        tap({ ret[1]["l"], ret[1]["b"] })
                        appearTap("红票商店干员聘用")
                        disappear("正在提交反馈至神经", network_timeout)
                        ssleep(2)
                        if not wait(function()
                                tap("开包skip")
                                ssleep(1)
                                if findOne("凭证交易所进入") then return true end
                                if findOne("购买物品面板") then return false end
                            end, 10) then
                            char_exist = false
                        end
                    else
                        char_exist = false
                    end
                else
                    char_exist = false
                end
            end
        end
    end

    --绿票商店购买()
    黄票商店购买()
    红票商店购买()
end

get_fight_left_times = function(x)
    local l_times = 0
    local i = 1

    while i <= #fight do
        if fight[i] == x then
            l_times = l_times + 1
        end
        i = i + 1
    end
    return l_times
end

get_fight_type = function(x)
    local f = startsWithX(x)
    if table.any({ "上一次" }, f) then
        return "上一次"
    elseif table.any({ "PR", "CE", "CA", "AP", "LS", "SK" }, f) then
        return "物资芯片"
    elseif table.any({ "CW" }, f) then
        return "插曲"
    elseif table.any({ "GT" }, f) then
        return "别传"
    elseif table.any({ "BQPZ", "BQPZ1", "BQPZ2" }, f) then
        return "保全"
    elseif table.any(table.values(jianpin2name), f) then
        return "剿灭"
    elseif f('HD') then
        return "活动"
    elseif f('BREAK') then
        return "BREAK"
    else
        return "主线"
    end
end

get_fight_special_type = function(x)
    local chapter = x:find("-")
    chapter = x:sub(1, chapter - 1)
    chapter = chapter:sub(chapter:find("%d+"))
    chapter = tonumber(chapter)
    if chapter ~= nil and chapter >= 10 then return "磨难" end
    return ""
end

same_page_fight = function(pre, cur)
    if type(pre) ~= 'string' then return end
    if findOne("面板") then return end

    -- 禁用同页跳转
    -- if get_fight_type(cur) == '活动' then return end

    if removeTrailingDigits(pre) == removeTrailingDigits(cur) then
        log("是同一页的作战:", pre, ",", cur)
        return true
    end

    if pre == nil or cur == nil then return end

    -- pattern before last - should be same
    -- PR-A-1 == PR-A-2, PR-A-1 != PR-A-2
    if pre:gsub("(.*)-.*$", "%1") == cur:gsub("(.*)-.*$", "%1") then
        log("是同一页的作战", pre, cur)
        return true
    end

    -- number before last - should be same
    if pre:gsub(".*(%d+)-.*$", "%1") == cur:gsub(".*(%d+)-.*$", "%1") then
        log("是同一页的作战", pre, cur)
        return true
    end

    log("不是同一页的作战", pre, cur)
end

path.轮次作战 = function()
    while not zero_san do
        if #fight == 0 then return true end
        fight_tick = fight_tick % #fight + 1
        if fight_tick == #fight then
            no_success_one_loop = no_success_one_loop + 1
            if no_success_one_loop > 5 then break end
        end
        if request_memory_clean() then path.跳转("首页") end

        cur_fight = fight[fight_tick]
        log.debug(cur_fight)
        if cur_fight == 'BREAK' then break end
        log(pre_fight, cur_fight)
        if not same_page_fight(pre_fight, cur_fight) then
            skip_guide = false
            path.跳转("首页")
        else
            skip_guide = true
        end
        log.debug(fight, fight_tick_ui)

        pre_fight = nil

        path[get_fight_type(cur_fight)](cur_fight)

        -- 导航/代理失败3次就删除
        fight_failed_times[cur_fight] = (fight_failed_times[cur_fight] or 0) + 1

        if fight_failed_times[cur_fight] >= max_fight_failed_times then
            -- 有磨难关卡，切换至磨难再试
            if get_fight_type(cur_fight) == "主线" and
                get_fight_special_type(cur_fight) == "磨难" and
                fight_hard_mode[cur_fight] ~= true then
                fight_failed_times[cur_fight] = 0
                fight_hard_mode[cur_fight] = true
                fight_tick = fight_tick - 1
            else
                clean_fight(cur_fight)
                table.insert(qqmessage, " " .. cur_fight .. "导航超时")
            end
        end
        -- 清光理智: 第一次理智不足时，转为1-7
        log.debug("作战后清光1-7理智", zero_san_after_fight, "1-7理智", zero_san)
        if zero_san_after_fight and zero_san then
            if zero_san_hit > 0 then break end
            zero_san_hit = zero_san_hit + 1
            zero_san = false
            fight_tick = 0
            fight = {}
            for i = 1, 99 do
                table.insert(fight, "1-7")
            end
        end
    end
end

jianpin2name = {
    -- JM = '剿灭',
    DQWT = "当期委托",
    -- JSCK = "积水潮窟",
    -- CMHB = "潮没海滨",
    LMSQ = "龙门市区",
    LMWH = "龙门外环",
    QENBG = "切尔诺伯格",
    CQWT1 = "长期委托1",
    CQWT2 = "长期委托2",
    CQWT3 = "长期委托3",
    CQWT4 = "长期委托4",
    -- BYBFFC = "北原冰封废城",
    -- DQSLJW = "大骑士领郊外",
    -- FQKQ = "废弃矿区",
    保全 = "BQPZ",
    保全1 = "BQPZ1",
    保全2 = "BQPZ2",
    保全派驻 = "BQPZ",
    保全派驻1 = "BQPZ1",
    保全派驻2 = "BQPZ2",
    BQ = "BQPZ",
    BQ1 = "BQPZ1",
    BQ2 = "BQPZ2",
}
extrajianpin2name = {
    SYC = "上一次",
    长期委托 = "长期委托1",
    CQWT = "长期委托1",
    当前委托 = "当期委托",
}

chinese2name = {
    近卫 = "JW",
    近卫芯片 = "JW",
    特种 = "TZ",
    特种芯片 = "TZ",
    重装 = "ZZ",
    重装芯片 = "ZZ",
    医疗 = "YL",
    医疗芯片 = "YL",
    术师 = "SS",
    术师芯片 = "SS",
    狙击 = "JJ",
    狙击芯片 = "JJ",
    先锋 = "XF",
    先锋芯片 = "XF",
    辅助 = "FZ",
    辅助芯片 = "FZ",
    近卫1 = "JW1",
    近卫2 = "JW2",
    特种1 = "TZ1",
    特种2 = "TZ2",
    重装1 = "ZZ1",
    重装2 = "ZZ2",
    医疗1 = "YL1",
    医疗2 = "YL2",
    术师1 = "SS1",
    术师2 = "SS2",
    狙击1 = "JJ1",
    狙击2 = "JJ2",
    先锋1 = "XF1",
    先锋2 = "XF2",
    辅助1 = "FZ1",
    辅助2 = "FZ2",
}

XinPian = {
    ['JW'] = { "PR-D-2", "PR-D-1" },
    ['TZ'] = { "PR-D-2", "PR-D-1" },
    ['JW1'] = { "PR-D-1" },
    ['TZ1'] = { "PR-D-1" },
    ['JW2'] = { "PR-D-2" },
    ['TZ2'] = { "PR-D-2" },
    ['XF'] = { "PR-C-2", "PR-C-1" },
    ['FZ'] = { "PR-C-2", "PR-C-1" },
    ['XF1'] = { "PR-C-1" },
    ['FZ1'] = { "PR-C-1" },
    ['XF2'] = { "PR-C-2" },
    ['FZ2'] = { "PR-C-2" },
    ['SS'] = { "PR-B-2", "PR-B-1" },
    ['JJ'] = { "PR-B-2", "PR-B-1" },
    ['FS1'] = { "PR-B-1" },
    ['JJ1'] = { "PR-B-1" },
    ['FS2'] = { "PR-B-2" },
    ['JJ2'] = { "PR-B-2" },
    ['YL'] = { "PR-A-2", "PR-A-1" },
    ['ZZ'] = { "PR-A-2", "PR-A-1" },
    ['YL1'] = { "PR-A-1" },
    ['ZZ1'] = { "PR-A-1" },
    ['YL2'] = { "PR-A-2" },
    ['ZZ2'] = { "PR-A-2" },
}

材料关卡 = {
    扭转醇 = { "GT-5", "6-11", "11-13" },
    轻锰矿 = { "10-16", "3-2" },
    研磨石 = { "10-12", "9-16", "5-7", "4-8", "3-3" },
    固源岩组 = { "10-6", "2-4" },
    固源岩 = { "1-7" },
    全新装置 = { "11-7", "M8-8", "9-10", "7-15", "3-4" },
    装置 = { "S3-4", "1-12" },
    糖组 = { "HD-6", "2-5" },
    糖 = { "S3-1", "2-2" },
    聚酸酯组 = { "7-4", "2-6" },
    聚酸酯 = { "S3-2", "1-8" },
    异铁组 = { "10-11", "7-18", "2-8" },
    异铁 = { "S3-3", "2-1" },
    酮凝集组 = { "10-4", "JT8-3", "3-1" },
    酮凝集 = { "3-7", "S2-1" },
    凝胶 = { "R8-8", "JT8-2", "S4-10" },
    炽合金 = { "S3-6" },
    晶体元件 = { "R8-11", "S5-9", "S3-7" },
    半自然溶剂 = { "12-10", "9-18", "9-4" },
    化合切削液 = { "10-17", "9-6" },
    转质盐组 = { "11-3", "S9-2" },
    褐素纤维 = { "13-5" },
    环烃聚质 = { "13-15" },
    ["RMA70-12"] = { "9-19", "7-10", "R8-9", "2-10" }
}

path.开始游戏 = function(x, disable_ptrs_check)
    -- 记录石头数量
    save_run_state()
    if new_change_account_plan and not save_token then
        path.账户数据保存()
        save_token = true
    end
    local need_copy_homework = nil
    log("开始游戏,第", fight_tick, "次作战,关卡:", x)
    if copy_homework_only then pre_fight = x end

    if findOne("获得塔罗牌页面") or findOne("塔罗牌关闭") then
        wait(function()
            tap("塔罗牌关闭")
            if not findOne("塔罗牌关闭") then return true end
        end, 3)
        disappear("塔罗牌关闭", 3)
        ssleep(.5)
    end

    if not findOne("开始行动") then
        log.debug("未找到开始行动")
        return
    end

    -- TODO 活动时需要注意这个地方，活动关的代理指挥不长这样
    -- 目的是剿灭
    -- if not appear("代理指挥开", 1) then return end
    -- log(findOne("开始行动"))
    -- log(findOne("返还规则"))
    -- log(findOne("报酬合成玉已满"))
    -- log(findOne("开始行动"))
    -- safeexit()

    log.debug("抄作业模式", copy_homework, "作业代码", homework[x])
    if not appear("代理指挥开", .5) then
        if copy_homework and findOne("突袭模式") then
            log("进入突袭难度")
            tap("突袭模式")
            appear("开始突袭", 3)
            ssleep(.5)
            if findOne("突袭未三星") or not copy_homework_only then
                tap("开始突袭")
                appear("开始行动突袭", 3)
                goto wait_for_prts
            else
                return true
            end
        end
        if copy_homework and findOne("切换到险地作战") then
            log("切换险地作战")
            tap("切换到险地作战")
            appear("沙盘推演星未打满", 3)
        end
        if copy_homework then
            if findOne("险地作战星未打") or not copy_homework_only then
            elseif findOne("开始行动1") then
            elseif findOne("险地作战星已打") and findOne("沙盘推演星未打满") then
                log("沙盘推演")
                --选择沙盘推演
                tap("沙盘推演")
                appear("沙盘推演选择按钮", 2)
                ssleep(.8)
                tap("沙盘推演选择按钮")
                appear("沙盘推演选择面板", 2)
                ssleep(.5)
                goto wait_for_prts
            else
                log.warn("未找到")
                return true
            end
        end
        tap("代理指挥开1")
        if not appear("代理指挥开", .5) then
            log.debug("第一次尝试没有打开代理指挥")
            if copy_homework and homework[x] then
                need_copy_homework = true
                log("准备抄作业")
                --ssleep (6)--等待右上角提示消失
            elseif get_fight_type(cur_fight) == "主线" or get_fight_type(cur_fight) == "活动" then
                local chapter = x:match("^[^-]+")
                chapter = (chapter == "HD" and 16 or str2int(chapter, 0))
                if chapter >= 15 then
                    log("15章+难度切换")
                    appear({ "切换到险地作战", "切换到常规作战", }, 3)
                    local st = findAny({ "切换到险地作战", "切换到常规作战" })
                    if not st then
                        log.warn("切换到作战失败")
                        if not appear("主页") then back() end
                        return path.跳转("首页")
                    end
                    if not wait(function()
                            tap(st)
                            ssleep(.5)
                            tap("代理指挥开1")
                            if appear("代理指挥开", .5) then
                                return true
                            end
                        end, 5) then
                        log.warn("切换到作战失败")
                        if not appear("主页") then back() end
                        return path.跳转("首页")
                    end
                else
                    fight_failed_times[cur_fight] = max_fight_failed_times
                    if not appear("主页") then back() end
                    return path.跳转("首页")
                end
            else
                fight_failed_times[cur_fight] = max_fight_failed_times
                if not appear("主页") then back() end
                return path.跳转("首页")
            end
        elseif copy_homework_only then
            log.info("关卡", x, "已经三星且可以代理")
            log.debug("短路导航")
            pre_fight = cur_fight
            return
        end
        -- if not wait(function()
        --   if findOne("代理指挥开") and not disappear("代理指挥开", .5) then
        --     return true
        --   end
        --   tap("代理指挥开")
        --   appear("代理指挥开", .5)
        -- end, 5) then return end
    end
    if appear("代理指挥开", .5) then
        ssleep(.8)
        if copy_homework and findOne("险地作战星已打") and
            findOne("沙盘推演星未打满") then
            log("沙盘推演")
            --选择沙盘推演
            tap("沙盘推演")
            appear("沙盘推演选择按钮", 2)
            ssleep(.8)
            tap("沙盘推演选择按钮")
            appear("沙盘推演选择面板", 2)
            ssleep(.5)
        elseif (not copy_homework_only) and copy_homework and homework[x] then
            tap("代理指挥开1")
            need_copy_homework = true
            disappear("代理指挥开", .5)
        end
        if findOne("多倍代理按钮") and get_fight_type(x) ~= "剿灭" then
            log("多倍处理开始")
            battle_times = 1
            -- 当前关卡在作战列表中配置了几次，多倍代理不能超过这个次数
            local l_time = get_fight_left_times(x)
            l_time = l_time or 1
            if findOne("多倍代理处于选择状态") and not multiple_proxy_commander then
                --多倍代理已经存在，并且用户不想多倍代理，那么就恢复1倍
                wait(function()
                    tap("多倍代理按钮")
                    if appear({ "多倍代理次数面板", "多倍代理次数面板2" }, 1) then return true end
                end, 10)
                appear({ "多倍代理次数面板", "多倍代理次数面板2" }, 3)
                if findAny({ "多倍代理次数面板", "多倍代理次数面板2" }) then
                    ssleep(1.2)
                    wait(function()
                        tap('多倍代理下一页') --一直下滑到一倍
                        if findOne('多倍代理当前是一倍') then return true end
                    end, 4, .3)
                    ssleep(.5)
                    if findAny({ "多倍代理次数面板", "多倍代理次数面板2" }) then
                        tap('多倍代理面板关闭') --把面板点掉
                    end
                end
                log.debug('1000001')
                -- 出现面板后给一点时间等待展开
                ssleep(0.5)
            end
            if multiple_proxy_commander then
                log('需要多倍代理，准备切换')

                --打开面板，回到一倍代理
                wait(function()
                    tap("多倍代理按钮")
                    if appear({ "多倍代理次数面板", "多倍代理次数面板2" }, 1) then return true end
                end, 10)
                appear({ "多倍代理次数面板", "多倍代理次数面板2" }, 3)
                if findAny({ "多倍代理次数面板", "多倍代理次数面板2" }) then
                    ssleep(1.2)
                    wait(function()
                        tap('多倍代理下一页') --一直下滑到一倍
                        if findOne('多倍代理当前是一倍') then return true end
                    end, 4, .3)
                    ssleep(.5)
                end

                -- 游戏最高是10倍；同时不能超过fight中当前关卡的配置次数
                local max_battle_times = min(10, l_time)
                -- 默认按最高可用倍率，检测到蓝色加号时再回退到 i - 1 倍
                battle_times = max_battle_times
                for i = 2, max_battle_times do -- 从下往上找蓝色的加号，找到说明i-1是不用吃药的最大值
                    tap('多倍代理上一页')
                    ssleep(.5)                 --有些设备卡顿，额外加上的延迟
                    -- 有药时，不够理智的倍率会出现蓝色加号；没药时会显示灰色而不是白色
                    -- 一次等待同时检查两个点位，避免连续两个 appear 各等待0.5秒
                    -- 蓝色加号放前面：有药时白色和蓝色可能同时存在，必须优先判断蓝色
                    local current = appear({
                        '多倍代理当前倍率有加号蓝', '多倍代理次数白列表' .. i,
                    }, .7)
                    -- current是白色：当前倍率可用；是蓝色或nil：当前倍率不可用，需要回退
                    if current ~= '多倍代理次数白列表' .. i then
                        log('当前倍率不可用:', i, ' 准备回到倍率:', i - 1)
                        ssleep(.5)
                        tap('多倍代理下一页')
                        ssleep(1)
                        -- 回退后只接受白色且没有蓝色加号的倍率；i=2时回退到1倍，默认有效
                        local lower = i == 2 and '多倍代理次数白列表1' or appear({
                            '多倍代理当前倍率有加号蓝',
                            '多倍代理次数白列表' .. (i - 1),
                        }, .5)
                        if lower == '多倍代理次数白列表' .. (i - 1) then
                            log("find 多倍代理次数列表" .. i)
                            battle_times = i - 1
                            break
                        else
                            log('回退后的倍率仍不可用，可能出现抖动')
                        end
                        ssleep(1)
                    end
                end
                ssleep(1)
                if findAny({ "多倍代理次数面板", "多倍代理次数面板2" }) then
                    tap('多倍代理面板关闭') --把面板点掉
                end
            end
            log.debug('1000003')
            log("最大可重复次数", battle_times)
            if l_time < battle_times then
                battle_times = l_time
            end
            log("最大可重复次数 计算后", battle_times, multiple_proxy_commander)
            ssleep(.5)
        end
    end
    log.debug()
    if is_jmfight_enough(x) then return end

    if findOne("全权委托") then path.fallback.全权委托() end
    -- quick tap .5s
    log.debug()
    wait(function()
        if not findOne("代理指挥开") then return true end
        tap("开始行动蓝")
    end, 1)
    ::wait_for_prts::
    local state = nil
    local start_time = time()
    if not wait(function(reset_wait_start_time)
            state = findAny({
                "开始行动突袭", "开始行动红", "源石恢复理智取消", "药剂恢复理智取消",
                "单选确认框", "源石恢复理智不足", "当期委托侧边栏",
                "行动结束", "开始行动故事集S", "沙盘推演确定",
            })
            log.debug("当前状态:", state)
            -- 剿灭后一直按开始行动导致开始行动界面消失，可能出现下面的界面
            if state == "当前委托侧边栏" then
                path.跳转("首页")
                return true
            end
            -- 找到以下按钮直接短路，否则返回主页
            if state == "单选确认框" then return true end
            if state == "开始行动红" then return true end
            if state == "开始行动突袭" or state == "开始行动故事集S" or state == "沙盘推演确定" then return true end
            if state == "行动结束" then return true end
            if state and not disappear(state, .5) then return true end
            if findOne("正在提交反馈至神经") and not findOne("开始行动") then
                log.debug("正在提交反馈至神经")
                reset_wait_start_time()
            end
            local p = findAny({ "开始行动", "全权委托确认使用", "开始突袭", "开始险地作战" })
            log.debug("在开始行动按钮:", p)
            if p then
                tap("开始行动蓝")
                ssleep(.2)
                -- TODO 2秒太慢 => 一开始就用0秒, 2秒内增加至2秒
                disappear(p, min(5, (time() - start_time) / 1000 * 5 / 5))
                log((time() - start_time) / 1000 * 5 / 5)
            end
        end, 10, .1) then
        back()
        appear("主页")
        path.跳转("首页")
        return
    end
    log.debug(state)
    if state == "行动结束" then
        no_success_one_loop = 0
        return path.base.接管作战()
    elseif state == "开始行动红" or state == "开始险地作战" or (state == "开始行动突袭" and not copy_homework) then
        no_success_one_loop = 0
        if need_copy_homework then
            ssleep(0.5)
            pcall(upload_launch_info, "autofight")
            if auto_prts(homework[x], true) == "编队失败" then
                tap("返回")
                ssleep(1)
                tap("返回")
                ssleep(1)
                tap("取消开始行动")
                ssleep(.5)
                return true
            end
        else
            if not wait(function()
                    if not findOne(state) then return true end
                    tap("开始行动红按钮")
                end, 10) then
                return
            end
            if not wait(function()
                    if findAny({ "接管作战", "单选确认框", "剿灭接管作战" }) then
                        return true
                    end
                end, 60) then
                -- if findOne("跳过剧情2") and not disappear("跳过剧情2", 10) then
                path.跳过剧情()
                -- end
                return
            end
            -- if not appear({"接管作战", "单选确认框"}, 60) then
            --   log(1430)
            --   return
            -- end
            if findOne("单选确认框") then return end
        end
        return path.base.接管作战()
    elseif state == "开始行动突袭" or state == "开始行动故事集S" or state == "沙盘推演确定" then
        no_success_one_loop = 0
        ssleep(0.5)
        if auto_prts(homework[x], true) == "编队失败" then
            tap("返回")
            ssleep(1)
            tap("返回")
            ssleep(1)
            tap("取消开始行动")
            ssleep(.5)
        end
        return path.base.接管作战()
    elseif stone_times < max_stone_times and state == "源石恢复理智取消" or
        drug_times < max_drug_times and state == "药剂恢复理智取消" then
        if state == "源石恢复理智取消" then
            stone_times = stone_times + 1
        else
            drug_times = drug_times + 1
        end

        if not wait(function()
                if findOne("开始行动") then return true end
                if findOne(state) then
                    tap("恢复理智确认")
                    disappear(state, 10)
                end
            end, 10) then
            return
        end
        return path.开始游戏(x)
    elseif stone_times < max_stone_times and state == "药剂恢复理智取消" then
        tap("源石恢复理智")
        state = "源石恢复理智取消"
        if not appear({ state, '源石恢复理智不足' }) then
            log.debug()
            tap("开始行动蓝")
            return
        end
        if findOne('源石恢复理智不足') then
            log.debug()
            tap("开始行动蓝")
            return
        end

        stone_times = stone_times + 1
        if not wait(function()
                if findOne("开始行动") then return true end
                if findOne(state) then
                    tap("恢复理智确认")
                    disappear(state, 10)
                end
            end, 10) then
            return
        end
        return path.开始游戏(x)
    elseif state == "药剂恢复理智取消" then
        -- if (disable_drug_48hour and disable_drug_24hour) or
        --   not findTap("理智药清空选择") then
        --   log("2226", disable_drug_24hour, disable_drug_48hour)
        --   zero_san = true
        --   tap("药剂恢复理智取消")
        --   return
        -- end
        tap("理智药清空选择")

        local deadline = {}

        wait(function()
            deadline = ocr("理智药到期时间范围")
            if #deadline == 1 and deadline[1].text:includes({ "天", "时" }) then
                return true
            end
        end, 5)
        deadline = deadline[1] or { text = '' }
        local idx = table.findv(range(2, 7), function(i)
            return deadline.text == (i - 1) .. '天'
        end)
        if deadline.text:endsWith("时") then idx = 1 end
        idx = idx or 0
        log.debug(idx)
        local max_times = _G['max_drug_times_' .. idx .. 'day']
        local times = _G['drug_times_' .. idx .. 'day']

        if not max_times or times >= max_times or max_drug_times == -1 then
            log.debug(idx, times, max_times)
            zero_san = true
            tap("开始行动蓝")
            -- 云控理智上报，普通用户跳过
            if cloud.enabled() then
                log("云控", "理智上报")
                while appear("主页", 5) ~= "主页" do
                    -- 备用识别
                    log("云控", "备用识别")
                    if appear("代理券", 1) then
                        log("云控", "备用识别成功")
                        break
                    end
                    ssleep(1)
                end
                log("云控", "已找到主页")
                cloud.sanReport()
            end
            return
        end

        -- 理智小样为10, 最大理智关卡为35，5次应该足够
        -- deadline = map(function(x) return {x.r, scale(409)} end, deadline)
        -- for _, v in pairs(deadline) do for i = 1, 1 do tap(v) end end
        -- log(2240, deadline)

        if multiple_proxy_commander then --勾选多倍代理的话  可以一次多嗑药
            for i = 1, max_use_number_drug do
                tap({ deadline.l, scale(409) })
                ssleep(0.5)
            end
            _G['drug_times_' .. idx .. 'day'] = times + max_use_number_drug
        else
            tap({ deadline.l, scale(409) })
            _G['drug_times_' .. idx .. 'day'] = times + 1
        end

        if not wait(function()
                if findOne("开始行动") then return true end
                if findOne(state) then
                    tap("恢复理智确认")
                    disappear(state, 10)
                end
            end, 10) then
            return
        end

        return path.开始游戏(x)
    elseif state == "源石恢复理智取消" or state ==
        "药剂恢复理智取消" or state == '源石恢复理智不足' then
        zero_san = true
        tap("开始行动蓝")
        -- 云控理智上报，普通用户跳过
        if cloud.enabled() then
            log("云控", "理智上报")
            while appear("主页", 5) ~= "主页" do
                log("云控", "未找到主页")
                -- 备用识别
                log("云控", "备用识别")
                if appear("代理券", 1) then
                    log("云控", "备用识别成功")
                    break
                end
                ssleep(1)
            end
            log("云控", "已找到主页")
            cloud.sanReport()
        end
    end
    log('30449')
end

path.主线 = function(x)
    -- split s2-9 to 2 and 9
    local chapter = x:find("-")
    chapter = x:sub(1, chapter - 1)
    chapter = chapter:sub(chapter:find("%d+"))
    local chapter_index = tonumber(chapter) + 1
    local state_with_home = function(y)
        local f = function() return findOne("主页") and findOne(y) end
        return f
    end

    -- 普通磨难环境
    local hard_mode_switch = function()
        -- 从10章开始有磨难
        if get_fight_special_type(x) ~= "磨难" then return end
        -- 选标准还是磨难
        local hard_mode = fight_hard_mode[x]
        -- 抄作业模式下根据作业选择是否是磨难图
        if copy_homework then
            if not homework[x] then return end
            local homeworkInfo = loadHomework(homework[x])
            if homeworkInfo then
                --log(homeworkInfo)
                --"stage_name":"tough_14-01"
                if homeworkInfo["stage_name"] then
                    local t = homeworkInfo["stage_name"]
                    if t:sub(1, 5) == "tough" then hard_mode = true end
                end
            end
        end

        if not findTap("环境选择") then return end
        ssleep(1) -- 按钮组展开时间
        if hard_mode then
            tap("磨难环境")
        else
            tap("标准环境")
        end
        if not wait(function()
                tap("空白环境")
                if findOne("环境选择") then return true end
            end, 5) then
            return
        end
        ssleep(.5)
    end

    local go = function()
        ssleep(.5)
        hard_mode_switch()
        log.debug(x)
        swip(x)

        --exit() -- 主线手动取点时取消注释
        --教学关/剧情关和剿灭关只打一遍
        if x:includes({ "TR-", "14-10", "14-13", "14-22", "14-23", }) or x == "14-1" then
            log("剧情关教学关")
            if findOne("作战列表" .. x) then return true end
        end
        ssleep(1) --尝试加上延迟，避免出现导航超时
        tap("作战列表" .. x)
        if appear("开始剧情", 1) then
            if not wait(function()
                    tap("开始剧情")
                    sleep(1000)
                    if findOne("跳过剧情") then
                        path.跳过剧情()
                        disappear("正在提交反馈至神经", network_timeout)
                    end
                    if findOne("获得物资") then
                        tap("获得物资")
                        disappear("获得物资", 1.5)
                        return true
                    end
                end, 25) then
                return
            end
            return true
        end
        appear("开始行动")
    end
    local next_tap_index = 0
    if chapter_index > 15 then
        next_tap_index = chapter_index - 15
        chapter_index = 15 -- 固定点击14章，然后点击下一章进行跳转
    end
    log.debug(chapter_index, next_tap_index)
    local p
    p = {
        [state_with_home("当前进度列表" .. chapter_index)] = function()
            log.debug(chapter_index)
            go()
            return true
        end,
        -- [state_with_home("按下当前进度列表" .. chapter_index)] = function()
        --   go()
        --   return true
        -- end,
    }
    -- if chapter_index <= 4 then -- chapter 0 to 3
    --     switch_start = 1
    --     switch_end = 4
    -- elseif chapter_index <= 9 then -- chapter 4 to 8
    --     switch_start = 5
    --     switch_end = 9
    -- elseif chapter_index <= 15 then -- chapter 9 to ?
    --     switch_start = 10
    --     switch_end = 15
    -- end
    -- for i = switch_start, switch_end do
    --     if chapter_index ~= i then
    --         p[state_with_home("当前进度列表" .. i)] =
    --             "当前进度列表" .. (i > chapter_index and "左" or "右")
    --         -- p[state_with_home("按下当前进度列表" .. i)] =
    --         --   "当前进度列表" .. (i > chapter_index and "左" or "右")
    --     end
    -- end
    -- log("chapter",chapter)
    -- exit()

    -- chapter_index 比实际章节index大1，因为有第零章
    log.debug(chapter_index)
    if not findAny(table.keys(p)) then
        log.debug()
        path.跳转("首页")
        tap("面板作战")
        if not appear("主页") then return end
        log.debug()
        if not wait(function()
                if findOne("主题曲界面") then return true end
                tap("主题曲")
            end) then
            return
        end
        log.debug()
        ssleep(.3)
        appearTap("乐章收录按钮")
        ssleep(.4)
        appear("主题曲白色圆点", 1)
        log.debug()
        if not wait(function()
                if appear("主题曲白色圆点", 1) then return true end
                -- tap("乐章收录")
                -- ssleep(.1)
                -- tap("乐章收录")
                swip_formula(true)
            end, 10) then
            log.warn("跳转失败3")
            return
        end
        log.debug()
        local tap_chat_index = chapter_index - 1
        local wa_x, wa_y = point["主线第零章点击位置"][1] + tap_chat_index % 5 * scale(315),
            point["主线第零章点击位置"][2] + math.floor(tap_chat_index / 5) * scale(310)
        log("wa_x", wa_x, "wa_y", wa_y)
        ssleep(1)
        tap({ wa_x, wa_y })
        ssleep(1)
        log.debug(chapter, chapter_index, tap_chat_index % 5, math.floor(tap_chat_index / 5))
        if not wait(function()
                -- if not findOne(samp) then return true end
                for i = 1, 16 do
                    if findOne("当前进度列表" .. i) then
                        return true
                    end
                    tap("前往章节")
                end
                -- tap({ wa_x, wa_y })
                ssleep(.5)
            end, 5) then --默认的2s可能太短了  在【章节选择列表】进入到关卡列表的时候，可能超时了
            log.warn("跳转失败4")
            return
        end
        --小号有可能前面章节没解锁
        local cur_chapter = chapter_index
        for i = chapter_index, 16 do
            if findOne("当前进度列表" .. i) then
                cur_chapter = i
                log.debug(cur_chapter)
                if i - chapter_index > 0 then
                    for j = 1, i - chapter_index do
                        ssleep(.5)
                        tap("当前进度列表左")
                        ssleep(1.5)
                    end
                end
                break
            end
        end

        -- if chapter_index <= 4 then
        --     -- 从上到下，命中第一篇, 专为还没过3-8的玩家
        --     ssleep(.5)
        --     tap("觉醒")
        --     ssleep(.5)
        --     tap("觉醒")
        --     ssleep(.5)
        --     -- tap("幻灭")
        --     -- ssleep(.5)
        -- elseif chapter_index <= 9 then
        --     -- 只打到3-8，第9章也会解锁，无需特殊处理
        --     ssleep(.5)
        --     tap("幻灭")
        --     ssleep(.5)
        -- end
        -- 新章节开启后,怒号光明这个点位恰好适配所有新开的章节,否则新章节导航这里将失败
        -- 如果后续在"残阳"之后加新的篇章,这里的导航可能都会失败,如点两次觉醒无法导航到第一篇
        -- if not appear("怒号光明") then return end

        -- ssleep(3)
        -- if distance['' .. chapter] then swipc() end
        -- tap("作战主线章节列表" .. chapter)

        -- if not wait(function()
        --         if not findOne("怒号光明") then return true end
        --         tap("作战主线章节列表" .. 8)
        --     end, 3) and not wait(function()
        --         if not findOne("怒号光明") then return true end
        --         tap("作战主线章节列表" .. 7)
        --     end, 3) then
        --     return
        -- end
        -- if appear("不连续章节进入", 1) then
        --     tap("不连续章节进入")
        -- end
        if not appear(table.keys(p), 5) then
            log("无法确认是第几章")
            return
        end
        if next_tap_index > 0 then
            ssleep(1)
        end
        for i = 1, next_tap_index do
            tap("当前进度列表右")
            ssleep(1.5)
        end
        -- 15+ 章特殊处理: 这里 next_tap_index > 0, 表示前面已经 tap 了 N 次 "当前进度列表右",
        -- 把章节卡片从 14 章翻到了 15/16/17 章。
        --
        -- 此时 point.lua 里 当前进度列表 数组只到 index 15 (即 14 章), 没有 16/17/18 的点位,
        -- 所以下面那个 auto(p, ...) 的 p 表里只有 "当前进度列表15" 这一个 key,
        -- 翻到 15+ 章后这个 key 永远不会再命中, auto 会闷等 20s 超时, 然后导航失败。
        --
        -- 解决: 翻到目标章节后直接调 go() 完成 swip + tap(作战列表), 然后进 开始游戏。
        -- 不需要再走下面的 auto, 因为 auto 在这种场景下没有可命中的 state。
        --
        -- 如果未来给 当前进度列表 数组补了 15/16/17 章的多点找色, 并且 chapter_index 不再被
        -- 强制覆盖为 15, 这段可以删除, 让下面的 auto 统一处理。
        if next_tap_index > 0 then
            go()
            return path.开始游戏(x)
        end
    end
    -- 20秒内需要完成章节/环境切换
    auto(p, nil, 20, 20)

    path.开始游戏(x)
end

path.插曲 = function(x)
    log("插曲")
    local chapter = x:find("-")
    chapter = x:sub(1, chapter - 1)
    if findOne("开始行动") then return path.开始游戏(x) end
    path.跳转("首页")
    tap("面板作战")
    if not appear("主页") then return end
    if not wait(function()
            if findOne("插曲界面") then return true end
            tap("插曲")
        end) then
        return
    end
    if not wait(function()
            tap("插曲列表" .. chapter)
            if findOne("进入活动") then return true end
        end) then
        return
    end
    if not wait(function()
            tap("进入活动")
            if not appear("进入活动") then return true end
        end) then
        return
    end
    swip(x)
    ssleep(.5)
    tap("作战列表" .. x)
    if not appear("开始行动") then
        wait(function()
            if appear("主页") then return true end
            back()
        end, 30)
    end
    path.开始游戏(x)
end

path.别传 = function(x)
    log("别传")
    local chapter = x:find("-")
    chapter = x:sub(1, chapter - 1)
    if findOne("开始行动") then return path.开始游戏(x) end
    path.跳转("首页")
    tap("面板作战")
    if not appear("主页") then return end
    if not wait(function()
            if findOne("别传界面") then return true end
            tap("别传")
        end) then
        return
    end
    if not wait(function()
            -- point模块加载时将GT打平到point,这里对应直接点击别传左侧具体是哪个别传类型的坐标,如骑兵与猎人或火蓝之心等
            tap("别传列表" .. chapter)
            if findOne("进入活动") then return true end
        end) then
        return
    end
    if not wait(function()
            tap("进入活动")
            if not appear("进入活动") then return true end
        end) then
        return
    end
    swip(x)
    ssleep(.5)
    -- point模块加载时将GT打平到point,这里对应直接点击具体的关卡坐标
    tap("作战列表" .. x)
    if not appear("开始行动") then
        wait(function()
            if appear("主页") then return true end
            back()
        end, 30)
    end
    path.开始游戏(x)
end

path.上一次 = function(x)
    log.debug()
    if findOne("开始行动") then return path.开始游戏(x) end
    log.debug()
    path.跳转("首页")
    tap("面板作战")
    if not appear("主页") then return end
    wait(function()
        tap("上一次")
        if not findOne("主页") then return true end
    end, 5)
    if not appear("开始行动", 5) then return end
    -- 专为剿灭设计
    -- 但活动时可能有点问题会，因为
    path.开始游戏(x)
end

update_open_time = function()
    -- 芯片搜索
    pr_open_time = {
        A = { 1, 4, 5, 7 },
        B = { 1, 2, 5, 6 },
        C = { 3, 4, 6, 7 },
        D = { 2, 3, 6, 7 },
    }
    pr_open_time_r = table.reverseIndex(pr_open_time)
    -- pr_open_time_r[1]={"A","B"}
    -- pr_open_time_r[2]={"B","D"}
    -- pr_open_time_r[3]={"C","D"}
    -- pr_open_time_r[4]={"A","C"}
    -- pr_open_time_r[5]={"A","B"}
    -- pr_open_time_r[6]={"B","C","D"}
    -- pr_open_time_r[7]={"A","C","D}
    -- 物资筹备
    ls_open_time = {
        LS = { 1, 2, 3, 4, 5, 6, 7 },
        AP = { 1, 4, 6, 7 },
        CA = { 2, 3, 5, 7 },
        CE = { 2, 4, 6, 7 },
        SK = { 1, 3, 5, 6 },
    }
    ls_open_time_r = table.reverseIndex(ls_open_time)
    -- ls_open_time_r[1]={"LS","AP","SK"}
    -- ls_open_time_r[2]={"LS","CA","CE"}
    -- ls_open_time_r[3]={"LS","CA","SK"}
    -- ls_open_time_r[4]={"LS","AP","CE"}
    -- ls_open_time_r[5]={"LS","CA","SK"}
    -- ls_open_time_r[6]={"LS","AP","SK","CE"}
    -- ls_open_time_r[7]={"LS","AP","CA","CE"}
    -- move CE and LS to last
    local lotr = ls_open_time_r
    for k, v in pairs(lotr) do
        local p = table.find(lotr[k], equalX("CE"))
        if p then
            table.remove(lotr[k], p)
            table.insert(lotr[k], "CE")
        end
        table.remove(lotr[k], table.find(lotr[k], equalX("LS")))
        table.insert(lotr[k], "LS")
    end
    local t = parse_time()
    if all_open_time_start <= t and t < all_open_time_end then
        log("资源本全开")
        pr_open_time = {
            A = { 1, 2, 3, 4, 5, 6, 7 },
            B = { 1, 2, 3, 4, 5, 6, 7 },
            C = { 1, 2, 3, 4, 5, 6, 7 },
            D = { 1, 2, 3, 4, 5, 6, 7 },
        }
        pr_open_time_r[1] = { "A", "B", "C", "D" }
        pr_open_time_r[2] = { "B", "D", "A", "C" }
        pr_open_time_r[3] = { "C", "D", "A", "B" }
        pr_open_time_r[4] = { "A", "C", "B", "D" }
        pr_open_time_r[5] = { "A", "B", "C", "D" }
        pr_open_time_r[6] = { "B", "C", "D", "A" }
        pr_open_time_r[7] = { "A", "C", "D", "B" }

        ls_open_time = {
            LS = { 1, 2, 3, 4, 5, 6, 7 },
            CA = { 1, 2, 3, 4, 5, 6, 7 },
            CE = { 1, 2, 3, 4, 5, 6, 7 },
            SK = { 1, 2, 3, 4, 5, 6, 7 },
            AP = { 1, 2, 3, 4, 5, 6, 7 },
        }
        -- for i = 1, 7 do log(ls_open_time_r[i], i) end
        ls_open_time_r[1] = { "CA", "CE", "AP", "SK", "LS" }
        ls_open_time_r[2] = { "AP", "SK", "CA", "CE", "LS" }
        ls_open_time_r[3] = { "AP", "CE", "CA", "SK", "LS" }
        ls_open_time_r[4] = { "CA", "SK", "AP", "CE", "LS" }
        ls_open_time_r[5] = { "AP", "CE", "CA", "SK", "LS" }
        ls_open_time_r[6] = { "CA", "AP", "SK", "CE", "LS" }
        ls_open_time_r[7] = { "SK", "AP", "CA", "CE", "LS" }
    end
end

path.物资芯片 = function(x)
    -- split PR-A-1 to A and 1, split LS-1 to LS and 1
    local type = x:startsWith("PR") and "pr" or "ls"
    local x0 = type == "pr" and x:sub(4) or x
    local prls_open_time = _G[type .. "_open_time"]
    local prls_open_time_r = _G[type .. "_open_time_r"]
    local x1 = x0:find("-")
    if not x1 then return end
    x1 = x0:sub(1, x1 - 1)
    -- check if open now
    local open_time = prls_open_time[x1]
    local cur_time = tonumber(os.date("%w", os.time() - 4 * 3600))
    if cur_time == 0 then cur_time = 7 end
    if not table.includes(open_time, cur_time) then
        log(x, "未开启")
        log("before fight clean", fight, fight_tick)
        local unavailable_fight = type == "pr" and x:sub(1, 4) or x:sub(1, 2)
        log("unavailable_fight", unavailable_fight)
        fight, fight_tick = clean_table(fight, fight_tick, function(v)
            return v:startsWith(unavailable_fight)
        end)
        log("after fight clean", fight, fight_tick)
        -- end
        return
    end
    -- get index in 芯片搜索
    local cur_open = prls_open_time_r[cur_time]
    local index = table.find(cur_open, equalX(x1))
    if type == "pr" then
        index = index + 5
    else
        index = index + 5 - #cur_open
    end

    local fight_notation = "作战列表" .. x:sub(1, #x - 1) .. "0"
    if not findOne(fight_notation) then
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
            if not findOne("主题曲界面") then return true end
            tap("资源收集")
        end)
        ssleep(.2)
        log("资源收集", index, point["资源收集列表" .. index])
        local p = point["资源收集列表" .. index][1]
        if p < 0 then
            swipq(distance["资源收集列表1"])
            tap("资源收集最左列表" .. index)
        elseif p > screen.width - 1 then
            swipq(distance["资源收集列表9"])
            tap("资源收集最右列表" .. index)
        else
            tap("资源收集列表" .. index)
        end
        appear("资源收集背景页面")
    end
    if findOne("资源收集背景页面") then
        ssleep(.5)
        tap("作战列表" .. x)
        appear("开始行动")
        path.开始游戏(x)
    end
end

clean_jmfight = function()
    log("before jmfight clean", fight, fight_tick)
    -- local unavailable_fight = type == "pr" and x:sub(1, 4) or x:sub(1, 2)
    -- log("unavailable_fight", unavailable_fight)
    fight, fight_tick = clean_table(fight, fight_tick, function(v)
        return get_fight_type(v) == '剿灭'
    end)
    log("after jmfight clean", fight, fight_tick)
end

clean_fight = function(x)
    log("before fight clean", fight, fight_tick)
    fight, fight_tick = clean_table(fight, fight_tick,
        function(v) return v == x end)
end

is_jmfight_enough = function(x, outside)
    log("is_jmfight_enough", x)

    local auto_jm_rewards = function()
        if appear("剿灭奖励未领完", 1) then
            log("自动领取当前剿灭奖励")
            tap("剿灭奖励未领完")
            ssleep(.3)
            if not wait(function()
                    if findOne("剿灭奖励领完") then return true end
                    tap("剿灭奖励领完")
                    ssleep(.2)
                end, 20) then
                return
            end
            wait(function()
                tap("剿灭奖励领取退出")
                ssleep(.2)
            end, 1)
            ssleep(.5)
        end
    end

    -- all fights should check first, because x may not be in jmfight
    if findOne("报酬合成玉已满") and findOne("返还规则") then
        log("find报酬合成玉已满1")
        auto_jm_rewards()
        jmfight_enough = true
        clean_jmfight()
        return true
    end

    -- use state, jmfight only
    if not table.includes(table.values(jianpin2name), x) then
        log.debug()
        return false
    end
    if jmfight_enough then return true end

    if findOne("报酬合成玉已满") then
        log("find报酬合成玉已满2")
        auto_jm_rewards()
        jmfight_enough = true
        clean_jmfight()
        return true
    end
    log("not find报酬合成玉已满")
    return false
end

path.剿灭 = function(x)
    -- 白色皮肤首页误判为已满
    -- if is_jmfight_enough(x) then return end

    path.跳转("首页")
    tap("面板作战")
    if not appear("主页") then return end

    if not wait(function()
            tap("主题曲")
            if findOne("主题曲界面") then return true end
        end) then
        return
    end

    wait(function()
        tap("每周部署")
        if not findOne("主题曲界面") then return true end
    end)

    -- 注意有噪点
    if not appear("主页") then return end
    if not wait(function()
            tap("当期委托")
            if not findOne("主页") then return true end
            -- if findOne("剿灭内左下角合成玉") or findOne("剿灭内左下角合成玉下") then return true end
        end, 5) then
        return
    end

    if is_jmfight_enough(x) then return end
    if not appear("开始行动", 5) then return end
    if is_jmfight_enough(x) then return end

    -- if x ~= "当期委托" then
    -- 当期委托也需要切换
    -- if x ~= "剿灭" then
    -- 都需要切换
    wait(function()
        if not findOne("返还规则") then return true end
        -- tap("剿灭快速切换按钮右下")
        tap("主页右侧")
        disappear("返还规则", 1)
    end, 5)

    if is_jmfight_enough(x) then return end

    wait(function()
        if findOne("剿灭快速切换按钮右下") then return true end
        -- tap("剿灭快速切换按钮右下")
        tap("主页右侧")
        appear("剿灭快速切换按钮右下", 1)
    end, 5)

    if not wait(function()
            if findOne("当前委托侧边栏") then return true end
            tap("剿灭快速切换按钮右下")
            appear("当前委托侧边栏")
        end, 5) then
        return
    end

    if not wait(function()
            if not findOne("当前委托侧边栏") then return true end
            tap("作战列表" .. x)
            disappear("当前委托侧边栏", 1)
        end, 5) then
        return
    end

    log.debug()
    -- end
    if is_jmfight_enough(x) then return end
    log.debug()
    -- ssleep(1)
    -- log(1290)
    appear("开始行动", 5)
    path.开始游戏(x)
end

clean_hdfight = function()
    -- TODO
    log("before hdfight clean", fight, fight_tick)
    -- local unavailable_fight = type == "pr" and x:sub(1, 4) or x:sub(1, 2)
    -- log("unavailable_fight", unavailable_fight)
    fight, fight_tick = clean_table(fight, fight_tick, function(v)
        return get_fight_type(v) == '活动'
    end)
    log("after hdfight clean", fight, fight_tick)
    -- end
end

-- 使用模式匹配去除末尾的数字
removeTrailingDigits = function(str)
    if str == nil then
        return ""
    end
    local pattern = "(.-)%-?%d+$"
    local trimmedStr = string.match(str, pattern)
    log(trimmedStr)
    return trimmedStr
end

path.活动 = function(x)
    log("检测活动开放时间")
    local t = parse_time()
    if t >= hd_open_time_end then
        clean_hdfight()
        return
    end
    if hd_mod ~= "SS" and (not copy_homework) then
        clean_hdfight()
        return
    end
    log("进入活动关卡:", x, "跳过导航:", skip_guide)

    if not skip_guide then
        path.跳转("首页")
        tap(hd_position)
        log(x)
        if string.find(x, "HD-EX-", 1, true) then
            point["活动导航0"] = point["活动导航EX"]
        elseif string.find(x, "HD-S-", 1, true) then
            point["活动导航0"] = point["活动导航S"]
        end
        if not wait(function()
                ssleep(2) --at活动有过场动画
                if findOne("活动导航0") then return true end
                if findOne("跳过剧情") then
                    log(13247, '发现剧情')
                    path.跳过剧情()
                end
            end, 10) then
            return
        end
    end

    local car_check = function() --众生行记
        if dev_mode then return end
        if car_checked then return end
        car_checked = true
        fight_failed_times[cur_fight] = (fight_failed_times[cur_fight] or 0) - 1

        wait(function()
            tap("制铳师之夜进入")
            tap('制铳师之夜提示关闭')
            if findOne("在制铳师之夜界面") then
                ssleep(1) --有时候进入制铳师之夜界面，等待一会才会有提示出现
                if findOne("在制铳师之夜界面") then return true end
                return true
            end
        end, 10, .2)
        if findOne("活动导航0") then return true end
        wait(function()
            tap('制铳师之夜入账')
        end, 2, .2)
        if not wait(function()
                tap('制铳师之夜进入订单界面')
                if findOne("制铳师之夜已经在订单界面") then return true end
            end, 10, .2) then
            return
        end
        for i = 1, 4 do
            tap('制铳师之夜订单列表' .. i)
            appear({ '制铳师之夜接取订单', '制铳师之夜订单已经接取' }, 2)
            ssleep(1.5)
            if findOne("制铳师之夜接取订单") then
                tap('制铳师之夜接取订单')
            end
            if findOne("制铳师之夜领取报酬") then
                wait(function()
                    tap('制铳师之夜领取报酬')
                    tap("获得物资")
                end, 3, .2)
            end
            ssleep(1)
        end
    end

    --car_check() --有些大型活动会自带一些任务
    -- 25年夏活 相谈室
    -- if not car_checked and not copy_homework then
    --     相谈室活动()
    --     car_checked = true
    --     if findOne("相谈室新手教程回合暗") then
    --         if not wait(function()
    --                 if findOne('相谈室回应风格教程') then
    --                     tap('相谈室回应风格教程')
    --                     tap('相谈室使用望气教程点击')
    --                     tap('相谈室使用望气教程点击2')
    --                 end

    --                 tap("相谈室选项1")
    --                 ssleep(0.1)
    --                 tap("相谈室使用")
    --                 ssleep(0.1)
    --                 findTap("相谈室下一轮")
    --                 ssleep(0.1)
    --                 tap("相谈室结束确认选择")
    --                 ssleep(0.1)
    --                 tap('招募说明关闭')
    --                 if findAny({ "相谈室开始交谈", "相谈室开始营业" }) then return true end
    --             end, 40) then
    --             return
    --         end
    --     end
    --     if not wait(function()
    --             if findOne("活动导航0") then return true end
    --             back()
    --         end, 10) then
    --         log.warn("活动导航0未找到")
    --         return
    --     end
    --     path.跳转("首页")
    -- end

    if not skip_guide and not appear({ "活动导航0", "活动商店导航" }, 5) then
        log.warn("未找到活动导航")
        return
    end

    log("skip_guide", skip_guide)
    appear("活动导航0", 3)
    if not skip_guide then
        if not findOne("活动导航0") then return end
        log("已进入活动页面,根据" .. x .. "选择入口")
        if utf8.left(x, 5) == "HD-EX" then --提取x的前面五个，如果是"HD-EX"，则进入活动的ex界面
            if not wait(function()
                    tap("活动导航EX")
                    ssleep(.5)
                    if disappear("活动导航0", 1) then
                        ssleep(.5)
                        return true
                    end
                end, 5) then
                return
            end
        elseif utf8.left(x, 5) == "HD-S-" or utf8.left(x, 6) == "HD-MO-" then --提取x的前面4个，如果是"HD-S-"，则进入活动的S界面
            if not wait(function()
                    tap("活动导航S")
                    ssleep(.5)
                    if disappear("活动导航0", 1) then
                        ssleep(.5)
                        return true
                    end
                end, 5) then
                return
            end
        else --正常流程进入活动的第一阶段界面
            if not wait(function()
                    tap("活动导航0")
                    ssleep(.5)
                    if disappear("活动导航0", 1) then
                        ssleep(.5)
                        if findOne("跳过章节开启旅途") then
                            tap("跳过章节开启旅途")
                        end
                        return true
                    end
                end, 5) then
                return
            end
        end
    else
        log("跳过返回主页导航")
        tap("取消开始行动")
        ssleep(.5)
    end
    toast(x, screen.width * 0.05, screen.height * 0.8)
    swip(x)
    ssleep(.5)
    --exit() --活动手动取点时取消注释
    if x:includes({ "ST-", "TR-", "-P-", "-MO-1" }) or (x:includes({ "-S-" }) and hd_mod == "故事集") then
        --剧情关/教学观/剿灭关只打一遍
        log("剧情关/教学观/剿灭关")
        if findOne("作战列表" .. x) then return true end
    end
    tap("作战列表" .. x)

    if appear("开始剧情", 1) then
        if not wait(function()
                tap("开始剧情")
                sleep(1000)
                if findOne("跳过剧情") then
                    path.跳过剧情()
                    disappear("正在提交反馈至神经", network_timeout)
                end
                if findOne("获得物资") then
                    tap("获得物资")
                    disappear("获得物资", 1.5)
                    return true
                end
            end, 25) then
            return
        end
        return true
    end
    if not appear("开始行动") then
        wait(function()
            if appear("主页") then return true end
            back()
        end, 30)
    end
    log.debug()
    path.开始游戏(x)
end

hd_wrapper = function(func)
    local f = function(...)
        swipu_flipy = scale(100)
        -- -- local keys = {"代理指挥开", "开始行动"}
        -- local keys = {}
        -- local point_store = {}
        -- local rfl_store = {}
        -- local first_point_store = {}
        --
        -- for _, k in pairs(keys) do
        --   point_store[k] = point[k]
        --   rfl_store[k] = rfl[k]
        --   first_point_store[k] = first_point[k]
        --   point[k] = point[k .. "活动"]
        --   rfl[k] = rfl[k .. "活动"]
        --   first_point[k] = first_point[k .. "活动"]
        --
        -- end

        local ret = func(...)

        -- for _, k in pairs(keys) do
        --   point[k] = point_store[k]
        --   rfl[k] = rfl_store[k]
        --   first_point[k] = first_point_store[k]
        -- end
        swipu_flipy = 0

        return ret
    end
    return f
end

path.商店搬空 = function()
    local t = os.time()
    if not shop_period then shop_period = 0 end
    if not shop_day then shop_day = 0 end

    local hd_open_time_end = hd_mod == "故事集" and hd2_open_time_end or hd_open_time_end

    -- 搬商店时间
    local interval = t - hd_open_time_end
    if shop_period == 0 and not (interval < 0 and t > hd_open_time_end - 86400 * (shop_day + 1)) then
        return
    end

    path.跳转("首页")
    tap(hd_position)
    log.debug("进入活动")
    ssleep(4)
    if not wait(function()
            if findOne("活动导航0") or findOne("活动商店导航") then return true end
            if findOne("跳过剧情") and not findAny({ "活动导航0", "活动商店导航" }) then path.跳过剧情() end
            if findOne("教程关闭") then tap("教程关闭") end
        end, 15) then
        return
    end

    if not wait(function()
            if findOne("活动商店导航") then return true end
        end, 10, .1) then
        return
    end
    log.debug("查找是否有未领任务")
    if appear("活动任务导航", 1) then
        log.debug("领取任务")
        if not wait(function()
                tap("活动任务导航")
                ssleep(0.2)
                if appear("活动任务页面", 1) then
                    return true
                end
            end, 3, .2) then
            log.debug("未能进入活动任务页面")
        end
        if appear("活动任务页面", 3) then
            appear("活动任务一键领取", 2)
            if findOne("活动任务一键领取") then
                tap("活动任务一键领取")
                ssleep(.5)
                if not wait(function()
                        tap("活动任务一键领取")
                        ssleep(0.2)
                        if findOne("活动任务页面") then return true end
                    end, 10, .2) then
                    back()
                end
            end
            ssleep(0.2)
            if not wait(function()
                    back()
                    ssleep(0.2)
                    if appear("活动商店导航", 1) then
                        return true
                    end
                end, 10, .2) then
                back()
                return path.商店搬空()
            end
        end
        -- else
        --     snapShot("/sdcard/pictures/未找到活动任务导航.jpg")
    end

    if hd_nickname == "CF" then --怪猎活动
        if not wait(function()
                tap("活动商店导航")
                ssleep(1)
                if findOne("怪猎商店页面") then return true end
            end, 10, .2) then
        end
        ssleep(0.5)
        disappear("正在提交反馈至神经", network_timeout) -- 防止各种掉帧等导致卡在领取等页面
        log.info("进入商店,开始炼金")
        wait(function()
            ssleep(0.5)
            tap("怪猎商店快捷放入")
            ssleep(2)
            if not wait(function()
                    if findOne("怪猎商店开始炼金亮") then
                        tap("怪猎商店开始炼金亮")
                        return true
                    end
                end, 8, .5) then
                log.warn("素材不足,放弃炼金")
                wait(function()
                    back()
                end, 3, .5)
                path.跳转("首页")
                return true
            end
            if not wait(function()
                    tap("怪猎商店开始炼金亮")
                    if findOne("怪猎商店开始炼金灰") then
                        return true
                    end
                end, 10, .5) then
            end
        end, 300)
        log.info('炼金结束')
        path.跳转("首页")
        return
    end

    if not wait(function()
            tap("活动商店导航")
            ssleep(.2)
            if findOne("商店主页") then return true end
        end, 10) then
    end
    ssleep(0.5)
    disappear("正在提交反馈至神经", network_timeout) -- 防止各种掉帧等导致卡在领取等页面
    log.debug("进入商店,开始购买")
    local 回到商店主页 = function()
        if not wait(function()
                if findOne("商店主页") then return true end
                tap("商店顶栏")
            end, 10, .2) then
            return
        end
    end

    -- if not appear("商店主页", 2) then
    --     log.debug("未找到商店")
    --     return
    -- end
    local 物品横间距, 物品纵间距 = scale(516), scale(242)
    回到商店主页()
    local t = os.time()
    --point["商店支付1"] = "1387|837|" .. point["商店主题色"]
    while true do
        if os.time() - t > 5 * 60 then -- 任务总时长5分钟
            log("商店任务超时")
            return
        end
        for x = 0, 2 do -- 3*3商品进行购买
            for y = 0, 2 do
                log("第", x, "列,第", y, "行商品")
                for i = 1, 7 do
                    回到商店主页()
                    local intX, intY = findMultiColor(
                        scale(120) + x * 物品横间距, scale(515) + y * 物品纵间距,
                        scale(386) + x * 物品横间距, scale(555) + y * 物品纵间距,
                        "FFFFFF",
                        scale(17) .. "|" .. scale(-2) .. "|575757|" ..
                        scale(-100) .. "|" .. scale(-5) .. "|5A5A5A",
                        0, 0.83)
                    if intX == -1 then
                        log.warn("未找到购买按钮,可能已购买过")
                        break
                    end
                    if not wait(function()
                            tap({ intX, intY })
                            ssleep(.6)
                            if findOne("活动商店购买物品面板") then return true end
                        end, 1.8) then
                    end
                    if findOne("商店主页") then
                        log.warn("未能进入商品支付页，大概是识别错了")
                        break
                    end
                    -- 点击购买
                    if not wait(function()
                            if findOne("商店购买数量最多") then
                                tap("商店购买数量最多")
                                ssleep(0.2)
                            end
                            if findOne("商店支付1") then
                                tap("商店支付1")
                                ssleep(0.5)
                                disappear("正在提交反馈至神经", network_timeout)
                            end
                            if not findOne("活动商店购买物品面板") then return true end
                        end, 5) then
                    end
                    --disappear("正在提交反馈至神经", network_timeout)
                    if findOne("活动商店购买物品面板") then
                        log.warn("未能购买，大概是钱花完了")
                        return true
                    end
                end
                log("查找下一个商品")
            end
        end
        回到商店主页()
        ssleep(.5)
        path.swip_hd_shop()
        ssleep(.5)
        if findAny({ "活动商店无限池", "活动商店无限池2" }) then
            log("滑动到底")
            break
        end
    end
end

path.故事解锁 = function()
    local t = os.time()
    if not shop_period then shop_period = 0 end
    if not shop_day then shop_day = 0 end
    local hd_open_time_end = hd2_open_time_end

    -- 搬商店时间
    local interval = t - hd_open_time_end
    if shop_period == 0 and not (interval < 0 and t > hd_open_time_end - 86400 * (shop_day + 1)) then
        return
    end
    path.跳转("首页")
    log("故事集剧情解锁")

    tap(hd_position)
    if not wait(function()
            if findOne("活动导航0") or findOne("活动商店导航") then return true end
            if findOne("跳过剧情") and not findAny({ "活动导航0", "活动商店导航" }) then path.跳过剧情() end
            if findOne("教程关闭") then tap("教程关闭") end
        end, 15) then
        return
    end

    if not appear("故事集导航", 5) then
        log.warn("未找到故事集导航")
        return
    end
    if not wait(function()
            tap("故事集导航")
            ssleep(0.2)
            if disappear("故事集导航") or findOne("故事集相片页面") then return true end
        end, 5, .1) then
        return
    end

    disappear("正在提交反馈至神经", network_timeout)
    ssleep(0.5)
    local 故事集页面左侧 = { math.random(10, scale(260)), math.random(scale(145), screen.height) }
    -- 防止各种掉帧等导致卡在领取等页面
    回到故事集主页 = function()
        if not wait(function()
                if findOne("故事集相片页面") then return true end
                tap(故事集页面左侧)
                ssleep(0.2)
            end, 10) then
        end
    end

    local 向左滑动 = function()
        local sx = 1880
        local sy = 300
        local distance = -1800
        gesture({
            {
                point = {
                    { sx,            sy },
                    { sx + distance, sy - scale(math.random(80, 150)) },
                    { sx + distance, sy },
                    { sx + distance, sy - scale(math.random(80, 150)) },
                    { sx + distance, sy },
                },
                start = 0,
                duration = 500,
            },
        })
        sleep(500 + 50)
    end

    for i = 0, 7 do
        回到故事集主页()
        if i == 4 then
            向左滑动()
            ssleep(2)
        end
        local 领取 = function()
            disappear("正在提交反馈至神经", network_timeout)
            if appear("故事集解锁确认页面", 3) then
                tap("故事集解锁确认按钮")
            end
            disappear("故事集解锁确认按钮", network_timeout)
            ssleep(1)
        end
        if i <= 4 then
            if findOne(point["故事集未解锁左列表"][i]) then
                log("find", i)
                tap(point["故事集未解锁左列表"][i])
                领取()
            else
                log("not find", i)
            end
        else
            if findOne(point["故事集未解锁右列表"][i - 4]) then
                log("find2", i)
                tap(point["故事集未解锁右列表"][i - 4])
                领取()
            else
                log("not find2", i)
            end
        end
        if findOne("跳过剧情") then
            path.跳过剧情()
            disappear("正在提交反馈至神经", network_timeout)
        end
    end
    if findOne("跳过剧情") then
        path.跳过剧情()
        disappear("正在提交反馈至神经", network_timeout)
    end
end

path.故事解锁 = function()
    return
end

path.会客厅跳转好友 = function()
    -- deprecated, we now first do 访问好友, then do 基建
    if not findOne("线索传递") then return end

    if not wait(function()
            if findAny({ "进驻信息", "进驻信息选中" }) then return true end
            if findOne("线索传递") then
                tap("返回")
                -- can't ignore sleep
                disappear("线索传递", .5)
            end
        end, 5) then
        return
    end

    if not wait(function()
            if not findAny({ "进驻信息", "进驻信息选中" }) then return true end
            tap("好友")
        end, 5) then
        return
    end

    if not wait(function()
            if findOne("好友列表") then return true end
            tap('好友列表')
        end, 5) then
        return
    end

    if not wait(function()
            if not findOne("主页") then return true end
            tap('访问基建')
        end, 10) then
        return
    end
end

path.添加好友 = function()
    log.debug()
    if not findOne("添加好友红点") then return end
    if not wait(function()
            tap("添加好友红点")
            if findOne("添加好友页面") then return true end
        end, 2) then
        return
    end
    log.debug()
    if not wait(function()
            if findOne("添加好友确认") then
                tap("添加好友确认")
                disappear("正在提交反馈至神经", network_timeout)
            end
            ssleep(.1)
            if not findOne("添加好友红点") then return true end
        end, 10) then
        return
    end
    log.debug()
end

path.访问好友 = function()
    if communication_enough then return end
    log.debug()
    path.跳转("好友")
    log.debug()
    if not disable_add_friend then
        path.添加好友()
    end
    if not wait(function()
            tap('好友列表')
            if findOne("好友列表") then return true end
        end, 10) then
        return
    end
    log.debug()
    if not wait(function()
            tap('访问基建')
            if findAny({ "访问下位灰", "访问下位橘" }) and
                not findOne("好友列表") then
                return true
            end
            -- if not findOne("好友列表") then return true end
        end, 30) then
        return
    end -- 无好友或网络超时10秒
    log.debug()

    if not wait(function(reset_wait_start_time)
            if findOne("今日参与交流已达上限") then
                log("今日参与交流已达上限")
                disappear("正在提交反馈至神经", network_timeout)
                appear("主页", 5)
                communication_enough = true
                return true
            end
            if findOne("访问下位灰") then
                log("访问下位灰")
                return true
            end
            tap("访问下位橘")
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
        end, 30) then
        return
    end
    log.debug()
end

path.公开招募 = function()
    log.debug()
    path.跳转("公开招募")
    log.debug()
    local f, g
    local success = 0

    f = function(i)
        log.debug(i)
        if findOne("公开招募确认蓝") then tap("返回") end
        log.debug()
        if not appear("公开招募箭头", 1) then return end
        log.debug()
        local see
        -- 有灰，等待检测所有状态
        see = appear({
            "聘用候选人列表" .. i, "公开招募列表" .. i,
            "立即招募列表" .. i,
        })
        log.debug()
        if see == "立即招募列表" .. i and recruit_accelerate_mode then
            log.debug()
            if not appear("公开招募箭头") then return end
            wait(function()
                if not findOne("公开招募箭头") then return true end
                tapCard("立即招募列表" .. i)
            end, 5)
            log.debug()
            wait(function()
                if findOne("公开招募箭头") then return true end
                tap("中右确认")
            end, 5)
            log.debug()
            appear("聘用候选人列表" .. i)
            return
        end

        if see == "聘用候选人列表" .. i then
            log(i, 1001)
            -- 这个界面有噪点
            local last_time_see_home = time()
            if not wait(function()
                    if findOne("主页") then last_time_see_home = time() end
                    if time() - last_time_see_home > 1000 then return true end
                    -- if not findOne("公开招募") and not findOne("主页") then
                    --   return true
                    -- end
                    if findTap("聘用候选人列表" .. i) then
                        log.debug()
                        -- disappear("公开招募", 1)
                    end
                    tap("开包skip")
                end, 15) then
                return
            end

            -- 聘用
            if not wait(function()
                    if findOne("公开招募") and findOne("主页") then return true end
                    tap("开包skip")
                end, 15) then
                return
            end
            return f(i)
        end

        if see == "公开招募列表" .. i then
            if not wait(function()
                    if not findOne("公开招募箭头") then return true end
                    if findOne("立即招募列表" .. i) then return true end
                    tap("公开招募点击列表" .. i)
                end, 5) then
                return
            end
            if findOne("立即招募列表" .. i) then return f(i) end
            if appear("公开招募数量红") and appear("公开招募标签刷新灰") then return end
            g = function(pre_tags)
                local tags, r
                wait(function()
                    r = ocr("公开招募标签框范围")
                    tags = {}
                    for _, p in pairs(r) do
                        p.text = tagFix(p.text)             -- 替换常见错别字
                        if table.includes(tag, p.text) then -- 处理已知tag
                            tags[p.text] = { (p.l + p.r) // 2, (p.t + p.b) // 2 }
                        else                                -- 出现未知文字，重试
                            tags = {}
                            return
                        end
                    end
                    if #table.keys(tags) >= 5 and not table.equalKey(tags, pre_tags) then
                        return true
                    end
                    tags = {}
                    log.debug(tags)
                end, 5)

                local skip = false
                if #table.keys(tags) < 5 then skip = true end
                -- 保留标签处理
                -- log(2316, extra_recruit_importance_tag, recruit_accelerate_mode)
                if recruit_accelerate_mode and extra_recruit_importance_tag and
                    table.any(table.keys(tags),
                        function(x)
                            return extra_recruit_importance_tag:find(x)
                        end) then
                    stop("已找到保留标签：" .. extra_recruit_importance_tag, '',
                        true, true)
                end

                log.debug(tags, skip)
                -- exit()
                local tag4 = table.filter(tag5, function(rule)
                    return table.all(rule[1], function(m) return tags[m] end)
                end)
                -- 有噪点，得等
                local can_refresh = appear({
                    "公开招募标签刷新蓝", "公开招募标签刷新灰",
                }) == "公开招募标签刷新蓝"

                -- 如果勾选非保底，且不能刷新时，也招
                if auto_recruit0 and not can_refresh then
                    table.extend(tag4, tag0)
                end

                log.debug(tag4)
                -- toast(JsonEncode(tags))

                if #tag4 == 0 or skip then
                    if not skip and can_refresh then
                        tap("公开招募标签刷新蓝")
                        if not disappear("公开招募时间减", 10) then return end
                        if not wait(function()
                                if findOne("公开招募时间减") then return true end
                                tap("公开招募右确认")
                            end, 10) then
                            return
                        end
                        -- if not appear("公开招募时间减") then return end
                        return g(tags)
                    else
                        if not wait(function()
                                if findOne("公开招募箭头") and
                                    findOne("公开招募列表" .. i) then
                                    return true
                                end
                                if findOne("公开招募时间减") then
                                    tap("返回")
                                    disappear("公开招募时间减", 1)
                                end
                            end, 5) then
                            return
                        end
                        if recruit_accelerate_mode then
                            stop("已遇到需保留情况", '', true, true)
                        end
                    end
                else
                    -- 最大星数
                    local max_star = -1
                    local list = {}

                    for _, v in pairs(tag4) do
                        -- 同星级需要优选“资深”优选，不选会出弹窗。
                        local better = max_star < v[2] or max_star == v[2] and
                            (v[1][1] and v[1][1]:find("资深"))

                        if better then
                            max_star = v[2]
                            list = v[1]
                        end
                    end

                    if max_star >= 0 and not _G['auto_recruit' .. max_star] then
                        log("notify 存在", max_star, list)
                        -- table.insert(qqmessage, "可招募：" .. table.join(list))
                        table.insert(qqmessage, table.join(list))
                        if recruit_accelerate_mode then
                            stop(table.join(list), '', true, true)
                        end
                    end

                    if max_star >= 0 and _G['auto_recruit' .. max_star] then
                        for _, v in pairs(list) do tap(tags[v]) end
                        if max_star == 1 then
                            -- 3.5小时
                            tap("公开招募时间加")
                            tap("公开招募时间加")
                            tap("公开招募时间加")
                            tap("公开招募时间减2")
                        else
                            -- 9小时
                            tap("公开招募时间减")
                        end
                        -- 点太快会无效
                        ssleep(.25)
                        wait(function(reset_wait_start_time)
                            tap("公开招募确认蓝")
                            if findOne("正在提交反馈至神经") then
                                reset_wait_start_time()
                            end
                            if appear({ "公开招募箭头", "返回确认界面" }, 3) then
                                return true
                            end
                        end, 5)
                        if not appear({ "公开招募箭头", "返回确认界面" }) then
                            return
                        end

                        -- 漏判高星弹出提示
                        -- 这种情况出现并非ocr出错，而是选了另一个5星组合，而没选资深)
                        -- 已经添加优选资深，这块逻辑不会走到，另外刷新时也需要添加判断，单加这里也不够
                        -- if findOne('返回确认界面') then
                        --   -- 关闭提示
                        --   wait(function()
                        --     if not findOne('返回确认界面') then
                        --       return true
                        --     end
                        --     tap("左取消")
                        --   end, 5)
                        --   -- 标签界面 => 公招界面
                        --   if not wait(function()
                        --     if findOne("公开招募箭头") and
                        --       findOne("公开招募列表" .. i) then
                        --       return true
                        --     end
                        --     if findOne("公开招募时间减") then
                        --       tap("返回")
                        --       disappear("公开招募时间减", 1)
                        --     end
                        --   end, 5) then return end
                        -- end
                    end
                end
            end
            g()
        end
    end

    -- 第二个容易被刷新通知卡着，最后再做
    -- for i = 1, #point.公开招募列表 do
    for _, i in pairs(table.slice({ 1, 3, 4, 2 }, 1, #point.公开招募列表)) do
        f(i)
    end
    appear("主页", .5)
end

path.退出账号 = function()
    auto(update(path.base, {
        bilibili_framelayout_only = false,
        [function()
            return findOne("bilibili_framelayout_only") and
                not findOne("bilibili_username_inputbox")
        end] = function()
            if log_login_to_cloud == true then
                cloud.addLog("INFO", "开始登录", "正在尝试登录", "")
            end
            auto(path.bilibili_login_change, nil, 0, default_auto_timeout_second, true)
            if log_login_to_cloud == true then
                cloud.addLog("INFO", "登录成功", "已成功登录至游戏", "")
            end
        end,
        framelayout_only = false,
        [function()
            return findOne("framelayout_only") and not findOne("username_inputbox")
        end] = function()
            if log_login_to_cloud == true then
                cloud.addLog("INFO", "开始登录", "正在尝试登录", "")
            end
            auto(path.login_change, nil, 0, default_auto_timeout_second, true)
            if log_login_to_cloud == true then
                cloud.addLog("INFO", "登录成功", "已成功登录至游戏", "")
            end
        end,
        面板 = function()
            tap("面板设置", true)
            if not appear("返回3") then return end
            -- the old way
            wait(function()
                tap("账号登出" .. (appid == oppid and '' or '2'))
                ssleep(.1)
                tap("右右确认")
            end, 1)

            -- the now way
            if not wait(function()
                    tap("用户中心")
                    if appear("login_out", 1) then return true end
                end) then
                return
            end

            ssleep(.5)
            clickNodeFalse(findOne("login_out"))
            appear("yes")
            --ssleep(.5)
            clickNodeFalse(findOne("yes"))
            ssleep(.5)
        end,
        --  开始唤醒 = "账号管理",
        开始唤醒 = function()
            check_login_frequency()
            if not findOne("账号管理") then
                tap("开始登录单独")
            else
                tap("账号管理")
            end
            disappear("开始唤醒")
        end,
        bilibili_username_inputbox = true,
        username_inputbox = true,
        手机验证码登录 = true,
    }, nil, true), path.fallback, 0, default_auto_timeout_second)
end

path.前瞻投资 = function(lighter)
    -- 防止日志占用资源过多把脚本挤掉
    -- 防止无障碍节点获取失效，而反复重启游戏（在7时42分记录中浪费了2分多钟）
    -- if zl_disable_game_up_check then disable_game_up_check = true end
    -- 3.6.0发现当节点获取失效时，点击、找色其实都出问题了

    if findOne("凋零残响") then
        -- local last_time_see = time()
        wait(function()
            if findAny({ "常规行动", "面板" }) then return true end
            -- if findOne("凋零残响") then
            --   last_time_see = time()
            -- elseif time() - last_time_see > 5000 then
            --   return true
            -- end
            tap("战略确认")
        end, 15)
        return
    end

    -- 每8小时做日常
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

    local in_fight_return = ''
    local restart = function()
        toast(in_fight_return or '重开')

        ssleep(3)
        -- if not restart_game_check(zl_restart_interval) then
        if not request_memory_clean() then
            path.前瞻投资(true)
        else
            path.跳转("首页")
        end

        -- 脚本内存泄漏45M/h => 每小时重启acc进程
        -- 游戏内存泄漏66M/h => 每小时重启游戏

        -- -- 关闭游戏然后重启脚本
        -- if restart_game_check(zl_restart_interval) then
        --   saveConfig("hideUIOnce", "true")
        --   save_extra_mode(extra_mode, extra_mode_multi)
        --   log(3326, loadConfig("restart_mode_hook", ''))
        --   restartScript()
        -- end

        -- 抽空点亮幕后筹备
    end

    local jumpout
    if findOne("战略返回") then path.fallback.战略返回() end

    if findOne("暂停中") and findOne("生命值") then restartapp(appid) end

    -- 先导航到常规行动
    if not zl_navigation('常规行动', '傀影与猩红孤钻') then return end

    if zl_level_enough then
        if zl_no_waste then
            -- todo
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end
        傀影肉鸽完成 = true
        return
        --stop("肉鸽结束", '', false, true)
    end

    if zl_coin_enough then
        if zl_no_waste then
            -- todo
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end
        傀影肉鸽完成 = true
        return
        -- stop("肉鸽结束", '', false, true)
    end

    -- 检测等级
    local zl_level_check = function()
        if zl_disable_inspect_level then return -1 end
        if not (str2int(zl_max_level, 0) > 0) then return end
        if not findOne("常规行动") then return end
        -- if not wait(function()
        --   if not findOne("常规行动") then return true end
        --   tap("战略等级入口")
        -- end) then return end

        local prex = -1
        local ans = wait(function()
            ssleep(.5)
            -- if not findOne("常规行动") then return 0 end
            -- local x = ocr("战略等级") or {}
            local r = point["战略等级"]
            local x = ocrBinaryEx(r[1], r[2], r[3], r[4], "000000-feb525") or {}
            -- local x = ocrEx(r[1], r[2], r[3], r[4]) or {}
            log.debug(x)
            x = (x[1] or {}).text or ""
            x = number_ocr_correct(x)
            x = str2int(x:match("^(%d+).*"), -1)
            log.debug(x)
            if x == 125 and not findOne("战略等级" .. x) then return end
            if x >= 0 and x <= 155 and x == prex then return x end
            -- if x >= 0 and x <= 140 then return x end
            -- if x >= 0 then return x end
            prex = x
        end, 5)
        -- wait(function()
        --   tap("返回")
        --   if appear("常规行动") then return true end
        -- end, 5)
        return ans
    end

    local zl_level = zl_level_check() or -1
    if not zl_level_enough and zl_level == str2int(zl_max_level, 10000) then
        zl_level_enough = true
        captureqqimagedeliver("INFO", "肉鸽任务完成", table.join(qqmessage,
                ' ') .. " " ..
            (zl_level or '') .. "等级已满")
        傀影肉鸽完成 = true
        return
    end

    -- 检测源石锭
    local zl_coin_check = function()
        if zl_disable_inspect_level then return -1 end
        if not (str2int(zl_max_coin, 0) > 0) then return end
        if str2int(zl_max_coin, 0) >= 999 then return end

        if not findOne("常规行动") then return end
        if not wait(function()
                if not findOne("常规行动") then return true end
                tap("战略源石锭入口")
            end) then
            return
        end

        local prex = -1
        local ans = wait(function()
            ssleep(.5)
            -- if not findOne("常规行动") then return 0 end
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
            if appear("常规行动") then return true end
        end, 5)

        return ans
    end

    local zl_coin = zl_coin_check() or -1
    if not zl_coin_enough and zl_coin >= str2int(zl_max_coin, 10000) then
        zl_coin_enough = true
        captureqqimagedeliver("INFO", "肉鸽任务完成", table.join(qqmessage,
                ' ') .. " " ..
            (zl_coin or '') .. "源石锭已满")
        傀影肉鸽完成 = true
        return
    end
    log.debug()

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
    -- if not findOne("常规行动") then return end

    -- log(zl_coin, zl_level)
    -- exit()
    -- 放弃探索
    if findOne("放弃探索") then
        if not wait(function()
                if findOne("返回确认界面") then return true end
                tap("放弃本次探索")
            end, 5) then
            log.debug()
            -- 无法直接放弃的情况 不处理
            if not wait(function()
                    if not findOne("常规行动") then return true end
                    tap("继续探索")
                    ssleep(.5)
                    log.debug()
                end, 5) then
                return
            end

            if not wait(function()
                    if findOne("常规行动") then return true end
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
                if findOne("常规行动") and not findOne("放弃探索") then
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
    if jumpout then return end

    -- 等级满了，放弃行动后回到首页再截个图
    if zl_level_enough or zl_coin_enough then
        -- wait(function(reset_wait_start_time)
        --   if not findOne("常规行动") then return true end
        --   tap("战略确认")
        -- end,5)

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
        -- return path.fallback.签到返回()
    end
    log.debug()
    -- 回到常规行动？

    -- 点幕后筹备后继续
    if lighter and not lighter_enough and not zl_disable_lighter then
        local f = function()
            -- 进入幕后
            if not wait(function()
                    tap("战略确认")
                    tap("幕后筹备")
                    if findOne("幕后筹备界面") then return true end
                end, 5) then
                return
            end

            -- 确认是否已满
            ssleep(.1)
            tap("幕后筹备升级右列表1")
            appear({ "幕后筹备升级有", "幕后筹备升级无" }, .5)
            if findOne("幕后筹备升级无") then
                lighter_enough = true
                return
            end

            -- 确认类型
            local lists = {
                "幕后筹备升级左列表", "幕后筹备升级中3列表",
                "幕后筹备升级中2列表", "幕后筹备升级中1列表",
            }
            local list = point["幕后筹备升级右列表"]
            if not findOne("幕后筹备升级") then
                local found
                for _, p in pairs(lists) do
                    tap(p .. 1)
                    if appear("幕后筹备升级", .5) then
                        list = point[p]
                        found = true
                        break
                    end
                end
                if not found then return end
            end

            -- 从左向右点
            list = map(function(p) return point[p] end, list)
            table.sort(list, function(a, b) return a[1] < b[1] end)

            tap(list[2])
            for _, p in pairs(list) do
                tap(p)
                -- local jumpout
                if not wait(function(reset_wait_start_time)
                        appearTap("幕后筹备升级有", .25)
                        if findAny({ "幕后筹备升级无", "幕后筹备升级不" }) then
                            return true
                        end
                        -- if not appear({"幕后筹备升级", "正在提交反馈至神经"}) then
                        --   jumpout = true
                        --   return true
                        -- end
                        if findOne("正在提交反馈至神经") then
                            reset_wait_start_time()
                        end
                    end, 2) then
                    break
                end
            end
        end
        f()
        return
    end

    -- 开始探索
    if not wait(function(reset_wait_start_time)
            if findOne("战略返回") then return true end
            -- 第二次数据更新处理
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
        -- 初始选难度
        tap("战略难度列表" .. (zl_more_experience and "2" or "1"))
        return
    end
    if jumpout then return end

    -- 开始探索 一路按到 招募干员
    local first_time_see_first_card = 0
    if not wait(function(reset_wait_start_time)
            if findOne("初始招募") then return true end
            if findOne("正在提交反馈至神经") then reset_wait_start_time() end
            tap("战略确认")
            tap("战略确认")
            tap("战略确认")
            if findOne("指挥分队") then
                if first_time_see_first_card == 0 then
                    first_time_see_first_card = time()
                end
                if time() - first_time_see_first_card > 2000 then
                    tap("指挥分队1")
                    appear("指挥分队确认", 1)
                    ssleep(.5)
                    tap("指挥分队确认")
                    disappear("指挥分队确认")
                    first_time_see_first_card = 0
                end
            else
                first_time_see_first_card = 0
            end

            -- 因为小号只有指挥分队，但每一秒只做一次
            -- if findAny({"指挥分队", "指挥分队确认"}) and time() -
            --   last_time_see_first_card > first_card_interval then
            --   first_card_interval = 5000 -- 1秒
            --   findTap("指挥分队")
            --   wait(function() tap("战略确认") end, 0.5)
            --   if findTap("指挥分队确认") then disappear("指挥分队确认") end
            --   last_time_see_first_card = time()
            -- end
        end, 10) then
        return
    end

    if not wait(function(reset_wait_start_time)
            if findOne("初始招募") then return true end
            tap("近卫招募券")
        end, 10) then
        return
    end

    -- 第二人，这里三步带了 剿灭说明 处理
    if not wait(function()
            if findOne("确认招募") then return true end
            if findOne("剿灭说明") then tap("剿灭说明") end
            tap("辅助招募券")
            tap("招募说明关闭")
        end, 10) then
        return
    end

    if not wait(function()
            tap("放弃招募")
            if findOne("剿灭说明") then tap("剿灭说明") end
            if not findOne("确认招募") then return true end
        end, 10) then
        return
    end

    if not wait(function()
            tap("右右确认")
            if findOne("剿灭说明") then tap("剿灭说明") end
            if findOne("初始招募") then return true end
        end, 10) then
        return
    end

    -- 第三人
    if not wait(function()
            tap("医疗招募券")
            tap("招募说明关闭")
            if findOne("确认招募") then return true end
        end, 10) then
        return
    end

    if not wait(function()
            tap("放弃招募")
            if not findOne("确认招募") then return true end
        end, 10) then
        return
    end

    if not wait(function()
            tap("右右确认")
            if findOne("初始招募") then return true end
        end, 10) then
        return
    end

    -- 第一人
    if not wait(function()
            tap("近卫招募券")
            tap("招募说明关闭")
            if not findOne("初始招募") and findOne("确认招募") then
                return true
            end
        end, 10) then
        return
    end

    local help_fight = function()
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

        -- 山2、羽毛笔1、耀光1、史尔特尔2、煌2、帕拉斯1、赫拉格2、艾丽妮1、银灰1、幽灵鲨1、拉狗2
        local order = {
            { "山", 1, 2 }, { "羽毛笔", 0, 1 }, { "耀骑士临光", 0, 1 },
            { "史尔特尔", 99, 2 }, { "帕拉斯", 0, 1 }, { "赫拉格", 99, 2 },
            { "艾丽妮", 0, 1 }, { "斯卡蒂", 99, 1 }, { "银灰", 0, 1 },
            { "幽灵鲨", 99, 1 }, { "拉普兰德", 0, 1 },
        }
        local best = table.findv(order, function(x) return name2point[x[1]] end)
        if not best then return end
        zl_skill_times = best[2]
        zl_skill_idx = best[3]
        -- log("best", best)
        -- if not best then return point.战略助战干员列表1, 0, 1 end
        local p = name2point[best[1]]
        p = { p.l, p.t }
        tap(p)
        disappear("战略助战界面", 5)
        wait(function()
            if findOne("初始招募") then return true end
            tap("开包skip")
            tap("战略助战确认")
        end, 5)
    end

    if not wait(function()
            if findAny({ "初始招募", "战略返回" }) then
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
                help_fight()
            else
                stop("请设置近卫干员序号(1~12)", '', true, false)
            end
        end, 10) then
        return
    end

    if not appear("初始招募") then return end

    log.debug()
    -- 进入古堡 必须分为两段，否则产生位移
    if not wait(function()
            if not findOne("初始招募") then return true end
            tap("进入古堡")
        end, 5) then
        return
    end

    -- if not wait(function()
    --   if findOne("编队") then return true end
    --   tap("进入古堡")
    -- end, 10) then return end

    log.debug()
    if not appear("战略帮助", 10) then return end

    -- 幻觉选择性放弃
    if findOne("偏执的") then
        local all = {
            "迷茫的", "盲目的", "暴怒的", "孤独的", "偏执的",
            "敏感的", "臆想的", "生存的", "谨慎的",
        }
        local accept = { "孤独的", "偏执的", "谨慎的" }

        -- local danger_accept = {
        --   "敏感的", "臆想的", "生存的",
        -- }

        if zl_accept_mg then table.insert(accept, "敏感的") end
        if zl_accept_yx then table.insert(accept, "臆想的") end
        if zl_accept_sc then table.insert(accept, "生存的") end

        local cur = {}
        if not wait(function()
                cur = ocr("幻觉范围")

                -- 分割
                for _, v in pairs(cur) do
                    local txt = v.text
                    while #txt > 9 do
                        table.insert(cur, { text = txt:sub(#txt - 8, #txt) })
                        txt = txt:sub(1, #txt - 9)
                    end
                    v.text = txt
                end

                log("cur", cur)
                -- 模糊匹配
                for _, v in pairs(cur) do
                    local txt = v.text
                    if #txt ~= 9 or not txt:endsWith("的") then return end
                    local scores = map(function(x)
                        return { x, chineseUnicodeStringMatch(x, txt) }
                    end, all)
                    table.sort(scores, function(a, b) return a[2] < b[2] end)
                    log("scores", scores)
                    if scores[#scores][2] == 2 and scores[#scores - 1][2] < 2 then
                        log("模糊匹配before", txt)
                        txt = scores[#scores][1]
                        log("模糊匹配after", txt)
                    end
                    v.text = txt
                end

                if table.all(cur, function(x) return table.includes(all, x.text) end) then
                    return true
                end
            end, 5) then
            in_fight_return = "未知幻觉重试：" ..
                table.join(map(function(x) return x.text end, cur))
            return restart()
        end
        for _, c in pairs(cur) do
            if not table.includes(accept, c.text) then
                in_fight_return = "幻觉重试：" ..
                    table.join(map(function(x) return x.text end, cur))
                return restart()
            end
        end
    end

    -- 再看不期而遇
    for col = 1, 2 do
        local unexpect
        if findOne("第一层不期而遇" .. col .. "入口列表1") then
            log("第" .. col .. "列 " .. "3关卡状态")
            unexpect = {
                "第一层不期而遇" .. col .. "列表1",
                "第一层不期而遇" .. col .. "列表3",
                "第一层不期而遇" .. col .. "列表5",
            }
        elseif findOne("第一层不期而遇" .. col .. "入口列表2") then
            log("第" .. col .. "列 " .. "2关卡状态")
            unexpect = {
                "第一层不期而遇" .. col .. "列表2",
                "第一层不期而遇" .. col .. "列表4",
            }
        else
            log("第" .. col .. "列 " .. "1关卡状态")
            unexpect = { "第一层不期而遇" .. col .. "列表3" }
        end
        for k, v in pairs(unexpect) do
            unexpect[k] = {
                text = findOne(v) and "不期而遇" or '作战',
                l = str2int(point[v]:match("^(%d+)|"), 0),
                t = str2int(point[v]:match("^%d+|(%d+)|"), 0),
            }
        end
        _G["unexpect" .. col .. "ocr"] = unexpect
    end

    -- 设置商店
    fight2 = point.第一层作战2
    fight2 = { l = fight2[1], t = fight2[2] }

    if not table.find(unexpect2ocr,
            function(x) return x.text == "不期而遇" end) then
        in_fight_return = "第三列没找到不期而遇"
        return restart()
    end

    local from_bottom_node = findOne("第一层从下方来")

    if not table.find(unexpect1ocr,
            function(x) return x.text == "不期而遇" end) then
        in_fight_return = "第二列没找到不期而遇"
        return restart()
    end
    log("第二列 ", unexpect1ocr)
    log("第三列 ", unexpect2ocr)

    log.debug()
    -- 根据不期而遇来选择路径，只有边上两个均为不期而遇才行
    local unexpect1, unexpect2
    if unexpect1ocr[1].text == "不期而遇" and unexpect2ocr[1].text ==
        "不期而遇" then
        unexpect1 = unexpect1ocr[1]
        unexpect2 = unexpect2ocr[1]
    elseif unexpect1ocr[#unexpect1ocr].text == "不期而遇" and
        unexpect2ocr[#unexpect2ocr].text == "不期而遇" then
        unexpect1 = unexpect1ocr[#unexpect1ocr]
        unexpect2 = unexpect2ocr[#unexpect2ocr]
    elseif #unexpect1ocr == 1 then
        unexpect1 = unexpect1ocr[1]
        unexpect2 = table.findv(unexpect2ocr,
            function(x) return x.text == "不期而遇" end)
    elseif #unexpect2ocr == 1 then
        unexpect2 = unexpect2ocr[1]
        unexpect1 = table.findv(unexpect1ocr,
            function(x) return x.text == "不期而遇" end)

        -- 2 走 3 且 3只有中间为不期而遇时，确认2的上还是下来的
    elseif #unexpect2ocr == 3 and unexpect2ocr[2].text == '不期而遇' and
        #unexpect1ocr == 2 and unexpect1ocr[1].text == '不期而遇' and
        not from_bottom_node then
        unexpect2 = unexpect2ocr[2]
        unexpect1 = unexpect1ocr[1]
    elseif #unexpect2ocr == 3 and unexpect2ocr[2].text == '不期而遇' and
        #unexpect1ocr == 2 and unexpect1ocr[2].text == '不期而遇' and
        from_bottom_node then
        unexpect2 = unexpect2ocr[2]
        unexpect1 = unexpect1ocr[2]
    else
        in_fight_return = "难以找到一条全是不期而遇的路"
        return restart()
    end

    if not wait(function()
            tap("第一层作战1")
            if appear("进入界面", 1) then return true end
        end) then
        in_fight_return = "无法进入作战"
        return restart()
    end

    -- check which fight
    local fight1ocr = {}
    if not wait(function()
            fight1ocr = ocr("第一层作战")

            if #fight1ocr > 1 then
                log.debug(4880, fight1ocr)
                local fight1 = fight1ocr[2]
                -- 只支持三种作战
                if fight1.text:includes({ "意", "外" }) then
                    fight1.text = "意外"
                elseif fight1.text:includes({ "礼", "炮", "队" }) then
                    fight1.text = "礼炮小队"
                elseif fight1.text:includes({ "与", "虫", "伴" }) then
                    fight1.text = "与虫为伴"
                elseif fight1.text:includes({ "驯", "兽", "屋" }) then
                    fight1.text = "驯兽小屋"
                elseif fight1.text:includes({ "死", "斗" }) then
                    fight1.text = "死斗"
                else
                    log("不知道什么作战：" .. fight1.text)
                    return
                end
                return true
            end
        end, 5) then
        stop("不知道第一个作战是什么", 'cur')
        return
    end
    log(fight1ocr)
    local fight1 = fight1ocr[2]
    if zl_skip_hard and fight1.text == "驯兽小屋" then
        in_fight_return = "驯兽小屋重试"
        return restart()
    end

    -- tap({fight1.l, fight1.t})
    -- if not appear("进入界面") then
    --   return
    -- end
    if not wait(function()
            if findOne("快捷编队") then return true end
            tap("进入")
        end, 10) then
        return
    end

    if not wait(function()
            if findOne("确认招募") then return true end
            tap("快捷编队")
        end, 10) then
        return
    end

    if not wait(function()
            if findOne("攻击范围") and
                (zl_skill_idx ~= 2 or zl_skill_idx == 2 and findOne("战略二技能")) then
                return true
            end

            tap("近卫招募列表1")
            if not appear("攻击范围", 1) then return end
            if zl_skill_idx == 2 then
                tap("战略二技能")
                if not appear("战略二技能", 1) then return end
            end
        end, 10) then
        return
    end

    if not wait(function()
            if not findOne("确认招募") then return true end
            tap("确认招募")
        end, 10) then
        return
    end

    if not appear("快捷编队") then return end

    -- -- 回到上一级（这里好bug，选完人，开始行动就没了，只能回退）
    -- if not wait(function()
    --   if not findOne("快捷编队") then return true end
    --   tap("返回")
    --   disappear("快捷编队", 1)
    -- end, 10) then return end
    --
    -- if not wait(function()
    --   if findOne("快捷编队") then return true end
    --   tap("继续探索")
    -- end, 10) then return end

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

    -- 游戏界面
    if not wait(function()
            if findOne("单选确认框") then return true end
            if findOne("生命值") then return true end
        end, 30) then
        return
    end

    if not findOne("生命值") then return end

    -- 需要等等才能点
    appearTap("两倍速", 3)

    if #in_fight_return > 0 then
        toast(in_fight_return .. "，10秒后重开")
        ssleep(10)
        tap("面板设置", true)
        ssleep(2)
        tap("放弃行动")
        ssleep(2)
        tap("右确认")

        wait(function()
            if findAny({
                    "战略返回", "面板", "活动公告返回", "签到返回",
                    "签到返回黄", "开始唤醒", "常规行动",
                    "bilibili_framelayout_only", "framelayout_only",
                }) then
                return true
            end
            tap("战略确认")
        end, 60)

        return
    end

    if not wait(function()
            if findOne("干员费用够列表1") then return true end
            if not findOne("生命值") then
                log.debug()
                -- return true
            end
        end, 30) then
        return
    end

    -- 重复拖拽
    wait(function()
        log.debug()
        tap("干员费用够列表1")
        disappear("干员费用够列表1", 0.5)
        -- 部署 拖拽当前第一个干员至部署位dst，方向朝左或右
        local direction = 4
        if table.includes({ "礼炮小队", "驯兽小屋" }, fight1.text) then
            direction = 2
        end
        if fight1.text == '死斗' then direction = 1 end
        deploy3(1, fight1.text, direction)
        log.debug()
        wait(function()
            if findOne("生命值") then return true end
            tap("开始行动1")
        end)

        log.debug()
        if not appear("干员费用够列表1", 5) then return true end
        log.debug()
    end, 20)
    log.debug()

    appear("生命值")

    log.debug()
    -- 超时作战不对劲 超5分钟
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

    appear({ "战略返回", "凋零残响" }, 30)
    if findOne("凋零残响") then return end
    if not findOne("战略返回") then return end

    local drop_page = false
    if not wait(function()
            if not drop_page then tap("战略确认") end
            if zl_more_repertoire then findTap("剧目") end
            if zl_more_experience then findTap("招募券") end
            findTap("收藏品")
            if findTap("源石锭") then drop_page = true end
            local p = findOne("不要了")
            log.debug()
            if p and findOne("战略返回") then
                tap({ p[1] + scale(765 - 668), scale(774) })
                tap({ p[1] + scale(765 - 668), scale(774) })
                tap({ p[1] + scale(765 - 668), scale(774) })
                tap({ p[1] + scale(765 - 668), scale(774) })
            end

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
                if not appear({ "战略返回", "战略帮助" }) then
                    tap("战略确认")
                end
            end
            -- if disappear("战略返回",0.5) then return true end
            if findAny({ "常规行动", "战略帮助" }) and not findOne("确认招募") then
                return true
            end
        end, 30) then
        return
    end

    -- if not appear("战略返回", 5) then return end

    if not findOne("战略帮助") then
        log.debug()
        return
    end

    local last_time_see_help

    -- 不期而遇1 两次尝试
    tap({ point.第一层下一个[1], unexpect1.t })
    -- ssleep(.2)
    if not appear("进入界面") then return end
    last_time_see_help = time()
    if not wait(function()
            if findOne("战略帮助") then last_time_see_help = time() end
            if time() - last_time_see_help > 250 then return true end
            tap("不期而遇第三选项")
        end, 3) then
        swipzl("right")
        tap({ unexpect1.l, unexpect1.t })
        last_time_see_help = time()
        if not wait(function()
                if findOne("战略帮助") then last_time_see_help = time() end
                if time() - last_time_see_help > 250 then return true end
                tap("不期而遇第三选项")
            end, 3) then
            return
        end
    end

    wait(function()
        if findOne("确认招募") then
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
        end
        if findOne("战略帮助") then return true end
        -- 需要提前退出
        if not appear("战略返回", 1) and appear("战略帮助") then
            return true
        end
        tap("不期而遇第三选项")
        tap("不期而遇第三选项")
        tap("不期而遇第三选项")
        tap("不期而遇第三选项")
        tap("不期而遇第二选项")
        log.debug(findOne("确认招募"))
    end, 10)

    if not appear("战略帮助", 5) then return end

    -- 不期而遇2 两次尝试
    tap({ point.第一层下一个[1], unexpect2.t })
    -- ssleep(.2)
    -- ssleep(.2)
    if not appear("进入界面") then return end
    last_time_see_help = time()
    if not wait(function()
            if findOne("战略帮助") then last_time_see_help = time() end
            if time() - last_time_see_help > 250 then return true end
            tap("不期而遇第三选项")
        end, 3) then
        swipzl("left")
        tap({ unexpect2.l, unexpect2.t })
        last_time_see_help = time()
        if not wait(function()
                if findOne("战略帮助") then last_time_see_help = time() end
                if time() - last_time_see_help > 250 then return true end
                tap("不期而遇第三选项")
            end, 3) then
            return
        end
    end

    wait(function()
        if findOne("确认招募") then
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
        end
        if findOne("战略帮助") then return true end
        if not appear("战略返回", 1) and appear("战略帮助") then
            return true
        end
        tap("不期而遇第三选项")
        tap("不期而遇第三选项")
        tap("不期而遇第三选项")
        tap("不期而遇第三选项")
        tap("不期而遇第二选项")
        log.debug(findOne("确认招募"))
    end, 10)

    if not appear("战略帮助", 5) then return end
    -- 商店
    -- swipzl("left")
    -- tap({fight2.l, fight2.t})
    fight2.l = max(point.第一层下一个[1], fight2.l)
    tap({ fight2.l, fight2.t })
    if not appear("进入界面") then return end

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

    local goto_next_level = function()
        if not zl_more_experience then return end
        -- 去第二层
        wait(function()
            if not findOne("战略返回") then return true end
            tap("诡意行商离开")
        end, 10)
        wait(function()
            if findOne("战略返回") then return true end
            tap("诡意行商离开")
        end, 10)
    end

    local buy = function()
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

    local coin = function()
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
            if findAny({ "诡意行商投资", "诡意行商离开" }) then return true end
            tap("进入")
        end, 3) then
        -- check_goods()
        -- goto_next_level()
        return
    end

    check_goods()

    if not zl_skip_coin then coin() end

    if zl_more_experience then
        if not wait(function()
                if findOne("诡意行商离开") then return true end
                tap("开包skip")
            end, 5) then
            return
        end
        for i = 1, 10 do if not buy() then break end end
    end

    return goto_next_level()
end

path.战略前瞻投资 = never_end_wrapper(path.前瞻投资)
path.水月战略前瞻投资 = never_end_wrapper(path.水月与深蓝之树前瞻投资)
path.萨米战略前瞻投资 = never_end_wrapper(path.探索者的银淞止境前瞻投资)
path.萨卡兹战略前瞻投资 = never_end_wrapper(path.萨卡兹的无终奇语前瞻投资)
path.界园战略前瞻投资 = never_end_wrapper(path.界园前瞻投资)

path.肉鸽任务 = function()
    pcall(upload_launch_info, "rouge")
    log("肉鸽任务开始")
    if zl_ky then
        log("傀影")
        -- zl.放弃未结束的肉鸽探索()
        zl_level_enough = false
        傀影肉鸽完成 = false
        zl_skip_coin = zl_skip_coin_ky
        zl_only_coin = zl_only_coin_ky
        zl_need_goods = zl_need_goods_ky
        zl_max_level = zl_max_level_ky
        zl_max_coin = zl_max_coin_ky
        if zl_max_level_ky == 'max' then zl_max_level = '155' end --填max的时候，默认为155级
        while true do
            if 傀影肉鸽完成 then
                break
            end
            local status, err = pcall(path.前瞻投资)
            if not status then
                log("傀影肉鸽任务出错", err)
            end
        end
    end

    if zl_mizuki then
        log("水月任务开始")
        --   zl.放弃未结束的肉鸽探索()
        水月肉鸽完成 = false
        zl_level_enough = false
        zl_skip_coin = zl_skip_coin_mizuki
        zl_only_coin = zl_only_coin_mizuki
        zl_need_goods = zl_need_goods_mizuki
        zl_max_level = zl_max_level_mizuki
        zl_max_coin = zl_max_coin_mizuki
        if zl_max_level_sy == 'max' then zl_max_level = '170' end --填max的时候，默认为170级
        while true do
            if 水月肉鸽完成 then
                break
            end
            local status, err = pcall(path.水月与深蓝之树前瞻投资)
            if not status then
                log("水月肉鸽任务出错", err)
            end
        end
    end

    if zl_sami then
        log("萨米")
        --   zl.放弃未结束的肉鸽探索()
        萨米肉鸽完成 = false
        zl_skip_coin = zl_skip_coin_sami
        zl_only_coin = zl_only_coin_sami
        zl_need_goods = zl_need_goods_sami
        zl_max_level = zl_max_level_sami
        zl_max_coin = zl_max_coin_sami
        if zl_max_level_sami == 'max' then zl_max_level = '155' end --填max的时候，默认为155级
        while true do
            if 萨米肉鸽完成 then
                break
            end
            local status, err = pcall(path.探索者的银淞止境前瞻投资)
            if not status then
                log("萨米肉鸽任务出错", err)
            end
        end
    end

    if zl_skz then
        log("萨卡兹")
        --   zl.放弃未结束的肉鸽探索()
        萨卡兹肉鸽完成 = false
        zl_level_enough = false
        zl_skip_coin = zl_skip_coin_skz
        zl_only_coin = zl_only_coin_skz
        zl_need_goods = zl_need_goods_skz
        zl_max_level = zl_max_level_skz
        zl_max_coin = zl_max_coin_skz
        while true do
            if 萨卡兹肉鸽完成 then
                break
            end
            local status, err = pcall(path.萨卡兹的无终奇语前瞻投资)
            if not status then
                log("萨卡兹肉鸽任务出错", err)
            end
        end
    end

    if zl_jy then
        log("界园")
        界园肉鸽完成 = false
        zl_level_enough = false
        zl_skip_coin = zl_skip_coin_jy
        zl_only_coin = zl_only_coin_jy
        zl_need_goods = zl_need_goods_jy
        zl_max_level = zl_max_level_jy
        zl_max_coin = zl_max_coin_jy
        while true do
            if 界园肉鸽完成 then
                break
            end
            local status, err = pcall(path.界园前瞻投资)
            if not status then
                log("界园肉鸽任务出错", err)
            end
        end
    end

    if zl_hlsh then
        log("黑流树海")
        黑流树海完成 = false
        zl_level_enough = false
        zl_skip_coin = zl_skip_coin_hlsh
        zl_only_coin = zl_only_coin_hlsh
        zl_need_goods = zl_need_goods_hlsh
        zl_max_level = zl_max_level_hlsh
        zl_max_coin = zl_max_coin_hlsh
        while true do
            if 黑流树海完成 then
                break
            end
            local status, err = pcall(path.黑流树海)
            if not status then
                log("黑流树海肉鸽任务出错", err)
            end
        end
    end

    stop("肉鸽结束", '', true, true) --打不完不关闭游戏，有时候需要再检测一下的
end

path.公开招募加急 = function()
    -- 只处理第一个列表
    recruit_accelerate_mode = true
    point.公开招募列表 = table.slice(point.公开招募列表, 1, 1)
    forever(path.公开招募)
end

path.跳过剧情 = function()
    tap("战略确认")
    ssleep(2)
    back()
    ssleep(2)
    local txt = nil
    if not wait(function()
            txt = ocr("fullscreen")
            txt = table.findv(txt, function(x) return x.text:find('跳过剧情') end)
            if txt then return true end
        end, 5) then
        return back()
    end
    tap({ txt.r, txt.b })
end

path.生息演算任务 = function()
    if sx_szyw then
        if sand_mode == 3 then
            Tales_within_the_sand.六天奇遇循环()
            Tales_within_the_sand.下一天()
            Tales_within_the_sand.下一天()
            Tales_within_the_sand.下一天()
            Tales_within_the_sand.连续跳过()
            return
        elseif sand_mode == 4 then
            Tales_within_the_sand.连续跳过()
            return
        elseif sand_mode == 5 then
            Tales_within_the_sand.循环下一天()
            return
        end
        沙洲遗闻()
    end
    if sx_cqmd then
        重启锚点()
    end
end

path.生息演算商店 = function()
    if sx_szyw then
        Tales_within_the_sand.商店购买()
    end
    if sx_cqmd then
        Relaunch_anchor.商店购买()
    end
end

path.生息沙洲遗闻wrapper = function()
    path.跳转("首页")
    沙洲遗闻()
end

悖论模拟作业 = {
    ["维多利亚之矛"] = 36048,
    ["“将军风范”"] = 24999,
    ["洪流之中"] = 29753,
    ["锋芒如一"] = 24702,
    --["因地制宜"] = 34206,
    ["匿影藏形"] = 24368,
    ["队伍前列"] = 21432,
    ["告别软弱"] = 24632,
    ["别来拆家"] = 31694,
    ["迅捷之羽"] = 21245,
    ["目标在这儿呢！"] = 21441,
    ["小伙伴"] = 28036,
    ["生命是重量"] = 30764,
    ["共生共荣"] = 24570,
    ["互帮互助"] = 22765,
    ["“孤胆骑兵”"] = 30766,
    ["热情"] = 21476,
    ["侧翼援护"] = 21261,
    ["独行者的合谋"] = 21955,
    ["指挥天才"] = 21624,
    --["习惯成自然"] = 30587,
    ["荒野伏击"] = 36236,
    ["直线最短"] = 36237,
    --["书写悲痛"] = 23278,
    ["渗骨毒液"] = 32931,
    ["午后时光"] = 21280,
    --["火力网"] = 22727,
    ["狙击高地"] = 28977,
    ["箭指远方"] = 21442,
    ["模拟场景1122K"] = 21249,
    --["去往高处"] = 21956,
    ["防空炮手"] = 23250,
    ["拉特兰风格"] = 22676,
    ["无人机筛选"] = 22736,
    ["执行者的工作"] = 23890,
    ["控制距离"] = 22750,
    ["光源"] = 24709,
    ["万箭齐发"] = 31836,
    ["沉渊美梦"] = 24383,
    ["小憩"] = 30050,
    ["狩猎的节拍"] = 30968,
    ["战战兢兢"] = 21919,
    ["火矢天降"] = 26203,
    ["全面打击"] = 24381,
    ["射术传承"] = 24382,
    ["“不许靠近！”"] = 24380,
    ["打坏人的诀窍"] = 28648,
    ["不过是几只小虫子！"] = 32509,
    ["裂空之镞"] = 35616,
    ["收割"] = 29765,
    ["辗转反侧"] = 24526,
    ["互为后盾"] = 27395,
    ["戒骄戒躁"] = 20109,
    ["针对性合作"] = 22742,
    ["一个人的包围圈"] = 22501,
    ["群山相伴"] = 30711,
    ["“故地重游”"] = 27613,
    ["生还者"] = 24617,
    ["群星闪烁相映"] = 24842,
    ["光影谜面"] = 30624,
    ["勇往直前"] = 32940,
    --["钥与匙的守护者"] = 22521,
    ["声威在前"] = 23892,
    ["焮天铄地"] = 22866,
    ["机械援助"] = 24386,
    ["沉重舞步"] = 30713,
    ["童话愿望"] = 31212,
    ["电力充沛"] = 28502,
    ["过来吧你！"] = 26920,
    ["解构阵域"] = 24385,
    ["双人快打"] = 21993,
    ["闪烁徘徊"] = 21484,
    ["预卜先知"] = 21291,
    ["喷射！"] = 30062,
    --["重塑绿野"] = 24080,
    ["别问了，快吃"] = 28932,
    ["准备就绪"] = 21364,
    ["进化的佯谬"] = 22523,
    ["生财有道"] = 24621,
    ["东奔西走"] = 21730,
    ["“险路伏击”"] = 33152,
    ["步步紧逼"] = 29784,
    ["看见她"] = 26191,
    ["上共舞"] = 22524,
    ["制敌伏兵"] = 26206,
    ["控局"] = 22737,
    ["业精于勤"] = 23911,
    ["死缠烂打"] = 29658,
    ["诛邪义举"] = 25021,
    ["拳风拂面"] = 24479,
    ["“见缝插针”"] = 32650,
    ["共谋"] = 24023,
    ["预备方案"] = 30511,
    ["高效除虫"] = 31203,
    ["最佳拍档"] = 31489,
    ["爆炸美学"] = 29863,
    ["处世之道"] = 21663,
    --["“亲身经历”"] = 24465,不支持
    --["俯瞰风雪"] = 30709,
    --["心态平和"] = 21246,
    ["幼小的恐惧"] = 23669,
    ["有无"] = 21443,
    ["超越重力"] = 28711,
    ["“雄辩是金”"] = 31215,
    ["取之不尽，用之不竭"] = 29912,
    ["直面"] = 26228,
    ["“三人的阵线”"] = 32658,
    ["飞行管制"] = 24391,
    ["本应如此"] = 23656,
    ["幽径"] = 22764,
    ["本应如此"] = 25389,
    ["战场绘图"] = 24390,
    ["紧急补妆！"] = 24393,
    ["御护"] = 24392,
    ["风雪将至"] = 22739,
    ["“持续关注”"] = 27484,
    ["风浪微光"] = 29988,
    ["冷静的支援者"] = 32495,
    ["同气连枝"] = 34946,
    ["量化治疗"] = 21411,
    ["急救"] = 34957,
    ["风浪微光"] = 23504,
    ["花香四溢"] = 22399,
    ["牢不可破的幻影"] = 22753,
    ["涤净"] = 28501,
    ["战力增强剂"] = 22301,
    ["全域救护"] = 26223,
    ["并蒂花"] = 29890,
    ["抚慰伤痛"] = 21917,
    ["“聚焦”"] = 28503,
    ["伞下荫蔽"] = 31386,
    ["明椒"] = 24389,
    ["良药苦口"] = 21290,
    ["坚如信念"] = 36258,
    ["号声响起"] = 28440,
    ["最速防线"] = 34787,
    ["关键球员"] = 24839,
    ["吸引火力"] = 26245,
    ["不能白挨打"] = 31731,
    ["陷阵之志"] = 27127,
    ["“除夕”"] = 22466,
    ["战场上的旋律"] = 30442,
    ["战场烹调师"] = 28624,
    ["都放下来！"] = 20276,
    ["主演之人"] = 30770,
    ["火神"] = 21287,
    ["攻守兼备"] = 22762,
    ["犹豫不决"] = 24378,
    ["“热烈欢迎”"] = 28065,
    ["不惧严寒"] = 28071,
    ["坚如信念"] = 36258,
    ["重重一击"] = 24395,
    ["密友战线"] = 24377,
    ["岿然不动"] = 22757,
    ["浑金一块"] = 21679,
    ["如雷坚守"] = 21334,
    ["细剑的重量"] = 35931,
    ["“百炼"] = 27410,
    ["“百炼”"] = 27410,
    ["“友情出演”"] = 32534,
    ["同舟共济"] = 32532,
    ["风中之羽"] = 29768,
    --["一夫当关"] = 29063,
    --["安全框架"] = 31270,
    ["搭把手"] = 21895,
    ["月夜魔王之剑"] = 24304,
    ["泡普卡"] = 24421,
    ["不动如山"] = 30434,
    ["出鞘"] = 42459,
    ["睥睨"] = 21248,
    ["纯粹的强大"] = 22430,
    ["伤痛坚守"] = 21247,
    ["魂骨尚存"] = 21867,
    ["永不后退"] = 22864,
    ["一击必胜"] = 34494,
    ["沙滩假期"] = 22525,
    ["吾往矣"] = 25236,
    ["如星闪耀"] = 24372,
    ["捍卫潮流"] = 24913,
    ["风追击"] = 32651,
    ["持节之刃"] = 25175,
    ["“铮铮铁骨”"] = 25176,
    ["抱剑独行"] = 24466,
    ["小队"] = 24370,
    ["因材施教"] = 24375,
    ["来路无归"] = 24376,
    ["危机现场"] = 24374,
    ["据守险地"] = 22763,
    ["锲而不舍"] = 37442, --灰喉
    ["头阵冲锋"] = 36707, --推进之王
    ["闪耀时刻"] = 41238, --澄闪
    ["独刃"] = 36697, --阿斯卡纶
    ["倒影"] = 36660, --归溟幽灵鲨
    ["钢铁酋长"] = 41331, --森蚺
    ["只此一人"] = 39756, --泥岩
    ["爆炸美学"] = 29863, --梅尔
    ["学者的实力"] = 41749, --纯烬艾雅法拉
    ["坚如磐石"] = 36713, --闪灵
    ["紧急救护"] = 21282, --蜜莓
    ["携盾机动"] = 41296, --涤火杰西卡
}

path.悖论模拟 = function()
    path.跳转("干员")
    appear("干员界面", 3)
    ssleep(.1)
    tap("干员界面") --干员排序方式
    disappear("干员界面", 1)
    if not wait(function()
            if findOne("干员悖论模拟降序") then return true end
            tap("干员悖论模拟降序")
            ssleep(.3)
        end, 2) then
        return
    end
    if not findOne("干员界面") then
        tap("普通作战编队自定义排序关闭")
        appear("干员界面", 2)
    end
    --测试用
    if bl_text then
        local status
        status = pcall(JsonDecode, bl_text)
        if status then
            悖论模拟作业 = JsonDecode(bl_text)
        end
    end
    local 跳转干员页面 = function()
        local y = findAny({ "主页" })
        ssleep(.2)
        tap("主页")
        if not y or disappear(y, .5) then
            ssleep(.2)
            -- 一直按直到出现新状态
            tap("主页列表干员")
            tap("主页列表干员")

            wait(function()
                if not findAny({ "返回", "返回2" }) or
                    findAny({ "主页", "返回确认", "返回确认2" }) then
                    return true
                end
                tap("主页列表干员")
            end, .5)
            ssleep(.5)
            return true
        end
    end
    local ocr校正 = function(t)
        local 替换 = {
            ["势"] = "芬",
        }
        if t == nil or #t == 0 then return "" end
        for i = 1, #t do
            local 原文本 = (t[i]["text"])
            --print(原文本)
            if 替换[原文本] then
                t[i]["text"] = 替换[原文本]
            end
            -- 去除开头的书名号
            t[i]["text"] = t[i]["text"]:gsub("^《", "")

            --开头和结尾的半角引号替换成全角
            t[i]["text"] = t[i]["text"]:gsub("^\"(.-)\"$", "“%1”")
            if string.match(t[i]["text"], "^“") then
                -- 如果字符串以双引号开头
                local rest = string.sub(t[i]["text"], 2) -- 获取去掉开头双引号的剩余部分
                if not string.match(rest, "”$") then
                    -- 如果剩余部分不以双引号结尾
                    t[i]["text"] = t[i]["text"] .. "”" -- 在结尾补全双引号
                end
            end
            --print(t[i]["text"])
        end

        return t
    end

    while true do
        -- 取前12个位置
        for i = 1, 12 do
            local bl = true
            while bl do
                if appear("干员悖论模拟列表" .. i, 1) then
                    tap("干员悖论模拟列表" .. i)
                else
                    toast("第" .. i .. "位置无悖论,跳过")
                    return true
                end
                if appear("悖论模拟界面", 7) then
                    ssleep(.2)
                    local ret = ocr校正(ocrex("悖论模拟关卡名范围"))
                    if ret then
                        stage_name = ret[1]["text"]
                        log("关卡ocr结果:", stage_name)
                    end
                    if 悖论模拟作业[stage_name] then
                        log(悖论模拟作业[stage_name])
                        auto_prts(悖论模拟作业[stage_name], true)
                        if not wait(function()
                                tap("悖论模拟失败")
                                if findOne("悖论模拟界面2") then
                                    log("悖论模拟成功")
                                    跳转干员页面()
                                    return true
                                end
                                if findOne("悖论模拟界面") then
                                    log.warn("悖论模拟失败")
                                    bl = false
                                    return true
                                end
                            end, 15) then
                            return
                        end
                    else
                        toast("第" .. i .. "位置未找到可用作业")
                        break
                    end
                else
                    log.warn("未进入悖论模拟界面")
                    break
                end
            end
            log("返回干员页")
            跳转干员页面()
        end
        log("下一页干员")
        swip_char() --滑动6个干员位置
    end
end

path.自动模组 = function()
    if not character_table then
        -- 解包干员数据
        character_table = JsonDecode(readFile("char_table.json"))
    end

    if not 干员职业 then
        干员职业 = JsonDecode(readFile("character_type_list.json"))
    end
    if not character_name2id then
        character_name2id = {}
        for k, v in pairs(character_table) do
            local name = v["name"]
            character_name2id[name] = k
        end
    end
    if mz_text == nil then return end
    local names = string.split(mz_text)
    for i, v in ipairs(names) do
        raise.auto_module(v)
    end
end

path.自动合成材料 = function()
    if not item_name2id then
        item_name2id = {}
        for k, v in pairs(高级材料2低级材料) do
            local name = v["name"]
            item_name2id[name] = tostring(k)
        end
    end
    raise.材料合成()
    tap("返回")
    exit()
end

path.自动合成模组材料 = function(target_level)
    local target_level = target_level or 3
    if not item_name2id then
        item_name2id = {}
        for k, v in pairs(高级材料2低级材料) do
            local name = v["name"]
            item_name2id[name] = tostring(k)
        end
    end
    for i = 0, 2 do
        local current_level = math.min(i, 1)
        log("当前模组等级" .. i)
        if i > 0 then
            tap("模组升级")
            appear("模组升级确认", 2)
        end
        if findOne("干员模组" .. current_level .. "级红") then
            log("合成", i + 1, "级模组缺少材料")
            tap("干员模组" .. current_level .. "级红材料")
            appearTap("干员模组" .. current_level .. "级红材料跳转")
            appear("加工站")
            raise.材料合成()
            tap("返回")
            appear("干员模组" .. current_level .. "级红材料跳转")
            ssleep(.2)
            tap("干员模组" .. current_level .. "级红材料")
            disappear("干员模组" .. current_level .. "级红材料跳转")
        end
        if not wait(function()
                if findOne("模组升级") then return true end
                tap("模组升级确认")
                ssleep(.3)
            end, 3.5) then
        end
        if target_level == i + 1 then exit() end
    end
    exit()
end

path.自动升级潜能 = function()
    path.跳转("干员")
    appear("干员界面", 3)
    ssleep(.1)
    local 红点干员数量 = tonumber(ocro("干员界面红点数字范围") or 0)
    toast("红点干员数量" .. 红点干员数量)
    tap("干员界面红点") --筛选干员
    disappear("干员界面红点", 1)

    if not wait(function()
            if findOne("干员档案") then return true end
            tap("第一个干员")
            ssleep(.3)
        end, 2) then
        return
    end
    ssleep(.5)

    auto_upgrade_potentiality = function()
        if appear("干员潜能升级红点", 1) then
            if not wait(function()
                    if findOne("干员潜能界面") then return true end
                    tap("干员潜能升级红点")
                    ssleep(.3)
                end, 2) then
                return
            end
            if not wait(function()
                    if findOne("干员潜能升级确定") then tap("干员潜能升级确定") end
                    if findOne("干员档案") then return true end
                    tap("干员潜能界面")
                    ssleep(.3)
                end, 10) then
                if not wait(function()
                        if findOne("干员潜能升级确定") then tap("干员潜能升级取消") end
                        if findOne("干员档案") then return true end
                        tap("返回")
                        ssleep(.5)
                    end, 5) then
                    return
                end
                return
            end
        else
            return
        end
    end

    for i = 1, 红点干员数量 do
        toast("还剩 " .. (红点干员数量 - i + 1) .. " 个干员")
        auto_upgrade_potentiality()
        gesture({
            {
                point = { { scale(1103), scale(870) }, { scale(817), scale(870) } },
                start = 0,
                duration = 300,
            },
        })
        ssleep(1)
    end
end

path.隐秘战线 = function()
    local a1 = { 20, 20, 20 }
    local a2 = { 60, 55, 45 }
    local b2 = { 45, 60, 65 }
    local a3 = { 200, 155, 155 }
    local b3 = { 150, 220, 150 }
    local c3 = { 155, 180, 240 }
    local 结局A = { 510, 350, 350 }
    local 结局B = { 440, 440, 350 }
    local 结局C = { 350, 550, 350 }
    local 结局D = { 365, 475, 495 }
    local 结局E = { 370, 385, 620 }
    local 路径 = { { { "物资小队", a1, a2, a3, 结局A }, { "物资小队", "中", "左", "左", "左" } },
        { { "物资小队", a1, a2, a3, 结局B }, { "物资小队", "中", "左", "左", "中" } },
        { { "情报小队", a1, a2, b3, 结局C }, { "情报小队", "中", "左", "右", "中" } },
        { { "医疗小队", a1, b2, c3, 结局D }, { "医疗小队", "中", "右", "右", "中" } },
        { { "医疗小队", a1, b2, c3, 结局E }, { "医疗小队", "中", "右", "右", "右" } },
        { { "物资小队", a1, a2, a3, 结局A }, { "物资小队", "中", "左", "左", "左" } }, }
    local 检测点步数 = { 5, 10, 18, 26 }

    local 检测选项 = function(阶段, 结局, step)
        local 选项 = { { {}, {}, {} }, { {}, {}, {} }, { {}, {}, {} } }
        for i = 1, 3 do
            local 顺序 = { "左", "中", "右" }
            local name = ocro("隐秘战线选项名称")
            if findOne("隐秘战线双选项") then
                for j = 1, 2 do
                    local 物资 = ocro("隐秘战线双选项" .. 顺序[j] .. "物资")
                    if 物资 then
                        选项[i][j]["物资"] = tonumber(物资)
                        选项[i][j]["情报"] = tonumber(ocro("隐秘战线双选项" .. 顺序[j] .. "情报"))
                        选项[i][j]["医疗"] = tonumber(ocro("隐秘战线双选项" .. 顺序[j] .. "医疗"))

                        local 成功率范围 = "隐秘战线双选项" .. 顺序[j] .. "成功率"
                        选项[i][j]["坐标"] = { point[成功率范围][1], point[成功率范围][2] }
                        local ret = ocro(成功率范围)
                        if ret then
                            选项[i][j]["成功率"] = ((tonumber(ret:sub(1, -2)) - 30) / 70) *
                                math.abs((tonumber(ret:sub(1, -2)) - 30) / 70)
                        else
                            c = getPixelColor(选项[i][j]["坐标"][1], 选项[i][j]["坐标"][2])
                            log(c)
                        end
                        if 结局 > 5 and name:includes({ "平台" }) then
                            选项[i][j]["物资"] = 选项[i][j]["物资"] + 7
                            选项[i][j]["情报"] = 选项[i][j]["情报"] + 7
                            选项[i][j]["医疗"] = 选项[i][j]["医疗"] + 7
                        end
                        if 结局 == 4 then
                            if name:includes({ "游侠" }) then
                                选项[i][j]["物资"] = 选项[i][j]["物资"] + 4 * 阶段
                                选项[i][j]["情报"] = 选项[i][j]["情报"] + 4 * 阶段
                                选项[i][j]["医疗"] = 选项[i][j]["医疗"] + 4 * 阶段
                            elseif name:includes({ "影迷" }) then
                                选项[i][j]["物资"] = 选项[i][j]["物资"] + 5 * 阶段
                                选项[i][j]["情报"] = 选项[i][j]["情报"] + 5 * 阶段
                                选项[i][j]["医疗"] = 选项[i][j]["医疗"] + 5 * 阶段
                            end
                        end
                        if 结局 == 5 and name:includes({ "影迷" }) then
                            选项[i][j]["成功率"] = 选项[i][j]["成功率"] + 0.4
                            选项[i][j]["物资"] = 选项[i][j]["物资"] + 6 * 阶段
                            选项[i][j]["情报"] = 选项[i][j]["情报"] + 6 * 阶段
                            选项[i][j]["医疗"] = 选项[i][j]["医疗"] + 6 * 阶段
                        end
                        选项[i][j]["绝对值总和"] = 选项[i][j]["物资"] + 选项[i][j]["情报"] + 选项[i][j]["医疗"]
                        选项[i][j]["加权总和"] = 选项[i][j]["物资"] * 物资权重 + 选项[i][j]["情报"] * 情报权重 + 选项[i][j]["医疗"] * 医疗权重
                    end
                end
            else
                for j = 1, 3 do
                    local 物资 = ocro("隐秘战线" .. 顺序[j] .. "物资")
                    if 物资 then
                        选项[i][j]["物资"] = tonumber(物资)
                        选项[i][j]["情报"] = tonumber(ocro("隐秘战线" .. 顺序[j] .. "情报"))
                        选项[i][j]["医疗"] = tonumber(ocro("隐秘战线" .. 顺序[j] .. "医疗"))

                        local 成功率范围 = "隐秘战线" .. 顺序[j] .. "成功率"
                        选项[i][j]["坐标"] = { point[成功率范围][1], point[成功率范围][2] }
                        local ret = ocro(成功率范围)
                        if ret then
                            选项[i][j]["成功率"] = ((tonumber(ret:sub(1, -2)) - 30) / 70) *
                                math.abs((tonumber(ret:sub(1, -2)) - 30) / 70)
                        else
                            c = getPixelColor(选项[i][j]["坐标"][1], 选项[i][j]["坐标"][2])
                            log(c)
                        end
                        --所有结局完成后加权在完成一次平台系列任务
                        if 结局 > 5 and name:includes({ "平台" }) and step > 2 then
                            选项[i][j]["物资"] = 选项[i][j]["物资"] + 8
                            选项[i][j]["情报"] = 选项[i][j]["情报"] + 8
                            选项[i][j]["医疗"] = 选项[i][j]["医疗"] + 8
                        end
                        if 结局 == 4 and name:includes({ "游侠" }) then
                            选项[i][j]["物资"] = 选项[i][j]["物资"] + 6 * 阶段
                            选项[i][j]["情报"] = 选项[i][j]["情报"] + 6 * 阶段
                            选项[i][j]["医疗"] = 选项[i][j]["医疗"] + 6 * 阶段
                        end
                        if 结局 == 5 and name:includes({ "影迷" }) then
                            选项[i][j]["成功率"] = 选项[i][j]["成功率"] + 0.45
                            选项[i][j]["物资"] = 选项[i][j]["物资"] + 6 * 阶段
                            选项[i][j]["情报"] = 选项[i][j]["情报"] + 6 * 阶段
                            选项[i][j]["医疗"] = 选项[i][j]["医疗"] + 6 * 阶段
                        end
                        选项[i][j]["绝对值总和"] = 选项[i][j]["物资"] + 选项[i][j]["情报"] + 选项[i][j]["医疗"]
                        选项[i][j]["加权总和"] = 选项[i][j]["物资"] * 物资权重 + 选项[i][j]["情报"] * 情报权重 + 选项[i][j]["医疗"] * 医疗权重
                    end
                end
            end

            if i < 3 then
                tap("隐秘战线右翻页")
                ssleep(1.8) --展开动画
            end
        end
        log(选项)
        return 选项
    end
    local 比较选项 = function(所有选项, 阶段, step)
        local 最优选项
        for i = 1, 3 do
            for j = 1, 3 do
                local 当前选项 = 所有选项[i][j]
                if not table.isempty(当前选项) then
                    log(当前选项)
                    if not 最优选项 then
                        最优选项 = { i, 当前选项 }
                    elseif 物资权重 + 情报权重 + 医疗权重 == 0 then
                        --达到检测点要求,选择增长率最高的
                        if 阶段 < 3 then
                            if 当前选项["绝对值总和"] > 最优选项[2]["绝对值总和"] and 当前选项["成功率"] > 0.3 then 最优选项 = { i, 当前选项 } end
                        else
                            --if 结局=5 and 所有选项[i]["name"]:include({"影迷"}) then
                            if 当前选项["绝对值总和"] * 当前选项["成功率"] > 最优选项[2]["绝对值总和"] * 最优选项[2]["成功率"] then
                                最优选项 = { i, 当前选项 }
                            end
                        end
                    else
                        --未达到检测点要求,选择权重最高的
                        if 阶段 < 3 then
                            if 当前选项["加权总和"] > 最优选项[2]["加权总和"] and 当前选项["成功率"] > 0.3 then 最优选项 = { i, 当前选项 } end
                        else
                            if 当前选项["加权总和"] * 当前选项["成功率"] > 最优选项[2]["加权总和"] * 最优选项[2]["成功率"] then
                                最优选项 = { i, 当前选项 }
                            end
                        end
                    end
                end
            end
        end
        log("最优选项", 最优选项)
        return 最优选项
    end
    结局 = str2int(hidden_front_ending, 1)
    hidden_front_navigation()
    ::重新开始::
    local step = 0
    --选择结局
    local 路线 = 路径[结局][1]
    local 路线点 = 路径[结局][2]
    local 阶段 = 1

    appear("隐秘战线小队选择", 3)
    tap("隐秘战线" .. 路线[1])
    appearTap("隐秘战线确认出发")
    ssleep(5)
    while step <= 检测点步数[阶段] do
        if appear("隐秘战线继续前进", 3) then
            ssleep(.2)
            local ret = ocro("隐秘战线继续前进范围")
            if ret == "继续前进" then
                tap("隐秘战线继续前进")
                ssleep(.5)
                appear("隐秘战线返回", 3)
                ssleep(.6)
                tap("隐秘战线事件")
                ssleep(1.8)
                local 现有物资, 现有情报, 现有医疗, 物资权重，情报权重，医疗权重

                现有物资 = ocro("隐秘战线现有物资")
                现有情报 = ocro("隐秘战线现有情报")
                现有医疗 = ocro("隐秘战线现有医疗")
                log("现有:", 现有物资, 现有情报, 现有医疗)

                物资权重 = math.max(0, (路线[阶段 + 1][1] - 现有物资) / (检测点步数[阶段] - step))
                情报权重 = math.max(0, (路线[阶段 + 1][2] - 现有情报) / (检测点步数[阶段] - step))
                医疗权重 = math.max(0, (路线[阶段 + 1][3] - 现有医疗) / (检测点步数[阶段] - step))

                log("权重:", 物资权重, 情报权重, 医疗权重)
                local 选项 = 检测选项(阶段, 结局, step)
                local 最优选项 = 比较选项(选项, 阶段, step)
                if 最优选项[1] == 1 then
                    tap("隐秘战线右翻页")
                    ssleep(1.5) --展开动画
                elseif 最优选项[1] == 2 then
                    tap("隐秘战线左翻页")
                    ssleep(1.5) --展开动画
                end
                tap(最优选项[2]["坐标"])
                ssleep(.5) --展开动画
                tap(最优选项[2]["坐标"])
                if not wait(function()
                        if findOne("隐秘战线继续") then
                            tap("隐秘战线继续")
                            step = step + 1
                            ssleep(.5)
                            return true
                        end
                        ssleep(.5)
                    end, 10) then
                    return
                end
            elseif ret == "应对危机事件" then
                阶段 = 阶段 + 1
                if 阶段 > 2 and 结局 > 5 then
                    结局 = 结局 + 1
                    break
                end
                tap("隐秘战线继续前进")
                ssleep(.5)
                appear("隐秘战线返回", 3)
                if not wait(function()
                        if findOne("隐秘战线通过检测点") then
                            tap("隐秘战线通过检测点")
                            ssleep(.5)
                        end
                        if findOne("隐秘战线继续前进") then return true end
                        if findOne("隐秘战线小队选择") then return true end
                        tap("隐秘战线" .. 路线点[阶段])
                        ssleep(.5)
                    end, 10) then
                    return
                end
                if findOne("隐秘战线小队选择") then
                    log("通过结局" .. 结局)
                    结局 = 结局 + 1
                    break
                end
                tap("隐秘战线" .. 路线点[阶段])
                ssleep(.5)
            end
        end
        if findOne("隐秘战线红应对") then
            tap("隐秘战线红应对")
            if not wait(function()
                    if findOne("隐秘战线小队选择") then return true end
                    tap("隐秘战线中")
                    ssleep(.5)
                end, 10) then
                return
            end
            break
        end
    end

    if 结局 <= 6 then
        goto 重新开始
    end
    -- 领取任务
    if findOne("隐秘战线任务") and hidden_front_award then
        tap("隐秘战线任务")
        ssleep(.1)
        if appear("隐秘战线一键领取", 2) then
            ssleep(.2)
            tap("隐秘战线一键领取")
            wait(function()
                tap("隐秘战线空白")
                ssleep(.2)
                if findOne("隐秘战线小队选择") then return true end
            end, 5)
        end
    end
    --退出隐秘战线
    if not wait(function()
            tap("隐秘战线暂时离开")
            ssleep(.2)
            tap("隐秘战线重新开始确认")
            ssleep(.2)
            if findOne("主页") then
                path.跳转("首页")
                return true
            end
        end, 8) then
        return
    end
end

path.森空岛签到 = function()
    if username ~= nil and password ~= nil then
        if isPhoneNumber(username) then
            skland_daily_checkin(username, password)
        else
            log.warn("不符合签到条件跳过")
            table.insert(qqmessage, "不符合签到条件跳过")
        end
        return true
    elseif root_mode then
        log("root模式从本地获取token")
        skland_daily_checkin("local", "local")
    end
end

path.自动培养 = function()
    if not enable_raise_func then return end
    local status, data = pcall(raise.auto_raise)
    log(data)
end

path.宝石铭刻活动 = function()
    第九关打完了 = false
    while 第九关打完了 == false do
        path.宝石铭刻寻找课程()
    end
end

path.宝石铭刻寻找课程 = function()
    log('宝石铭刻 start')

    if findOne('宝石铭刻_结束课程') then
        log('宝石铭刻_结束课程')
        findTap('宝石铭刻_结束课程')
        appear('宝石铭刻_本轮成绩', 5)
    end
    if findOne('宝石铭刻_本轮成绩') then
        log('结算课程')
        --findTap('宝石铭刻_结束课程')
        wait(function()
            tap('宝石铭刻_结束特殊点')
            if findOne('宝石铭刻_开始上课') then return true end
        end, 10, .2)
    end
    if findOne('宝石铭刻_离开课程') then
        toast('宝石铭刻_离开课程')
        tap('宝石铭刻_离开课程')
        appear('宝石铭刻_下课1')
        return
    end

    path.跳转('首页')

    tap(hd_position)
    if not wait(function()
            if findOne("活动导航0") or findOne("活动商店导航") then return true end
            if findOne("跳过剧情") and not findAny({ "活动导航0", "活动商店导航" }) then path.跳过剧情() end
            if findOne("教程关闭") then tap("教程关闭") end
        end, 15) then
        return
    end

    log('3064')

    if 第九关打完了 then
        log('全打完了，准备领取奖励')
        wait(function()
            tap('宝石铭刻_结业奖励入口')
            if not findOne("活动导航0") then return true end
        end, 10)
        appear('宝石铭刻_结业奖励全部领取', 5)
        wait(function()
            tap('宝石铭刻_结业奖励全部领取')
        end, 3, .1)
        return
    end
    --准备进入【宝石铭刻】
    if not wait(function()
            tap('宝石铭刻入口')
            if not findOne("活动导航0") then return true end
        end, 10) then
        return
    end

    --点击进入宝石铭刻之后会有新手教程和一些教程提示，需要点击关闭
    local jump = false
    if not wait(function()
            tap('招募说明关闭')
            if findOne("宝石铭刻_主界面") then return true end
            if findOne('宝石铭刻_下课1') then
                tap('宝石铭刻_下课1')
                jump = true
                return true
            end
        end, 10) then
        return
    end

    --如果进来了，发现前面的课程还未结算，在上课中，先放弃本轮
    if jump then
        wait(function()
            tap('宝石铭刻_下课2')
            if findOne("宝石铭刻_本轮成绩") then return true end
        end, 10, .1)
        return
    end

    --返回到第一个课程，后续可以简单记录当前是第几个课程
    toast('回到第一个课程')
    if not wait(function()
            tap('宝石铭刻_上一个课程')
            if findOne('宝石铭刻_第一个课程') then return true end
        end, 10) then
        return
    end
    toast('寻找未结课的课程')

    local 当前课程序号 = 0 --记录当前属于第几个课程

    --寻找未结课的课程
    for i = 2, #point['宝石铭刻课程序号列表'] do
        local color = '宝石铭刻课程序号列表' .. i
        if findOne("宝石铭刻_已结课") then
            log('该课程【已结课】')
            tap('宝石铭刻_下一个课程')
            appear(color, 2)
            -- ssleep(2) --可以用其他方法判断是否到了下一个课程，这里简单用延迟
        end
        if findOne('宝石铭刻_开始上课') and not findOne("宝石铭刻_已结课") then
            log('该课程【未结课】,准备上课')
            if findOne("宝石铭刻课程序号列表1") then
                当前课程序号 = 1
            else
                当前课程序号 = i
            end

            break
        end
        if i == 9 and findOne("宝石铭刻_已结课") then --有时候第九关打完了，还在无限循环
            第九关打完了 = true
            return true
        end
        ssleep(.8) --翻页有动画需要加载，卡的话多给一点
    end

    log('准备【开始上课】 第' .. 当前课程序号 .. '课')

    --第一课的情况
    if 当前课程序号 == 1 then
        return path.宝石铭刻第1课教程()
    elseif 当前课程序号 <= 5 then
        return path.宝石铭刻第2345课教程(当前课程序号)
    elseif 当前课程序号 <= 8 then
        return path.宝石铭刻第678课教程(当前课程序号)
    elseif 当前课程序号 == 9 then
        return path.宝石铭刻第9课教程()
    end
end

path.宝石铭刻第1课教程 = function()
    local 手牌数量 = 0 --记录当前手牌数量
    log('宝石铭刻第一课教程')
    if not wait(function()
            tap('宝石铭刻_开始上课')
            tap('宝石铭刻_开始课程')
            if findOne("宝石铭刻_购买工艺界面") then return true end
        end, 10) then
        return
    end
    wait(function()
        log('第一课教程')
        if findOne('宝石铭刻_莎草教程界面下') then
            tap('开包skip')
            tap('宝石铭刻_新增工作台')
            tap('宝石铭刻_购买工艺')
        end
        if findOne('宝石铭刻_莎草教程界面上') then
            tap('宝石铭刻_购买工艺')
            tap('宝石铭刻_开始铭刻')
        end
        if findOne('宝石铭刻_购买工艺界面') then
            if not wait(function()
                    if not findOne('宝石铭刻_工艺购买') then return true end
                    for i = 1, 2 do
                        tap('宝石铭刻_工艺购买' .. i)
                        if appearTap('宝石铭刻_购买工艺', 1) then
                            手牌数量 = 手牌数量 + 1
                            ssleep(1)
                        end
                    end
                end, 5) then
                return
            end
            --购买完之后  准备进入【开始铭刻】界面
            if not wait(function()
                    tap('宝石铭刻_下一个课程')
                    if findOne('宝石铭刻_铭刻界面') then return true end
                end, 5) then
                return
            end
        end
        if findOne('宝石铭刻_开始铭刻') then
            宝石铭刻.摆放手牌到工作台()
        end
        if findAny({ '宝石铭刻_本轮成绩', '宝石铭刻_结束课程' }) then return true end
        if findOne('宝石铭刻_目标达成一轮结算') then
            tap('宝石铭刻_铭刻完下一轮')
            ssleep(2)
        end
    end, 120, .1)
end
path.宝石铭刻摆放手牌 = function(工艺底座数量, 识别不占用底座, 当前课程序号)
    appear('宝石铭刻_铭刻界面')
    ssleep(.5)
    local x, y = scale(55), -1
    local 手牌变化量 = 0
    local 宝石铭刻_放牌延迟 = str2int(宝石铭刻_放牌延迟)
    log('宝石铭刻_放牌延迟', 宝石铭刻_放牌延迟)
    for i = 1, 工艺底座数量 do
        -- 左起第一张牌
        ::查找::
        x, y = findMultiColor(x, scale(956), scale(1900), scale(957),
            "565656", scale(7) .. "|0|191515", 0, 0.9)
        log(x, y)
        if y ~= -1 then
            tap({ x + scale(30), y })
            ssleep(.1)
            if 识别不占用底座 then
                ssleep(.6)
                local text = ocr("宝石铭刻_工艺说明")
                text = table.findv(text, function(x) return x.text:find('工艺区') end)
                if text then
                    x = x + scale(150)
                    goto 查找
                else
                    识别不占用底座 = false
                end
            end
            tap("宝石铭刻_工作台列表" .. i)
            if 当前课程序号 >= 7 then
                手牌变化量 = 手牌变化量 - 1
            end
            sleep(宝石铭刻_放牌延迟)
        else
            break
        end
    end
    wait(function()
        tap('宝石铭刻_开始铭刻')
        if not findOne("宝石铭刻_开始铭刻") then return true end
    end, 10)
    return 手牌变化量
end
path.宝石铭刻第2345课教程 = function(当前课程序号)
    local 手牌数量 = 0 --记录当前手牌数量
    local 工艺底座数量 = 2 --记录底座的数量
    local 当前轮数 = 1 --记录当前第几轮
    log('宝石铭刻第2345课教程')
    if not wait(function()
            tap('宝石铭刻_开始上课')
            tap('宝石铭刻_开始课程')
            if findOne("宝石铭刻_购买工艺界面") then return true end
        end, 10) then
        return
    end

    local 宝石工艺可升级判断并购买 = function()
        ssleep(1)
        if not findOne('宝石铭刻_工艺购买') then return false end
        if not findOne('宝石铭刻_工艺可升级') then
            log('没有可升级的工艺')
            return false
        end
        log('购买工艺升级')

        if not wait(function()
                if not findOne('宝石铭刻_工艺可升级') then return true end
                for i = 1, 3 do
                    if findOne('宝石铭刻_工艺可升级' .. i) then
                        tap('宝石铭刻_工艺可升级' .. i)
                        if appearTap('宝石铭刻_购买工艺', 1) then ssleep(1) end
                    end
                end
            end, 10) then
            return false
        end
        return true
    end
    local 判断是否有0刷新 = function()
        if not findOne('宝石铭刻_0刷新') then return end
        tap('宝石铭刻_0刷新')
        ssleep(2)
        return true
    end
    local 手牌数量再购买一张 = function()
        --下面是跳过购买新卡的特殊情况
        if 当前课程序号 == 4 and (当前轮数 == 3 or 当前轮数 == 4) then
            log('特殊情况跳过购买')
            return
        end

        local p = appear(point["宝石铭刻_优先购买的工艺列表"], 1)
        p = findAny(point["宝石铭刻_优先购买的工艺列表"])
        if not p then
            --随机买一张
            log('随机买一张')
            for i = 1, 3 do
                tap('宝石铭刻_工艺购买' .. i)
                if appearTap('宝石铭刻_购买工艺', 1) then
                    手牌数量 = 手牌数量 + 1
                    return true
                end
            end
        else
            --购买指定的某些
            log('p：', p)
            if not wait(function()
                    local x, y = point[p]:match("(%d+)" .. coord_delimeter .. "(%d+)")
                    tap({ tonumber(x), tonumber(y) })
                    if appearTap('宝石铭刻_购买工艺', 1) then
                        手牌数量 = 手牌数量 + 1
                        ssleep(1)
                        return true
                    end
                    if disappear(p, 1) then return true end
                end) then
                return
            end
        end
    end
    local 增加操作台购买判断 = function()
        if not findOne('宝石铭刻_新增工作台') then return false end
        log('判断工作台是否可以购买')
        tap('宝石铭刻_新增工作台')
        if appearTap('宝石铭刻_购买工艺') then
            工艺底座数量 = 工艺底座数量 + 1
            --如果购买成功，则随机再买一张卡
            ssleep(1)
            手牌数量再购买一张()
            return true
        end
    end

    log('第一轮  购买两个工艺，不用判断')
    appear('宝石铭刻_工艺购买', 5)
    if not wait(function()
            if not findOne('宝石铭刻_工艺购买') then return true end
            for i = 1, 2 do
                tap('宝石铭刻_工艺购买' .. i)
                if appearTap('宝石铭刻_购买工艺', 1) then
                    手牌数量 = 手牌数量 + 1
                    ssleep(1)
                end
                if i == 2 then return true end
            end
        end, 15) then
        return
    end

    while true do
        log('工艺底座数量:', 工艺底座数量, ' 手牌数量:', 手牌数量, '当前轮数 :', 当前轮数)

        --购买完之后  准备进入【开始铭刻】界面
        if not wait(function()
                tap('宝石铭刻_下一个课程')
                if findOne('宝石铭刻_铭刻界面') then return true end
            end, 15) then
            return
        end

        log('开始铭刻', 工艺底座数量)
        path.宝石铭刻摆放手牌(工艺底座数量, false, 当前课程序号)

        --【开始铭刻】之后，准备进入下一轮的购买的界面
        log('准备下一轮')
        local jump = false
        if not wait(function()
                if findOne('宝石铭刻_铭刻完下一轮') then return true end
                if findOne('宝石铭刻_结束课程') then
                    jump = true
                    return true
                end
            end, 10, .2) then
            return
        end

        if jump then break end --遇到课程完事了情况 跳出
        log.debug()
        if not wait(function()
                tap('宝石铭刻_铭刻完下一轮')
                if not findOne('宝石铭刻_铭刻完下一轮') then return true end
            end, 10, .2) then
            return
        end
        log.debug()
        if not appear('宝石铭刻_购买工艺界面') then return end
        if not wait(function()
                if findOne('宝石铭刻_工艺购买') and findOne('宝石铭刻_购买工艺界面') then return true end
            end, 10, .2) then
            return
        end
        log.debug()
        当前轮数 = 当前轮数 + 1
        --优先级为  升级> 0刷新 > 购买底座
        --目前是在下一轮界面内
        log('工艺底座数量:', 工艺底座数量, ' 手牌数量:', 手牌数量, '当前轮数 :', 当前轮数)
        宝石工艺可升级判断并购买()

        if 判断是否有0刷新() then 宝石工艺可升级判断并购买() end

        增加操作台购买判断()
        if 工艺底座数量 > 手牌数量 then
            手牌数量再购买一张()
        end
        宝石工艺可升级判断并购买() --有时候买完新卡，会有可以升级工艺的情况在

        --特殊关卡在额外买一张
        if 当前课程序号 == 2 and 当前轮数 == 3 then
            log('第二课 第三轮再买一张')
            手牌数量再购买一张()
        end
    end
    log('宝石铭刻 end')
end
path.宝石铭刻第678课教程 = function(当前课程序号)
    local 手牌数量 = 0 --记录当前手牌数量
    local 工艺底座数量 = 2 --记录底座的数量
    local 当前轮数 = 1 --记录当前第几轮
    手牌 = {
        红 = 0,
        黄 = 0,
        青1 = 0,
        青2 = 0,
        青3 = 0,
        紫 = 0
    }

    local 宝石铭刻购买 = function()
        local 商店列表 = {}
        local 免费刷新 = false
        local 购买次数 = 0
        local 购买一次 = function(商品, 刷新前)
            log("购买一次")
            --先买升级
            local 购买 = function(i, 不增加手牌)
                tap("宝石铭刻_工艺购买" .. i)
                ssleep(.1)
                tap("宝石铭刻_购买工艺")
                ssleep(.3)
                disappear("正在提交反馈至神经", network_timeout)
                if not 不增加手牌 then
                    手牌数量 = 手牌数量 + 1
                end
                商品 = path.宝石铭刻识别()
                购买次数 = 购买次数 + 1
            end
            for i = 1, 3 do
                if 商品[i][2] == 1 and 商品[i][1] ~= "青1" then
                    if findOne("宝石铭刻_钱不足" .. i) then
                        return
                    end
                    购买(i, true)
                end
            end
            if 当前课程序号 >= 7 then
                for i = 1, 3 do
                    if 商品[i][2] == 0 and 商品[i][1] == "红" then
                        if findOne("宝石铭刻_钱不足" .. i) then
                            return
                        end
                        购买(i)
                        手牌["红"] = 手牌["红"] + 1
                    end
                    if 商品[i][2] == 1 and 商品[i][1] == "红" then
                        if findOne("宝石铭刻_钱不足" .. i) then
                            return
                        end
                        购买(i, true)
                        手牌["红"] = 手牌["红"] + 1
                    end
                end
            end
            for i = 1, 3 do
                if 商品[i][1] == "黄" then
                    if findOne("宝石铭刻_钱不足" .. i) then
                        return
                    end
                    购买(i)
                    手牌["黄"] = 手牌["黄"] + 1
                end
            end
            if 当前课程序号 < 8 then
                for i = 1, 3 do
                    if 商品[i][2] == 0 and 商品[i][1] == "青1" then
                        if 手牌数量 >= 工艺底座数量 + 1 or findOne("宝石铭刻_钱不足" .. i) then
                            return
                        end
                        购买(i)
                        手牌["青1"] = 手牌["青1"] + 1
                        break
                    end
                end
                if 手牌["青1"] > 0 or not 刷新前 then
                    for i = 1, 3 do
                        if 商品[i][2] == 0 and 商品[i][1] == "青2" then
                            if 手牌数量 >= 工艺底座数量 + 1 or findOne("宝石铭刻_钱不足" .. i) then
                                return
                            end
                            购买(i)
                            手牌["青2"] = 手牌["青2"] + 1
                            break
                        end
                    end
                end
                if 手牌["青2"] > 0 then
                    for i = 1, 3 do
                        if 商品[i][2] == 0 and 商品[i][1] == "青3" then
                            if 手牌数量 >= 工艺底座数量 + 1 or findOne("宝石铭刻_钱不足" .. i) then
                                return
                            end
                            购买(i)
                            手牌["青3"] = 手牌["青3"] + 1
                            break
                        end
                    end
                end
            end
            if 手牌["红"] > 0 or not 刷新前 then
                for i = 1, 3 do
                    if 商品[i][2] == 0 and 商品[i][1] == "红" then
                        if 手牌数量 >= 工艺底座数量 or findOne("宝石铭刻_钱不足" .. i) then
                            return
                        end
                        购买(i)
                        手牌["红"] = 手牌["红"] + 1
                    end
                    if 商品[i][2] == 1 and 商品[i][1] == "红" then
                        if findOne("宝石铭刻_钱不足" .. i) then
                            return
                        end
                        购买(i, true)
                        手牌["红"] = 手牌["红"] + 1
                    end
                end
            end
            return true
        end
        商店列表, 免费刷新 = path.宝石铭刻识别()
        if 免费刷新 then
            购买一次(商店列表, 免费刷新)
            tap("宝石铭刻_0刷新")
            ssleep(1)
            disappear("正在提交反馈至神经", network_timeout)
            ssleep(1)
        end
        商店列表 = path.宝石铭刻识别()
        购买一次(商店列表)
        if 当前轮数 >= 5 then
            local 有钱 = true
            while (购买次数 < 3 or (当前课程序号 == 8 and 手牌数量 < 工艺底座数量)) and 有钱 do
                if findOne("宝石铭刻_钱不足刷新") then break end
                tap("宝石铭刻_0刷新")
                ssleep(1)
                disappear("正在提交反馈至神经", network_timeout)
                ssleep(1)
                商店列表 = path.宝石铭刻识别()
                有钱 = 购买一次(商店列表)
            end
        end
        if findOne("宝石铭刻_钱不足底座") then
            return
        end
        tap('宝石铭刻_新增工作台')
        ssleep(.1)
        tap('宝石铭刻_购买工艺')
        ssleep(.2)
        工艺底座数量 = 工艺底座数量 + 1
        disappear("正在提交反馈至神经", network_timeout)
        商店列表 = path.宝石铭刻识别()
        购买一次(商店列表)
    end

    log("宝石铭刻第" .. 当前课程序号 .. "课教程")
    if not wait(function()
            tap('宝石铭刻_开始上课')
            tap('宝石铭刻_开始课程')
            if findOne("宝石铭刻_购买工艺界面") then return true end
        end, 10) then
        return
    end

    log('第一轮  购买两个工艺，不用判断')
    appear('宝石铭刻_工艺购买', 5)

    local jump = false
    while true do
        ssleep(2.5)
        宝石铭刻购买()
        log('工艺底座数量:', 工艺底座数量, ' 手牌数量:', 手牌数量, '当前轮数 :', 当前轮数, "手牌", 手牌)
        if 手牌["红"] >= 3 then
            手牌数量 = 手牌数量 - 1
            手牌["红"] = 手牌["红"] - 3
        end
        --购买完之后  准备进入【开始铭刻】界面
        if not wait(function()
                tap('宝石铭刻_下一个课程')
                if findOne('宝石铭刻_铭刻界面') then return true end
            end, 10, 1) then
            --if findOne('宝石铭刻_免费次数未用完') then   toast('免费次数未用完，重开')    end
            return
        end
        --if jump then return end --有时候出现免费次数未用完的情况，不继续购买直接重开

        log('开始铭刻', 工艺底座数量)
        手牌数量 = 手牌数量 + path.宝石铭刻摆放手牌(工艺底座数量, 1, 当前课程序号)

        --【开始铭刻】之后，准备进入下一轮的购买的界面
        log('准备下一轮')
        local jump = false
        if not wait(function()
                if findOne('宝石铭刻_铭刻完下一轮') then return true end
                if findOne('宝石铭刻_结束课程') then
                    jump = true
                    return true
                end
            end, 10, .2) then
            return
        end

        if jump then break end --遇到课程完事了情况 跳出
        log.debug()
        if not wait(function()
                tap('宝石铭刻_铭刻完下一轮')
                if not findOne('宝石铭刻_铭刻完下一轮') then return true end
            end, 10, .2) then
            return
        end
        log.debug()
        if not appear('宝石铭刻_购买工艺界面') then return end
        if not wait(function()
                if findOne('宝石铭刻_工艺购买') and findOne('宝石铭刻_购买工艺界面') then return true end
            end, 10, .2) then
            return
        end
        log.debug()
        当前轮数 = 当前轮数 + 1
        --优先级为  升级> 0刷新 > 购买底座
        --目前是在下一轮界面内
    end
    log('宝石铭刻 end')
end

path.宝石铭刻识别 = function()
    local 商品间距 = 167
    local 商品 = {}
    local 刷新 = false
    keepCapture()
    for i = 1, 3 do
        商品[i] = { "无商品", 0 }
        for i = 1, 3 do
            商品[i] = { "无商品", 0 }
            if cmpColor(scale(商品间距 * (i - 1) + 6 * math.floor(i / 3) + 617), scale(310), "DA9A39", 0.85) == 1 then
                商品[i][1] = "黄"
            elseif cmpColor(scale(商品间距 * (i - 1) + 6 * math.floor(i / 3) + 612), scale(312), "6E1829", 0.87) == 1 then
                商品[i][1] = "红"
            elseif cmpColor(scale(商品间距 * (i - 1) + 6 * math.floor(i / 3) + 611), scale(317), "32B99F", 0.85) == 1 then
                商品[i][1] = "青"
                if cmpColor(scale(商品间距 * (i - 1) + 6 * math.floor(i / 3) + 621), scale(321), "14FEF9", 0.85) == 1 then
                    商品[i][1] = "青1"
                elseif cmpColor(scale(商品间距 * (i - 1) + 6 * math.floor(i / 3) + 621), scale(322), "120D0C", 0.8) == 1 then
                    商品[i][1] = "青2"
                elseif cmpColor(scale(商品间距 * (i - 1) + 6 * math.floor(i / 3) + 620), scale(319), "161A1A", 0.8) == 1 then
                    商品[i][1] = "青3"
                end
            elseif cmpColor(scale(商品间距 * (i - 1) + 6 * math.floor(i / 3) + 590), scale(322), "242282", 0.87) == 1 then
                商品[i][1] = "紫"
            else
                商品[i][1] = "无商品"
            end
            if cmpColor(scale(商品间距 * (i - 1) + 6 * math.floor(i / 3) + 727), scale(331), "FFFFFF", 0.9) == 1 then
                --升级
                商品[i][2] = 1
            else
                商品[i][2] = 0
            end
        end
    end
    log(商品)
    if findOne("宝石铭刻_0刷新") then 刷新 = true end
    releaseCapture()
    return 商品, 刷新
end

path.宝石铭刻第9课教程 = function()
    local 当前课程序号 = 9
    local 手牌数量 = 0 --记录当前手牌数量
    local 工艺底座数量 = 2 --记录底座的数量
    local 当前轮数 = 1 --记录当前第几轮

    local 宝石铭刻购买 = function()
        if findOne("宝石铭刻_钱不足底座") or 工艺底座数量 == 6 then
            return
        end
        tap('宝石铭刻_新增工作台')
        ssleep(.1)
        tap('宝石铭刻_购买工艺')
        ssleep(.2)
        工艺底座数量 = 工艺底座数量 + 1
        disappear("正在提交反馈至神经", network_timeout)
    end

    log("宝石铭刻第" .. 当前课程序号 .. "课教程")
    if not wait(function()
            tap('宝石铭刻_开始上课')
            if not findOne("宝石铭刻_开始上课") then return true end
        end, 10, .2) then
        return
    end
    appear('宝石铭刻_开始课程')
    if not wait(function()
            tap('宝石铭刻_开始课程')
            if not findOne("宝石铭刻_开始课程") then return true end
        end, 10, .2) then
        return
    end

    log('第一轮  购买两个工艺，不用判断')
    appear('宝石铭刻_钱不足底座', 5)

    while true do
        ssleep(2.5)
        宝石铭刻购买()

        --购买完之后  准备进入【开始铭刻】界面
        if not wait(function()
                tap('宝石铭刻_下一个课程')
                if findOne('宝石铭刻_铭刻界面') then return true end
            end, 15) then
            return
        end

        if 工艺底座数量 < 5 then
            --单出红4
            tap("宝石铭刻_第九关红4")
            ssleep(.1)
            tap("宝石铭刻_工作台列表1")
            ssleep(.2)
        else
            for i = 1, 工艺底座数量 do
                tap("宝石铭刻_第九关出" .. 工艺底座数量 .. "牌列表" .. i)
                ssleep(.1)
                tap("宝石铭刻_工作台列表" .. i)
                ssleep(.2)
            end
        end
        wait(function()
            tap('宝石铭刻_开始铭刻')
            if not findOne("宝石铭刻_开始铭刻") then return true end
        end, 10)

        --【开始铭刻】之后，准备进入下一轮的购买的界面
        log('准备下一轮')
        local jump = false
        if not wait(function()
                if findOne('宝石铭刻_铭刻完下一轮') then return true end
                if findOne('宝石铭刻_结束课程') then
                    jump = true
                    return true
                end
            end, 10, .2) then
            return
        end
        --点数不够可以打无尽
        if jump then
            第九关打完了 = true
            break
        end --遇到课程完事了情况 跳出
        log.debug()
        if not wait(function()
                tap('宝石铭刻_铭刻完下一轮')
                if not findOne('宝石铭刻_铭刻完下一轮') then return true end
            end, 10, .2) then
            return
        end
        log.debug()
        if not appear('宝石铭刻_购买工艺界面') then return end
        if not wait(function()
                if findOne('宝石铭刻_周边部') and findOne('宝石铭刻_购买工艺界面') then return true end
            end, 10, .2) then
            return
        end
        log.debug()
        当前轮数 = 当前轮数 + 1
        --优先级为  升级> 0刷新 > 购买底座
        --目前是在下一轮界面内
    end
    log('宝石铭刻 end')
end

path.专注失调 = function()
    auto_skill()
end

-- 原先的table.equal不知道为什么有误，重写的
tablesEqual = function(t1, t2)
    if t1 == t2 then return true end
    if type(t1) ~= "table" or type(t2) ~= "table" then return false end

    for k, v in pairs(t1) do
        if not tablesEqual(v, t2[k]) then
            return false
        end
    end

    for k in pairs(t2) do
        if t1[k] == nil then
            return false
        end
    end

    return true
end

-- 原先的table.equalkey不知道为什么有误，重写的
equalKey2 = function(a, b)
    if type(a) ~= 'table' or type(b) ~= 'table' then return end

    if #a ~= #b then return end
    if #a == 0 and #table.keys(a) ~= #table.keys(b) then return end

    for k, _ in pairs(a) do if b[k] == nil then return end end

    local count = {}

    for _, value in ipairs(a) do
        count[value] = (count[value] or 0) + 1
    end

    for _, value in ipairs(b) do
        if not count[value] then
            return false
        end
        count[value] = count[value] - 1
    end

    for _, v in pairs(count) do
        if v ~= 0 then
            return false
        end
    end

    return true
end

path.烟花委员会loop = function()
    car_checked = false
    while true do
        if not appear("活动导航0", 2) then
            tap(hd_position)
            if not wait(function()
                    if findOne("活动导航0") or findOne("活动商店导航") then return true end
                    if findOne("跳过剧情") and not findAny({ "活动导航0", "活动商店导航" }) then path.跳过剧情() end
                    if findOne("教程关闭") then tap("教程关闭") end
                end, 15) then
                return
            end
        end
        path.烟花委员会()
        car_checked = false
        ssleep(0.3)
    end
end

path.烟花委员会 = function()
    log("烟花活动")
    -- 导航
    if car_checked or copy_homework then --抄作业时候不做小游戏
        car_checked = true
        return
    end
    appear("烟花委员会进入", 3)
    if not (findOne("活动导航0") and findOne("烟花委员会进入")) then
        return
    end
    car_checked = true
    tap("烟花委员会进入")
    appear("烟花委员会首页", 5)
    if appear("烟花_剧情判断", 0.5) then
        wait(function()
            for w = 150, screen.width - 50, 50 do
                if findOne("烟花关卡内部进入判断") then return true end
                if findAny(known) then return true end
                for h = 50, screen.height - 50, 50 do
                    tap({ w, h })
                    back()
                end
            end
            ssleep(1)
        end, 15)
        tap("生息演算_全局_返回")
        ssleep(1)
    end
    ssleep(1)
    -- 寻找没打的关卡
    if not wait(function()
            -- local p = findOnes("烟花_关卡寻找", .87)
            -- if p then
            --     for _, v in ipairs(p) do
            --         --快速点击所有结果，总有一个能进入
            --         tap({ v.x, v.y })
            --         ssleep(.1)
            --         if not findOne("烟花委员会首页") then break end
            --     end
            --     disappear("烟花委员会首页", 3)
            -- end
            local d_p = find_color("烟花_关卡寻找范围", "DF554E", 4, 0.95)
            if d_p then
                log(d_p)
                tap({ d_p[1], d_p[2] + scale(40) })
                disappear("烟花委员会首页", 3)
            end
            if findOne("烟花关卡内部进入判断") then return true end
        end, 3, 1) then
        -- wait(function()
        --     tap("生息演算_全局_返回")
        --     ssleep(1)
        --     if findOne("活动导航0") then return true end
        -- end, 10)
        -- return
        local d_p = find_color("烟花_关卡寻找范围", "DF554E", 4, 0.95)
        if d_p then
            log(d_p)
            tap({ d_p[1], d_p[2] + scale(40) })
            disappear("烟花委员会首页", 3)
        else
            back()
            return
        end
    end

    -- 基础函数
    local rotate90 = function(x, y)
        return { y, 7 - x + 1 }
    end

    local rotate180 = function(x, y)
        return { 7 - x + 1, 7 - y + 1 }
    end

    local rotate270 = function(x, y)
        return { 7 - y + 1, x }
    end

    local trans_p = function(sam_p)
        local cur_card = {}
        cur_card[1] = shallowCopy(sam_p)
        cur_card[2] = {}
        cur_card[3] = {}
        cur_card[4] = {}
        for k, v in pairs(sam_p) do
            -- log(v)
            table.insert(cur_card[2], rotate90(v[1], v[2]))
            table.insert(cur_card[3], rotate180(v[1], v[2]))
            table.insert(cur_card[4], rotate270(v[1], v[2]))
        end
        for i = 1, 4 do
            table.sort(cur_card[i], function(a, b)
                if a[1] == b[1] then
                    return a[2] < b[2]
                else
                    return a[1] < b[1]
                end
            end)
        end
        if tablesEqual(cur_card[1], cur_card[3]) then
            log(cur_card)
            cur_card[3] = {}
            cur_card[4] = {}
        end
        return cur_card
    end
    all_p = {}
    local count_p = function(col, xp1, sc, t_data)
        for i = 1, 7 do     -- 行
            for j = 1, 7 do -- 列
                if math.abs(4 - i) <= j and j <= 7 - math.abs(4 - i) then
                    local tx, ty = tonumber(xp1.x + (j - 1) * scale(sc) - 0.8 * (i - 1)),
                        tonumber(xp1.y + (i - 1) * scale(sc) + 0.8 * j)
                    -- log(i, j)
                    -- log(tx, ty)
                    -- log(getPixelColor(tx, ty))
                    if cmpColor(tx, ty, col, 0.9) == 1 then
                        -- log("find")
                        table.insert(t_data, { i, j })
                    end
                end
            end
        end
        return t_data
    end
    -- 这是需要填满的格子
    all_p = count_p("AAAAA9", { x = scale(504), y = scale(130) }, 95, all_p)
    -- table.insert(all_p, { 4, 4 })
    log("all_p", all_p)

    -- 计算可填充的卡片
    -- 未来会不会有更多的不清楚
    local positions = {
        { x = scale(1480), y = scale(86) },  --1,1
        { x = scale(1713), y = scale(84) },  --1,2
        { x = scale(1472), y = scale(275) }, --2,1
        { x = scale(1703), y = scale(280) }, --2,2
        { x = scale(1459), y = scale(470) }, -- 3,1
        { x = scale(1694), y = scale(472) }  -- 3,2

    }

    local max_card_group = #positions
    local cards = {}
    for i = 1, max_card_group do
        cards[i] = trans_p(count_p("B2B2B2", positions[i], 22, {}))
        log("card_" .. i, cards[i])
    end

    local all_card = {}

    local get_match_card = function()
        for i, card in ipairs(cards) do
            for k, v in pairs(card) do
                table.insert(all_card, { i, k, v })
            end
        end
    end
    get_match_card()
    log("all_card", all_card)

    local check_p = function(cd)
        local td = {}
        for k, v in pairs(cd) do
            for k2, v2 in pairs(v[3]) do
                table.insert(td, "p" .. v2[1] .. v2[2])
            end
        end
        td = table.remove_duplicate(td)
        table.removev(td, "p44") -- 4,4不用考虑
        local all_p2 = {}
        for k, v in pairs(all_p) do
            table.insert(all_p2, "p" .. v[1] .. v[2])
        end
        -- log("cd", cd)
        -- log("t", td)
        -- log("p", all_p2)
        if equalKey2(td, all_p2) then
            log("可填满")
            return true
        end
    end
    log("开始遍历")
    local c_number = 4
    local tmp_cn = find_color("卡片数量判断范围", "E6E6E6", 0, 0.9)
    if tmp_cn then
        log(tmp_cn, math.floor((tmp_cn[1] / scale(160) + 0.5)))
        c_number = math.floor((tmp_cn[1] / scale(160) + 0.5)) - 1
        log("待选择卡片数量", c_number)
    end
    -- 遍历运算
    local last_choose = 0
    for _, c in pairs(table.combination(range(1, #all_card), c_number)) do
        nx = table.index(all_card, c)
        if check_p(nx) then
            for k, v in pairs(nx) do
                log("点击第" .. v[1] .. "套卡片的第" .. v[2] .. "张")
                local 待点击卡片组 = { scale(1546), scale(148) }
                if v[1] % 2 == 0 then
                    log(v[1], v[1] % 2)
                    待点击卡片组[1] = 待点击卡片组[1] + scale(230)
                end
                待点击卡片组[2] = 待点击卡片组[2] + scale(210) * math.floor((v[1] - 1) / 2)
                if last_choose == v[1] then
                    tap("烟花_卡片" .. v[2])
                else
                    tap(待点击卡片组)
                    appear("烟花_卡片选择弹出", 2)
                    ssleep(0.6)
                    tap("烟花_卡片" .. v[2])
                end
                last_choose = v[1]
                ssleep(0.8)
            end
            break
        end
    end
    log("结束遍历")
    appearTap("烟花_方案确认", 5)
    ssleep(1)
    wait(function()
        tap("生息演算_全局_返回")
        ssleep(1)
        if findOne("活动导航0") then return true end
    end, 10)
    return
    -- path.跳转("首页")
end

-- 横排奖励,要求取入口/页面/领取三个点
path.活动奖励 = function(活动)
    log("领取" .. 活动 .. "奖励")
    if appear(活动 .. "奖励入口", 1) then
        tap(活动 .. "奖励入口")
    else
        log(活动 .. "奖励入口未找到")
        return
    end
    appear(活动 .. "奖励页面", 3)
    if not wait(function()
            tap(活动 .. "奖励全部领取")
            if findOne("获得物资") then
                tap("获得物资")
                disappear("获得物资", 1.5)
                return true
            end
            ssleep(.1)
        end, 10) then
    end
    appear(活动 .. "奖励页面", 3)
    ssleep(.1)
    tap("返回")
    appear(活动 .. "首页", 2)
end

path.卫戍协议 = function()
    if not findAny({ "卫戍协议首页", "卫戍协议放弃模拟" }) then
        path.跳转("首页")
        tap("面板活动")
        ssleep(2.5)
    end
    if appear("教程关闭", 3) then tap("教程关闭") end
    while not path.卫戍协议循环() do

    end
    path.活动奖励("卫戍协议")
end

path.卫戍协议循环 = function()
    log("卫戍协议循环")
    local p = findAny({ "卫戍协议首页", "卫戍协议放弃模拟" })
    if not p then
        path.跳转("首页")
        tap("面板活动")
        ssleep(2.5)
    end
    if not appear(p, 5) then return end
    if p == "卫戍协议放弃模拟" then
        goto relink
    end
    if findOne("卫戍协议等级max") then
        log("卫戍协议等级已满")
        captureqqimagedeliver("INFO", "卫戍协议等级已满", "卫戍协议等级已满")
        return true
    end
    if shp_only_daily_task and findOne("卫戍协议每日已完成") then
        log("卫戍协议每日已完成")
        captureqqimagedeliver("INFO", "卫戍协议每日已完成", "卫戍协议每日已完成")
        return true
    end
    tap("卫戍协议首页")
    disappear("卫戍协议首页", 3)
    appear("卫戍协议开始模拟", 2)
    ssleep(.2)
    -- 打过高难度之后需要滑动重置难度
    gesture({
        {
            point = {
                { scale(1481), scale(232) },
                { scale(1481), scale(2000) },
            },
            start = 0,
            duration = 300,
        },
    })
    sleep(300)
    log("滑动完毕")
    ssleep(.3)
    for i = 1, 2 do --只打前两个难度
        tap("卫戍协议难度列表" .. i)
        ssleep(.9)
    end
    -- if findOne("卫戍协议入门难度") then
    --     log("跳过教程")
    --     --进图后强退app,到主页放弃上一把
    -- end
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
    for i = 1, 4 do
        if appearTap("卫戍协议战斗准备就绪", 45) then
            i = i + 1
            ssleep(.5)
            if appear("卫戍协议金币清零确定") then
                tap("卫戍协议金币清零勾")
                ssleep(.1)
                tap("卫戍协议金币清零确定")
            end
            ssleep(15)
        end
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
    if not wait(function()
            tap("卫戍协议准备就绪")
            ssleep(2)
            disappear("正在提交反馈至神经", network_timeout)
            if findOne("卫戍协议首页") then return true end
        end, 30, 1) then
        log("可能是卡住了,点一下返回首页")
        tap("卫戍协议准备就绪")
    end
end

path.保全 = function()
    path.跳转("首页")
    tap("面板作战")
    if not appear("主页") then return end

    if not wait(function()
            tap("主题曲")
            if findOne("主题曲界面") then return true end
        end) then
        return
    end

    wait(function()
        tap("每周部署")
        if not findOne("主题曲界面") then return true end
    end)

    -- 注意有噪点
    -- 只做一次，防止循环等
    clean_fight(cur_fight)
    local 继续打
    if not appear("主页") then return end
    if not appear("保全派驻进入黄") then
        if copy_homework then
            继续打 = true
        else
            return
        end
    end
    if not wait(function()
            tap("保全派驻进入黄")
            if not findOne("主页") then return true end
        end, 5) then
        return
    end
    log.debug(cur_fight)
    if 继续打 then
        ssleep(4)
        appear("开始行动保全")
        auto_sss(homework[cur_fight], true, nil, 继续打)
        return
    end

    if not appear("保全派驻首页", 10) then
        back()
        if appear("保全离开确认", 3) then
            tap("保全离开确认")
        end
        return
    end

    if findOne("保全作战全部完成白条") then
        log.debug()
        return
    end
    ssleep(1)

    -- 保全抄作业
    if copy_homework then
        log("抄作业", cur_fight, homework[cur_fight])
        --if not homework[cur_fight] then return end
        if cur_fight == "BQPZ1" then
            if findOne("保全关卡1全部完成勾") then
                log.debug()
                return
            end
            tap("保全1进入")
        elseif cur_fight == "BQPZ2" then
            --[[if findOne("保全关卡2全部完成勾") then
                log.debug()
                return
            end]]
            tap("保全2进入")
        else
            log.warn("未知保全地图")
            return
        end
        if not appear("保全作战开始按钮", 3) then return end
        auto_sss(homework[cur_fight], true)
        return
    end

    -- 扫荡
    if findOne("保全关卡1全部完成勾") then
        tap("保全关卡1全部完成勾") -- 左上角的那个
    elseif findOne("保全关卡2全部完成勾") then
        tap("保全关卡2全部完成勾") -- 中间的那个
    elseif not sss_only_complete then
        log.debug()
        if findOne("保全1可扫荡") then
            tap("保全1进入")
        elseif findOne("保全2可扫荡") then
            tap("保全2进入")
        elseif sss_try_complete then
            cur_fight = "BQPZ1&prts://44971"
            log("抄作业", cur_fight, homework[cur_fight])
            tap("保全1进入")
            if not appear("保全作战开始按钮", 3) then return end
            auto_sss(homework[cur_fight], true)
        else
            log.debug()
            return
        end
    else
        log.debug()
        return
    end

    -- 代理卡
    if not appear("保全作战开始按钮", 3) then
        back()
        return
    end
    if not wait(function()
            tap("保全prts按钮")
            ssleep(0.5)
            if findOne("全权委托变蓝") then return true end
        end, 3) then
        log.debug()
        return
    end

    tap("保全作战开始按钮")
    if not appear("确认使用代理卷蓝", 3) then return end
    tap("确认使用代理卷蓝")
    if not wait(function()
            appearTap("保全完成黄色竖条", 0.5)
            if findOne("保全作战开始按钮") then return true end
        end, 10) then
        back()
        log.debug()
        return
    else
        log.debug()
        return true
    end
end

path.促融共竞 = function()
    ib.start()
end

path.促融共竞重复IG7 = function()
    never_end_wrapper(ib.促融共竞重复IG7())
end


path.争锋频道活动 = function()
    if not findOne("争锋频道首页") then
        path.跳转("首页")
        tap("面板活动2")
    end
    if not appear("争锋频道首页", 5) then return end
    if duel_channel_only_daily_task and appear("争锋频道每日打满", 2) then
        log("争锋频道每日已完成")
        goto duel_channel_reward
    end
    wait(function()
        if findOne("自娱自乐第一位") then
            tap("自娱自乐第一位")
            ssleep(.5)
        end
        if duel_channel_mode == 0 and findOne("自娱自乐第三位") then
            tap("自娱自乐第三位")
            ssleep(.5)
        end
        tap("加入赛事")
        if findOne("礼物对决") then return true end
    end, 10, .2)
    log("加入赛事完成")
    auto(争锋频道循环, true, 0, nil, false)
    ::duel_channel_reward::
    path.活动奖励("争锋频道")
end


争锋频道循环 = {
    争锋频道选择模式 = function()
        if duel_channel_mode == 0 then
            tap("自娱自乐第三位")
        elseif duel_channel_mode == 1 then
            tap("礼物对决")
        end
        ssleep(0.5)
    end,
    自娱自乐第一位 = function()
        tap("自娱自乐第一位")
        ssleep(0.5)
    end,
    开始匹配 = function()
        tap("开始匹配")
        ssleep(0.5)
    end,
    结算_离开比赛 = function()
        tap("结算_离开比赛")
        ssleep(0.5)
    end,
    争锋频道继续匹配 = function()
        if duel_channel_auto_stop then
            local 代币增加 = (ocr("结算代币ocr范围")[1] or {}).text or ""
            if string.finds(代币增加, { "+" }) then
                local 代币增加数量 = int(string.match(代币增加, "%d+")) or 1
                log("代币增加数量", 代币增加, 代币增加数量)
                if 代币增加数量 == 0 then
                    log("停止匹配")
                    return "返回"
                end
            end
        end
        tap("争锋频道继续匹配")
        ssleep(0.5)
    end,
    争锋频道首页 = function()
        ssleep(0.5)
        if duel_channel_only_daily_task and findOne("争锋频道每日打满") then
            return "争锋频道每日打满"
        else
            tap("加入赛事")
            ssleep(.8)
        end
    end,
    支持左侧 = function()
        if duel_channel_strategy == 1 then
            local left_text = (ocr("左边支持人数ocr范围")[1] or {}).text or ""
            local right_text = (ocr("右边支持人数ocr范围")[1] or {}).text or ""
            local left_number = str2int(string.match(left_text, "%d+"), 0)
            local right_number = str2int(string.match(right_text, "%d+"), 0)
            log("左边支持人数", left_text, left_number)
            log("右边支持人数", right_text, right_number)
            if left_number > 0 or right_number > 0 then
                if left_number > right_number then
                    log("支持左侧")
                    tap("支持左侧按钮")
                    ssleep(0.5)
                elseif right_number > left_number then
                    log("支持右侧")
                    tap("支持右侧按钮")
                    ssleep(0.5)
                else
                    log("相同")
                    tap("支持右侧按钮")
                    ssleep(0.5)
                end
            end
        end
        ssleep(1)
    end,
    支持右侧 = function()
        return 争锋频道循环.支持左侧()
    end,
    礼物不足 = function()
        return 争锋频道循环.支持左侧()
    end,
}


相谈室活动 = function(是否继续)
    if not 是否继续 then
        log('是 继续')
        if not findAny({ "相谈室进入", "相谈室交谈进行中" }) then
            log.debug()
            return
        end
        if not wait(function()
                findTap("相谈室进入")
                findTap("相谈室交谈进行中")
                if findOne("相谈室首页") then return true end
            end, 10) then
            return
        end
        if findOne("相谈室任务领取") then
            tap("相谈室任务领取")
            appearTap("相谈室任务领取按钮", 4)
            if not wait(function()
                    back()
                    ssleep(0.3)
                    if findOne("相谈室首页") then return true end
                end, 10) then
                return
            end
        end
        if appear("相谈室全部完成", 2) then
            log("小活动已完成")
            return true
        end
        if not wait(function()
                tap("相谈室开始营业")
                if findOne("相谈室钱币不够弹窗") then
                    return true
                end
                if findOne("相谈室开始交谈") then return true end
                if findAny({ "相谈室当前回合页面教程" }) then return true end
            end, 10) then
            return
        end
        if findOne("相谈室钱币不够弹窗") then
            back()
            return true
        end
    else
        if findOne("相谈室开始营业") then
            return
        end
    end

    if not wait(function()
            if findOne('相谈室开始营业页面教程') then
                tap('相谈室开始营业页面教程')
            end
            tap("相谈室开始交谈")
            ssleep(0.8)
            if findAny({ "相谈室当前回合页面", "相谈室结束对话", "相谈室当前回合页面教程" }) then return true end
        end, 35) then
        return
    end

    信任 = 0
    兴趣 = 0
    回合数 = 0
    local 选项转换 = {
        喋喋不休 = {
            信任 = 3,
            兴趣 = -1
        },
        花言巧语 = {
            信任 = -1,
            兴趣 = 3
        },
        言之有据 = {
            信任 = 2,
            兴趣 = 1
        },
        口吐珠玑 = {
            信任 = 1,
            兴趣 = 2
        },
        随想畅聊 = {
            信任 = 1,
            兴趣 = 1
        },
    }

    local 获取选项文字 = function(area)
        local ret1 = ocr_ret(area)
        log.debug(ret1)
        if string.finds(ret1, { "不休", "不", "休" }) then
            return "喋喋不休"
        elseif string.finds(ret1, { "巧语", "花言巧语", }) then
            return "花言巧语"
        elseif string.finds(ret1, { "言之", "言之有据" }) then
            return "言之有据"
        elseif string.finds(ret1, { "口吐珠玑", "口吐" }) then
            return "口吐珠玑"
        elseif string.finds(ret1, { "畅聊", "想" }) then
            return "随想畅聊"
        else
            log("未知选项", ret1)
            return nil
        end
    end
    local 选哪个好点 = function(选项1, 选项2, is_max)
        if not 选项1 or not 选项2 then
            log.warn("选项1未识别")
            return 1
        end
        local 选项1结果 = {
            信任 = 信任 + 选项转换[选项1].信任,
            兴趣 = 兴趣 + 选项转换[选项1].兴趣
        }
        log("选项1结果", 选项1结果)
        local 选项2结果 = {
            信任 = 信任 + 选项转换[选项2].信任,
            兴趣 = 兴趣 + 选项转换[选项2].兴趣
        }
        log("选项2结果", 选项2结果)
        if is_max then
            if 选项1结果.信任 + 选项1结果.兴趣 > 选项2结果.信任 + 选项2结果.兴趣 then
                return 1
            else
                return 2
            end
        else
            if math.abs(选项1结果.信任 - 选项1结果.兴趣) > math.abs(选项2结果.信任 - 选项2结果.兴趣) then
                return 2
            else
                return 1
            end
        end
    end

    local 进行游戏回合 = function()
        local 选项1 = 获取选项文字("相谈室选项1ocr范围")
        local 选项2 = 获取选项文字("相谈室选项2ocr范围")
        local 选择结果 = 选哪个好点(选项1, 选项2, true and 回合数 < 5 or false)
        log.debug(选项1, 选项2, 选择结果)
        if 选择结果 == 1 and 选项1 ~= nil then
            信任 = 信任 + 选项转换[选项1].信任
            兴趣 = 兴趣 + 选项转换[选项1].兴趣
        elseif 选择结果 == 2 and 选项2 ~= nil then
            信任 = 信任 + 选项转换[选项2].信任
            兴趣 = 兴趣 + 选项转换[选项2].兴趣
        end
        log.debug(信任, 兴趣)
        if not wait(function()
                tap("相谈室选项" .. 选择结果)
                ssleep(0.5)
                if not findOne("相谈室当前回合页面") then return true end
            end, 10) then
            log.warn("相谈室选项点击失败")
            return
        end
        back()
        log.debug()
        if not wait(function()
                if findOne('相谈室回应风格教程') then
                    tap('相谈室回应风格教程')
                    tap('相谈室使用望气教程点击')
                    tap('相谈室使用望气教程点击2')
                end
                findTap("相谈室开始营业", 5)
                tap("相谈室下一轮")
                ssleep(0.8)
                if findAny({ "相谈室当前回合页面", "相谈室结单按钮" }) then return true end
                if findOne("相谈室结束对话") then return true end
            end, 15) then
            log.debug()
            return
        end
    end

    for i = 1, 9 do
        回合数 = i
        进行游戏回合()
        local x = appear({ "相谈室当前回合页面", "相谈室结单按钮" }, 5)
        if x == "相谈室结单按钮" then
            log("相谈室结单按钮")
            tap("相谈室结单按钮")
            break
        elseif x ~= "相谈室当前回合页面" then
            log.debug()
            return
        end
        ssleep(0.3)
    end

    -- 终止游戏
    appearTap("相谈室结束对话", 5)
    if not wait(function()
            tap("相谈室结束确认选择")
            if findOne("相谈室营业结束") then
                return true
            end
            if findAny({ "相谈室开始交谈", "相谈室开始营业" }) then return true end
            ssleep(0.5)
        end, 30) then
        log.warn("相谈室终止游戏点击失败")
        return
    end
    if findOne("相谈室开始交谈") then
        return 相谈室活动(true)
    end
    if findOne("相谈室营业结束") then
        if not wait(function()
                back()
                findTap("相谈室活动左上角返回")
                ssleep(0.5)
                if findOne("活动导航0") then return true end
            end, 30) then
            log.warn("相谈室终止游戏点击失败")
            return
        end
        return true
    end
end

-- -- 这次联动用的 左下角不能点到
-- swipenew = function(x)
--     -- 作战中第一次右滑容易错位，先做一次
--     if first_time_swipe then
--         first_time_swipe = false
--         -- swip("9-2")
--     end

--     -- tap({scale(300), scale(150)})
--     log("swipenew", x)
--     if x == 'right' then
--         -- 15章滑动修复
--         gesture({
--             {
--                 point = { { scale(370), scale(573) }, { 1000000, scale(573) } },
--                 start = 0,
--                 duration = 250,
--             },
--         })
--         sleep(150 + 50)
--     end
-- end


-- swipnew = function(dis)
--     if type(dis) == "string" then dis = distance[dis] end
--     if type(dis) ~= "table" then dis = { dis } end
--     if not dis then return end

--     -- 懒人单次手势不能添加过多定时点，理想是在插入finger时处理，偷懒直接手动切分下距离
--     -- 只处理作战关卡导航中的情况
--     log.debug()
--     log(dis)
--     local max_dis_one_gesture = 5000
--     if #dis == 2 and math.abs(dis[1]) == swip_right_max and dis[2] <
--         -max_dis_one_gesture then
--         table.insert(dis, dis[2] + max_dis_one_gesture)
--         dis[2] = -max_dis_one_gesture
--     end
--     log.debug()
--     log(dis)
--     for i, d in pairs(dis) do
--         if i ~= 1 then ssleep(0.1) end
--         if math.abs(d) == swip_right_max then
--             swipenew("right")
--         else
--             swipunew(d)
--         end
--     end
-- end


-- swipunew = function(dis)
--     log('swipu2', dis)
--     -- preprocess distance
--     if type(dis) == "string" then dis = distance[dis] end
--     if type(dis) ~= "table" then dis = { dis } end
--     if not dis then return end
--     log.debug()
--     -- flatten to one depth
--     -- local max_once_dis = 1080
--     -- local freey = scale(150)
--     local freey = scale(150)              -- 避开14章右上角
--     local freex = scale(360 / 720 * 1080) -- 第12章左上角
--     local max_once_dis = screen.width - scale(300) - freex

--     for _, d in pairs(dis) do
--         local sign = d > 0 and 1 or -1
--         if math.abs(d) == swip_right_max then
--             swipe(sign > 0 and "right" or "left")
--         else
--             -- 只实现了右移
--             if sign > 0 then stop("swipu左移未实现") end
--             local finger = {
--                 {
--                     point = { { freex, freey }, { freex, screen.height - 1 } },
--                     start = 0,
--                     duration = 0,
--                 },
--             }
--             local start = 0
--             local duration = 300
--             local interval = 100
--             local end_delay = 150
--             local flipy = swipu_flipy or 0
--             local flipx = swipu_flipx or 0
--             d = math.abs(d)
--             while d > 0 do
--                 if d > max_once_dis then
--                     table.insert(finger, {
--                         point = {
--                             { freex + max_once_dis, freey + flipx },
--                             { freex + max_once_dis, freey + flipy },
--                         },
--                         start = start,
--                         duration = duration,
--                     })
--                 else
--                     table.insert(finger, {
--                         point = { { freex + d, freey }, { freex + d + flipx, freey + flipy } },
--                         start = start,
--                         duration = duration,
--                     })
--                 end
--                 d = d - max_once_dis
--                 start = start + duration + interval
--                 -- log(finger[#finger])
--             end
--             local last_finger = finger[#finger]
--             finger[1].duration = last_finger.start + last_finger.duration + end_delay
--             log("finger", finger)
--             gesture(finger)
--             if type(swipp_wait_time) == "string" and swipp_wait_time ~= "" then
--                 sleep(tonumber(swipp_wait_time))
--             end
--             sleep(finger[1].duration + 50)
--         end
--     end
-- end

markConsecutiveSequences = function(data)
    for _, item in ipairs(data) do
        item.is_con = false
    end

    local i = 1
    local seq_index = {}
    while i <= #data do
        local currentNum = data[i].number
        local j = i
        local sequence = {}
        local numberToIndex = {} -- 记录每个数字第一次出现的索引

        -- 继续查找连续的数字
        while j <= #data do
            local num = data[j].number

            if num == currentNum then
                -- 相同的数字，只记录第一次出现的索引
                if not numberToIndex[num] then
                    numberToIndex[num] = data[j].index
                    table.insert(sequence, data[j].index)
                end
                j = j + 1
            elseif num == currentNum + 1 then
                -- 连续的下一个数字
                if not numberToIndex[num] then
                    numberToIndex[num] = data[j].index
                    table.insert(sequence, data[j].index)
                end
                currentNum = num
                j = j + 1
            else
                -- 数字不连续，退出循环
                break
            end
        end

        -- 计算序列中包含多少个不同的数字
        local uniqueCount = 0
        for _ in pairs(numberToIndex) do
            uniqueCount = uniqueCount + 1
        end
        if uniqueCount >= 2 then
            -- 标记所有在这个范围内的项
            for k = i, j - 1 do
                data[k].is_con = true
            end
            table.insert(seq_index, sequence)
        end

        i = j
    end
    log("标记连续序列结果", data)

    return seq_index, data
end

path.喀兰贸易技术研发部 = function()
    if screen.width ~= 1920 or screen.height ~= 1080 then
        stop("喀兰贸易技术研发部仅支持1920x1080分辨率")
    end
    if not findAny({ "喀兰贸易活动首页进入", "喀兰贸易活动场地未开放", "喀兰贸易活动开始重建" }) then
        path.跳转("首页")
        tap(hd_position)
        if not appear("喀兰贸易活动首页进入", 5) then return end
    end
    喀兰贸易重建活动(true)
end

喀兰贸易重建活动 = function(need_enter)
    log("喀兰贸易重建活动")
    if need_enter then
        if not appear({ "喀兰贸易活动首页进入", "喀兰贸易活动场地未开放", "喀兰贸易活动开始重建" }, 5) then return end
        log.debug()
        if not wait(function()
                tap("喀兰贸易活动首页进入")
                if findOne("喀兰贸易活动场地未开放") then return true end
                if findOne("喀兰贸易活动开始重建") then return true end
                if findOne("教程关闭") then
                    tap("教程关闭")
                    ssleep(.2)
                end
            end, 10) then
            back()
            log.debug()
            return
        end
        log.debug()
        if findOne("喀兰贸易活动场地未开放") then
            log.debug()
            return true
        end
        while true do
            if findOne('喀兰贸易活动已达成') then
                if findOne('喀兰贸易活动最后一关') then
                    log("喀兰贸易活动完成所有关卡")
                    captureqqimagedeliver("INFO", "喀兰贸易活动推送", table.join(qqmessage, ' '))
                    return true
                end
                tap('喀兰贸易活动下一关')
                ssleep(0.2)
                log.debug()
            end
            if findOne('喀兰贸易活动开始重建', 2) then
                tap('喀兰贸易活动开始重建')
                log.debug()
                break
            end
            if not findOne('喀兰贸易活动下一关') then
                log.debug()
                return
            end
        end
        log.debug()
    end

    if findOne("喀兰贸易结算画面") then
        log("重建成功，下一局")
        tap("喀兰贸易下一局")
        wait(function()
            tap("喀兰贸易领取")
            if findAny({ "喀兰贸易活动首页进入", "喀兰贸易活动场地未开放", "喀兰贸易活动开始重建" }) then
                return true
            end
        end, 10)
        appear({ "喀兰贸易活动首页进入", "喀兰贸易活动场地未开放", "喀兰贸易活动开始重建" }, 4)
        return 喀兰贸易重建活动(true)
    end

    local 数字列表 = {}
    log("开始识别数字")
    for i = 1, 8 do
        local cx = 63 + (i - 1) * 147
        local cy = 880
        for j = 1, 5 do
            local need_cop = point["喀兰贸易数字列表" .. str(j)]
            -- log("need", need_cop)
            local is_this_number = true
            for k, v in pairs(need_cop) do
                local px = cx + v[1]
                local py = cy + v[2]
                --log("check", px, py)
                --log(getColor(px, py))
                if not compareColor(px, py, "#FFFFFF", 0.9) then
                    is_this_number = false
                    break
                end
                --log("match", px, py)
            end
            if is_this_number then
                table.insert(数字列表, {
                    index = i,
                    number = j,
                    is_choose = false,
                })
                break
            end
        end
    end

    -- 测试
    -- local hd_debug = true
    -- 数字列表 = { { index = 1, number = 1, is_choose = false }, { index = 2, number = 2, is_choose = false }, { index = 3, number = 2, is_choose = false }, { index = 4, number = 4, is_choose = false }, { index = 5, number = 5, is_choose = false } }

    if #数字列表 < 1 then
        log("数字识别失败", 数字列表)
        appearTap("喀兰贸易结束回合红", 1)
        return 喀兰贸易重建活动()
    end

    local seq_index
    seq_index, 数字列表 = markConsecutiveSequences(数字列表)
    log("数字列表", 数字列表)
    log("连续序列索引", seq_index)

    -- 寻找 非连续序列的数字，选择第一个选择标记为前进。然后寻找连续序列的最后一项，全部标记为 收集资源。
    -- 重复上面的逻辑直到没有非连续序列的数字或者没有连续序列的数字为止。
    -- 如果存在连续序列，但是不存在非连续序列，则选择连续序列第一项标记为前进，当前连续序列剩下的标记为收集资源。
    -- 如果不存在连续序列，但是存在非连续序列，则选择第一个非连续序列标记为前进，倒数第一个标记为收集资源，然后再次寻找非连续序列，
    -- 重复上述逻辑直到没有非连续序列为止。


    数字列表, 规划列表 = markActions(数字列表, seq_index) -- claude真好用
    log("规划列表", 规划列表)
    local kl_choice_delay = str2int(kl_choice_delay, 500)
    if hd_debug then exit() end

    get_tap_index = function(tap_index)
        -- 根据index获取tap位置
        -- 排除掉之前的已选择的部分
        local real_tap_index = 0
        for _, item in ipairs(数字列表) do
            if not item.is_choose then
                real_tap_index = real_tap_index + 1
            end
            if item.index == tap_index then
                数字列表[tap_index].is_choose = true
                return real_tap_index
            end
        end
    end

    for _, plan in ipairs(规划列表) do
        log("执行计划", plan)
        local tap_index = get_tap_index(plan.index)
        log("tap_index", tap_index)
        local tx, ty = scale(130 + 147 * (tap_index - 1)), scale(920)
        log("点击位置坐标", tx, ty)
        wait(function()
            tap({ tx, ty })
            if appear({ "喀兰贸易前进", "喀兰贸易收集资源" }, 0.8) then return true end
        end, 5)
        if plan.action == "forward" then
            log("位置" .. plan.index .. "的数字" .. plan.number .. ": 前进")
            wait(function()
                tap("喀兰贸易前进")
                if disappear("喀兰贸易前进", 0.5) then return true end
            end, 5)
        elseif plan.action == "collect" then
            log("位置" .. plan.index .. "的数字" .. plan.number .. ": 收集资源")
            -- 执行收集资源操作
            wait(function()
                tap("喀兰贸易收集资源")
                if disappear("喀兰贸易收集资源", 0.5) then return true end
            end, 5)
            ssleep(0.2)
            if findOne("喀兰贸易前进") then
                wait(function()
                    tap("喀兰贸易前进")
                    if disappear("喀兰贸易前进", 0.5) then return true end
                end, 5)
            end
        end
        disappear({ "喀兰贸易前进", "喀兰贸易收集资源" }, 3)
        sleep(kl_choice_delay)
    end
    appear("喀兰贸易结束回合红", 2)
    if not wait(function()
            appearTap("喀兰贸易结束回合红", 0.5)
            if not findOne("喀兰贸易结束回合红") then return true end
        end, 3) then
        log.warn("喀兰贸易结束回合点击失败")
        return
    end
    if appear("喀兰贸易结算画面", 3) then
        log("重建成功，下一局")
        wait(function()
            tap("喀兰贸易下一局")
            if appear({ "喀兰贸易活动首页进入", "喀兰贸易活动场地未开放", "喀兰贸易活动开始重建" }, 1) then
                return true
            end
        end, 15)
        return 喀兰贸易重建活动(true)
    end
    return 喀兰贸易重建活动(false)
end

markActions = function(数字列表, seq_index)
    -- 为每个item添加action字段
    for _, item in ipairs(数字列表) do
        item.action = nil -- nil表示不操作, "forward"表示前进, "collect"表示收集资源
    end

    -- 创建规划列表
    local 规划列表 = {}

    -- 辅助函数: 获取所有非连续序列的数字(is_con为false的)
    local function getNonConsecutive()
        local result = {}
        -- for _, item in ipairs(数字列表) do
        --     if not item.is_con then
        --         table.insert(result, item)
        --     end
        -- end
        local all_seq_index = {}
        for _, seq in ipairs(seq_index) do
            for _, idx in ipairs(seq) do
                all_seq_index[idx] = true
            end
        end
        for _, item in ipairs(数字列表) do
            if not all_seq_index[item.index] then
                table.insert(result, item)
            end
        end
        return result
    end

    -- 辅助函数: 获取未处理的连续序列
    local function getUnprocessedSequences()
        local result = {}
        for _, seq in ipairs(seq_index) do
            local hasUnprocessed = false
            for _, idx in ipairs(seq) do
                if 数字列表[idx].action == nil then
                    hasUnprocessed = true
                    break
                end
            end
            if hasUnprocessed then
                table.insert(result, seq)
            end
        end
        return result
    end

    while true do
        local nonConsec = getNonConsecutive()
        local unprocessedSeqs = getUnprocessedSequences()

        -- 过滤掉已经被标记的非连续项
        local availableNonConsec = {}
        for _, item in ipairs(nonConsec) do
            if item.action == nil then
                table.insert(availableNonConsec, item)
            end
        end
        log("可用非连续项", availableNonConsec)
        log("未处理连续序列", unprocessedSeqs)

        -- 情况1: 有非连续序列和连续序列
        if #availableNonConsec > 0 and #unprocessedSeqs > 0 then
            -- 选择第一个非连续序列标记为前进
            availableNonConsec[1].action = "forward"
            table.insert(规划列表, {
                index = availableNonConsec[1].index,
                number = availableNonConsec[1].number,
                action = "forward"
            })

            -- 找到连续序列的最后一项,全部标记为收集资源
            last_seq = unprocessedSeqs[#unprocessedSeqs]
            -- for _, seq in ipairs(unprocessedSeqs) do
            for _, idx in ipairs(last_seq) do
                if 数字列表[idx].action == nil then
                    数字列表[idx].action = "collect"
                    table.insert(规划列表, {
                        index = 数字列表[idx].index,
                        number = 数字列表[idx].number,
                        action = "collect"
                    })
                end
            end

            -- end

            -- 情况2: 只有连续序列,没有非连续序列
        elseif #availableNonConsec == 0 and #unprocessedSeqs > 0 then
            -- 选择第一个连续序列的第一项标记为前进
            local firstSeq = unprocessedSeqs[1]
            数字列表[firstSeq[1]].action = "forward"
            table.insert(规划列表, {
                index = 数字列表[firstSeq[1]].index,
                number = 数字列表[firstSeq[1]].number,
                action = "forward"
            })

            -- -- 当前连续序列剩下的标记为收集资源
            for i = 2, #firstSeq do
                数字列表[firstSeq[i]].action = "collect"
                table.insert(规划列表, {
                    index = 数字列表[firstSeq[i]].index,
                    number = 数字列表[firstSeq[i]].number,
                    action = "collect"
                })
            end

            -- -- 其他连续序列全部标记为收集资源
            -- for i = 2, #unprocessedSeqs do
            --     for _, idx in ipairs(unprocessedSeqs[i]) do
            --         数字列表[idx].action = "collect"
            --         table.insert(规划列表, {
            --             index = 数字列表[idx].index,
            --             number = 数字列表[idx].number,
            --             action = "collect"
            --         })
            --     end
            -- end
            -- break

            -- 情况3: 只有非连续序列,没有连续序列
        elseif #availableNonConsec > 0 and #unprocessedSeqs == 0 then
            if #availableNonConsec == 1 then
                -- 只剩一个非连续项,标记为前进
                availableNonConsec[1].action = "forward"
                table.insert(规划列表, {
                    index = availableNonConsec[1].index,
                    number = availableNonConsec[1].number,
                    action = "forward"
                })
                break
            else
                -- 第一个标记为前进
                availableNonConsec[1].action = "forward"
                table.insert(规划列表, {
                    index = availableNonConsec[1].index,
                    number = availableNonConsec[1].number,
                    action = "forward"
                })

                -- 倒数第一个标记为收集资源
                availableNonConsec[#availableNonConsec].action = "collect"
                table.insert(规划列表, {
                    index = availableNonConsec[#availableNonConsec].index,
                    number = availableNonConsec[#availableNonConsec].number,
                    action = "collect"
                })
            end

            -- 情况4: 既没有非连续也没有连续(全部处理完毕)
        else
            break
        end
    end

    return 数字列表, 规划列表
end

活动dis计算 = function()
    -- 截图
    --local scren_p = getScreenPixel(0, 0, 0, 0)

    function printRGB(color)
        local r, g, b = colorToRGB(color)
        print("col:" .. "=>" .. r .. "," .. g .. "," .. b)
    end

    local w, h, arr = getScreenPixel(0, 0, 0, 0)

    print("image size:" .. w .. "," .. h)
    local x = 847
    local y = 634
    local color = arr[y * w + (x + 1)]
    local cc = getPixelColor(x, y)
    print(color, cc)
    printRGB(cc)
    printRGB(color)
    printRGB('00B1FF')
end
