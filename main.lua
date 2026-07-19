-- predebug = true
-- prefer_bapp = true
-- zl_disable_log = true
-- enable_drug_24hour = true
-- disable_hotupdate = true
-- disable_root_mode = true
-- no_background_after_run = true
-- during_crisis_contract =true
-- debug = true
-- disable_log = true
-- unsafe_tap = true
if getPackageName() == "com.nx.nxproj.assist" then
    print("开发模式")
    dev_mode = true
    always_enable_log = true
    debug_mode = true
end
zl_enable_tap_before_drag = true
check_after_tap = true
crontab_enable = true
-- enable_simultaneous_tap = true
-- very_slow_state_check = true
default_findcolor_confidence = 95 / 100
default_auto_timeout_second = 300
-- default_max_drug_times = 9999
-- default_max_stone_times = 0
-- disable_game_up_check = true
-- skip_snapshot_service_check = true
-- need_show_console = true
-- 设成10以下时，单核机作战导航失败率高，真机基建缩放也会有问题
-- 设成1000//30时，真机同时开着B服与官服时会出现点着点着脚本就停（从基建开始做邮件）
dev_maps = false
frame_milesecond = 1000 // 30
milesecond_after_click = frame_milesecond
release_date = "07.20 01:01"
update_announcement = '最近更新: 黑流树海肉鸽（1层）'
ui_submit_color = "#ff0d47a1"
ui_cancel_color = "#ff1976d2"
ui_warn_color = "#ff33ccff"
ui_page_width = -2
ui_submit_width = -2
ui_small_submit_width = -2
ui_small_submit_height = -2
network_timeout = 300
copy_homework = false
log_time = os.time()
log_count = 0
max_log_time = 15
max_log_count = 1000
console.clearLog()
--太多地方会用到,有时候会出bug,把最后两个职业的顺序换了一下
operator_job = { "PIONEER", "WARRIOR", "TANK", "SNIPER", "CASTER", "MEDIC", "SPECIAL", "SUPPORT" }

ark_api_base = "https://arkapi.enlysure.com"
update_source = 'http://ark.aegirtech.com:8080'

log_path = "/sdcard/" .. getPackageName() .. "/log/"

if fileExist(log_path .. "log_ark.txt") then
    print("检测到旧日志文件")
    delfile(log_path .. "log_backup.txt")
    exec("cp " .. log_path .. "log_ark.txt " .. log_path .. "log_backup.txt")
    delfile(log_path .. "log_ark.txt")
end

--工具类函数
require('util')
--界面
require('interface')
--所有的点位
require("point")
--日常任务实现
require("path")
--公招标签
require("tag")
--基建
require('skill')
--云控
require("cloud")
--其他功能实现（部分不依靠懒人框架的实现内容）
require("func")
--肉鸽
require("roguelike")
--生息
require("sand")
--促融共竞
require("icebreaker")
--森空岛
require("sha2")
require("skland")
--自动作战
require("prts")
--飞桨OCR
require("exOcr")
--自动养成
require("raise")

load(after_require_hook or '')()
consoleInit()
showControlBar(true)
setControlBar() -- 非唤起游戏，不会设置按钮
setEventCallback()
hotUpdate()
check_root_mode()
detect_simulators()
unpacking_library()
enable_accessibility_service()
enable_snapshot_service()
remove_old_log()
remove_lr_ad()
detectServer()
-- predebug_hook()
backup_config()
showUI()
loadUIConfig()
restart_mode_hook()
update_state_from_debugui()
check_crontab_on_start()
cloud.startHeartBeat()

if use_local_dictionary then
    --自动战斗本地字库ocr
    require("turing")
