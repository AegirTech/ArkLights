---@meta

--懒人3.8.7.1命令
--在sumneko.lua-设置-中搜索library添加

-- 设备方法

--- 判断当前app是否为前台运行
---@param package_name any 指定要查找的包名
function appIsFront(package_name) end

--- 判断当前app是否在运行中
---@param package_name any 指定要查找的包名
function appIsRunning(package_name) end

--- 以当前最高权限(如果设备是root的则以root权限执行，如果是激活的则以激活权限执行)执行命令
-- 语法: exec(cmd,[isRet])
---@param cmd any
---@param isRet any
function exec(cmd, isRet) end

--- 停止脚本运行
function exitScript() end

--- 释放资源到指定目录
---@param assets any
---@param outdir any
---@param pattern any
function extractAssets(assets, outdir, pattern) end

--- 获取前台app包名
---@return any 前台app包名
function frontAppName() end

--- 获取壳子版本 - 功能说明:获取当前apk壳子的版本号，返回一个整数
function getApkVerInt() end

--- 获取设备电量
function getBatteryLevel() end

--- 获取主板号
function getBoard() end

--- 获取BOOTLOADER版本号
function getBootLoader() end

--- 获取设备BRAD号
function getBrand() end

--- cpu支持类型
function getCpuAbi2() end

--- cpu支持类型
function getCpuAbi() end

--- 获取最顶层activity名称 - 说明:此函数需要开启节点服务或者无障碍服务
---@return any 获取最顶层activity名称
function getCurrentActivity() end

--- 获取设备id号 - 功能说明:获取设备id号
function getDeviceId() end

--- 获取设备别名
function getDevice() end

--- 获取设备dpi
function getDisplayDpi() end

--- 屏幕旋转方向
---@return table 0无旋转 1表示屏幕逆时针旋转90度 2表示屏幕逆时针旋转180度 3表示屏幕逆时针旋转270度
function getDisplayRotate() end

--- 获取屏幕分辨率
---@return any 返回屏幕的尺寸长和宽
function getDisplaySize() end

--- 获取编译版本号
function getFingerprint() end

--- 获取硬件序列号
function getHardware() end

--- 获取id修订号
function getId() end

--- 获取已安装apk
function getInstalledApk() end

--- 获取已安装apk的信息
function getInstalledApps() end

--- 获取制造商代号
function getManufacturer() end

--- 获取型号
function getModel() end

--- 读取整数配置
---@param key any
---@param defval any
---@return number 读取对应键值为key的数值
function getNumberConfig(key, defval) end

--- 获取当前包名
function getPackageName() end

--- 获取产品代号
function getProduct() end

--- 获取sdk版本
function getSdkVersion() end

--- 获取设备sim卡序列号
function getSimSerialNumber() end

--- 读取字符串配置
---@param key any
---@return string 读取对应键值为key的字符串值
function getStringConfig(key) end

--- 获取设备imsi
function getSubscriberId() end

--- 读取UI配置
---@param configName any
---@return table result:数组类型返回用户的配置键值对
function getUIConfig(configName) end

--- 获取wifi mac地址
function getWifiMac() end

--- 获取云控引擎加载传入的参数
function getYkArg() end

--- 安装apk
-- 语法: installApk(apkpath,[callback])
---@param apkpath any 待安装的apk的绝对路径
---@param callback any 函数类型,如果该变量不为空那么是静默安装, 并在回调方法中返回安装成功结果.如果该变量为空则是普通安装，需要手动操作
function installApk(apkpath, callback) end

--- 安装更新包lr文件，注意此处不是apk
---@param lrpath any 待安装的更新包文件绝对路径
function installLrPkg(lrpath) end

--- 保持屏幕长亮 - 功能说明:保持屏幕不熄灭，一直长亮
function lockScreen() end

--- 拨号或者打出
---@param number any
---@param state any
function phoneCall(number, state) end

--- 播放音乐
---@param audio_path any
function playAudio(audio_path) end

--- 调试输出
---@param str any
function printEx(str) end

--- 读取剪贴板
---@return string 返回剪贴板内容
function readPasteboard() end

--- 重置用户数据配置
function resetConfig() end

--- 恢复为默认的系统分辩率和dpi - 说明:此方法不能在无障碍模式下使用
---@return boolean 布尔类型，true成功，false失败
function resetDisplaySize() end

--- 重置ui窗口布局到默认配置
---@param configName any
function resetUIConfig(configName) end

--- 重启当前脚本
function restartScript() end

--- 生成随机数
---@param min any
---@param max any
function rnd(min, max) end

--- 打开app
-- 语法: runApp(package_name,[component_name],[is_open_by_super])
---@param package_name any 字符串型,某个应用程序的包名
---@param component_name any 可选参数,字符串型,某个应用程序的组件名,可省略
---@param is_open_by_super any 可选参数,布尔类型,表示是否用最高权限去打开
---@return any 空
function runApp(package_name, component_name, is_open_by_super) end

--- 打开一个意图(部分手机需要开启允许后台弹窗才能正常运行)
---@param intent any
---@return boolean 布尔类型
function runIntent(intent) end

--- 刷新图片文件到图库
---@param imagepath any
function scanImage(imagepath) end

--- 发动短信
---@param number any
---@param content any
function sendSms(number, content) end

--- 打开或关闭飞行模式
---@param state any
function setAirplaneMode(state) end

--- 打开或关闭蓝牙
---@param state any
function setBTEnable(state) end

--- 设置悬浮窗位置 - 功能说明:设置悬浮窗位置
---@param x any
---@param y any
function setControlBarPosNew(x, y) end

--- 设置悬浮窗位置 - 功能说明:设置悬浮窗位置
---@param pos any
---@param type any
function setControlBarPos(pos, type) end

--- 设置真实的物理分辨率和dpi - 说明:此方法不能在无障碍模式下使用
-- 语法: setDisplaySize(w,h,[dpi])
---@param w any 整数类型，表示宽度
---@param h any 整数类型，表示高度
---@param dpi any 整数类型，默认可以不填写
---@return boolean 布尔类型，true成功，false失败
function setDisplaySize(w, h, dpi) end

--- 写入整数键值对
---@param key any
---@param value any
function setNumberConfig(key, value) end

--- 设置停止脚本的回调函数 - 功能说明:如果想在脚本结束的时候能处理一些收尾的事情可以用此方法设置结束时的回调方法 注意使用此方法的回调函数中不能使用ui显示操作
function setStopCallBack() end

--- 写入键值对
---@param key any
---@param value any
function setStringConfig(key, value) end

--- 设置悬浮按钮菜单自定义事件回调函数(注意只有新版悬浮菜单才能触发此回调函数) - 功能说明:用户通过点击悬浮按钮菜单来触发一个事件给脚本
---@param cb any
function setUserEventCallBack(cb) end

--- 打开或关闭wifi
---@param state any
function setWifiEnable(state) end

--- 显示或者隐藏悬浮按钮
---@param isShow any
function showControlBar(isShow) end

--- 休眠
---@param time any
function sleep(time) end

--- 关闭app
---@param package_name any 字符串型,某个应用程序的包名
---@return any 空
function stopApp(package_name) end

--- 关闭播放音乐
function stopAudio() end

--- 释放屏幕长亮
function unLockScreen() end

--- 解压zip文件到指定的目录
---@param zippath any
---@param outdir any
---@param pass any 字符类型，解压密码，没有密码可以不填写
function unZip(zippath, outdir, pass) end

--- 震动 - 功能说明:震动设备
function vibrate() end

--- 写数据到剪贴板
---@param str any
---@return any 无
function writePasteboard(str) end

--- zip 压缩文件
---@param file any
---@param zippath any
function zip(file, zippath) end

-- 网路方法

--- HTTP GET请异步求
-- 语法: asynHttpGet(callback,url,[timeout],[header])
---@param callback any 函数类型，当服务器响应返回数据时调用该函数
---@param url any GET请求的网络地址可带参数
---@param timeout any 请求超时时间单位是秒可不填写默认30秒
---@param header any http请求头默认为空
---@return any 无
function asynHttpGet(callback, url, timeout, header) end

--- HTTP POST异步请求
-- 语法: asynHttpPost(callback,url,postdata,[timeout],[header])
---@param callback any 函数类型，当服务器响应返回数据时调用该函数
---@param url any POST请求的网络地址可带参数
---@param postdata any 字符出类型，POST传递的数据
---@param timeout any 请求超时时间单位是秒可不填写默认30秒
---@param header any http请求头默认为空
---@return any 无
function asynHttpPost(callback, url, postdata, timeout, header) end

--- 关闭一个websocket连接
---@param handle any 数字类型，由startWebSocket返回的句柄 使用事项:该函数只能在主线程中使用，所以需要在子线程中触发此函数可以调用setTimer在回调函数中调用关闭
---@return boolean 布尔类型，true成功，false失败
function closeWebSocket(handle) end

--- 关闭一个websocket连接
---@param handle any 数字类型，由startWebSocket返回的句柄 使用事项:该函数只能在主线程中使用，所以需要在子线程中触发此函数可以调用setTimer在回调函数中调用关闭
---@return boolean 布尔类型，true成功，false失败
function closeWebSocket(handle) end

--- HTTP GET请求
-- 语法: httpGet(url,[timeout],[header])
---@param url any GET请求的网络地址可带参数
---@param timeout any 请求超时时间单位是秒可不填写默认30秒
---@param header any http请求头默认为空
---@return string http响应状态码
function httpGet(url, timeout, header) end

--- HTTP POST请求
-- 语法: httpPost(url,postdata,[timeout],[header])
---@param url any POST请求的网络地址可带参数
---@param postdata any 字符出类型，POST传递的数据
---@param timeout any 请求超时时间单位是秒可不填写默认30秒
---@param header any http请求头默认为空
---@return string 字符串类型，http响应状态码
function httpPost(url, postdata, timeout, header) end

--- import 加载java类 - 功能说明:此方法是为了能更加方便扩展安卓原生调用，具体详细的使用例子请进群下载 注意事项:此方法只支持android端，后续ios端不支持此方法
---@param className any 字符串类型,表示一个java类名
function import(className) end

--- LuaEngine.getContext 获取android上下文对象
---@return table 获取android上下文对象
function LuaEngine.getContext() end

--- LuaEngine.httpGet java层http get
---@param url any 字符串类型,访问的网络地址 params：数组类型，参数键值对
---@param params any
---@param timeout any 整数型，超时时间
function LuaEngine.httpGet(url, params, timeout) end

--- LuaEngine.httpPostData java层http post 任意数据
---@param url any 字符串类型,访问的网络地址 params：字符串类型 headers：字符串类型
---@param params any
---@param headers any
---@param timeout any 整数型，超时时间
function LuaEngine.httpPostData(url, params, headers, timeout) end

