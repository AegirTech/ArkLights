---@type string 官服包名
oppid = "com.hypergryph.arknights"          --官服包名
---@type string B服包名
bppid = "com.hypergryph.arknights.bilibili" --B服包名

--- 临时关闭 `disable_game_up_check` 标记执行函数
--- @generic T
--- @param func fun(...):T @被包装的函数
--- @return fun(...):T     @包装后的函数
disable_game_up_check_wrapper = function(func)
    return function(...)
        local state = disable_game_up_check
        disable_game_up_check = true
        local ret = func(...)
        disable_game_up_check = state
        return ret
    end
end

--- 将函数包装为“永不返回”，在死循环中不断调用
--- @generic T
--- @param func fun(...):T
--- @return fun(...)
never_end_wrapper = function(func)
    return function(...) while true do func(...) end end
end

--- 在函数执行期间保持截图/节点捕获
--- @generic T
--- @param func fun(...):T
--- @return fun(...):T
still_wrapper = function(func)
    return function(...)
        -- nodeLib.keepNode()
        keepCapture()
        local ret = func(...)
        releaseCapture()
        -- nodeLib.releaseNode()
        return ret
    end
end

--- 执行函数期间临时修改 `disable_log`
--- @generic T
--- @param func fun(...):T
--- @param enable boolean 是否启用日志（true 为开启日志）
--- @return fun(...):T
disable_log_wrapper = function(func, enable)
    return function(...)
        local state = disable_log
        disable_log = not enable and true or false
        local ret = func(...)
        disable_log = state
        return ret
    end
end

--- 始终启用日志的包装函数
--- @generic T
--- @param func fun(...):T
--- @return fun(...):T
enable_log_wrapper = function(func) return disable_log_wrapper(func, true) end

-- 无障碍函数替换 -- 没什么用，给root打包用的，速通目前用的是无障碍打包
--- 无障碍函数替换
--- 若未提供系统级 `openPermissionSetting` 等函数（通常为 root 打包用），
--- 则在此声明兼容版本，避免后续逻辑报错。
if not openPermissionSetting then
    openPermissionSetting =
        function() stop("没root请换用无障碍版速通") end
    isSnapshotServiceRun = function() return true end
    isAccessibilityServiceRun = function() return true end
    --- 手势路径
    --- @class Path
    --- @field startTime number 起始时间（毫秒）
    --- @field durTime number 持续时间（毫秒）
    --- @field point number[] 点序列，格式为 {x1, y1, x2, y2, ...}
    Path = {}
    --- 创建路径对象
    --- @param o? Path
    --- @return Path
    function Path:new(o)
        o = o or { startTime = 0, durTime = 0, point = {} }
        setmetatable(o, self)
        self.__index = self
        return o
    end

    --- 设置起始时间
    --- @param t number
    function Path:setStartTime(t) self.startTime = t end

    --- 设置持续时间
    --- @param t number
    function Path:setDurTime(t) self.durTime = t end

    --- 在路径中追加一个坐标点
    --- @param x number
    --- @param y number
    function Path:addPoint(x, y)
        table.insert(self.point, x)
        table.insert(self.point, y)
    end

    --- 手势容器
    --- @class Gesture
    --- @field path Path[] 路径数组
    Gesture = {}

    --- 创建手势对象
    --- @param o? Gesture
    --- @return Gesture
    function Gesture:new(o)
        o = o or { path = {} }
        setmetatable(o, self)
        self.__index = self
        return o
    end

    --- 添加一条路径
    --- @param path Path
    function Gesture:addPath(path) table.insert(self.path, path) end

    --- 实际执行一条 Path 的手势
    --- @param path Path
    --- @param id integer 手指 id
    gestureDispatchOnePath = function(path, id)
        log('root gesture')
        local point = path.point -- 此时path已经已经Path:addPoint修改过了。point是[x,y,x1,y1,...]
        if #point < 2 then return end
        local start_time = time()
        local timeline = {}
        local length = 0
        local x, y, px, py
        px = point[1] -- 初始点
        py = point[2]
        sleep(path.startTime)
        for i = 2, #point / 2 do
            x = point[i * 2]
            y = point[i * 2 + 1]
            length = length + math.sqrt((x - px) ^ 2 + (y - py) ^ 2)
            table.insert(timeline, length) -- 计算每个点和前一个点的距离，累加
            px, py = x, y
        end
        touchUp(id)
        touchMove(id, point[1], point[2]) -- 移到开始的点
        touchDown(id)
        print(59, id, point)
        for i = 2, #point / 2 do
            x = point[i * 2]
            y = point[i * 2 + 1]
            timeline[i] = timeline[i] / length * path.durTime    -- 当前已经滑动距离/总距离*总时间 = 当前时间点
            touchMoveEx(id, x, y, timeline[i])
            if time() - start_time > path.durTime then break end -- 每次滑动后检查是否超时
        end
        sleep(max(0, time() - start_time - path.durTime))
        print(60, id, point, start_time + path.durTime - time())
        touchUp(id)
    end
    --- 多路径分发
    function Gesture:dispatch()
        for id, path in pairs(self.path) do
            log(71, id, path)
            beginThread(gestureDispatchOnePath, path, id)
        end
    end
end

--- 当前脚本绑定的游戏包名
--- @type string
package = getPackageName()
--- 将屏幕像素颜色从 BGR 转为 RGB（节点精灵到懒人精灵）
--- @param x integer
--- @param y integer
--- @return string rgbHex 形如 \"RRGGBB\" 的 16 进制字符串
getColor = function(x, y)
    local bgr = getPixelColor(x, y):upper()
    return bgr:sub(7, 8) .. bgr:sub(5, 6) .. bgr:sub(3, 4)
end
--- 获取当前时间（毫秒）
--- @type fun():integer
time = systemTime

--- 安全退出脚本
--- @type fun()
exit = exitScript

--- JSON 解码
--- @type fun(json:string):any
JsonDecode = jsonLib.decode
--- JSON 编码
--- @type fun(value:any):string
JsonEncode = jsonLib.encode

--- 查找单个节点
--- @param selector string|table
--- @return table|nil
findNode = function(selector) return nodeLib.findOne(selector, true) end

--- 查找多个节点
--- @param selector string|table
--- @return table[] 节点列表
findNodes = function(selector) return nodeLib.findAll(selector, true) end


--- 根据index 查找节点
--- @param selector string|table
--- @return table[] 节点列表
findNodeByIndex = function(selector)
    return nodeLib.findByIndex(selector)
end

--- 点击节点（带校验）
--- @param x table
clickNode = function(x) nodeLib.click(x, true) end

--- 点击节点（不校验）
--- @param x table
clickNodeFalse = function(x) nodeLib.click(x, false) end

--- 在指定坐标执行一次点击手势
--- @param x integer
--- @param y integer
clickPoint = function(x, y)
    local gesture = Gesture:new()
    local path = Path:new()
    path:setStartTime(0)
    path:setDurTime(1)
    path:addPoint(x, y)
    gesture:addPath(path)
    gesture:dispatch()
end
--- 原始点击函数封装
--- @type fun(x:integer, y:integer)
_tap = tap

--- 文件转 base64
--- @type fun(path:string):string
base64 = getFileBase64

--- 写入剪贴板
--- @type fun(text:string)
putClipboard = writePasteboard

--- 读取剪贴板
--- @type fun():string
getClipboard = readPasteboard

--- 原始 toast 函数
--- @type fun(text:string)
_toast = toast

--- 屏幕显示并输出日志
--- @param x string 显示内容
toast = function(x)
    _toast(x)
    log(x)
end

--- 设备点击事件坐标最大值，用于把 getevent 的原始坐标换算为屏幕坐标
--- @type integer|nil
deviceClickEventMaxX = nil
--- @type integer|nil
deviceClickEventMaxY = nil

--- 通过 root getevent 获取用户最后一次点击的屏幕坐标
--- @return table|nil pos { x:number, y:number } 或 nil（未获取到）
catchClick = function()
    if not root_mode then stop("未实现免root获取用户点击") end
    local result = exec("su root sh -c 'getevent -l -c 4 -q'")
    local x, y
    x = result:match('POSITION_X%s+([^%s]+)')
    y = result:match('POSITION_Y%s+([^%s]+)')
    -- log(33, x, y)
    if x and y then
        if not deviceClickEventX then
            local event = result:match('(/dev/[^:]+):.+POSITION_X')
            result = exec("su root sh -c 'getevent -il " .. event .. "'")
            deviceClickEventMaxX = result:match("POSITION_X[^\n]+max%s*(%d+)")
            deviceClickEventMaxY = result:match("POSITION_Y[^\n]+max%s*(%d+)")
        end
        local screen = getScreen()
        return {
            x = math.round(tonumber(x, 16) * screen.width / deviceClickEventMaxX),
            y = math.round(tonumber(y, 16) * screen.height / deviceClickEventMaxY),
        }
    end
end

--- 返回手机主页
home = function() --返回手机主页
    -- open(package)
    keyPress(3)
end

--- 发送返回键
back = function() keyPress(4) end --点击返回

--- 发送电源键
power = function() keyPress(26) end

--- 原始分辨率获取函数
_getDisplaySize = getDisplaySize

--- 获取当前逻辑分辨率，可被全局的 force_width/force_height 覆盖
--- @return integer width, integer height
getDisplaySize = function()
    -- override height and width
    if type(force_height) == 'number' and type(force_width) == 'number' and
        force_width > 0 and force_height > 0 then
        return force_width, force_height
    end

    -- -- try to get from wm command, seems not work on real devices
    -- local wmsize = exec("wm size")
    -- local x, y = wmsize:match("(%d+)%s*x%s*(%d+)%s*$")
    -- x = str2int(x, -1)
    -- y = str2int(y, -1)
    -- if x > 0 and y > 0 then return x, y end

    -- use internal api
    return _getDisplaySize()
end

--- 获取当前屏幕宽高（自动考虑旋转）
--- @return {width:integer,height:integer}
getScreen = function()
    local width, height = getDisplaySize()
    if getDisplayRotate() % 2 == 1 then width, height = height, width end
    return { width = width, height = height }
end

--- 保存配置（字符串）
--- @type fun(key:string, value:string)
saveConfig = setStringConfig

--- 读取配置（字符串），若不存在则返回默认值
--- @param k string
--- @param v? string 默认值
--- @return string
loadConfig = function(k, v)
    v = v or ''
    local y = getStringConfig(k)
    if not y or #y == 0 then y = v end
    return y
end

--- 友好退出脚本
peaceExit = function()
    -- need_show_console = false
    exit()
end

--- 数学工具别名
--- @type fun(a:number, b:number,...):number
max = math.max
--- @type fun(a:number, b:number,...):number
min = math.min

--- 四舍五入
--- @param x number
--- @return integer
math.round = function(x) return math.floor(x + 0.5) end

--- 四舍五入别名
--- @type fun(x:number):integer
round = math.round

--- 将数值限制在 [minimum, maximum] 区间内
--- @param x number
--- @param minimum number
--- @param maximum number
--- @return number
clip = function(x, minimum, maximum) return min(max(x, minimum), maximum) end

--- 对字符串进行转义，使其可安全用于 gsub 正则
--- @param str string
--- @return string
-- https://stackoverflow.com/questions/9790688/escaping-strings-for-gsub
string.quote = function(str)
    local quotepattern = '([' .. ("%^$().[]*+-?"):gsub("(.)", "%%%1") .. '])'
    return str:gsub(quotepattern, "%%%1")
end

--- 去除字符串首尾空白
--- @param s string|nil
--- @return string
-- https://stackoverflow.com/questions/10460126/how-to-remove-spaces-from-a-string-in-lua
string.trim = function(s)
    s = s or ''
    return s:match '^()%s*$' and '' or s:match '^%s*(.*%S)'
end

--- 统计 pattern 在字符串中出现的次数
--- @param str string
--- @param pattern string
--- @return integer
string.count = function(str, pattern)
    local ans = 0
    for _ in str.gfind(pattern) do ans = ans + 1 end
    return ans
end

--- 按 UTF-8 字符映射替换字符串
--- @param str string
--- @param map table<string,string>
--- @return string
string.map = function(str, map)
    local ans = ''
    for character in string.gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)") do
        -- print(217, character)
        if map[character] == nil then
            ans = ans .. character
        else
            ans = ans .. map[character]
        end
    end
    return ans
end

