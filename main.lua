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
release_date = "11.15 11:05"
update_announcement = '最近更新: TL活动导航'
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
--卫戍协议
require("autochess")
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
--showUI()
loadUIConfig()
restart_mode_hook()
update_state_from_debugui()
check_crontab_on_start()
cloud.startHeartBeat()

if use_local_dictionary then
    --自动战斗本地字库ocr
    TURING = require("turing")
end
if dev_mode and getPackageName() ~= "com.bilabila.arknightsspeedrun2" then
    log.debug("dev mode")
    ssleep(1) --防止启动过快下方信息影响截图
    -- local 近战职业 = { PIONEER = true, WARRIOR = true }
    -- local 远程职业 = { SNIPER = true, CASTER = true, SUPPORT = true }
    -- local 医疗职业 = { MEDIC = true }
    -- local borderOn = "3F8E7F"         --卡边框亮色=可购买
    -- local borderOff = "50706A"        --卡边框灰色=买不起
    -- local borderGold = "CE9644"       --已拥有干员的金色发光边框(实测约206,150,68),同样可购买(买它推进合成)
    -- local borderGoldBright = "E2B25A" --金光偏亮态兜底
    -- local borderSelected = "128E74"   --卡被选中待确认的边框色(18,142,116),再点一次才真正购买
    -- local borderEmpty = "454545"      --空槽位灰板色(69,69,69),比无槽位的深色背景(约27,32,34)亮
    -- local benchLimit = 8              --待部署区共10格,留2格余量
    -- local refreshLimit = 8            --每回合刷新次数上限,防止异常死循环
    -- local data = { operators = {}, items = {}, bonds = {} }
    -- local readOk, readRet = pcall(JsonDecode, readFile("autochess_data.json"))
    -- if readOk and readRet then
    --     data.operators = readRet.operators or {}
    --     data.items = readRet.items or {}
    --     for _, v in pairs(data.operators) do
    --         for bondName in pairs(v.bonds or {}) do data.bonds[bondName] = true end
    --     end
    -- end
    -- readOk, readRet = pcall(JsonDecode, readFile("character_type_list.json"))
    -- if readOk and readRet then
    --     for opName, prof in pairs(readRet) do
    --         if prof ~= "TRAP" and prof ~= "TOKEN" then
    --             local info = data.operators[opName]
    --             if info then
    --                 info.prof = prof
    --             else
    --                 data.operators[opName] = { prof = prof }
    --             end
    --         end
    --     end
    -- end
    -- --槽位(右起1-6)边框比色:亮=可购买,灰=已购/买不起,都不是=空槽
    -- local slotColor = function(slotIndex, borderColor)
    --     local slotPoint = point["卫戍协议商店槽位列表" .. slotIndex]
    --     if not slotPoint then return false end
    --     return findOneStr(slotPoint[1] .. "|" .. slotPoint[2] .. "|" .. borderColor) ~= nil
    -- end
    -- local 卫戍协议干员ocr校正 = function(name)
    --     if not name or name == "" then return name end
    --     local nameFixes = {
    --         ["野鬘"] = "野鬃",
    --         ["灰亳"] = "灰毫",
    --         ["墨键"] = "黑键",
    --         ["愧影"] = "傀影",
    --         ["狮蜴"] = "狮蝎",
    --         ["霸叶"] = "霜叶",
    --         ["翎羽羽"] = "翎羽",
    --         ["哞"] = "吽",
    --         ["哗"] = "吽",
    --         ["子"] = "孑",
    --         ["委"] = "黍",
    --         ["铜"] = "锏",
    --         ["势"] = "芬",
    --         ["纯烟艾雅法拉"] = "纯烬艾雅法拉",
    --         ["纯艾雅法拉"] = "纯烬艾雅法拉",
    --         ["缄默德克萨斯"] = "缄默德克萨斯",
    --         ["圣约送葬"] = "圣约送葬人",
    --     }
    --     if nameFixes[name] then return nameFixes[name] end
    --     --开头两个汉字相同(OCR把首字重复了)则去掉第一个,如"琴琴柳"→"琴柳"
    --     if #name >= 9 and name:sub(1, 3) == name:sub(4, 6) and name ~= "苏苏洛" then
    --         return name:sub(4)
    --     end
    --     return name
    -- end

    -- --名字匹配干员 key:先全等,再包含匹配(OCR 常掉字)
    -- local matchOperator = function(data, name)
    --     if name and data.operators[name] then return name end
    --     if name and #name >= 3 then --1个汉字=3字节
    --         for opKey in pairs(data.operators) do
    --             if #opKey >= 3 and (opKey:find(name, 1, true) or name:find(opKey, 1, true)) then
    --                 return opKey
    --             end
    --         end
    --     end
    -- end

    -- --盟约区OCR对已知盟约名:池外干员(JSON里只有职业)和JSON读不到时的兜底识别
    -- local ocrBonds = function(data, slotIndex)
    --     local bonds = {}
    --     local bondText = ocrText("卫戍协议商店盟约列表" .. slotIndex)
    --     for bondName in pairs(data.bonds) do
    --         if bondText:find(bondName, 1, true) then bonds[bondName] = true end
    --     end
    --     return bonds
    -- end
    -- local slotBuyable = function(slotIndex)
    --     --金光=已拥有同名干员,可买且推进合成;两个金色色调兜底
    --     return slotColor(slotIndex, borderOn) or slotColor(slotIndex, borderGold) or
    --         slotColor(slotIndex, borderGoldBright)
    -- end

    -- local slotHasCard = function(slotIndex)
    --     return slotBuyable(slotIndex) or slotColor(slotIndex, borderOff)
    -- end

    -- --槽位是否存在:有卡(亮/灰边框)或空槽灰板,都比"无槽位"的深色背景亮
    -- local slotExists = function(slotIndex)
    --     return slotBuyable(slotIndex) or slotColor(slotIndex, borderOff) or slotColor(slotIndex, borderEmpty)
    -- end
    -- local readCard = function(data, slotIndex)
    --     local card = {}
    --     local name = ""
    --     for _ = 1, 4 do
    --         name = 卫戍协议干员ocr校正(ocro("卫戍协议商店名称列表" .. slotIndex))
    --         if name ~= "" then break end
    --         log()
    --         ssleep(.5)
    --     end
    --     if name == "" then log.debug("识别:槽位" .. slotIndex .. "名称多次OCR为空") end
    --     card.name = name
    --     local opName = matchOperator(data, name)
    --     if opName then
    --         local info = data.operators[opName]
    --         card.name = opName
    --         card.level = info.level
    --         card.prof = info.prof
    --         card.bonds = info.bonds or ocrBonds(data, slotIndex)
    --     else
    --         card.bonds = ocrBonds(data, slotIndex)
    --     end
    --     return card
    -- end

    autochess.卫戍协议循环1()
    -- swip_up_20px = function()
    --     local x1 = scale(1110)
    --     local y1 = scale(276)
    --     local y2 = scale(145)
    --     duration = 400
    --     finger = { { point = { { x1, y1 }, { x1, y2 } }, duration = duration } }
    --     delay = 750
    -- end
    -- swip_up_20px()
    -- ssleep(100)
    exit()
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
