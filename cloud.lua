-- 云控对接
-- 为什么不用local，因为有些解释器的require有bug。
cloud = {}
m = cloud

m.deviceToken = ''
m.captchaToken = ''
m.server = ''
m.captchaServer = ''
m.heartBeatTid = -1
m.status = 1

m.setDeviceToken = function(deviceToken)
    deviceToken = strOr(deviceToken):trim()
    if #deviceToken < 5 then return end
    m.deviceToken = deviceToken
end

m.setCaptcha = function(server, token)
    server = strOr(server):trim()
    server = server:gsub("/+$", '')
    if #server < 5 then return end
    m.captchaServer = server

    token = strOr(token):trim()
    if #token < 5 then return end
    m.captchaToken = token
end

m.setServer = function(server)
    server = strOr(server):trim()
    server = server:gsub("/+$", '')
    if #server < 5 then return end
    m.server = server
end

m.setStatus = function(status) m.status = status end

m.enabled =
    function() return #strOr(m.server) > 0 and #strOr(m.deviceToken) > 0 end

m.getTaskEnabled = function() return cloud_get_task and m.enabled() end

m.heartBeat = function()
    -- log("32",32)
    local data = { status = m.status, deviceToken = m.deviceToken }
    local res, code = httpPost(m.server .. "/heartBeat", JsonEncode(data), 30,
        "Content-Type: application/json")
    -- log("res,code", res, code)
    return res, code
end

m.getTask = function()
    -- log("40",40)
    local res, code = httpGet(m.server .. "/getTask?" .. "deviceToken=" ..
        m.deviceToken, 30,
        'Content-Type: application/json')
    return res, code
end

-- m.addLog = function(img, info)
--   -- log("48",48)
--   if not m.enabled() then return end
--   local x = cloud_task or {}
--   local data = {
--     id = x.id or 0,
--     level = 'INFO',
--     taskType = x.taskType or '',
--     title = info or '',
--     detail = info or '',
--     imageUrl = img or '',
--     from = x.from or '',
--     name = x.name or '',
--     account = x.account or '',
--     password = x.password or '',
--     server = x.server or '',
--     time = os.date("!%Y-%m-%dT%TZ"),
--   }
--   -- log("data",data)
--   local res, code = httpPost(
--                       m.server .. "/addLog?deviceToken=" .. m.deviceToken,
--                       JsonEncode(data), 30, 'Content-Type: application/json')
--   -- log("res,code", res, code)
--   return res, code
-- end

-- Standardized log
-- Author: DazeCake
m.addLog = function(log_level, log_title, log_detail, img_url)
    -- log("48",48)
    if not m.enabled() then return end
    local x = cloud_task or {}
    local data = {
        id = x.id or 0,
        level = log_level or 'INFO',
        taskType = x.taskType or '',
        title = log_title or '',
        detail = log_detail or '',
        imageUrl = img_url or '',
        from = x.from or '',
        name = x.name or '',
        account = x.account or '',
        password = '',
        server = x.server or '',
        time = os.date("!%Y-%m-%dT%TZ"),
    }
    -- log("data",data)
    local res, code = httpPost(
        m.server .. "/addLog?deviceToken=" .. m.deviceToken,
        JsonEncode(data), 30, 'Content-Type: application/json')
    -- log("res,code", res, code)
    return res, code
end

m.uploadImgToInquisition = function(img_path)
    local base64Image = getFileBase64(img_path) or ""
    local data = {
        base64Image = base64Image,
        deviceToken = m.deviceToken
    }
    local res, code = httpPost(m.server .. "/uploadImage", JsonEncode(data), 30,
        "Content-Type: application/json")
    if code == 200 then
        status, data = pcall(JsonDecode, res)
        if data.code == 200 then
            log("云控日志", "截图上传成功")
            return data.data
        else
            log("云控日志", "截图上传失败")
            return ""
        end
    else
        return ""
    end
end

