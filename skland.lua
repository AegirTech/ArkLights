-- ===========================================
--               官方接口
-- 以下所有功能均使用官方接口实现
-- 不保证长久可用性
--
-- 所有函数最上方标明接口用处/参数等信息
-- 所有请求均使用 curl（懒人精灵问题及限制过多）
-- ===========================================

API = "https://zonai.skland.com/api/v1"
Skland_app_code = '4ca99fa6b56cc2ba'
Skland_sign_token = "" -- 新版森空岛签名使用
cred = ""

Headers = {
    ["User-Agent"] = 'Skland/1.0.1 (com.hypergryph.skland; build:100001047; Android 33; ) Okhttp/4.11.0',
    ["Content-Type"] = "application/json"
}

-- 鹰角通行证登录，成功返回token
arknights_login = function(account, password)
    log("[1]获取token开始")
    local url = "https://as.hypergryph.com/user/auth/v1/token_by_phone_password"
    local data = {}
    data["phone"] = account
    data["password"] = password
    local ret = curl_post(url, Headers, JsonEncode(data), 5, nil)
    local status, ret = pcall(JsonDecode, ret)
    log(ret)
    if status then
        local token = get(ret, 'data', 'token')
        return token
    else
        log("[1]通行证登录失败" .. ret)
        return 0
    end
end

-- 通行证验证，成功返回code
get_grant_code = function(token)
    log("[2]获取grant_code开始")
    if token == 0 then return 0 end
    local url = "https://as.hypergryph.com/user/oauth2/v2/grant"
    local data = {}
    data["token"] = token
    data["appCode"] = Skland_app_code
    data["type"] = 0
    local ret = curl_post(url, Headers, JsonEncode(data), 5, nil)
    local status, ret = pcall(JsonDecode, ret)
    log(ret)
    if status then
        local code = get(ret, 'data', 'code')
        return code
    else
        log("[2]获取grant_code失败" .. ret)
        return 0
    end
end

-- 获取cred，用于森空岛api验证，并设置全局变量Skland_sign_token用于签名
skland_get_cred_by_token = function(code)
    log("[3]获取cred开始")
    if code == 0 then return 0 end
    local url = API .. "/user/auth/generate_cred_by_code"
    local data = {
        kind = 1,
        code = code
    }
    local ret = curl_post(url, Headers, JsonEncode(data), 5, nil)
    local status, ret = pcall(JsonDecode, ret)
    if status then
        log(ret)
        local code = get(ret, 'data', 'cred')
        Skland_sign_token = get(ret, 'data', 'token')
        log(Skland_sign_token)
        return code
    else
        log("[3]森空岛获取cred失败" .. ret)
        return 0
    end
end

--生成签名sign值，并直接设置Headers
skland_sign = function(url, data)
    skland_refresh_token()
    local data = data or ""
    local sha = require("sha2")
    local hmac = sha.hmac
    -- local curtime = os.time() 部分设备时间不对
    local curtime = get_timestamp_oneline(1)
    local headers = {
        ["platform"] = 'Android',
        ["timestamp"] = '',
        ["dId"] = '0f1c0e9ea95e832d',
        ["vName"] = '1.1.0'
    }
    headers["timestamp"] = curtime
    -- log(JsonEncode(headers))
    local temp = '{"platform":"Android","timestamp":"%s","dId":"0f1c0e9ea95e832d","vName":"1.1.0"}'
    temp = string.format(temp, curtime)
    local data = "/api/v1" .. url .. data .. curtime .. temp
    local ret = hmac(sha.sha256, Skland_sign_token, data)
    ret = MD5(ret)
    headers["sign"] = ret
    for k, v in pairs(headers) do
        Headers[k] = v
    end
end

-- 登录获取cred，并直接设置Headers
skland_get_cred = function(account, password)
    cred = skland_get_cred_by_token(get_grant_code(arknights_login(account, password)))
    Headers["cred"] = cred
    return cred
end

-- 获取森空岛绑定的账户信息
skland_get_bind_info = function()
    local url = API .. "/game/player/binding"
    skland_sign("/game/player/binding", "")
    local ret = curl_get(url, Headers, 5, nil)
    local status, ret = pcall(JsonDecode, ret)
    if status then
        if get(ret, 'code') == 0 then
            for i, v in pairs(ret["data"]["list"]) do
                if v["appCode"] == "arknights" then
                    return v["bindingList"]
                end
            end
            return nil
        else
            return nil
        end
    else
        log("json解析失败" .. ret)
        return {}
    end
