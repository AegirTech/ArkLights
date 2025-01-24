import('java.io.File')
import('java.lang.*')
import('java.util.Arrays')
import('android.content.Context')
import('android.hardware.Sensor')
import('android.hardware.SensorEvent')
import('android.hardware.SensorEventListener')
import('android.hardware.SensorManager')
import('com.nx.assist.lua.LuaEngine')

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
    print("ocrinput", r)
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
    print("ocroutput", res)

    --释放 LuaEngine.snapShot 截取的图片 如不释放会导致内存溢出
    if BitMap ~= nil and BitMap.isRecycled() == false then
        BitMap.recycle()
    end
    --次数过多之后会闪退,加点延时
    sleep(5)
    return res
end