--- LuaEngine.httpPost java层http post
---@param url any 字符串类型,访问的网络地址 params：数组类型，参数键值对 headers：数组类型，通params一样
---@param params any
---@param headers any
---@param timeout any 整数型，超时时间
function LuaEngine.httpPost(url, params, headers, timeout) end

--- LuaEngine.loadApk 加载一个apk插件 - 说明:此函数还可以加载autojs的插件
---@param name any 字符串类型，如果apk插件放到资源中则只需要写名字，如果需要从sd卡加载则这里写绝对路径
---@return table 返回一个插件对象
function LuaEngine.loadApk(name) end

--- LuaEngine.sendMailWithFile 发送一个带附件的邮件
-- 语法: LuaEngine.sendMailWithFile(账号,密码,发送给谁,邮箱服务器,是否开启认证,邮件标题,邮件内容,文件路径,[发送结果回调])
---@param 账号 any 字符串类型,需要用此账号的邮箱去发送邮件 密码：字符串类型 发送给谁：字符串类型
---@param 密码 any
---@param 发送给谁 any
---@param 邮箱服务器 any 字符串类型
---@param 是否开启认证 any 布尔类型 邮件标题：字符串类型 邮件内容：字符串类型
---@param 邮件标题 any
---@param 邮件内容 any
---@param 文件路径 any 字符串类型 发送结果回调：函数类型用于接收发送结果状态，可以不填写
---@param 发送结果回调 any
function LuaEngine.sendMailWithFile(账号, 密码, 发送给谁, 邮箱服务器, 是否开启认证, 邮件标题, 邮件内容, 文件路径, 发送结果回调) end

--- LuaEngine.snapShot java层截图方法
---@param l any
---@param t any
---@param r any
---@param b any
---@return table 返回一个java的Bitmap对象，记得一定要释放避免内存泄漏
function LuaEngine.snapShot(l, t, r, b) end

--- 关闭数据库连接
---@param handle any 整数类型，由mysql_connect返回
---@return boolean 布尔值
function mysql_close(handle) end

--- 连接mysql数据库
---@param host any 字符串类型,MYSQL服务器地址
---@param port any 数字类型,MYSQL服务端口号
---@param database any 字符串类型,要访问的数据库名称
---@param user any 字符串类型,访问数据库的账号名称（如果没有不用填写）
---@param password any 字符串类型,访问数据库密码（如果没有不用填写）
---@return table 返回两个值，第一个表示该连接的唯一句柄如果为空表示失败，第二个结果是失败原因
function mysql_connect(host, port, database, user, password) end

--- 执行sql语句并返回结果
---@param handle any 整数类型，由mysql_connect返回
---@param sql any 字符串类型，sql语句，请参考sql语法
---@return boolean 返回值有三个第一个布尔类型表示是否成功，第二个是失败原因，第三个是执行成功返回的数据表结果
function mysql_execSQLWithResult(handle, sql) end

--- 执行sql语句
---@param handle any 整数类型，由mysql_connect返回
---@param sql any 字符串类型，sql语句，请参考sql语法
---@return boolean 返回值有两个个第一个布尔类型表示是否成功，第二个是失败原因
function mysql_execSQL(handle, sql) end

--- 读取键值对
---@param key any 字符串类型，键值，读取后会自动将此键值对从全局表中删除
---@return string 字符串类型
function readKeyVal(key) end

--- 向服务器发送数据
---@param handle any 数字类型，由startWebSocket返回的句柄
---@param text any 字符串类型，待发送的字符串
---@return boolean 布尔类型，true成功，false失败
function sendWebSocket(handle, text) end

--- 打开一个websocket连接
---@param url any ws地址,目前只支持ws协议wss暂不支持 onOpend:当连接服务器成功后会回调这个函数
---@param onOpened any
---@param onClosed any 当连接服务器断开后会回调这个函数
---@param onError any 当连接服务器失败后会回调这个函数
---@param onRecv any 当有接收到数据时会回调这个函数 使用事项:以上所有回调函数是在单独的一个线程里面，请不要在回调函数中阻塞运行 或者调用停止(exitScript)或者重启脚本(restartScript)函数，如果非要使用请在setTimer回调函数中执行， 因为setTimer回调函数是运行在主线程中
---@return number 返回一个数字类型，表示这个websocket链接的句柄
function startWebSocket(url, onOpened, onClosed, onError, onRecv) end

--- 上传文件
-- 语法: uploadFile(url,uploadfile,[timeout])
---@param url any 请求的网络地址
---@param uploadfile any 要上传到服务器的文件路径
---@param timeout any
---@return string 返回服务器的response字符串
function uploadFile(url, uploadfile, timeout) end

--- 写键值对
---@param key any
---@param val any
---@return boolean 布尔值
function writeKeyVal(key, val) end

-- 扩展方法

--- bdOcr 百度ocr
-- 语法: bdOcr(url,apikey,secretkey,[type])
---@param url any
---@param apikey any
---@param secretkey any
---@param type any 可以取值0,1,2,3 ,0:通用文字识别 1:通用文字识别（含位置信息版）,2:通用文字识别（高精度版）,3:通用文字识别（高精度含位置版）
---@return any 返回一个json 例子如:{"words_result":[{"words":"名称:ur.r"},{"words":"大小:1KB"}],"log_id":1302556202114220032,"words_result_num":2}
function bdOcr(url, apikey, secretkey, type) end

--- 启动一个新的线程，注意新线程无法使用exitScript 和 restartScript，
---@param callback any
---@param ... any
---@return table 线程标识符，为空表示失败
function beginThread(callback, ...) end

--- binaryImage二值化本地图片,图片格式可以是png bmp jpg三种类型
-- 语法: binaryImage(srcimage,dstimage,[ThresholdTypes],[thresh],[maxthresh]))
---@param srcimage any
---@param dstimage any
---@param ThresholdTypes integer (THRESH_BINARY = 0,THRESH_BINARY_INV = 1,THRESH_TRUNC = 2,THRESH_TOZERO = 3,THRESH_TOZERO_INV = 4,THRESH_MASK = 7,THRESH_OTSU = 8,THRESH_TRIANGLE = 16)具体含义请查看opencv文档，默认不写是8(THRESH_OTSU)
---@param thresh any 整数型，阈值默认不写是150 maxthresh：整数型，最大阈值，默认不写255
---@param maxthresh any
---@return table 1表示成功0表示失败
function binaryImage(srcimage, dstimage, ThresholdTypes, thresh, maxthresh) end

--- binaryRect 区域截图二值化,保存的图片格式可以是png bmp jpg三种类型
-- 语法: binaryRect(save,l,t,r,b,[ThresholdTypes],[thresh],[maxthresh])
---@param save any
---@param l any
---@param t any
---@param r any
---@param b any
---@param ThresholdTypes integer (THRESH_BINARY = 0,THRESH_BINARY_INV = 1,THRESH_TRUNC = 2,THRESH_TOZERO = 3,THRESH_TOZERO_INV = 4,THRESH_MASK = 7,THRESH_OTSU = 8,THRESH_TRIANGLE = 16)具体含义请查看opencv文档，默认不写是8(THRESH_OTSU)
---@param thresh any 整数型，阈值默认不写是150 maxthresh：整数型，最大阈值，默认不写255
---@param maxthresh any
---@return table 1表示成功0表示失败
function binaryRect(save, l, t, r, b, ThresholdTypes, thresh, maxthresh) end

--- 清除日志文件
---@return any 无
function clearLog() end

--- base64字符串解码
---@param str any
---@return any base64解码结果
function decodeBase64(str) end

--- decodeUrl url格式解码
---@param str any
---@return any url解码结果
function decodeUrl(str) end

--- delfile 删除文件或文件夹
---@param dir any
---@return boolean true表示成功false失败
function delfile(dir) end

--- 字符串base64编码
---@param str any
---@return any base64编码结果
function encodeBase64(str) end

--- encodeUrl 格式编码为url格式
---@param str any
---@return string 编码后的url字符串
function encodeUrl(str) end

--- fileExist 文件是否存在
---@param file any
---@return boolean true表示存在false不存在
function fileExist(file) end

--- 获取文件的MD5码
---@param path string 要MD5编码的文件绝对路径
function fileMD5(path) end

--- 获取文件的MD5码
---@param str string 要MD5编码的字符串
function MD5(str) end

--- 获取文件内容的base64编码
---@param path string 文件的路径
function getFileBase64(path) end

--- 获取文件的大小
---@param path string 文件路径
---@return number 文件大小 单位字节
function fileSize(path) end

--- mkdir 创建文件夹
---@param dir any
---@return boolean true表示成功false失败
function mkdir(dir) end

--- 二维码解析
---@param pngpath any
---@return number ret 为1表示成功0表示失败 text是返回解析的结果
---@return string text 返回解析的结果
function qrDecode(pngpath)
    local ret, text
    return ret, text
end

--- readFile 读取文件所有内容
---@param path any
---@return any 读取的文件数据
function readFile(path) end

--- rotateImage 旋转本地图片,图片格式可以是png bmp jpg三种类型
---@param path string 文件的路径
---@param rotate integer 90 180 270三种值，此处为顺时针旋转
---@return integer 1表示成功0表示失败
function rotateImage(path, rotate) end

--- scaleImage 缩放图片,图片格式可以是png bmp jpg三种类型
---@param src any
---@param dst any
---@param w any
---@param h any
---@return boolean true表示成功false表示失败
function scaleImage(src, dst, w, h) end

--- 停止一个线程
---@param tid any
function stopThread(tid) end

--- useRes 指定资源文件为默认查找的对象 - 说明:指定为默认查找对象后图色以及资源获取都是默认从此rc文件中获取
---@param name any
function useRes(name) end

--- writeFile 写字符串到文件
-- 语法: writeFile(path,str,[append])
---@param path any
---@param str any
---@param append any
---@return boolean 布尔类型
function writeFile(path, str, append) end

--- log 写日志到文件，日志文件存放在sd卡下脚本包名目录下的log文件夹中例如/mnt/sdcard/com.nx.nxproj/log/log.txt
---@param str any
---@return any 无
function writeLog(str) end

-- 触控方法

--- 捕捉点击屏幕坐标 - 功能说明:调用该函数后，将等待用户完成一次或多次屏幕点击，并返回点击的坐标 注意:此函数不支持在无障碍模式下使用，只能在激活或者root模式下使用，获取运行环境类型函数为getRunEnvType
---@param count any 捕捉触摸屏幕的次数
---@return number 返回一个数组类型，数组长度为触摸的次数，数组内容是每次触摸的坐标值
function catchTouchPoint(count) end

