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
s_did = "BthF/q9lF2i1A5Rg/RmK/tSaf1lQsyGDtShjEXP8C8bO1bQp54yS952DEQPVCouDQJontBBrVK6EbDfXBOzPEnQ=="

Headers = {
    ["User-Agent"]   =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
    ["Content-Type"] = "application/json",
    ["cred"]         = cred,
    ["platform"]     = '3',
    ["timestamp"]    = '',
    ["dId"]          = s_did,
    ["vName"]        = '1.0.0',
    ["origin"]       = 'https://www.skland.com',
    ["referer"]      = 'https://www.skland.com',
}

skland = {}

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
    local url = "https://zonai.skland.com/web/v1/user/auth/generate_cred_by_code"
    local data = {
        kind = 1,
        code = code
    }
    local ret = curl_post(url, Headers, JsonEncode(data), 5, nil)
    local status, ret = pcall(JsonDecode, ret)
    log(ret)
    if status then
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
skland.sign = function(url, data)
    skland.get_refresh_token()
    local data           = data or ""
    local sha            = require("sha2")
    local hmac           = sha.hmac
    -- local curtime = os.time() 部分设备时间不对
    local curtime        = tonumber(get_timestamp_oneline(1)) - 2
    curtime              = tostring(curtime)
    local headers        = {
        ["platform"] = '3',
        ["timestamp"] = '',
        ["dId"] = s_did,
        ["vName"] = '1.0.0'
    }
    headers["timestamp"] = curtime
    log(JsonEncode(headers))
    local temp      = '{"platform":"3","timestamp":"%s","dId":"' .. s_did .. '","vName":"1.0.0"}'
    temp            = string.format(temp, curtime)
    local data      = "/api/v1" .. url .. data .. curtime .. temp
    local ret       = hmac(sha.sha256, Skland_sign_token, data)
    ret             = MD5(ret)
    headers["sign"] = ret
    log("sign", ret)
    for k, v in pairs(headers) do
        Headers[k] = v
    end
end

-- 登录获取cred，并直接设置Headers
skland.get_cred = function(account, password)
    cred = skland_get_cred_by_token(get_grant_code(arknights_login(account, password)))
    Headers["cred"] = cred
    return cred
end

skland.request = function(method, url, data)
    local data = data or ""
    local method = method or "GET"
    if type(data) == "table" then
        data = JsonEncode(data)
    end
    skland.sign(url, data)
    if method == "GET" then
        local ret = curl_get(API .. url, Headers, 5, nil)
        log(method, url, ret)
        return ret
    elseif method == "POST" then
        local ret = curl_post(API .. url, Headers, data, 5, nil)
        log(method, url, ret)
        return ret
    end
end

-- 获取森空岛绑定的账户信息
skland.get_bind_info = function()
    local ret = skland.request("GET", "/game/player/binding")
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
        return nil
    end
end

skland.account_check = function()
    -- local result = skland.request("GET", "/game/player/binding")
    -- local status, result = pcall(JsonDecode, result)
    -- if status then
    --     -- local code = get(result, "code")
    --     local msg = get(result, "message")
    --     if string.find(msg, "用户未登录") then
    --         return false
    --     else
    --         return true
    --     end
    -- else
    --     log("json解析失败")
    --     return false
    -- end
    return true
end

-- 森空岛签到接口 成功返回0，重复签到返回1，其他各种失败原因返回2
skland.checkin = function(uid, server)
    local data = {}
    data["uid"] = uid
    data["gameId"] = tonumber(server)
    local ret = skland.request("POST", "/game/attendance", data)
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

-- 获取绑定的游戏信息
skland.get_game_info = function(uid)
    local url = API .. "/game/player/info"
    local params = {
        ["uid"] = uid
    }
    skland.sign("/game/player/info", "uid=" .. uid)
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
        log("json解析失败", ret)
        return {}
    end
end

-- 获取干员和材料
skland.cultivate = function(uid)
    local url = API .. "/game/cultivate/player"
    params = {
        ["uid"] = uid
    }
    skland.sign("/game/cultivate/player", "uid=" .. uid)
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
        log("json解析失败", ret)
        return {}
    end
