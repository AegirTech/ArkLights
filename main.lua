-- predebug = true
-- always_enable_log = true
-- fake_fight = true
-- prefer_bapp = true
-- zl_disable_log = true
-- enable_drug_24hour = true
-- disable_dorm_shift=true
-- disable_manu_shift=true
-- disable_overview_shift=true
-- disable_hotupdate = true
-- disable_root_mode = true
-- no_background_after_run = true
-- during_crisis_contract =true
-- disable_communication_check=true
-- speedrun=true
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
zero_wait_click = true
check_after_tap = true
crontab_enable = true
-- enable_simultaneous_tap = true
-- auto_clean_fight=true
-- enable_dorm_check = true
-- fake_transfer= true
-- verbose_fca = true
-- no_dorm = true
-- test_some = true
-- ok_time = 1000
-- ignore_jmfight_enough_check=true
-- no_config_cache = true
-- prefer_bapp_on_android7 = true
-- debug0721 = true
-- longest_tag = true
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
release_date = "02.24 23:02"
update_announcement = '最近更新：故事集导航'
ui_submit_color = "#ff0d47a1"
ui_cancel_color = "#ff1976d2"
ui_warn_color = "#ff33ccff"
ui_page_width = -2
ui_submit_width = -2
ui_small_submit_width = -2
ui_small_submit_height = -2
network_timeout = 300
matrixOcr = ocr
copy_homework = false
log_time = os.time()
log_count = 0
max_log_time = 15
max_log_count = 1000

update_source = 'http://ark.aegirtech.com:8080'
new_script_path = getWorkPath() .. '/newscript.lr'
skill_path = getWorkPath() .. '/skill.zip'
skill_extract_path = getWorkPath() .. '/skill'

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
--init_ocr() --tessocr初始化
setEventCallback()
hotUpdate()
--fetchMaps()
check_root_mode()
detect_simulators()
unpacking_library()
enable_accessibility_service()
enable_snapshot_service()
remove_old_log()
remove_lr_ad()
detectServer()
predebug_hook()
showUI()
loadUIConfig()
applyRemoteConfig()
restart_mode_hook()
update_state_from_debugui()
check_crontab_on_start()
cloud.startHeartBeat()

if use_local_dictionary then
    --自动战斗本地字库ocr
    require("turing")
end
if debug_mode and getPackageName() ~= "com.bilabila.arknightsspeedrun2" then
    log("debug mode")
end

load(before_account_hook or '')()

no_extra_job = {}
transfer_global_variable("multi_account_user1", "multi_account_user0")
saveConfig("continue_account", '')
saveConfig("continue_extra_mode", extra_mode or '')

-- 清理download文件夹
if delete_download_floder == true then delele_download_file() end

if auto_update_gameclient == true then auto_update_game() end

-- log("100",cloud.enabled(),cloud_task)
if cloud.getTaskEnabled() and not cloud_task then
    -- 云控模式冷启动
    log("102", 102)
elseif not crontab_enable_only and (not extra_mode and true or extra_mode_multi) and
    multi_account_enable and not multi_account_only_login then
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

        switch_account()

        if 快速切号功能状态 == false then
            table.insert(job, "账户数据保存")
        end

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

        -- 双休日不上号
        if not isweekday() and table.includes(multi_account_choice_weekday_only, i) then
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
    log(job)
    run(job)
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