--- 模拟输入文字
-- 语法: inputText(text,[needsetime])
---@param text any 文本类型
---@param needsetime any 布尔类型，如果设置为true表明需要自己设置输入法设置方法是setIme
---@return any 无
function inputText(text, needsetime) end

--- 按下一个按键不弹起
---@param keycode any 按键标识符或者数字按键码 按键码名称 标识符和按键码对应如下 ------------------------------------ 名称 标识符合 按键码 主页键 Home 3 返回键 Back 4 打电话 Call 5 挂电话 EndCall 6 音量增加 VolUp 24 音量减少 VolDown 25 电源键 Power 26 相机键 Camera 27 菜单键 Menu 82 向上翻页 PageUp 92 向下翻页 PageDown 93 -------------------------------------
---@return any 无
function keyDown(keycode) end

--- 按一下按键并弹起
---@param keycode any 按键标识符或者数字按键码 按键码名称 标识符和按键码对应如下 ------------------------------------ 名称 标识符合 按键码 主页键 Home 3 返回键 Back 4 RECENT键 Recent 187 打电话 Call 5 挂电话 EndCall 6 音量增加 VolUp 24 音量减少 VolDown 25 电源键 Power 26 相机键 Camera 27 菜单键 Menu 82 向上翻页 PageUp 92 向下翻页 PageDown 93 -------------------------------------
---@return any 无
function keyPress(keycode) end

--- 弹起一个按键
---@param keycode any 按键标识符或者数字按键码 按键码名称 标识符和按键码对应如下 ------------------------------------ 名称 标识符合 按键码 主页键 Home 3 返回键 Back 4 打电话 Call 5 挂电话 EndCall 6 音量增加 VolUp 24 音量减少 VolDown 25 电源键 Power 26 相机键 Camera 27 菜单键 Menu 82 向上翻页 PageUp 92 向下翻页 PageDown 93 -------------------------------------
---@return any 无
function keyUp(keycode) end

--- 设置输入法，配合inputText使用
---@param isLrIme any 布尔值类型，是否设置懒人自带输入法，true是懒人自带输入，false为系统输入法
---@return boolean 布尔值
function setIme(isLrIme) end

--- 模拟从一点滑动到另外一点
---@param x1 integer 划动的起点x坐标
---@param y1 integer 划动的起点y坐标
---@param x2 integer 划动的终点x坐标
---@param y2 integer 划动的终点y坐标
---@param time integer 滑动到x,y坐标点所需要的时间单位是毫秒
---@return any 无
function swipe(x1, y1, x2, y2, time) end

--- 点击坐标为x,y的点
---@param x integer 当前屏幕横坐标
---@param y integer 当前屏幕纵坐标
---@return any 无
function tap(x, y) end

--- 按住不放
---@param id any 模拟手指的索引号0-4之间
---@param x integer 当前屏幕横坐标
---@param y integer 当前屏幕纵坐标
---@return any 无
function touchDown(id, x, y) end

--- 模拟滑动增强版
---@param id any 模拟手指的索引号0-4之间
---@param x integer 当前屏幕横坐标
---@param y integer 当前屏幕纵坐标
---@param time integer 滑动到x,y坐标点所需要的时间单位是毫秒
---@return any 无
function touchMoveEx(id, x, y, time) end

--- 模拟滑动
---@param id any 模拟手指的索引号0-4之间
---@param x integer 当前屏幕横坐标
---@param y integer 当前屏幕纵坐标
---@return any 无
function touchMove(id, x, y) end

--- 弹起手指
---@param id any 模拟手指的索引号0-4之间
---@return any 无
function touchUp(id) end

-- 互交方法

--- 创建一个HUD用于显示 - 功能说明:HUD是一个悬浮在屏幕上的画面可以实时更新
---@return number 是一个HUD实例句柄
function createHUD() end

--- 获取按钮标题内容 - 功能说明:获取当前窗口中指定id的按钮的标题，可以在点击事件或者加载完成事件中获取
---@param handle any
---@param id any
function getButtonText(handle, id) end

--- 获取多选组合框当前选项 - 功能说明:获取当前窗口中指定id的多选组合框当前选项，可以在点击事件或者加载完成事件中获取
---@param handle any
---@param id any
function getCheckGroupSel(handle, id) end

--- 获取下拉框当前选项 - 功能说明:获取当前窗口中指定id的下拉框当前选项，可以在点击事件或者加载完成事件中获取
---@param handle any
---@param id any
function getDropSel(handle, id) end

--- 获取输入框文本 - 功能说明:获取当前窗口中指定id的文本框中的文本，可以在点击事件或者加载完成事件中获取
---@param handle any
---@param id any
function getEditText(handle, id) end

--- 获取静态Lable的文本 - 功能说明:获取当前窗口中指定id的Lable中的文本，可以在点击事件或者加载完成事件中获取
---@param handle any
---@param id any
function getLableText(handle, id) end

--- 获取单选组合框当前选项 - 功能说明:获取当前窗口中指定id的单选组合框当前选项，可以在点击事件或者加载完成事件中获取
---@param handle any
---@param id any
function getRadioGroupSel(handle, id) end

--- 获取控件状态是否可用 - 功能说明:获取控件状态是否可用，可以在点击事件或者加载完成事件中获取
---@param handle any
---@param id any
function getViewEnable(handle, id) end

--- 获取控件是否可见 - 功能说明:获取控件是否可见，可以在点击事件或者加载完成事件中获取
---@param handle any
---@param id any
---@return number 返回一个整数值:当取值为8表示隐藏控件不占据ui的布局空间，4表示隐藏控件但是依然占据布局空间，0是显示控件
function getViewVisible(handle, id) end

--- 隐藏并销毁HUD
---@param id any 整:数型,用于标示HUD
---@return any 无 注意:调用此方法后不能再用当前id句柄继续showHUD，如果需要调用showHUD需要重新createHUD
function hideHUD(id) end

--- 关闭消息显示
function hideToast() end

--- 设置按钮标题内容 - 功能说明:设置当前窗口中指定id的按钮标题，可以在点击事件或者加载完成事件中设置
---@param handle any
---@param id any
---@param text any
function setButtonText(handle, id, text) end

--- 设置多选组合框选中某几项 - 功能说明:设置当前窗口中指定id的单选组合框的某几项被选中，可以在点击事件或者加载完成事件中设置
---@param handle any
---@param id any
---@param sel any
function setCheckGroupSel(handle, id, sel) end

--- 设置下拉框选中某一项 - 功能说明:设置当前窗口中指定id的下拉框的某一项被选中，可以在点击事件或者加载完成事件中设置
---@param handle any
---@param id any
---@param sel any
function setDropSel(handle, id, sel) end

--- 设置输入框内容 - 功能说明:设置当前窗口中指定id的文本框的文本，可以在点击事件或者加载完成事件中设置
---@param handle any
---@param id any
---@param text any
function setEditText(handle, id, text) end

--- 设置Lable内容 - 功能说明:设置当前窗口中指定id的Lable的文本，可以在点击事件或者加载完成事件中设置
---@param handle any
---@param id any
---@param text any
function setLableText(handle, id, text) end

--- 设置单选组合框选中某一项 - 功能说明:设置当前窗口中指定id的单选组合框的某一项被选中，可以在点击事件或者加载完成事件中设置
---@param handle any
---@param id any
---@param sel any
function setRadioGroupSel(handle, id, sel) end

--- 给指定窗口ui加载一个配置 - 说明:handle是窗口的句柄,config 是一个json字符串，可以在点击事件或者加载完成事件中设置
---@param handle any
---@param config any
function setUIConfigEx(handle, config) end

--- 给指定窗口ui加载一个配置 - 说明:handle是窗口的句柄,json是要加载的配置字符串{"id1":"value1","id2":"value2"},可以在点击事件或者加载完成事件中设置
---@param handle any
---@param json any
function setUIConfig(handle, json) end

--- 设置控件状态是否可用 - 功能说明:设置控件状态是否可用，如果设置为false那么控件将失去焦点无法接受事件， 可以在点击事件或者加载完成事件中设置
---@param handle any
---@param id any
---@param enable any
function setViewEnable(handle, id, enable) end

--- 设置浏览器的js回调函数
---@param handle any
---@param id any
---@param cb any
function setWebViewJsCallBack(handle, id, cb) end

--- 设置浏览器地址 - 功能说明:设置当前窗口中指定id的浏览器的url，可以在点击事件或者加载完成事件中设置
---@param handle any
---@param id any
---@param url any
function setWebViewUrl(handle, id, url) end

--- 显示HUD或者刷新 - 功能说明:显示更新HUD
-- 语法: showHUD(id,text,size,color,bg,pos,x,y,width,height,[leftpadding,toppadding,rightpadding,bottompadding],[align_text])
---@param id any 整:数型,用于标示HUD
---@param text any 文本型,提示信息,将在屏幕上以HUD形式显示
---@param size integer 表:示提示信息的字体大小
---@param color any 文本型,表示提示信息的字体颜色，格式为ARGB
---@param bg any 文本型,表示提示信息的背景颜色，可以是ARGB，也可以是图片文件名称
---@param pos integer 表示提示信息的原点位置，0 - 左上角，1 - 居中，2 - 水平居中， 3 - 垂直居中 x,y:整数型,表示提示信息相对原点的坐标偏移值 width,height:整数型,表示提示信息显示的宽高
---@param x any
---@param y any
---@param width any
---@param height any
---@param leftpadding any 左边内边距默认不填写是3
---@param toppadding any 上边内边距默认不填写是3
---@param rightpadding any 右边内边距默认不填写是3
---@param bottompadding any 下边内边距默认不填写是3
---@param align_text any 文本对齐方式默认不写为1， 0左上 1居中 2上水平居中 3左垂直居中 4左下 5右上 6右边垂直居中 7右下 8下水平居中
---@return any 无
function showHUD(id, text, size, color, bg, pos, x, y, width, height, leftpadding, toppadding, rightpadding,
                 bottompadding, align_text)
end

