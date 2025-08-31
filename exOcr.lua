import("com.nx.assist.lua.LuaEngine")
local PaddLeOCR = {}
local PluGinObject
function PaddLeOCR.IniTiaLModeL(Object)
    if type(Object) ~= "userdata" or Object == nil then
        return "变量类型错误"
    end
    PluGinObject = Object.loadClass("com.LR.JZ.PaddLeOCR.Main")
    if PluGinObject == nil then
        return "加载Java类失败"
    end
    return PluGinObject.IniTiaLModeL(LuaEngine.getContext()) == false and "初始化插件失败, 请确保当前设备系统版本不低于7.0" or nil
end

function PaddLeOCR.GetCPUCoreNumBer()
    if PluGinObject == nil then
        return "请先初始化插件"
    end
    return PluGinObject.ObtainCoreNumber()
end

function PaddLeOCR.IFGPUIsItAvaiLabLe()
    if PluGinObject == nil then
        return "请先初始化插件"
    end
    return PluGinObject.IFGPUIsItAvaiLabLe()
end

function PaddLeOCR.LoadModeL(LaBeL, DbModeL, RecModeL, Input, Core, GPU, DbPassWord, RecPassWord)
    if PluGinObject == nil then
        return "请先初始化插件"
    end
    if type(LaBeL) ~= "string" or LaBeL == "" then
        return "标签参数错误"
    end
    if type(DbModeL) ~= "table" or #DbModeL ~= 2 or type(DbModeL[1]) ~= "string" or type(DbModeL[2]) ~= "string" then
        return "文本检测模型参数错误"
    end
    if type(RecModeL) ~= "table" or #RecModeL ~= 2 or type(RecModeL[1]) ~= "string" or type(RecModeL[2]) ~= "string" then
        return "文本识别模型参数错误"
    end
    if type(Input) ~= "number" or not (Input > 0) then
        return "输入大小参数错误 并且需要大于0"
    end
    if type(Core) ~= "number" or not (Core > 0) then
        return "核心数参数错误 并且需要大于0"
    end
    local ParameterGPU = false
    local ParameterDbPassWord = ""
    local ParameterRecPassWord = ""
    if type(GPU) == "boolean" then
        ParameterGPU = GPU
    end
    if type(DbPassWord) == "string" then
        ParameterDbPassWord = DbPassWord
    end
    if type(RecPassWord) == "string" then
        ParameterRecPassWord = RecPassWord
    end
    local VaLue = PluGinObject.LoadModeL(LaBeL, DbModeL[1], DbModeL[2], RecModeL[1], RecModeL[2], Input, Core,
        ParameterGPU, ParameterDbPassWord, ParameterRecPassWord)
    if VaLue == nil then
    end
    return VaLue
end

function PaddLeOCR.Detect(BitMap, Confidence, ProbabiLity)
    if PluGinObject == nil then
        return "请先初始化插件"
    end
    if type(BitMap) ~= "userdata" then
        return nil
    end
    if math.type(Confidence) ~= "float" or Confidence < 0 then
        return nil
    end
    if math.type(ProbabiLity) ~= "float" or ProbabiLity < 0 then
        return nil
    end
    local Data = PluGinObject.Detect(BitMap, Confidence, ProbabiLity)
    if Data == "[]" then
        return {}
    end
    return jsonLib.decode(Data)
end

-- 优先使用新ocr
if not fileExist("mnt/sdcard/Pictures/yoloppv4.apk") then
    extractAssets("main.rc", "mnt/sdcard/Pictures/", "yoloppv4.apk")
    extractAssets("main.rc", "mnt/sdcard/Pictures/", "ppocrv4.zip")
end

