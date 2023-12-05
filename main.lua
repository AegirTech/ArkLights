-- predebug = true
-- always_enable_log = true
-- test_fight = true
-- fake_fight = true
-- prefer_bapp = true
-- zl_disable_log = true
-- enable_drug_24hour = true
-- prefer_speed = true
-- disable_dorm_shift=true
-- disable_manu_shift=true
-- disable_overview_shift=true
-- disable_hotupdate = true
-- disable_root_mode = true
-- no_background_after_run = true
-- fake_recruit = true
-- debug_tag = true
-- during_crisis_contract =true
-- disable_communication_check=true
-- speedrun=true
-- debug = true
-- disable_log = true
-- unsafe_tap = true
-- zl_disable_fight_drop = true
if getPackageName() == "com.nx.nxproj.assist" then
    print("开发模式")
    dev_mode = true
    always_enable_log = true
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
-- use_zhuzhu_game = true
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
frame_milesecond = 1000 // 30
milesecond_after_click = frame_milesecond
release_date = "12.05 21:05"
ui_submit_color = "#ff0d47a1"
ui_cancel_color = "#ff1976d2"
ui_warn_color = "#ff33ccff"
ui_page_width = -2
ui_submit_width = -2
ui_small_submit_width = -2
ui_small_submit_height = -2
network_timeout = 300
matrixOcr = ocr

-- update_source = 'https://arklights.pages.dev'
-- update_source = 'https://gitee.com/bilabila/arknights/raw/master'
-- update_source_fallback = update_source

update_source = 'http://ark.aegirtech.com:8080'
new_script_path = getWorkPath() .. '/newscript.lr'
skill_path = getWorkPath() .. '/skill.zip'
skill_extract_path = getWorkPath() .. '/skill'

require('util')
require("point")
require("path")
require("tag")
require('skill')
require("fight")
require("cloud")
require("ex")

load(after_require_hook or '')()

consoleInit()
showControlBar(true)
setEventCallback()
hotUpdate()
-- fetchSkillIcon()
check_root_mode()
unpacking_library()
enable_accessibility_service()
enable_snapshot_service()
remove_old_log()
detectServer()
predebug_hook()
showUI()
loadUIConfig()
restart_mode_hook()
update_state_from_debugui()
check_crontab_on_start()
cloud.startHeartBeat()

-- debug_mode=true
if debug_mode then
    log("debug_mode")
    -- log(findOne("活动公告返回"))
    -- log(findOne("framelayout_only"))
    -- log(findOne("login"))
    -- ssleep(1)
    -- tap("login")
    -- exit()
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
    -- log("102",102)
elseif not crontab_enable_only and (not extra_mode and true or extra_mode_multi) and
    multi_account_enable then
    -- 多帐号模式

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

        -- 无密码切号方案
        if new_change_account_plan and root_mode then
            log("切号测试")
            _G.快速切号功能状态 = false
            closeapp(appid)
            if server == 0 and read_local_config("account", username .. "hyperautologin") then
                local user_token = read_local_config("account", username .. "token")
                if user_token and #user_token > 10 then
                    log("官服快速登录")
                    user_token = decodeBase64(user_token)
                    _G.快速切号功能状态 = official_set_login_user(user_token)
                end
            elseif server ~= 0 and read_local_config("account", username .. "biliautologin") then
                local userid = read_local_config("account", username .. "userid")
                if userid and #userid > 1 and bilibili_is_uid_exist(userid) then
                    log("b服快速登录")
                    log(userid)
                    _G.快速切号功能状态 = bilibili_set_login_uid(userid)
                end
            end
        end

        if 快速切号功能状态 == false then
            table.insert(job, "账户数据保存")
        end

        if #username > 0 and #password > 0 and _G.快速切号功能状态 ~= true then
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
    transfer_global_variable("multi_account_user0")
    update_state_from_ui()
    test_fight_hook()
    if extra_mode then
        no_extra_job = job
        job = { extra_mode }
    end
    if #strOr(username) > 0 and #strOr(password) > 0 then
        username = username:trim()
        password = password:trim()
        table.insert(job, 1, "退出账号")
    end
    run(job)
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