--- 显示一个自定义的界面,这个是showUI的扩展版本，该方法可以设置窗口的坐标位置 - 功能说明:显示一个用户自定义弹窗界面,当窗口关闭时返回配置数据
-- 语法: showUIEx(uifile,[x],[y],[w],[h],[loadEvent],[clickEvent],[closeEvent])
---@param uifile any 可以是一个ui文件名称或路径，也可以是ui文件的字符串形式 x,y 整数型, 可选项,设置悬浮窗的位置 w,h:整数型, 可选项,设置此值来改变窗口的大小 loadEvent,clickEvent,closeEvent,selectEvent:函数类型,可选项, 设置此值可以触发窗口的加载完成事件,以及多选框，单选框，组合框选中事件(多选框选中和被反选都会有触发)， 窗口中按钮的点击事件，窗口的关闭事件，说明一下，不要在窗口关闭事件中设置或者获取窗口中控件的属性值， 因为此时窗口已经被摧毁，可以通过showUI的返回值获取
---@param x any
---@param y any
---@param w any
---@param h any
---@param loadEvent any
---@param clickEvent any
---@param closeEvent any
---@return number ret:整数类型,是一个用户行为，取消或者确定 result:数组类型返回用户的配置键值对
function showUIEx(uifile, x, y, w, h, loadEvent, clickEvent, closeEvent) end

--- 显示一个自定义的界面 - 功能说明:显示一个用户自定义弹窗界面,当窗口关闭时返回配置数据
-- 语法: showUI(uifile,[w],[h],[loadEvent],[clickEvent],[closeEvent])
---@param uifile any 可以是一个ui文件名称或路径，也可以是ui文件的字符串形式 w,h:整数型，可选项,设置此值来改变窗口的大小 loadEvent,clickEvent,closeEvent,selectEvent:函数类型,可选项, 设置此值可以触发窗口的加载完成事件,以及多选框，单选框，组合框选中事件(多选框选中和被反选都会有触发)， 窗口中按钮的点击事件，窗口的关闭事件，说明一下，不要在窗口关闭事件中设置或者获取窗口中控件的属性值， 因为此时窗口已经被摧毁，可以通过showUI的返回值获取
---@param w any
---@param h any
---@param loadEvent any
---@param clickEvent any
---@param closeEvent any
---@return number ret:整数类型,是一个用户行为，取消或者确定 result:数组类型返回用户的配置键值对
function showUI(uifile, w, h, loadEvent, clickEvent, closeEvent) end

--- 屏幕上显示信息 - 功能说明:在屏幕指定位置弹出信息框，当坐标x,y同时为0的时候，默认向下横向居中显示，5秒后自动消失
-- 语法: toast(text,[x,y,textsize])
---@param text any 要显示的字符串
---@param x integer 屏幕横向坐标，可以不填写默认为0
---@param y integer 屏幕纵向坐标，可以不填写默认为0
---@param textsize integer 字体大小，可以不填写默认为12
function toast(text, x, y, textsize) end

-- 图色方法

--- 同时比较指定的多个坐标点的颜色，支持多色、偏色、相似度比较此功能和cmpColorEx一样不过
---@param t table {mul_color, sim}
---@return integer 1为完全匹配,0为没有完全匹配到
function cmpColorExT(t) end

--- 同时比较指定的多个坐标点的颜色，支持多色、偏色、相似度比较
---@param mul_color string 需要对比的点xy坐标和16进制颜色,格式为(X坐标|Y坐标|16进制颜色), 多个颜色用“|”号分隔,需要偏色用“-”号分隔,多个点信息用“,”号分隔， 比如"100|200|FFFFFF|123456-000000,300|500|FFFFFF"
---@param sim number 相似度,取值范围0-1
---@return any 整型，1为完全匹配,0为没有完全匹配到
function cmpColorEx(mul_color, sim) end

--- 指定坐标颜色比对
---@param x integer 需要对比颜色的X坐标
---@param y integer 需要对比颜色的Y坐标
---@param color string 待比较的16进制颜色,格式为"BBGGRR",多个颜色用“|”号分隔, 支持偏色,比如"787878-101010|123456"
---@param sim number 相似度,取值范围0-1
---@return any 整型，1为匹配到,0为没有匹配到
function cmpColor(x, y, color, sim) end

--- 颜色比对
---@param color1 any 16进制颜色,格式为"BBGGRR",或者10进制颜色 color2：16进制颜色,格式为"BBGGRR",或者10进制颜色
---@param color2 any
---@return number 整数型:两个颜色的红、绿、蓝三个分量的差值之总和
function colorDiff(color1, color2) end

--- 颜色比对
---@param color any 16进制颜色,格式为"BBGGRR",或者10进制颜色
---@return number r:整数型,十进制颜色红分量 g:整数型,十进制颜色绿分量 b:整数型,十进制颜色蓝分量
function colorToRGB(color) end

--- 创建一个tresseract-ocr(4.1.0)本地光学ocr对象 - 说明:请下载群里的光学ocr训练工具可以自己针对性的训练自己的字库
-- 语法: createOcr(lang,[mode],[engine])
---@param lang any 字符串型,字库语言文件名称，不填则默认eng(只支持一般的中英+数字+标点符号), 注意lang也可以是字库文件的绝对路径，如果字库比较大，那么建议先把字库放到手机sd卡下测试， 不然如果放到资源文件中，数据包会很大导致调试速度很慢
---@param mode any 整数型 0 仅检测方向和文本 1 自动检测方向和文本(OSD) 2 自动检测，但不进行OSD或OCR处理 3 自动PSM模式(但不含OSD) 4 所识别图片的字体大小不一 5 所识别图片当作整块竖向文字区域 6 所识别图片当作整块横向文字区域 (默认值) 7 所识别图片当作一行文字 8 所识别图片当作单个词语 9 所识别图片当作单个圆型围绕的词语 10 所识别图片当作单个英文/数字字符 11 尽可能识别更多的字符(无顺序要求) 12 分散稀疏的OSD检测
---@param engine any 整数型 0 OEM_TESSERACT_ONLY 老版本训练引擎 1 OEM_LSTM_ONLY 新版本基于神经网络的训练引擎 3 OEM_DEFAULT 默认引擎
---@return table 一个tresseract-ocr对象句柄
function createOcr(lang, mode, engine) end

--- 霍夫变换找圆
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标 dp，累加面分辨率
---@param dp any
---@param minDist any 两个圆心之间的最小距离.
---@param param1 any Canny 边缘检测的高阈值，低阈值被自动置为高阈值的一半,默认为 100.
---@param param2 any 累加平面某点是否是圆心的判定阈值。它越大，能通过检测的圆就更接近完美的圆形,默认为 100.
---@param minRadius any 圆半径的最小值.默认为 0.
---@param maxRadius any 圆半径的最大值,默认为 0.
---@return table ret:数组类型{{x=centerX,y=centerY,r=radius},{x=centerX1,y=centerY1,r=radius1}}
function findCircle(x1, y1, x2, y2, dp, minDist, param1, param2, minRadius, maxRadius) end

--- 在指定区域内查找指定的颜色，功能和findColor一样不过参数
---@param t table {x1,y1,x2,y2,color,dir,sim}
---@return any ret:如果有多个颜色用"|"分割,则对应找到的索引 x,y 对应找到的坐标
function findColorT(t) end

--- 在指定区域内查找指定的颜色
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param color any
---@param dir integer 查找方向 0: 表示从左上向右下； 1: 表示从中心往四周查找； 2: 表示从右下向左上查找； 3: 表示从左下向右上查找； 4：表示从右上向左下查找
---@param sim any
---@return any ret:如果有多个颜色用"|"分割,则返回结果为对应找到的索引 x,y 对应找到的坐标
function findColor(x1, y1, x2, y2, color, dir, sim) end

--- opencv模板匹配找图
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param pic_name string 要找的图片名字,多个图片用“|”号分隔
---@param sim number 相似度,取值范围0-1
---@return any ret:如果有多个颜色用"|"分割,则对应找到的索引 x,y 对应找到的坐标
function findImage(x1, y1, x2, y2, pic_name, sim) end

--- 区域多点找色,和findMultiColorAll一样不过参数是一个数组,这样做的目的是为了提高开发效率
---@param t table {x1, y1, x2, y2, first_color, offset_color, dir, sim}
---@return table 如果成功返回所有满足要求的表格数组
function findMultiColorAllT(t) end

--- 区域多点找色
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param first_color any 要对比的16进制颜色,多个颜色用"|"号分隔, 如果需要对比偏色则中间用“-”号分隔,比如"888888|123456-000000|00FF00-101010"
---@param offset_color string 偏移颜色
---@param dir integer 查找方向. 0:表示从左上向右下查找; 1:表示从中心往四周查找; 2:表示从右下向左上查找; 3:表示从左下向右上查找; 4:表示从右上向左下查找;
---@param sim number 相似度,取值范围0-1
---@return table 如果成功返回所有满足要求的表格数组
function findMultiColorAll(x1, y1, x2, y2, first_color, offset_color, dir, sim) end

--- 区域多点找色,和findMultiColor一样不过参数是一个数组,这样做的目的是为了提高开发效率
---@param t table {x1, y1, x2, y2, first_color, offset_color, dir, sim}
---@return number n 如果成功返回对应点的坐标x,y,否则返回-1,-1
function findMultiColorT(t)
    local n
    return n
end

--- 区域多点找色
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param first_color any 要对比的16进制颜色,多个颜色用"|"号分隔, 如果需要对比偏色则中间用“-”号分隔,比如"888888|123456-000000|00FF00-101010"
---@param offset_color string 偏移颜色
---@param dir integer 查找方向. 0:表示从左上向右下查找; 1:表示从中心往四周查找; 2:表示从右下向左上查找; 3:表示从左下向右上查找; 4:表示从右上向左下查找;
---@param sim number 相似度,取值范围0-1
---@return number x 如果成功返回对应点的坐标x,否则返回-1
---@return number y 如果成功返回对应点的坐标y,否则返回-1
function findMultiColor(x1, y1, x2, y2, first_color, offset_color, dir, sim)
    local x, y
    return x, y
end

--- 图片查找获取要查找图片在所选区域中的所有坐标
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param pic_name string 要找的图片名字,注意这里是单个图片的查找
---@param sim number 相似度,取值范围0-1
---@return table ret:返回一个坐标数组
function findPicAllPoint(x1, y1, x2, y2, pic_name, sim) end

--- 高级区域找图
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param pic_name string 要找的图片名字,多个图片用“|”号分隔
---@param sim number 相似度,取值范围0-1
---@return any ret:如果有多个颜色用"|"分割,则对应找到的索引 x,y 对应找到的坐标
function findPicEx(x1, y1, x2, y2, pic_name, sim) end

--- 区域找图
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param pic_name string 要找的图片名字,多个图片用“|”号分隔
---@param delta_color any 16进制字符串,偏色
---@param dir integer 查找方向: 0:表示从左上向右下查找; 1:表示从中心往四周查找; 2:表示从右下向左上查找; 3:表示从左下向右上查找; 4:表示从右上向左下查找;
---@param sim number 相似度,取值范围0-1
---@return any ret:如果有多个颜色用"|"分割,则对应找到的索引 x,y 对应找到的坐标
function findPic(x1, y1, x2, y2, pic_name, delta_color, dir, sim) end