end


-- 刷新token
skland.get_refresh_token = function()
    url = API .. "/auth/refresh"
    local ret = curl_get(url, nil, 5, nil)
    local status, ret = pcall(JsonDecode, ret)
    log(ret)
    if status then
        local code = get(ret, "code")
        if code == 0 then
            Skland_sign_token = get(ret, "data", "token")
            log("森空岛刷新token成功", Skland_sign_token)
        else
            log("森空岛刷新token失败")
        end
    else
        log("json解析失败")
    end
end

-- 森空岛每日签到
skland_daily_checkin = function(account, password)
    log("森空岛签到开始")
    local curtime = os.date('%y%m%d')
    local lasttime = get(account_data, str(account), "lastcheckintime")
    if lasttime == curtime then
        log("森空岛签到跳过")
        table.insert(qqmessage, "森空岛签到跳过")
        return true
    end
    -- did 从接口获取（有点麻烦，没法写lua版本的）
    local did_time = get(account_data, "did_time")
    if did_time == nil or did_time < os.date('%y%m%d') then
        local res, code = httpGet("https://skland-api.enlysure.com:13000/skland/get_did?verify=arklights", 10)
        log("did code get", res, code)
        if code == 200 then
            s_did = res
            Headers["dId"] = s_did
            account_data["did_time"] = os.date('%y%m%d', os.time() + 3 * 24 * 60 * 60)
            account_data["did"] = s_did
            save_local_config()
        end
    else
        s_did = get(account_data, "did")
        Headers["dId"] = s_did
    end
    skland_init(account, password)
    local list = get(account_data, str(account), "binding")
    if list == nil then
        list = skland.get_bind_info()
    end
    if list == nil then
        log("森空岛签到失败")
        table.insert(qqmessage, "森空岛签到失败,获取绑定id失败")
        account_data[account]["cred"] = ""
        save_local_config()
        return false
    end
    for i, v in pairs(list) do
        local gameuid = list[i]["uid"]
        local server = list[i]["channelMasterId"]
        log(i, gameuid, server)
        ret = skland.checkin(gameuid, server)
        if ret == 0 then
            log("森空岛签到完成")
            table.insert(qqmessage, "森空岛签到完成")
        elseif ret == 1 then
            log("森空岛签到重复")
            table.insert(qqmessage, "森空岛签到重复")
        else
            table.insert(qqmessage, "森空岛签到未知错误，请联系开发者")
            account_data[account]["cred"] = ""
            save_local_config()
            return false
        end
    end
    account_data[account]["binding"] = list
    account_data[account]["lastcheckintime"] = curtime
    save_local_config()
    return true
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
    cred = get(account_data, str(account), "cred")
    if not account_data[account] then
        account_data[account] = {}
    end
    if type(cred) ~= "string" or #cred < 5 then
        log("cred无效")
        cred = skland.get_cred(account, password)
        if type(cred) == "string" and #cred > 5 then
            account_data[account]["cred"] = cred
            log("cred获取", cred)
        else
            log("cred登录存在错误")
            return false
        end
    else
        log("从配置中读取cred", cred)
        Headers["cred"] = cred
        if skland.account_check() then
            log("森空岛初始化完成")
            return true
        else
            log("cred无效")
            cred = skland.get_cred(account, password)
            if cred ~= 0 then
                account_data[account]["cred"] = cred
                log("cred获取完成", cred)
            else
                log("cred登录存在错误")
                return false
            end
        end
    end
    Headers["cred"] = cred
    save_local_config()
    return true
end

-- 获取游戏信息 完整流程 如果账户绑定了多个b服则需要指定，大部分情况不用考虑
get_game_info = function(account, password, require_uid, require_server)
    require_uid = require_uid or 0
    require_server = require_server or 0
    skland_init(account, password)
    list = skland.get_bind_info()
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
        ret = skland.cultivate(gameuid)
        if ret ~= {} then
            log("获取完成，后续跳过")
            --log("ret:", ret)
            return ret["data"]
        end
        ::countinue::
    end
    return {}
end
