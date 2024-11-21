--- 识别时请根据训练时图片的方向 选择截图模式 或者训练 4角度的模型
--- 公共模型与APK插件都在ZIP压缩包里
--- 由于插件体积过大 建议把插件以及模型打成压缩包 释放后再进行解压

import("com.nx.assist.lua.LuaEngine")

--导入插件
local PaddLeOCR = require("PaddLeOCRPluGin")

if not fileExist("mnt/sdcard/Pictures/PaddLeOCR.apk") then
    extractAssets("main.rc", "mnt/sdcard/Pictures/", "ppocr.zip")
    unZip("mnt/sdcard/Pictures/ppocr.zip", "mnt/sdcard/Pictures")
end

if not fileExist("mnt/sdcard/Pictures/ppocr.zip") then
    toast("请确保ppocr.zip在sdcard/Pictures/目录下")
    console.show()
    ssleep(10)
    console.dismiss()
end

-- 加载插件 有时会加载不上插件 加载不上时请把APK删除重新释放即可
local Loader = LuaEngine.loadApk("mnt/sdcard/Pictures/PaddLeOCR.apk")
-- 初始化OCR插件 需要把 LuaEngine.loadApk函数返回的插件对象传递过去
local Err = PaddLeOCR.IniTiaLModeL(Loader)
if Err ~= nil then
    print(string.format("初始化OCR插件失败 原因: %s", Err))
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
local Err = PaddLeOCR.LoadModeL(LaBeL, DbModeL, RecModeL, 640, 2, false, nil, nil)
if Err ~= nil then
    print(string.format("加载模型错误 原因: %s", Err))
end

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