--- 区域文字查找
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param text string 要找的文字,多个图片用“|”号分隔
---@param colorfmt string 文字的颜色格式
---@param sim number 相似度,取值范围0-1
---@return any ret:如果有多个颜色用"|"分割,则对应找到的索引 x,y 对应找到的坐标
function findStr(x1, y1, x2, y2, text, colorfmt, sim) end

--- 获取区域颜色数量，支持多色、偏色、相似度比较
---@param x1 integer 区域左上X坐标
---@param y1 integer 区域左上Y坐标
---@param x2 integer 区域右下X坐标
---@param y2 integer 区域右下Y坐标
---@param color string 要找的16进制颜色,格式为"BBGGRR",多个颜色用“|”号分隔,支持偏色, 比如"FFFFFF-000000|123456"
---@param sim number 相似度,取值范围0-1
---@return number n 指定区域颜色匹配相同的像素点个数
function getColorNum(x1, y1, x2, y2, color, sim) end

--- 获取指定坐标处屏幕的颜色值
-- 语法: getPixelColor(x,y,[type])
---@param x any
---@param y any
---@param type any
---@return any 返回指定坐标处的颜色值
function getPixelColor(x, y, type) end

--- 获取指定范围内的像素数组
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@return number w 是获取范围的长,如果w,h小于0则表明失败
---@return number h 是获取范围的高,如果w,h小于0则表明失败
---@return number arr 是返回的数组,如果w,h小于0则表明失败
function getScreenPixel(x1, y1, x2, y2) end

--- 检测屏幕区域所有色点是否变化 - 说明:该方法会阻塞住，等待颜色发生改变，区域内颜色一旦发生变化立刻返回
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param time integer 等待的时间单位是秒
---@return boolean ret:true表示没有变化，false有变化
function isDisplayDead(x1, y1, x2, y2, time) end

--- 截图到内存 - 功能说明:截取当前屏幕内容保留在内存,可以供后续图色查找
function keepCapture() end

--- 二值化本地神经网络ocr - 说明:这些参数可以通过群里的神经网络ocr.exe工具进行调试到自己满意值后直接生成代码
-- 语法: ocrj(x1, y1, x2, y2,color_desc,[padding],[maxSlidLen],[boxscoreth],[boxthresh],[clipratio],[doAngle],[mostAngle])
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param color_desc string 文字的颜色格式
---@param padding integer 周围添加隔离空白区域大小,默认不写是50
---@param maxSlidLen integer 长宽按比例缩放最大值，默认不写为0 boxscoreth：浮点类型，框置信度默认不写是0.6 boxthresh：浮点类型，默认0.3 clipratio：框大小倍率，默认2.0 doAngle：布尔类型，是否角度分析默认为true
---@param boxscoreth any
---@param boxthresh any
---@param clipratio any
---@param doAngle any
---@param mostAngle any 布尔类型,是否进行方向分析默认为true
---@return table 数组类型
function ocrj(x1, y1, x2, y2, color_desc, padding, maxSlidLen, boxscoreth, boxthresh, clipratio, doAngle, mostAngle) end

--- 本地神经网络ocr - 说明:这些参数可以通过群里的神经网络ocr.exe工具进行调试到自己满意值后直接生成代码
-- 语法: ocrEx(x1, y1, x2, y2,[padding],[maxSlidLen],[boxscoreth],[boxthresh],[clipratio],[doAngle],[mostAngle])
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param padding integer 周围添加隔离空白区域大小,默认不写是50
---@param maxSlidLen integer 长宽按比例缩放最大值，默认不写为0 boxscoreth：浮点类型，框置信度默认不写是0.6 boxthresh：浮点类型，默认0.3 clipratio：框大小倍率，默认2.0 doAngle：布尔类型，是否角度分析默认为true
---@param boxscoreth any
---@param boxthresh any
---@param clipratio any
---@param doAngle any
---@param mostAngle any 布尔类型,是否进行方向分析默认为true
---@return table 数组类型
function ocrEx(x1, y1, x2, y2, padding, maxSlidLen, boxscoreth, boxthresh, clipratio, doAngle, mostAngle) end

--- 根据选中的字典查找该区域内所有文字和坐标
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param colorfmt string 文字的颜色格式
---@param sim number 相似度,取值范围0-1
---@return string json格式的字符串
function ocrj(x1, y1, x2, y2, colorfmt, sim) end

--- 获取指定范围内的文本字符串 - 说明:请下载群里的光学ocr训练工具可以自己针对性的训练自己的字库
-- 语法: oocrTextExJ(handle,x1,y1,x2,y2,[splitType],[ThresholdTypes],[thresh],[maxthresh])
---@param handle any 整数型，tresseract-ocr对象句柄
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param splitType any 整数型，文本分割类型 0(RIL_BLOCK),1(RIL_PARA),2(RIL_TEXTLINE),3(RIL_WORD),4(RIL_SYMBOL) 默认不写是3（RIL_WORD）
---@param ThresholdTypes integer (THRESH_BINARY = 0,THRESH_BINARY_INV = 1,THRESH_TRUNC = 2,THRESH_TOZERO = 3,THRESH_TOZERO_INV = 4,THRESH_MASK = 7,THRESH_OTSU = 8,THRESH_TRIANGLE = 16)具体含义请查看opencv文档，默认不写是8(THRESH_OTSU)
---@param thresh any 整数型，阈值默认不写是150 maxthresh：整数型，最大阈值，默认不写255
---@param maxthresh any
---@return table 返回查找的结果的表
function oocrTextExJ(handle, x1, y1, x2, y2, splitType, ThresholdTypes, thresh, maxthresh) end

--- 获取指定范围内的文本字符串 - 说明:请下载群里的光学ocr训练工具可以自己针对性的训练自己的字库
-- 语法: ocrTextEx(handle,x1,y1,x2,y2,[ThresholdTypes],[thresh],[maxthresh])
---@param handle any 整数型，tresseract-ocr对象句柄
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param ThresholdTypes integer (THRESH_BINARY = 0,THRESH_BINARY_INV = 1,THRESH_TRUNC = 2,THRESH_TOZERO = 3,THRESH_TOZERO_INV = 4,THRESH_MASK = 7,THRESH_OTSU = 8,THRESH_TRIANGLE = 16)具体含义请查看opencv文档，默认不写是8(THRESH_OTSU)
---@param thresh any 整数型，阈值默认不写是150 maxthresh：整数型，最大阈值，默认不写255
---@param maxthresh any
---@return string 返回查找的字符串
function ocrTextEx(handle, x1, y1, x2, y2, ThresholdTypes, thresh, maxthresh) end

--- 获取指定范围内的文本字符串
---@param handle any 整数型，tresseract-ocr对象句柄
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param colorfmt string 文字的颜色格式
---@return string 返回查找的字符串
function ocrText(handle, x1, y1, x2, y2, colorfmt) end

--- 根据选中的字典查找该区域内所有文字组成的字符串
---@param x1 integer 查找区域左上X坐标
---@param y1 integer 查找区域左上Y坐标
---@param x2 integer 查找区域右下X坐标
---@param y2 integer 查找区域右下Y坐标
---@param colorfmt string 文字的颜色格式
---@param sim number 相似度,取值范围0-1
---@return string 字符串
function ocr(x1, y1, x2, y2, colorfmt, sim) end

--- 删除内存中的截图 - 功能说明:删除内存中的截图
function releaseScreen() end

--- 释放指定句柄的tresseract-ocr对象
---@param handle any 整数型，tresseract-ocr对象句柄
function releaseOcr(handle) end

--- 设置字库文件
---@param index integer 需要设置的字典的索引目前取值范围0-29
---@param name any 字典的名称,目前字典只能放入资源文件中
---@return any 0失败1成功
function setDict(index, name) end

--- 屏幕缩放 - 功能说明:此功能用于非目标分辨率设备上找色和点击时使用
-- 语法: setScreenScale(type,width,height,[scale])
---@param type any 0取消缩放，1开启缩放
---@param width integer 脚本开发时使用的设备宽度
---@param height integer 脚本开发时使用的设备高度
---@param scale any 可选参数,默认为1,0代表只对传入函数的坐标进行缩放, 从函数返回坐标的不缩放,即为当前使用设备真实坐标。 1代表传入函数的坐标进行缩放，函数返回的坐标进行反向缩放
function setScreenScale(type, width, height, scale) end

--- 设置本地光学ocr白名单 - 说明:如果你选择的光学ocr识别引擎使用的是lstm神经网络模式那么白名单将失效
---@param handle any 通过createOcr创建的句柄 whiteList:字符串类型，不在这个字符集里面的字符全部被过滤掉
---@param whitelist any
---@return any 无
function setWhiteList(handle, whitelist) end

--- 截图并保存
-- 语法: snapShot(path,[left,top,right,bottom])
---@param path any
---@param left any
---@param top any
---@param right any
---@param bottom any
function snapShot(path, left, top, right, bottom) end

--- 设置要查找的字典索引,后面所有的查询都是在这个字典中查找
---@param index integer 需要设置的字典的索引目前取值范围0-29
---@return any 0失败1成功
function useDict(index) end

-- 控制台方法

--- clearLog 清除控制台中的日志
---@return any 无
function console.clearLog() end

--- dismiss 关闭控制台窗口
---@return boolean 布尔类型
function console.dismiss() end

--- lockConsole 锁定控制台窗口,锁定后窗口将无法触摸拖动，事件直接透传到下面的窗口中
function console.lockConsole() end

--- println 打印日志到控制台窗口
---@param level any
---@param log any
---@return any 无
function console.println(level, log) end

--- setPos 设置控制台位置和大小
-- 语法: console.setPos(x,y,[w],[h])
---@param x any
---@param y any
---@param w any
---@param h any
---@return any 无
function console.setPos(x, y, w, h) end

--- setTitle 设置控制台标题
---@param title any
---@return any 无
function console.setTitle(title) end

--- showTitle 显示或者隐藏控制台标题栏
-- 语法: console.showTitle([isShow])
---@param isShow any
---@return boolean 布尔类型
function console.showTitle(isShow) end

--- show 创建并显示控制台窗口
-- 语法: console.show([isShow])
---@param isShow any
---@return boolean 布尔类型
function console.show(isShow) end

--- unlockConsole 解除锁定控制台窗口
function console.unlockConsole() end

-- 时间方法

--- 获取网络时间
---@return string 格式为年-月-日_时-分-秒的时间字符串
function getNetWorkTime() end

