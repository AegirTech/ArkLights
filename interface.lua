-- ===========================================
--                  UI相关
-- ===========================================
all_job = {
    "邮件收取", "轮次作战", "自动培养", "访问好友",
    "基建收获", "基建换班", "制造加速", "线索交流",
    "副手换人", "信用购买", "公开招募", "任务收集",
    "限时活动", "商店搬空", "故事解锁", "森空岛签到",
}

script_layouts = { "multi_account", "gesture_capture", "extra", "debug", "main", "auto", "sss_fight" }

now_job = table.filter(all_job, function(x) return x ~= "副手换人" end)
now_job = table.filter(all_job, function(x) return true end)
multi_account_num = 30

getUIConfigPath = function(layout)
    return getWorkPath() .. '/config_' .. layout .. '.json'
end

loadOneUIConfig = function(layout)
    local config = getUIConfigPath(layout)
    if not fileExist(config) then return {} end
    -- log("load", config)
    local f = io.open(config, 'r')
    local content = f:read() or '{}'
    f:close()
    local status
    status, content = pcall(JsonDecode, content)
    if status then return content or {} end
    return {}
end

saveOneUIConfig = function(layout, content)
    if type(content) == 'table' then content = JsonEncode(content) end

    local config = getUIConfigPath(layout)
    local f = io.open(config, 'w')
    f:write(content or '{}')
    f:close()
end

-- 将UI内容转为全局变量
loadUIConfig = function(layouts)
    if not layouts then
        layouts = script_layouts
    end
    for _, layout in pairs(layouts) do
        assignGlobalVariable(loadOneUIConfig(layout))
    end
end

styleButton = function(layout)
    ui.setBackground(layout, "#fff1f3f4")
    ui.setTextColor(layout, "#ff000000")
end

addButton = function(layout, id, text, func, w, h, bg)
    id = id or randomString(32)
    ui.addButton(layout, id, text, w or -2, h or -2)
    ui.setOnClick(id, func)
    if bg then ui.setBackground(id, bg) end
    -- styleButton(id)
end

setNewRowGid = function(gid) default_row_gid = gid end

newRow = function(layout, id, align, w, h)
    -- log(173,default_row_gid)
    id = id or randomString(32)
    ui.newRow(layout, id, w or -2, h or -2, default_row_gid)
    align = align or 'left'
    if align == 'center' then ui.setGravity(id, 17) end
end

addTextView = function(layout, text, id)
    ui.addTextView(layout, id or randomString(32), text)
end

make_account_ui = function(layout, prefix)
    layout = layout or "main"
    prefix = prefix or ''
    newRow(layout)
    addTextView(layout, "作战关卡")
    ui.addEditText(layout, prefix .. "fight_ui", [[jm hd ce ls pr ap]])

    newRow(layout)
    addTextView(layout, "作战吃药")
    ui.addEditText(layout, prefix .. 'max_drug_times', "0")
    addTextView(layout, "次，吃石头")
    ui.addEditText(layout, prefix .. 'max_stone_times', "0")
    addTextView(layout, "次")

    newRow(layout)
    addTextView(layout, "信用多买")
    ui.addEditText(layout, prefix .. "high_priority_goods", "聘 土 装置 技")
    addTextView(layout, "信用少买")
    ui.addEditText(layout, prefix .. "low_priority_goods", "碳 家 急")

    newRow(layout)
    -- addTextView(layout, "商店购买黑名单")
    -- ui.addEditText(layout, prefix .. "shop_buy_black", "增补条 ")
    ui.addCheckBox(layout, prefix .. "accelerate_trading", "无人机用于贸易站", false)

    newRow(layout)
    addTextView(layout, "自动招募")
    ui.addCheckBox(layout, prefix .. "auto_recruit0", "其他", true)
    ui.addCheckBox(layout, prefix .. "auto_recruit1", "车", true)
    ui.addCheckBox(layout, prefix .. "auto_recruit4", "4", true)
    ui.addCheckBox(layout, prefix .. "auto_recruit5", "5", true)
    ui.addCheckBox(layout, prefix .. "auto_recruit6", "6", false)

    newRow(layout)
    addTextView(layout, "培养计划")
    ui.addEditText(layout, prefix .. "raise_plan_text", "", 350, -1)

    -- local max_checkbox_one_row = getScreen().width //200
    local max_checkbox_one_row = 3

    for k, v in pairs(all_job) do
        if k % max_checkbox_one_row == 1 then
            newRow(layout, prefix .. "now_job_row" .. k)
        end
        ui.addCheckBox(layout, prefix .. "now_job_ui" .. k, v,
            table.includes(now_job, v))
    end
end