end
if dev_mode and getPackageName() ~= "com.bilabila.arknightsspeedrun2" then
    log.debug("dev mode")
    ssleep(1)
    -- hlsh.战斗后领取()
    -- if not zl.fight_name_ocr("黑流树海") then return end
    -- toast(now_fight_name)
    -- exit()
    -- log("开始")
    -- local 地图序号 = appear({ "黑流树海地图列表1", "黑流树海地图列表2", "黑流树海地图列表3", "黑流树海地图列表4", "黑流树海地图列表5" }, 10, 0.1)
    -- log("黑流树海地图", 地图序号)

    -- if 地图序号 == "黑流树海地图列表1" or 地图序号 == "黑流树海地图列表2" then
    --     地图序号 = "1"
    -- elseif 地图序号 == "黑流树海地图列表3" or 地图序号 == "黑流树海地图列表4" then
    --     地图序号 = "2"
    -- elseif 地图序号 == "黑流树海地图列表5" then
    --     地图序号 = "3"
    -- else
    --     log.error("未识别地图序号")
    --     return
    -- end

    -- local 最优路线 = 1
    -- local 最优得分 = -100
    -- local map = {}

    -- for i = 1, 4 do
    --     local xmap = {}
    --     local 线路得分 = 0
    --     local 待ocr列表 = point["黑流树海地图" .. 地图序号 .. "线路" .. str(i) .. "OCR范围"]
    --     if not 待ocr列表 then
    --         goto continue
    --     end
    --     for j = 1, #待ocr列表 do
    --         local ocr范围 = 待ocr列表[j]
    --         local ocr结果 = ocrex_ret(ocr范围, true)
    --         log.debug("ocr范围", ocr范围, "ocr结果", ocr结果)
    --         if string.finds(ocr结果, { "作战" }) then
    --             线路得分 = 线路得分 - 10
    --             table.insert(xmap, "作战")
    --         elseif string.finds(ocr结果, { "凶" }) then
    --             线路得分 = 线路得分 - 10
    --             table.insert(xmap, "作战")
    --         elseif string.finds(ocr结果, { "诡" }) then
    --             线路得分 = 线路得分 + 5
    --             table.insert(xmap, "非作战")
    --         else
    --             table.insert(xmap, "空坐标")
    --         end
    --     end
    --     log.debug("线路", i, "得分", 线路得分)
    --     if 线路得分 > 最优得分 then
    --         最优得分 = 线路得分
    --         最优路线 = i
    --         map = shallowCopy(xmap)
    --     end
    --     ::continue::
    -- end

    -- table.insert(map, 1, "作战")
    -- if 地图序号 == "3" then
    --     table.insert(map, "非作战")
    -- end

    -- table.insert(map, "尽头")
    -- log.debug("地图", 地图序号, map, "最优路线", 最优路线, "最优得分", 最优得分)

    -- local 缩放函数 = function()
    --     wait(function()
    --         if findOne("黑流树海放大镜加号") then return true end
    --         tap("黑流树海放大镜减号")
    --         appear("黑流树海放大镜加号", 0.5)
    --         if appear("黑流树海放大镜加号", 0.5) then return true end
    --     end, 10)
    -- end
    -- 缩放函数()
    -- local 关卡坐标 = point["黑流树海地图" .. 地图序号 .. "关卡列表" .. str(最优路线)]
    -- for i = 1, #map do
    --     local node = map[i]
    --     log.debug("当前节点", i, node)
    --     tap(关卡坐标[i])
    --     if node == "作战" then
    --         log("点击作战")
    --         if not appear("黑流树海_作战页面出现", 5) then
    --             log.debug("无法进入")
    --             return
    --         end

    --         if not zl.fight_name_ocr("黑流树海") then return end
    --         toast(now_fight_name)
    --         ssleep(1)
    --         if not wait(function()
    --                 if findOne("快捷编队") then return true end
    --                 tap("黑流树海_作战出发前往")
    --             end, 5) then
    --             log.debug("无法进入")
    --             zl_repos_path('黑流树海_放弃本次探索')
    --         end

    --         log.debug()

    --         if not wait(function()
    --                 if findOne("确认招募") then return true end
    --                 tap("快捷编队")
    --             end, 10) then
    --             return
    --         end

    --         if not wait(function()
    --                 if findOne("攻击范围") and
    --                     (zl_skill_idx ~= 2 or zl_skill_idx == 2 and findOne("战略二技能")) then
    --                     --tap("近卫招募列表2") --第2个干员
    --                     --ssleep(.2)
    --                     --tap("近卫招募列表3") --第3个干员
    --                     --会把二战新招募的干员带上，如果招募了高费的导致下错人
    --                     return true
    --                 end
    --                 tap("近卫招募列表1")
    --                 if not appear("攻击范围", 1) then return end
    --                 if zl_skill_idx == 2 then
    --                     tap("战略二技能")
    --                     if not appear("战略二技能", 1) then return end
    --                 end
    --             end, 10) then
    --             return
    --         end
    --         log.debug()
    --         if not wait(function()
    --                 if not findOne("确认招募") then return true end
    --                 tap("确认招募")
    --             end, 10) then
    --             return
    --         end

    --         if not appear("快捷编队") then return end
    --         log.debug()
    --         -- 开始游戏
    --         if not wait(function()
    --                 tap("确认招募")
    --                 if not findOne("快捷编队") then return true end
    --                 -- 出现过在这儿卡死的
    --                 if not disappear("正在提交反馈至神经", network_timeout) then
    --                     restartapp(appid)
    --                     return true
    --                 end
    --             end, 10) then
    --             return
    --         end
    --         log.debug()
    --         -- 等待加载游戏界面
    --         if not wait(function()
    --                 if findOne("单选确认框") then return true end
    --                 if findOne("生命值") then return true end
    --             end, 60) then
    --             return
    --         end

    --         if not findOne("生命值") then return end

    --         -- 需要等等才能点两倍速
    --         appearTap("两倍速", 3)
    --         log.debug()
    --         -- 部署干员到关卡位置 只部署一个人的
    --         zl_deploy(point.黑流树海_作战关卡[now_fight_name], 1)

    --         appear("生命值")
    --         log.debug()
    --         local last_time_see_life = time()
    --         local skill_times = 0
    --         if not wait(function()
    --                 if findOne("返回确认界面") then tap("左取消") end
    --                 if findOne("暂停中") then
    --                     tap("开包skip")
    --                     disappear("暂停中")
    --                 end
    --                 if findOne("生命值") then last_time_see_life = time() end
    --                 -- 超过3秒没看到生命值
    --                 if time() - last_time_see_life > 5000 then
    --                     tap("战略确认")
    --                     log.debug("超过3秒没看到生命值")
    --                     return true
    --                 end
    --                 tap("开始行动1")
    --                 local p = findOne("技能亮")
    --                 local jump = false
    --                 if p and skill_times < zl_skill_times then
    --                     skill_times = skill_times + 1
    --                     tap({ p[1], p[2] + scale(200) })
    --                     --把【appear("生命值蓝", 5)】改成下面的，有时候打完会停顿一会，下面加快判断
    --                     wait(function()
    --                         if findOne("萨卡兹_成功通过") then
    --                             log('成功通过')
    --                             jump = true
    --                             return true
    --                         end
    --                         if findOne("生命值蓝") then return true end
    --                     end, 5)
    --                     if jump then return true end

    --                     ssleep(0.5)
    --                     wait(function()
    --                         tap("开技能")
    --                         if disappear("生命值蓝", 1) then return true end
    --                     end)
    --                     ssleep(1)
    --                 end
    --                 ssleep(0.5)
    --             end, 300) then
    --             log.debug()
    --             return restartapp(appid)
    --         end
    --         log.debug()
    --     elseif node == "非作战" then
    --         log("黑流树海_非作战")
    --     elseif node == "尽头" then
    --         log("黑流树海_尽头")
    --     end
    --     ssleep(20)
    -- end

    -- exit()
    -- ret = findOne("黑流树海_医疗招募卷")
    -- log(ret)
    -- ret = findOne("黑流树海_右上角希望")
    -- log(ret)
    -- ret = findAny({ "黑流树海_近卫招募卷", "黑流树海_医疗招募卷", "黑流树海_右上角希望", "黑流树海_辅助招募卷", "黑流树海_选择招募最后阶段" })
    -- log.debug(ret)

    -- 开始坐标 = { 906, 537 }
    -- 宽度 = 260
    -- -- 文字位置 = { 1347, 573, 1506, 625 }
    -- allret = {}
    -- for x = -4, 4, 1 do
    --     for y = -4, 4, 1 do
    --         local xx = 开始坐标[1] + 宽度 * x
    --         local yy = 开始坐标[2] + 宽度 * y
    --         if xx < scale(200) or yy < scale(100) or x > scale(1800) or yy > scale(900) then
    --             -- log.debug("坐标越界", xx, yy)
    --             goto continue
    --         end
    --         local 文字位置 = { xx - 60, yy + 40, xx + 60, yy + 75 }
    --         -- log.debug("坐标", xx, yy, "文字位置", 文字位置)
    --         --oc11 = ocr_ret(文字位置)
    --         oc222 = ocrex_ret(文字位置, true)
    --         if oc222 == "" then
    --             -- log.debug("坐标", xx, yy, "ocr_ret", oc11)
    --             -- log.debug("坐标", xx, yy, "ocrex_ret", oc222)
    --             goto continue
    --         end
    --         allret[#allret + 1] = { xx, yy, oc222 }
    --         ::continue::
    --     end
    -- end
    -- log("allret", allret)
    --exit()
end

load(before_account_hook or '')()

no_extra_job = {}
transfer_global_variable("multi_account_user1", "multi_account_user0")
saveConfig("continue_account", '')
saveConfig("continue_extra_mode", extra_mode or '')

-- 清理download文件夹
if delete_download_floder == true then delele_download_file() end

if auto_update_gameclient == true then auto_update_game() end

if getPackageName() == "com.bilabila.arknightsspeedrun2" then
    check_server_is_close()
    pcall(upload_device_info)
    pcall(upload_launch_info, "launch")
end

-- log("100",cloud.enabled(),cloud_task)
if cloud.getTaskEnabled() and not cloud_task then
    log("云控模式冷启动")
elseif not crontab_enable_only and (not extra_mode and true or extra_mode_multi) and
    multi_account_enable then
    -- 多帐号模式
    log("多帐号模式")
    -- 分隔临时账号设置
    multi_account_choice = multi_account_choice:commonmap()
    local temp_choice_pos = multi_account_choice:find('#')
    if temp_choice_pos then
        multi_account_config_remove_once_choice()
        multi_account_choice = multi_account_choice:sub(temp_choice_pos + 1,
            #multi_account_choice)
    end
    log("multi_account_choice", multi_account_choice)

    multi_account_choice = expand_number_config(multi_account_choice)
    for idx, i in pairs(multi_account_choice) do
        multi_account_choice_idx = idx
        account_idx = i
        -- log("type(i)",type(i))
        -- log('_G["username" .. i]',_G["username" .. i])
        username = (_G["username" .. i] or ''):map({
            ["＃"] = "#",
            ["\n"] = "",
            [" "] = "",
            ["　"] = "",
        })
        password = (_G["password" .. i] or ''):map({
            ["\n"] = "",
            [" "] = "",
            ["　"] = "",
        })
        server = _G["server" .. i] or 0
        usernote = ''
        apply_multi_account_setting(i)
        update_state_from_ui()
        if multi_account_end_closeotherapp then
            closeapp(appid == oppid and bppid or oppid)
        end
        if multi_account_end_closeapp then closeapp(appid) end

        log(account_idx, username, '*****' .. password:sub(#password, #password))
        if username:find("#") then
            usernote = username:sub(username:find('#') + 1, #username):trim()
            username = username:sub(1, username:find('#') - 1):trim()
        end
        -- log({username, usernote})
        if extra_mode then
            no_extra_job = job
            job = { extra_mode }
        end

        pcall(switch_account)

        if #username > 0 and #password > 0 and 快速切号功能状态 ~= true then
            table.insert(job, 1, "退出账号")
        end

        saveConfig("continue_account", (not temp_choice_pos and idx == 1) and '' or
            table.join(table.slice(multi_account_choice, idx), ' '))
        saveConfig("continue_all_account",
            (not temp_choice_pos and idx == 1) and '' or
            table.join(
                table.extend(table.slice(multi_account_choice, idx),
                    table.slice(multi_account_choice, 1, idx - 1)),
                ' '))

        -- 账密有一为空
        local skip_account = false
        if not (disable_strick_account_check or #username > 0 and #password > 0) then
            skip_account = true
        end

        --特殊指定不上号时间
        log("login_week_time", login_week_time)
        local login_time = expand_number_config((not login_week_time or login_week_time == "") and "1-7" or
            login_week_time)
        if not table.includes(login_time, get_day_of_week()) then
            log("不在每周上号列表，跳过")
            skip_account = true
        end

        log(job)
        if not skip_account then run(job) end
    end
    saveConfig("continue_account", '')
elseif not crontab_enable_only then
    -- 单帐号模式
    log("单帐号模式")
    transfer_global_variable("multi_account_user0")
    update_state_from_ui()
    if extra_mode then
        no_extra_job = job
        job = { extra_mode }
    end
    if #strOr(username) > 0 and #strOr(password) > 0 then
        username = username:trim()
        password = password:trim()
        table.insert(job, 1, "退出账号")
    elseif #strOr(single_account) > 0 and #strOr(single_password) > 0 then
        username = single_account
        password = single_password
        if single_account_login then
            table.insert(job, 1, "退出账号")
        end
    end

    local skip_account = false
    local login_time = expand_number_config((not login_week_time or login_week_time == "") and "1-7" or
        login_week_time)
    if not table.includes(login_time, get_day_of_week()) then
        log.warn("不在每周上号列表，跳过")
        skip_account = true
    end

    log(job)
    if not skip_account then
        run(job)
    end
    log("任务完成")
    cloud.completeTask(last_upload_img)
end

-- 完成后
if end_closeapp then
    closeapp(oppid)
    closeapp(bppid)
end
if not no_background_after_run and end_home then home() end
if end_screenoff then screenoff() end
if end_poweroff then poweroff() end

-- 等待所有QQ通知结束
wait(function() return lock.length == 0 end, 30)

-- 本地通知
vibrate(100)
playAudio('/system/media/audio/ui/Effect_Tick.ogg')

-- 云控模式
cloud.fetchSolveTask()

-- 定时任务
check_crontab()

load(after_all_hook or '')()

ssleep(.5)
peaceExit()