--- 字符串分割
--- @param str string
--- @param sep? string 分隔符（默认为空白）
--- @return string[]
string.split = function(str, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(str, "([^" .. sep .. "]+)") do table.insert(t, str) end
    return t
end

--- 全角转半角 + 统一常见符号
--- @param str string
--- @param extra_map? table<string,string>
--- @return string
-- 全角转半角
string.commonmap = function(str, extra_map)
    return string.map(str, update({
        ["　"] = " ",
        ["１"] = "1",
        ["２"] = "2",
        ["３"] = "3",
        ["４"] = "4",
        ["５"] = "5",
        ["６"] = "6",
        ["７"] = '7',
        ["８"] = '8',
        ["９"] = '9',
        ["０"] = '0',

        ["Ａ"] = 'a',
        ["Ｂ"] = 'b',
        ["Ｃ"] = 'c',
        ["Ｄ"] = 'd',
        ["Ｅ"] = 'e',
        ["Ｆ"] = 'f',
        ["Ｇ"] = 'g',
        ["Ｈ"] = 'h',
        ["Ｉ"] = 'i',
        ["Ｊ"] = 'j',
        ["Ｋ"] = 'k',
        ["Ｌ"] = 'l',
        ["Ｍ"] = 'm',
        ["Ｎ"] = 'n',
        ["Ｏ"] = 'o',
        ["Ｐ"] = 'p',
        ["Ｑ"] = 'q',
        ["Ｒ"] = 'r',
        ["Ｓ"] = 's',
        ["Ｔ"] = 't',
        ["Ｕ"] = 'u',
        ["Ｖ"] = 'v',
        ["Ｗ"] = 'w',
        ["Ｘ"] = 'x',
        ["Ｙ"] = 'y',
        ["Ｚ"] = 'z',

        ["ａ"] = 'a',
        ["ｂ"] = 'b',
        ["ｃ"] = 'c',
        ["ｄ"] = 'd',
        ["ｅ"] = 'e',
        ["ｆ"] = 'f',
        ["ｇ"] = 'g',
        ["ｈ"] = 'h',
        ["ｉ"] = 'i',
        ["ｊ"] = 'j',
        ["ｋ"] = 'k',
        ["ｌ"] = 'l',
        ["ｍ"] = 'm',
        ["ｎ"] = 'n',
        ["ｏ"] = 'o',
        ["ｐ"] = 'p',
        ["ｑ"] = 'q',
        ["ｒ"] = 'r',
        ["ｓ"] = 's',
        ["ｔ"] = 't',
        ["ｕ"] = 'u',
        ["ｖ"] = 'v',
        ["ｗ"] = 'w',
        ["ｘ"] = 'x',
        ["ｙ"] = 'y',
        ["ｚ"] = 'z',

        [";"] = " ",
        ['"'] = " ",
        ["'"] = " ",
        ["；"] = " ",
        ["："] = ":",
        [":"] = ":",
        [","] = " ",
        ["_"] = "-",
        ["－"] = "-",
        ["＿"] = "-",
        ["、"] = " ",
        ["，"] = " ",
        ["|"] = " ",
        ["@"] = "@",
        ["#"] = "#",
        ["&"] = "&",
        ["\n"] = " ",
        ["\t"] = " ",

        ["！"] = "!",
        ["＠"] = "@",
        ["＃"] = "#",
        ["＄"] = " ",
        ["％"] = " ",
        ["＾"] = " ",
        ["＆"] = "&",
        ["＊"] = "*",
        ["（"] = " ",
        ["）"] = " ",
        ["￥"] = " ",
        ["…"] = " ",
        ["×"] = "x",
        ["—"] = "-",
        ["＋"] = "+",
    }, extra_map or {}))
end

--- 先统一字符，再按空白拆分
--- @param str string
--- @param extra_map? table<string,string>
--- @return string[]
string.filterSplit = function(str, extra_map)
    return string.split(string.commonmap(str, extra_map))
end

--- 是否以 prefix 开头
--- @param str string
--- @param prefix string
--- @return boolean
string.startsWith = function(str, prefix)
    return string.sub(str, 1, string.len(prefix)) == prefix
end

--- 是否以 suffix 结尾
--- @param str string
--- @param suffix string
--- @return boolean
string.endsWith = function(str, suffix)
    return string.sub(str, #str - string.len(suffix) + 1) == suffix
end

--- 在字符串中查找任一目标子串
--- @param x string
--- @param targetStr? string[]
--- @return boolean
string.finds = function(x, targetStr)
    local targetStr = targetStr or {}
    for _, v in ipairs(targetStr) do
        if string.find(x, v, 1, true) then
            return true
        end
    end
    return false
end

--- 生成一个以固定字符串为前缀判断的函数
--- @param x string
--- @return fun(prefix:string):boolean
startsWithX = function(x)
    return
        function(prefix) return x:startsWith(prefix) end
end

--- 左侧补齐到指定长度
--- @param str string
--- @param len integer
--- @param char? string
--- @return string
string.padStart = function(str, len, char)
    if char == nil then char = " " end
    return string.rep(char, len - #str) .. str
end

--- 右侧补齐到指定长度
--- @param str string
--- @param len integer
--- @param char? string
--- @return string
string.padEnd = function(str, len, char)
    if char == nil then char = " " end
    return str .. string.rep(char, len - #str)
end

--- 计算两个表之间的差异（仅保留 a 中与 b 不同的键值）
--- @param a table
--- @param b table
--- @return table
--- 计算两个表之间的差异，只保留 a 中与 b 不同的键值
table.diff = function(a, b)
    local ans = {}
    for k, v in pairs(a) do if v ~= b[k] then ans[k] = v end end
    return ans
end

--- 按索引列表从表中取值，返回一个新的数组
table.index = function(t, idx)
    local ans = {}
    for _, i in pairs(idx) do table.insert(ans, t[i]) end
    return ans
end

--- 使用归并函数从左到右对表中的元素进行聚合
table.reduce = function(t, f, a)
    a = a or 0
    for _, c in pairs(t) do a = f(a, c) end
    return a
end

--- 求表中所有数值元素之和
table.sum = function(t)
    local a = 0
    for _, c in pairs(t) do a = a + c end
    return a
end

-- 从t中选出长度为n的所有组合，结果在ans，
table.combination = function(t, n)
    local ans = {}
    local cur = {}
    local k = 1
    combination(t, n, ans, cur, k)
    return ans
end

--- 递归实现组合枚举的内部函数
combination = function(t, n, ans, cur, k)
    -- cur = cur or {}
    -- k = k or 1
    if n == 0 then
        table.insert(ans, shallowCopy(cur))
    elseif k <= #t then
        table.insert(cur, t[k])
        combination(t, n - 1, ans, cur, k + 1)
        cur[#cur] = nil
        combination(t, n, ans, cur, k + 1)
    end
end

--- 将嵌套表拍平成一维数组
table.flatten = function(t)
    local ans = {}
    for _, v in pairs(t) do
        if type(v) == 'table' then
            table.extend(ans, table.flatten(v))
        else
            table.insert(ans, v)
        end
    end
    return ans
end

--- 去除数组中的重复元素，按首次出现的顺序保留
table.remove_duplicate = function(t)
    local ans = {}
    local visited = {}
    for _, v in pairs(t) do
        if not visited[v] then
            table.insert(ans, v)
            visited[v] = 1
        end
    end
    return ans
end

--- 从数组中删除所有等于指定值的元素（原地修改）
table.removev = function(t, v)
    for i = #t, 1, -1 do
        if t[i] == v then
            table.remove(t, i)
        end
    end
end

--- 返回在表中恰好出现指定次数的元素列表
table.appear_times = function(t, times)
    local ans = {}
    local visited = {}
    for _, v in pairs(t) do visited[v] = (visited[v] or 0) + 1 end
    -- log(visited)
    -- exit()
    for k, _ in pairs(visited) do
        if visited[k] == times then table.insert(ans, k) end
    end
    return ans
end

-- table.rotate = function(t, idx)
--   return table.extend(table.slice(t, idx), table.slice(t, 1, idx - 1))
-- end

--- 求两个数组的交集，返回共同出现的元素
table.intersect = function(a, b)
    local ans = {}
    if #b < #a then a, b = b, a end
    b = table.value2key(b)
    a = table.value2key(a)
    for k, _ in pairs(a) do if b[k] then table.insert(ans, k) end end
    return ans
end

--- 求数组差集，返回在 a 中但不在 b 中的元素
table.subtract = function(a, b)
    local ans = {}
    b = table.value2key(b or {})
    a = table.value2key(a or {})
    for k, _ in pairs(a) do if not b[k] then table.insert(ans, k) end end
    return ans
end

--- 对数组进行切片，返回指定区间与步长的新数组
table.slice = function(tbl, first, last, step)
    local sliced = {}
    for i = first or 1, last or #tbl, step or 1 do sliced[#sliced + 1] = tbl[i] end
    return sliced
end

--- 判断浅层表 a 是否包含表 b 的所有键值对
table.contains = function(a, b)
    for k, v in pairs(b) do if a[k] ~= v then return false end end
    return true
end

--- 将数组“值”反转为哈希表的“键”
table.value2key = function(x)
    local ans = {}
    for k, v in pairs(x) do ans[v] = k end
    return ans
end

--- 按掩码表从参考数组中选择元素
table.select = function(mask, reference)
    local ans = {}
    for i = 1, #reference do if mask[i] then table.insert(ans, reference[i]) end end
    return ans
end

--- 判断表中是否存在至少一个元素使得函数 f 返回 true
table.any = function(t, f)
    for k, v in pairs(t) do if f(v) then return true end end
end

--- 判断表中所有元素是否都满足函数 f
table.all = function(t, f)
    for _, v in pairs(t) do if not f(v) then return false end end
    return true
end

--- 在表中查找是否存在指定键名
table.findk = function(t, s)
    for k, _ in pairs(t) do if s == k then return true end end
end

--- 查找键值所在位置（只适用于数组）
table.search = function(t, s)
    for k, v in ipairs(t) do if s == v then return k end end
end

--- 查找键值或满足条件的值
table.findv = function(t, f)
    for k, v in pairs(t) do
        if type(f) == "string" then
            if v == f then return true end
        elseif type(f) == "function" then
            if f(v) then
                return v
            end
        end
    end
end

--- 过滤表中元素，返回满足条件的新数组
table.filter = function(t, f)
    local a = {}
    for _, v in pairs(t) do if f(v) then table.insert(a, v) end end
    return a
end

--- 过滤键值对，返回满足条件的新表
table.filterKV = function(t, f)
    local a = {}
    for k, v in pairs(t) do if f(k, v) then a[k] = v end end
    return a
end

--- 获取表中所有键，返回为数组
table.keys = function(t)
    local a = {}
    t = t or a
    for k, _ in pairs(t) do table.insert(a, k) end
    return a
end

--- 获取表中所有值，返回为数组
table.values = function(t)
    local a = {}
    t = t or a
    for _, v in pairs(t) do table.insert(a, v) end
    return a
end

--- 生成等差数列数组 a, a+s, ..., b
range = function(a, b, s)
    local t = {}
    if not b and not s then a, b = 1, a end
    s = s or 1
    for i = a, b, s do table.insert(t, i) end
    return t
end

--- 判断数组中是否包含指定元素
table.includes = function(t, e)
    return table.any(t, function(x) return x == e end)
end

--- 判断表是否为空（没有任何键）
table.isempty = function(t)
    for _ in pairs(t) do
        return false
    end
    return true
end

--- 判断字符串 s 是否包含列表 t 中的任意子串
string.includes = function(s, t)
    for _, v in pairs(t) do if s:find(v, 1, true) then return true end end
end

--- 将数组 e 中的所有元素追加到数组 t 末尾
table.extend = function(t, e)
    for k, v in pairs(e) do table.insert(t, v) end
    return t
end

--- 将一组数组按顺序拼接成一个大数组
table.cat = function(t)
    local ans = {}
    for _, v in pairs(t) do for _, n in pairs(v) do table.insert(ans, n) end end
    return ans
end

-- in = {
--    "A" = {1,4,5,7},
--    "B" = {1,2,5,6},
--    "C" = {3,4,6,7},
--    "D" = {2,3,6,7},
--  }
-- out = { {"A","B"},...}
-- n:key, m:value O(mmn)
--- 根据“值到键列表”的关系反向索引，构造“每个值对应在哪些键中出现”的映射
table.reverseIndex = function(t)
    local r = {}
    local s = {}
    for k, v in pairs(t) do for k2, v2 in pairs(v) do s[v2] = true end end
    for k, v in pairs(s) do
        r[k] = {}
        for k2, v2 in pairs(t) do
            if table.includes(v2, k) then table.insert(r[k], k2) end
        end
    end
    for k, v in pairs(r) do table.sort(v) end
    return r
end

--- 在表中查找第一个使函数 f 返回 true 的元素，并返回其键
table.find =
    function(t, f) for k, v in pairs(t) do if f(v) then return k end end end

table.shuffle = function(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

-- one depth compare, and key-value pairs all same
table.equal = function(a, b)
    if type(a) ~= 'table' or type(b) ~= 'table' then return end

    if #a ~= #b then return end
    if #a == 0 and #table.keys(a) ~= #table.keys(b) then return end

    for k, v in pairs(a) do if v ~= b[k] then return end end
    return true
end

-- one depth compare, and key all same
table.equalKey = function(a, b)
    if type(a) ~= 'table' or type(b) ~= 'table' then return end

    if #a ~= #b then return end
    if #a == 0 and #table.keys(a) ~= #table.keys(b) then return end

    for k, _ in pairs(a) do if b[k] == nil then return end end
    return true
end

equalX = function(x) return function(y) return x == y end end

shallowCopy = function(x)
    local y = {}
    if x == nil then return y end
    for k, v in pairs(x) do y[k] = v end
    return y
end

update = function(b, x, inplace, false_as_nil)
    local y = inplace and b or shallowCopy(b)
    if x == nil then return y end
    for k, v in pairs(x) do
        if false_as_nil and v == false then v = nil end
        y[k] = v
    end
    return y
end

-- n: num, a: alternative element
repeat_last = function(x, n, a)
    if a == nil then a = x[#x] end
    for i = 1, n do table.insert(x, a) end
    return x
end

-- TODO: better algorithms
loop_times = function(x)
    local times, f, n
    local maxlen = 40  -- of one piece
    local maxtimes = 1 -- of same pieces
    if x == nil or #x == 0 then return 0 end
    for i = 1, maxlen do
        f = true
        n = math.floor(#x / i)
        if n <= maxtimes then break end
        for j = 1, n - 1 do
            for k = 1, i do
                if x[#x - j * i - k + 1] ~= x[#x - k + 1] then
                    f = false
                    break
                end
            end
            if not f then
                maxtimes = math.max(maxtimes, j)
                break
            else
                maxtimes = math.max(maxtimes, j + 1)
            end
        end
    end
    return maxtimes
end

map = function(...)
    local a = { ... }
    local n = select("#", ...)
    local r = {}
    local f, x = a[1], a[2]
    local p, ur
    if n < 2 then return r end
    if n == 2 then
        n = #x
    elseif n > 2 then
        ur = true
        x = { table.unpack(a, 2, n) }
        n = n - 1
    end
    for i = 1, n do
        p = x[i]
        if type(f) == "function" then
            p = f(p)
        elseif type(f) == "table" then
            p = f[p]
        end
        r[i] = p
    end
    if ur then return table.unpack(r, 1, n) end
    return r
end

-- 休眠x秒，x不填默认1s
ssleep = function(x)
    if x == nil then x = 1 end
    sleep(x * 1000)
end

table.join = function(t, d)
    t = t or {}
    d = not d and ',' or d
    local a = ''
    for i = 1, #t do
        a = a .. t[i]
        if i ~= #t then a = a .. d end
    end
    return a
end

table.clear = function(x) for k, v in pairs(x) do x[k] = nil end end

removeFuncHash =
    function(x) return x:startsWith('function') and 'function' or x end

table2string = function(t)
    if type(t) == 'table' then
        t = shallowCopy(t)
        for k, v in pairs(t) do if type(v) == "function" then t[k] = 'func' end end
        t = JsonEncode(t)
    end
    return t
end

-- log_history = {}
--- 日志输出函数（由脚本运行环境提供）
--- 会把所有参数序列化后打印到控制台/日志窗口。
--- @type fun(...:any)  -- 可接受任意数量、任意类型的参数
log = function(...)
    if disable_log then return end
    if os.time() - log_time > tonumber(max_log_time) * 60 then
        console.clearLog()
        log_time = os.time()
    end
    if log_count > tonumber(max_log_count) then
        console.clearLog()
        log_count = 0
    end
    log_count = log_count + 1
    local arg = { ... }

    local l = table.join({
        map(tostring, running, ' ', table.unpack(map(table2string, arg))),
    }, ' ')
    -- l = map(removeFuncHash, l)
    -- l = map(table2string, l)

    local a = os.date('%Y.%m.%d %H:%M:%S')
    -- local a = time()
    -- for _, v in pairs(l) do a = a .. ' ' .. v end
    -- TODO: 有可能是日志太多导致速通停止运行
    print(l)
    console.println(1, a .. ' ' .. l)
    if write_log_local then
        -- writeLog(l)
        writeFile(log_path .. "log_ark.txt", a .. ' ' .. l .. "\n", true)
    end
end

open = function(id)
    id = id or appid
    runApp(id)
end

stop = function(msg, mode, nohome, complete)
    msg = msg or ''
    msg = "stop " .. "当前任务" .. strOr(running, "") .. msg
    disable_log = false -- 强制开启日志
    local info = table.join(qqmessage, ' ') .. ' ' .. msg
    if complete then
        captureqqimagedeliver("INFO", "任务结束", info, true)
        cloud.completeTask(last_upload_img)
    else
        captureqqimagedeliver("WARN", "任务结束", info, true)
        local type = ''
        if msg:find("登录次数达到") then
            type = cloud.FAILTASK_LINEBUSY
        elseif msg:find("密码") then
            type = cloud.FAILTASK_ACCOUNTERROR
        end
        cloud.failTask(last_upload_img, type)
    end
    toast(msg)

    if not nohome then
        closeapp(appid)
        home()
    end

    cloud.fetchSolveTask()

    ssleep(2)

    if mode == 'next' then restart_account(true) end
    if mode == 'cur' then restart_account(false) end
    exit()
end

findColorAbsolute = function(color, confidence)
    -- print(286, confidence)
    confidence = confidence or 100
    for x, y, c in color:gmatch("(%d+),(%d+),(#[^|]+)") do
        -- log(x, y, c)
        if not compareColor(tonumber(x), tonumber(y), c, confidence) then
            -- if getColor(tonumber(x), tonumber(y)).hex ~= c then
            -- log(x, y, c)
            -- keepScreen(false)
            return
        end
    end
    local x, y = color:match("(%d+),(%d+)")
    return { x = tonumber(x), y = tonumber(y) }
end

findOne_game_up_check_last_time = 0
findOne_keepalive_check_last_time = time()
findOne_last_time = time()
findOne_locked = false
--- 在当前画面中查找一个目标（UI 点/颜色模板/节点等）
--- @param x string|table|fun():any
---        - string: point 名称（会从全局 point 表中取坐标模板）
---        - table:  坐标/节点表，或空表（空表时会退化为 findNode 调用）
---        - fun():any: 回调函数，直接执行并返回结果
--- @param confidence? integer  颜色匹配置信度，默认 default_findcolor_confidence
--- @return table|nil
---         - 对于颜色模板：返回 {x, y} 坐标表或 nil
---         - 对于节点：返回节点表或 nil
findOne = function(x, confidence)
    if type(x) == "function" then return x() end

    -- 每5秒确认游戏在前台
    if (time() - findOne_game_up_check_last_time > 5000) then
        findOne_game_up_check_last_time = time()
        wait_game_up()
    end

    local x0 = x
    confidence = confidence or default_findcolor_confidence

    if type(x) == 'string' and not x:find(coord_delimeter) then x = point[x] end
    if type(x) == "function" then return x() end
    if type(x) == "table" and #x == 0 then return findNode(x) end
    if type(x) == "table" and #x > 0 then return x end
    if type(x) == "string" then
        -- 控制截图频率
        local current = time()
        if findOne_interval > 0 and current - findOne_last_time > findOne_interval then
            findOne_last_time = time()
            -- log(500)
            -- releaseCapture()
            keepCapture()
        end

        -- sleep(max(0, findOne_interval - (time() - findOne_last_time)))
        -- findOne_last_time = time()
        local pos
        -- log(x0, rfl[x0], x, confidence)
        if rfl[x0] then
            if cmpColorEx(x, confidence) == 1 then pos = first_point[x0] end
        else
            local px, py
            -- log(x0, rfg[x0], first_color[x0], x)
            px, py = findMultiColor(rfg[x0][1], rfg[x0][2], rfg[x0][3], rfg[x0][4],
                first_color[x0], x, 0, confidence)
            if px ~= -1 then pos = { px, py } end
        end
        return pos
    end
end

findAny = function(x) return appear(x, 0, 0) end

findOnes = function(x, confidence)
    confidence = confidence or default_findcolor_confidence
    log(rfg[x], first_color[x], point[x])
    return findMultiColorAll(rfg[x][1], rfg[x][2], rfg[x][3], rfg[x][4],
        first_color[x], point[x], 0, confidence) or {}
end

-- x={2,3} "信用" func nil
tap_last_time = time()
tap = function(x, noretry, allow_outside_game)
    if not unsafe_tap and not allow_outside_game and not check_after_tap then
        wait_game_up()
    end

    local x0 = x
    if x == nil then return end
    if x == true then return true end
    if type(x) == "function" then return x() end
    if type(x) == "string" and not x:find(coord_delimeter) then
        x = point[x]
        if type(x) == "string" then
            local p = x:find(coord_delimeter)
            local q = x:find(coord_delimeter, p + 1)
            x = map(tonumber, { x:sub(1, p - 1), x:sub(p + 1, q - 1) })
        end
    end
    log("tap", x0, x)
    if type(x) ~= "table" then return end

    -- log(843, tap_interval)
    if tap_interval > 0 and tap_interval - (time() - tap_last_time) > 0 then
        return
        -- sleep(max(0, tap_interval - (time() - tap_last_time)))
    end

    tap_last_time = time()
    -- log(838,x)
    if #x > 0 then
        clickPoint(x[1], x[2])
    else
        clickNode(x)
    end
    collectgarbage("collect")

    -- collectgarbage('collect')
    local start_time = time()

    -- 后置检查
    if not unsafe_tap and not allow_outside_game and check_after_tap then
        wait_game_up()
    end

    -- 这个sleep的作用是两次gesture间隔太短被判定为长按/点击，游戏界面会无反应，
    -- 所以click后需要等一会儿
    -- 懒人无现象闪退，可能和点太快有关
    sleep(max(milesecond_after_click + start_time - time(), 0))

    -- 返回"面板"后易触发数据更新，导致操作失效
    if noretry then return end
    if type(x0) == 'string' and x0:startsWith('面板') then
        wait(function()
            if not findOne("面板") then return true end
            if findOne("阿米娅") then
                path.fallback.阿米娅()
                return true
            end
            log("retap", x0)
            tap(x0, true, allow_outside_game)
        end, 10)
    end
end

-- simple swip for 资源收集
swipq = function(direction)
    local finger = {
        point = {
            { screen.width // 2,                                screen.height // 2 },
            { direction == 'right' and (screen.width - 1) or 0, screen.height // 2 },
        },
        duration = 500,
    }
    gesture(finger)
    sleep(finger.duration + 50)
end

-- quick swip for fight
swipu = function(dis)
    log('swipu', dis)
    -- preprocess distance
    if type(dis) == "string" then dis = distance[dis] end
    if type(dis) ~= "table" then dis = { dis } end
    if not dis then return end
    log(705)
    -- flatten to one depth
    -- local max_once_dis = 1080
    -- local freey = scale(150)
    local freey = scale(180)              -- 避开14章右上角
    local freex = scale(360 / 720 * 1080) -- 第12章左上角
    local max_once_dis = screen.width - scale(300) - freex
    if type(swipp_max_len) == "string" and swipp_max_len ~= "" then
        max_once_dis = math.min(max_once_dis, screen.width * tonumber(swipp_max_len))
    end

    for _, d in pairs(dis) do
        local sign = d > 0 and 1 or -1
        if math.abs(d) == swip_right_max then
            swipe(sign > 0 and "right" or "left")
        else
            -- 只实现了右移
            if sign > 0 then stop("swipu左移未实现") end

            local finger = {
                {
                    point = { { freex, freey }, { freex, screen.height - 1 } },
                    start = 0,
                    duration = 0,
                },
            }
            local start = 0
            local duration = 150
            local interval = 50
            local end_delay = 50
            local flipy = swipu_flipy or 0
            local flipx = swipu_flipx or 0
            d = math.abs(d)
            while d > 0 do
                if d > max_once_dis then
                    table.insert(finger, {
                        point = {
                            { freex + max_once_dis, freey + flipx },
                            { freex + max_once_dis, freey + flipy },
                        },
                        start = start,
                        duration = duration,
                    })
                else
                    table.insert(finger, {
                        point = { { freex + d, freey }, { freex + d + flipx, freey + flipy } },
                        start = start,
                        duration = duration,
                    })
                end
                d = d - max_once_dis
                start = start + duration + interval
                -- log(finger[#finger])
            end
            local last_finger = finger[#finger]
            finger[1].duration = last_finger.start + last_finger.duration + end_delay
            log("finger", finger)
            gesture(finger)
            if type(swipp_wait_time) == "string" and swipp_wait_time ~= "" then
                sleep(tonumber(swipp_wait_time))
            end
            sleep(finger[1].duration + 50)
        end
    end
end

-- swip to end for fight
swipe = function(x)
    -- 作战中第一次右滑容易错位，先做一次
    if first_time_swipe then
        first_time_swipe = false
        -- swip("9-2")
    end

    -- tap({scale(300), scale(150)})
    log("swipe", x)
    if x == 'right' then
        -- 15章滑动修复
        gesture({
            {
                point = { { scale(500), scale(850) }, { 1000000, scale(850) } },
                start = 0,
                duration = 250,
            },
        })
        sleep(150 + 50)
    elseif x == 'left' then
        gesture({
            {
                point = { { screen.width - 100, scale(150) }, { scale(1), scale(150) } },
                start = 0,
                duration = 250,
            },
        })
        sleep(100 + 50)
    elseif x == 'lift' then
        gesture({
            {
                point = { { scale(300), scale(150) }, { scale(300), screen.height - 1 } },
                start = 0,
                duration = 100,
            },
            { point = { { screen.width - scale(300), 150 } }, start = 60, duration = 50 },
        })
        sleep(100 + 50)
    end
end

-- 安卓8以下的滑动用双指
android_verison_code = tonumber(getSdkVersion())
if android_verison_code < 24 then
    toast("安卓版本7以下不可用")
    ssleep(3)
end
-- if android_verison_code < 26 then
--   is_device_swipe_too_fast = true
-- else
--   is_device_swipe_too_fast = false
-- end

-- 华为手机需要慢速滑动
-- is_device_need_slow_swipe = true

-- simple swip for chapter navigation
swipc = function()
    local x1, y1, x2, y2
    x1, y1 = math.round((500 - 1920 / 2) * minscale + screen.width / 2),
        screen.height // 2
    x2, y2 = math.round((1500 - 1920 / 2) * minscale + screen.width / 2),
        scale(100)
    local finger = { point = { { x1, y1 }, { x2, y1 }, { x2, y2 } }, duration = 500 }
    gesture(finger)
    sleep(finger.duration + 50)
end

-- 基建翻页
swipo = function(left, nodelay)
    local duration
    local finger
    local delay
    if left then
        local x1 = scale(600)
        local x2 = scale(10000 / 720 * 1080)
        local y1 = scale(533)
        duration = 400
        finger = { { point = { { x1, y1 }, { x2, y1 } }, duration = duration } }
        delay = 750
    else
        local x = scale(600)
        local y = scale(533)
        local y2 = scale(900)
        local x2 = scale(1681)
        local y3 = scale(1005)
        local slids = 50
        local slidd = 200
        local taps = slids + slidd + 150
        local tapd = 200
        local downd = taps + 100
        duration = downd
        finger = {
            -- x,y是滑动起点,注意机器过卡的时候会产生点击的效果,所以x,y要避开响应点击的区域
            { point = { { x, y }, { x, y2 } },   start = 0,     duration = downd },
            -- x2,y3是滑动起点,注意机器过卡的时候会产生点击的效果,所以x2,y3要避开响应点击的区域
            { point = { { x2, y }, { x2, y3 } }, start = slids, duration = slidd },
            { point = { { x2, y }, { x2, y } },  start = taps,  duration = tapd },
        }
        delay = 250
    end
    log(JsonEncode(finger))
    gesture(finger)
    sleep(duration + (nodelay and 0 or delay))
    return nodelay and delay or 0
end

-- swip for fight
swip = function(dis)
    if type(dis) == "string" then dis = distance[dis] end
    if type(dis) ~= "table" then dis = { dis } end
    if not dis then return end

    -- 懒人单次手势不能添加过多定时点，理想是在插入finger时处理，偷懒直接手动切分下距离
    -- 只处理作战关卡导航中的情况
    log(700)
    log(dis)
    local max_dis_one_gesture = 5000
    if #dis == 2 and math.abs(dis[1]) == swip_right_max and dis[2] <
        -max_dis_one_gesture then
        table.insert(dis, dis[2] + max_dis_one_gesture)
        dis[2] = -max_dis_one_gesture
    end
    log(701)
    log(dis)
    for i, d in pairs(dis) do
        if i ~= 1 then ssleep(0.1) end
        if math.abs(d) == swip_right_max then
            swipe(d == swip_right_max and "right" or "left")
        else
            swipu(d)
        end
    end
end

-- pass loading, give a standard view of 基建
zoom = function(retry)
    log("zoom", retry)
    retry = retry or 0
    if retry > 20 then -- 20*200 = 4000（毫秒）
        -- TODO: 提示到底影响了什么，是不能缩放，还是缩放结束找不到
        log("缩放结束未找到")
        return true
    end

    log(696, findOne("进驻总览"))
    if not findOne("进驻总览") then return path.跳转("基建") end
    if findOne("缩放结束") then
        log("缩放结束")
        return true
    end

    -- 网络加载时重置retry
    if findOne("正在提交反馈至神经") then retry = 0 end

    -- 2x2 pixel zoom
    local duration = 40
    local delay = 500
    local finger

    -- 特殊兼容 华为云 miui13
    if retry % 2 == 0 then
        finger = {
            { point = { { 5, 0 } },           duration = duration },
            { point = { { 0, 0 }, { 5, 0 } }, duration = duration },
        }
    else
        log("缩放测试2")
        -- finger = {
        --     { point = { point["miui缩放开始"] }, duration = duration },
        --     { point = { point["miui缩放结束"], point["miui缩放开始"] }, duration = duration },
        -- }

        finger = {
            {
                point = { { screen.width - scale(300),      scale(180) },
                    { math.round(screen.width / 2 + scale(10)), math.round(screen.height / 2 - scale(10)) } },
                duration = duration,
                start = 0
            },
            {
                point = {
                    { scale(300),                               screen.height - scale(10) },
                    { math.round(screen.width / 2 - scale(10)), math.round(screen.height / 2 + scale(10)) },
                },
                duration = duration,
                start = 0
            },
        }
        -- finger = {
        --     { point = { { 0, 0 } },           duration = duration },
        --     { point = { { 0, 5 }, { 0, 0 } }, duration = duration },
        -- }
    end
    -- local w =screen.width//2
    --   local h=screen.height//2
    --     finger = {
    --       {point = {{w-5,h-5}}, duration = duration},
    --       {point = {{w+5,h+5}, {w-5,h-5}}, duration = duration},
    --     }
    gesture(finger)
    sleep(duration + 50)
    -- 右移
    path.swip_hd_shop(true)
    appear("缩放结束", 0.5)

    -- local start_time = time()
    -- if appear("缩放结束", (duration + 50) / 1000) then
    --   sleep(max(0, start_time + duration + 50 - time()))
    --   return true
    -- end
    return zoom(retry + 1)
end

auto_total_timeout_hook = function()
    -- 应对进关卡黑屏、启动游戏黑屏、卡死
    -- 愚人节
    if findOne("跳过剧情") then path.跳过剧情() end
    -- path.跳过剧情()

    -- 新增界面卡住、回归任务

    local known = { "面板", "主页" }
    wait(function()
        if findAny(known) then return true end
        tap("主题曲已开放")
        ssleep(.5)
    end, 5)

    wait(function()
        back()
        ssleep(.5)
    end, 2)

    if findAny(known) then return true end

    -- 全屏点一遍
    for w = 150, screen.width - 50, 50 do
        if findAny(known) then return true end
        for h = 50, screen.height - 50, 50 do
            tap({ w, h })
            back()
        end
    end
end
-- 为什么auto要有两组状态： 第二组状态点唯一性不足，比如返回与邮件同时出现时，需要的是邮件。没有优先级。
--- 自动状态机：
--- 根据状态表 p 不断轮询画面，出现某个 key（通过 findOne 判断）时，点击对应的 value（通常是坐标/点位），直到完成或超时。
--- - 若 total_timeout 未设置：理论上会一直循环，直到某个状态点击成功（finish=true）。
--- - 若 total_timeout 设置：
---     * total_timeout_restart=true 时，超时后会执行一次重启流程（带“登录未完成”的特殊处理），然后 stop 脚本。
---     * total_timeout_restart=false 时，超时直接返回 true。
--- - fallback 为真且本轮 wait 未命中任何状态时，会调用一次 `auto(path.fallback, nil, nil, 0)` 作为兜底。
--- @param p table<string, any>|fun():any  状态表（key 为状态名/识别点，value 为点击目标），或直接是一个函数（直接执行并返回）
--- @param fallback? boolean               是否启用 fallback 自动机（只在本轮 wait 无事件时触发一次）
--- @param timeout? number                 单次 wait 超时时间（秒），为 nil/0 表示不等待
--- @param total_timeout? number           auto 整体最长运行时间（秒），为 nil 表示不限制
--- @param total_timeout_restart? boolean  超时后是否走“重启游戏 + 钩子 + stop”流程
--- @return boolean?                       true 表示已完成/无需处理（包括超时返回），nil 表示在内部重启/stop 中断
auto = function(p, fallback, timeout, total_timeout, total_timeout_restart)
    if type(p) == "function" then return p() end
    if type(p) ~= "table" then return true end
    local start_time = time()
    while true do
        if total_timeout and time() - start_time > total_timeout * 1000 then
            if total_timeout_restart then
                if not 登录完成状态 then
                    log("登录未完成，尝试重启游戏再试一次")
                    restartapp(appid)
                    登录完成状态 = true
                    return
                end
                -- should be a hook, by defualt restartapp
                auto_total_timeout_hook()
                stop("auto超时" .. total_timeout .. 's', 'cur')
            else
                return true
            end
        end
        -- local found = false
        local finish = false
        local check = function()
            for k, v in pairs(p) do
                -- log(663, k, v)
                -- print(type(k))
                if findOne(k) then
                    -- log(664, k)
                    log(k, "=>", v)
                    -- effective_state = k
                    -- found = true
                    if tap(v) then finish = true end
                    return true
                end
            end
        end
        timeout = timeout or 0
        local e = wait(check, timeout)
        if finish then return true end

        -- fallback自动机只做一次
        if not e and fallback then auto(path.fallback, nil, nil, 0) end
    end
end

parse_time = function(x)
    if not x then return os.time() end
    return os.time({
        year = tonumber(x:sub(1, 4)),
        month = tonumber(x:sub(5, 6)),
        day = tonumber(x:sub(7, 8)),
        hour = tonumber(x:sub(9, 10)),
        min = tonumber(x:sub(11, 12)),
    })
end

qqnotify_before_run = function()
    qqmessage = {}
    if qqnotify_quiet then
        table.extend(qqmessage, { devicenote, usernote })
    elseif account_idx ~= nil then
        table.extend(qqmessage, {
            devicenote and devicenote or getDevice(), "号" .. account_idx,
            server == 0 and "官服" or "B服", username, usernote,
        })
    else
        table.extend(qqmessage, {
            devicenote and devicenote or getDevice(),
            server == 0 and "官服" or "B服",
        })
    end
end

qqnotify_after_run = function(run_start_time)
    local qqmessage_bak = shallowCopy(qqmessage)
    if run_start_time then
        table.insert(qqmessage,
            math.floor((time() - run_start_time) / 1000 / 60) .. "分钟")
    end
    if not qqnotify_nofight then
        table.insert(qqmessage, shrink_fight_config(fight_history))
    end
    path.跳转("首页")
    captureqqimagedeliver("INFO", "通知", table.join(qqmessage, ' '))
    qqmessage = qqmessage_bak
end

qqnotify_before_restart_package = function()
    table.insert(qqmessage, "即将重启脚本")
    if not qqnotify_nofight then
        table.insert(qqmessage, shrink_fight_config(fight_history))
    end
    captureqqimagedeliver("INFO", "战术重启", table.join(qqmessage, ' '))
end

-- run function / job / table of function and job
run = function(...)
    pcall(upload_launch_info, "account")
    local run_internal = function(...)
        local arg = { ... }
        if #arg == 1 then
            if type(arg[1]) == "function" then return arg[1]() end
            if type(arg[1]) == "table" then arg = arg[1] end
        end
        local run_start_time = time()
        qqnotify_before_run()
        update_state()
        save_run_state()
        wait_game_up()
        for _, v in ipairs(arg) do
            running = v
            if type(v) == 'function' then
                v()
            else
                auto(path[v], path.fallback)
            end
        end
        qqnotify_after_run(run_start_time)
    end

    if catch_run_crash then
        local status, err = pcall(run_internal, ...)
        if not status then
            log("Error in run(): " .. err)
            toast("捕获到运行崩溃，请上传日志至开发者，即将跳过当前任务")
            ssleep(5)
        end
    else
        run_internal(...)
    end
end

half_hour_cron = function(x, h)
    local m = 30
    if type(x) == "table" then
        if #x == 3 then
            x, h, m = x[1], x[2], x[3]
        else
            x, h = x[1], x[2]
        end
    end
    return { callback = function() run(x) end, hour = h, minute = m }
end

findTap = function(target)
    if type(target) == 'string' or #target == 0 then target = { target } end
    for _, v in pairs(target) do
        -- log(574, v, type(v))
        local p = findOne(v)
        if p then
            --      log("findTap:", v, p)
            tap(p)
            return v
        end
    end
end

appearTap = function(target, timeout, interval)
    if type(target) == 'string' or #target == 0 then target = { target } end
    target = appear(target, timeout, interval)
    if target then
        -- log("apperTap: ", target)
        findTap(target)
        return true
    end
end
-- {x:2,y:3} => {2,3}
xy2arr = function(t) return { t.x, t.y } end

clamp = function(x, minimum, maximum)
    minimum = minimum or 0
    maximum = maximum or (screen.width - 1)
    return min(max(x, minimum), maximum)
end
clampw = clamp
clamph = function(x, minimum, maximum)
    return clampw(x, minimum or 0, maximum or (screen.height - 1))
end

-- resoluton invariant deploy
-- idx=1 => the left most operator
-- idx=total => the right most operator
-- x2,y2 => destination
-- d => direction
deploy2 = function(idx, total, x2, y2, d)
    local max_op_width = scale(178) --  in loose mode, each operator's width
    local x1
    if total * max_op_width > screen.width then
        -- tight
        max_op_width = screen.width // total
        x1 = idx * max_op_width - max_op_width // 2
    else
        -- loose
        x1 = screen.width - (total - idx) * max_op_width - max_op_width // 2
    end
    x2 = math.round((x2 - (1920 / 2)) * minscale) + (screen.width // 2)
    y2 = math.round((y2 - (1080 / 2)) * minscale) + (screen.height // 2)
    deploy(x1, x2, y2, d)
end

deploy = function(x1, x2, y2, d, nopause)
    log("deploy", x1, x2, y2, d, nopause)
    local y1 = screen.height - scale(109)
    local d = d or 2
    d = ({ { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 } })[d]
    d = { d[1] * 500, d[2] * 500 }
    local dragd = 800
    local dird = 200
    local delay = 150 -- 有人卡这儿？
    local x3 = x2 - scale(5)
    local x4 = x2 + scale(5)
    local y3 = y2 - scale(5)
    local y4 = y2 + scale(5)
    local finger = {
        {
            point = {
                { x1, y1 }, { x1, y1 - 60 }, { (x1 + x2) / 3 * 2, (y1 + y2) / 3 * 2, }, --{x2, y2-40},
                { x2, y2 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x2, y2 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x2, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x2, y2 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 },
                { x4, y2 }, { x2, y3 }, { x2, y2 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 },
                { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 },
                { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 },
                { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 },
                { x3, y2 }, { x4, y2 }, { x2, y3 }, { x2, y4 }, { x3, y2 }, { x4, y2 }, { x2, y2 },
            },
            duration = dragd,
        }, {
        point = { { x2, y2 }, { clamp(x2 + d[1]), clamp(y2 + d[2]) } },
        duration = dird,
        start = dragd + delay,
    },
    }
    -- if 1 or zl_enable_tap_before_drag then
    --   tap({x1, y1})
    --   ssleep(.5)
    -- end
    gesture(finger)
    sleep(250)
    if not nopause then back() end
    sleep(dragd + delay + dird + delay - 250)
    if not nopause then back() end
    log("deploy", finger)
end

-- todo: make a map ?
retreat = function(x1, y1, x2, y2)
    local t = .5
    x1 = math.round((x1 - (1920 / 2)) * minscale) + (screen.width // 2)
    y1 = math.round((y1 - (1080 / 2)) * minscale) + (screen.height // 2)
    x2 = math.round((x2 - (1920 / 2)) * minscale) + (screen.width // 2)
    y2 = math.round((y2 - (1080 / 2)) * minscale) + (screen.height // 2)
    tap({ x1, y1 })
    ssleep(t)
    tap({ x2, y2 })
    ssleep(t)

    -- touchDown(0, x1, y1)
    -- ssleep(t)
    -- touchUp(0, x1, y1)
    -- ssleep(t)
    -- touchDown(0, x2, y2)
    -- ssleep(t)
    -- touchUp(0, x2, y2)
end

--- wait until func success
---@param func function 循环体
---@param timeout number 循环最大时间,单位秒
---@param interval number 单次循环间隔时间,单位秒
wait = function(func, timeout, interval)
    timeout = timeout or 2
    interval = interval or 0
    -- log(timeout,interval)
    local start_time = time()
    local reset_wait_start_time = function()
        if not disappear("正在提交反馈至神经", network_timeout) then
            stop("网络连接超时" .. network_timeout .. "秒", 'cur')
        end
        start_time = time()
    end
    while true do
        local ans = func(reset_wait_start_time)
        -- log(584,ans)
        if ans then return ans end
        if (time() - start_time) > timeout * 1000 then break end
        ssleep(interval)
    end
end

-- wait until see node / point / list of node and point
appear = function(target, timeout, interval, disappear)
    --log((disappear and "dis" or '') .. "appear", target)
    if not (type(target) == 'table' and #target > 0) then target = { target } end
    return wait(function()
        for _, v in pairs(target) do
            -- log(1291, type(v), #v, v, findNode(v))
            if disappear then
                if type(v) == "function" and not v() then
                    return v
                elseif type(v) == "table" and #v == 0 and not findNode(v) then
                    return v
                elseif type(v) == "string" and #v > 0 and not findOne(v) then
                    return v
                end
            else
                if type(v) == "function" and v() then
                    return v
                elseif type(v) == "table" and #v == 0 and findNode(v) then
                    return v
                elseif type(v) == "string" and #v > 0 and findOne(v) then
                    return v
                end
            end
        end
    end, timeout, interval)
end

disappear = function(target, timeout, interval)
    return appear(target, timeout, interval, true)
end

wait_game_up = function(retry)
    retry = retry or 0
    if disable_game_up_check then return end
    local prev = disable_game_up_check
    disable_game_up_check = true

    if findOne("game") then
        disable_game_up_check = prev
        -- 前台切到游戏后，需要延时再设悬浮按钮与oom_score_adj
        if retry > 0 then
            setTimer(setControlBar, 2000)
            setTimer(setControlBar, 5000)
            setTimer(oom_score_adj, 2000)
            setTimer(oom_score_adj, 5000)
        end
        return
    end

    if retry == 2 then closeapp(appid) end
    if retry >= 4 then stop("无法启动游戏", 'cur') end

    open(appid)
    screenon()
    request_game_permission()
    local p = appear({
        "game", "keyguard_indication", "keyguard_input", "captcha",
        "同意并继续",
    }, 5)
    if p == "同意并继续" then path.bilibili_login[p]() end
    trySolveSlipCaptcha()
    log(1701)
    checkScreenLock()
    log("wait_game_up next", retry)
    disable_game_up_check = prev
    return wait_game_up(retry + 1)
end

screenLockSwipUp = function()
    if not wait(function()
            local node = findOne("keyguard_indication")
            if not node then return true end
            local center = (node.bounds.t + node.bounds.b) // 2
            local width = getScreen().width
            gesture({ point = { { width // 2, center }, { width // 2, 1 } }, duration = 1000 })
            sleep(1000 + 50)
        end, 5) then
        stop("解锁失败1004")
    end
end
screenLockGesture = function()
    local point = JsonDecode(unlock_gesture or "[]") or {}
    log("point", point)
    if findOne("keyguard_input") then
        if unlock_mode == 0 then
            gesture({ point = point, duration = 3000 })
            sleep(3000 + 50)
        else
            for _, p in pairs(point) do
                tap(p)
                ssleep(.5)
            end
        end
        if not disappear("keyguard_input") then stop("解锁失败1005") end
    end
end

-- 检查解锁界面
checkScreenLock = function()
    screenLockSwipUp()
    screenLockGesture()
end
checkScreenLock = disable_game_up_check_wrapper(checkScreenLock)

coming_hour = function(a, b, starttime)
    if a == nil then return b end
    if b == nil then return a end
    start = os.date("*t", starttime)

    atime = os.time({
        year = start.year,
        month = start.month,
        day = start.day,
        hour = tonumber(a),
    })
    if atime < starttime then atime = atime + 24 * 3600 end

    btime = os.time({
        year = start.year,
        month = start.month,
        day = start.day,
        hour = tonumber(b),
    })
    if btime < starttime then btime = btime + 24 * 3600 end

    if atime - starttime < btime - starttime then return a end
    return b
end

findtap_operator = function(operator)
    operator_notfound = table.value2key(operator)
    found = #operator
    swipo(true)
    tap("清空选择")
    -- swip 3 times only
    for i = 1, 3 do
        if found <= 0 then return end
        if i ~= 1 then swipo() end
        ssleep(1)
        -- 616,107
        local res = ocrp({
            rect = { scale(616), scale(107), screen.width - 1, screen.height - 1 },
        })
        res = res or {}

        for _, node in pairs(res) do
            log(node.text)
            for pattern, _ in pairs(operator_notfound) do
                if string.find(node.text, pattern) then
                    log('found', pattern)
                    tap(node.text_box_position[1])
                    operator_notfound[pattern] = nil
                    found = found - 1
                    if found == 0 then return end
                    break
                end
            end
        end
    end
end

ocr_fast = function(x1, y1, x2, y2, timeout)
    timeout = timeout or 10
    local status, text, info
    wait(function()
        if status then return true end
        status, text, info = pcall(ocr, x1, y1, x2, y2)
    end, timeout)
    if not status then
        text = nil
        info = {}
    end
    return text, info
end

findtap_operator_fast = function(operator)
    operator_notfound = table.value2key(operator)
    found = #operator
    -- swip 3 times only
    for i = 1, 3 do
        if found <= 0 then return end
        if i ~= 1 then swipo() end

        -- TODO: wait for 节点精灵 fix bug
        -- we must ocr on small region if we want to use position
        local region = {
            { 590, 487, 1059, 523 }, { 1033, 487, 1491, 523 }, { 1464, 487, 1919, 523 },
            { 590, 907, 1059, 943 }, { 1033, 907, 1491, 943 }, { 1464, 907, 1919, 943 },
        }

        -- {0,0,0,0,"1059,457,#D2D1D1|1033,455,#FFFFFF|1464,443,#D1CACE|1491,446,#D6D5D5",95}

        -- local r = region[1]
        -- ocr_fast(scale(r[1]), scale(r[2]),
        --          scale(r[3]), scale(r[4]))
        for _, r in pairs(region) do
            local text, info
            text, info = ocr_fast(scale(r[1]), scale(r[2]), scale(r[3]), scale(r[4]))
            if text then
                log(text, info, r)
                for _, w in pairs(info.words) do
                    if operator_notfound[w.word] then
                        log('found', w.word)
                        tap({ scale(r[1]) + w.rect.left, scale(r[2]) + w.rect.top })
                        operator_notfound[w.word] = nil
                        found = found - 1
                        if found == 0 then return end
                    end
                end
                -- 补救节点精灵bug
                for w in string.gmatch(text, "([%z\1-\127\194-\244][\128-\191]*)") do
                    if operator_notfound[w] then
                        log('found in text but not in words', w)
                        tap({
                            math.round((r[3] - 100) * minscale),
                            math.round((r[4] - 100) * minscale),
                        })
                        operator_notfound[w] = nil
                        found = found - 1
                        if found == 0 then return end
                    end
                end
            end
        end
    end
end

-- findtap_operator_type = function(type)
--   swipo(true)
--   tap("清空选择")
--   ssleep(2)
--   log('type', type)
--   local 经验加速 = {
--     '#261500-50',
--     '[{"a":0.129,"d":1.622,"id":"1","r":529.0,"s":"34|5<fOm>&5~9zPN&5~amm]&5>Yg}@&5]8m]^&5X[L$H&5X[L$H&5X[L$X&5>xRmv&5<quBx&5>GERF&5>GERE&5X[L$Y&5X[Npu&5X[Npu&5Y6o!c&5>YhCE&5~a15*&5~9z^6&5~9z^6&2~zjVe"}]',
--     0.85,
--   }
--   local 赤金加速 = {
--     '#202020-50',
--     '[{"a":-0.044,"d":1.807,"id":"1","r":358.0,"s":"22|py&PS&PS&PS&H6!&18dN&18dN&18dM&18dM&2OY&2OY&2LC&2LC&2gre&4wSA&8{v2&8{v2&4wSs&aL6&ax~&ax~&lgc&k]*&k]*&lGs&H6!&H6!&H6!&18dM&H6Y"}]',
--     0.85,
--   }
--   if type == '经验站' then
--     type = 经验加速
--   elseif type == "赤金站" then
--     type = 赤金加速
--   end
--   -- swip 3 times only
--   for i = 1, 3 do
--     if i ~= 1 then swipo() end
--
--     local candidate = findShape(type)
--     if candidate then
--       log(11777, #candidate)
--       local p = {}
--       for j, c in pairs(candidate) do
--         -- 宽度不超过
--         if c['x'] < 1920 * minscale then
--           table.insert(p, 'candidates' .. j)
--           point['candidates' .. j] = {c['x'], c['y']}
--         end
--       end
--       if #p > 0 then
--         tapAll(p)
--         ssleep(.1)
--       end
--     end
--   end
--   swipo(true)
-- end

timeit = function(f)
    local start = time()
    f()
    log(time() - start)
end

tapAll = function(ks)
    log("tapAll", ks)
    if #ks == 0 then return end
    -- 0 还是漏第一个
    -- 试试100 还是会漏第一个，即使界面看上去已经是完全可用状态了
    local duration = 1
    if tapall_duration > 0 then duration = tapall_duration end

    local finger = {}
    for i, k in pairs(ks) do
        if type(k) == 'string' then k = point[k] end
        table.insert(finger, { point = { { k[1], k[2] } }, duration = duration })
    end
    log('tapall', finger)
    if enable_simultaneous_tap then
        gesture(finger)
        sleep(duration + 50)
    else
        for _, v in pairs(finger) do tap(v.point[1]) end
    end
end

-- event queue
Lock = {}
function Lock:new(o)
    o = o or { queue = {}, length = 0, id = 0 }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Lock:remove(id)
    self.queue[id] = nil
    self.length = self.length - 1
end

function Lock:exist(id) return self.queue[id] end

function Lock:add()
    self.id = self.id + 1
    self.queue[self.id] = 1
    self.length = self.length + 1
    return self.id
end

lock = Lock:new()

---审判庭通知和推送
---@param log_level string INFO,WARN
---@param log_title string 通知标题
---@param log_detail string 通知内容
---@param important boolean 是否通知用户
captureqqimagedeliver = function(log_level, log_title, log_detail, important)
    local f = io.open(getWorkPath() .. '/.nomedia', 'w')
    f:close()
    local img = getWorkPath() .. "/tmp.jpg"
    local img_src = img

    hideControlBar()
    ssleep(.5)
    snapShot(img)
    setControlBar()

    info = log_title .. ' ' .. log_detail

    log_title = os.date('[%m-%d][%H:%M]') .. ' ' .. log_title

    if not qqnotify_notime then info = os.date('%m.%d %H:%M:%S') .. ' ' .. info end

    img = base64(img)
    info = tostring(info):trim():gsub("%s+", ' ')

    -- qq
    notifyqq(img, info, QQ)
    if important then notifyqq(img, info, QQ2) end

    local img_url
    if cloud.enabled() then
        img_url = cloud.uploadImgToInquisition(img_src)
    elseif type(pushplus_token) == 'string' and #pushplus_token > 5 then
        img_url = uploadImg(img_src)
    elseif type(telegram_token) == 'string' and type(telegram_chatid) == 'string' and
        #telegram_token > 0 and #telegram_chatid > 0 then
        img_url = uploadImg(img_src)
    else
        img_url = ''
    end

    -- 检查url是否正确（有时候图床上传可能会失败）
    if string.find(img_url, "http") == nil then img_url = '' end

    -- pushplus
    notifypp(img_url, info, pushplus_token, pushplus_channel)

    -- tg
    notifytg(getWorkPath() .. "/tmp.jpg", info, sync)

    -- 企业微信推送
    local imgmd5 = fileMD5(getWorkPath() .. "/tmp.jpg")
    notify_wechat(wechat_webhook_url, info, img, imgmd5)

    -- cloud
    cloud.addLog(log_level, log_title, log_detail, img_url)

    -- local
    -- if qqnotify_save then
    --     local img_dst = '/sdcard/' .. package .. '/' .. path_name_escape(info) ..
    --         '.jpg'
    --     exec("cp '" .. img_src .. "' '" .. img_dst .. "'")
    -- end
end

poweroff =
    function() if root_mode then exec("su root sh -c 'reboot -p'") end end

kill_game_last_time = { [oppid] = time(), [bppid] = time() }
closeapp = function(package)
    if not package then return end
    -- log("package",package)
    -- 记录app被杀时间
    kill_game_last_time[package] = time()
    -- log("closeapp", package)
    if not isAppInstalled(package) then return end
    if root_mode then
        exec("su root sh -c 'am force-stop " .. package .. "'")
    else
        --log("无障碍模式关闭app方式", app_close_way)
        if app_close_way == 1 then
            local intent = {
                action = "android.settings.APPLICATION_DETAILS_SETTINGS",
                uri = "package:" .. package,
            }
            runIntent(intent)
            --log(intent)
            local stop_node
            stop_node = appear({
                { text = ".*停止.*" }, { text = ".*结束.*" }, { text = ".*STOP.*" },
            }, 10)
            --log(stop_node)
            if not stop_node then return end
            stop_node = findNode(stop_node)
            if not stop_node or not stop_node.enabled then return back() end
            tap(stop_node)

            ok_node = nil
            ok_node = appear({ { text = ".*确.*" }, { text = ".*OK.*" } }, 5)
            if not ok_node then return end
            ok_node = findNode(ok_node)
            if not ok_node or not ok_node.enabled then return back() end
            tap(ok_node)
            disappear(ok_node)
            back()
            disappear(stop_node)
            ssleep(1)
        elseif app_close_way == 2 then
            stopApp(package)
        elseif app_close_way == 3 then
            path.跳转("首页")
            back()
            appear("右确认")
            ssleep(1)
            tap("右确认")
            ssleep(1)
        end
    end
end
closeapp = disable_game_up_check_wrapper(closeapp)
restartapp = function(package)
    closeapp(package)
    wait_game_up()
end
screenoff = function()
    if root_mode then exec([[su root sh -c 'input keyevent 223']]) end
end
screenon = function()
    if root_mode then
        exec([[su root sh -c 'input keyevent 224']])
    else
        -- stop("无障碍亮屏未实现")
    end
end

multiply = function(prefix, times)
    times = times or 1
    local ans = {}
    for i = 1, times do table.insert(ans, prefix .. i) end
    return ans
end

parse_id_to_ui = function(prefix, length)
    local ans = ''
    for i = 1, length do ans = ans .. prefix .. i .. '|' end
    return ans:sub(1, #ans - 1)
end

parse_value_to_ui = function(all, select)
    local ans = ''
    for _, v in pairs(all) do
        if table.includes(select, v) then ans = ans .. '*' end
        ans = ans .. v .. '|'
    end
    return ans:sub(1, #ans - 1)
end

parse_from_ui = function(prefix, reference)
    local ans = {}
    for i = 1, #reference do
        -- log("prefix..i", prefix .. i, _G[prefix .. i])
        if _G[prefix .. i] then table.insert(ans, reference[i]) end
    end
    return ans
end

transfer_global_variable = function(prefix, save_prefix)
    local stem
    -- 存在了几个月的BUG：遍历key的过程中修改key
    local G = {}
    for k, v in pairs(_G) do
        if k:startsWith(prefix) then
            stem = string.sub(k, #prefix + 1)
            if save_prefix and #save_prefix > 0 then
                G[save_prefix .. stem] = _G[stem] or false
            end
            G[stem] = v
        end
    end
    update(_G, G, true)
end

notifyqq = function(image, info, to, sync)
    image = image or ''
    info = info or ''
    to = to or ''

    if #to < 5 then return end

    local param = "image=" .. encodeUrl(image) .. "&info=" .. encodeUrl(info) ..
        "&to=" .. encodeUrl(to)
    log('notify qq', info, to)

    local id = lock:add()
    asynHttpPost(function(res, code)
        -- log("notifyqq response", res, code)
        lock:remove(id)
    end, qqimagedeliver, param)
    if sync then wait(function() return not lock:exist(id) end, 30) end
end

notifypp = function(img, info, to, channel, sync)
    img = img or ''
    info = info or ''
    to = to or ''

    if #to < 5 then return end

    -- 不发图更好
    local param = "content=" .. encodeUrl("![](" .. img .. ")") .. "&title=" ..
        encodeUrl(info) .. "&token=" .. encodeUrl(to) ..
        "&template=markdown"
    if #strOr(channel) > 0 then param = param .. "&channel=" .. channel end
    log('notify pp', info, to)
    -- log("param", param)

    local id = lock:add()

    asynHttpPost(function(res, code)
        log("notifypp response", res, code)
        lock:remove(id)
    end, 'http://www.pushplus.plus/send', param)

    if sync then wait(function() return not lock:exist(id) end, 30) end
end

notifytg = function(img_path, info, sync)
    log("notifytg")
    img_path = img_path or ''
    info = info or ''
    chatid = telegram_chatid or ''
    bottoken = telegram_token or ''
    tgapi = telegram_api or 'https://api.telegram.org/'
    if type(tgapi) ~= 'string' or (type(tgapi) == 'string' and #tgapi == 0) then tgapi = 'https://api.telegram.org/' end
    if string.find(tgapi, "http") == nil then tgapi = 'https://' .. tgapi end

    if #chatid == 0 and #bottoken == 0 then return end

    local id = lock:add()
    if #img_path == 0 and (not telegram_api_curl) then -- 图片url为空 不发图
        local tgurl = tgapi .. 'bot' .. bottoken .. '/sendMessage'
        local param = "chat_id=" .. chatid .. "&text=" .. encodeUrl(info)
        asynHttpPost(function(code)
            log("notifytg", code)
            lock:remove(id)
        end, tgurl, param)
        log("notifytg", tgurl, param)
    else
        copy_file_s(img_path, '/sdcard/Pictures/image.png')
        local tgurl = tgapi .. 'bot' .. bottoken .. '/sendPhoto'

        local param = {
            chat_id = chatid,
            caption = info,
        }
        curl_post(tgurl, nil, param, 10, '-F "photo=@/sdcard/Pictures/image.png"')
        log("notifytg", tgurl, param)
    end
    if sync then wait(function() return not lock:exist(id) end, 30) end
end

-- 企业微信推送
notify_wechat = function(webhookurl, info, img, md5)
    log("notify_wechat")
    webhookurl = webhookurl or ''
    info = info or ''
    if #webhookurl == 0 then return end
    log(webhookurl)
    if string.find(webhookurl, "#") then
        local result = {}
        for item in string.gmatch(webhookurl, "[^#]+") do
            table.insert(result, item)
        end
        if #result > 0 then
            local i = math.random(1, #result)
            webhookurl = result[i]
        end
    end
    log(webhookurl)
    if string.find(webhookurl, "weixin.qq.com") == nil then
        webhookurl = 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=' ..
            webhookurl
    end
    -- 推送文字
    local body = { msgtype = "text", text = { content = info } }
    local res, code = httpPost(webhookurl, JsonEncode(body), 15,
        "Content-Type: application/json;charset=UTF-8")
    if code ~= 200 then log("Wechat text failed", code, res) end
    -- 推送图片 因为markdown格式限制4kb 使用文件上传获取media麻烦，故图片文字分开发送
    if img ~= nil then
        local body = { msgtype = "image", image = { base64 = img, md5 = md5 } }
        local res, code = httpPost(webhookurl, JsonEncode(body), 15,
            "Content-Type: application/json;charset=UTF-8")
        if code == 200 then
            log("Wechat notify successfully")
        else
            log("Wechat picture failed", code, res)
        end
    end
end

-- remove unneed elements while preserving cursor
clean_table = function(t, idx, bad)
    local ans = {}
    for k, v in pairs(t) do
        if not bad(v) then table.insert(ans, v) end
        if idx == k then idx = #ans end
    end
    return ans, idx
end

download_from_alist = function(file_name, path)
    local path = path or getWorkPath()
    path = path .. '/' .. file_name
    local url = ark_api_base .. "/ark/get_file?name=" .. file_name .. "&verify=arklights"
    local ret, code = httpGet(url, 10)
    log(ret, code)
    if code == 200 then
        local data = JsonDecode(ret)
        local download_url = get(data, 'url')
        local file_md5 = get(data, 'md5')
        local local_md5 = fileMD5(path)
        if local_md5 ~= file_md5 then
            log(file_name, path, download_url)
            toast("正在下载" .. file_name .. ",请稍等")
            downloadFile(download_url, path)
            if fileMD5(path) == file_md5 then
                return true
            end
        else
            return true
        end
    end
end

unpacking_library = function()
    if use_system_library then
        _G.sqlite3path = "sqlite3"
        _G.curlpath = "curl"
    else
        --sqlite3
        if not fileExist("/data/local/tmp/sqlite3") then
            local ret = download_from_alist("sqlite3", "/sdcard/Pictures")
            if ret then
                copy_file_su("/sdcard/Pictures/sqlite3", "/data/local/tmp/sqlite3")
                sqlite3path = "/data/local/tmp/sqlite3"
                setFilePremission(sqlite3path, "777")
            else
                sqlite3path = "sqlite3"
            end
        else
            sqlite3path = "/data/local/tmp/sqlite3"
        end

        local curl_file = "curl_" .. get_cpu_arch()
        curl_file = curl_file:map({
            ["\n"] = "",
            [" "] = "",
            ["　"] = "",
        })

        if curl_file == "curl_" then
            curl_file = "curl_arm64-v8a"
        end

        if not fileExist("/data/local/tmp/" .. curl_file) then
            ret = download_from_alist(curl_file, "/sdcard/Pictures")
            if ret then
                copy_file_su("/sdcard/Pictures/" .. curl_file, "/data/local/tmp/" .. curl_file)
                curlpath = "/data/local/tmp/" .. curl_file
                setFilePremission(curlpath, "777")
            else
                curlpath = "curl"
            end
        else
            curlpath = "/data/local/tmp/" .. curl_file
        end
    end
    log("sqlite3path", sqlite3path, "curlpath", curlpath)
end

check_hot_update = function()
    toast("正在检查更新...")

    local file_md5 = loadConfig("lr_md5", "null")
    local skill_md5 = loadConfig("skill_md5", "null")

    -- 检查是否需要更新
    update_source = (custom_update_source and #custom_update_source > 1) and custom_update_source or update_source
    update_source = update_source:trim()
    local apk_v = dev_mode and 1000000 or getApkVerInt()
    local res, code = httpGet(
        update_source .. "/checkUpdate?lr_md5=" .. tostring(file_md5) ..
        "&skill_md5=" .. tostring(skill_md5) .. "&apk_ver=" .. tostring(apk_v), 5)
    if code ~= 200 then
        toast("无法连接到审判庭热更新服务器，即将更换")
        ssleep(1)
        return false
    end
    local status, data = pcall(JsonDecode, res)
    local update_info = data.data
    return update_info
end

updateLr = function(update_info)
    local new_script_path = getWorkPath() .. '/newscript.lr'
    if update_info.updateLr then
        toast("正在更新脚本...")
        if downloadFile(update_info.lrUrl, new_script_path) == -1 then
            toast("下载最新版本失败")
            return false
        end
    else
        toast("脚本已经是最新版")
        return true
    end
    if fileMD5(new_script_path) ~= update_info.lrMD5 then
        toast("脚本校验失败")
        return false
    end
    installLrPkg(new_script_path)
    saveConfig("lr_md5", update_info.lrMD5)
    return true
end

updateSkill = function(update_info)
    local skill_extract_path = getWorkPath() .. '/skill'
    local skill_path = getWorkPath() .. '/skill.zip'
    if dev_maps then
        log("开发模式解压skill.zip")
        extractAssets("main.rc", getWorkPath(), "skill.zip")
        unZip(skill_path, skill_extract_path)
        return
    end
    if update_info.updateSkill then
        toast("正在更新基建图标...")
        if downloadFile(update_info.skillUrl, skill_path) == -1 then
            toast("下载最新版本基建图标失败")
            return false
        end
    else
        toast("基建图标已经是最新版")
        return true
    end
    if fileMD5(skill_path) ~= update_info.skillMD5 then
        toast("基建图标校验失败")
        return false
    end
    unZip(skill_path, skill_extract_path)
    saveConfig("skill_md5", update_info.skillMD5)
    return true
end

uploadStatistician = function(is_download)
    local account_count = multi_account_num_get()
    local uuid = loadConfig("uuid", "null")
    local url = update_source ..
        "/statistician?uuid=" ..
        tostring(uuid) ..
        "&account_count=" ..
        tostring(account_count) ..
        "&is_download=" ..
        tostring(is_download)
    local res, code = httpGet(url, 5)
    local status, data = pcall(JsonDecode, res)
    if not status then
        return
    end
    if data.data.uuid ~= uuid then
        saveConfig("uuid", data.data.uuid)
        log("uuid已更新 " .. data.data.uuid)
    end
end


check_hot_update_backup = function()
    toast("正在获取更新数据...")
    local file_md5 = loadConfig("lr_md5", "null")
    local skill_md5 = loadConfig("skill_md5", "null")

    local res, code = httpGet(ark_api_base .. "/ark/script/update", 5)
    if code ~= 200 then
        toast("无法连接到主热更新服务器，即将切换")
        return false
    end
    local status, data = pcall(JsonDecode, res)
    local update_info = data
    update_info = {
        lrUrl = data.script.url,
        lrMD5 = data.script.md5,
        updateLr = true and data.script.md5 ~= file_md5 or false,
        skillUrl = data.skill.url,
        skillMD5 = data.skill.md5,
        updateSkill = true and data.skill.md5 ~= skill_md5 or false,
        isOldApk = false,
    }
    return update_info
end

hotUpdate = function()
    if disable_hotupdate or dev_mode then
        log("热更新已禁用")
        return true
    end
    local update_info
    -- if math.random() < 0.2 then
    --     update_info = check_hot_update()
    --     if not update_info then
    --         update_info = check_hot_update_backup()
    --     end
    -- else
    --     update_info = check_hot_update_backup()
    -- end
    for i = 1, 3 do
        if i == 1 then
            update_info = check_hot_update_backup()
        elseif i == 2 then
            ark_api_base = "https://arkapi.moyuancn.vip"
            update_info = check_hot_update_backup()
        elseif i == 3 then
            update_info = check_hot_update()
        end
        if update_info then break end
    end

    if not update_info then
        log("热更新检查失败")
        return false
    end

    log("update_info", update_info)
    if get(update_info, "isOldApk") then
        toast("当前APK版本过旧，请更新！")
        sleep(1000)
        exit()
    end
    if not update_info.updateLr and not update_info.updateSkill then
        toast("已经是最新版")
        --显示一些更新公告
        toast(update_announcement)
        uploadStatistician(false)
        return true
    end
    updateLr(update_info)
    updateSkill(update_info)
    toast("基建图标已经是最新版")
    uploadStatistician(true)
    sleep(1000)
    log("更新完成")

    return restartScript()
end

gesture_capture = function()
    tap_interval = -1
    findOne_interval = -1
    -- update_state_from_debugui()
    local finger = {}
    screenoff()
    ssleep(3)
    -- wait(function()
    --   log(findOne("gesture_capture_ui"))
    --   nodeLib.updateNode()
    --   if not findOne("gesture_capture_ui") then return true end
    -- end,5)

    -- disappear("gesture_capture_ui", 5)
    screenon()
    disappear("gesture_capture_ui", 1)

    local state
    if not wait(function()
            state = appear({
                "gesture_capture_ui", "keyguard_indication", "keyguard_input",
            }, 5)
            if not state then
                stop("未找到解锁界面")
            elseif state == "gesture_capture_ui" then
                ui.setText("unlock_gesture", JsonEncode({}))
                return true
            elseif state == "keyguard_indication" then
                screenLockSwipUp()
            elseif state == "keyguard_input" then
                return true
            end
        end, 30) then
        stop("手势录制2010")
    end

    if state == title then return end
    log(200)

    if not wait(function()
            local p = catchClick()
            if findOne("gesture_capture_ui") then return true end
            if p then
                table.insert(finger, { p.x, p.y })
                ui.setText("unlock_gesture", JsonEncode(finger))
            end
        end, 30) then
        stop("手势录制超时")
    end
end
gesture_capture = disable_game_up_check_wrapper(gesture_capture)

assignGlobalVariable = function(t)
    for k, v in pairs(t) do
        -- if string.find(k, "dual") then log(k, v, type(v)) end
        -- if _G[k] then log("_G[k] exist", k, v) end
        _G[k] = v
    end
end

all_apps = getInstalledApk()
isAppInstalled = function(package) return table.includes(all_apps, package) end

--随机生成指定长度字符串
randomString = function(length)
    length = length or 8
    local res = ""
    for i = 1, length do res = res .. string.char(math.random(97, 122)) end
    return res
end

gesture = function(fingers)
    if #fingers == 0 then fingers = { fingers } end
    local gesture = Gesture:new() -- 创建一个手势滑动对象
    for _, finger in pairs(fingers) do
        local path = Path:new()
        for _, point in pairs(finger.point) do path:addPoint(point[1], point[2]) end
        path:setDurTime(finger.duration or 1000)
        path:setStartTime(finger.start or 0)
        gesture:addPath(path)
    end
    gesture:dispatch()
end

compareColor = function(x, y, color, sim)
    -- color = color:sub(6,7)..color:sub(4,5)..color:sub(2,3)
    -- log(x,y,color,sim)
    -- exit()
    return cmpColor(x, y, color:sub(2), sim) == 1
end

scale = function(x, mode)
    if not mode or mode == 'min' then
        return math.round(x * minscale)
    elseif mode == 'max' then
        return math.round(x * maxscale)
    elseif type(mode) == 'number' then
        return math.round(x * mode)
    end
end

input = function(selector, text)
    if type(text) ~= 'string' then return end
    local node = findNodes(point[selector])
    if not node then return end
    for _, n in pairs(node) do nodeLib.setText(n, text) end
end
-- input = disable_game_up_check_wrapper(input)

enable_accessibility_service = function(after_killacc)
    if isAccessibilityServiceRun() then return end
    if root_mode then
        local service = package .. "/com.nx.assist.AssistService"
        local services = exec(
            "su root sh -c 'settings get secure enabled_accessibility_services'")
        log("3363", services)
        services = table.filter(services:trim():split(':'),
            function(x) return x ~= 'null' end)

        log("3365", services)
        local other_services = table.join(table.filter(services, function(x)
            return x ~= service
        end), ':')
        log("3366", other_services)
        local cmd = [[su root sh -c '
settings put secure enabled_accessibility_services ]] .. other_services ..
            (#other_services > 0 and ':' or '') .. service .. [[;
settings put secure enabled_accessibility_services ]] ..
            (#other_services > 0 and other_services or [['\'\'']]) .. [[;

settings put secure enabled_accessibility_services ]] .. other_services ..
            (#other_services > 0 and ':' or '') .. service .. [[;

' 2>&1 ]]
        local out = exec(cmd)
        log(3386, cmd)
        log(3387, out)
        if not wait(function() return isAccessibilityServiceRun() end, 2) then
            stop("无障碍服务启动失败", 'cur')
        else
            return
        end
    end
    openPermissionSetting()
    toast("请开启无障碍权限")
    if not wait(function() return isAccessibilityServiceRun() end, 60) then
        toast("开启无障碍权限超时")
        restartPackage()
    end
    toast("已开启无障碍权限")
end

enable_snapshot_service = disable_game_up_check_wrapper(function()
    if isSnapshotServiceRun() then return end
    if skip_snapshot_service_check then return end

    if root_mode then
        log("enable snapshot permission by root")
        exec([[su root sh -c '
appops set ]] .. package .. [[ PROJECT_MEDIA allow
appops set ]] .. package .. [[ SYSTEM_ALERT_WINDOW allow
']])
    end

    -- log("3444", 3444)
    -- if apk502 then
    --   import('java.lang.*')
    --   import('android.content.Context')
    --   import('com.nx.assist.lua.LuaEngine')
    --   import('com.nx.assist.lua.IReqSnapshotServiceResult')
    --   local cbReqSnapshot = IReqSnapshotServiceResult {
    --     onResult = function(ret)
    --       print(ret) -- ret是true或者false true表示成功，false失败
    --     end,
    --   }
    --   LuaEngine.requestSnapshotService(cbReqSnapshot)
    -- end

    -- log(isSnapshotServiceRun())
    -- exit()

    -- if loadConfig("hideUIOnce", "false") ~= "false" then
    --   log(2237)
    --   log("定时模式启动，不敢弹录屏")
    --   return
    -- end

    -- if wait(function() return isSnapshotServiceRun() end) then return end

    -- _toast("请开启录屏权限")
    openPermissionSetting()
    if not wait(function()
            if isSnapshotServiceRun() then return true end
            local p
            p = findOne("snap")
            if p then clickNodeFalse(p) end
            p = findOne({ text = '立即开始' })
            if p then clickNodeFalse(p) end
            ssleep(1)
        end, 60) then
        toast("开启录屏权限超时")
        restartPackage()
    end
end)

predebug_hook = function()
    if not predebug then return end
    tap_interval = -1
    findOne_interval = -1
    zl_skill_times = 100

    disable_game_up_check = true
    swip("HD-2")
    -- tap("作战列表HD-8")

    log(findOne("就这么决定了"))
    -- local p = findOne("同意协议")
    -- if p ~= nil then
    --   local left, top = p.bounds.l, p.bounds.t
    --   tap({left - scale(10), top + scale(10)})
    -- end
    findTap({ text = "下一步" })
    exit()
end

_exec = exec
check_root_mode = function()
    -- log(4040)
    if hy_exec("echo aaa"):trim() == 'aaa' then
        exec = hy_exec
        log('华云')
    end

    if not disable_root_mode and #exec("su root sh -c 'echo aaa'") > 1 then
        root_mode = true
        disableRootToast()
    end
    -- log(exec("sh -c 'echo aaa'"))
    -- log(exec("sh -c 'echo aaa'"))
    -- log(exec("su root sh -c 'echo aaa'"))
    -- log(exec("su -c 'echo aaa'"))
    -- log(exec("su -h"))
    -- log(exec("which su"))
    -- log(exec("echo $PATH"))
    -- log(exec("ls /system/xbin/su"))
    -- log(exec("/system/xbin/su -h"))
    -- log(exec("/system/xbin/su -h 2>&1"))
    -- log(exec("id"))
    log("root_mode", root_mode and 'true' or 'false')
end

parse_fight_config = function(fight_ui)
    local fight = string.filterSplit(fight_ui)
    fight = map(string.upper, fight)

    -- expand LS-5x999
    local expanded_fight = {}
    homework = {}
    for _, v in pairs(fight) do
        local cur_fight, times = v:match('(.+)[xX*](%d+)')
        if not cur_fight then
            local cur_fight, secret_code = v:match('(.+)&MAA://(%d+)')
            if secret_code then
                copy_homework = true

                if table.find({ '活动', hd_nickname, }, startsWithX(cur_fight)) then
                    local idx = cur_fight:gsub(".-(%d+)$", '%1')
                    idx = tonumber(idx) or 0
                    cur_fight = "HD-" .. (idx or '')
                    log(2731, cur_fight, idx)
                end

                homework[cur_fight] = secret_code
                table.insert(expanded_fight, cur_fight)
            else
                table.insert(expanded_fight, v)
            end
        else
            for _ = 1, times do table.insert(expanded_fight, cur_fight) end
        end
    end
    fight = expanded_fight

    -- LMSQ => 龙门市区
    expand_fight = {}
    local xk2 = table.keys(XinPian)
    for k, v in pairs(fight) do
        if table.includes(table.keys(jianpin2name), v) then
            v = jianpin2name[v]
        elseif table.includes(table.keys(extrajianpin2name), v) then
            v = extrajianpin2name[v]
        elseif table.includes(table.keys(chinese2name), v) then
            v = chinese2name[v]
        end
        if table.find({ '活动', hd_nickname, }, startsWithX(v)) then
            local idx = v:gsub(".-(%d+)$", '%1')
            idx = tonumber(idx) or 0
            v = "HD-" .. (idx or '')
            -- log(2731, v, idx)
        end

        if table.find({ 'HD-', }, startsWithX(v)) then
            local idx = v:gsub(".-(%d+)$", '%1')
            idx = tonumber(idx) or 0
            if idx > hd_max_stage and not copy_homework then
                v = "HD-" .. (hd_max_stage or '')
            end
        end

        -- 芯片
        if table.includes(xk2, v) then
            for _ = 1, 99 do
                table.extend(expand_fight, XinPian[v])
            end
        end

        -- special fight expand
        if table.includes({ 'CE', 'LS', 'AP', 'SK', 'CA' }, v) then
            for i = 6, 1, -1 do
                for _ = 1, 99 do table.insert(expand_fight, v .. '-' .. i) end
            end
        elseif table.includes({ 'PR' }, v) then
            for _ = 1, 99 do
                table.extend(expand_fight, { "PR-B-2", "PR-A-2", "PR-C-2", "PR-D-2" })
            end
            for _ = 1, 99 do
                table.extend(expand_fight, { "PR-B-1", "PR-A-1", "PR-C-1", "PR-D-1" })
            end
        elseif table.includes({ 'PR2' }, v) then
            for _ = 1, 99 do
                table.extend(expand_fight, { "PR-B-2", "PR-A-2", "PR-C-2", "PR-D-2" })
            end
        elseif table.includes({ 'PR1' }, v) then
            for _ = 1, 99 do
                table.extend(expand_fight, { "PR-B-1", "PR-A-1", "PR-C-1", "PR-D-1" })
            end
        elseif table.includes({ 'WT', 'JM' }, v) then
            for _ = 1, 99 do table.insert(expand_fight, '当期委托') end
            for _ = 1, 99 do table.insert(expand_fight, '长期委托1') end
            for _ = 1, 99 do table.insert(expand_fight, '长期委托2') end
            for _ = 1, 99 do table.insert(expand_fight, '长期委托3') end
            if not isweekday() and sss_weekend_auto then
                table.insert(expand_fight, 'BQPZ')
            end
        elseif table.includes({ "BQPZ", "BQPZ1", "BQPZ2" }, v) then
            table.insert(expand_fight, v)
        elseif table.includes({ 'HD' }, v) then
            for i = hd_max_stage, hd_max_stage - 2, -1 do
                if not table.contains(hd_exclude, { i }) then
                    for _ = 1, 99 do table.insert(expand_fight, v .. '-' .. i) end
                end
            end
            for _ = 1, 99 do table.insert(expand_fight, "HD-1") end
        elseif table.includes({ 'HD1' }, v) then
            for i = 1, hd_max_stage do table.insert(expand_fight, 'HD' .. '-' .. i) end
            table.insert(expand_fight, "BREAK")
        elseif table.includes({ 'HD2' }, v) then                --【速通输入，“hd3”“HD3”】都会插入16个关卡坐标
            for i = 1, 8 do
                table.insert(expand_fight, 'HD-EX' .. '-' .. i) --插入ex普通关卡
                -- table.insert(expand_fight, 'HD-EX' .. '-' .. i) --插入ex突袭关卡，做两次检测
            end
            table.insert(expand_fight, "BREAK")
        elseif table.includes({ 'HD3' }, v) then               --【速通输入，“hd3”“HD3”】都会插入16个关卡坐标
            for i = 1, 5 do
                table.insert(expand_fight, 'HD-S' .. '-' .. i) --插入s普通关卡
                -- table.insert(expand_fight, 'HD-S' .. '-' .. i) --插入s突袭关卡，做两次检测
            end
            table.insert(expand_fight, 'HD-MO-1') --插入MO
            table.insert(expand_fight, "BREAK")
        elseif table.includes({ '扭转醇', '轻锰矿', 'RMA70-12', '固源岩组', '固源岩', '研磨石', '全新装置',
                '装置',
                '聚酸酯组', '聚酸酯', '糖组', '糖', '异铁组', '异铁', '酮凝集组', '酮凝集', '凝胶',
                '炽合金', '晶体元件', '半自然溶剂', '化合切削液', '转质盐组' }, v) then
            if v == '扭转醇' then
                for _, i in pairs({ 'GT-5', '6-11', '11-13' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '轻锰矿' then
                for _, i in pairs({ '10-16', '3-2' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == 'RMA70-12' then
                for _, i in pairs({ '9-19', '7-10', 'R8-9', '2-10' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '固源岩组' then
                for _, i in pairs({ '10-6', '2-4' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '固源岩' then
                for _, i in pairs({ '1-7' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '研磨石' then
                for _, i in pairs({ 'HD-7', '10-12', '9-16', '5-7', '4-8', '3-3' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '全新装置' then
                for _, i in pairs({ '11-7', 'M8-8', '9-10', '7-15', '3-4' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '聚酸酯组' then
                for _, i in pairs({ '7-4', '2-6' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '聚酸酯' then
                for _, i in pairs({ 'S3-2', '1-8' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '装置' then
                for _, i in pairs({ 'S3-4', '1-12' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '糖组' then
                for _, i in pairs({ 'HD-6', '2-5' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '糖' then
                for _, i in pairs({ 'S3-1', '2-2' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '异铁组' then
                for _, i in pairs({ '10-11', '7-18', '2-8' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '异铁' then
                for _, i in pairs({ 'S3-3', '2-1' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '酮凝集组' then
                for _, i in pairs({ '10-4', 'JT8-3', '3-1' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '酮凝集' then
                for _, i in pairs({ '3-7', 'S2-1' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '凝胶' then
                for _, i in pairs({ 'R8-8', 'JT8-2', 'S4-10' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '炽合金' then
                for _, i in pairs({ 'S3-6' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '晶体元件' then
                for _, i in pairs({ 'R8-11', 'S5-9', 'S3-7' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '半自然溶剂' then
                for _, i in pairs({ '12-10', '9-18', '9-4' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '化合切削液' then
                for _, i in pairs({ '10-17', '9-6' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            elseif v == '转质盐组' then
                for _, i in pairs({ '11-3', 'S9-2' }) do
                    for _ = 1, 99 do table.insert(expand_fight, i) end
                end
            end
        else
            table.insert(expand_fight, v)
        end
    end
    fight = expand_fight
    fight = table.filter(fight, function(v) return point['作战列表' .. v] end)
    return fight
end

update_state_from_ui = function()
    bilibili_captcha_times = 0

    disable_clue_unlock = account_idx and
        table.includes(multi_account_disable_clue_unlock,
            account_idx)

    use_abyssal_hunter = account_idx and
        table.includes(multi_account_use_abyssal_hunter,
            account_idx)

    -- 总览换班就按工作状态了，保证高心情
    -- prefer_skill = true
    drug_times = 0
    max_drug_times = str2int(max_drug_times, 0)
    stone_times = 0
    max_stone_times = str2int(max_stone_times, 0)
    for i = 1, 7 do
        local k = 'drug_times_' .. i .. 'day'
        _G[k] = 0
    end

    appid = server == 0 and oppid or bppid
    job = parse_from_ui("now_job_ui", all_job)

    -- 活动开放时间段
    hd_nickname = "TA"
    hd_max_stage = 9
    hd_exclude = {}                                --排除哪些关卡不刷，例如{9}
    hd_open_time_end = parse_time("202603030400")
    hd2_open_time_end = parse_time("202507150400") -- 故事集开放时间段
    hd_mod = "SS"
    log("fight_ui", fight_ui)
    fight = parse_fight_config(fight_ui)

    -- 资源关全天开放时间段
    all_open_time_start = parse_time("202504141600")
    all_open_time_end = parse_time("202508280400")
    update_open_time()

    -- 危机合约时间段，只为加速平时的信用交易所
    during_crisis_contract = false
    local crisis_contract_start = parse_time("202211151600")
    local crisis_contract_end = parse_time("202211290400")
    local current = parse_time()
    if crisis_contract_start < current and current < crisis_contract_end then
        during_crisis_contract = true
    end

    --[[ -- 用于自定义换班，已弃用
    startup_time = parse_time()
    facility2operator = {}
    facility2nexthour = {}
    log(dorm)

    for _, v in pairs(string.split(dorm, '\n')) do
        v = string.split(v)
        if #v > 3 then
            local facility = v[1]
            if #facility == 3 then facility = facility .. 1 end
            local hour = tonumber(v[2])
            local operator = table.slice(v, 3)
            local cur_hour = facility2nexthour[facility]
            if coming_hour(cur_hour, hour, startup_time) == hour then
                facility2operator[facility] = operator
                facility2nexthour[facility] = hour
            end
        end
    end
    -- log(facility2nexthour)
    -- log(facility2operator) ]]
end

apply_multi_account_setting = function(i, visited)
    visited = visited or {}
    table.insert(visited, i)
    local txt = _G["multi_account_inherit_toggle" .. i]
    if txt == "继承设置" then
        local inherit = _G["multi_account_inherit_spinner" .. i]
        local j = math.floor(inherit) + 1
        if table.includes(visited, j) then
            transfer_global_variable("multi_account_user0")
        else
            apply_multi_account_setting(j, visited)
        end
    elseif txt == "单号设置" or txt == "默认设置" then
        transfer_global_variable("multi_account_user0")
    else
        transfer_global_variable("multi_account_user" .. i)
    end
end

crontab_next_time = function(text)
    log(1056)
    log(text)
    local config = string.filterSplit(text)
    local candidate = {}
    if #config == 0 then return 0 end
    local current = os.time()
    for _, v in pairs(config) do
        local hour_second = v:split(':')
        local hour = math.round(tonumber(hour_second[1] or 0) or 0)
        local min = math.round(tonumber(hour_second[2] or 0) or 0)
        table.insert(candidate, os.time(
            update(os.date("*t"), { hour = hour, min = min, sec = 0 })))
        table.insert(candidate, os.time(
            update(os.date("*t"), { hour = hour + 24, min = min, sec = 0 })))
    end
    log(candidate)
    table.sort(candidate)
    -- log("candidate", candidate)
    -- log("#candidate", #candidate)
    local next_time = table.findv(candidate, function(x) return x > current end)
    log(next_time)
    return next_time or 0
end

check_crontab_on_start = function()
    if not crontab_enable then return end
    if #loadConfig("crontab_next_time_on_start", "") > 0 then return end
    local next_time = crontab_next_time(crontab_text)
    -- log(4748, "next_time", next_time)
    saveConfig("crontab_next_time_on_start", str(next_time))
end

-- 定时执行逻辑：如果到点但脚本还在run则跳过
check_crontab = function()
    if not crontab_enable then return end
    saveConfig("hideUIOnce", "true")
    saveConfig("restart_mode_hook", '')
    local next_time_on_start = loadConfig("crontab_next_time_on_start", "")
    saveConfig("crontab_next_time_on_start", '')
    local next_time = crontab_next_time(crontab_text)
    log(4749, "next_time_now", next_time, "next_time_ori", next_time_on_start)
    multi_account_choice_idx = nil

    local restart = function()
        wait_game_up()
        restartPackage()
    end
    -- 有+号直接重启
    if crontab_text:find("+") then
        toast("无等待重启")
        restart()
    end
    -- 跨定时点重启
    -- log("next_time_on_start", next_time_on_start)
    -- log("next_time", next_time)
    -- exit()
    if next_time == 0 then return end
    if restart_on_crontab_timeout and str2int(next_time_on_start, next_time) ~=
        next_time then
        toast("跨定时点重启")
        restart()
    end

    toast("下次执行时间：" .. os.date("%Y-%m-%d %H:%M", next_time))
    while true do
        if os.time() >= next_time then break end
        ssleep(5)
        -- ssleep(clamp(next_time - os.time(), 0, 1000))
    end
    restart()
end

setEventCallback = function()
    setStopCallBack(function()
        disable_log = false
        log("结束")
        saveConfig("hideUIOnce", "false")
        saveConfig("restart_mode_hook", '')
        saveConfig("crontab_next_time_on_start", '')
        disableRootToast(true)
        console.show()
    end)

    setUserEventCallBack(function(type)
        disable_log = false
        log("重启", type)
        saveConfig("hideUIOnce", "false")
        saveConfig("restart_mode_hook", '')
        disableRootToast(true)
        restartScript()
    end)
end

consoleInit = function()
    console.setPos(round(screen.height * 0.05), round(screen.height * 0.05),
        round(screen.height * 0.9), round(screen.height * 0.9))
    local screen = getScreen()
    local resolution = screen.width .. 'x' .. screen.height
    local title = '明日方舟速通-' .. release_date .. ' ' .. resolution
    console.setTitle(title)
    console.show()
    console.dismiss()
end

detectServer = function()
    appid = oppid
    if prefer_bapp then appid = bppid end
    local app_info = isAppInstalled(appid)
    local bpp_info = isAppInstalled(bppid)
    if not app_info and not bpp_info then
        toast("未安装明日方舟官服或B服")
        ssleep(3)
    end
    if bpp_info and not app_info then appid = bppid end
    if bpp_info and app_info then appid_need_user_select = true end
    server = appid == oppid and 0 or 1
end

setControlBar = function()
    -- TODO: 用0,1时，会缩进去半个图标，圆角手机不好点
    -- local screen = getScreen()
    -- setControlBarPosNew(0, 1)
    setControlBarPosNew(0, 1)
end

hideControlBar = function() showControlBar(false) end

ocr = function(r, max_height)
    -- releaseCapture()
    if type(r) == 'string' then
        r = point[r]
    end
    if type(r) ~= 'table' then
        return {}
    end
    log("ocrinput", r, max_height)
    local d1 = scale(math.random(-1, 1))
    local d2 = scale(math.random(-1, 1))
    local d3 = scale(math.random(-1, 1))
    local d4 = scale(math.random(-1, 1))
    r = ocrEx(r[1] + d1, r[2] + d2, r[3] + d3, r[4] + d4) or {}

    if max_height then
        r = table.filter(r, function(x) return (x.b - x.t) <= max_height end)
    end
    log("ocroutput", r)
    return r
end

ocrex1 = function(r, white_list, max_height)
    -- releaseCapture()
    if type(r) == 'string' then
        r = point[r]
    end
    if type(r) ~= 'table' then
        return {}
    end
    log("ocrinput", r, ocr_handle)
    if white_list then
        log("本次ocr白名单:", white_list)
        setWhiteList(ocr_handle, white_list)
    end
    local d1 = scale(math.random(-1, 1))
    local d2 = scale(math.random(-1, 1))
    local d3 = scale(math.random(-1, 1))
    local d4 = scale(math.random(-1, 1))
    ret = ocrTextExJ(ocr_handle, r[1] + d1, r[2] + d2, r[3] + d3, r[4] + d4, 3, 8, 150, 255) or {}
    local res = {}
    log(ret)
    for i = 1, #ret, 1 do
        if ret[i]["conf"] > 40 then
            table.insert(res, {
                text = ret[i]["text"],
                l = r[1] + ret[i]["pos"]["l"],
                r = r[1] + ret[i]["pos"]["r"],
                t = r[2] + ret[i]["pos"]["t"],
                b = r[2] + ret[i]["pos"]["b"],
            })
        end
    end
    log("ocroutput", res)
    return res
end

ocro = function(r)
    local ret = ocrex(r)
    if ret and #ret ~= 0 then return ret[1]["text"] end
end

ocro1 = function(r)
    local ret = ocrex1(r)
    if ret and #ret ~= 0 then return ret[1]["text"] end
end

-- 集成战略
swipzl = function(mode)
    -- 两个200的时候逍遥有概率出先没点下一关情况，不知道是不是这个引起的。
    -- 加了一次滑动冗余，应该不会了，改回200
    local duration = 200
    local delay = 200 -- 后面直接ocr或点击了，给点时间吧
    local x1 = scale(300)
    local x2 = screen.width - scale(300)
    local y = scale(1080 // 2)
    local finger
    if mode == "card" then
        duration = 300
        x2 = scale(1516)
    end

    if mode == 'right' then
        finger = {
            { point = { { x1, y }, { screen.width - 1, y } }, start = 0, duration = duration },
            {
                point = { { x1, y }, { screen.width - 1, y } },
                start = duration + delay,
                duration = duration,
            },
        }
        duration = duration + delay + duration
        delay = 500
    else
        finger = {
            { point = { { x2, y }, { 0, y } }, start = 0,                duration = duration },
            { point = { { x2, y }, { 0, y } }, start = duration + delay, duration = duration },
        }
        duration = duration + delay + duration
        delay = 500
    end
    log(28491, finger)
    gesture(finger)
    log(28501)
    sleep(duration + delay)
end

-- src: 从右数第几个干员
-- dst: 目标位置，格式{A-G}{1-10} 参考https://map.ark-nights.com/map/ro1_n_1_4
-- total: 当前有几个干员，不同干员数影响干员位置
deploy3 = function(src, dst, direction, total)
    total = total or 1
    local max_op_width = scale(178) --  in loose mode, each operator's width
    local x1
    if total * max_op_width > screen.width then
        -- tight
        max_op_width = screen.width // total
        x1 = src * max_op_width - max_op_width // 2
    else
        -- loose
        x1 = screen.width - (total - src) * max_op_width - max_op_width // 2
    end

    dst = point["部署位" .. dst]
    deploy(x1, dst[1], dst[2], direction)
end

always_request_appid = {}
request_game_permission = function()
    log(2943)
    if not root_mode then return end
    if always_request_appid[appid] then return end
    always_request_appid[appid] = 1
    local aapt = [[android.permission.ACCESS_WIFI_STATE
android.permission.READ_PHONE_STATE
android.permission.ACCESS_NETWORK_STATE
android.permission.INTERNET
android.permission.WRITE_EXTERNAL_STORAGE]]
    local cmd = ''
    for s in aapt:gmatch("[^\r\n]+") do
        cmd = cmd .. 'pm grant ' .. appid .. ' ' .. s .. ';'
    end
    log(cmd)
    exec("su root sh -c '" .. cmd .. "'")
    log(2944)
end

str2int = function(number, fallback)
    if type(number) == 'number' then return math.floor(number) end
    return math.floor(tonumber(string.trim(number)) or fallback)
end

-- string annotation to list
expand_number_config = function(x)
    local y = {}
    x = string.filterSplit(x)
    for _, v in pairs(x) do
        if v:find('-') then
            local s = str2int(v:sub(1, v:find('-') - 1), -1)
            local e = str2int(v:sub(v:find('-') + 1), -1)
            local d = e < s and -1 or 1
            if s > 0 and e > 0 then for i = s, e, d do table.insert(y, i) end end
        else
            table.insert(y, str2int(v, 0))
        end
    end
    return y
end

equal_number_config = function(a, b)
    a = expand_number_config(a)
    b = expand_number_config(b)
    return table.equal(a, b)
end

-- {1,2,3,6,9,8} => '1-3 6 9-8'
shrink_number_config = function(x)
    local ans = ''
    x = x:split(' ')
    for i, _ in pairs(x) do x[i] = str2int(x[i], -1) end
    local i = 1
    while i <= #x do
        local j = i + 1
        while j <= #x and x[j] - x[j - 1] == 1 do j = j + 1 end
        if j == i + 1 then
            while j <= #x and x[j] - x[j - 1] == -1 do j = j + 1 end
        end
        if j == i + 1 then
            ans = ans .. x[i] .. ' '
        else
            ans = ans .. x[i] .. '-' .. x[j - 1] .. ' '
        end
        i = j
    end
    return ans
end

-- {1-7 1-7 1-7 CE-6} => '1-7x3 CE-6'
shrink_fight_config = function(x)
    local ans = ''
    local i = 1

    while i <= #x do
        local j = i + 1
        while j <= #x and x[j] == x[j - 1] do j = j + 1 end
        if j == i + 1 then
            ans = ans .. x[i] .. ' '
        else
            ans = ans .. x[i] .. 'x' .. (j - i) .. ' '
        end
        i = j
    end

    return ans
end

restart_game_check_last_time = nil
restart_game_check = function(timeout)
    timeout = timeout or 3600
    log(3145, timeout)
    restart_game_check_last_time = restart_game_check_last_time or time()
    if (time() - restart_game_check_last_time) > timeout * 1000 then
        restart_game_check_last_time = time()
        restartapp(appid)
        return true
    end
end

forever = function(f, ...) while true do f(...) end end

make_extra_mode_hook = function(mode, multi)
    if not mode then return '' end
    local hook = [[;
extra_mode=]] .. string.format('%q', str(mode)) .. [[;
extra_mode_multi=]] .. str(multi and true or false) .. [[;
zl_no_waste_last_time=]] .. str(zl_no_waste_last_time)
    return hook
end

make_drug_stone_times_hook = function()
    if not max_stone_times or not stone_times then return '' end
    local stone_remain_times = max_stone_times - stone_times
    local drug_remain_times = max_drug_times - drug_times
    local idx = account_idx
    local hook = ''
    if not idx then
        hook = [[;
max_stone_times=]] .. stone_remain_times .. [[;
max_drug_times=]] .. drug_remain_times .. [[;
]]
    else
        hook = [[;
multi_account_user]] .. idx .. [[max_stone_times=]] .. stone_remain_times .. [[;
multi_account_user]] .. idx .. [[max_drug_times=]] .. drug_remain_times .. [[;
]]
    end
    return hook
end

make_multi_account_choice_hook = function(skip_current)
    if not multi_account_choice_idx or not account_idx then return '' end
    local choice_idx = multi_account_choice_idx
    local choice = multi_account_choice
    -- 跳过当前账号
    if skip_current then
        while choice[choice_idx] == account_idx do choice_idx = choice_idx + 1 end
    end
    -- 截取后续账号
    choice = table.slice(choice, choice_idx)
    return ";multi_account_choice=" ..
        string.format('%q', table.join(choice, ' '))
end

save_run_state = function(skip_current)
    local hook_prefix = ";-- save_run_state_begin;"
    local hook_suffix = ";-- save_run_state_end;"
    local hook = ''

    hook = hook .. make_extra_mode_hook(extra_mode, extra_mode_multi)
    hook = hook .. make_drug_stone_times_hook()
    hook = hook .. make_multi_account_choice_hook(skip_current)

    hook = hook_prefix .. hook .. hook_suffix

    local pre_hook = loadConfig('restart_mode_hook', '')
    pre_hook = pre_hook:gsub(hook_prefix:quote() .. ".*" .. hook_suffix:quote(),
        '')
    hook = pre_hook .. hook
    saveConfig("restart_mode_hook", hook)
    saveConfig("hideUIOnce", "true")
end

restart_account = function(skip_current)
    -- 单帐号等待
    if not account_idx and skip_current then
        toast("等待1小时")
        wait(function() ssleep(1) end, 3600)
    end
    -- 无障碍/录屏服务启动失败时，在这里释放hook
    if not restart_mode_hook_applied then restart_mode_hook() end

    save_run_state(skip_current)

    -- local f = loadConfig("restart_mode_hook", '')

    restartPackage()
end

restart_mode_hook = function()
    -- load(loadConfig("restart_mode_hook", ''))()
    -- saveConfig("restart_mode_hook", '')
    local f = loadConfig("restart_mode_hook", '')

    saveConfig("restart_mode_hook", '')
    load(f)()
    restart_mode_hook_applied = true
end

check_login_frequency = function()
    login_times = (login_times or 0) + 1

    if login_times > 1 then
        -- captureqqimagedeliver(table.join(qqmessage, ' ') .. ' ' .. "登录次数" ..
        --                         login_times ..
        --                         (is_network_unstable() and
        --                           ",闪断时间段等15分钟" or ''))
        if is_network_unstable() then
            toast("闪断时间段等15分钟")
            wait(function() ssleep(1) end, 900)
            login_times = login_times - 1
            return
        end
    end

    if login_times >= max_login_times then
        stop("登录次数达到" .. login_times, 'next')
    end

    table.insert(login_time_history, time())
    log("login_time_history", login_time_history)
    if max_login_times_5min > 0 and #login_time_history >= max_login_times_5min and
        login_time_history[#login_time_history] -
        login_time_history[#login_time_history - max_login_times_5min + 1] < 15 * 60 *
        1000 then
        stop("15分钟内登录次数达到" .. max_login_times_5min, 'next')
    end
end

killacc = function()
    exit()
    -- collectgarbage("collect")
    if not root_mode then return end
    if disable_killacc1 then return end
    -- if enable_killacc2 then return killacc2() end
    --   if 1 then return 1 end
    --
    --   local service = package .. "/com.nx.assist.AssistService"
    --   local services = exec(
    --                      "su root sh -c 'settings get secure enabled_accessibility_services'")
    --   log("3363", services)
    --   services = table.filter(services:trim():split(':'),
    --                           function(x) return x ~= 'null' end)
    --
    --   log("3365", services)
    --   local other_services = table.join(table.filter(services, function(x)
    --     return x ~= service
    --   end), ':')
    --   log("3366", other_services)
    --   local cmd = [[su root sh -c '
    -- pid=$(pidof ]] .. package .. [[:acc)
    -- settings put global heads_up_notifications_enabled 0
    -- # 开
    -- settings put secure enabled_accessibility_services ]] .. other_services ..
    --                 (#other_services > 0 and ':' or '') .. service .. [[;
    -- # 关
    -- settings put secure enabled_accessibility_services ]] ..
    --                 (#other_services > 0 and other_services or [['\'\'']]) .. [[;
    -- kill $pid
    -- sleep 1
    -- # 开
    -- settings put secure enabled_accessibility_services ]] .. other_services ..
    --                 (#other_services > 0 and ':' or '') .. service .. [[;
    -- # 关
    -- settings put secure enabled_accessibility_services ]] ..
    --                 (#other_services > 0 and other_services or [['\'\'']]) .. [[;
    -- # 开
    -- settings put secure enabled_accessibility_services ]] .. other_services ..
    --                 (#other_services > 0 and ':' or '') .. service .. [[;
    -- ' 2>&1 ]]
    open(package)
    appear({ package = package }, 5)
    ssleep(1)

    local cmd = [[nohup su root sh -c ' \
# settings put global heads_up_notifications_enabled 0
kill $(pidof ]] .. package .. [[:acc)
secs=2
endTime=$(( $(date +%s) + secs ))
while [ $(date +%s) -lt $endTime ]; do
  pidof ]] .. package .. [[:acc && continue
  break
done
secs=2
endTime=$(( $(date +%s) + secs ))
while [ $(date +%s) -lt $endTime ]; do
  pidof ]] .. package .. [[:acc && break
done
echo -1000 > /proc/$(pidof ]] .. package .. [[:acc)/oom_score_adj

' > /dev/null & ]]

    log(5031)
    exec(cmd)
    -- log(4661, isAccessibilityServiceRun())
    -- log(4662, exec(cmd), isAccessibilityServiceRun())
    wait(function() return not isAccessibilityServiceRun() end, 2)
    if not wait(function() return isAccessibilityServiceRun() end, 2) then
        enable_accessibility_service(true)
        -- stop("无障碍服务启动失败，可以勾选禁用重启acc", false)
    end
    log(5038)
    -- log(5038)
    -- ssleep(100)
    -- exit()
    -- enable_accessibility_service()
    -- log("cmd", cmd)
    -- if #exec(cmd):trim() == 0 then
    -- stop(
    --   "acc进程重启失败，华云必须按必读操作，其他请反馈。可在高级设置中暂时关闭，但会引入内存泄漏无法长时间运行。",
    --   false)
    -- end
    -- log(1)
    -- exit()

    -- home()
    -- tap({screen.width + 1, screen.width + 1}, true, true)
    ssleep(1)
    home()
    wait_game_up()

    -- exit()

    --   cmd = [[nohup su root sh -c ' \
    -- sleep 10
    -- settings put global heads_up_notifications_enabled 1
    -- ' > /dev/null & ]]
    --   exec(cmd)
end

restartPackage = function()
    -- log("restart_mode_hook", loadConfig("restart_mode_hook", ''))
    -- log("hideUIOnce", loadConfig("hideUIOnce", ''))
    if loadConfig("Not_Restart", "") == "true" then
        exit()
    end

    if getApkVerInt() == 1 then
        disable_restart_package = true
        log("debug")
    end
    if not root_mode or disable_restart_package then return restartScript() end
    local cmd = [[nohup su root sh -c ' \
while :; do
am force-stop ]] .. oppid .. [[;
am force-stop ]] .. bppid .. [[;
am force-stop ]] .. package .. [=[;
sleep 1
input keyevent KEYCODE_HOME
sleep 1
secs=300
endTime=$(( $(date +%s) + secs ))
while [[ $(date +%s) -lt $endTime ]]; do
  monkey -p ]=] .. package .. [=[ -c android.intent.category.LAUNCHER 1
  foreground=$(dumpsys activity recents|sed -rn '\''s/.*Recent #0.*(com[^ ]+).*/\1/p'\'')
  if [[ $foreground == *com.bilabila* ]];then
     break
  fi
  sleep 5
done
secs=300
endTime=$(( $(date +%s) + secs ))
ok_found=0
while [[ $(date +%s) -lt $endTime ]]; do
  sleep 5
  foreground=$(dumpsys activity recents|sed -rn '\''s/.*Recent #0.*(com[^ ]+).*/\1/p'\'')

  if [[ ! $foreground == *com.bilabila* ]] && [[ $ok_found == 1 ]] ;then
     exit
  fi

  if [[ ! $foreground == *com.bilabila* ]];then
     continue
  fi

  uiautomator dump /sdcard/window_dump.xml

  cancel=$(sed -rn '\''s|.*text=.取消.[^>]*bilabila[^>]*bounds=.\[([0-9]*),([0-9]*)\]\[([0-9]*),([0-9]*)\]..*|input tap $(((\1+\3)/2)) $(((\2+\4)/2))|p'\'' /sdcard/window_dump.xml)
  ok=$(sed -rn '\''s|.*text=.确定.[^>]*bilabila[^>]*bounds=.\[([0-9]*),([0-9]*)\]\[([0-9]*),([0-9]*)\]..*|input tap $(((\1+\3)/2)) $(((\2+\4)/2))|p'\'' /sdcard/window_dump.xml)
  close=$(sed -rn '\''s|.*text=.关闭.[^>]*bilabila[^>]*bounds=.\[([0-9]*),([0-9]*)\]\[([0-9]*),([0-9]*)\]..*|input tap $(((\1+\3)/2)) $(((\2+\4)/2))|p'\'' /sdcard/window_dump.xml)
  if [[ -n $close ]]; then
    eval $close
  fi

  if [[ -n $cancel ]]; then
    eval $cancel
    continue
  elif [[ -n $ok ]]; then
    sleep 1
    eval $ok
    ok_found=1
    continue
  fi

  #start=$(sed -rn '\''s|.*text=.立即开始.[^>]*bilabila[^>]*bounds=.\[([0-9]*),([0-9]*)\]\[([0-9]*),([0-9]*)\]..*|input tap $(((\1+\3)/2)) $(((\2+\4)/2))|p'\'' /sdcard/window_dump.xml)
  #if [[ -n $start ]]; then
  #  eval $start
  #  continue
  #fi

  # snap=$(sed -rn '\''s|.*com.bilabila.arknightsspeedrun2:id/switch_snap.[^>]*bilabila[^>]*bounds=.\[([0-9]*),([0-9]*)\]\[([0-9]*),([0-9]*)\]..*|input tap $(((\1+\3)/2)) $(((\2+\4)/2))|p'\'' /sdcard/window_dump.xml)
  # if [[ -n $snap ]]; then
  #   eval $snap
  #   continue
  # fi
done
done
' > /dev/null & ]=]

    exec(cmd)
    ssleep(60)
    restartScript()
end

oom_score_adj = function()
    if not root_mode then return end
    if disable_oom_score_adj then return end
    -- if disable_oom_score_adj then return end
    -- if not enable_oom_score_adj then return end
    -- log("4032")

    -- local f = function(package)
    --     local cmd = [[nohup su root sh -c ' \
    -- while :; do
    --   package=]] .. package .. [[
    --   pid=$(pidof $package)
    --   [ -z $pid ] && exit
    --   echo -1000 > /proc/$pid/oom_score_adj
    --   strace -e trace=none -e signal=none -p $pid
    --   sleep 0.1
    -- done
    local cmd = [[nohup su root sh -c ' \
echo -1000 > /proc/$(pidof ]] .. package .. [[:remote)/oom_score_adj
echo -1000 > /proc/$(pidof ]] .. package .. [[)/oom_score_adj
echo -1000 > /proc/$(pidof ]] .. package .. [[:acc)/oom_score_adj
echo -1000 > /proc/$(pidof ]] .. [[nc)/oom_score_adj
' > /dev/null & ]]

    exec(cmd)

    -- cmd = 'nohup sleep 50 > /dev/null &'
    -- log(exec(cmd))
    -- while true do log(exec(cmd)) end
    -- end
    -- f(package .. ':acc')
    -- f(package .. ':remote')
    -- f(package .. '')
    -- keepalive_thread[1] = beginThread(f, package .. ':acc')
    -- keepalive_thread[2] = beginThread(f, package .. ':remote')
    -- keepalive_thread[3] = beginThread(f, package .. '')
    -- log("keepalive", keepalive_thread)

    -- local getCmd = function(package, score)
    --
    --   score = score or "-1000"
    --   return "echo " .. score .. " > /proc/$(pidof " .. package ..
    --            ")/oom_score_adj"
    -- end
    -- local get = function(package)
    --   return (exec("su root sh -c 'cat /proc/$(pidof " .. package ..
    --                  ")/oom_score_adj'") or ''):trim()
    -- end
    -- local package = getPackageName()
    -- local cmd = table.join({
    --   getCmd(package), getCmd(package .. ":acc"), getCmd(package .. ":remote"),
    -- }, ';')
    -- log(cmd)
    -- exec("su root sh -c '" .. cmd .. "'")
    -- exec("su root sh -c '" .. "sleep 1000" .. "'")
    -- log(4040)
    -- exit()
    -- log("oom_score_adj:" .. get(package) .. get(package .. ":acc") ..
    --       get(package .. ":remote"))
end

-- disable_lmk = function()
--     if not root_mode then return end
--     if not enable_disable_lmk then return end
--     local cmd = [[nohup su root sh -c ' \
-- echo 1,2,3,4,5,6 > /sys/module/lowmemorykiller/parameters/minfree
-- ' > /dev/null & ]]
--     exec(cmd)
-- end

-- solveCapture = function()
--     log("solve")

--     ssleep(1)
--     keepCapture()
--     local node = findOne("captcha")
--     if not node then
--         log('3576 not found captcha')
--         return
--     end
--     local left, top = node.bounds.l, node.bounds.t
--     point.captcha_area = {
--         left + scale(240), top + scale(40), left + scale(789), top + scale(481),
--     }
--     point.captcha_left_area = {
--         left + scale(105), top + scale(40), left + scale(196), top + scale(481),
--     }
--     point.captcha_area_btn = { left + scale(114), top + scale(609) }

--     local w, h, color
--     local i, j, b, g, r
--     local best, best_score, best_left, best_right
--     local data
--     local maxgrad
--     local diff1, diff2, y1, y2, y3
--     w, h, color = getScreenPixel(table.unpack(point.captcha_area))
--     data = {}
--     for i = 1, #color do
--         b, g, r = colorToRGB(color[i])
--         table.extend(data, { r, g, b })
--     end

--     maxgrad = {}
--     for i = w + 1, #color do
--         y1 = (0.299 * data[i * 3 - 2] + 0.587 * data[i * 3 - 1] + 0.114 *
--             data[i * 3])
--         y2 =
--             (0.299 * data[(i - 2) * 3 - 2] + 0.587 * data[(i - 2) * 3 - 1] + 0.114 *
--                 data[(i - 2) * 3])
--         y3 =
--             (0.299 * data[(i - w) * 3 - 2] + 0.587 * data[(i - w) * 3 - 1] + 0.114 *
--                 data[(i - w) * 3])
--         diff1 = y1 - y2
--         diff2 = y1 - y3
--         maxgrad[i % w] = (maxgrad[i % w] or 0) + max(0, diff1) /
--             (1 + math.abs(diff2))
--     end

--     -- local best = {}
--     -- for i = 4, #maxgrad do
--     --   table.insert(best, {maxgrad[i], i + point.captcha_area[1]})
--     -- end
--     -- table.sort(best, function(a, b) return a[1] > b[1] end)
--     -- log(table.slice(best, 1, 10))
--     -- log(point.captcha_area)
--     -- exit()

--     best = 1
--     best_score = 0
--     for i = 4, #maxgrad do
--         if best_score < maxgrad[i] then
--             best_score = maxgrad[i]
--             best = i
--         end
--     end

--     best_right = best + point.captcha_area[1]

--     w, h, color = getScreenPixel(table.unpack(point.captcha_left_area))
--     data = {}
--     for i = 1, #color do
--         b, g, r = colorToRGB(color[i])
--         table.extend(data, { r, g, b })
--     end
--     maxgrad = {}
--     for i = w + 1, #color do
--         y1 = (0.299 * data[i * 3 - 2] + 0.587 * data[i * 3 - 1] + 0.114 *
--             data[i * 3])
--         y2 =
--             (0.299 * data[(i - 2) * 3 - 2] + 0.587 * data[(i - 2) * 3 - 1] + 0.114 *
--                 data[(i - 2) * 3])
--         y3 =
--             (0.299 * data[(i - w) * 3 - 2] + 0.587 * data[(i - w) * 3 - 1] + 0.114 *
--                 data[(i - w) * 3])
--         diff1 = y1 - y2
--         diff2 = y1 - y3
--         maxgrad[i % w] = (maxgrad[i % w] or 0) + max(0, -diff1) /
--             (1 + math.abs(diff2))
--     end

--     -- local best = {}
--     -- for i = 4, #maxgrad do
--     --   table.insert(best, {maxgrad[i], i + point.captcha_area[1]})
--     -- end
--     -- table.sort(best, function(a, b) return a[1] > b[1] end)
--     -- log(table.slice(best,1,10))
--     -- exit()

--     best = 1
--     best_score = 0
--     for i = 4, #maxgrad do
--         if best_score < maxgrad[i] then
--             best_score = maxgrad[i]
--             best = i
--         end
--     end

--     best_left = best + point.captcha_left_area[1]
--     log(3399, best_left, best_right)
--     -- exit()

--     -- log(table.slice(best, 1, 10))
--     -- exit()
--     -- log(w, h, best, best_score, best + point.captcha_area[1])

--     -- for i = 1, #maxgrad do log(i, maxgrad[i]) end
--     -- log(point.captcha_area)
--     --
--     local distance = best_right - best_left
--     local sx, sy
--     sx = point.captcha_area_btn[1]
--     sy = point.captcha_area_btn[2]
--     local duration = 500
--     local finger = {
--         point = {
--             { sx,                        sy }, { sx + distance, sy },
--             { sx + distance + scale(10), sy - scale(100) },
--             { sx + distance + scale(10), sy },
--             { sx + distance + scale(10), sy - scale(100) },
--             { sx + distance + scale(10), sy },
--             { sx + distance - scale(10), sy - scale(100) },
--             { sx + distance - scale(10), sy },
--             { sx + distance - scale(10), sy - scale(100) },
--             { sx + distance - scale(10), sy }, { sx + distance, sy - scale(100) },
--             { sx + distance, sy }, { sx + distance, sy - scale(100) },
--             { sx + distance, sy }, { sx + distance, sy - scale(100) },
--             { sx + distance, sy },
--         },
--         duration = duration,
--     }
--     log(finger.point[1], finger.point[#finger.point])
--     gesture(finger)
--     sleep(duration + 50)

--     releaseCapture()
-- end

chineseUnicodeStringMatch = function(a, b)
    local len = min(#a, #b) // 3
    local score = 0
    for i = 1, len do
        if a:sub(i * 3 - 2, i * 3) == b:sub(i * 3 - 2, i * 3) then
            score = score + 1
        end
    end
    return score
end

disableRootToast = function(reenable)
    -- toast会影响识别
    local cmd = [[nohup su root sh -c ' \
root_manager=$(pm list packages|grep -e .superuser -e .supersu -e .magisk | head -n1|cut -d: -f2)
root_manager=${root_manager:-com.android.settings}
appops set $root_manager TOAST_WINDOW ]] .. (reenable and "allow" or "deny") ..
        [[;
settings put global heads_up_notifications_enabled ]] .. (reenable and 1 or 0) ..
        [[;
' > /dev/null & ]]
    -- log(5208,cmd)
    exec(cmd)
    -- ssleep(1000)
end

hd_wrapper = function(func)
    local f = function(...)
        swipu_flipy = scale(100)
        local keys = {}
        local point_store = {}
        local rfl_store = {}
        local first_point_store = {}

        for _, k in pairs(keys) do
            point_store[k] = point[k]
            rfl_store[k] = rfl[k]
            first_point_store[k] = first_point[k]
            point[k] = point[k .. "活动"]
            rfl[k] = rfl[k .. "活动"]
            first_point[k] = first_point[k .. "活动"]
        end

        local ret = func(...)

        for _, k in pairs(keys) do
            point[k] = point_store[k]
            rfl[k] = rfl_store[k]
            first_point[k] = first_point_store[k]
        end
        swipu_flipy = 0

        return ret
    end
    return f
end

-- 调试界面 某些功能的默认值
update_state_from_debugui = function()
    write_log_local = (write_log_local == nil) and true or write_log_local
    enable_log = (enable_log == nil) and true or enable_log
    multi_account_disable_clue_unlock = expand_number_config(
        multi_account_disable_clue_unlock or '')
    multi_account_use_abyssal_hunter = expand_number_config(
        multi_account_use_abyssal_hunter or '')

    training_check_time = str2int(training_check_time, 1.5)
    if multiple_proxy_commander == nil then multiple_proxy_commander = true end
    max_use_number_drug = str2int(max_use_number_drug, 3)
    max_jmfight_times = str2int(max_jmfight_times, 1)
    findOne_interval = str2int(findOne_interval, -1)
    max_fight_times = str2int(max_fight_times, math.huge)
    tap_interval = str2int(tap_interval, -1)
    zl_skill_times = str2int(zl_skill_times, 0)
    zl_skill_idx = str2int(zl_skill_idx, 1)
    tapall_duration = str2int(tapall_duration, -1)
    max_login_times = str2int(max_login_times, math.huge)
    max_login_times_5min = str2int(max_login_times_5min, 5)
    milesecond_after_click = str2int(tap_wait, milesecond_after_click)
    max_log_time = str2int(max_log_time, 15)
    max_log_count = str2int(max_log_count, 1000)
    --bili_captcha_mode = str2int(bili_captcha_mode, 1)

    --验证码
    use_free_server_captcha = (use_free_server_captcha == nil) and true or use_free_server_captcha
    use_captcha_aunly_slip = (use_captcha_aunly_slip == nil) and true or use_captcha_aunly_slip
    use_captcha = (use_captcha == nil) and true or use_captcha
    use_captcha_aunly = (use_captcha_aunly == nil) and true or use_captcha_aunly


    catch_run_crash = (catch_run_crash == nil) and true or catch_run_crash

    if not (always_enable_log or enable_log) then run = disable_log_wrapper(run) end
    QQ = (QQ or ''):commonmap():trim()
    if QQ:find('#') then
        devicenote = QQ:sub(QQ:find('#') + 1, #QQ):trim()
        QQ = QQ:sub(1, QQ:find('#') - 1):trim()
        if QQ:find(' ') then
            QQ = QQ:split(' ')
            QQ, QQ2 = QQ[1], QQ[2]
        end
    end
    qqimagedeliver = (qqimagedeliver or ''):trim()
    pushplus_token = (pushplus_token or ''):trim()
    notify_sub_expire = (notify_sub_expire == nil) and true or notify_sub_expire
    for i = 1, 7 do
        local k = 'max_drug_times_' .. i .. 'day'
        _G[k] = str2int(_G[k], 0)
    end
    shift_min_mood = str2int(shift_min_mood, 12)
    manu_shift_short_circuit_threshold = tonumber(manu_shift_short_circuit_threshold) or 0.38
    if shift_min_mood <= 0 or shift_min_mood >= 24 then shift_min_mood = 12 end
    if enable_native_tap then clickPoint = _tap end
    max_fight_failed_times = str2int(max_fight_failed_times, 2)
    cloud.setDeviceToken(cloud_device_token)
    cloud.setServer(cloud_server)
    cloud.setCaptcha(cloud_captcha_server, cloud_captcha_token)
    cloud.setStatus(extra_mode == "战略前瞻投资" and 1002 or extra_mode == "生息沙洲遗闻wrapper" and 1003 or 1001)
    -- enable_restart_package = not disable_restart_package

    restart_game_interval = str2int(restart_game_interval, 900)
    restart_package_interval = str2int(restart_package_interval, 3600)

    if restart_on_crontab_timeout == nil then restart_on_crontab_timeout = true end
    auto_update_game_select = str2int(auto_update_game_select, 0)

    sss_weekend_auto = (sss_weekend_auto == nil) and true or sss_weekend_auto
    sss_only_complete = (sss_only_complete == nil) and true or sss_only_complete

    if paddleocr_loadfailed or disable_paddleocr then
        log("PaddleOCR不可用，使用默认OCR")
        ocrex = ocr
    end
end

hy_exec = function(x)
    return _exec('echo "' .. x:gsub('%$', '\\$') .. '"|nc localhost 49876')
end

-- path_name_escape = function(x)
--     return x:map({
--         ['/'] = '_',
--         ["'"] = '_',
--         ['"'] = '_',
--         ['$'] = '_',
--         ['\\'] = '_',
--     })
-- end

number_ocr_correct = function(x)
    return x:map({
        ['〇'] = '0',
        ['C'] = '0',
        [','] = '',
        ['.'] = '',
        [' '] = '',
        ["O"] = '0',
        ["Q"] = '0',
        ["o"] = '0',
        ["|"] = '1',
        ["z"] = '2',
        ["Z"] = '2',
        ['s'] = '5',
        ['S'] = '5',
        -- ['e'] = '8',
        -- ['B'] = '8',
    }):trim()
end

isweekday = function()
    local cur_time = tonumber(os.date("%w", os.time()))
    if cur_time == 0 then cur_time = 7 end
    if cur_time < 6 then return true end
end

is_network_unstable = function()
    local cur_time = parse_time()
    local s, e
    s = os.time(update(os.date("*t"), { hour = 4, min = 0 }))
    e = os.time(update(os.date("*t"), { hour = 4, min = 15 }))
    if s < cur_time and cur_time < e then return true end
    s = os.time(update(os.date("*t"), { hour = 16, min = 0 }))
    e = os.time(update(os.date("*t"), { hour = 16, min = 15 }))
    if s < cur_time and cur_time < e then return true end
end

restart_package_last_time = time()
request_memory_clean = function()
    log("request_memory_clean")
    if (time() - restart_package_last_time > restart_package_interval * 1000) then
        qqnotify_before_restart_package()
        restart_account(false)
        return true
    end

    if (time() - kill_game_last_time[appid] > restart_game_interval * 1000) then
        restartapp(appid)
        return true
    end
end

remove_old_log = function()
    -- 一周前的文件
    exec("find /sdcard/" .. package .. '/ -cmin +720 -type f -delete')
end

clear_hook = function()
    local config = loadOneUIConfig("debug")
    config["before_account_hook"] = '-- before_account_hook'
    config["after_require_hook"] = '-- after_require_hook'
    config["after_all_hook"] = '-- after_all_hook'
    saveOneUIConfig("debug", config)
end

strOr = function(x, y)
    if type(x) == 'string' and #x:trim() > 0 then return x end
    return y or ''
end
str = tostring
int = tonumber

get = function(Obj, Field, ...)
    if Obj == nil or Field == nil or type(Obj) ~= 'table' then
        return Obj
    else
        return get(Obj[Field], ...)
    end
end

istable = function(x) return type(x) == 'table' end

last_upload_img = ''

uploadImg = function(img)
    -- https://www.imgtp.com/index/api.html
    local ret = uploadFile("https://www.imgtp.com/api/upload", img, 30)
    -- log('uploadImg', ret)
    local status
    status, ret = pcall(JsonDecode, ret)
    log("ret", ret)
    ret = get(ret, 'data', 'url')
    ret = strOr(ret)
    -- last_upload_img = ret
    return ret
end

force_width = str2int(force_width, 0)
force_height = str2int(force_height, 0)

isPhoneNumber = function(str)
    local str = str:gsub("%D", "")
    if #str == 11 then
        return true
    else
        return false
    end
end

-- 以字符串格式找色
findOneStr = function(x, confidence)
    -- 每5秒确认游戏在前台
    -- if (time() - findOne_game_up_check_last_time > 5000) then
    --     findOne_game_up_check_last_time = time()
    --     wait_game_up()
    -- end

    confidence = confidence or default_findcolor_confidence

    if type(x) == "string" then
        -- 控制截图频率
        local current = time()
        if findOne_interval > 0 and current - findOne_last_time > findOne_interval then
            findOne_last_time = time()
            keepCapture()
        end

        local pos

        if cmpColorEx(x, confidence) == 1 then
            pos = { str2int(x:match("^(%d+)|"), 0), str2int(x:match("^%d+|(%d+)|"), 0) }
        end

        return pos
    end
end

-- 单点找色
checkPointColor = function(pInfo, confidence)
    -- 每5秒确认游戏在前台
    -- if (time() - findOne_game_up_check_last_time > 5000) then
    --     findOne_game_up_check_last_time = time()
    --     wait_game_up()
    -- end

    confidence = confidence or default_findcolor_confidence

    -- 控制截图频率
    local current = time()
    if findOne_interval > 0 and current - findOne_last_time > findOne_interval then
        findOne_last_time = time()
        keepCapture()
    end

    if type(pInfo) == "table" then
        colorStr = pInfo[1] .. "|" .. pInfo[2] .. "|" .. pInfo[3]
    elseif type(pInfo) == "string" then
        colorStr = pInfo
    end

    -- 比色
    if cmpColorEx(colorStr, confidence) == 1 then
        return true
    else
        return false
    end
end

-- 等待单点颜色出现
waitUntilFindColor = function(pInfo, time)
    local time = time or 5
    return wait(function()
        if checkPointColor(pInfo) then
            return true
        end
    end, time)
end

-- 持续点击直到找到指定颜色
tapUntilCheckedPointColor = function(pTap, pInfo, msg, sleep, time)
    log(msg)
    local sleep = sleep or 0
    local time = time or 5
    if wait(function()
            if checkPointColor(pInfo) then
                log(msg, "成功")
                return true
            end
            tap({ pTap[1], pTap[2] })
            ssleep(sleep)
        end, time) then
        return true
    else
        log("持续点击直到找到指定颜色失败")
        return false
    end
end

doIfCheckedColor = function(pInfo, func, time)
    time = time or 15
    if checkPointColor(pInfo) then
        wait(function()
            return func()
        end, time)
    end
end

tapIfCheckedColor = function(pTap, pInfo)
    doIfCheckedColor(pInfo,
        function()
            tap({ pTap[1], pTap[2] })
            return true
        end)
end

-- 新deploy3 原deploy3有计算bug
-- src: 从右数第几个干员
-- dst: 目标位置，格式{x,y,direction} direction: 上1 右2 下3 左4
-- total: 当前有几个干员，不同干员数影响干员位置
nDeploy3 = function(src, dst, total)
    total = total or 1
    local max_op_width = scale(178) --  in loose mode, each operator's width
    local x1
    if total * max_op_width > screen.width then
        -- tight
        max_op_width = screen.width // total
        x1 = src * max_op_width - max_op_width // 2
    else
        -- loose
        -- x1 = screen.width - (total - src) * max_op_width - max_op_width // 2
        x1 = screen.width - src * max_op_width + max_op_width // 2
    end
    deploy(x1, dst[1], dst[2], dst[3])
end

-- 使用root权限判断文件夹是否存在
folder_exists = function(folderpath)
    local ret = exec2(string.format([[su root sh -c 'if [ -d "%s" ]; then echo "true"; else echo "false"; fi']],
        folderpath))
    if string.find(ret, "true") then
        return true
    else
        return false
    end
end

find_color = function(v, color, dir, condifence)
    local color = color or "000000"
    if v == nil then v = { 0, 0, 0, 0 } end
    if v == true then return true end
    if type(v) == "function" then return v() end
    if type(v) == "string" and not v:find(coord_delimeter) then v = point[v] end
    if type(v) == "string" and v:find(coord_delimeter) then return nil end
    if #v ~= 4 then return nil end
    local dir = dir or 1
    -- 0: 表示从左上向右下；
    -- 1: 表示从中心往四周查找；
    -- 2: 表示从右下向左上查找；
    -- 3: 表示从左下向右上查找；
    -- 4：表示从右上向左下查找
    local condifence = condifence or default_findcolor_confidence
    -- log("find_color", v, color, dir, condifence)
    local index, x, y = findColor(v[1], v[2], v[3], v[4], color, dir, condifence)
    -- log("find_color", v, index, x, y)
    if x > -1 and y > -1 then
        return { x, y }
    else
        return nil
    end
end

get_cpu_arch = function()
    return (exec("getprop ro.product.cpu.abi")):map({
        ["\n"] = "",
        [" "] = "",
        ["　"] = "",
    })
end


hd_test_mode = function()
    for i = 1, 11 do
        log("测试第" .. i .. "关")
        swip("HD-" .. i)
        tap("作战列表HD-" .. i)
        ssleep(1)
        back()
        ssleep(1.5)
    end
end
