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
        local red1 = parse_download_url(url)
        local red2 = parse_download_url(red1)
        if auto_update_mode == 0 then
            install_game(red2)  --使用curl下载并安装
        else
            install_game2(red2) --用自带的更新
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
    if code == 302 or code == 301 then
        local redirect = headers.location
        return redirect
    else
        return url
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
    log("获取官服用户缓存")
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
    log("获取官服最后登录账户")
    local data = official_get_user_cache()
    data = data:gsub('&quot;', '"')
    data = JsonDecode(data)
    data = JsonEncode({ data[1] })
    data = data:gsub('"', '&quot;')
    return data
end

clear_fight_auto_battle = function()
    if not root_mode then return end
    local xmlname = getWorkPath() .. "/playerprefs.xml"
    exec2(string.format(
        [[su root sh -c "cp '/data/user/0/com.hypergryph.arknights/shared_prefs/com.hypergryph.arknights.v2.playerprefs.xml' '%s'"]],
        xmlname))
    setFilePremission(xmlname, nil)
    local file = io.open(xmlname, "r+")
    local xml = file:read("*a")
    local pattern = "<[^>]+name=\"%d+%%23key_mulitple_battle_times_[^\"]+\"[^>]*/>"
    local cleaned_xml = xml:gsub(pattern, "")
    file:seek("set", 0)
    file:write(cleaned_xml)
    file:close()
    exec2(string.format(
        [[su root sh -c "cp '%s' '/data/user/0/com.hypergryph.arknights/shared_prefs/com.hypergryph.arknights.v2.playerprefs.xml'"]],
        xmlname))
    log("清除连战历史记录完成")
end

-- 设置官服登录账户
official_set_login_user = function(data)
    local data = data or ""
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
save_local_config = function()
    local filePath = getWorkPath() .. "/account_data.json"
    local file = io.open(filePath, "w")
    file:write(JsonEncode(account_data))
    file:close()
end

-- 初始化账户配置
read_local_config = function()
    local filePath = getWorkPath() .. "/account_data.json"
    local file = io.open(filePath, "r")
    if file then
        local json = file:read("*a")
        local status
        status, account_data = pcall(JsonDecode, json)
        if not status then
            account_data = {}
            file:write("{}")
        end
        file:close()
        return
    else
        file = io.open(filePath, "w")
        file:write(JsonEncode(account_data))
        file:close()
        return
    end
end

account_data = {}
read_local_config()

switch_account = function()
    -- 无密码切号方案
    log("switch_account")
    if new_change_account_plan and root_mode and account_data[username] then
        log("切号测试")
        _G.快速切号功能状态 = false
        closeapp(appid)
        if server == 0 and account_data[username]["hyper"] then
            local user_token = account_data[username]["token"]
            if user_token and #user_token > 10 then
                log("官服快速登录")
                user_token = decodeBase64(user_token)
                _G.快速切号功能状态 = official_set_login_user(user_token)
            end
        elseif server ~= 0 and account_data[username]["bili"] then
            local userid = account_data[username]["userid"]
            if userid and #userid > 1 and bilibili_is_uid_exist(userid) then
                log("b服快速登录")
                log(userid)
                _G.快速切号功能状态 = bilibili_set_login_uid(userid)
            end
        end
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
        if type(postData) == "table" then
            for k, v in pairs(postData) do
                local data = string.format("%s=%s", k, v)
                curlCommand = string.format("%s -d '%s'", curlCommand, data)
            end
        elseif type(postData) == "string" then
            curlCommand = string.format("%s -d '%s'", curlCommand, postData)
        end
    end
    timeout = timeout or 5
    curlCommand = string.format("%s -m %s", curlCommand, timeout)
    if arguments then
        curlCommand = string.format("%s %s", curlCommand, arguments)
    end
    if string.find(curlCommand, " -F ") then
        curlCommand = string.gsub(curlCommand, " %-d ", " -F ")
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

gen_ua = function()
    local UA = "Arklights/" .. getApkVerInt() .. " " .. release_date
    local headers = ""
    if cloud_get_task then
        headers = [[Content-Type: application/json
            Type: cloud
            Cloud_url: {SERVER}
            User-Agent: {UA}
            Authorization: Bearer {CAPTCHATOKEN}]]
        headers = string.gsub(headers, "{SERVER}", cloud_server)
    elseif multi_account_enable then
        headers = [[Content-Type: application/json
            Type: multi_account
            User-Agent: {UA}
            Authorization: Bearer {CAPTCHATOKEN}]]
    else
        headers = [[Content-Type: application/json
            Type: single
            User-Agent: {UA}
            Authorization: Bearer {CAPTCHATOKEN}]]
    end
    headers = string.gsub(headers, "{APKVERSION}", getApkVerInt())
    headers = string.gsub(headers, "{CAPTCHATOKEN}", cloud.captchaToken)
    headers = string.gsub(headers, "{UA}", UA)
    return headers