m.captcha = function()
    if only_use_ttshitu then
        return false
    end
    -- if m.captchaToken == '' or m.captchaServer == '' then
    --   return false
    -- end
    local text_box = findOne("B服安全验证目标字符")
    -- log("text_box_右坐标", text_box.bounds.r)
    local text_slice_box = findOne("B服安全验证目标字符切片")
    -- log("text_slice_box_右坐标", text_slice_box.bounds.r)
    local big_image_box = findOne("B服安全验证泛目标图像")
    local text_pos = { text_slice_box.bounds.r, text_box.bounds.t, big_image_box.bounds.r, text_box.bounds.b }
    log("目标字符坐标", text_pos)
    local image_box = findOne("B服安全验证目标图像")
    local image_pos = { image_box.bounds.l, image_box.bounds.t, image_box.bounds.r, image_box.bounds.b }
    log("图像坐标", image_pos)

    local img = getWorkPath() .. "/capture_cloud.jpg"
    snapShot(img, text_pos[1], text_pos[2], text_pos[3], text_pos[4])
    local text_img_base64 = base64(img)
    ssleep(.1)
    snapShot(img, image_pos[1], image_pos[2], image_pos[3], image_pos[4])
    local image_img_base64 = base64(img)

    local data = {
        text_base64 = text_img_base64,
        image_base64 = image_img_base64,
        token = m.captchaToken
    }

    local res, code = httpPost(m.captchaServer .. "/captcha/select/base64", JsonEncode(data), 30,
        "Content-Type: application/json")
    if code == 200 then
        status, data = pcall(JsonDecode, res)
        if data.code == 0 then
            cloud_captcha_id = data.data.captcha_id or nil
            log("云控打码数量", #data.data.points)
            log("云控打码坐标", data.data.points)
            for _, coord in pairs(data.data.points) do
                x = coord[1] or 0
                y = coord[2] or 0
                tap({ image_pos[1] + x, image_pos[2] + y })
                ssleep(0.3)
            end
            return true
        else
            log("云控打码", data.message)
            return false
        end
    else
        log("云控打码", "网络错误")
        return false
    end
end

m.captcha_report = function()
    -- if m.captchaToken == '' or m.captchaServer == '' then
    --   return false
    -- end
    if not cloud_captcha_id then
        return
    end

    local data = {
        captcha_id = cloud_captcha_id,
        token = m.captchaToken
    }

    local res, code = httpPost(m.captchaServer .. "/captcha/select/report", JsonEncode(data), 30,
        "Content-Type: application/json")
    cloud_captcha_id = nil
    log("云控打码失败上报", res, code)
end

m.FAILTASK_LINEBUSY = 'lineBusy'
m.FAILTASK_ACCOUNTERROR = 'accountError'

m.failTask = function(imageUrl, type)
    -- log("73",73)
    if not m.getTaskEnabled() then return end
    imageUrl = imageUrl or ''
    type = type or ''
    local res, code = httpPost(m.server .. "/failTask?deviceToken=" ..
        m.deviceToken .. "&imageUrl=" ..
        encodeUrl(imageUrl) .. "&type=" .. type, '', 30,
        'Content-Type: application/json')
    return res, code
end

m.completeTask = function(imageUrl)
    -- log("84",84)
    if not m.getTaskEnabled() then return end
    imageUrl = imageUrl or ''
    local res, code = httpPost(m.server .. "/completeTask?deviceToken=" ..
        m.deviceToken .. "&imageUrl=" ..
        encodeUrl(imageUrl), '', 30,
        'Content-Type: application/json')
    return res, code
end

m.haltComplete = function()
    print("停机上报")
    local data = { status = m.status, deviceToken = m.deviceToken }
    local res, code = httpPost(m.server .. "/haltComplete", JsonEncode(data), 30,
        "Content-Type: application/json")
    return res, code
end

m.solveTask = function(data) restartSimpleMode(data) end

m.fetchSolveTask = function()
    if not m.getTaskEnabled() then return end
    while true do
        local res, code = m.getTask()
        -- log("code", code)
        -- log("res", res)
        local status, data
        status, data = pcall(JsonDecode, res)
        log("云控", data)
        if type(data) == 'table' and type(data.data) == 'table' and data.code ~= 500 then
            m.solveTask(data.data)
        end
        m.setStatus(1)
        ssleep(5)
    end
end

m.startHeartBeat = function()
    -- log("m.enabled()", m.enabled())
    if not m.enabled() then return end
    local f = function()
        while true do
            local res, code = m.heartBeat()
            local status, data = pcall(JsonDecode, res)
            if data.code == 500 then
                m.haltComplete()
                log("云控", "停机上报")
                -- 子线程不能直接stop 需要使用setTimer延时函数回调stop到主线程
                setTimer(stop, 100, "强制停机")
            end
            ssleep(5)
        end
    end
    m.heartBeatTid = beginThread(f)
end

m.stopHeartBeat = function() stopThread(m.heartBeatTid) end

m.sanReport = function()
    log("理智上报", m.enabled())
    -- if not m.enabled() then return true end
    local p = point["剩余理智"]
    local ocrHander = createOcr()
    local sanText = ocrText(ocrHander, p[1], p[2], p[3], p[4], "ffffff-a8a8a8") or "0/100"
    releaseOcr(ocrHander)
    sanText = string.match(sanText, "[%d]+[/][%d]+")
    if sanText == "" or sanText == nil then
        sanText = "0/100"
    end
    local index = 1
    local san = {}
    log("理智", '[' .. sanText .. ']')
    for word in string.gmatch(sanText, "%d+") do
        san[index] = word
        index = index + 1
    end
    local res, code = httpPost(m.server .. "/sanReport?san=" .. san[1] ..
        "&maxSan=" .. san[2] .. "&deviceToken=" ..
        m.deviceToken, '', 30,
        'Content-Type: application/json')
end

restartSimpleMode = function(data)
    if not type(data) == 'table' then return end
    if not table.includes({ "daily", "rogue", "sand_fire" }, data.taskType) then return end
    local username = data.account
    local password = data.password
    local server = data.server
    local config = data.config
    local taskType = data.taskType
    -- local x
    -- set recommend config over default
    -- x = loadOneUIConfig("main")
    -- x["fight_ui"] = "jm hd ce ls ap pr"
    -- for i = 1, 12 do x["now_job_ui" .. i] = true end
    -- x["now_job_ui8"] = false
    -- x["crontab_text"] = "4:00 12:00 20:00"
    -- saveOneUIConfig("main", x)
    --
    -- x = loadOneUIConfig("debug")
    -- x["max_jmfight_times"] = "1"
    -- x["max_login_times_5min"] = "3"
    -- x["QQ"] = strOr(config.QQ) .. '#' .. strOr(config.deviceName)
    -- x["multi_account_choice_weekday_only"] =
    --   strOr(config.weekdayOnly, x["multi_account_choice_weekday_only"])
    --
    -- x["qqnotify_beforemail"] = true
    -- x["qqnotify_afterenter"] = true
    -- x["qqnotify_beforeleaving"] = true
    -- x["qqnotify_beforemission"] = true
    -- x["qqnotify_save"] = true
    -- x["collect_beforeleaving"] = true
    -- -- 一是完成日常任务，二是间隔时间最长可以11小时，提高容错
    -- x["zero_san_after_fight"] = true
    -- x["max_drug_times_" .. str(1) .. "day"] = "99"
    -- x["max_drug_times_" .. str(2) .. "day"] = "99"
    -- x["max_drug_times_" .. str(3) .. "day"] = "1"
    -- x["max_drug_times_" .. str(4) .. "day"] = "1"
    -- x["max_drug_times_" .. str(5) .. "day"] = "1"
    -- x["max_drug_times_" .. str(6) .. "day"] = "1"
    -- x["max_drug_times_" .. str(7) .. "day"] = "1"
    -- x["enable_log"] = false
    -- x["disable_killacc"] = false
    -- x["keepalive_interval"] = "900"
    -- saveOneUIConfig("debug", x)
    --
    -- x = loadOneUIConfig("multi_account")
    -- x["multi_account_end_closeotherapp"] = true
    -- x["multi_account_end_closeapp"] = true
    -- x["multi_account_choice"] = "1-30"
    -- x["multi_account_enable"] = true
    -- saveOneUIConfig("multi_account", x)

    -- log("64",64)
    -- set task config
    -- log("62",61)
    -- exit()
    if #strOr(username) == 0 or #strOr(password) == 0 then return end
    -- log("63",61)
    if not table.includes({ 0, 1 }, server) then return end
    -- log("64",61)
    if not type(config) == 'table' then return end
    -- log("65",61)
    -- log("65", 64)

    local hook = [[
cloud_task=JsonDecode(]] .. string.format("%q", JsonEncode(data)) .. [[);
crontab_enable=false
multi_account_enable=false
username=]] .. string.format("%q", username) .. [[;
password=]] .. string.format("%q", password) .. [[;
server=]] .. server
    if taskType == 'rogue' then
        hook = hook .. [[;extra_mode="战略前瞻投资"]]
    elseif taskType == 'rogue2' then
        hook = hook .. [[;extra_mode="水月与深蓝之树"]]
    elseif taskType == 'sand_fire' then
        hook = hook .. [[;extra_mode="生息演算沙中之火"]]
    end

    -- log("64",64)
    -- log("config",config)
    -- exit()
    -- 日常
    local x
    x = get(config, 'daily', 'fight')
    if istable(x) then
        local y = ''
        for _, v in pairs(x) do
            if get(v, 'num') == 1 then
                y = y .. str(get(v, 'level')) .. ' '
            else
                y = y .. str(get(v, 'level')) .. 'x' .. str2int(get(v, 'num')) .. ' '
            end
        end
        hook = hook .. [[;fight_ui=]] .. string.format("%q", y)
        hook = hook .. [[;now_job_ui2=]] .. str(#y > 0)
    end
    -- log("65",64)

    x = get(config, 'daily', 'sanity', 'drug')
    if x then hook = hook .. [[;max_drug_times=]] .. str2int(x) end

    x = get(config, 'daily', 'sanity', 'stone')
    if x then hook = hook .. [[;max_stone_times=]] .. str2int(x) end

    hook = hook .. [[;now_job_ui1=]] .. str(get(config, 'daily', 'mail'))
    hook = hook .. [[;now_job_ui3=]] .. str(get(config, 'daily', 'friend'))

    hook = hook .. [[;now_job_ui4=]] ..
        str(get(config, 'daily', 'infrastructure', 'harvest'))
    hook = hook .. [[;now_job_ui5=]] ..
        str(get(config, 'daily', 'infrastructure', 'shift'))
    hook = hook .. [[;now_job_ui6=]] ..
        str(get(config, 'daily', 'infrastructure', 'acceleration'))

    hook = hook .. [[;now_job_ui7=]] ..
        str(get(config, 'daily', 'infrastructure', 'communication'))
    hook = hook .. [[;now_job_ui8=]] ..
        str(get(config, 'daily', 'infrastructure', 'deputy'))
    hook = hook .. [[;now_job_ui9=]] .. str(get(config, 'daily', 'credit'))

    hook = hook .. [[;now_job_ui10=]] ..
        str(get(config, 'daily', 'offer', 'enable'))
    hook = hook .. [[;now_job_ui11=]] .. str(get(config, 'daily', 'task'))
    hook = hook .. [[;now_job_ui12=]] .. str(get(config, 'daily', 'activity'))
    --审判庭配置提前写在这里里,如果需要对接审判庭,青在daily属性中添加shopping
    local shopping_cloud_switch = get(config, 'daily', 'shopping')

    local main_config = loadOneUIConfig("main")

    local shopping_ui_switch = main_config["now_job_ui13"]
    --审判庭云控不存在则使用本地配置
    shopping_ui_switch = (shopping_cloud_switch == nil) and shopping_ui_switch or str(shopping_cloud_switch)

    hook = hook .. [[;now_job_ui13=]] .. str(shopping_ui_switch)

    hook = hook .. [[;auto_recruit0=]] ..
        str(get(config, 'daily', 'offer', 'other'))
    hook = hook .. [[;auto_recruit1=]] ..
        str(get(config, 'daily', 'offer', 'car'))
    hook = hook .. [[;auto_recruit4=]] ..
        str(get(config, 'daily', 'offer', 'star4'))
    hook = hook .. [[;auto_recruit5=]] ..
        str(get(config, 'daily', 'offer', 'star5'))
    hook = hook .. [[;auto_recruit6=]] ..
        str(get(config, 'daily', 'offer', 'star6'))

    -- 肉鸽
    hook = hook .. [[;zl_best_operator=]] ..
        str2int(get(config, 'rogue', 'operator', 'index'))
    hook = hook .. [[;zl_skill_times=]] ..
        str2int(get(config, 'rogue', 'operator', 'num'))
    hook = hook .. [[;zl_skill_idx=]] ..
        str2int(get(config, 'rogue', 'operator', 'skill'))
    hook = hook .. [[;zl_max_coin=]] .. str2int(get(config, 'rogue', 'coin'))
    hook = hook .. [[;zl_max_level=]] .. str2int(get(config, 'rogue', 'level'))
    hook = hook .. [[;zl_more_repertoire=false]]
    hook = hook .. [[;zl_more_experience=true]]
    hook = hook .. [[;zl_skip_coin=]] .. str(get(config, 'rogue', 'skip', 'coin'))
    hook = hook .. [[;zl_skip_hard=]] ..
        str(get(config, 'rogue', 'skip', 'beast'))
    hook = hook .. [[;zl_no_waste=]] ..
        str(not get(config, 'rogue', 'skip', 'daily'))
    hook = hook .. [[;zl_accept_mg=]] ..
        str(not get(config, 'rogue', 'skip', 'sensitive'))
    hook = hook .. [[;zl_accept_yx=]] ..
        str(not get(config, 'rogue', 'skip', 'illusion'))
    hook = hook .. [[;zl_accept_sc=]] ..
        str(not get(config, 'rogue', 'skip', 'survive'))

    -- --- TODO debug
    -- for i = 1,12 do
    --   hook = hook .. [[;now_job_ui]]..i .. [[=false]]
    -- end
    -- ---

    hook = hook .. [[;saveConfig("restart_mode_hook",]] ..
        string.format("%q", hook) .. ')'
    log("hook", hook)
    -- ssleep(1000)
    saveConfig("hideUIOnce", "true")
    saveConfig("restart_mode_hook", hook)
    restartPackage()
end