--- 日期格式化 - 功能说明:用来格式化时间戳为可读时间,time为可选时间戳,省略时取当下
-- 语法: os.date(format [, time]])
---@param format any
---@param time any
function os.date(format, time) end

--- 时间戳 - 功能说明:默认获取当前时间戳,也可以指定table参数
-- 语法: os.time([table])
---@param table any
function os.time(table) end

--- 系统时间戳单位是毫秒
function systemTime() end

--- 脚本运行时间单位是毫秒
function tickCount() end

-- 文件方法

--- 打开一个文件输入
-- 语法: io.input([file])
---@param file any
---@return any 文件句柄 在出错的情况下,函数抛出错误而不是返回错误码
function io.input(file) end

--- 打开一个文件
---@param path any
---@param mode any
---@return any 文件句柄 失败则返回nil+错误信息
function io.open(path, mode) end

--- 打开一个文件输出
-- 语法: io.output([file])
---@param file any 可以是字符串路径也可以是以io.open打开的句柄，用文件名调用它时,以文本模式来打开该名字的文件,并将文件句柄设为默认输出文件.如果用文件句柄去调用它,就简单的将该句柄设为默认输出文件.如果调用时不传参数,
---@return any 文件句柄 在出错的情况下,函数抛出错误而不是返回错误码
function io.output(file) end

--- 读取文件数据
--- 等价于 io.input():read(···)
function io.read() end

--- 写入数据到文件
--- 等价于 io.output():write(···)
--- @param t any 要写入的数据，可以是多个
function io.write(t) end

-- json方法

--- jsonLib.decode 把json字符串转换成lua表格
---@param json any
---@return table lua表格
function jsonLib.decode(json) end

--- jsonLib.encode 把lua表格编码成json字符串
---@param table any
---@return string json字符串
function jsonLib.encode(table) end

-- 数学方法

--- 绝对值
---@param number any
function math.abs(number) end

--- 反余弦
---@param number any
function math.acos(number) end

--- 反正弦
---@param number any
function math.asin(number) end

--- 反正切
---@param number any
function math.atan(number) end

--- 向上取整
---@param number any
function math.ceil(number) end

--- 余弦
---@param number any
function math.cos(number) end

--- 弧度转角度
---@param number any
function math.deg(number) end

--- e为底x次方值
---@param number any
function math.exp(number) end

--- 向下取整
---@param number any
function math.floor(number) end

--- 取余数
---@param 被除数 any
---@param 除数 any
function math.fmod(被除数, 除数) end

--- 数字的自然对数
---@param number any
function math.log(number) end

--- 取得参数中最大值
---@param number1 any
---@param number2 any
---@param number any
---@param ... any
function math.max(number1, number2, number, ...) end

--- 取得参数中最小值
---@param number1 any
---@param number2 any
---@param number any
---@param ... any
function math.min(number1, number2, number, ...) end

--- 取整数和小数部分
---@param number any
function math.modf(number) end

--- 角度转弧度
---@param rad any
function math.rad(rad) end

--- 设随机数种子
---@param seed any
function math.randomseed(seed) end

--- 正弦
---@param number any
function math.sin(number) end

--- 开根号
---@param number any
function math.sqrt(number) end

--- 正切
---@param rad any
function math.tan(rad) end

--- 转化整数 - 功能说明:如果 x 可以转换为一个整数， 返回该整数。 否则返回 nil。
---@param n any
---@return number 转化的整数
function math.tointeger(n) end

--- 获取数字类型 - 功能说明:如果 x 是整数，返回 "integer"， 如果它是浮点数，返回 "float"， 如果 x 不是数字，返回 nil。
---@param n any
---@return string 字符串类型
function math.type(n) end

--- 无符号数据比较 - 功能说明:如果整数 m 和 n 以无符号整数形式比较， m 在 n 之下，返回布尔真否则返回假。
---@param m any
---@param n any
---@return boolean 布尔类型
function math.ult(m, n) end

-- 节点方法

--- nodeLib.click 点击指定节点
-- 语法: local node = nodeLib.click(node,[mode])
---@param node any
---@param mode any
---@return boolean 布尔类型
function nodeLib.click(node, mode) end

--- nodeLib.findAll 查找所有满足要求的节点
---@param selector any
---@param fuzzy_match any
---@return any 查找所有满足要求的节点
function nodeLib.findAll(selector, fuzzy_match) end

--- nodeLib.findByIndex 根据节点所在树的每个分支顺序查找
---@param indexs any
---@return any 查找所有满足要求的节点
function nodeLib.findByIndex(indexs) end

--- nodeLib.findChildNodes 查找所有满足要求的节点的所有子节点
---@param selector any
---@param fuzzy_match any
---@return any 查找所有满足要求的节点所有子节点
function nodeLib.findChildNodes(selector, fuzzy_match) end

--- nodeLib.findOne 查找出一个节点
---@param src any
---@param dst any
---@param isfindall any
---@param fuzzy_match any
---@return table 返回一个满足要求的节点或者节点数组
function nodeLib.findInNode(src, dst, isfindall, fuzzy_match) end

--- nodeLib.findNextNode 获取指定节点的下一个兄弟节点
---@param selector any
---@param fuzzy_match any
---@return any 返回一个满足要求的节点的下一个兄弟节点
function nodeLib.findNextNode(selector, fuzzy_match) end

--- nodeLib.findOne 查找出一个节点
---@param selector any
---@param fuzzy_match any
---@return any 返回一个满足要求的节点
function nodeLib.findOne(selector, fuzzy_match) end

--- nodeLib.findParentNode 查找出一个节点的父节点
---@param selector any
---@param fuzzy_match any
---@return any 返回一个满足要求的节点的父节点
function nodeLib.findParentNode(selector, fuzzy_match) end

--- nodeLib.findPreNode 获取指定节点的上一个兄弟节点
---@param selector any
---@param fuzzy_match any
---@return any 返回一个满足要求的节点的上一个兄弟节点
function nodeLib.findPreNode(selector, fuzzy_match) end

--- getXml 获取节点xml字符
---@return string 返回当前界面布局xml字符串
function nodeLib.getXml() end

--- nodeLib.keepNode 锁定当前界面到内存，下次节点查找查找都会直接从内存中获取该节点
---@return any 成功返回真失败返回假
function nodeLib.keepNode() end

--- nodeLib.longClick 指针长按节点
-- 语法: local node = nodeLib.longClick(node,[isRegMatch])
---@param node any
---@param isRegMatch any
---@return boolean 返回一个布尔值
function nodeLib.longClick(node, isRegMatch) end

--- nodeLib.matchAllAndClick 匹配出所有符合条件的节点并进行无指针点击
---@param selector any
---@return number 返回一个数组 匹配的所有结果
function nodeLib.matchAllAndClick(selector) end

--- nodeLib.matchAllAndInputText 匹配出一个符合条件的节点并进行输入
---@param selector any
---@param str string
---@return number 返回一个数组 匹配的所有结果
function nodeLib.matchAllAndInputText(selector, str) end

--- nodeLib.matchAll 匹配所有符合条件的节点
---@param selector any
---@return number 返回一个数组 匹配的所有结果
function nodeLib.matchAll(selector) end

--- nodeLib.matchOneAndClick 匹配出一个符合条件的节点并进行无指针点击
---@param selector any
---@return number 返回一个数组 匹配的所有结果
function nodeLib.matchOneAndClick(selector) end

--- nodeLib.matchOneAndInputText 匹配出一个符合条件的节点并进行输入
---@param selector any
---@param str string
---@return number 返回一个数组 匹配的所有结果
function nodeLib.matchOneAndInputText(selector, str) end

--- nodeLib.matchOne 匹配出一个符合条件的节点
---@param selector any
---@return number 返回一个数组
function nodeLib.matchOne(selector) end

--- saveNode 保存当前界面的节点到文件,此文件可以用节点工具箱打开方便测试
---@param path any
---@return boolean 返回布尔类型
function nodeLib.saveNode(path) end

--- nodeLib.scrollBackward 向下滚动一页
-- 语法: local node = nodeLib.scrollBackward(node,[isRegMatch])
---@param node any
---@param isRegMatch any
---@return boolean 返回一个布尔值
function nodeLib.scrollBackward(node, isRegMatch) end

--- nodeLib.scrollForward 向上滚动一页
-- 语法: local node = nodeLib.scrollForward(node,[isRegMatch])
---@param node any
---@param isRegMatch any
---@return boolean 返回一个布尔值
function nodeLib.scrollForward(node, isRegMatch) end

--- setOnMsgNotify 监听系统通知类信息
---@param callback any
---@return boolean 返回布尔值
function nodeLib.setOnMsgNotify(callback) end

--- nodeLib.setOnNodeEvent 设置监听节点事件回调函数
---@param callback any
---@return boolean 布尔类型
function nodeLib.setOnNodeEvent(callback) end

--- nodeLib.setText 给文文本输入框节点输入文字
---@param node any
---@param text any
---@return boolean 布尔类型
function nodeLib.setText(node, text) end

--- nodeLib.updateNode 刷新节点缓存
function nodeLib.updateNode() end

-- 字符串方法

--- 字符串分割
---@param src any
---@param matchstr any
function splitStr(src, matchstr) end

--- 转换字符为整数值 - 功能说明:函数返回字符s[i], s[i+1], ···, s[j]的内部数字编码(ASCII码)，其中参数i的默认值是1，而参数j的默认值是i
-- 语法: string.byte (s [, i [, j] ])
---@param s any
---@param i any
---@param j any
function string.byte(s, i, j) end

--- 将整型数字转成字符并连接 - 功能说明:将整型数字转成字符并连接
---@param arg any
function string.char(arg) end

--- 字符串中查找子字符串 - 功能说明:函数在字符串s里查找第一个和参数pattern匹配的子串，如果找到了一个匹配的子串， 就会返回这个子串的起始索引和结束索引，否则就会返回nil。另外，参数init作为一个数字，指定了搜索的起始位置， 这个数字默认为1可以一个负数，表示从后往前数的字符个数。参数plain作为第四个可选参数默认为flase， 传入参数true表示关闭模式匹配，所以函数只做简单的查找子串的操作，如果子串pattern没有字符为空字符串""将会被认为是魔法字符。 如果模式匹配子串被找到了，一个成功被找到的子串将会作为第三个返回值，放在两个索引返回值的后边而返回。 返回其具体位置。不存在则返回 nil。
-- 语法: string.find(s, pattern [, init [, plain]] )
---@param s any
---@param pattern any
---@param init any
---@param plain any
function string.find(s, pattern, init, plain) end

--- 字符格式化 - 功能说明:将一个字符串反转
---@param ... any
function string.format(...) end