end

getCaptchaBox = function(retry)
    retry = retry or 0
    if retry > 3 then return end
    local box = { l = 0, t = 0, r = 0, b = 0 }
    local bx = find_color(nil, "5381FD", 0, 0.95)
    if not bx then return end
    box.l, box.t = bx[1], bx[2]
    bx = find_color(nil, "5381FD", 4, 0.95)
    if not bx then return end
    box.r = bx[1]
    bx = find_color(nil, "5381FD", 3, 0.95)
    if not bx then return end
    box.b = bx[2] - 3
    log("bbox", box)
    local notb = false
    for y = box.b, box.t, -1 do
        if cmpColor(bx[1], y, "FFFFFF", 0.96) == 1 then
            notb = true
        end
        if notb and cmpColor(bx[1], y, "FFFFFF", 0.96) == 0 then
            box.b = y
            box.t = y - max(scale(351), 300)
            box.l, box.r = box.l + scale(35), box.r - scale(35)
            break
        end
    end
    if box.b - box.t < max(scale(351), 300) - 20 then
        log("box find failed", box)
        ssleep(0.5)
        return getCaptchaBox(retry + 1)
    end

    if box.r - box.l > scale(1600) or box.r - box.l < scale(200) then
        log("滑块验证框 failed2", box)
        ssleep(2)
        return getCaptchaBox(retry + 1)
    end

    local total_pixels = (box.r - box.l) * (box.b - box.t)
    local white_pixels = 0
    for x = box.l, box.r do
        for y = box.t, box.b do
            if cmpColor(x, y, "FFFFFF", 0.96) == 1 then
                white_pixels = white_pixels + 1
            end
        end
    end
    local white_ratio = white_pixels / total_pixels
    log("滑块验证框白色像素比例", white_ratio, "总像素", total_pixels, "白色像素", white_pixels)
    if white_ratio > 0.35 then
        ssleep(1.5)
        return getCaptchaBox(retry + 1)
    end

    log("cap box", box)
    return box
end

getChoiceBox = function(retry)
    local retry = retry or 0
    if retry > 3 then return end
    local box = { l = 0, t = 0, r = 0, b = 0 }
    local bx = find_color(nil, "5381FD", 0)
    log(1)
    if not bx then return end
    box.l = bx[1]
    box.t = bx[2]
    bx = find_color(nil, "5381FD", 4)
    log(2)
    if not bx then return end
    box.r = bx[1]
    bx = find_color(nil, "B2C2EE", 3)
    log(3)
    if not bx then return end
    box.b = bx[2] - 5
    log("点选验证框2", box)
    if box.b - box.t < scale(200) then
        log("点选验证框 failed", box)
        ssleep(1)
        return getChoiceBox(retry + 1)
    end
    if box.r - box.l > scale(1600) or box.r - box.l < scale(200) then
        log("点选验证框 failed2", box)
        ssleep(2)
        return getChoiceBox(retry + 1)
    end
    log("点选验证框", box)
    return box
end