if not fileExist("mnt/sdcard/Pictures/yoloppv4.apk") then
    --local PaddLeOCR = require("PaddLeOCRPluGin")
    if not fileExist("mnt/sdcard/Pictures/ppocr.zip") then
        toast("未找到飞浆ocr模型文件，正在尝试下载。")
        if not download_from_alist("ppocr.zip", "/sdcard/Pictures") then
            toast("飞浆ocr模型下载失败,已禁用")
            paddleocr_loadfailed = true
            return
        end
    end
    if not fileExist("mnt/sdcard/Pictures/PaddLeOCR.apk") then
        extractAssets("main.rc", "mnt/sdcard/Pictures/", "ppocr.zip")
        unZip("mnt/sdcard/Pictures/ppocr.zip", "mnt/sdcard/Pictures")
    end

    -- 加载插件 有时会加载不上插件 加载不上时请把APK删除重新释放即可
    local Loader = LuaEngine.loadApk("mnt/sdcard/Pictures/PaddLeOCR.apk")
    -- 初始化OCR插件 需要把 LuaEngine.loadApk函数返回的插件对象传递过去
    local Err = PaddLeOCR.IniTiaLModeL(Loader)
    if Err ~= nil then
        print(string.format("初始化OCR插件失败 原因: %s", Err))
        paddleocr_loadfailed = true
    end

    -- 加载模型 公共模型在ZIP文件里

    -- 文本检测模型 文件名带有Db的文件 数组下标1为param文件 下标2为bin文件
    local DbModeL = {
        "mnt/sdcard/Pictures/PaddLeOCR/Db/PaddLeOCR_Db.param",
        "mnt/sdcard/Pictures/PaddLeOCR/Db/PaddLeOCR_Db.bin"
    }

    -- 文本识别模型 文件名带有Rec的文件 数组下标1为param文件 下标2为bin文件
    local RecModeL = {
        "mnt/sdcard/Pictures/PaddLeOCR/Rec/PaddLeOCR_Rec.param",
        "mnt/sdcard/Pictures/PaddLeOCR/Rec/PaddLeOCR_Rec.bin"
    }

    -- 生成数据时创建的txt文件 又名: 标签文件 字典文件
    local LaBeL = "mnt/sdcard/Pictures/PaddLeOCR/Rec/Label.txt"

    -- 加载模型
    local Err = PaddLeOCR.LoadModeL(LaBeL, DbModeL, RecModeL, 640, math.floor(2, PaddLeOCR.GetCPUCoreNumBer()),
        false, nil, nil)
    if Err ~= nil then
        log(string.format("加载模型错误 原因: %s", Err))
        paddleocr_loadfailed = true
    end
    log("当前机器cpu核心数:", PaddLeOCR.GetCPUCoreNumBer())
    ocrex = function(r)
        if disable_paddleocr then
            return ocr(r)
        end
        if type(r) == "string" then r = point[r] end
        --log("ocrinput", r)
        local BitMap = LuaEngine.snapShot(r[1], r[2], r[3], r[4])
        local ret = PaddLeOCR.Detect(BitMap, 0.3, 0.5)
        local res = {}
        for i = 1, #ret, 1 do
            res[i] = {
                text = ret[i].LaBeL,
                l = r[1] + ret[i]["X0"],
                r = r[1] + ret[i]["X1"],
                t = r[2] + ret[i]["Y0"],
                b = r[2] + ret[i]["Y3"],
            }
        end
        --[[if max_height then
	r = table.filter(r, function(x) return (x.b - x.t) <= max_height end)
	end]]
        --log("ocroutput", res)

        --释放 LuaEngine.snapShot 截取的图片 如不释放会导致内存溢出
        if BitMap ~= nil and BitMap.isRecycled() == false then
            BitMap.recycle()
        end
        --次数过多之后会闪退,加点延时
        sleep(5)
        return res
    end
else
    import('java.io.File')
    import('java.lang.*')
    import('java.util.Arrays')
    import('android.content.Context')
    import('android.hardware.Sensor')
    import('android.hardware.SensorEvent')
    import('android.hardware.SensorEventListener')
    import('android.hardware.SensorManager')

    local work = "mnt/sdcard/Pictures"
    local ocrzipfile = work .. "/ppocrv4.zip" --飞桨ocr模型地址

    if not fileExist("mnt/sdcard/Pictures/yoloppv4.apk") then
        extractAssets("main.rc", work, "yoloppv4.apk")
        extractAssets("main.rc", work, "ppocrv4.zip")
    end

    if not fileExist("mnt/sdcard/Pictures/yoloppv4.apk") then
        toast("飞桨ocr加载失败,请重新安装或者禁用飞桨ocr")
        console.show()
        ssleep(10)
        console.dismiss()
    end

    local loader = LuaEngine.loadApk(work .. "/yoloppv4.apk")

    local ocr1
    if loader ~= nil then
        --ocr
        local plugin = loader.loadClass("com.tencent.paddleocrncnn.PaddleOCRNcnn")
        ocr1 = plugin.initOcr(ocrzipfile)
        --print(fileExist(yolozipfile))
    end

    ocrex = function(r)
        if disable_paddleocr then
            return ocr(r)
        end
        if type(r) == "string" then r = point[r] end
        log("ocrinput", r)
        local BitMap = LuaEngine.snapShot(r[1], r[2], r[3], r[4])
        local ret = ocr1.DetectJson(BitMap, 0.3, 0.5)
        local res = {}
        if #ret > 0 then
            ret = jsonLib.decode(ret)
            for i = 1, #ret, 1 do
                res[i] = {
                    text = ret[i].label,
                    l = r[1] + ret[i]["x0"],
                    r = r[1] + ret[i]["x1"],
                    t = r[2] + ret[i]["y0"],
                    b = r[2] + ret[i]["y3"],
                }
            end
        end
        --[[if max_height then
	r = table.filter(r, function(x) return (x.b - x.t) <= max_height end)
	end]]
        --print("ocroutput", res)

        --释放 LuaEngine.snapShot 截取的图片 如不释放会导致内存溢出
        if BitMap ~= nil and BitMap.isRecycled() == false then
            BitMap.recycle()
        end
        --次数过多之后会闪退,加点延时
        sleep(5)
        return res
    end
end