--- 字符串长度 - 功能说明:获取字符串长度
---@param arg any
function string.len(arg) end

--- 转为小写字母 - 功能说明:字符串全部转为小写字母
---@param argument any
function string.lower(argument) end

--- 返回字符串string的n个拷贝 - 功能说明:返回字符串string的n个拷贝
---@param string any
---@param n any
function string.rep(string, n) end

--- 字符串反转 - 功能说明:将一个字符串反转
---@param argument any
function string.reverse(argument) end

--- 转为大写字母 - 功能说明:字符串全部转为大写字母
---@param argument any
function string.upper(argument) end

--- 反向查找utf8字符串
---@param string1 any
---@param string2 any 要搜索的字符串任意有效字符串表达式,
---@param start any 开始搜索的字符位置,-1表示从最后一个字符开始搜索
---@param compare any ,可选。是否忽略大小写,默认False,即不忽略大小写
---@return number 数值型 返回反方向搜索字符串在原字符串中第一次出现的正方向位置
function string.inStrRev(string1, string2, start, compare) end

--- 查找utf8字符串
-- 语法: utf8.inStr(start,string1,string2[,comparision]))
---@param start any 数值表达式,用于设置每次搜索的开始位置
---@param string1 any 要搜索的字符串表达式
---@param string2 any 被搜索的字符串表达式 comparision:对比方式,是否忽略大小写,可省略,默认false,即不忽略大小写
---@param comparision any 可选。是否忽略大小写,默认False,即不忽略大小写
---@return string 字符串在另一字符串中第一次出现的位置
function utf8.inStr(start, string1, string2, comparision) end

--- 取左边字符
---@param string1 any
---@param len any
---@return string utf8字符串取左边字符
function utf8.left(string1, len) end

--- 获取utf8字符串长度
---@param string1 any
---@return string utf8字符串长度
function utf8.length(string1) end

--- 从字符串的指定位置开始截取一定数量的字符
---@param string any
---@param start any
---@param length any
---@return string 从utf8字符串中返回指定数目的字符
function utf8.mid(string, start, length) end

--- 取右边字符
---@param string1 any
---@param len any
---@return string utf8字符串取右边字符
function utf8.right(string1, len) end

--- 移除指定数目字符
---@param string any
---@param start any
---@param length any
---@return string 字符串型，返回移除了指定字符后的字符串
function utf8.strCut(string, start, length) end

--- 颠倒utf8字符串
---@param string1 any
---@return string 与指定字符串顺序相反的字符串
function utf8.strReverse(string1) end

-- 动态UI方法

--- ui.addButton 创建一个按钮
-- 语法: ui.addButton(layout,name,text,[w],[h])
---@param layout any
---@param name any
---@param text any
---@param w any
---@param h any
---@return boolean 布尔类型
function ui.addButton(layout, name, text, w, h) end

--- ui.addCheckBox 创建输入框控件
-- 语法: ui.addCheckBox(layout,name,text,[sel],[w],[h])
---@param layout any
---@param name any
---@param text any
---@param sel any
---@param w any
---@param h any
---@return boolean 布尔类型
function ui.addCheckBox(layout, name, text, sel, w, h) end

--- ui.addCheckBox 创建输入框控件
-- 语法: ui.addCheckBox(layout,name,text,[sel],[w],[h])
---@param layout any
---@param name any
---@param text any
---@param sel any
---@param w any
---@param h any
---@return boolean 布尔类型
function ui.addCheckBox(layout, name, text, sel, w, h) end

--- ui.setEditText 重设输入框控件
-- 语法: ui.setEditText(name,text,[w],[h])
---@param name any
---@param text any
---@param w any
---@param h any
---@return boolean 布尔类型
function ui.setEditText(name, text, w, h) end

--- ui.setEnable 设置控件可用状态
---@param name any
---@param enable any
---@return boolean 布尔类型
function ui.setEnable(name, enable) end

--- ui.setFullScreen 设置控件宽度全屏
---@param name any
---@return string 字符串类型
function ui.getTextColor(name) end

--- ui.setGravity 设置控件对齐方式
---@param name any
---@param alignMode any
---@return boolean 布尔类型
function ui.setGravity(name, alignMode) end

--- ui.setImageView 重设图像控件
-- 语法: ui.setImageView(name,path,[w],[h])
---@param name any
---@param path any
---@param w any
---@param h any
---@return boolean 布尔类型
function ui.setImageView(name, path, w, h) end

--- ui.setInputType 设置输入类型
---@param name any
---@param type any
---@return boolean 布尔类型
function ui.setInputType(name, type) end

--- ui.setLine 重设线控件
-- 语法: ui.setLine(name,[w],[h])
---@param name any
---@param w any
---@param h any
---@return boolean 布尔类型
function ui.setLine(name, w, h) end

--- ui.setOnChange 设置控件单击事件
---@param name any
---@param event any
---@return boolean 布尔类型
function ui.setOnChange(name, event) end

--- ui.setOnClick 设置控件单击事件
---@param name any
---@param event any
---@return boolean 布尔类型
function ui.setOnClick(name, event) end

--- ui.setOnClose 设置控件单击事件
---@param event any
---@return boolean 布尔类型
function ui.setOnClose(event) end

--- ui.setPadding 设置控件内边距
---@param name any
---@param l any
---@param t any
---@param r any
---@param b any
---@return string 字符串类型
function ui.setPadding(name, l, t, r, b) end

--- ui.setRadioGroup 重设单选框控件
-- 语法: ui.setRadioGroup(name,list,select,[w],[h],[horiziontal])
---@param name any
---@param list any
---@param select any
---@param w any
---@param h any
---@param horiziontal any
---@return boolean 布尔类型
function ui.setRadioGroup(name, list, select, w, h, horiziontal) end

--- ui.setRowVisibleByGid 批量设置行控件显示状态通过gid
---@param layoutid any
---@param name any
---@param state any
---@return boolean 布尔类型
function ui.setRowVisibleByGid(layoutid, name, state) end

--- ui.setSpinner 重设下拉框控件
-- 语法: ui.setSpinner(name,list,select,[w],[h])
---@param name any
---@param list any
---@param select any
---@param w any
---@param h any
---@return boolean 布尔类型
function ui.setSpinner(name, list, select, w, h) end

--- ui.setTextColor 设置文字颜色
---@param name any
---@param color any
---@return boolean 布尔类型
function ui.setTextColor(name, color) end

--- ui.setTextSize 设置文字大小
---@param layout any
---@param size any
---@return boolean 布尔类型
function ui.setTextSize(layout, size) end

--- ui.setTextView 重设文本框控件
-- 语法: ui.setTextView(name,text,[w],[h])
---@param name any
---@param text any
---@param w any
---@param h any
---@return boolean 布尔类型
function ui.setTextView(name, text, w, h) end

--- ui.setText 控件设置文字
---@param name any
---@param text any
---@return boolean 布尔类型
function ui.setText(name, text) end

--- ui.setTitleBackground 设置控件背景颜色
---@param layout1 any
---@param color any
---@return boolean 布尔类型
function ui.setBackground(layout1, color) end

--- ui.setTitleText 设置布局标题
---@param layout any
---@param text any
---@return boolean 布尔类型
function ui.setText(layout, text) end

--- ui.setVisiblity 设置控件显示状态
---@param name any
---@param state any
---@return boolean 布尔类型
function ui.setVisiblity(name, state) end

--- ui.setWebView 重设浏览器控件
-- 语法: ui.setWebView(name,url,[w],[h])
---@param name any
---@param url any
---@param w any
---@param h any
---@return boolean 布尔类型
function ui.setWebView(name, url, w, h) end

--- ui.show 显示一个布局
-- 语法: ui.show(name,[isShowBottom])
---@param name any
---@param isShowBottom any
---@return boolean 布尔类型
function ui.show(name, isShowBottom) end