end

-- 森空岛签到接口 成功返回0，重复签到返回1，其他各种失败原因返回2
skland_checkin = function(uid, server)
    local url = API .. "/game/attendance"
    local data = {}
    data["uid"] = uid
    data["gameId"] = tonumber(server)
    data = JsonEncode(data)
    skland_sign("/game/attendance", data)
    local ret = curl_post(url, Headers, data, 5, nil)
    log(ret)
    local status, ret = pcall(JsonDecode, ret)
    if status then
        local code = get(ret, "code")
        local msg = get(ret, "message")
        if code == 0 then
            return 0
        elseif string.find(msg, "请勿重复签到") then
            return 1
        else
            return 2
        end
    else
        log("json解析失败")
        return -1
    end
end

-- 刷新token
skland_refresh_token = function()
    url = API .. "/auth/refresh"
    local headers = shallowCopy(Headers)
    headers["sign_enable"] = false
    -- headers["timestamp"] = os.time()
    headers["sign"] = nil
    local ret = curl_get(url, headers, 5, nil)
    log(ret)
    local status, ret = pcall(JsonDecode, ret)
    if status then
        local code = get(ret, "code")
        if code == 0 then
            Skland_sign_token = get(ret, "data", "token")
            log("森空岛刷新token成功" .. Skland_sign_token)
        else
            log("森空岛刷新token失败")
        end
    else
        log("json解析失败")
    end
end

-- 获取森空岛账户信息
skland_get_account_info = function(cred)
    local url = API .. "/user"
    skland_sign("/user", "")
    local ret = curl_get(url, Headers, 5, nil)
    log(ret)
    local status, ret = pcall(JsonDecode, ret)
    if status then
        return ret
    else
        log("json解析失败" .. ret)
        return 0
    end
end

-- 森空岛每日签到
skland_daily_checkin = function(account, password)
    log("森空岛签到开始")
    local curtime = os.date('%y%m%d')
    local lasttime = read_local_config("account", account .. "lastcheckintime")
    if lasttime == curtime then
        log("森空岛签到跳过")
        table.insert(qqmessage, "森空岛签到跳过")
        return true
    end
    local cred = read_local_config("account", account .. "cred")
    if cred == nil or cred == "" or #cred < 5 then
        log("cred无效，等待重新获取")
        cred = skland_get_cred(account, password)
        if cred ~= 0 then
            save_local_config("account", account .. "cred", cred)
            log("cred获取完成" .. cred)
        else
            log("cred无效，登录存在错误，请联系开发者")
            table.insert(qqmessage, "森空岛签到登录发生错误")
        end
    end
    log("从配置中读取cred" .. cred)
    if cred == 0 then
        log("森空岛登录失败")
        table.insert(qqmessage, "森空岛登录失败")
        return false
    end

    Headers["cred"] = cred
    if type(cred) == "string" and #cred > 5 then
        list = skland_get_bind_info()
        if list == nil then
            log("森空岛签到失败")
            table.insert(qqmessage, "森空岛签到失败,cred无效")
            save_local_config("account", account .. "cred", "")
            return false
        end
        for i, v in pairs(list) do
            local gameuid = list[i]["uid"]
            local server = list[i]["channelMasterId"]
            log(i, gameuid, server)
            ret = skland_checkin(gameuid, server)
            if ret == 0 then
                log("森空岛签到完成")
                table.insert(qqmessage, "森空岛签到完成")
            elseif ret == 1 then
                log("森空岛签到重复")
                table.insert(qqmessage, "森空岛签到重复")
            else
                table.insert(qqmessage, "森空岛签到未知错误，请联系开发者")
            end
        end
        save_local_config("account", account .. "lastcheckintime", curtime)
        return true
    else
        log("未知错误")
        table.insert(qqmessage, "森空岛签到未知错误，请联系开发者")
        save_local_config("account", account .. "lastcheckintime", curtime)
        return false
    end
end