-- 滑块验证码/官服点选 处理判断
trySolveSlipCaptcha = function(retry)
    local retry = retry or 1
    ssleep(1.5) -- 等待验证码出图
    if not findAny({ "captcha", "滑块验证节点", "官服点选验证节点", "滑块验证节点新720" }) then return end
    log("等待验证码出图")
    is_old_slip = false
    if findOne("滑块验证节点新") or findOne("滑块验证节点新720") then
        log("find 滑块验证节点新")
        local box = getCaptchaBox()
        log(box)
        local choices = { 1, 3, 2 }
        for _, choice in ipairs(choices) do
            local ret = SolveSlipCaptcha(box, choice)
            if ret then break end
            ssleep(0.5)
        end
    elseif findOne("官服点选验证节点") or findOne("官服点选验证节点") then
        log("find 官服点选验证节点")
        ssleep(0.2)
        official_choice = true
        local choices = { 3, 4, 1 }
        local bbox = getChoiceBox()
        log("点选验证框", bbox)
        for _, choice in ipairs(choices) do
            local ret = trySolvePointSelectionCapture(bbox, choice)
            ssleep(0.5)
            if findOne("官服点选验证确认720") or findOne("官服点选验证确定按钮") then
                log("点选确认按钮 find")
                break
            end
            if ret and findOne("B服刷新验证") then
                tap("B服刷新验证")
                ssleep(1.5)
            end
            ssleep(3)
        end
        official_choice = false
        wait(function()
            if not findAny({ "captcha", "官服点选验证确认720", "官服点选验证节点", "官服点选验证确定按钮" }) then return true end
            local fo = findAny({ "官服点选验证确认720", "官服点选验证确定按钮" })
            log("find 官服点选验证确认2 ", fo)
            tap(fo)
            ssleep(0.5)
        end, 10)
    elseif findOne("滑块验证节点") then -- 旧版滑块->b服
        if findOne("官服点选验证节点") then
            ssleep(0.5)
            return
        end
        local box = findOne("滑块验证节点")
        log("find 旧版滑块box", box)
        is_old_slip = true
        if not box then return end
        box = box.bounds
        if retry > 1 then
            SolveSlipCaptcha(box, 2)
        else
            SolveSlipCaptcha(box, 1)
        end
    end
    log("验证码处理完毕，等待游戏")
    if not appear("realgame", 5) then
        jfbym_report()
        if retry < 4 then
            tap("登录")
            ssleep(0.2)
            trySolveSlipCaptcha(retry + 1)
        end
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

-- 滑块验证码打码
SolveSlipCaptcha = function(rect, p_type)
    if not rect then return end

    local p_type = p_type or 1
    if (p_type == 1 and not use_free_server_captcha) or (p_type == 2 and not jfbym_token) or (p_type == 3 and not cloud_captcha_token) then return end
    local img = getWorkPath() .. "/captcha_slip.jpg"
    snapShot(img, rect.l, rect.t, rect.r, rect.b)
    local ret, distance
    if p_type == 1 then
        local param = "img=" .. encodeUrl(base64(img))
        log("免费服务器准备发送")
        ret = httpPost("http://175.178.58.160:8899/yolo_new/", param)
        local status, data = pcall(JsonDecode, ret)
        if not status then return end
        distance = str2int(data.target[1].distance, 0)
        distance = distance - scale(17)
    elseif p_type == 2 then
        local data = {
            token = jfbym_token,
            type = "22222",
            image = base64(img),
            developer_tag = "1fd49a52277365a95b785710e9fb54c9",
        }
        ret = httpPost("http://api.jfbym.com/api/YmServer/customApi", JsonEncode(data), 30,
            "Content-Type: application/json;charset=UTF-8")
        local status, data = pcall(JsonDecode, ret)
        data = data or {}
        if get(data, "code") ~= 10000 then return end
        distance = tonumber(get(data, "data", "data")) or 0
        distance = distance - scale(18)
    elseif p_type == 3 then
        -- UA/数据生成
        local postdata = [[{"image_base64": "]] .. base64(img) .. [["}]]
        local headers = gen_ua()

        local res, code = httpPost(cloud.captchaServer .. "/captcha/recognize", postdata, 30, headers)
        log(res, code)
        if code == 200 then
            local status, data = pcall(JsonDecode, res)
            if data.code == 0 then
                distance = tonumber(data.data.result.slider_distance) or 0
            else
                log("Aunly打码失败", data.msg)
                return false
            end
        end
        distance = distance - scale(20)
    end
    if distance < 1 then return false end

    local sx, sy
    if is_old_slip then
        distance = distance + scale(4)
        sx, sy = scale(702), scale(686)
    else
        tap({ scale(964), scale(805) })
        sx, sy = scale(750), scale(740)
    end
    -- 用于模拟滑动轨迹
    gesture({
        {
            point = {
                { sx,                                        sy }, { sx + distance, sy },
                { sx + distance + scale(math.random(5, 10)), sy - scale(math.random(80, 120)) },
                { sx + distance + scale(math.random(3, 10)), sy },
                { sx + distance + scale(math.random(5, 10)), sy - scale(math.random(80, 150)) },
                { sx + distance + scale(math.random(3, 10)), sy },
                { sx + distance - scale(math.random(3, 10)), sy - scale(math.random(80, 120)) },
                { sx + distance - scale(math.random(5, 10)), sy },
                { sx + distance - scale(math.random(5, 10)), sy - scale(math.random(80, 150)) },
                { sx + distance - scale(math.random(3, 10)), sy }, { sx + distance, sy - scale(math.random(80, 150)) },
                { sx + distance, sy }, { sx + distance, sy - scale(math.random(80, 150)) },
                { sx + distance, sy }, { sx + distance, sy - scale(math.random(80, 150)) },
                { sx + distance, sy },
            },
            start = 0,
            duration = 1000,
        },
    })
    ssleep(1.5) -- 等待验证码关闭或者重试
    return true