show_multi_account_ui = function()
    local num = multi_account_num
    toast("正在加载多账号设置...")
    local layout = "multi_account"
    saveConfig('last_layout', layout)

    ui.newLayout(layout, ui_page_width, -2)

    make_ui_title(layout, "多账号")

    newRow(layout)
    -- ui.addButton(layout, layout .. "_start", "返回", ui_submit_width)
    -- ui.setBackground(layout .. "_start", ui_submit_color)
    -- ui.setOnClick(layout .. "_start", make_jump_ui_command(layout, "main"))

    addButton(layout, nil, "返回", make_jump_ui_command(layout, "main"), nil,
        nil)

    local cmd = {
        "ui.saveProfile('" .. getUIConfigPath("multi_account") .. "')",
        "ui.dismiss('multi_account');", "sync_ui_config('multi_account')",
    }
    ui_cmd = table.join(cmd, ';')


    -- addButton(layout, nil, "启动", make_jump_ui_command(layout, nil,
    --                                                       "crontab_enable=false;lock:remove(main_ui_lock)"),
    -- ui_small_submit_width)
    addButton(layout, nil, "定时", make_jump_ui_command(layout, nil,
            "crontab_enable_only=true;lock:remove(main_ui_lock)"),
        ui_small_submit_width)

    addButton(layout, nil, "启动并定时",
        make_jump_ui_command(layout, nil, "lock:remove(main_ui_lock)"),
        ui_small_submit_width, ui_small_submit_height, ui_submit_color)

    newRow(layout)
    addButton(layout, randomString(32), "导出帐密", make_jump_ui_command(
        layout, layout, "multi_account_config_export(1)"))
    addButton(layout, randomString(32), "导出全部", make_jump_ui_command(
        layout, layout, "multi_account_config_export()"))
    addButton(layout, randomString(32), "导入",
        make_jump_ui_command(layout, nil,
            "multi_account_config_import();show_multi_account_ui()"))

    newRow(layout)
    ui.addCheckBox(layout, layout .. '_enable', "启用账号", false)
    ui.addEditText(layout, layout .. "_choice", "1-" .. multi_account_num, -1)

    continue_account = loadConfig("continue_account", '')
    if #continue_account > 0 then
        continue_account = shrink_number_config(continue_account)
        continue_account_btn = randomString(32)
        addButton(layout, continue_account_btn, "继续账号" .. continue_account,
            "ui.setVisiblity(continue_account_btn,3);ui.setText('multi_account_choice', ui.getText('multi_account_choice') .. ' # '.. continue_account);saveConfig('continue_account','');")
    end

    newRow(layout)
    addTextView(layout, "切号前关闭")
    ui.addCheckBox(layout, "multi_account_end_closeotherapp", "其他服", true)
    ui.addCheckBox(layout, "multi_account_end_closeapp", "当前服", true)
    ui.addCheckBox(layout, "multi_account_only_login", "仅上号", false)

    -- newRow(layout)
    -- addTextView(layout, "单号最大登录次数")
    -- ui.addEditText(layout, "max_login_times", "")

    -- newRow(layout)
    -- addTextView(layout,[[启用账号]])
    -- newRow(layout)
    -- addTextView(layout,
    --             [[“启用账号”填“1-10”表示跑前10个号，填“7 10-8 7 1-3”等价于“7 10 9 8 7 1 2 3”。临时账号写在#号后，填“1-10 # 5-10”表示跑前10个号，但本次启动只跑第5到第10个。账密为空跳过，高级设置中可调。抢登处理看必读。]])
    --
    newRow(layout)

    multi_account_all_inherit_choice = map(function(x)
        return "账号" .. tostring(x):padStart(2, '0')
    end, range(1, multi_account_num))

    for i = 1, num do
        local padi = tostring(i):padStart(2, '0')
        newRow(layout)
        addTextView(layout, "账号" .. padi)
        ui.addEditText(layout, "username" .. i, "", -1)
        addTextView(layout, "密码")
        ui.addEditText(layout, "password" .. i, "", -1)

        addButton(layout, nil, "#" .. i, make_jump_ui_command(layout, nil,
                "multi_account_config_remove_once_choice('" ..
                i ..
                "');saveConfig('continue_account','');lock:remove(main_ui_lock)"),
            -2, nil, ui_submit_color)

        -- ui.addCheckBox(layout, "multi_account" .. i, "启用", true)
        newRow(layout)
        addTextView(layout, "账号" .. padi .. "在")
        -- addTextView(layout, "在")

        -- ui.addRadioGroup(layout, "server" .. i, {"官服", "B服"}, 0, -2, -2, true)

        ui.addSpinner(layout, "server" .. i, { "官服", "B服" }, 0)
        -- newRow(layout)
        -- addTextView(layout, "账号" .. padi .. "用")

        addTextView(layout, "用")
        addButton(layout, "multi_account_inherit_toggle" .. i,
            i == 1 and '单号设置' or "继承设置",
            "multi_account_inherit_toggle(" .. i .. ")")

        --
        -- addButton(layout, "multi_account_inherit_toggle" .. i, "单号设置",
        --           "multi_account_inherit_toggle(" .. i .. ")")

        -- addTextView(layout, "账号" .. padi .. "使用",multi_account_inherit)
        -- newRow(layout)
        ui.addSpinner(layout, "multi_account_inherit_spinner" .. i,
            multi_account_all_inherit_choice, 0)

        -- addTextView(layout, "设置")
        -- addButton(layout, "multi_account_inherit_toggle" .. i,
        --           "切换为独立设置",
        --           "multi_account_inherit_toggle(" .. i .. ")")
        setNewRowGid("multi_account_user_row" .. i)
        make_account_ui(layout, "multi_account_user" .. i)
        setNewRowGid()
    end

    -- local all_inherit_choice = map(function(j)
    --   return "账号" .. tostring(j):padStart(2, '0')
    -- end, table.filter(range(1, num), function(k) return k ~= i end))
    -- all_inherit_choice = table.extend({"默认"}, all_inherit_choice)
    -- ui函数必须global
    multi_account_inherit_toggle = function(i)
        local btn = "multi_account_inherit_toggle" .. i

        local txt = ui.getText(btn)
        if txt == "单号设置" then
            ui.setText(btn, "继承设置")
        elseif txt == "继承设置" then
            ui.setText(btn, "独立设置")
        else
            ui.setText(btn, "单号设置")
        end
        multi_account_inherit_render(i)
    end

    -- ui函数必须global
    multi_account_inherit_render = function(start, stop)
        local layout = "multi_account"
        start = start or 1
        stop = stop or start
        for i = start, stop do
            local btn = "multi_account_inherit_toggle" .. i
            local gid = "multi_account_user_row" .. i
            local spinner = "multi_account_inherit_spinner" .. i

            local txt = ui.getText(btn)
            -- local txt = ui.getText(btn)
            -- if txt == "默认设置" then
            --   ui.setText(btn, "使用" .. txt)
            -- elseif txt == "独立设置" then
            --   ui.setText(btn, "使用" .. txt)
            -- end

            -- fallback
            if txt == "默认设置" then
                txt = "单号设置"
                ui.setText(btn, txt)
            end

            -- ui.setText(btn,"账号30设置")
            if txt == "单号设置" then
                ui.setVisiblity(spinner, 3)
                ui.setRowVisibleByGid(layout, gid, 8)
            elseif txt == "独立设置" then
                ui.setVisiblity(spinner, 3)
                ui.setRowVisibleByGid(layout, gid, 0)
            elseif txt == "继承设置" then
                ui.setRowVisibleByGid(layout, gid, 8)
                ui.setVisiblity(spinner, 1)
            end
        end
    end

    ui.saveProfile(getUIConfigPath(layout .. '_default'))
    ui.loadProfile(getUIConfigPath(layout))
    multi_account_inherit_render(1, num)

    -- if #continue_account > 0 then
    --   if equal_number_config(ui.getText('multi_account_choice') or '',
    --                          continue_account) then
    --     ui.setVisiblity(continue_account_btn, 3)
    --   end
    -- end

    ui.show(layout, false)
end

multi_account_config_export = function(simple)
    local layout = "multi_account"
    local content = loadOneUIConfig(layout)

    content = table.filterKV(content, function(k, v)
        if #k == 32 and not k:find('_') then return false end
        return true
    end)

    if simple then
        -- 提取账密
        local account = ''
        for i = 1, multi_account_num do
            local username = content['username' .. i]:trim():map({ [' '] = '' })
            local password = content['password' .. i]:trim()
            local server = content['server' .. i]
            if type(username) == 'string' and #username > 0 and type(password) ==
                'string' and #password > 0 then
                account = account .. username .. ' ' .. password .. ' ' ..
                    (server == 1 and 'B服' or '官服') .. '\n'
            end
        end
        log(account)
        content = account
    else
        local default = loadOneUIConfig(layout .. "_default")
        content = JsonEncode(table.diff(content, default))
    end

    putClipboard(content)
    toast("多账号设置已复制" .. #content)
end

multi_account_num_get = function()
    local layout = "multi_account"
    local content = loadOneUIConfig(layout)
    local num = 0

    content = table.filterKV(content, function(k, v)
        if #k == 32 and not k:find('_') then return false end
        return true
    end)

    local account = ''
    for i = 1, 30 do
        local username = content['username' .. i] or ''
        local password = content['password' .. i] or ''
        local server = content['server' .. i] or 0
        if type(username) == 'string' and #username > 0 and type(password) ==
            'string' and #password > 0 then
            num = num + 1
        end
    end
    return num or 0
end

parse_simple_config = function(data)
    data = data or ''
    local layout = 'multi_account'
    local cur = loadOneUIConfig(layout)
    local i = multi_account_num
    while i > 0 do
        if type(cur["username" .. i]) == 'string' and #cur["username" .. i] > 0 or
            type(cur["password" .. i]) == 'string' and #cur["password" .. i] > 0 then
            break
        end
        i = i - 1
    end
    i = i + 1
    if i > multi_account_num then i = 1 end
    log('good index', i)
    local startidx = i

    -- log(2041, data)
    for _, v in pairs(data:split('\n')) do
        v = v:trim():split(' ')
        if #v >= 2 and not v[1]:startsWith('#') then
            local username = v[1]
            local password = v[2]
            local server = 0
            if type(v[3]) == 'string' and string.upper(v[3]:sub(1, 1)) == 'B' then
                server = 1
            end
            log(i, v)
            update(cur, {
                ['username' .. i] = username,
                ['password' .. i] = password,
                ['server' .. i] = server,
            }, true)
            i = i + 1
        end
    end
    local endidx = i - 1
    return JsonEncode(cur), startidx, endidx
end

multi_account_config_import = function()
    local data = getClipboard():trim()
    if not data or #data == 0 then stop('剪贴板无数据') end
    log("剪贴板数据：" .. data)
    local status, result
    status, result = pcall(JsonDecode, data)
    if not status and data:sub(1, 1) == '{' then
        stop("json格式错误(剪贴板数据不完整)")
    end
    if not status then data = parse_simple_config(data) end
    if not data or #data == 0 then stop("从剪贴板导入失败：" .. result) end
    local layout = "multi_account"
    saveOneUIConfig(layout, data)
end

multi_account_config_remove_once_choice = function(append)
    local layout = "multi_account"
    local cur = loadOneUIConfig(layout)
    local choice = cur[layout .. "_choice"] or ''
    choice = choice:commonmap()
    if choice:find('#') then choice = choice:sub(1, choice:find('#') - 1):trim() end
    if type(append) == "string" and #append > 0 then
        choice = choice .. '#' .. append
    end
    cur[layout .. "_choice"] = choice
    cur = JsonEncode(cur)
    saveOneUIConfig(layout, cur)
    -- log("choice", choice)
    return choice
end

make_jump_ui_command = function(cur, next, extra)
    -- log(getUIConfigPath(cur))
    local cmd = {
        -- 'log(ui.getData())',
        "ui.saveProfile('" .. getUIConfigPath(cur) .. "')",
        "ui.dismiss('" .. cur .. "');", next and "show_" .. next .. "_ui()" or '',
        extra or '', "sync_ui_config('" .. cur .. "')",
    }
    return table.join(cmd, ';')
end

-- 快速启动
make_continue_account_ui = function(layout)
    continue_account = loadConfig("continue_account", '')
    continue_all_account = loadConfig("continue_all_account", '')
    if #continue_account > 0 and #continue_all_account > 0 then
        newRow(layout, nil, nil, -1)
        continue_account = shrink_number_config(continue_account)
        addButton(layout, nil, "启动并定时，本次只跑剩余账号 #" ..
            continue_account, make_jump_ui_command(layout, nil,
                "multi_account_config_remove_once_choice(continue_account);saveConfig('continue_account','');lock:remove(main_ui_lock)"),
            -1, nil, ui_submit_color)
        newRow(layout, nil, nil, -1)
        continue_all_account = shrink_number_config(continue_all_account)
        addButton(layout, nil, "启动并定时，本次先跑剩余账号 #" ..
            continue_all_account, make_jump_ui_command(layout, nil,
                "multi_account_config_remove_once_choice(continue_all_account);saveConfig('continue_account','');lock:remove(main_ui_lock)"),
            -1, nil, ui_submit_color)
    end
end

make_continue_extra_ui = function(layout)
    continue_extra_mode = loadConfig("continue_extra_mode", '')
    if #continue_extra_mode > 0 then
        newRow(layout, nil, nil, -1)
        addButton(layout, nil, "继续" .. continue_extra_mode,
            make_jump_ui_command(layout, nil,
                "extra_mode=continue_extra_mode;saveConfig('continue_extra_mode','');lock:remove(main_ui_lock)"),
            -1, nil, ui_submit_color)
    end
end

make_afterjob_ui = function(layout)
    newRow(layout)
    addTextView(layout, "完成之后")
    ui.addCheckBox(layout, "end_home", "返回桌面", true)
    ui.addCheckBox(layout, "end_closeapp", "关闭游戏", false)
    ui.addCheckBox(layout, "end_screenoff", "熄屏")

    newRow(layout)
    addTextView(layout, "定时启动")
    ui.addEditText(layout, "crontab_text", "4:00 12:00 20:00")
end

make_jump_ui = function(layout)
    newRow(layout)
    addButton(layout, nil, "启动", make_jump_ui_command(layout, nil,
            "crontab_enable=false;lock:remove(main_ui_lock)"),
        ui_small_submit_width)
    addButton(layout, nil, "定时", make_jump_ui_command(layout, nil,
            "crontab_enable_only=true;lock:remove(main_ui_lock)"),
        ui_small_submit_width)
    addButton(layout, "start_and_clock", "启动并定时",
        make_jump_ui_command(layout, nil, "lock:remove(main_ui_lock)"),
        ui_small_submit_width, ui_small_submit_height, ui_submit_color)
    local max_checkbox_one_row = 3
    local readme_btn = randomString(32)

    local buttons = {
        { nil, "多账户", make_jump_ui_command(layout, 'multi_account') },
        { nil, "测试功能", make_jump_ui_command(layout, "auto") },
        { nil, "肉鸽/生息", make_jump_ui_command(layout, "extra") },
        { "quit_script", "退出", make_jump_ui_command(layout, nil, "saveConfig('Not_Restart','true');peaceExit()") },
        { nil, "保全派驻", make_jump_ui_command(layout, "sss_fight") },
        { nil, "高级设置", make_jump_ui_command(layout, "debug") },
        { "join_qq", "加入QQ群", make_jump_ui_command(layout, nil, "jump_qq_qun()") },
        { "join_channel", "QQ频道", make_jump_ui_command(layout, nil, "jump_qq_channel()") },
        { "readme_btn", "使用文档", make_jump_ui_command(layout, nil, "saveConfig('readme_already_read','1');jump_readme()") },
        { "close_app", "完全关闭脚本并禁止自启动", make_jump_ui_command(layout, nil, "close_app_r()") },
    }

    for k, v in pairs(buttons) do
        if k % max_checkbox_one_row == 1 then newRow(layout) end
        addButton(layout, v[1], v[2], v[3])
    end
end

make_ui_title = function(layout, name)
    local screen = getScreen()
    local resolution = screen.width .. 'x' .. screen.height
    name = name or ''
    local title = name .. " " .. getApkVerInt() .. "-LTS " ..
        release_date:gsub(' ', '-') .. ' ' .. resolution
    ui.setTitleText(layout, title)
end

jump_address = function(address)
    local intent = {
        action = "android.intent.action.VIEW",
        uri = address,
    }
    runIntent(intent)
    toast("正在跳转到购买地址")
    peaceExit()
end

show_main_ui = function()
    local layout = "main"

    saveConfig('last_layout', layout)
    ui.newLayout(layout, ui_page_width, -2)

    make_ui_title(layout, "明日方舟速通")

    -- make_continue_account_ui(layout)
    -- make_continue_extra_ui(layout)

    if appid_need_user_select then
        newRow(layout)
        addTextView(layout, "服务器选")
        -- ui.addRadioGroup(layout, "server", {"官服", "B服"}, 0, -2, -2, true)

        ui.addSpinner(layout, "server", { "官服", "B服" }, 0)
    end

    make_account_ui(layout)

    make_afterjob_ui(layout)

    -- 无法实现
    -- ui.addCheckBox(layout, "end_poweroff", "关机")

    -- newRow(layout)
    -- addTextView(layout,
    --             [[开基建退出提示，异形屏适配设为0。关游戏模式、全局侧边栏、深色夜间护眼模式、隐藏刘海。关懒人输入法，音量加停止脚本。有问题看必读。]])

    -- local max_checkbox_one_row = getScreen().width // 200
    make_jump_ui(layout)

    ui.loadProfile(getUIConfigPath(layout))

    -- 后处理
    if not root_mode then
        ui.setEnable("end_screenoff", false)
        ui.setEnable("end_poweroff", false)
        ui.setEnable("end_closeapp", false)
    end
    ui.show(layout, false)

    local tcolor = "#ff4169E1"
    if #loadConfig("readme_already_read", '') == 0 then
        ui.setBackground("readme_btn", tcolor)
    end
    ui.setBackground("join_qq", tcolor)
    ui.setBackground("join_channel", tcolor)
    ui.setBackground("quit_script", "#ffeb1c09")
    ui.setBackground("start_and_clock", "#ff37a652")
end

show_ad_ui = function()
    local curday = os.date('%y%m%d')
    if loadConfig("check_captcha_time", "null") == curday then return end
    local check_result = cloud.check_captcha_token()
    if check_result then
        saveConfig("check_captcha_time", curday)
    end

    if dev_mode then return end
    if multi_account_enable then
        if multi_account_num_get() < 5 then return end
    else
        if not cloud_get_task then
            return
        end
    end

    local layout = "advertisement"
    ui.newLayout(layout, ui_page_width, -2)
    ui.setTitleText(layout, "广告")
    add_text = function(text)
        newRow(layout)
        addTextView(layout, text)
    end

    add_text("===============广告===============")
    add_text("Aunly 打码平台：https://captcha.aunly.cn/")
    add_text("适用b服点选验证码，价格0.012/次，价格更便宜！")
    add_text("打码设置在 高级设置-验证码 中可以看到")

    newRow(layout)
    addButton(layout, nil, "Aunly打码平台官网", [[putClipboard("https://captcha.aunly.cn/");
    toast("已复制到剪贴板")]])
    -- addButton(layout, nil, "微店购买充值CDK",
    --     make_jump_ui_command(layout, nil, [[jump_address("https://weidian.com/item.html?itemID=7398821178")]]))

    add_text("\r\n \r\n")
    add_text("此广告的收益将用于维护脚本和服务器\r\n")
    add_text("如何关闭广告：非多账户模式下不会展示广告")
    add_text("或者已经购买使用Aunly打码平台也不会展示该广告\r\n")
    add_text("本页面将在20s后自动关闭（不会影响脚本自启动等）")

    newRow(layout)
    addButton(layout, "close_ad_b", "点此关闭广告(剩余5s)", "close_ad()")
    addButton(layout, "close_ad_c", "退出脚本", "peaceExit()")
    ui.show(layout, false)
    ad_close_time = os.time() + 5
    ad_ui_lock = lock:add()
    if not wait(function()
            sleep(1000)
            if ad_close_time - os.time() > 0 then
                ui.setButton("close_ad_b", "点此关闭广告(剩余" .. (ad_close_time - os.time()) .. "s)")
            else
                ui.setButton("close_ad_b", "点此关闭广告")
            end
            return not lock:exist(ad_ui_lock)
        end, 20) then
        close_ad()
    end
end

close_ad = function()
    if ad_close_time > os.time() then return end
    ui.dismiss("advertisement")
    lock:remove(ad_ui_lock)
end

show_debug_ui = function()
    local layout = "debug"
    debug_page_width = screen.width * 0.5
    ui.newLayout(layout, debug_page_width, -2)
    ui.setTitleText(layout, "高级设置")

    newRow(layout)
    addButton(layout, nil, "返回",
        make_jump_ui_command(layout, loadConfig("last_layout", "main")),
        nil, nil)

    newRow(layout)
    ui.addCheckBox(layout, "enable_log", "启用日志", true)
    ui.addCheckBox(layout, "write_log", "保存日志到本地", false)
    addButton(layout, "upload_log_server", "上传日志至开发者", "upload_log()")

    newRow(layout)
    addTextView(layout, "最大日志时长(分钟)")
    ui.addEditText(layout, "max_log_time", "15")
    newRow(layout)
    addTextView(layout, "最大日志行数")
    ui.addEditText(layout, "max_log_count", "1000")

    newRow(layout)
    addButton(layout, nil, "解锁", make_jump_ui_command(layout, 'gesture_capture'))

    newRow(layout)
    ui.addTabView(layout, "debug_tab")

    local debug_layout_验证码 = "debug_tab_yzm"
    ui.addTab("debug_tab", debug_layout_验证码, "验证码")

    newRow(debug_layout_验证码)
    addTextView(debug_layout_验证码, "Aunly打码用于点选验证码，平台注册&购买地址(打码每次0.012元)")

    newRow(debug_layout_验证码)
    addButton(debug_layout_验证码, nil, "Aunly打码平台官网",
        make_jump_ui_command(layout, nil, [[jump_address("https://captcha.aunly.cn/")]]))
    addButton(debug_layout_验证码, nil, "微店购买充值CDK",
        make_jump_ui_command(layout, nil, [[jump_address("https://weidian.com/item.html?itemID=7398821178")]]))

    newRow(debug_layout_验证码)
    addTextView(debug_layout_验证码, "Aunly打码服务Token")
    ui.addEditText(debug_layout_验证码, "cloud_captcha_token", "")

    newRow(debug_layout_验证码)
    addTextView(debug_layout_验证码, "==================================")

    newRow(debug_layout_验证码)
    addTextView(debug_layout_验证码, "-->滑块验证码(2个至少勾选一个!)")

    newRow(debug_layout_验证码)
    ui.addCheckBox(debug_layout_验证码, "use_local_captcha", "使用速通本地打码服务", true)
    newRow(debug_layout_验证码)
    ui.addCheckBox(debug_layout_验证码, "use_free_server_captcha", "使用免费打码服务(仅滑块验证码)", false)
    -- newRow(debug_layout_验证码)
    -- ui.addCheckBox(debug_layout_验证码, "use_jfbym", "使用云码API处理滑块验证码", false)

    newRow(debug_layout_验证码)
    addTextView(debug_layout_验证码, "==================================")

    newRow(debug_layout_验证码)
    addTextView(debug_layout_验证码, "-->点选验证码(只要填写自定义打码地址则会优先使用)")

    newRow(debug_layout_验证码)
    ui.addCheckBox(debug_layout_验证码, "use_captcha", "使用图鉴打码", true)
    newRow(debug_layout_验证码)
    addTextView(debug_layout_验证码, "图鉴用户名")
    ui.addEditText(debug_layout_验证码, "captcha_username", "")
    newRow(debug_layout_验证码)
    addTextView(debug_layout_验证码, "图鉴密码")
    ui.addEditText(debug_layout_验证码, "captcha_password", "")

    -- newRow(debug_layout_验证码)
    -- addTextView(debug_layout_验证码, "云码Token")
    -- ui.addEditText(debug_layout_验证码, "jfbym_token", "")
    -- newRow(debug_layout_验证码)
    -- ui.addCheckBox(debug_layout_验证码, "use_jfbym_dx", "使用云码处理点选", false)

    -- newRow(debug_layout_验证码)
    -- ui.addCheckBox(debug_layout_验证码, "use_free_server_captcha", "使用免费服务器解决官服滑块验证码", false)

    -- newRow(debug_layout_验证码)
    -- addTextView(debug_layout_验证码, "自定义打码地址")
    -- ui.addEditText(debug_layout_验证码, "cloud_captcha_server", "")

    newRow(debug_layout_验证码)
    addTextView(debug_layout_验证码, "自定义打码地址②")
    ui.addEditText(debug_layout_验证码, "cloud_captcha_server2", "")

    local debug_layout_云控 = "debug_tab_yk"
    ui.addTab("debug_tab", debug_layout_云控, "云控")

    newRow(debug_layout_云控)
    ui.addCheckBox(debug_layout_云控, "cloud_get_task", "审判庭接受任务", false)

    newRow(debug_layout_云控)
    addTextView(debug_layout_云控, "审判庭服务地址")
    ui.addEditText(debug_layout_云控, "cloud_server", "")

    newRow(debug_layout_云控)
    addTextView(debug_layout_云控, "审判庭设备标识")
    ui.addEditText(debug_layout_云控, "cloud_device_token", "")

    newRow(debug_layout_云控)
    ui.addCheckBox(debug_layout_云控, "log_login_to_cloud", "上报登录流程", false)

    newRow(debug_layout_云控)
    ui.addCheckBox(debug_layout_云控, "apply_remote_config", "接受远程配置更新", false)

    local debug_layout_账户 = "debug_tab_account"
    ui.addTab("debug_tab", debug_layout_账户, "账户日常")

    newRow(debug_layout_账户)
    ui.addCheckBox(debug_layout_账户, "new_change_account_plan", "新版切号方案（测试）", false)

    newRow(debug_layout_账户)
    addTextView(debug_layout_账户, "单号最大登录次数")
    ui.addEditText(debug_layout_账户, "max_login_times", "")

    newRow(debug_layout_账户)
    addTextView(debug_layout_账户, "单号15分钟内最大登录次数")
    ui.addEditText(debug_layout_账户, "max_login_times_5min", "3")

    newRow(debug_layout_账户)
    addTextView(debug_layout_账户, "单关卡最大连续代理/导航失败次数")
    ui.addEditText(debug_layout_账户, "max_fight_failed_times", "3")

    newRow(debug_layout_账户)
    addTextView(debug_layout_账户, "单号最大成功剿灭次数")
    ui.addEditText(debug_layout_账户, "max_jmfight_times", "1")

    newRow(debug_layout_账户)
    addTextView(debug_layout_账户, "最大连续作战次数(达到重启游戏)")
    ui.addEditText(debug_layout_账户, "max_fight_times", "")

    -- newRow(layout)
    -- addTextView(layout, "多点点击时长(宿舍换班选不上人)")
    -- ui.addEditText(layout, "tapall_duration", "")
    -- ui.addCheckBox(layout, "tapall_usetap", "多点点击模式", false)

    --
    -- newRow(layout)
    -- ui.addCheckBox(layout, "disable_drug_24hour",
    --                "禁用自动吃24时到期理智药", false)
    --
    -- newRow(layout)
    -- ui.addCheckBox(layout, "disable_drug_48hour",
    --                "禁用自动吃48时到期理智药", false)

    for i = 1, 7 do
        newRow(debug_layout_账户)
        local timenote = i == 1 and "“X小时”" or "“" .. (i - 1) .. "天”"
        local default = i < 3 and '99' or '1'
        addTextView(debug_layout_账户, timenote .. "理智药最多吃")
        ui.addEditText(debug_layout_账户, "max_drug_times_" .. i .. "day", default)
        addTextView(debug_layout_账户, "次")
    end

    newRow(debug_layout_账户)
    ui.addCheckBox(debug_layout_账户, "continuous_battle", "自动使用最大连战次数,会导致作战次数错乱",
        false)
    newRow(debug_layout_账户)
    ui.addCheckBox(debug_layout_账户, "zero_san_after_fight", "使用1-7清空剩余理智",
        true)

    local debug_layout_通知 = "debug_tab_notify"
    ui.addTab("debug_tab", debug_layout_通知, "通知")

    newRow(debug_layout_通知)
    addTextView(debug_layout_通知, "QQ通知账号")
    ui.addEditText(debug_layout_通知, "QQ", "")

    newRow(debug_layout_通知)
    addTextView(debug_layout_通知, "QQ通知自建服务地址")
    ui.addEditText(debug_layout_通知, "qqimagedeliver", "")

    newRow(debug_layout_通知)
    addTextView(debug_layout_通知, "pushplus通知账号(token)")
    ui.addEditText(debug_layout_通知, "pushplus_token", "")

    newRow(debug_layout_通知)
    addTextView(debug_layout_通知, "pushplus通知渠道(channel)")
    ui.addEditText(debug_layout_通知, "pushplus_channel", "")

    newRow(debug_layout_通知)
    ui.addCheckBox(debug_layout_通知, "telegram_api_curl",
        "使用curl推送通知", true)

    newRow(debug_layout_通知)
    addTextView(debug_layout_通知, "Telegram推送api(可不填)")
    ui.addEditText(debug_layout_通知, "telegram_api", "")

    newRow(debug_layout_通知)
    addTextView(debug_layout_通知, "Telegram Bot Token")
    ui.addEditText(debug_layout_通知, "telegram_token", "")

    newRow(debug_layout_通知)
    addTextView(debug_layout_通知, "Telegram chat ID")
    ui.addEditText(debug_layout_通知, "telegram_chatid", "")

    newRow(debug_layout_通知)
    addTextView(debug_layout_通知, "企业微信 webhook地址")
    ui.addEditText(debug_layout_通知, "wechat_webhook_url", "")

    newRow(debug_layout_通知)
    ui.addCheckBox(debug_layout_通知, "qqnotify_save",
        "QQ通知保存到/sdcard/包名/ (保留一周)", true)

    newRow(debug_layout_通知)
    ui.addCheckBox(debug_layout_通知, "qqnotify_quiet",
        "QQ通知设备名与账号名只显示备注", false)

    newRow(debug_layout_通知)
    ui.addCheckBox(debug_layout_通知, "qqnotify_notime", "QQ通知不显示发送时间",
        false)

    newRow(debug_layout_通知)
    ui.addCheckBox(debug_layout_通知, "qqnotify_nofailedfight",
        "QQ通知不显示代理失败信息", false)

    newRow(debug_layout_通知)
    ui.addCheckBox(debug_layout_通知, "qqnotify_nofight", "QQ通知不显示作战信息",
        false)
    newRow(debug_layout_通知)
    ui.addCheckBox(debug_layout_通知, "qqnotify_noruntime", "QQ通知不显示耗时信息",
        false)

    newRow(debug_layout_通知)
    ui.addCheckBox(debug_layout_通知, "qqnotify_bar", "QQ通知显示悬浮按钮", false)

    newRow(debug_layout_通知)
    ui.addCheckBox(debug_layout_通知, "qqnotify_beforemail",
        "QQ通知显示邮件收取前情况", false)

    newRow(debug_layout_通知)
    ui.addCheckBox(debug_layout_通知, "qqnotify_afterenter",
        "QQ通知显示基建进入后情况", false)

    newRow(debug_layout_通知)
    ui.addCheckBox(debug_layout_通知, "qqnotify_beforeleaving",
        "QQ通知显示基建退出前情况", false)

    newRow(debug_layout_通知)
    ui.addCheckBox(debug_layout_通知, "qqnotify_beforemission",
        "QQ通知显示任务收集前情况", false)

    local debug_layout_基建 = "debug_tab_base"
    ui.addTab("debug_tab", debug_layout_基建, "基建")

    newRow(debug_layout_基建)
    ui.addCheckBox(debug_layout_基建, "not_use_ocr", "基建不使用ocr（低配置或基建崩溃建议打开）", false)
    newRow(debug_layout_基建)
    addTextView(debug_layout_基建, "      勾选后无法使用红松林、多萝西等标准化组合，无法自动使用菲亚梅塔")

    newRow(debug_layout_基建)
    ui.addCheckBox(debug_layout_基建, "disable_add_friend", "好友访问不自动添加好友", false)

    newRow(debug_layout_基建)
    ui.addCheckBox(debug_layout_基建, "disable_training_shift", "基建换班忽略训练室", false)

    newRow(debug_layout_基建)
    addTextView(debug_layout_基建, "基建训练室检测延迟")
    ui.addEditText(debug_layout_基建, "training_check_time", '0.15')
    newRow(debug_layout_基建)
    addTextView(debug_layout_基建, "基建换班心情阈值")
    ui.addEditText(debug_layout_基建, "shift_min_mood", '12')

    newRow(debug_layout_基建)
    ui.addCheckBox(debug_layout_基建, "disable_dorm_shift", "基建换班禁用宿舍换班",
        false)
    newRow(debug_layout_基建)
    ui.addCheckBox(debug_layout_基建, "disable_control_shift",
        "基建换班禁用控制中枢换班", false)
    newRow(debug_layout_基建)
    ui.addCheckBox(debug_layout_基建, "disable_meeting_shift",
        "基建换班禁用会客厅换班", false)
    newRow(debug_layout_基建)
    ui.addCheckBox(debug_layout_基建, "disable_office_shift",
        "基建换班禁用办公室换班", false)
    newRow(debug_layout_基建)
    ui.addCheckBox(debug_layout_基建, "disable_manu_shift",
        "基建换班禁用制造站换班", false)
    newRow(debug_layout_基建)
    ui.addCheckBox(debug_layout_基建, "disable_trading_shift",
        "基建换班禁用贸易站换班", false)
    newRow(debug_layout_基建)
    ui.addCheckBox(debug_layout_基建, "disable_overview_shift",
        "基建换班禁用总览换班", false)
    newRow(debug_layout_基建)
    ui.addCheckBox(debug_layout_基建, "only_change_assistant_at_Monday",
        "副手换人仅在周一执行", false)

    newRow(debug_layout_基建)
    ui.addCheckBox(debug_layout_基建, "collect_beforeleaving",
        "基建离开前加一次基建收获", true)
    newRow(debug_layout_基建)
    addTextView(debug_layout_基建, "多账号仅传递线索账号(线索小号)")
    ui.addEditText(debug_layout_基建, "multi_account_disable_clue_unlock", '')

    local debug_layout_其他 = "debug_tab_other"
    ui.addTab("debug_tab", debug_layout_其他, "其他")

    newRow(debug_layout_其他)
    ui.addCheckBox(debug_layout_其他, "disable_paddleocr",
        "完全禁用飞浆OCR", false)

    newRow(debug_layout_其他)
    ui.addCheckBox(debug_layout_其他, "disable_free_draw",
        "限时活动禁用赠送寻访(每日单抽)", false)

    newRow(debug_layout_其他)
    ui.addCheckBox(debug_layout_其他, "zl_disable_lighter",
        "前瞻投资禁用升级幕后筹备", false)
    newRow(debug_layout_其他)
    ui.addCheckBox(debug_layout_其他, "zl_disable_inspect_level",
        "前瞻投资禁用检测等级源石锭", false) --有些手机cpu不能使用ocr插件

    newRow(debug_layout_其他)
    ui.addCheckBox(debug_layout_其他, "disable_strick_account_check",
        "多账号允许不填帐密(双号双服玩家)", false)

    newRow(debug_layout_其他)
    addTextView(debug_layout_其他, "多账号双休日跳过账号")
    ui.addEditText(debug_layout_其他, "multi_account_choice_weekday_only", '')

    newRow(debug_layout_其他)
    ui.addCheckBox(debug_layout_其他, "restart_on_crontab_timeout",
        "跨定时点结束后重启", true)

    newRow(debug_layout_其他)
    ui.addCheckBox(debug_layout_其他, "auto_update_gameclient",
        "自动更新游戏客户端", false)
    ui.addSpinner(debug_layout_其他, "auto_update_mode", { "方式一", "方式二" }, 1)
    ui.addSpinner(debug_layout_其他, "auto_update_game_select", { "官服和B服", "只更新官服", "只更新B服" }, 0)

    newRow(debug_layout_其他)
    ui.addCheckBox(debug_layout_其他, "delete_download_floder",
        "自动清理download文件夹", false)

    newRow(debug_layout_其他)
    addTextView(debug_layout_其他, "搬商店时间在活动")
    ui.addSpinner(debug_layout_其他, "shop_period", { "结束前", "结束后", "结束前后", "每一次" }, 0)
    addTextView(debug_layout_其他, "的第")
    ui.addSpinner(debug_layout_其他, "shop_day", { "1", "2", "3", "4", "5" }, 0)
    addTextView(debug_layout_其他, "天当天")

    newRow(debug_layout_其他)
    addTextView(debug_layout_其他, "无障碍模式关闭app方式")
    ui.addSpinner(debug_layout_其他, "app_close_way", { "不关闭", "节点强退", "懒人自带", "首页退出" }, 1)

    local debug_layout_调试 = "debug_tab_setting"
    ui.addTab("debug_tab", debug_layout_调试, "调试")

    -- newRow(layout)
    -- ui.addCheckBox(layout, "enable_keepalive",
    --                "保活模式(需关root通知与“X正在运行”通知)",
    --                false)

    -- newRow(layout)
    -- ui.addCheckBox(layout, "disable_shift_mood", "高产换班忽略心情", false)
    newRow(debug_layout_调试)
    addButton(debug_layout_调试, nil, "清除缓存", "clear_cache()")

    newRow(debug_layout_调试)
    ui.addCheckBox(debug_layout_调试, "use_system_library", "使用系统支持库", true)

    newRow(debug_layout_调试)
    addTextView(debug_layout_调试, "游戏重启间隔(s)")
    ui.addEditText(debug_layout_调试, "restart_game_interval", "900")

    newRow(debug_layout_调试)
    addTextView(debug_layout_调试, "完全重启间隔(s)")
    ui.addEditText(debug_layout_调试, "restart_package_interval", "3600")

    -- newRow(layout)
    -- ui.addCheckBox(layout, "enable_disable_lmk",
    --                "禁用LMK(测试中,专用挂机设备建议勾)", false)

    newRow(debug_layout_调试)
    ui.addCheckBox(debug_layout_调试, "disable_restart_package", "禁用完全重启", false)

    -- newRow(layout)
    -- ui.addCheckBox(layout, "disable_killacc1", "禁用重启acc进程", false)

    -- addTextView(layout, "禁用重启acc")
    -- ui.addEditText(layout, "disable_killacc", "")
    -- ui.addCheckBox(layout, "enable_killacc", "启用重启acc进程", false)

    newRow(debug_layout_调试)
    ui.addCheckBox(debug_layout_调试, "disable_oom_score_adj", "禁用oom_score_adj", false)

    newRow(debug_layout_调试)
    addTextView(debug_layout_调试, "更新源")
    ui.addEditText(debug_layout_调试, "custom_update_source", nil)

    newRow(debug_layout_调试)
    ui.addCheckBox(debug_layout_调试, "disable_hotupdate", "禁用自动更新", false)

    newRow(debug_layout_调试)
    ui.addCheckBox(debug_layout_调试, "debug_mode", "启用测试模式", false)

    newRow(debug_layout_调试)
    ui.addCheckBox(debug_layout_调试, "enable_native_tap", "启用原生点击方式", false)

    newRow(debug_layout_调试)
    ui.addCheckBox(debug_layout_调试, "enable_simultaneous_tap", "启用多点同步点击",
        false)

    newRow(debug_layout_调试)
    addTextView(debug_layout_调试, "强制分辨率")
    ui.addEditText(debug_layout_调试, "force_width", [[]])
    addTextView(debug_layout_调试, "x")
    ui.addEditText(debug_layout_调试, "force_height", [[]])

    newRow(debug_layout_调试)
    addTextView(debug_layout_调试, "点击后等待(ms)")
    ui.addEditText(debug_layout_调试, "tap_wait", "")

    newRow(debug_layout_调试)
    addTextView(debug_layout_调试, "最小点击间隔(丢包模式)(ms)")
    ui.addEditText(debug_layout_调试, "tap_interval", "")

    newRow(debug_layout_调试)
    addTextView(debug_layout_调试, "最小截屏间隔(ms)")
    ui.addEditText(debug_layout_调试, "findOne_interval", "")

    newRow(debug_layout_调试)
    ui.addEditText(debug_layout_调试, "after_require_hook", "-- after_require_hook")
    newRow(debug_layout_调试)
    ui.addEditText(debug_layout_调试, "before_account_hook", "-- before_account_hook")
    newRow(debug_layout_调试)
    ui.addEditText(debug_layout_调试, "after_all_hook", "-- after_all_hook")

    ui.loadProfile(getUIConfigPath(layout))
    ui.show(layout, false)
    ui.setButton("upload_log_server", "上传日志至开发者")
end

show_extra_ui = function()
    local layout = "extra"
    saveConfig('last_layout', layout)

    ui.newLayout(layout, ui_page_width, -2)

    make_ui_title(layout, "其他功能")

    newRow(layout)

    addButton(layout, nil, "返回", make_jump_ui_command(layout, "main"), nil,
        nil)

    newRow(layout)
    addTextView(layout, [[以下功能将沿用脚本主页设置]])

    -- newRow(layout)
    -- addButton(layout, nil, "生息演算(仅720p)",
    --     make_jump_ui_command(layout, nil,
    --         "extra_mode='生息演算沙中之火';lock:remove(main_ui_lock)"))
    -- ui.addCheckBox(layout, "sand_fire_unstop", "打满也不结束", false)

    newRow(layout)
    addTextView(layout, "=================账户设置(同步)=================")

    newRow(layout)
    ui.addCheckBox(layout, "extra_multi_account_enable", "启用多账号", false)
    ui.addEditText(layout, "extra_multi_account_choice", "")

    newRow(layout)
    ui.addCheckBox(layout, "extra_single_account_login", "启用单号登录", false)
    addTextView(layout, "账户")
    ui.addEditText(layout, "extra_single_account", "")
    addTextView(layout, "密码")
    ui.addEditText(layout, "extra_single_password", "")

    newRow(layout)
    addTextView(layout, "===========促融共竞===========")
    newRow(layout)
    addTextView(layout, "组队选择")
    ui.addSpinner(layout, "ib_grouping_method", { "参与方", "房主" }, 0)
    ui.addCheckBox(layout, "agree_cost_request_automaticlly",
        "自动同意费用请求", true)
    newRow(layout)
    addTextView(layout, "角色")
    ui.addSpinner(layout, "ib_team_role", { "躺赢狗", "角色A", "角色B" }, 0)
    ui.addCheckBox(layout, "ib_auto_team_format",
        "自动编队", true)
    --[[newRow(layout)
     ui.addCheckBox(layout, " ib_auto_like",
        "自动点赞", true) ]]
    newRow(layout)
    addTextView(layout, "房间号")
    ui.addEditText(layout, "extra_crgj_room", "")

    newRow(layout)
    addTextView(layout, "房主请在进入房间后的页面开始，仅支持组队，不能用于匹配作战")
    newRow(layout)
    addButton(layout, nil, "促融共竞开始",
        make_jump_ui_command(layout, nil,
            "extra_mode='促融共竞';extra_mode_multi=true;lock:remove(main_ui_lock)"))

    -- newRow(layout)
    -- addTextView(layout, "===========宝石铭刻===========")
    -- newRow(layout)
    -- addButton(layout, nil, "宝石铭刻——夏活小游戏(最好是1080p，平板模式)",
    --     make_jump_ui_command(layout, nil,
    --         "extra_mode='宝石铭刻活动';extra_mode_multi=true;lock:remove(main_ui_lock)"))
    -- newRow(layout)
    -- addTextView(layout, [[放牌延迟(ms)]])
    -- ui.addEditText(layout, "宝石铭刻_放牌延迟", [[100]])
    -- newRow(layout)

    newRow(layout)
    addTextView(layout, "=================肉鸽相关=================")

    newRow(layout)
    addTextView(layout, "通用选项")
    addTextView(layout, [[选第]])
    ui.addEditText(layout, "zl_best_operator", [[-1]])
    addTextView(layout, [[个近卫 开]])
    ui.addEditText(layout, "zl_skill_times", [[0]])
    addTextView(layout, [[次]])
    ui.addEditText(layout, "zl_skill_idx", [[1]])
    addTextView(layout, [[技能]])

    newRow(layout)
    ui.addCheckBox(layout, "zl_no_waste", "每8小时日常", false)
    addButton(layout, nil, "肉鸽任务开始",
        make_jump_ui_command(layout, nil,
            "extra_mode='肉鸽任务';lock:remove(main_ui_lock)"))
    newRow(layout)
    addTextView(layout, "需要刷哪个肉鸽，去勾选启用，然后点击上面的【肉鸽任务开始】")
    newRow(layout)

    newRow(layout)
    ui.addTabView(layout, "extra_tab")
    local rouge_layout_傀影 = "extra_tab_zl1"
    ui.addTab("extra_tab", rouge_layout_傀影, "傀影")
    newRow(rouge_layout_傀影)
    ui.addCheckBox(rouge_layout_傀影, "zl_ky", "启用【傀影与猩红孤钻】", false)
    -- addButton(rouge_layout_傀影, nil, "傀影与猩红孤钻",
    --     make_jump_ui_command(rouge_layout_傀影, nil,
    --         "extra_mode='战略前瞻投资';lock:remove(main_ui_lock)"))

    newRow(rouge_layout_傀影)
    ui.addCheckBox(rouge_layout_傀影, "zl_more_repertoire", "多点剧目", true)
    ui.addCheckBox(rouge_layout_傀影, "zl_more_experience", "多点蜡烛", true)
    ui.addCheckBox(rouge_layout_傀影, "zl_skip_hard", "不打驯兽", true)

    newRow(rouge_layout_傀影)
    ui.addCheckBox(rouge_layout_傀影, "zl_accept_mg", "可打敏感", true)
    ui.addCheckBox(rouge_layout_傀影, "zl_accept_yx", "可打臆想", true)
    ui.addCheckBox(rouge_layout_傀影, "zl_accept_sc", "可打生存", true)

    newRow(rouge_layout_傀影)
    ui.addCheckBox(rouge_layout_傀影, "zl_skip_coin_ky", "跳过投币", true)
    ui.addCheckBox(rouge_layout_傀影, "zl_only_coin_ky", "只是投币", false)

    newRow(rouge_layout_傀影)
    addTextView(rouge_layout_傀影, [[需求商品]])
    ui.addEditText(rouge_layout_傀影, "zl_need_goods_ky", [[]])
    addTextView(rouge_layout_傀影, [[等级]])
    ui.addEditText(rouge_layout_傀影, "zl_max_level_ky", [[max]])
    addTextView(rouge_layout_傀影, [[源石锭]])
    ui.addEditText(rouge_layout_傀影, "zl_max_coin_ky", [[]])

    local rouge_layout_水月 = "extra_tab_zl2"
    ui.addTab("extra_tab", rouge_layout_水月, "水月")
    newRow(rouge_layout_水月)
    ui.addCheckBox(rouge_layout_水月, "zl_mizuki", "启用【水月与深蓝之树】", false)
    addTextView(rouge_layout_水月, "| 已经勉强可以刷")

    newRow(rouge_layout_水月)
    ui.addCheckBox(rouge_layout_水月, "zl_skip_coin_mizuki", "跳过投币", false)
    ui.addCheckBox(rouge_layout_水月, "zl_only_coin_mizuki", "只是投币", false)

    newRow(rouge_layout_水月)
    addTextView(rouge_layout_水月, [[需求商品]])
    ui.addEditText(rouge_layout_水月, "zl_need_goods_mizuki", [[]])
    addTextView(rouge_layout_水月, [[等级]])
    ui.addEditText(rouge_layout_水月, "zl_max_level_mizuki", [[max]])
    addTextView(rouge_layout_水月, [[源石锭]])
    ui.addEditText(rouge_layout_水月, "zl_max_coin_mizuki", [[]])

    local rouge_layout_萨米 = "extra_tab_zl3"
    ui.addTab("extra_tab", rouge_layout_萨米, "萨米")
    newRow(rouge_layout_萨米)
    ui.addCheckBox(rouge_layout_萨米, "zl_sami", "启用【探索者的银淞止境】", false)
    addTextView(rouge_layout_萨米, "| 已经勉强可以刷")

    newRow(rouge_layout_萨米)
    ui.addCheckBox(rouge_layout_萨米, "zl_skip_coin_sami", "跳过投币", false)
    ui.addCheckBox(rouge_layout_萨米, "zl_only_coin_sami", "只是投币", false)

    newRow(rouge_layout_萨米)
    addTextView(rouge_layout_萨米, [[需求商品]])
    ui.addEditText(rouge_layout_萨米, "zl_need_goods_sami", [[]])
    addTextView(rouge_layout_萨米, [[等级]])
    ui.addEditText(rouge_layout_萨米, "zl_max_level_sami", [[max]])
    addTextView(rouge_layout_萨米, [[源石锭]])
    ui.addEditText(rouge_layout_萨米, "zl_max_coin_sami", [[]])

    local rouge_layout_萨卡兹 = "extra_tab_zl4"
    ui.addTab("extra_tab", rouge_layout_萨卡兹, "萨卡兹")

    newRow(rouge_layout_萨卡兹)
    ui.addCheckBox(rouge_layout_萨卡兹, "zl_skz", "启用【萨卡兹的无终奇语】", false)

    newRow(rouge_layout_萨卡兹)
    ui.addCheckBox(rouge_layout_萨卡兹, "zl_skip_coin_skz", "跳过投币", false)
    ui.addCheckBox(rouge_layout_萨卡兹, "zl_only_coin_skz", "只是投币", false)

    newRow(rouge_layout_萨卡兹)
    ui.addCheckBox(rouge_layout_萨卡兹, "zl_blueprint", "使用蓝图/后勤分队,", false)
    addTextView(rouge_layout_萨卡兹, [[分队位置]])
    ui.addEditText(rouge_layout_萨卡兹, "zl_blueprint_position", [[3]]) --蓝图分队解锁的话 大多在第三个位置

    --newRow(rouge_layout_萨卡兹)
    --ui.addCheckBox(rouge_layout_萨卡兹, "zl_skz_use_seed", "使用预设参数:", false)
    --addTextView(rouge_layout_萨卡兹, "种子ID")
    --ui.addEditText(rouge_layout_萨卡兹, "zl_skz_seed", [[]])

    newRow(rouge_layout_萨卡兹)
    addTextView(rouge_layout_萨卡兹, [[需求商品]])
    ui.addEditText(rouge_layout_萨卡兹, "zl_need_goods_skz", [[]])
    addTextView(rouge_layout_萨卡兹, [[等级]])
    ui.addEditText(rouge_layout_萨卡兹, "zl_max_level_skz", [[]])
    addTextView(rouge_layout_萨卡兹, [[源石锭]])
    ui.addEditText(rouge_layout_萨卡兹, "zl_max_coin_skz", [[]])

    -- newRow(layout)
    -- addTextView(layout, "===========肉鸽相关===========")

    -- newRow(layout)
    -- addButton(layout, nil, "傀影与猩红孤钻",
    --     make_jump_ui_command(layout, nil,
    --         "extra_mode='战略前瞻投资';lock:remove(main_ui_lock)"))
    -- addButton(layout, nil, "水月(仅720p)",
    --     make_jump_ui_command(layout, nil,
    --         "extra_mode='水月与深蓝之树';lock:remove(main_ui_lock)"))
    -- newRow(layout)
    -- addButton(layout, nil, "探索者的银淞止境(开发中)",
    --     make_jump_ui_command(layout, nil,
    --         "extra_mode='探索者的银淞止境';lock:remove(main_ui_lock)"))
    -- newRow(layout)
    -- addButton(layout, nil, "萨卡兹的无终奇语",
    --     make_jump_ui_command(layout, nil,
    --         "extra_mode='萨卡兹的无终奇语';lock:remove(main_ui_lock)"))

    -- newRow(layout)
    -- addTextView(layout,
    --             [[用于刷源石锭投资、等级(蜡烛)、藏品、剧目等。应选择常见5、6星近卫，临光1、煌2、山2、羽毛笔1、帕拉斯1、赫拉格2、史尔特尔2、银灰1、幽灵鲨1、拉狗2，更多干员测试见群精华消息。]] ..
    --   [[刷源石锭应选“观光难度”，不勾“多点蜡烛”、“跳过投币”]]
    --               [[支持凌晨4点数据更新、支持掉线抢登情况、支持每8小时做日常。支持16:9及以上分辨率，但建议16:9，否则可能选不到后勤队。]] ..
    --               [[游戏本体存在内存泄漏，因此会抽空重启。如果1小时内就出现脚本停止运行、随机界面卡住、悬浮按钮消失，应把“高级设置”中两个3600重启间隔调小(如900)。]] ..
    --               [[999源石锭刷取耗时与难度、幕后筹备无关，与是否通关三结局、网络延迟有关，双结局耗时10时14分(97个/时)，三结局耗时8时10分(122个/时)，低网络延迟+三结局耗时7时21分(135个/时)。]] ..
    --               [[如需刷等级(蜡烛)，应选普通难度，勾“多点蜡烛”与“跳过投币”。]] ..
    --               [[商品需求可填商品名称关键字，用空格隔开(如填“玩 金 骑士”)，则刷到其中任一商品就会停止并通知QQ]])

    newRow(layout)
    addTextView(layout, "=================生息演算=================")

    newRow(layout)
    addButton(layout, nil, "沙洲遗闻刷点数启动",
        make_jump_ui_command(layout, nil,
            "extra_mode='生息沙洲遗闻';extra_mode_multi=true;lock:remove(main_ui_lock)"))
    addButton(layout, nil, "沙洲遗闻自动商店购买",
        make_jump_ui_command(layout, nil,
            "extra_mode='生息沙洲遗闻商店';extra_mode_multi=true;lock:remove(main_ui_lock)"))
    newRow(layout)
    addTextView(layout, "刷点数模式")
    ui.addSpinner(layout, "sand_mode", { "标准:从4-7天开始循环(手动过1-3天)",
        "标准:从0开始,自动过1-3天,4-7天循环",
        "休养:从0升至三本198木",
        "休养:手动开完奇遇后升至三本198木",
        "休养:三本后荧光棒(普难100天+也可,不删档,3天循环)",
        "休养:持续下一天(不回档不删档)" }, 4)

    newRow(layout)
    addTextView(layout, "调试选项")
    ui.addCheckBox(layout, "sand_nostop", "不判断代币数量", false)
    ui.addCheckBox(layout, "sand_noincrease_stop", "代币不增加则停止", true)
    newRow(layout)
    ui.addCheckBox(layout, "skip_make", "跳过合成种植箱", false)

    newRow(layout)
    addTextView(layout, "=================隐秘战线=================")
    newRow(layout)
    addButton(layout, nil, "隐秘战线——慈悲灯塔",
        make_jump_ui_command(layout, nil,
            "extra_mode='隐秘战线';extra_mode_multi=true;lock:remove(main_ui_lock)"))
    addTextView(layout, "从结局")
    ui.addEditText(layout, "hidden_front_ending", "1")
    addTextView(layout, "(数字)开始")
    newRow(layout)
    ui.addCheckBox(layout, "hidden_front_award", "隐秘战线打完领取奖励", true)

    newRow(layout)
    addTextView(layout, "=================连续公招=================")
    newRow(layout)
    addButton(layout, layout .. "_recruit", "公开招募加急",
        make_jump_ui_command(layout, nil,
            "extra_mode='公开招募加急';lock:remove(main_ui_lock)"))
    addTextView(layout, [[保留标签]])
    ui.addEditText(layout, layout .. "_recruit_important_tag", [[]])
    -- newRow(layout)
    -- addTextView(layout,
    --             [[用于刷黄绿票，或刷出指定标签。使用加急券在第一个公招位反复执行“公开招募”任务，沿用脚本主页的“自动招募”设置。“自动招募”只勾“其他”时，刷出保底标签就停；只勾“其他”、“4”时，刷出保底小车、保底5星、资深就停；其余同理。如果想刷到指定标签就停，则“保留标签”填期望标签（例如填“削弱 快速复活”）。]])

    newRow(layout)
    addTextView(layout, "=================采购中心=================")

    newRow(layout)
    addButton(layout, nil, "执行采购中心商店购买",
        make_jump_ui_command(layout, nil,
            "extra_mode='采购中心商店';extra_mode_multi=true;lock:remove(main_ui_lock)"))

    ui.addTabView(layout, "extra_tab_shop")

    local shop_layout_green = "extra_tab_green"
    ui.addTab("extra_tab_shop", shop_layout_green, "绿票商店")

    newRow(shop_layout_green)
    ui.addCheckBox(shop_layout_green, "green_ticket_shop", "购买绿票商店", true)

    green_ticket_shop_good = { "寻访凭证", "合成玉", "龙门币", "家具零件", "招聘许可", "中级作战记录", "赤金", "2层寻访凭证", "2层招聘许可" }

    local max_checkbox_one_row = 4
    for k, v in pairs(green_ticket_shop_good) do
        if k == 1 or k == 5 or k == 8 then
            newRow(shop_layout_green, "green_ticket_shop_row" .. k)
        end
        ui.addCheckBox(shop_layout_green, "green_ticket_shop_" .. k, v, true)
    end

    local shop_layout_yellow = "extra_tab_yellow"
    ui.addTab("extra_tab_shop", shop_layout_yellow, "黄票商店")

    newRow(shop_layout_yellow)
    ui.addCheckBox(shop_layout_yellow, "yellow_ticket_shop", "购买黄票商店", false)

    yellow_ticket_shop_good = { "寻访凭证", "中坚寻访凭证", "模组数据块" }

    for k, v in pairs(yellow_ticket_shop_good) do
        if k % max_checkbox_one_row == 1 then
            newRow(shop_layout_yellow, "yellow_ticket_shop_row" .. k)
        end
        ui.addCheckBox(shop_layout_yellow, "yellow_ticket_shop_" .. k, v, false)
    end

    local shop_layout_red = "extra_tab_red"
    ui.addTab("extra_tab_shop", shop_layout_red, "红票商店")

    newRow(layout)
    ui.addCheckBox(shop_layout_red, "red_ticket_shop", "购买红票商店", false)

    red_ticket_shop_good = { "模组数据块", "干员(请单独勾选,买所有干员)" }

    for k, v in pairs(red_ticket_shop_good) do
        if k % max_checkbox_one_row == 1 then
            newRow(shop_layout_red, "red_ticket_shop_row" .. k)
        end
        ui.addCheckBox(shop_layout_red, "red_ticket_shop_" .. k, v, false)
    end

    -- newRow(layout)
    -- addButton(layout, layout .. "_speedrun", "每日任务速通（待修）",
    --           make_jump_ui_command(layout, nil,
    --                                "extra_mode='每日任务速通';lock:remove(main_ui_lock)"))

    -- ui.setOnClick(layout .. "_speedrun", )
    -- addButton(layout, layout .. "jump_qq_btn", "需加机器人好友",
    --           make_jump_ui_command(layout, nil, 'jump_qq()'))
    -- newRow(layout)
    -- ui.addButton(layout, layout .. "_speedrun", "每日任务速通（别用）")
    -- ui.setOnClick(layout .. "_speedrun", make_jump_ui_command(layout, nil,
    --                                                           "extra_mode='每日任务速通';lock:remove(main_ui_lock)"))
    --

    -- newRow(layout)
    -- ui.addButton(layout, layout .. "_1-12", "克洛丝单人1-12（没写）")
    -- ui.setOnClick(layout .. "_1-12", make_jump_ui_command(layout, nil,
    --                                                       "extra_mode='克洛丝单人1-12';lock:remove(main_ui_lock)"))

    ui.loadProfile(getUIConfigPath(layout))
    ui.show(layout, false)
end

sync_ui_config = function(layout)
    local ui_config_extra = loadOneUIConfig("extra")
    local ui_config_multi = loadOneUIConfig("multi_account")
    local ui_config_auto = loadOneUIConfig("auto")
    if layout == "multi_account" then
        ui_config_extra["extra_multi_account_enable"] = ui_config_multi["multi_account_enable"]
        ui_config_extra["extra_multi_account_choice"] = ui_config_multi["multi_account_choice"]
        saveOneUIConfig("extra", ui_config_extra)
    elseif layout == "extra" then
        ui_config_multi["multi_account_enable"] = ui_config_extra["extra_multi_account_enable"]
        ui_config_multi["multi_account_choice"] = ui_config_extra["extra_multi_account_choice"]
        ui_config_auto["single_account"] = ui_config_extra["extra_single_account"]
        ui_config_auto["single_password"] = ui_config_extra["extra_single_password"]
        ui_config_auto["single_account_login"] = ui_config_extra["extra_single_account_login"]
        saveOneUIConfig("multi_account", ui_config_multi)
        saveOneUIConfig("auto", ui_config_auto)
    elseif layout == "auto" then
        ui_config_extra["extra_single_account"] = ui_config_auto["single_account"]
        ui_config_extra["extra_single_password"] = ui_config_auto["single_password"]
        ui_config_extra["extra_single_account_login"] = ui_config_auto["single_account_login"]
        saveOneUIConfig("extra", ui_config_extra)
    end
end

show_auto_ui = function()
    local layout = "auto"
    saveConfig('last_layout', layout)
    ui.newLayout(layout, ui_page_width, -2)
    ui.setTitleText(layout, "测试功能")

    newRow(layout)
    addTextView(layout, "以下功能均为测试功能，如果有bug请在GitHub上提交issue反馈")

    newRow(layout)
    addTextView(layout, "仓库地址 https://github.com/AegirTech/ArkLights")

    newRow(layout)
    addButton(layout, nil, "返回",
        make_jump_ui_command(layout, "main"),
        nil, nil)

    newRow(layout)
    addTextView(layout, "--------------------单账户设置--------------------")

    newRow(layout)
    addTextView(layout, "此账户用于单账户模式下的森空岛及其他需要账密的API请求使用")

    newRow(layout)
    ui.addCheckBox(layout, "single_account_login", "启用此账户登录", false)

    newRow(layout)
    addTextView(layout, "账户")
    ui.addEditText(layout, "single_account", "")

    newRow(layout)
    addTextView(layout, "密码")
    ui.addEditText(layout, "single_password", "")

    newRow(layout)
    ui.addCheckBox(layout, "skland_use_cloud", "森空岛签到使用云端接口", false)
    newRow(layout)
    addTextView(layout, [[勾选使用云端接口请求时候会附带账户密码
不勾选此选项则所有的请求全在本地完成
部分设备（如光速虚拟机）内无法使用curl，故本地签到会失败]])

    newRow(layout)
    addTextView(layout, "--------------------自动养成相关--------------------")

    --[[
    newRow(layout)
    addTextView(layout, "接口选择")
    ui.addSpinner(layout, "auto_raise_api_select", { "森空岛", "第三方", "自定义", "本地" }, 0)

    newRow(layout)
    addTextView(layout, "自定义接口地址")
    ui.addEditText(layout, "auto_raise_api", "")

    newRow(layout)
    addTextView(layout, "官服请求Token")
    ui.addEditText(layout, "a60_token_offcial", "")
    addTextView(layout, "B服请求Token")
    ui.addEditText(layout, "a60_token_bili", "")


    --ui.addCheckBox(layout, "raise_material", "材料合成（未完成）", false)
    ]]

    newRow(layout)
    ui.addCheckBox(layout, "enable_raise_func", "启用自动养成", false)


    newRow(layout)
    newRow(layout)
    addButton(layout, nil, "开始模组任务2",
        make_jump_ui_command(layout, nil,
            "extra_mode='自动模组';extra_mode_multi=true;lock:remove(main_ui_lock)"))
    addTextView(layout, "干员名字,用空格分开")
    ui.addEditText(layout, "mz_text", "", -2, -1)

    newRow(layout)
    addButton(layout, nil, "自动合成材料(跳转加工站后启动)",
        make_jump_ui_command(layout, nil,
            "extra_mode='自动合成材料';extra_mode_multi=false;lock:remove(main_ui_lock)"))
    newRow(layout)
    addButton(layout, nil, "将当前模组升到满级",
        make_jump_ui_command(layout, nil,
            "extra_mode='自动合成模组材料';extra_mode_multi=false;lock:remove(main_ui_lock)"))
    --[[
    newRow(layout)
    ui.addCheckBox(layout, "raise_fight_plan", "作战计划(未完成)", true)
    newRow(layout)
    addButton(layout, nil, "仓库识别(未完成)", "raise_storage_dentify")]]
    newRow(layout)
    addButton(layout, nil, "自动升级潜能红点(测试)",
        make_jump_ui_command(layout, nil,
            "extra_mode='自动升级潜能';extra_mode_multi=true;lock:remove(main_ui_lock)"))
    newRow(layout)
    addButton(layout, nil, "活动商店购买(测试)",
        make_jump_ui_command(layout, nil,
            "extra_mode='活动商店购买';extra_mode_multi=true;lock:remove(main_ui_lock)"))
    newRow(layout)
    addTextView(layout, "--------------------悖论模拟相关--------------------")
    --[[
    newRow(layout)
    addTextView(layout, "悖论作业")
    ui.addEditText(layout, "bl_text", "", -2, -1)
    ]]
    newRow(layout)
    addButton(layout, nil, "悖论模拟(测试)",
        make_jump_ui_command(layout, nil,
            "extra_mode='悖论模拟';extra_mode_multi=true;lock:remove(main_ui_lock)"))

    --[[
    newRow(layout)
    addTextView(layout, "--------------------卫戍协议相关--------------------")
    newRow(layout)

    addTextView(layout, "建议ew、异拉放5本")
    newRow(layout)
    addButton(layout, nil, "卫戍协议每日",
        make_jump_ui_command(layout, nil,
            "extra_mode='卫戍协议';extra_mode_multi=true;lock:remove(main_ui_lock)"))
    addButton(layout, nil, "重复到打满",
        make_jump_ui_command(layout, nil,
            "extra_mode='重复卫戍协议';extra_mode_multi=true;lock:remove(main_ui_lock)"))
    ]]

    newRow(layout)
    addTextView(layout, "--------------------自动作战相关--------------------")

    newRow(layout)
    ui.addCheckBox(layout, "copy_homework_only", "只抄作业不打已三星关卡", false)
    newRow(layout)
    ui.addCheckBox(layout, "use_local_dictionary", "抄作业数字识别使用本地字库", false)
    newRow(layout)
    addButton(layout, "map_online", "联网更新地图包", "fetchMaps()")
    addButton(layout, nil, "本地更新地图包", "fetchLocalMaps()")
    newRow(layout)
    addTextView(layout, "将maps.zip放在/sdcard/Pictures下")

    newRow(layout)
    addTextView(layout, "--------------------辅助作战--------------------")
    newRow(layout)
    addButton(layout, nil, "辅助作战-专注失调",
        make_jump_ui_command(layout, nil,
            "extra_mode='专注失调';extra_mode_multi=false;lock:remove(main_ui_lock)"))
    newRow(layout)

    ui.loadProfile(getUIConfigPath(layout))
    ui.show(layout, false)
    ui.setButton("map_online", "联网更新地图包")
end

show_sss_fight_ui = function()
    local layout = "sss_fight"
    saveConfig('last_layout', layout)
    ui.newLayout(layout, ui_page_width, -2)
    ui.setTitleText(layout, "保全派驻")

    newRow(layout)
    addButton(layout, nil, "返回",
        make_jump_ui_command(layout, "main"),
        nil, nil)

    newRow(layout)
    addTextView(layout, "--------------------基础设置--------------------")

    newRow(layout)
    addTextView(layout, "默认在每周日打剿灭之后扫荡保全,仅在写jm/wt时候有效")
    newRow(layout)
    addTextView(layout, "保全关卡代号: 保全 保全派驻 BQ BQPZ")
    newRow(layout)
    addTextView(layout, "作战使用保全关卡代号则无视每周扫荡选项")

    newRow(layout)
    ui.addCheckBox(layout, "sss_weekend_auto", "每周末自动扫荡", true)

    newRow(layout)
    ui.addCheckBox(layout, "sss_only_complete", "仅在完成6层后扫荡", true)

    newRow(layout)
    ui.addCheckBox(layout, "sss_try_complete", "未完成6层则尝试抄作业", false)

    ui.loadProfile(getUIConfigPath(layout))
    ui.show(layout, false)
end

jump_readme = function()
    local intent = {
        action = "android.intent.action.VIEW",
        uri = "https://arkdoc.enlysure.com",
    }
    runIntent(intent)
    while true do ssleep(1) end
    peaceExit()
end

jump_qq_qun = function()
    local intent = {
        action = "android.intent.action.VIEW",
        uri = "https://qm.qq.com/q/sA0WcIoIV2",
    }
    runIntent(intent)
    toast("或手动加入QQ群629618641")
    while true do ssleep(1) end
    peaceExit()
end

jump_qq_channel = function()
    local intent = {
        action = "android.intent.action.VIEW",
        uri = "https://pd.qq.com/s/f2npvrgjb",
    }
    runIntent(intent)
    toast("频道号h800n9f23g或搜索【明日方舟速通】")
    while true do ssleep(1) end
    peaceExit()
end

jump_multi_account_json = function()
    log(getUIConfigPath("multi_account"))
    local intent = {
        action = "android.intent.action.VIEW",
        uri = "file://" .. getUIConfigPath("multi_account"),
    }
    runIntent(intent)
    peaceExit()
end

show_gesture_capture_ui = function()
    local layout = "gesture_capture"
    ui.newLayout(layout, ui_page_width, -2)
    ui.setTitleText(layout, (root_mode and '亮屏解锁' or
        " 当前无root权限，请借助其他亮屏解锁软件"))

    newRow(layout)

    addButton(layout, nil, "返回", make_jump_ui_command(layout, "main"))

    newRow(layout)
    addTextView(layout,
        [[录入解锁手势或密码，以便熄屏下自动解锁]])

    newRow(layout)
    addTextView(layout, "1. 点击")

    addButton(layout, nil, "开始录制", "gesture_capture()", nil, nil,
        ui_submit_color)
    -- ui.addButton(layout, layout .. "_start", "开始录制", ui_small_submit_width)
    -- ui.setBackground(layout .. "_start", ui_submit_color)
    -- ui.setOnClick(layout .. "_start", "")

    newRow(layout)
    addTextView(layout, "2. 观察到 熄屏+亮屏+上滑 后，手动解锁")
    newRow(layout)
    addTextView(layout, "3. 点击本界面任意文字区域")
    newRow(layout)
    addTextView(layout, "4. 选择锁屏类型")

    ui.addSpinner(layout, "unlock_mode", { "手势", "密码" }, 0)
    -- ui.addRadioGroup(layout, "unlock_mode", {"手势", "密码"}, 0, -2, -2, true)

    newRow(layout)
    addTextView(layout,
        [[5. 快速测试：启动脚本后，手动熄屏，5秒内应观察到亮屏解锁现象。]])
    newRow(layout)
    addTextView(layout, "当前手势：")
    ui.addTextView(layout, "unlock_gesture", JsonEncode({}))

    ui.loadProfile(getUIConfigPath(layout))
    ui.show(layout, false)
end

showUI = function(last_layout)
    if loadConfig("hideUIOnce", "false") ~= "false" then
        saveConfig("hideUIOnce", "false")
    else
        saveConfig("Not_Restart", "false")
        main_ui_lock = lock:add()
        local last_layout = last_layout or loadConfig("last_layout", "main")
        _G["show_" .. last_layout .. "_ui"]()
        if not wait(function()
                sleep(300)
                return not lock:exist(main_ui_lock)
            end, math.huge) then
            peaceExit()
        end
    end
end

-- eager post_util_hook
loadUIConfig({ "debug" })