skland_account_check = function()
    local url = API .. "/user/me"
    skland_sign("/user/me", "")
    local result = curl_get(url, Headers)
    local status, result = pcall(JsonDecode, result)
    log(result)
    if status then
        -- local code = get(result, "code")
        local msg = get(result, "message")
        if string.find(msg, "用户未登录") then
            return false
        else
            return true
        end
    else
        log("json解析失败")
        return false
    end
end

-- 获取当前时间戳 使用淘宝接口，解决部分设备时间不对的情况 类型1 返回10位时间戳 类型2 返回13位时间戳 默认1
get_timestamp_oneline = function(v)
    local url = "https://acs.m.taobao.com/gw/mtop.common.getTimestamp/"
    local retdata, code = httpGet(url, 5)
    local status, ret = pcall(JsonDecode, retdata)
    if status then
        if string.find(retdata, "SUCCESS") then
            local timestamp = get(ret, "data", "t")
            if v == 2 then
                return timestamp
            else
                return string.sub(timestamp, 1, 10)
            end
        else
            log("获取时间戳失败")
            return 0
        end
    else
        log("json解析失败")
        return 0
    end
end

-- 森空岛初始化
skland_init = function(account, password)
    log("森空岛初始化")
    cred = read_local_config("account", account .. "cred")
    if type(cred) ~= "string" or #cred < 5 then
        log("cred无效，等待重新获取")
        cred = skland_get_cred(account, password)
        if cred ~= 0 then
            save_local_config("account", account .. "cred", cred)
            log("cred获取完成" .. cred)
        else
            log("cred无效，登录存在错误，请联系开发者")
            return false
        end
    else
        log("从配置中读取cred" .. cred)
        Headers["cred"] = cred
        if skland_account_check() then
            log("森空岛初始化完成")
            return true
        else
            log("cred无效，等待重新获取")
            cred = skland_get_cred(account, password)
            if cred ~= 0 then
                save_local_config("account", account .. "cred", cred)
                log("cred获取完成" .. cred)
            else
                log("cred无效，登录存在错误，请联系开发者")
                return false
            end
        end
    end
    Headers["cred"] = cred
    return true
end

-- 获取绑定的游戏信息
skland_get_game_info = function(uid)
    local url = API .. "/game/player/info"
    params = {
        ["uid"] = uid
    }
    skland_sign("/game/player/info", "uid=" .. uid)
    local ret = curl_get(url .. "?uid=" .. uid, Headers, 10, nil)
    local status
    status, ret = pcall(JsonDecode, ret)
    if status then
        if get(ret, 'code') == 0 then
            return ret
        else
            return {}
        end
    else
        log("json解析失败" .. ret)
        return {}
    end
end

-- 获取干员和材料
skland_cultivate = function(uid)
    local url = API .. "/game/cultivate/player"
    params = {
        ["uid"] = uid
    }
    skland_sign("/game/cultivate/player", "uid=" .. uid)
    local ret = curl_get(url .. "?uid=" .. uid, Headers, 10, nil)
    log(ret)
    local status
    status, ret = pcall(JsonDecode, ret)
    if status then
        if get(ret, 'code') == 0 then
            return ret
        else
            return {}
        end
    else
        log("json解析失败" .. ret)
        return {}
    end
end

-- 获取游戏信息 完整流程 如果账户绑定了多个b服则需要指定，大部分情况不用考虑
get_game_info = function(account, password, require_uid, require_server)
    require_uid = require_uid or 0
    require_server = require_server or 0
    skland_init(account, password)
    list = skland_get_bind_info()
    if list == nil then
        log("绑定列表获取失败")
        return false
    end
    log("list:", list)
    for i, v in pairs(list) do
        local gameuid = list[i]["uid"]
        if require_uid ~= 0 and require_uid ~= gameuid then
            log("uid不匹配，跳过")
            goto countinue
        end
        local server = list[i]["channelMasterId"]
        if require_server ~= 0 and require_server ~= server then
            log("server不匹配，跳过")
            goto countinue
        end
        log(i, gameuid, server)
        ret = skland_cultivate(gameuid)
        if ret ~= {} then
            log("获取完成，后续跳过")
            --log("ret:", ret)
            return ret["data"]
        end
        ::countinue::
    end
    return {}
end