end

-- 官服/b服选点验证码打码
trySolvePointSelectionCapture = function(rect, p_type)
    local p_type = p_type or 1
    log("choice", type, rect)
    if not rect then return end
    local img = getWorkPath() .. "/capture.jpg"
    snapShot(img, rect.l, rect.t, rect.r, rect.b)
    local ans = nil
    if p_type == 1 then -- 图鉴
        log("B服安全验证流程", "正在使用图鉴")
        if not use_captcha then return end
        if not captcha_username or not captcha_password then
            log("未配置图鉴打码，跳过")
            choice_map_jump[p_type] = true
            return
        end
        local data = {
            username = captcha_username,
            password = captcha_password,
            typeid = "27",
            image = base64(img),
        }
        local res, code = httpPost("http://api.ttshitu.com/predict", JsonEncode(data),
            30, "Content-Type: application/json;charset=UTF-8")
        log("识别结果", res)
        if code == 200 then
            local status, data = pcall(JsonDecode, res)
            data = data or {}
            ttshitu_last_id = get(data, "data", "id") or ""
            local success = get(data, "success") or false
            if not success then return end
            ans = get(data, "data", "result") or ""
        end
    elseif p_type == 3 then
        if #cloud.captchaToken < 10 then
            log("未配置aunly打码，跳过")
            choice_map_jump[p_type] = true
            return
        end
        log("B服安全验证流程", "正在使用Aunly")
        if cloud.captcha(rect) then
            log(12015, "Aunly打码成功")
            return true
        else
            log(12016, "Aunly打码失败")
            return false
        end
    elseif p_type == 4 then
        log("B服安全验证流程", "正在使用自选打码")
        if cloud.captchaSecond(rect) then
            return true
        else
            if type(cloud_captcha_server2) ~= "string" or #cloud_captcha_server2 < 10 then
                log("未配置自选打码，跳过")
                choice_map_jump[p_type] = true
            end
            return false
        end
    end
    log("ans", ans)
    if not ans then return end
    for coord in string.gmatch(ans, "%d+,%d+") do
        local x, y = string.match(coord, "(%d+),(%d+)")
        x = x or 0
        y = y or 0
        local ans_p = { rect.l + x, rect.t + y }
        tap(ans_p)
        ssleep(0.2)
        if official_choice then
            ssleep(0.5)
        end
    end
    return true
end

ttshitu_report = function()
    if not ttshitu_last_id then return end
    local data = { id = ttshitu_last_id }
    local ret, code = httpPost("http://api.ttshitu.com/reporterror.json",
        JsonEncode(data), 30,
        "Content-Type: application/json;charset=UTF-8")
    log(ret, code)
    ttshitu_last_id = nil
end

jfbym_report = function()
    if not unique_code then return end
    local data = { uniqueCode = unique_code, token = jfbym_token }
    local ret, code = httpPost("http://api.jfbym.com/api/YmServer/refundApi",
        JsonEncode(data), 30,
        "Content-Type: application/json;charset=UTF-8")
    log(ret, code)
    unique_code = nil
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

宝石铭刻 = {}
宝石铭刻.摆放手牌到工作台 = function()
    log('滑动')
    local g6 = { scale(1336), scale(501) } --第六个工作台
    local p = {}
    if 手牌数量 == 4 then
        p = {
            { scale(700), scale(875) }, { scale(766), scale(850) },
            { scale(766), scale(850) }, { scale(971), scale(850) }
        }
        --elseif 手牌数量 ==3 then
        --elseif 手牌数量 == 2 then
    else
        p = { --手牌位置，没有考虑顺序，就随便取的
            { scale(838), scale(904) }, { scale(900), scale(925) },
            { scale(900), scale(925) }, { scale(900), scale(925) },
            { scale(900), scale(925) }
        }
    end

    if 当前课程序号 == 2 and 当前轮数 == 3 then --特殊关卡替换卡牌出场顺序
        log('第二课 第三轮特殊摆放')
        p = {
            { scale(700), scale(875) }, { scale(766), scale(850) },
            { scale(766), scale(850) }
        }
    end

    for _, v in ipairs(p) do
        gesture({
            {
                point = { v, g6 },
                start = 0,
                duration = 200,
            },
        })
        ssleep(.5)
    end

    wait(function()
        tap('宝石铭刻_开始铭刻')
        if not findOne("宝石铭刻_开始铭刻") then return true end
    end, 10)