local M = {}
M["appIsFront"] = appIsFront
M["appIsRunning"] = appIsRunning
M["exec"] = exec
M["exitScript"] = exitScript
M["extractAssets"] = extractAssets
M["frontAppName"] = frontAppName
M["getApkVerInt"] = getApkVerInt
M["getBatteryLevel"] = getBatteryLevel
M["getBoard"] = getBoard
M["getBootLoader"] = getBootLoader
M["getBrand"] = getBrand
M["getCpuAbi2"] = getCpuAbi2
M["getCpuAbi"] = getCpuAbi
M["getCurrentActivity"] = getCurrentActivity
M["getDeviceId"] = getDeviceId
M["getDevice"] = getDevice
M["getDisplayDpi"] = getDisplayDpi
M["getDisplayRotate"] = getDisplayRotate
M["getDisplaySize"] = getDisplaySize
M["getFingerprint"] = getFingerprint
M["getHardware"] = getHardware
M["getId"] = getId
M["getInstalledApk"] = getInstalledApk
M["getInstalledApps"] = getInstalledApps
M["getManufacturer"] = getManufacturer
M["getModel"] = getModel
M["getNumberConfig"] = getNumberConfig
M["getPackageName"] = getPackageName
M["getProduct"] = getProduct
M["getSdkVersion"] = getSdkVersion
M["getSimSerialNumber"] = getSimSerialNumber
M["getStringConfig"] = getStringConfig
M["getSubscriberId"] = getSubscriberId
M["getUIConfig"] = getUIConfig
M["getWifiMac"] = getWifiMac
M["getYkArg"] = getYkArg
M["installApk"] = installApk
M["installLrPkg"] = installLrPkg
M["lockScreen"] = lockScreen
M["phoneCall"] = phoneCall
M["playAudio"] = playAudio
M["printEx"] = printEx
M["readPasteboard"] = readPasteboard
M["resetConfig"] = resetConfig
M["resetDisplaySize"] = resetDisplaySize
M["resetUIConfig"] = resetUIConfig
M["restartScript"] = restartScript
M["rnd"] = rnd
M["runApp"] = runApp
M["runIntent"] = runIntent
M["scanImage"] = scanImage
M["sendSms"] = sendSms
M["setAirplaneMode"] = setAirplaneMode
M["setBTEnable"] = setBTEnable
M["setControlBarPosNew"] = setControlBarPosNew
M["setControlBarPos"] = setControlBarPos
M["setDisplaySize"] = setDisplaySize
M["setNumberConfig"] = setNumberConfig
M["setStopCallBack"] = setStopCallBack
M["setStringConfig"] = setStringConfig
M["setUserEventCallBack"] = setUserEventCallBack
M["setWifiEnable"] = setWifiEnable
M["showControlBar"] = showControlBar
M["sleep"] = sleep
M["stopApp"] = stopApp
M["stopAudio"] = stopAudio
M["unLockScreen"] = unLockScreen
M["unZip"] = unZip
M["vibrate"] = vibrate
M["writePasteboard"] = writePasteboard
M["zip"] = zip
M["asynHttpGet"] = asynHttpGet
M["asynHttpPost"] = asynHttpPost
M["closeWebSocket"] = closeWebSocket
M["closeWebSocket"] = closeWebSocket
M["httpGet"] = httpGet
M["httpPost"] = httpPost
M["import"] = import
M["LuaEngine.getContext"] = LuaEngine.getContext
M["LuaEngine.httpGet"] = LuaEngine.httpGet
M["LuaEngine.httpPostData"] = LuaEngine.httpPostData
M["LuaEngine.httpPost"] = LuaEngine.httpPost
M["LuaEngine.loadApk"] = LuaEngine.loadApk
M["LuaEngine.sendMailWithFile"] = LuaEngine.sendMailWithFile
M["LuaEngine.snapShot"] = LuaEngine.snapShot
M["mysql_close"] = mysql_close
M["mysql_connect"] = mysql_connect
M["mysql_execSQLWithResult"] = mysql_execSQLWithResult
M["mysql_execSQL"] = mysql_execSQL
M["readKeyVal"] = readKeyVal
M["sendWebSocket"] = sendWebSocket
M["startWebSocket"] = startWebSocket
M["uploadFile"] = uploadFile
M["writeKeyVal"] = writeKeyVal
M["bdOcr"] = bdOcr
M["beginThread"] = beginThread
M["binaryImage"] = binaryImage
M["binaryRect"] = binaryRect
M["clearLog"] = clearLog
M["decodeBase64"] = decodeBase64
M["decodeUrl"] = decodeUrl
M["delfile"] = delfile
M["encodeBase64"] = encodeBase64
M["encodeUrl"] = encodeUrl
M["fileExist"] = fileExist
M["fileMD5"] = fileMD5
M["mkdir"] = mkdir
M["qrDecode"] = qrDecode
M["readFile"] = readFile
M["rotateImage"] = rotateImage
M["scaleImage"] = scaleImage
M["stopThread"] = stopThread
M["useRes"] = useRes
M["writeFile"] = writeFile
M["writeLog"] = writeLog
M["catchTouchPoint"] = catchTouchPoint
M["inputText"] = inputText
M["keyDown"] = keyDown
M["keyPress"] = keyPress
M["keyUp"] = keyUp
M["setIme"] = setIme
M["swipe"] = swipe
M["tap"] = tap
M["touchDown"] = touchDown
M["touchMoveEx"] = touchMoveEx
M["touchMove"] = touchMove
M["touchUp"] = touchUp
M["createHUD"] = createHUD
M["getButtonText"] = getButtonText
M["getCheckGroupSel"] = getCheckGroupSel
M["getDropSel"] = getDropSel
M["getEditText"] = getEditText
M["getLableText"] = getLableText
M["getRadioGroupSel"] = getRadioGroupSel
M["getViewEnable"] = getViewEnable
M["getViewVisible"] = getViewVisible
M["hideHUD"] = hideHUD
M["hideToast"] = hideToast
M["setButtonText"] = setButtonText
M["setCheckGroupSel"] = setCheckGroupSel
M["setDropSel"] = setDropSel
M["setEditText"] = setEditText
M["setLableText"] = setLableText
M["setRadioGroupSel"] = setRadioGroupSel
M["setUIConfigEx"] = setUIConfigEx
M["setUIConfig"] = setUIConfig
M["setViewEnable"] = setViewEnable
M["setWebViewJsCallBack"] = setWebViewJsCallBack
M["setWebViewUrl"] = setWebViewUrl
M["showHUD"] = showHUD
M["showUIEx"] = showUIEx
M["showUI"] = showUI
M["toast"] = toast
M["cmpColorExT"] = cmpColorExT
M["cmpColorEx"] = cmpColorEx
M["cmpColor"] = cmpColor
M["colorDiff"] = colorDiff
M["colorToRGB"] = colorToRGB
M["createOcr"] = createOcr
M["findCircle"] = findCircle
M["findColorT"] = findColorT
M["findColor"] = findColor
M["findImage"] = findImage
M["findMultiColorAllT"] = findMultiColorAllT
M["findMultiColorAll"] = findMultiColorAll
M["findMultiColorT"] = findMultiColorT
M["findMultiColor"] = findMultiColor
M["findPicAllPoint"] = findPicAllPoint
M["findPicEx"] = findPicEx
M["findPic"] = findPic
M["findStr"] = findStr
M["getColorNum"] = getColorNum
M["getPixelColor"] = getPixelColor
M["getScreenPixel"] = getScreenPixel
M["isDisplayDead"] = isDisplayDead
M["keepCapture"] = keepCapture
M["ocrj"] = ocrj
M["ocrEx"] = ocrEx
M["ocrj"] = ocrj
M["oocrTextExJ"] = oocrTextExJ
M["ocrTextEx"] = ocrTextEx
M["ocrText"] = ocrText
M["ocr"] = ocr
M["releaseScreen"] = releaseScreen
M["releaseOcr"] = releaseOcr
M["setDict"] = setDict
M["setScreenScale"] = setScreenScale
M["setWhiteList"] = setWhiteList
M["snapShot"] = snapShot
M["useDict"] = useDict
M["console.clearLog"] = console.clearLog
M["console.dismiss"] = console.dismiss
M["console.lockConsole"] = console.lockConsole
M["console.println"] = console.println
M["console.setPos"] = console.setPos
M["console.setTitle"] = console.setTitle
M["console.showTitle"] = console.showTitle
M["console.show"] = console.show
M["console.unlockConsole"] = console.unlockConsole
M["getNetWorkTime"] = getNetWorkTime
M["os.date"] = os.date
M["os.time"] = os.time
M["systemTime"] = systemTime
M["tickCount"] = tickCount
M["io.input"] = io.input
M["io.open"] = io.open
M["io.output"] = io.output
M["io.read"] = io.read
M["io.read"] = io.read
M["jsonLib.decode"] = jsonLib.decode
M["jsonLib.encode"] = jsonLib.encode
M["math.abs"] = math.abs
M["math.acos"] = math.acos
M["math.asin"] = math.asin
M["math.atan"] = math.atan
M["math.ceil"] = math.ceil
M["math.cos"] = math.cos
M["math.deg"] = math.deg
M["math.exp"] = math.exp
M["math.floor"] = math.floor
M["math.fmod"] = math.fmod
M["math.log"] = math.log
M["math.max"] = math.max
M["math.min"] = math.min
M["math.modf"] = math.modf
M["math.rad"] = math.rad
M["math.randomseed"] = math.randomseed
M["math.random"] = math.random
M["math.sin"] = math.sin
M["math.sqrt"] = math.sqrt
M["math.tan"] = math.tan
M["math.tointeger"] = math.tointeger
M["math.type"] = math.type
M["math.ult"] = math.ult
M["nodeLib.click"] = nodeLib.click
M["nodeLib.findAll"] = nodeLib.findAll
M["nodeLib.findByIndex"] = nodeLib.findByIndex
M["nodeLib.findChildNodes"] = nodeLib.findChildNodes
M["nodeLib.findInNode"] = nodeLib.findInNode
M["nodeLib.findNextNode"] = nodeLib.findNextNode
M["nodeLib.findOne"] = nodeLib.findOne
M["nodeLib.findParentNode"] = nodeLib.findParentNode
M["nodeLib.findPreNode"] = nodeLib.findPreNode
M["nodeLib.getXml"] = nodeLib.getXml
M["nodeLib.keepNode"] = nodeLib.keepNode
M["nodeLib.longClick"] = nodeLib.longClick
M["nodeLib.matchAllAndClick"] = nodeLib.matchAllAndClick
M["nodeLib.matchAllAndInputText"] = nodeLib.matchAllAndInputText
M["nodeLib.matchAll"] = nodeLib.matchAll
M["nodeLib.matchOneAndClick"] = nodeLib.matchOneAndClick
M["nodeLib.matchOneAndInputText"] = nodeLib.matchOneAndInputText
M["nodeLib.matchOne"] = nodeLib.matchOne
M["nodeLib.saveNode"] = nodeLib.saveNode
M["nodeLib.scrollBackward"] = nodeLib.scrollBackward
M["nodeLib.scrollForward"] = nodeLib.scrollForward
M["nodeLib.setOnMsgNotify"] = nodeLib.setOnMsgNotify
M["nodeLib.setOnNodeEvent"] = nodeLib.setOnNodeEvent
M["nodeLib.setText"] = nodeLib.setText
M["nodeLib.updateNode"] = nodeLib.updateNode
M["splitStr"] = splitStr
M["string.byte"] = string.byte
M["string.char"] = string.char
M["string.find"] = string.find
M["string.format"] = string.format
M["string.len"] = string.len
M["string.lower"] = string.lower
M["string.rep"] = string.rep
M["string.reverse"] = string.reverse
M["string.upper"] = string.upper
M["string.inStrRev"] = string.inStrRev
M["utf8.inStr"] = utf8.inStr
M["utf8.left"] = utf8.left
M["utf8.length"] = utf8.length
M["utf8.mid"] = utf8.mid
M["utf8.right"] = utf8.right
M["utf8.strCut"] = utf8.strCut
M["utf8.strReverse"] = utf8.strReverse
M["ui.addButton"] = ui.addButton
M["ui.addCheckBox"] = ui.addCheckBox
M["ui.addCheckBox"] = ui.addCheckBox
M["ui.setEditText"] = ui.setEditText
M["ui.setEnable"] = ui.setEnable
M["ui.getTextColor"] = ui.getTextColor
M["ui.setGravity"] = ui.setGravity
M["ui.setImageView"] = ui.setImageView
M["ui.setInputType"] = ui.setInputType
M["ui.setLine"] = ui.setLine
M["ui.setOnChange"] = ui.setOnChange
M["ui.setOnClick"] = ui.setOnClick
M["ui.setOnClose"] = ui.setOnClose
M["ui.setPadding"] = ui.setPadding
M["ui.setRadioGroup"] = ui.setRadioGroup
M["ui.setRowVisibleByGid"] = ui.setRowVisibleByGid
M["ui.setSpinner"] = ui.setSpinner
M["ui.setTextColor"] = ui.setTextColor
M["ui.setTextSize"] = ui.setTextSize
M["ui.setTextView"] = ui.setTextView
M["ui.setText"] = ui.setText
M["ui.setBackground"] = ui.setBackground
M["ui.setText"] = ui.setText
M["ui.setVisiblity"] = ui.setVisiblity
M["ui.setWebView"] = ui.setWebView
M["ui.show"] = ui.show
return M
