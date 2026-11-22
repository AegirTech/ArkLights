import("com.nx.assist.lua.LuaEngine")

local work = "mnt/sdcard/Pictures"
local newApk = work .. "/YOLOCR-v6.apk"
local oldApk = work .. "/PaddLeOCR.apk"
local detect
mkdir(work)

local function loadNewOcr()
    local loader = assert(LuaEngine.loadApk(newApk), "无法加载 APK " .. newApk)
    -- 使用不同的类名，避免懒人精灵复用同名类的方法缓存。
    local entry = assert(loader.loadClass("com.yolocr.speedrun.MyAIPlugin"), "加载 PP-OCRv6 类失败")
    assert(entry.initializeOcr(LuaEngine.getContext()), "初始化 PP-OCRv6 失败")
    local err = entry.loadOcrModel("", "", "", "", "", 640, 1, false, "", "")
    assert(err == nil, err)
    return function(bitmap)
        return entry.detectOcr(bitmap, 0.3, 0.5)
    end
end

local function findOldModels()
    if not fileExist(oldApk) then
        return nil
    end
    for _, name in ipairs({ "PaddLeOCR", "PaddleOCR" }) do
        local dir = work .. "/" .. name
        local label = dir .. "/Rec/LaBeL.txt"
        if not fileExist(label) then
            label = dir .. "/Rec/Label.txt"
        end
        local detParam = dir .. "/Db/PaddLeOCR_Db.param"
        local detBin = dir .. "/Db/PaddLeOCR_Db.bin"
        local recParam = dir .. "/Rec/PaddLeOCR_Rec.param"
        local recBin = dir .. "/Rec/PaddLeOCR_Rec.bin"
        if fileExist(label) and fileExist(detParam) and fileExist(detBin)
            and fileExist(recParam) and fileExist(recBin) then
            return { label, detParam, detBin, recParam, recBin }
        end
    end
end

local function loadOldOcr()
    local models = findOldModels()
    if not models then
        for _, name in ipairs({ "ppocr.zip", "ppocr2.zip" }) do
            local archive = work .. "/" .. name
            if not fileExist(archive) and type(extractAssets) == "function" then
                pcall(extractAssets, "main.rc", work, name)
            end
            if not fileExist(archive) and type(download_from_alist) == "function" then
                pcall(download_from_alist, name, work)
            end
            if fileExist(archive) then
                pcall(unZip, archive, work)
                models = findOldModels()
                if models then
                    break
                end
            end
        end
    end

    assert(models, "缺少 PaddLeOCR.apk 或 PP-OCRv3 模型文件")
    local loader = assert(LuaEngine.loadApk(oldApk), "无法加载 APK " .. oldApk)
    local entry = assert(loader.loadClass("com.LR.JZ.PaddLeOCR.Main"), "加载 PP-OCRv3 类失败")
    assert(entry.IniTiaLModeL(LuaEngine.getContext()), "初始化 PP-OCRv3 失败")
    local label, detParam, detBin, recParam, recBin = table.unpack(models)
    local cores = math.min(2, entry.ObtainCoreNumber())
    local err = entry.LoadModeL(label, detParam, detBin, recParam, recBin, 640, cores, false, "", "")
    assert(err == nil, err)
    return function(bitmap)
        return entry.Detect(bitmap, 0.3, 0.5)
    end
end

if fileExist(newApk) then
    local ok, result = pcall(loadNewOcr)
    if ok then
        detect = result
        log.debug("OCR 使用 PP-OCRv6", newApk)
    else
        log.debug("PP-OCRv6 加载失败 " .. tostring(result))
    end
end

if not detect then
    local ok, result = pcall(loadOldOcr)
    if ok then
        detect = result
        log.debug("OCR 使用 PP-OCRv3", oldApk)
    else
        log.debug("PP-OCRv3 加载失败 " .. tostring(result))
    end
end
paddleocr_loadfailed = detect == nil

function ocrex(r)
    if disable_paddleocr or paddleocr_loadfailed then
        return ocr(r)
    end
    if type(r) == "string" then
        r = point[r]
    end
    local left, top, right, bottom = table.unpack(r)
    local bitmap = LuaEngine.snapShot(left, top, right, bottom)
    if not bitmap then
        return {}
    end

    local ok, rows = pcall(function()
        local data = detect(bitmap)
        return data == "[]" and {} or jsonLib.decode(data)
    end)
    if not bitmap.isRecycled() then
        bitmap.recycle()
    end
    sleep(5)
    if not ok then
        log.debug("OCR 识别失败 " .. tostring(rows))
        return {}
    end

    local matches = {}
    for i, item in ipairs(rows or {}) do
        matches[i] = {
            text = item.LaBeL,
            l = left + item.X0,
            r = left + item.X1,
            t = top + item.Y0,
            b = top + item.Y3,
        }
    end
    return matches
end
