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
        account_data = JsonDecode(json)
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

trySolveSlipCaptcha = function(retry)
    local retry = retry or 0
    -- if not use_jfbym and not use_free_server_captcha then trySolveCapture() end
    if not findOne("captcha") then return end
    if use_local_captcha then
        solveCapture_new(getCaptchaBox())
    else
        trySolveCaptureFreeServer(getCaptchaBox()) -- 使用免费打码
    end
    if not disappear("captcha", 5) then
        trySolveCaptureFreeServer(getCaptchaBox()) -- 第二次使用免费打码
    end
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
    local data = { uniqueCode = unique_code, token = jfbym_token }
    local ret, code = httpPost("http://api.jfbym.com/api/YmServer/refundApi",
        JsonEncode(data), 30,
        "Content-Type: application/json;charset=UTF-8")
    log(ret, code)
    unique_code = nil
end

-- b服选点验证码打码
-- 统一更改为 https://console.jfbym.com/
trySolvePointSelectionCapture = function(rect)
    if cloud.captcha() then return end
    if not rect then return end
    local img = getWorkPath() .. "/capture.jpg"
    snapShot(img, rect.l, rect.t, rect.r, rect.b)
    local img_base64 = base64(img)
    local ans = nil
    -- if bili_captcha_mode == 0 then
    --     -- 云码
    --     if not jfbym_token or #jfbym_token < 5 then return end
    --     local data = {
    --         token = jfbym_token,
    --         type = "88888",
    --         image = img_base64,
    --     }

    --     local res, code = httpPost("http://api.jfbym.com/api/YmServer/customApi", JsonEncode(data),
    --         30, "Content-Type: application/json;charset=UTF-8")

    --     local status, data = pcall(JsonDecode, res)
    --     log("识别结果", data)
    --     data = data or {}
    --     if get(data, "code") ~= 10000 then
    --         log("识别失败")
    --         return
    --     end
    --     unique_code = get(data, "data", "unique_code") or ""

    --     ans = get(data, "data", "data") or ""
    if use_captcha then
        -- 极验
        if not captcha_username or not captcha_password then return end
        local data = {
            username = captcha_username,
            password = captcha_password,
            typeid = "27",
            image = img_base64,
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
    else
        return
    end
    if not ans then return end
    for coord in string.gmatch(ans, "%d+,%d+") do
        local x, y = string.match(coord, "(%d+),(%d+)")
        x = x or 0
        y = y or 0
        local ans_p = { rect.l + x, rect.t + y }
        tap(ans_p)
        ssleep(0.2)
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

--使用部署的客户端免费打码官服滑块验证码
trySolveCaptureFreeServer = function(rect)
    if not use_free_server_captcha then
        return
    end
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
    local distance = ret.target[1].distance
    local distance = str2int(distance, 0)
    log("distance:", distance)
    if distance < 1 then
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
    log("滑动结束")
    ssleep(1.5)      -- 等待验证码关闭或者重试
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

solveCapture_new = function(rect, is_retry)
    local is_retry = is_retry or false
    if not rect then return end
    wait(function()
        local b, g, r = colorToRGB(getPixelColor())
        if cmpColor(scale(1083), scale(401), "FFFFFF", 1) == 0 then
            return true
        end
    end, 5)
    -- 等待验证码加载
    ssleep(0.2)
    keepCapture()
    -- rect.l, rect.t, rect.r, rect.b
    -- rect = {}
    -- rect.l = 636
    -- rect.t = 207
    -- rect.r = 1287
    -- rect.b = 605

    -- 11,11,11 50
    -- 理论上可以用getScreenPixel一次性获取全部的像素点，但是后面取有点麻烦。
    local bb_socre, max_count, max_c = 150, 0, 50
    local best_x = 0
    for y = rect.t, rect.b do
        for x = rect.l, rect.r do
            local pixel = getPixelColor(x, y)
            local b, g, r = colorToRGB(pixel)
            local rx, gx, bx = math.abs(r - 11), math.abs(g - 11), math.abs(b - 11)

            if rx < max_c and gx < max_c and bx < max_c and rx + gx + bx < max_c then
                local socre, count = 0, 0
                for y2 = y, y + scale(100) do
                    pixel = getPixelColor(x, y2)
                    b, g, r = colorToRGB(pixel)
                    rx, gx, bx = math.abs(r - 11), math.abs(g - 11), math.abs(b - 11)

                    if rx < max_c and gx < max_c and bx < max_c then
                        socre = socre + rx + gx + bx
                        count = count + 1
                    end
                end

                for x2 = x, x + scale(100) do
                    pixel = getPixelColor(x2, y)
                    b, g, r = colorToRGB(pixel)
                    rx, gx, bx = math.abs(r - 11), math.abs(g - 11), math.abs(b - 11)
                    if rx < max_c and gx < max_c and bx < max_c then
                        socre = socre + rx + gx + bx
                        count = count + 1
                    end
                end
                socre = socre / count
                if math.abs(socre - bb_socre) < 150 and count > max_count then
                    bb_socre, max_count = socre, count
                    log(x, y, socre, count)
                    best_x = x
                end
            end
        end
    end
    log(3399, best_x, bb_socre, max_count)
    log("滑块验证码位置", best_x)
    releaseCapture()
    if best_x == 0 and not is_retry then
        log("重试")
        solveCapture_new(rect, true)
    end

    -- exit()

    -- log(table.slice(best, 1, 10))
    -- exit()
    -- log(w, h, best, best_score, best + point.captcha_area[1])

    -- for i = 1, #maxgrad do log(i, maxgrad[i]) end
    -- log(point.captcha_area)
    --
    local sx, sy = scale(702), scale(686)
    --  修正偏移
    local distance = best_x - rect.l
    log(sx, sy, distance)
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
            duration = 800,
        },
    })
    ssleep(1.2) -- 等待验证码关闭或者重试
    return true
end