end

detect_simulators = function()
    local simulators_list = {
        雷电模拟器 = "com.android.googleinstaller", -- 雷电判断一下自带的谷歌安装器com.android.googleinstaller 雷电游戏中心com.android.flysilkworm
        Genymotion = "com.genymotion.genymotion",
        mumu = "com.mumu.launcher",
        bluestacks = "com.bluestacks.appmart",
        vmos = "com.vmos.pro.intent",
        光速 = "com.thirdparty.superuser",
        逍遥 = "com.microvirt.launcher",
        夜神 = { "com.bignox.launcher", "com.bignox.app.noxservice" },
        supersu = "eu.chainfire.supersu", -- 用来判断一些云手机
        xposed = "de.robv.android.xposed.installer",
    }
    local ret = exec('su root sh -c "pm list packages"')
    if type(ret) == "string" and #ret > 2 then
        all_apps = {}
        for app in ret:gmatch("package:(.-)\n") do
            table.insert(all_apps, app)
        end
    end

    local 设备 = "真机"
    for k, v in pairs(simulators_list) do
        local apps = type(v) == "table" and v or { v }
        for _, app in ipairs(apps) do
            if isAppInstalled(app) then
                设备 = k
                break
            end
        end
        if 设备 ~= "真机" then break end
    end

    设备 = (设备 == "xposed" or 设备 == "supersu") and "云手机" or 设备
    console.println(1, "环境检测：" .. 设备)
    if 设备 == "mumu" then
        console.println(3, "如果出现任何问题，请更换雷电模拟器，不推荐使用Mumu。")
    end
    return 设备
end

upload_log = function()
    if not write_log_local then
        ui.setButton("upload_log_server", "请先勾选保存日志到本地")
        return
    end
    ui.setButton("upload_log_server", "上传日志中，请稍后")
    local url = ark_api_base .. "/statistic/log?verify=arklights&device_id=test"
    local log_path = log_path .. "log_backup.txt"
    local ret = uploadFile(url, log_path)
    -- log(ret)
    if type(ret) == "string" and #ret == 6 then
        console.println(3, "上传日志成功，日志编号：" .. ret)
        ui.setButton("upload_log_server", "上传日志成功，编号" .. ret .. " 请截图或复制给开发者")
        return true
    end
end

copy_file_s = function(src, dest)
    local src_file = io.open(src, "rb")
    if not src_file then
        log("无法打开源文件: " .. src)
        return
    end

    local dest_file = io.open(dest, "wb")
    if not dest_file then
        src_file:close()
        log("无法打开目标文件: " .. dest)
        return
    end

    local block_size = 1024 -- 每次读取的块大小
    while true do
        local block = src_file:read(block_size)
        if not block then break end
        dest_file:write(block)
    end

    src_file:close()
    dest_file:close()
end

clear_cache = function()
    delfile(getWorkPath() .. "/account_data.json")
    delfile(getWorkPath() .. "/HypergryphSdkPreferences.xml")
    delfile("/storage/emulated/0/" .. package)
    toast("清除缓存成功")
end

backup_config = function()
    local backup_path = "/sdcard/" .. getPackageName() .. "/backup/"
    local config_path = getWorkPath() .. "/"
    mkdir(backup_path)

    local source_path, dest_path
    if fileExist(config_path .. "config_main.json") then
        log("开始备份配置")
        source_path, dest_path = config_path, backup_path
    elseif fileExist(backup_path .. "config_main.json") then
        toast("自动恢复旧配置")
        source_path, dest_path = backup_path, config_path
    else
        return
    end

    for _, layout in pairs(script_layouts) do
        local c_path = source_path .. "config_" .. layout .. ".json"
        local d_path = dest_path .. "config_" .. layout .. ".json"
        if fileExist(c_path) then
            copy_file_s(c_path, d_path)
        end
    end
end


get_day_of_week = function()
    local day = tonumber(os.date("%w"))
    return day == 0 and 7 or day
end
