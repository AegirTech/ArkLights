local TURING = {}
local ImgData = {}
local IncData = {}
local LibData = {}
local BakData0 = {}
local BakData1 = {}
local BakData2 = {}
local BakData3 = {}
local BakData4 = {}
local BakData5 = {}
local BakData6 = {}
local BakData7 = {}
local BakData8 = {}
local BakData9 = {}
local Color_B = 255
local Color_G = 255
local Color_R = 255
local R_Left = 0
local R_Top = 0
local R_Right = 0
local R_Bottom = 0
local R_Model = 0

--- 原中文 API：`TURING["来源_获取屏幕像素"]`
function TURING.Pixel_FromScreen(iLeft, iTop, iRight, iBottom)
    local width, height, arr = getScreenPixel(iLeft, iTop, iRight, iBottom)
    R_Left = iLeft
    R_Top = iTop
    R_Right = iRight
    R_Bottom = iBottom
    R_Model = 0
    ImgData = {}
    if arr == nil then
        return ImgData
    end
    for x = 1, width do
        ImgData[x] = {}
        for y = 1, height do
            local color = arr[(y - 1) * width + x]
            local r, g, b = colorToRGB(color)
            ImgData[x][y] = {
                r,
                g,
                b
            }
        end
    end
    arr = nil
    return ImgData
end

local function NewRound(decimal)
    return math.floor(decimal + 0.444444)
end

local function Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

local function Filter_BinaryColor(value)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local flag, imin, imax
    local range = {}
    if string.find(value, "-") ~= nil then
        flag = true
    else
        flag = false
    end
    if flag == true then
        range = Split(value, "-")
        imin = tonumber(range[1])
        imax = tonumber(range[2])
    else
        imax = tonumber(value)
    end
    local w, h, average
    for w = 1, width do
        for h = 1, height do
            average = NewRound((ImgData[w][h][1] + ImgData[w][h][2] + ImgData[w][h][3]) / 3)
            if flag == false then
                if imax > average then
                    ImgData[w][h] = {
                        0,
                        0,
                        0
                    }
                else
                    ImgData[w][h] = {
                        255,
                        255,
                        255
                    }
                end
            elseif flag == true then
                if imin <= average and imax >= average then
                    ImgData[w][h] = {
                        0,
                        0,
                        0
                    }
                else
                    ImgData[w][h] = {
                        255,
                        255,
                        255
                    }
                end
            end
        end
    end
    return ImgData
end

local function Filter_PickColor(feature)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local W, H, fsColor, flag
    if string.sub(feature, 1, 1) == "@" then
        fsColor = 255
        feature = string.sub(feature, 2, #feature)
    else
        fsColor = 0
    end
    local R, G, B, dR, dG, dB
    local range = Split(feature, "|")
    local num = #range
    local ColorData = {}
    for i = 1, num do
        local tempColor = Split(range[i], "-")
        local sColor = tonumber(tempColor[1], 16)
        R = math.floor(sColor % 256)
        G = math.floor(sColor % 65536 / 256)
        B = math.floor(sColor / 65536)
        if 1 < #tempColor then
            sColor = tonumber(tempColor[2], 16)
            dR = math.floor(sColor % 256)
            dG = math.floor(sColor % 65536 / 256)
            dB = math.floor(sColor / 65536)
        else
            dR = 0
            dG = 0
            dB = 0
        end
        ColorData[i] = {
            R + dR,
            G + dG,
            B + dB,
            R - dR,
            G - dG,
            B - dB
        }
    end
    for W = 1, width do
        for H = 1, height do
            flag = false
            for i = 1, num do
                if ImgData[W][H][3] >= ColorData[i][4] and ImgData[W][H][3] <= ColorData[i][1] and ImgData[W][H][2] >= ColorData[i][5] and ImgData[W][H][2] <= ColorData[i][2] and ImgData[W][H][1] >= ColorData[i][6] and ImgData[W][H][1] <= ColorData[i][3] then
                    ImgData[W][H] = {
                        255 - fsColor,
                        255 - fsColor,
                        255 - fsColor
                    }
                    flag = true
                    break
                end
            end
            if flag == false then
                ImgData[W][H] = {
                    fsColor,
                    fsColor,
                    fsColor
                }
            end
        end
    end
    return ImgData
end

local function mao_pao(tb, key)
    local Num = #tb
    for i = 1, Num do
        for j = 1, Num - i do
            if tb[j + 1][key] < tb[j][key] then
                local temp = tb[j + 1]
                tb[j + 1] = tb[j]
                tb[j] = temp
            end
        end
    end
    return tb
end

local function Filter_AI()
    local W, H, width, height, Gray, n, Num, Nums, R, G, B, i, ii, k, m, Flag
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    Nums = math.floor(width * height * 0.5)
    for W = 1, width do
        for H = 1, height do
            R = ImgData[W][H][3]
            G = ImgData[W][H][2]
            B = ImgData[W][H][1]
            Gray = (R ^ 2.2 * 0.2973 + G ^ 2.2 * 0.6274 + B ^ 2.2 * 0.0753) ^ 0.45454545454545453
            ImgData[W][H][1] = Gray
        end
    end
    local Colors = {}
    k = 1
    for W = 1, width do
        for H = 1, height do
            Flag = false
            if 1 < k then
                for m = 1, k - 1 do
                    if ImgData[W][H][1] == Colors[m][1] then
                        Colors[m][2] = Colors[m][2] + 1
                        Flag = true
                        break
                    end
                end
            end
            if Flag == false then
                Colors[k] = {}
                Colors[k][1] = ImgData[W][H][1]
                Colors[k][2] = 1
                k = k + 1
            end
        end
    end
    Num = #Colors
    Colors = mao_pao(Colors, 1)
    local MaxN, MinN, Max, Min
    if 3 < Num then
        MaxN = 0
        MinN = 0
        Max = 1
        Min = 1
        for i = 1, Num do
            MinN = MinN + Colors[i][2]
            if Nums < MinN then
                Min = i
                break
            end
        end
        for ii = Num, 2, -1 do
            MaxN = MaxN + Colors[ii][2]
            if Nums < MaxN then
                Max = ii
                break
            end
        end
        if Min == 1 then
            MinN = Colors[Min][2]
        else
            MinN = MinN - Colors[Min - 1][2]
        end
        if Max == Num then
            MaxN = Colors[Max][2]
        else
            MaxN = MaxN - Colors[Max + 1][2]
        end
        if Colors[Max][2] > Colors[Min][2] then
            if MinN < MaxN then
                Gray = Colors[Max + 1][1]
            else
                Gray = Colors[Min][1]
            end
        elseif MinN > MaxN then
            if Min <= 1 then
                Min = 2
            end
            Gray = Colors[Min - 1][1]
        else
            Gray = Colors[Max][1]
        end
    elseif 2 < Num then
        if Colors[1][2] > Colors[3][2] then
            Gray = Colors[1][1]
        else
            Gray = Colors[2][1]
        end
    else
        Gray = Colors[1][1]
    end
    for W = 1, width do
        for H = 1, height do
            if Gray >= ImgData[W][H][1] then
                ImgData[W][H] = {
                    0,
                    0,
                    0
                }
            else
                ImgData[W][H] = {
                    255,
                    255,
                    255
                }
            end
        end
    end
    return ImgData
end

--- 原中文 API：`TURING["滤镜_彩色_二值化"]`
function TURING.Filter_Binaryzation(threshold)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local flag, value
    if type(threshold) == "number" then
        value = tostring(threshold)
    else
        value = threshold
    end
    if string.sub(value, #value, #value) == "-" then
        return
    end
    if 6 <= #value then
        if 7 < #value then
            flag = 1
        elseif string.find(value, "-") ~= nil then
            flag = 0
        else
            flag = 1
        end
    elseif string.lower(value) == "auto" then
        flag = 2
    elseif string.lower(value) == "ai" then
        flag = 3
    else
        flag = 0
    end
    if flag == 1 then
        return Filter_PickColor(value)
    elseif flag == 0 then
        return Filter_BinaryColor(value)
    elseif flag == 3 then
        return Filter_AI()
    else
        return
    end
end

local function ToMax(r, g, b)
    local Max
    if g <= r and b <= r then
        Max = r
    elseif r <= g and b <= g then
        Max = g
    elseif r <= b and g <= b then
        Max = b
    end
    return Max
end

local function ToMin(r, g, b)
    local Min
    if r <= g and r <= b then
        Min = r
    elseif g <= r and g <= b then
        Min = g
    elseif b <= r and b <= g then
        Min = b
    end
    return Min
end

--- 原中文 API：`TURING["滤镜_彩色_灰度"]`
function TURING.Filter_Gray(Model)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local Gray, W, H, r, g, b, Num, Max, Min
    if Model == nil then
        Model = 0
    end
    Num = 0
    for W = 1, width do
        for H = 1, height do
            r = ImgData[W][H][3]
            g = ImgData[W][H][2]
            b = ImgData[W][H][1]
            if Model == 1 then
                Gray = (r ^ 2.2 * 0.2973 + g ^ 2.2 * 0.6274 + b ^ 2.2 * 0.0753) ^ 0.45454545454545453
            elseif Model == 2 then
                Max = ToMax(r, g, b)
                Min = ToMin(r, g, b)
                Gray = (Max + Min) / 2
            else
                Gray = (r * 299 + g * 587 + b * 114) / 1000
            end
            ImgData[W][H] = {
                Gray,
                Gray,
                Gray
            }
            Num = Num + Gray
        end
    end
    Gray = Num / (width * height)
    return Gray
end

--- 原中文 API：`TURING["滤镜_彩色_色调分离"]`
function TURING.Filter_Posterization(value)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local W, H, n
    if value == nil or value < 2 then
        value = 2
    end
    if 255 < value then
        value = 255
    end
    local feature = 255 / value
    local fsColor = 255 / (value - 1)
    for H = 1, height do
        for W = 1, width do
            local bR = true
            local bG = true
            local bB = true
            for n = 1, value do
                if bB == true and ImgData[W][H][1] >= feature * (n - 1) and ImgData[W][H][1] < feature * n then
                    bB = false
                    ImgData[W][H][1] = math.floor(fsColor * (n - 1))
                end
                if bG == true and ImgData[W][H][2] >= feature * (n - 1) and ImgData[W][H][2] < feature * n then
                    bG = false
                    ImgData[W][H][2] = math.floor(fsColor * (n - 1))
                end
                if bR == true and ImgData[W][H][3] >= feature * (n - 1) and ImgData[W][H][3] < feature * n then
                    bR = false
                    ImgData[W][H][3] = math.floor(fsColor * (n - 1))
                end
            end
        end
    end
    return ImgData
end

--- 原中文 API：`TURING["滤镜_彩色_通道图层"]`
function TURING.Filter_ChannelLayer(Model)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    if Model == nil then
        Model = 0
    end
    for W = 1, width do
        for H = 1, height do
            if Model == 0 then
                ImgData[W][H][2] = 0
                ImgData[W][H][1] = 0
            elseif Model == 1 then
                ImgData[W][H][3] = 0
                ImgData[W][H][1] = 0
            elseif Model == 2 then
                ImgData[W][H][3] = 0
                ImgData[W][H][2] = 0
            elseif Model == 3 then
                ImgData[W][H][1] = 0
            elseif Model == 4 then
                ImgData[W][H][3] = 0
            else
                ImgData[W][H][2] = 0
            end
        end
    end
    return ImgData
end

--- 原中文 API：`TURING["滤镜_黑白_清除杂点"]`
function TURING.Filter_Despeckle(value, interval, Model)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    if value == nil or 8 < value then
        value = 8
    end
    if value < 1 then
        value = 1
    end
    if interval == nil or interval < 0 then
        interval = 0
    end
    if 16 < interval then
        interval = 16
    end
    local fsColor
    if Model == nil or Model == 1 then
        fsColor = 0
    else
        fsColor = 255
    end
    local W, H, X, Y, num, flag, n
    for W = 1, width do
        for H = 1, height do
            num = 0
            if ImgData[W][H][1] == 255 - fsColor then
                flag = false
                if 0 < interval then
                    n = 0
                    for X = -1 - interval, 1 + interval do
                        for Y = -1 - interval, 1 + interval do
                            if -1 <= X and X <= 1 and -1 <= Y and Y <= 1 then
                            elseif W + X < 1 or H + Y < 1 or (width < W + X or height < H + Y) and fsColor == 255 then
                                n = n + 1
                            elseif ImgData[W + X][H + Y][1] == fsColor then
                                n = n + 1
                            end
                        end
                    end
                    if n >= (interval * 2 + 3) ^ 2 - 9 then
                        flag = true
                    end
                else
                    flag = true
                end
                if flag == true then
                    for X = -1, 1 do
                        for Y = -1, 1 do
                            if W + X < 1 or H + Y < 1 or width < W + X or height < H + Y then
                                num = num + 1
                            elseif ImgData[W + X][H + Y][1] ~= 255 - fsColor then
                                num = num + 1
                            end
                        end
                    end
                    if value <= num then
                        ImgData[W][H] = {
                            fsColor,
                            fsColor,
                            fsColor
                        }
                    else
                        ImgData[W][H] = {
                            255 - fsColor,
                            255 - fsColor,
                            255 - fsColor
                        }
                    end
                end
            end
        end
    end
    return ImgData
end

local function DeepCopy(object)
    local SearchTable = {}

    local function Func(object)
        if type(object) ~= "table" then
            return object
        end
        local NewTable = {}
        SearchTable[object] = NewTable
        for k, v in pairs(object) do
            NewTable[Func(k)] = Func(v)
        end
        return setmetatable(NewTable, getmetatable(object))
    end

    return Func(object)
end

--- 原中文 API：`TURING["滤镜_黑白_提取色块"]`
function TURING.Filter_ExtractBlock(wNum, hNum, Num)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local W, H, X, Y, n
    local TmpData = {}
    for W = 1, width do
        TmpData[W] = {}
        for H = 1, height do
            TmpData[W][H] = {
                0,
                0,
                0
            }
        end
    end
    for W = 1, width do
        for H = 1, height do
            n = 0
            if ImgData[W][H][1] == 255 then
                for X = 0, wNum - 1 do
                    for Y = 0, hNum - 1 do
                        if width < W + X or height < H + Y then
                            break
                        end
                        if ImgData[W + X][H + Y][1] == 255 then
                            n = n + 1
                        end
                    end
                end
                if Num <= n then
                    for X = 0, wNum - 1 do
                        for Y = 0, hNum - 1 do
                            if width < W + X or height < H + Y then
                                break
                            end
                            TmpData[W + X][H + Y] = {
                                ImgData[W + X][H + Y][1],
                                ImgData[W + X][H + Y][2],
                                ImgData[W + X][H + Y][3]
                            }
                        end
                    end
                end
            end
        end
    end
    ImgData = {}
    ImgData = DeepCopy(TmpData)
    return ImgData
end

--- 原中文 API：`TURING["滤镜_彩色_色块选留"]`
function TURING.Filter_BlockChoose(iWidth, iHeight, fColor, bColor)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    if iWidth < 2 and iHeight < 2 then
        return
    end
    if fColor == nil then
        fColor = "FFFFFF"
    end
    if bColor == nil then
        bColor = "000000"
    end
    local ZuoBiao, px, py, sColor, R1, G1, B1, R2, G2, B2, i, ii, Num, n, R, G, B, RR, GG, BB, OK, Flag, k, m
    i = 1
    ZuoBiao = {}
    for H = 0, iHeight - 1 do
        for W = 0, iWidth - 1 do
            ZuoBiao[i] = { x = W, y = H }
            i = i + 1
        end
    end
    Num = #ZuoBiao
    ii = 1
    RR = {}
    GG = {}
    BB = {}
    for W = 1, width - iWidth do
        for H = 1, height - iHeight do
            R = ImgData[W][H][3]
            G = ImgData[W][H][2]
            B = ImgData[W][H][1]
            OK = false
            k = 1
            for n = 1, Num do
                if n % 2 == 1 then
                    i = Num - k
                    k = k + 1
                else
                    i = k
                end
                px = ZuoBiao[i].x
                py = ZuoBiao[i].y
                if ImgData[W + px][H + py][1] == B then
                    if ImgData[W + px][H + py][2] == G then
                        if ImgData[W + px][H + py][3] == R then
                            OK = true
                        else
                            OK = false
                            break
                        end
                    else
                        OK = false
                        break
                    end
                else
                    OK = false
                    break
                end
            end
            if OK then
                Flag = false
                if 1 < ii then
                    m = #RR
                    for n = 1, m do
                        if R == RR[n] and G == GG[n] and B == BB[n] then
                            Flag = true
                            break
                        end
                    end
                end
                if not Flag then
                    RR[ii] = R
                    GG[ii] = G
                    BB[ii] = B
                    ii = ii + 1
                end
            end
        end
    end
    Num = #RR
    if fColor and fColor ~= "" then
        sColor = tonumber(fColor, 16)
        R1 = math.floor(sColor % 256)
        G1 = math.floor(sColor % 65536 / 256)
        B1 = math.floor(sColor / 65536)
    end
    if bColor and bColor ~= "" then
        sColor = tonumber(bColor, 16)
        R2 = math.floor(sColor % 256)
        G2 = math.floor(sColor % 65536 / 256)
        B2 = math.floor(sColor / 65536)
    end
    local TmpData = {}
    for W = 1, width do
        TmpData[W] = {}
        for H = 1, height do
            Flag = false
            for ii = 1, Num do
                if ImgData[W][H][3] == RR[ii] and ImgData[W][H][2] == GG[ii] and ImgData[W][H][1] == BB[ii] then
                    if not fColor or fColor == "" then
                        TmpData[W][H] = {
                            ImgData[W][H][1],
                            ImgData[W][H][2],
                            ImgData[W][H][3]
                        }
                    else
                        TmpData[W][H] = {
                            B1,
                            G1,
                            R1
                        }
                    end
                    Flag = true
                    break
                end
            end
            if not Flag then
                TmpData[W][H] = {
                    B2,
                    G2,
                    R2
                }
            end
        end
    end
    ImgData = {}
    ImgData = DeepCopy(TmpData)
    return ImgData
end

local function Filter_Outline(value, Interval, r, g, b)
    local W, H, width, height, Flag, n, yuzhi, jianju, R1, G1, B1, R2, G2, B2, R3, G3, B3, R4, G4, B4
    yuzhi = value
    jianju = Interval
    if yuzhi < 0 then
        yuzhi = 0
    end
    if 255 < yuzhi then
        yuzhi = 255
    end
    if 255 < jianju then
        jianju = 255
    end
    if jianju <= 0 then
        jianju = 1
        n = false
    else
        n = true
    end
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local TmpData = {}
    for W = 1, width do
        TmpData[W] = {}
        for H = 1, height do
            TmpData[W][H] = {
                b,
                g,
                r
            }
        end
    end
    width = width - jianju
    height = height - jianju
    for W = 1, width do
        for H = 1, height do
            R1 = ImgData[W][H][3]
            G1 = ImgData[W][H][2]
            B1 = ImgData[W][H][1]
            R2 = ImgData[W + jianju][H][3]
            G2 = ImgData[W + jianju][H][2]
            B2 = ImgData[W + jianju][H][1]
            R3 = ImgData[W][H + jianju][3]
            G3 = ImgData[W][H + jianju][2]
            B3 = ImgData[W][H + jianju][1]
            Flag = false
            if yuzhi <= (math.abs(R1 - R2) + math.abs(G1 - G2) + math.abs(B1 - B2)) / 3 then
                Flag = true
                TmpData[W + jianju][H] = {
                    ImgData[W + jianju][H][1],
                    ImgData[W + jianju][H][2],
                    ImgData[W + jianju][H][3]
                }
            end
            if yuzhi <= (math.abs(R1 - R3) + math.abs(G1 - G3) + math.abs(B1 - B3)) / 3 then
                Flag = true
                TmpData[W][H + jianju] = {
                    ImgData[W][H + jianju][1],
                    ImgData[W][H + jianju][2],
                    ImgData[W][H + jianju][3]
                }
            end
            if n == true then
                R4 = ImgData[W + jianju][H + jianju][3]
                G4 = ImgData[W + jianju][H + jianju][2]
                B4 = ImgData[W + jianju][H + jianju][1]
                if yuzhi <= (math.abs(R1 - R4) + math.abs(G1 - G4) + math.abs(B1 - B4)) / 3 then
                    Flag = true
                    TmpData[W + jianju][H + jianju] = {
                        ImgData[W + jianju][H + jianju][1],
                        ImgData[W + jianju][H + jianju][2],
                        ImgData[W + jianju][H + jianju][3]
                    }
                end
            end
            if Flag == true then
                TmpData[W][H] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
            end
        end
    end
    ImgData = {}
    ImgData = DeepCopy(TmpData)
    return ImgData
end

--- 原中文 API：`TURING["滤镜_黑白_获取轮廓"]`
function TURING.Filter_Outline(value, Interval, r, g, b)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    if value ~= nil and 0 < value then
        if Interval == nil then
            Interval = 1
        end
        if r == nil then
            r = 255
        end
        if g == nil then
            g = 0
        end
        if b == nil then
            b = 0
        end
        return Filter_Outline(value, Interval, r, g, b)
    end
    local W, H
    local TmpData = {}
    for W = 1, width do
        TmpData[W] = {}
        for H = 1, height do
            if 1 < W and 1 < H and W < width and H < height then
                local c = ImgData[W][H][1]
                if c == 255 then
                    if ImgData[W - 1][H][1] == c and ImgData[W][H - 1][1] == c and ImgData[W + 1][H][1] == c and ImgData[W][H + 1][1] == c then
                        TmpData[W][H] = {
                            0,
                            0,
                            0
                        }
                    else
                        TmpData[W][H] = {
                            255,
                            255,
                            255
                        }
                    end
                else
                    TmpData[W][H] = {
                        0,
                        0,
                        0
                    }
                end
            else
                TmpData[W][H] = {
                    0,
                    0,
                    0
                }
            end
        end
    end
    ImgData = {}
    ImgData = DeepCopy(TmpData)
    return ImgData
end

--- 原中文 API：`TURING["滤镜_黑白_颠倒颜色"]`
function TURING.Filter_InverseColor(Inverse)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local W, H, HEI, BAI
    if Inverse == 1 or Inverse == nil then
        value = 0
    elseif Inverse == 0 then
        value = 255
    else
        value = 178
    end
    if value == 0 or value == 255 then
        HEI = 0
        BAI = 0
        for H = 1, height do
            for W = 1, width do
                if ImgData[W][H][1] == value then
                    HEI = HEI + 1
                else
                    BAI = BAI + 1
                end
            end
        end
        if (HEI ~= 0 or BAI ~= 0) and HEI < BAI then
            for H = 1, height do
                for W = 1, width do
                    if ImgData[W][H][1] == value then
                        ImgData[W][H] = {
                            255 - value,
                            255 - value,
                            255 - value
                        }
                    else
                        ImgData[W][H] = {
                            value,
                            value,
                            value
                        }
                    end
                end
            end
        end
    else
        for H = 1, height do
            for W = 1, width do
                if ImgData[W][H][1] == 0 then
                    ImgData[W][H] = {
                        255,
                        255,
                        255
                    }
                else
                    ImgData[W][H] = {
                        0,
                        0,
                        0
                    }
                end
            end
        end
    end
    return ImgData
end

--- 原中文 API：`TURING["滤镜_黑白_腐蚀膨胀"]`
function TURING.Filter_DilationErosion(Inverse)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local value, m
    if Inverse == 1 or Inverse == nil then
        value = 0
    else
        value = 255
    end
    local TempData = {}
    for W = 1, width do
        TempData[W] = {}
        for H = 1, height do
            m = 0
            TempData[W][H] = {
                ImgData[W][H][1],
                ImgData[W][H][2],
                ImgData[W][H][3]
            }
            if ImgData[W][H][1] == value then
                for Y = 0, 1 do
                    for X = 0, 1 do
                        if width < W + X or height < H + Y then
                            break
                        end
                        if ImgData[W + X][H + Y][1] == 255 - value then
                            m = 1
                        end
                    end
                end
                if m == 1 then
                    TempData[W][H] = {
                        255 - value,
                        255 - value,
                        255 - value
                    }
                end
            end
        end
    end
    ImgData = TempData
    return ImgData
end

--- 原中文 API：`TURING["滤镜_通用_等比缩放"]`
function TURING.Filter_Zoom(ZoomX, ZoomY)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local W, H, X, Y, ZoomW, ZoomH
    if ZoomX == nil then
        ZoomX = 1
    end
    if ZoomY == nil then
        ZoomY = 1
    end
    if 10 < ZoomX or 10 < ZoomY or ZoomX <= 0 or ZoomY <= 0 then
        return ImgData
    end
    if ZoomX < 1 then
        if ZoomX == 0.5 then
            ZoomW = 2
        elseif ZoomX == 0.25 then
            ZoomW = 4
        elseif ZoomX == 0.125 then
            ZoomW = 8
        else
            ZoomW = 1
        end
    else
        ZoomW = ZoomX
    end
    if ZoomY < 1 then
        if ZoomY == 0.5 then
            ZoomH = 2
        elseif ZoomY == 0.25 then
            ZoomH = 4
        elseif ZoomY == 0.125 then
            ZoomH = 8
        else
            ZoomH = 1
        end
    else
        ZoomH = ZoomY
    end
    local TmpData = {}
    if ZoomX == 1 and ZoomY == 1 then
        return ImgData
    elseif ZoomX < 1 and ZoomY < 1 then
        X = 1
        for W = 1, width, ZoomW do
            TmpData[X] = {}
            Y = 1
            for H = 1, height, ZoomH do
                TmpData[X][Y] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
                Y = Y + 1
            end
            X = X + 1
        end
    elseif 1 <= ZoomX and 1 <= ZoomY then
        for W = 1, width do
            for X = 0, ZoomW - 1 do
                TmpData[(W - 1) * ZoomX + X + 1] = {}
                for H = 1, height do
                    for Y = 0, ZoomH - 1 do
                        TmpData[(W - 1) * ZoomX + X + 1][(H - 1) * ZoomY + Y + 1] = {
                            ImgData[W][H][1],
                            ImgData[W][H][2],
                            ImgData[W][H][3]
                        }
                    end
                end
            end
        end
    elseif 1 <= ZoomX and ZoomY < 1 then
        for W = 1, width do
            for X = 0, ZoomW - 1 do
                TmpData[(W - 1) * ZoomX + X + 1] = {}
                Y = 0
                for H = 1, height, ZoomH do
                    TmpData[(W - 1) * ZoomX + X + 1][Y] = {
                        ImgData[W][H][1],
                        ImgData[W][H][2],
                        ImgData[W][H][3]
                    }
                    Y = Y + 1
                end
            end
        end
    elseif ZoomX < 1 and 1 <= ZoomY then
        X = 0
        for W = 1, width, ZoomW do
            TmpData[X] = {}
            for H = 1, height do
                for Y = 0, ZoomH - 1 do
                    TmpData[X][(H - 1) * ZoomY + Y + 1] = {
                        ImgData[W][H][1],
                        ImgData[W][H][2],
                        ImgData[W][H][3]
                    }
                end
            end
            X = X + 1
        end
    end
    ImgData = {}
    ImgData = DeepCopy(TmpData)
    return ImgData
end

--- 原中文 API：`TURING["滤镜_通用_等比缩小"]`
function TURING.Filter_ZoomOut(ZoomX, ZoomY)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local W, H, X, Y, ZX, ZY
    if ZoomX == nil then
        ZX = 1
    else
        ZX = ZoomX
    end
    if ZoomY == nil then
        ZY = 1
    else
        ZY = ZoomY
    end
    if 8 < ZX then
        ZX = 8
    end
    if 8 < ZY then
        ZY = 8
    end
    local TmpData = {}
    X = 1
    for W = 1, width, ZX do
        TmpData[X] = {}
        Y = 1
        for H = 1, height, ZY do
            TmpData[X][Y] = {
                ImgData[W][H][1],
                ImgData[W][H][2],
                ImgData[W][H][3]
            }
            if TmpData[X][Y][1] == nil then
                TmpData[X][Y][1] = 0
            end
            if TmpData[X][Y][2] == nil then
                TmpData[X][Y][2] = 0
            end
            if TmpData[X][Y][3] == nil then
                TmpData[X][Y][3] = 0
            end
            Y = Y + 1
        end
        X = X + 1
    end
    ImgData = {}
    ImgData = DeepCopy(TmpData)
    return ImgData
end

--- 原中文 API：`TURING["滤镜_通用_等比放大"]`
function TURING.Filter_ZoomIn(ZoomX, ZoomY)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local W, H, X, Y, ZX, ZY
    if ZoomX == 2 then
        ZX = 2
    else
        ZX = 1
    end
    if ZoomY == 2 then
        ZY = 2
    else
        ZY = 1
    end
    local TmpData = {}
    X = 1
    for W = 1, width * ZX, ZX do
        TmpData[W] = {}
        if ZX == 2 then
            TmpData[W + 1] = {}
        end
        Y = 1
        for H = 1, height * ZY, ZY do
            TmpData[W][H] = {
                ImgData[X][Y][1],
                ImgData[X][Y][2],
                ImgData[X][Y][3]
            }
            if ZX == 2 and ZY == 2 then
                TmpData[W][H + 1] = {
                    ImgData[X][Y][1],
                    ImgData[X][Y][2],
                    ImgData[X][Y][3]
                }
                TmpData[W + 1][H] = {
                    ImgData[X][Y][1],
                    ImgData[X][Y][2],
                    ImgData[X][Y][3]
                }
                TmpData[W + 1][H + 1] = {
                    ImgData[X][Y][1],
                    ImgData[X][Y][2],
                    ImgData[X][Y][3]
                }
            elseif ZX == 2 then
                TmpData[W + 1][H] = {
                    ImgData[X][Y][1],
                    ImgData[X][Y][2],
                    ImgData[X][Y][3]
                }
            elseif ZY == 2 then
                TmpData[W][H + 1] = {
                    ImgData[X][Y][1],
                    ImgData[X][Y][2],
                    ImgData[X][Y][3]
                }
            end
            Y = Y + 1
        end
        X = X + 1
    end
    ImgData = {}
    ImgData = DeepCopy(TmpData)
    return ImgData
end

--- 原中文 API：`TURING["滤镜_通用_缩放归一化"]`
function TURING.Filter_ZoomOne(ZoomW, ZoomH, Model)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local W, H, Temp, m, n, x, y, BeginX, BeginY, EndX, EndY, CurStep, NxtStep, NegN, CurC0, NxtC0, DCt0, DC0, CurC1, NxtC1, DCt1, DC1, CurC2, NxtC2, DCt2, DC2
    if ZoomW == nil or ZoomW <= 0 then
        return
    end
    if ZoomH == nil or ZoomH <= 0 then
        return
    end
    if Model == nil or Model <= 0 then
        Model = 0
    else
        Model = 1
    end
    local iWidth, iHeight
    if Model == 1 then
        iWidth = NewRound(width * (ZoomW / 100))
        iHeight = NewRound(height * (ZoomH / 100))
    else
        iWidth = ZoomW
        iHeight = ZoomH
    end
    local TempData = {}
    local OverData = {}
    local RatioX, RatioY
    if width == 1 then
        RatioX = 0
    else
        RatioX = iWidth / width
    end
    if height == 1 then
        RatioY = 0
    else
        RatioY = iHeight / height
    end
    NegN = math.floor(1 / (RatioY + 1))
    for W = 1, width do
        TempData[W] = {}
        if height == 1 then
            for H = 1, iHeight do
                TempData[W][H] = {
                    ImgData[W][1][1],
                    ImgData[W][1][2],
                    ImgData[W][1][3]
                }
            end
        else
            CurC0 = ImgData[W][1][1]
            CurC1 = ImgData[W][1][2]
            CurC2 = ImgData[W][1][3]
            CurStep = 1
            NxtStep = 1
            for H = 1, height - 1 do
                NxtStep = CurStep + RatioY
                BeginY = math.floor(CurStep)
                EndY = math.floor(NxtStep)
                n = NxtStep - CurStep
                TempData[W][BeginY] = {
                    CurC0,
                    CurC1,
                    CurC2
                }
                m = H + 1
                NxtC0 = ImgData[W][m][1]
                NxtC1 = ImgData[W][m][2]
                NxtC2 = ImgData[W][m][3]
                if 1 < n then
                    DCt0 = (NxtC0 - CurC0) * NegN
                    DCt1 = (NxtC1 - CurC1) * NegN
                    DCt2 = (NxtC2 - CurC2) * NegN
                    DC0 = 0
                    DC1 = 0
                    DC2 = 0
                    for Temp = BeginY + 1, EndY - 1 do
                        DC0 = DC0 + DCt0
                        DC1 = DC1 + DCt1
                        DC2 = DC2 + DCt2
                        TempData[W][Temp] = {
                            CurC0 + DC0,
                            CurC1 + DC1,
                            CurC2 + DC2
                        }
                    end
                end
                CurStep = NxtStep
                CurC0 = NxtC0
                CurC1 = NxtC1
                CurC2 = NxtC2
            end
            for xx = EndY, iHeight do
                TempData[W][xx] = {
                    NxtC0,
                    NxtC1,
                    NxtC2
                }
            end
        end
    end
    NegN = math.floor(1 / (RatioX + 1))
    for H = 1, iHeight do
        OverData[H] = {}
        if width == 1 then
            for W = 1, iWidth do
                OverData[H][W] = {
                    TempData[1][H][1],
                    TempData[1][H][2],
                    TempData[1][H][3]
                }
            end
        else
            CurC0 = TempData[1][H][1]
            CurC1 = TempData[1][H][2]
            CurC2 = TempData[1][H][3]
            CurStep = 1
            NxtStep = 1
            for W = 1, width - 1 do
                NxtStep = CurStep + RatioX
                BeginX = math.floor(CurStep)
                EndX = math.floor(NxtStep)
                n = NxtStep - CurStep
                OverData[H][BeginX] = {
                    CurC0,
                    CurC1,
                    CurC2
                }
                m = W + 1
                NxtC0 = TempData[m][H][1]
                NxtC1 = TempData[m][H][2]
                NxtC2 = TempData[m][H][3]
                if 1 < n then
                    DCt0 = (NxtC0 - CurC0) * NegN
                    DCt1 = (NxtC1 - CurC1) * NegN
                    DCt2 = (NxtC2 - CurC2) * NegN
                    DC0 = 0
                    DC1 = 0
                    DC2 = 0
                    for Temp = BeginX + 1, EndX - 1 do
                        DC0 = DC0 + DCt0
                        DC1 = DC1 + DCt1
                        DC2 = DC2 + DCt2
                        OverData[H][Temp] = {
                            CurC0 + DC0,
                            CurC1 + DC1,
                            CurC2 + DC2
                        }
                    end
                end
                CurStep = NxtStep
                CurC0 = NxtC0
                CurC1 = NxtC1
                CurC2 = NxtC2
            end
            for xx = EndX, iWidth do
                OverData[H][xx] = {
                    NxtC0,
                    NxtC1,
                    NxtC2
                }
            end
        end
    end
    ImgData = {}
    width = iHeight
    height = iWidth
    x = 1
    for W = 1, height do
        ImgData[x] = {}
        y = 1
        for H = 1, width do
            ImgData[x][y] = {
                OverData[H][W][1],
                OverData[H][W][2],
                OverData[H][W][3]
            }
            y = y + 1
        end
        x = x + 1
    end
    return ImgData
end

--- 原中文 API：`TURING["滤镜_通用_缩放自适应"]`
function TURING.Filter_ZoomAdaptive(ZoomW, ZoomH)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local W, H
    W = width
    if ZoomW < W then
        W = width * 0.5
        if ZoomW > W then
            W = ZoomW
        end
    elseif ZoomW > W then
        W = width * 2
        if ZoomW < W then
            W = ZoomW
        end
    end
    H = height
    if ZoomH < H then
        H = height * 0.5
        if ZoomH > H then
            H = ZoomH
        end
    elseif ZoomH > H then
        H = height * 2
        if ZoomH < H then
            H = ZoomH
        end
    end
    return TURING.Filter_ZoomOne(W, H, 0)
end

--- 原中文 API：`TURING["滤镜_通用_延伸裁剪"]`
function TURING.Filter_Tailor(Left, Top, Right, Bottom)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local iLeft, iTop, iRight, iBottom, W, H, WW, HH, X, Y, xx, yy
    iLeft = 0
    iTop = 0
    iRight = Right - Left
    iBottom = Bottom - Top
    if Left < 0 then
        X = 1
        xx = 1 - Left
    else
        X = Left
        xx = 1
    end
    if Top < 0 then
        Y = 1
        yy = 1 - Top
    else
        Y = Top
        yy = 1
    end
    if Right > width then
        WW = width
    else
        WW = Right
    end
    if Bottom > height then
        HH = height
    else
        HH = Bottom
    end
    local TempData = {}
    for W = 1, iRight + 1 do
        TempData[W] = {}
        for H = 1, iBottom + 1 do
            TempData[W][H] = {
                0,
                0,
                0
            }
        end
    end
    local X1, Y1
    X1 = xx
    for W = X, WW do
        Y1 = yy
        for H = Y, HH do
            TempData[X1][Y1] = {
                ImgData[W][H][1],
                ImgData[W][H][2],
                ImgData[W][H][3]
            }
            Y1 = Y1 + 1
        end
        X1 = X1 + 1
    end
    ImgData = {}
    for W = 1, iRight do
        ImgData[W] = {}
        for H = 1, iBottom do
            ImgData[W][H] = {
                TempData[W][H][1],
                TempData[W][H][2],
                TempData[W][H][3]
            }
        end
    end
    R_Right = R_Left + Right
    R_Bottom = R_Top + Bottom
    R_Left = R_Left + Left
    R_Top = R_Top + Top
    return ImgData
end

--- 原中文 API：`TURING["滤镜_通用_颜色选留"]`
function TURING.Filter_ColorChoose(feature, bColor)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    if feature == nil then
        feature = "FFFFFF"
    end
    if bColor == nil then
        bColor = "000000"
    end
    local W, H, fsColor, sColor, i, flag
    if string.sub(feature, 1, 1) == "@" then
        fsColor = 255
        feature = string.sub(feature, 2, #feature)
    else
        fsColor = 0
    end
    local R, G, B, RR, GG, BB, dR, dG, dB
    local range = Split(feature, "|")
    local num = #range
    local ColorData = {}
    for i = 1, num do
        local tempColor = Split(range[i], "-")
        sColor = tonumber(tempColor[1], 16)
        R = math.floor(sColor % 256)
        G = math.floor(sColor % 65536 / 256)
        B = math.floor(sColor / 65536)
        if 1 < #tempColor then
            sColor = tonumber(tempColor[2], 16)
            dR = math.floor(sColor % 256)
            dG = math.floor(sColor % 65536 / 256)
            dB = math.floor(sColor / 65536)
        else
            dR = 0
            dG = 0
            dB = 0
        end
        ColorData[i] = {
            R + dR,
            G + dG,
            B + dB,
            R - dR,
            G - dG,
            B - dB
        }
    end
    sColor = tonumber(bColor, 16)
    RR = math.floor(sColor % 256)
    GG = math.floor(sColor % 65536 / 256)
    BB = math.floor(sColor / 65536)
    for W = 1, width do
        for H = 1, height do
            if fsColor == 0 then
                flag = false
                for i = 1, num do
                    if ImgData[W][H][3] >= ColorData[i][4] and ImgData[W][H][3] <= ColorData[i][1] and ImgData[W][H][2] >= ColorData[i][5] and ImgData[W][H][2] <= ColorData[i][2] and ImgData[W][H][1] >= ColorData[i][6] and ImgData[W][H][1] <= ColorData[i][3] then
                        flag = true
                        break
                    end
                end
                if flag == false then
                    ImgData[W][H] = {
                        BB,
                        GG,
                        RR
                    }
                end
            else
                for i = 1, num do
                    if ImgData[W][H][3] >= ColorData[i][4] and ImgData[W][H][3] <= ColorData[i][1] and ImgData[W][H][2] >= ColorData[i][5] and ImgData[W][H][2] <= ColorData[i][2] and ImgData[W][H][1] >= ColorData[i][6] and ImgData[W][H][1] <= ColorData[i][3] then
                        ImgData[W][H] = {
                            BB,
                            GG,
                            RR
                        }
                        break
                    end
                end
            end
        end
    end
    return ImgData
end

--- 原中文 API：`TURING["滤镜_通用_固定旋转"]`
function TURING.Filter_Rotate(angle)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    local W, H, X, Y, nX, nY, dx, dy, ddX, ddY
    local size = width + height + 2
    local iLeft = size
    local iRight = 1
    local iTop = size
    local iBottom = 1
    local PI = 3.14159265358979
    local dThetaRad = -angle * PI / 180
    R_Model = 0
    local TempData = {}
    if angle == nil or angle == 0 then
        return
    end
    if angle == 90 or angle == -270 then
        X = 1
        for H = height, 1, -1 do
            TempData[X] = {}
            Y = 1
            for W = 1, width do
                TempData[X][Y] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
                Y = Y + 1
            end
            X = X + 1
        end
        iLeft = 1
        iRight = height
        iTop = 1
        iBottom = width
    elseif angle == -90 or angle == 270 then
        X = 1
        for H = 1, height do
            TempData[X] = {}
            Y = 1
            for W = width, 1, -1 do
                TempData[X][Y] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
                Y = Y + 1
            end
            X = X + 1
        end
        iLeft = 1
        iRight = height
        iTop = 1
        iBottom = width
        R_Model = 1
    elseif angle == 180 or angle == -180 then
        X = 1
        for W = width, 1, -1 do
            TempData[X] = {}
            Y = 1
            for H = height, 1, -1 do
                TempData[X][Y] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
                Y = Y + 1
            end
            X = X + 1
        end
        iLeft = 1
        iRight = width
        iTop = 1
        iBottom = height
    else
        for X = 1, size do
            TempData[X] = {}
            nX = math.floor(X - size / 2)
            for Y = 1, size do
                nY = math.floor(Y - size / 2)
                dx = nX * math.cos(-dThetaRad) + nY * math.sin(-dThetaRad) + 0.4
                dy = nY * math.cos(-dThetaRad) - nX * math.sin(-dThetaRad) + 0.4
                ddX = math.floor(dx + (width + 1) / 2)
                ddY = math.floor(dy + (height + 1) / 2)
                if 0 <= ddX and width > ddX and 0 <= ddY and height > ddY then
                    if X <= iLeft then
                        iLeft = X
                    end
                    if X >= iRight then
                        iRight = X
                    end
                    if Y <= iTop then
                        iTop = Y
                    end
                    if Y >= iBottom then
                        iBottom = Y
                    end
                    ddX = ddX + 1
                    ddY = ddY + 1
                    TempData[X][Y] = {
                        ImgData[ddX][ddY][1],
                        ImgData[ddX][ddY][2],
                        ImgData[ddX][ddY][3]
                    }
                else
                    TempData[X][Y] = {
                        0,
                        0,
                        0
                    }
                end
            end
        end
    end
    ImgData = {}
    X = 1
    for W = iLeft, iRight do
        ImgData[X] = {}
        Y = 1
        for H = iTop, iBottom do
            ImgData[X][Y] = {
                TempData[W][H][1],
                TempData[W][H][2],
                TempData[W][H][3]
            }
            Y = Y + 1
        end
        X = X + 1
    end
    return ImgData
end

--- 原中文 API：`TURING["滤镜_通用_电影底片"]`
function TURING.Filter_Negative()
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    for W = 1, width do
        for H = 1, height do
            ImgData[W][H] = {
                255 - ImgData[W][H][1],
                255 - ImgData[W][H][2],
                255 - ImgData[W][H][3]
            }
        end
    end
    return ImgData
end

--- 原中文 API：`TURING["滤镜_通用_固定镜像"]`
function TURING.Filter_Mirror(value)
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if width <= 0 or height <= 0 then
        return
    end
    if value == nil then
        value = 0
    end
    local x, y
    local TempData = {}
    if value == 0 then
        x = 1
        for W = width, 1, -1 do
            TempData[x] = {}
            y = 1
            for H = 1, height do
                TempData[x][y] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
                y = y + 1
            end
            x = x + 1
        end
    elseif value == 1 then
        x = 1
        for W = 1, width do
            TempData[x] = {}
            y = 1
            for H = height, 1, -1 do
                TempData[x][y] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
                y = y + 1
            end
            x = x + 1
        end
    else
        x = 1
        for W = width, 1, -1 do
            TempData[x] = {}
            y = 1
            for H = height, 1, -1 do
                TempData[x][y] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
                y = y + 1
            end
            x = x + 1
        end
    end
    ImgData = TempData
    return ImgData
end

--- 原中文 API：`TURING["切割_选取指定字符颜色"]`
function TURING.Incise_PickColor(ColorValue)
    if ColorValue == nil or string.len(ColorValue) < 6 then
        Color_B = 255
        Color_G = 255
        Color_R = 255
    else
        local sColor = tonumber(ColorValue, 16)
        Color_B = math.floor(sColor / 65536)
        Color_G = math.floor(sColor % 65536 / 256)
        Color_R = math.floor(sColor % 256)
    end
end

--- 原中文 API：`TURING["切割_固定位置切割"]`
function TURING.Incise_FixedLocation(Qx, Qy, ZW, ZH, Column, cNum, Row, rNum)
    local width = #ImgData
    if width <= 0 then
        return 0
    end
    local height = #ImgData[1]
    if height <= 0 then
        return 0
    end
    if Column == nil then
        Column = 0
    end
    if cNum == nil then
        cNum = 1
    end
    if Row == nil then
        Row = 0
    end
    if rNum == nil then
        rNum = 1
    end
    local X, Y, W, H, WW, HH, i
    IncData = {}
    i = 1
    Y = Qy
    for HH = 1, rNum do
        X = Qx
        for WW = 1, cNum do
            local Two = {}
            for W = 1, ZW do
                if width < W + X then
                    break
                end
                local One = {}
                for H = 1, ZH do
                    if height < H + Qy then
                        break
                    end
                    if ImgData[W + X][H + Y][1] == Color_B and ImgData[W + X][H + Y][2] == Color_G and ImgData[W + X][H + Y][3] == Color_R then
                        One[H] = "1"
                    else
                        One[H] = "0"
                    end
                end
                Two[W] = string.sub(table.concat(One, "") .. string.rep("0", ZH), 1, ZH)
            end
            local n = ZW * ZH
            local iLeft = X
            local iTop = Y
            local iWidth = ZW
            local iHeight = ZH
            local ysWidth = ZW
            local ysHeight = ZH
            local sLattice = string.sub(table.concat(Two, "") .. string.rep("0", n), 1, n)
            IncData[i] = {
                iLeft,
                iTop,
                iWidth,
                iHeight,
                ysWidth,
                ysHeight,
                sLattice
            }
            i = i + 1
            X = X + Column
        end
        Y = Y + Row
    end
    return cNum * rNum
end

--- 原中文 API：`TURING["切割_随机方位切割"]`
function TURING.Incise_RandomOrientation(Vlaue, sWidth, sHeight)
    local width = #ImgData
    if width <= 0 then
        return 0
    end
    local height = #ImgData[1]
    if height <= 0 then
        return 0
    end
    if Vlaue == nil then
        Vlaue = 0
    end
    if sWidth == nil then
        sWidth = "0"
    end
    if sHeight == nil then
        sHeight = "0"
    end
    local W, H, Zw, Zh, QX, QY, bo, j, Point, n, m
    local ZYBJ = {}
    local SXBJ = {}
    IncData = {}
    bo = false
    n = 1
    for W = 1, width do
        Point = 0
        for H = 1, height do
            if ImgData[W][H][1] == Color_B and ImgData[W][H][2] == Color_G and ImgData[W][H][3] == Color_R and bo == false then
                Point = Point + 1
                if Vlaue < Point then
                    bo = true
                    ZYBJ[n] = W
                    n = n + 1
                    break
                end
            elseif ImgData[W][H][1] == Color_B and ImgData[W][H][2] == Color_G and ImgData[W][H][3] == Color_R and bo == true then
                Point = Point + 1
            end
            if W < width and H >= height and bo == true and Vlaue >= Point then
                bo = false
                ZYBJ[n] = W - 1
                n = n + 1
                break
            end
        end
        if W >= width and bo == true then
            ZYBJ[n] = W
            n = n + 1
            break
        end
    end
    if n < 3 then
        return 0
    end
    m = n - 1
    local i = 0
    n = 1
    for j = 1, m, 2 do
        if j >= m then
            j = m
        end
        Zw = ZYBJ[j + 1] - ZYBJ[j]
        for H = 1, height do
            for W = ZYBJ[j], ZYBJ[j + 1] do
                if ImgData[W][H][1] == Color_B and ImgData[W][H][2] == Color_G and ImgData[W][H][3] == Color_R then
                    SXBJ[n] = H
                    n = n + 1
                    goto lbl_159
                end
            end
        end
        ::lbl_159::
        for H = height, 1, -1 do
            for W = ZYBJ[j], ZYBJ[j + 1] do
                if ImgData[W][H][1] == Color_B and ImgData[W][H][2] == Color_G and ImgData[W][H][3] == Color_R then
                    SXBJ[n] = H
                    n = n + 1
                    goto lbl_191
                end
            end
        end
        ::lbl_191::
        Zh = SXBJ[j + 1] - SXBJ[j]
        local Two = {}
        for QX = 0, Zw do
            local One = {}
            for QY = 0, Zh do
                if ImgData[QX + ZYBJ[j]][QY + SXBJ[j]][1] == Color_B and ImgData[QX + ZYBJ[j]][QY + SXBJ[j]][2] == Color_G and ImgData[QX + ZYBJ[j]][QY + SXBJ[j]][3] == Color_R then
                    table.insert(One, "1")
                else
                    table.insert(One, "0")
                end
            end
            table.insert(Two, table.concat(One, ""))
        end
        if sWidth == "0" and sHeight == "0" then
            local fLeft = Qx
            local fTop = Qy
            local fWidth = Zw + 1
            local fHeight = Zh + 1
            local ysWidth = Zw + 1
            local ysHeight = Zh + 1
            local sLattice = table.concat(Two, "")
            IncData[i + 1] = {
                fLeft,
                fTop,
                fWidth,
                fHeight,
                ysWidth,
                ysHeight,
                sLattice
            }
            i = i + 1
        else
            local q, iLfet, iRight, iTop, iBottom
            local FW = {}
            _, q = string.find(sWidth, "-")
            if q == nil then
                q = 0
            end
            if 0 < q then
                FW = Split(sWidth, "-")
                iLfet = tonumber(FW[1])
                iRight = tonumber(FW[2])
            else
                iLfet = 1
                iRight = tonumber(sWidth)
            end
            _, q = string.find(sHeight, "-")
            if q == nil then
                q = 0
            end
            if 0 < q then
                FW = Split(sHeight, "-")
                iTop = tonumber(FW[1])
                iBottom = tonumber(FW[2])
            else
                iTop = 1
                iBottom = tonumber(sHeight)
            end
            if iLfet <= Zw + 1 and iRight >= Zw + 1 and iTop <= Zh + 1 and iBottom >= Zh + 1 then
                goto lbl_340
                goto lbl_363
                ::lbl_340::
                local iLeft = ZYBJ[j]
                local iTop = SXBJ[j]
                local iWidth = Zw + 1
                local iHeight = Zh + 1
                local ysWidth = Zw + 1
                local ysHeight = Zh + 1
                local sLattice = table.concat(Two, "")
                IncData[i + 1] = {
                    iLeft,
                    iTop,
                    iWidth,
                    iHeight,
                    ysWidth,
                    ysHeight,
                    sLattice
                }
                i = i + 1
            end
        end
        ::lbl_363::
    end
    return i
end

local function imgZhongZiTianChong(Qx, Qy, sColor, isBaxiang)
    local i
    local JiLu = {
        0,
        0,
        0
    }
    local xxTmp = {}
    local yyTmp = {}
    local width = #ImgData
    local height = #ImgData[1]
    local nLeft = width
    local nTop = height
    local nGight = 1
    local nBottom = 1
    local R = math.floor(sColor % 256)
    local G = math.floor(sColor % 65536 / 256)
    local B = math.floor(sColor / 65536)
    if isBaxiang == true then
        xxTmp = {
            1,
            1,
            0,
            -1,
            -1,
            -1,
            0,
            1
        }
        yyTmp = {
            0,
            -1,
            -1,
            -1,
            0,
            1,
            1,
            1
        }
    else
        xxTmp = {
            1,
            0,
            -1,
            0
        }
        yyTmp = {
            0,
            -1,
            0,
            1
        }
    end
    local Num = #xxTmp
    local n = 2
    local t = 0
    local xx = Qx
    local yy = Qy
    t = t + 1
    JiLu[t] = { xx, yy }
    while t ~= 0 do
        xx = JiLu[t][1]
        yy = JiLu[t][2]
        t = t - 1
        if width < xx then
            xx = width
        end
        if height < yy then
            yy = height
        end
        if xx < 1 then
            xx = 1
        end
        if yy < 1 then
            yy = 1
        end
        local BB = ImgData[xx][yy][1]
        local GG = ImgData[xx][yy][2]
        local RR = ImgData[xx][yy][3]
        if RR == Color_B and GG == Color_G and BB == Color_R then
            ImgData[xx][yy] = {
                B,
                G,
                R
            }
            if nLeft > xx then
                nLeft = xx
            end
            if nTop > yy then
                nTop = yy
            end
            if nGight < xx then
                nGight = xx
            end
            if nBottom < yy then
                nBottom = yy
            end
            for i = 1, Num do
                if t == n then
                    n = n * 2
                    for m = 0, n - 1 do
                        JiLu[n + m] = {}
                    end
                end
                t = t + 1
                JiLu[t] = {
                    xx + xxTmp[i],
                    yy + yyTmp[i]
                }
            end
        end
    end
    local QuYU = {}
    QuYU[1] = nLeft
    QuYU[2] = nTop
    QuYU[3] = nGight
    QuYU[4] = nBottom
    return QuYU
end

local function H_TableSort(Min, Max)
    for i = Min, Max - 1 do
        for j = i + 1, Max do
            if IncData[j][2] < IncData[i][2] then
                local temp = {}
                for n = 1, 7 do
                    temp[n] = IncData[i][n]
                    IncData[i][n] = IncData[j][n]
                    IncData[j][n] = temp[n]
                end
            end
        end
    end
    return
end

local function W_TableSort(Min, Max)
    for i = Min, Max - 1 do
        for j = i + 1, Max do
            if IncData[j][1] < IncData[i][1] then
                local temp = {}
                for n = 1, 7 do
                    temp[n] = IncData[i][n]
                    IncData[i][n] = IncData[j][n]
                    IncData[j][n] = temp[n]
                end
            end
        end
    end
    return
end

--- 原中文 API：`TURING["切割_连通区域切割"]`
function TURING.Incise_ConnectedArea(Through, sWidth, sHeight)
    local width = #ImgData
    if width <= 0 then
        return 0
    end
    local height = #ImgData[1]
    if height <= 0 then
        return 0
    end
    if Through == nil then
        Through = false
    end
    if sWidth == nil then
        sWidth = "0"
    end
    if sHeight == nil then
        sHeight = "0"
    end
    if sort == nil then
        sort = 0
    end
    IncData = {}
    local nLeft = {}
    local nTop = {}
    local nWidth = {}
    local nHeight = {}
    local sColor = {}
    local iColor = 1
    local i = 1
    for W = 1, width do
        for H = 1, height do
            if ImgData[W][H][1] == Color_B and ImgData[W][H][2] == Color_G and ImgData[W][H][3] == Color_R then
                local QuYU = {}
                QuYU = imgZhongZiTianChong(W, H, iColor, Through)
                if 0 <= QuYU[3] - QuYU[1] and 0 <= QuYU[4] - QuYU[2] and width >= QuYU[3] - QuYU[1] and height >= QuYU[4] - QuYU[2] then
                    sColor[i] = iColor
                    nLeft[i] = QuYU[1]
                    nTop[i] = QuYU[2]
                    nWidth[i] = QuYU[3] - QuYU[1] + 1
                    nHeight[i] = QuYU[4] - QuYU[2] + 1
                    i = i + 1
                    iColor = iColor + 1
                end
            end
        end
    end
    if i == 1 then
        return 0
    end
    local Num = #sColor
    i = 0
    for j = 1, Num do
        local R = math.floor(sColor[j] % 256)
        local G = math.floor(sColor[j] % 65536 / 256)
        local B = math.floor(sColor[j] / 65536)
        local Two = {}
        for QX = 0, nWidth[j] - 1 do
            local One = {}
            if width < QX + nLeft[j] then
                break
            end
            for QY = 0, nHeight[j] - 1 do
                if height < QY + nTop[j] then
                    break
                end
                if ImgData[QX + nLeft[j]][QY + nTop[j]][3] == R and ImgData[QX + nLeft[j]][QY + nTop[j]][2] == G and ImgData[QX + nLeft[j]][QY + nTop[j]][1] == B then
                    table.insert(One, "1")
                else
                    table.insert(One, "0")
                end
            end
            table.insert(Two, table.concat(One, ""))
        end
        if sWidth == "0" and sHeight == "0" then
            local fLeft = nLeft[j]
            local fTop = nTop[j]
            local fWidth = nWidth[j]
            local fHeight = nHeight[j]
            local ysWidth = nWidth[j]
            local ysHeight = nHeight[j]
            local sLattice = table.concat(Two, "")
            IncData[i + 1] = {
                fLeft,
                fTop,
                fWidth,
                fHeight,
                ysWidth,
                ysHeight,
                sLattice
            }
            i = i + 1
        else
            local q, iLfet, iRight, iTop, iBottom
            local FW = {}
            _, q = string.find(sWidth, "-")
            if q == nil then
                q = 0
            end
            if 0 < q then
                FW = Split(sWidth, "-")
                iLfet = tonumber(FW[1])
                iRight = tonumber(FW[2])
            else
                iLfet = 1
                iRight = tonumber(sWidth)
            end
            _, q = string.find(sHeight, "-")
            if q == nil then
                q = 0
            end
            if 0 < q then
                FW = Split(sHeight, "-")
                iTop = tonumber(FW[1])
                iBottom = tonumber(FW[2])
            else
                iTop = 1
                iBottom = tonumber(sHeight)
            end
            if iLfet <= nWidth[j] and iRight >= nWidth[j] and iTop <= nHeight[j] and iBottom >= nHeight[j] then
                goto lbl_327
                goto lbl_350
                ::lbl_327::
                local fLeft = nLeft[j]
                local fTop = nTop[j]
                local fWidth = nWidth[j]
                local fHeight = nHeight[j]
                local ysWidth = nWidth[j]
                local ysHeight = nHeight[j]
                local sLattice = table.concat(Two, "")
                IncData[i + 1] = {
                    fLeft,
                    fTop,
                    fWidth,
                    fHeight,
                    ysWidth,
                    ysHeight,
                    sLattice
                }
                i = i + 1
            end
        end
        ::lbl_350::
    end
    if 0 < i and sort == 0 then
        local n = #IncData
        H_TableSort(1, n)
        local InitialRange = IncData[1][2] + IncData[1][4]
        local m = 1
        for k = 1, n - 1 do
            if InitialRange <= IncData[k + 1][2] then
                InitialRange = IncData[k + 1][2] + IncData[k + 1][4]
                W_TableSort(m, k)
                m = k + 1
            elseif InitialRange < IncData[k + 1][2] + IncData[k + 1][4] then
                InitialRange = IncData[k + 1][2] + IncData[k + 1][4]
            end
        end
        if n > m then
            W_TableSort(m, n)
        end
    end
    return i
end

--- 原中文 API：`TURING["切割_范围投影切割"]`
function TURING.Incise_ScopeAisle(Row, Column, sWidth, sHeight, sort)
    local width = #ImgData - 1
    if width <= 0 then
        return 0
    end
    local height = #ImgData[1] - 1
    if height <= 0 then
        return 0
    end
    local w, h, LuXian, Zw, Zh, x, y, Qx, Qy, Zx, Zy, ix, iy
    if Row == nil or Row < 1 then
        Row = 1
    end
    if Column == nil or Column < 1 then
        Column = 1
    end
    if sWidth == nil then
        sWidth = "0"
    end
    if sHeight == nil then
        sHeight = "0"
    end
    if sort == nil then
        sort = 0
    end
    IncData = {}
    local i = 0
    for w = 0, width do
        h = 0
        while height >= h do
            if ImgData[w + 1][h + 1][4] ~= nil and 1 <= ImgData[w + 1][h + 1][4] then
                h = h + ImgData[w + 1][h + 1][4]
            elseif ImgData[w + 1][h + 1][1] == Color_B and ImgData[w + 1][h + 1][2] == Color_G and ImgData[w + 1][h + 1][3] == Color_R then
                Qx = w
                Qy = h
                Zx = Qx + 1
                Zy = Qy + 1
                while true do
                    LuXian = true
                    for x = 0, Column - 1 do
                        for y = 0, Row - 1 do
                            if width < Zx + x or height < Zy + y then
                                break
                            end
                            if Zx > width - x then
                                Zx = width - x
                            end
                            if Zy > height - y then
                                Zy = height - y
                            end
                            if ImgData[Zx + x + 1][Zy + y + 1][1] == Color_B and ImgData[Zx + x + 1][Zy + y + 1][2] == Color_G and ImgData[Zx + x + 1][Zy + y + 1][3] == Color_R then
                                Zx = Zx + 1
                                Zy = Zy + 1
                                LuXian = false
                            end
                        end
                    end
                    if LuXian ~= true then
                    else
                        if LuXian == true then
                            for y = 0, Row - 1 do
                                for ix = Qx + 1, Zx + Column - 1 do
                                    if ix > width or 0 > Qy - y - 1 then
                                        break
                                    end
                                    if ImgData[ix + 1][Qy - y - 1 + 1][1] == Color_B and ImgData[ix + 1][Qy - y - 1 + 1][2] == Color_G and ImgData[ix + 1][Qy - y - 1 + 1][3] == Color_R then
                                        Qy = Qy - 1
                                        LuXian = false
                                        break
                                    end
                                end
                                if LuXian == false then
                                    break
                                end
                            end
                        end
                        if LuXian == true then
                            for x = 0, Column - 1 do
                                for iy = Zy - 1, Qy, -1 do
                                    if iy < 0 or iy > height or width < Zx + x then
                                        break
                                    end
                                    if ImgData[Zx + x + 1][iy + 1][1] == Color_B and ImgData[Zx + x + 1][iy + 1][2] == Color_G and ImgData[Zx + x + 1][iy + 1][3] == Color_R then
                                        Zx = Zx + 1
                                        LuXian = false
                                        break
                                    end
                                end
                                if LuXian == false then
                                    break
                                end
                            end
                        end
                        if LuXian == true then
                            for y = 0, Row - 1 do
                                for ix = Zx - 1, Qx, -1 do
                                    if ix < 0 or ix > width or height < Zy + y then
                                        break
                                    end
                                    if ImgData[ix + 1][Zy + y + 1][1] == Color_B and ImgData[ix + 1][Zy + y + 1][2] == Color_G and ImgData[ix + 1][Zy + y + 1][3] == Color_R then
                                        Zy = Zy + 1
                                        LuXian = false
                                        break
                                    end
                                end
                                if LuXian == false then
                                    break
                                end
                            end
                        end
                        if LuXian == true then
                            break
                        end
                    end
                end
                Zw = Zx - Qx - 1
                Zh = Zy - Qy - 1
                local Two = {}
                for x = 0, Zw do
                    local One = {}
                    for y = 0, Zh do
                        if ImgData[Qx + x + 1][Qy + y + 1][1] == Color_B and ImgData[Qx + x + 1][Qy + y + 1][2] == Color_G and ImgData[Qx + x + 1][Qy + y + 1][3] == Color_R then
                            ImgData[Qx + x + 1][Qy + y + 1] = {
                                0,
                                0,
                                0
                            }
                            table.insert(One, "1")
                        else
                            table.insert(One, "0")
                        end
                        ImgData[Qx + x + 1][Qy + y + 1][4] = Zh - y
                    end
                    table.insert(Two, table.concat(One, ""))
                end
                if sWidth == "0" and sHeight == "0" then
                    local fLeft = Qx
                    local fTop = Qy
                    local fWidth = Zw + 1
                    local fHeight = Zh + 1
                    local ysWidth = Zw + 1
                    local ysHeight = Zh + 1
                    local sLattice = table.concat(Two, "")
                    IncData[i + 1] = {
                        fLeft,
                        fTop,
                        fWidth,
                        fHeight,
                        ysWidth,
                        ysHeight,
                        sLattice
                    }
                    i = i + 1
                else
                    local q, iLfet, iRight, iTop, iBottom
                    local FW = {}
                    _, q = string.find(sWidth, "-")
                    if q == nil then
                        q = 0
                    end
                    if 0 < q then
                        FW = Split(sWidth, "-")
                        iLfet = tonumber(FW[1])
                        iRight = tonumber(FW[2])
                    else
                        iLfet = 1
                        iRight = tonumber(sWidth)
                    end
                    _, q = string.find(sHeight, "-")
                    if q == nil then
                        q = 0
                    end
                    if 0 < q then
                        FW = Split(sHeight, "-")
                        iTop = tonumber(FW[1])
                        iBottom = tonumber(FW[2])
                    else
                        iTop = 1
                        iBottom = tonumber(sHeight)
                    end
                    if iLfet <= Zw + 1 and iRight >= Zw + 1 and iTop <= Zh + 1 and iBottom >= Zh + 1 then
                        goto lbl_523
                        goto lbl_546
                        ::lbl_523::
                        local fLeft = Qx
                        local fTop = Qy
                        local fWidth = Zw + 1
                        local fHeight = Zh + 1
                        local ysWidth = Zw + 1
                        local ysHeight = Zh + 1
                        local sLattice = table.concat(Two, "")
                        IncData[i + 1] = {
                            fLeft,
                            fTop,
                            fWidth,
                            fHeight,
                            ysWidth,
                            ysHeight,
                            sLattice
                        }
                        i = i + 1
                    end
                end
            end
            ::lbl_546::
            h = h + 1
        end
    end
    if 0 < i and sort == 0 then
        local n = #IncData
        H_TableSort(1, n)
        local InitialRange = IncData[1][2] + IncData[1][4]
        local m = 1
        for k = 1, n - 1 do
            if InitialRange <= IncData[k + 1][2] then
                InitialRange = IncData[k + 1][2] + IncData[k + 1][4]
                W_TableSort(m, k)
                m = k + 1
            elseif InitialRange < IncData[k + 1][2] + IncData[k + 1][4] then
                InitialRange = IncData[k + 1][2] + IncData[k + 1][4]
            end
        end
        if n > m then
            W_TableSort(m, n)
        end
    end
    return i
end

local function Other_pointData(iWidth, iHeight, sLattice)
    local W, H, n
    local TempData = {}
    n = 0
    for W = 1, iWidth do
        TempData[W] = {}
        for H = 1, iHeight do
            if string.sub(sLattice, n + H, n + H) == "1" then
                TempData[W][H] = {
                    255,
                    255,
                    255
                }
            else
                TempData[W][H] = {
                    0,
                    0,
                    0
                }
            end
        end
        n = n + iHeight
    end
    return TempData
end

--- 原中文 API：`TURING["切割_获取切割字符数据"]`
function TURING.Incise_GetCharData()
    return IncData
end

local function Other_ZoomOne(TmpData, ZoomW, ZoomH, Model)
    local width = #TmpData
    if width <= 0 then
        return
    end
    local height = #TmpData[1]
    if height <= 0 then
        return
    end
    local W, H, Temp, m, n, x, y, BeginX, BeginY, EndX, EndY, CurStep, NxtStep, NegN, CurC0, NxtC0, DCt0, DC0, CurC1, NxtC1, DCt1, DC1, CurC2, NxtC2, DCt2, DC2
    if ZoomW == nil or ZoomW <= 0 then
        return
    end
    if ZoomH == nil or ZoomH <= 0 then
        return
    end
    if Model == nil or Model <= 0 then
        Model = 0
    else
        Model = 1
    end
    local iWidth, iHeight
    if Model == 1 then
        iWidth = width * (ZoomW / 100)
        iHeight = height * (ZoomH / 100)
    else
        iWidth = ZoomW
        iHeight = ZoomH
    end
    local TempData = {}
    local OverData = {}
    local RatioX, RatioY
    if width == 1 then
        RatioX = 0
    else
        RatioX = iWidth / width
    end
    if height == 1 then
        RatioY = 0
    else
        RatioY = iHeight / height
    end
    NegN = math.floor(1 / (RatioY + 1))
    for W = 1, width do
        TempData[W] = {}
        if height == 1 then
            for H = 1, iHeight do
                TempData[W][H] = {
                    ImgData[W][1][1],
                    ImgData[W][1][2],
                    ImgData[W][1][3]
                }
            end
        else
            CurC0 = TmpData[W][1][1]
            CurC1 = TmpData[W][1][2]
            CurC2 = TmpData[W][1][3]
            CurStep = 1
            NxtStep = 1
            for H = 1, height - 1 do
                NxtStep = CurStep + RatioY
                BeginY = math.floor(CurStep)
                EndY = math.floor(NxtStep)
                n = NxtStep - CurStep
                TempData[W][BeginY] = {
                    CurC0,
                    CurC1,
                    CurC2
                }
                m = H + 1
                NxtC0 = TmpData[W][m][1]
                NxtC1 = TmpData[W][m][2]
                NxtC2 = TmpData[W][m][3]
                if 1 < n then
                    DCt0 = (NxtC0 - CurC0) * NegN
                    DCt1 = (NxtC1 - CurC1) * NegN
                    DCt2 = (NxtC2 - CurC2) * NegN
                    DC0 = 0
                    DC1 = 0
                    DC2 = 0
                    for Temp = BeginY + 1, EndY - 1 do
                        DC0 = DC0 + DCt0
                        DC1 = DC1 + DCt1
                        DC2 = DC2 + DCt2
                        TempData[W][Temp] = {
                            CurC0 + DC0,
                            CurC1 + DC1,
                            CurC2 + DC2
                        }
                    end
                end
                CurStep = NxtStep
                CurC0 = NxtC0
                CurC1 = NxtC1
                CurC2 = NxtC2
            end
            for xx = EndY, iHeight do
                TempData[W][xx] = {
                    NxtC0,
                    NxtC1,
                    NxtC2
                }
            end
        end
    end
    NegN = math.floor(1 / (RatioX + 1))
    for H = 1, iHeight do
        OverData[H] = {}
        if width == 1 then
            for W = 1, iWidth do
                OverData[H][W] = {
                    TempData[1][H][1],
                    TempData[1][H][2],
                    TempData[1][H][3]
                }
            end
        else
            CurC0 = TempData[1][H][1]
            CurC1 = TempData[1][H][2]
            CurC2 = TempData[1][H][3]
            CurStep = 1
            NxtStep = 1
            for W = 1, width - 1 do
                NxtStep = CurStep + RatioX
                BeginX = math.floor(CurStep)
                EndX = math.floor(NxtStep)
                n = NxtStep - CurStep
                OverData[H][BeginX] = {
                    CurC0,
                    CurC1,
                    CurC2
                }
                m = W + 1
                NxtC0 = TempData[m][H][1]
                NxtC1 = TempData[m][H][2]
                NxtC2 = TempData[m][H][3]
                if 1 < n then
                    DCt0 = (NxtC0 - CurC0) * NegN
                    DCt1 = (NxtC1 - CurC1) * NegN
                    DCt2 = (NxtC2 - CurC2) * NegN
                    DC0 = 0
                    DC1 = 0
                    DC2 = 0
                    for Temp = BeginX + 1, EndX - 1 do
                        DC0 = DC0 + DCt0
                        DC1 = DC1 + DCt1
                        DC2 = DC2 + DCt2
                        OverData[H][Temp] = {
                            CurC0 + DC0,
                            CurC1 + DC1,
                            CurC2 + DC2
                        }
                    end
                end
                CurStep = NxtStep
                CurC0 = NxtC0
                CurC1 = NxtC1
                CurC2 = NxtC2
            end
            for xx = EndX, iWidth do
                OverData[H][xx] = {
                    NxtC0,
                    NxtC1,
                    NxtC2
                }
            end
        end
    end
    TempData = {}
    width = iHeight
    height = iWidth
    x = 1
    for W = 1, height do
        TempData[x] = {}
        y = 1
        for H = 1, width do
            TempData[x][y] = {
                OverData[H][W][1],
                OverData[H][W][2],
                OverData[H][W][3]
            }
            y = y + 1
        end
        x = x + 1
    end
    return TempData
end

local function Other_BinaryColor(TempData, value)
    local width = #TempData
    local height = #TempData[1]
    local w, h, average
    for w = 1, width do
        for h = 1, height do
            average = (TempData[w][h][1] + TempData[w][h][2] + TempData[w][h][3]) / 3
            if value > average then
                TempData[w][h] = {
                    0,
                    0,
                    0
                }
            else
                TempData[w][h] = {
                    255,
                    255,
                    255
                }
            end
        end
    end
    return TempData
end

local function Other_CreateLattice(TempData)
    local W, H
    local Two = {}
    local width = #TempData
    local height = #TempData[1]
    for W = 1, width do
        local One = {}
        for H = 1, height do
            if TempData[W][H][1] == 255 then
                table.insert(One, "1")
            else
                table.insert(One, "0")
            end
        end
        table.insert(Two, table.concat(One, ""))
    end
    return table.concat(Two, "")
end

--- 原中文 API：`TURING["切割_字符大小归一化"]`
function TURING.Incise_CharSizeOne(iWidth, iHeight)
    local IncNum = #IncData
    if IncNum <= 0 then
        return
    end
    local W, H, Width, Height, n
    for n = 1, IncNum do
        local TempData1 = {}
        TempData1 = Other_pointData(IncData[n][3], IncData[n][4], IncData[n][7])
        local TempData2 = {}
        TempData2 = Other_ZoomOne(TempData1, iWidth, iHeight)
        local TempData3 = {}
        TempData3 = Other_BinaryColor(TempData2, 128)
        local sLattice = Other_CreateLattice(TempData3)
        IncData[n][3] = iWidth
        IncData[n][4] = iHeight
        IncData[n][7] = sLattice
    end
    return IncData
end

local function Incise_Rotate_Ex(angle, TempImgData)
    local width = #TempImgData
    local height = #TempImgData[1]
    if width <= 0 or height <= 0 then
        return
    end
    local W, H, X, Y, nX, nY, dx, dy, ddX, ddY
    local size = width + height + 2
    local PI = 3.14159265358979
    local dThetaRad = -angle * PI / 180
    local TempData = {}
    if angle == nil or angle == 0 then
        return
    end
    for X = 1, size do
        TempData[X] = {}
        nX = math.floor(X - size / 2)
        for Y = 1, size do
            TempData[X][Y] = {
                0,
                0,
                0
            }
            nY = math.floor(Y - size / 2)
            dx = nX * math.cos(-dThetaRad) + nY * math.sin(-dThetaRad) + 0.4
            dy = nY * math.cos(-dThetaRad) - nX * math.sin(-dThetaRad) + 0.4
            ddX = math.floor(dx + (width + 1) / 2) + 1
            ddY = math.floor(dy + (height + 1) / 2) + 1
            if 1 <= ddX and width >= ddX and 1 <= ddY and height >= ddY then
                TempData[X][Y] = {
                    TempImgData[ddX][ddY][1],
                    TempImgData[ddX][ddY][2],
                    TempImgData[ddX][ddY][3]
                }
            end
        end
    end
    local iLeft, iRight, iTop, iBottom
    for X = 1, size do
        for Y = 1, size do
            if TempData[X][Y][3] == 255 and TempData[X][Y][2] == 255 and TempData[X][Y][1] == 255 then
                iLeft = X
                goto lbl_140
            end
        end
    end
    ::lbl_140::
    for X = size, 1, -1 do
        for Y = 1, size do
            if TempData[X][Y][3] == 255 and TempData[X][Y][2] == 255 and TempData[X][Y][1] == 255 then
                iRight = X
                goto lbl_167
            end
        end
    end
    ::lbl_167::
    for Y = 1, size do
        for X = 1, size do
            if TempData[X][Y][3] == 255 and TempData[X][Y][2] == 255 and TempData[X][Y][1] == 255 then
                iTop = Y
                goto lbl_194
            end
        end
    end
    ::lbl_194::
    for Y = size, 1, -1 do
        for X = 1, size do
            if TempData[X][Y][3] == 255 and TempData[X][Y][2] == 255 and TempData[X][Y][1] == 255 then
                iBottom = Y
                goto lbl_221
            end
        end
    end
    ::lbl_221::
    ImgData = {}
    X = 1
    for W = iLeft, iRight do
        ImgData[X] = {}
        Y = 1
        for H = iTop, iBottom do
            ImgData[X][Y] = {
                TempData[W][H][1],
                TempData[W][H][2],
                TempData[W][H][3]
            }
            Y = Y + 1
        end
        X = X + 1
    end
    return ImgData
end

local function Incise_RotateCorrect_Ex(angle, istep, TempImgData)
    local width = #TempImgData
    local height = #TempImgData[1]
    if width <= 0 or height <= 0 then
        return
    end
    local PI = 3.14159265358979
    local W, H, n, i, k
    local BaiDianZuoBiao = {}
    n = 1
    for W = 1, width do
        k = 0
        for H = 1, height do
            if TempImgData[W][H][1] == 255 and TempImgData[W][H][2] == 255 and TempImgData[W][H][3] == 255 then
                BaiDianZuoBiao[n] = { W, H }
                n = n + 1
                k = H + 1
                break
            end
        end
        if 0 < k then
            for H = height, k, -1 do
                if TempImgData[W][H][1] == 255 and TempImgData[W][H][2] == 255 and TempImgData[W][H][3] == 255 then
                    BaiDianZuoBiao[n] = { W, H }
                    n = n + 1
                    break
                end
            end
        end
    end
    local XinBaiDianZuoBiao = {}
    local JiLuMianJi = {}
    local iLeft, iTop, iRight, iBottom, dThetaRad, CenterX, CenterY, TempX, TempY, ddX, ddY
    local size = width + height + 4
    k = 1
    for i = -angle, angle, istep do
        dThetaRad = (i * 2 + -i) * PI / 180
        iLeft = size
        iTop = size
        iRight = 1
        iBottom = 1
        for n = 1, #BaiDianZuoBiao do
            CenterX = math.floor(BaiDianZuoBiao[n][1] - (width + 2) / 2)
            CenterY = math.floor(BaiDianZuoBiao[n][2] - (height + 2) / 2)
            TempX = CenterX * math.cos(-dThetaRad) + CenterY * math.sin(-dThetaRad) + 0.4
            TempY = CenterY * math.cos(-dThetaRad) - CenterX * math.sin(-dThetaRad) + 0.4
            ddX = math.floor(TempX + size / 2 + 1)
            ddY = math.floor(TempY + size / 2 + 1)
            XinBaiDianZuoBiao[n] = { ddX, ddY }
            if iLeft > XinBaiDianZuoBiao[n][1] then
                iLeft = XinBaiDianZuoBiao[n][1]
            end
            if iRight < XinBaiDianZuoBiao[n][1] then
                iRight = XinBaiDianZuoBiao[n][1]
            end
            if iTop > XinBaiDianZuoBiao[n][2] then
                iTop = XinBaiDianZuoBiao[n][2]
            end
            if iBottom < XinBaiDianZuoBiao[n][2] then
                iBottom = XinBaiDianZuoBiao[n][2]
            end
        end
        JiLuMianJi[k] = {
            i,
            iLeft,
            iTop,
            iRight,
            iBottom,
            (iRight - iLeft + 1) * (iBottom - iTop + 1) + (iRight - iLeft + 1)
        }
        k = k + 1
    end
    i = size * size
    n = 0
    for k = 1, #JiLuMianJi do
        if i > JiLuMianJi[k][6] then
            i = JiLuMianJi[k][6]
            n = JiLuMianJi[k][1]
        end
    end
    return Incise_Rotate_Ex(n, TempImgData)
end

--- 原中文 API：`TURING["切割_字符旋转纠正"]`
function TURING.Incise_CharRotateCorrect(angle, istep)
    local IncNum = #IncData
    if IncNum <= 0 then
        return
    end
    if angle == nil then
        angle = 30
    end
    if istep == nil then
        istep = 1
    end
    local W, H, n
    for n = 1, IncNum do
        local TempData1 = {}
        TempData1 = Other_pointData(IncData[n][3], IncData[n][4], IncData[n][7])
        local TempData2 = {}
        TempData2 = Incise_RotateCorrect_Ex(angle, istep, TempData1)
        local sLattice = Other_CreateLattice(TempData2)
        IncData[n][3] = #TempData2
        IncData[n][4] = #TempData2[1]
        IncData[n][7] = sLattice
    end
    return IncData
end

local function isFind(iText, iList)
    local nT = string.len(iText)
    local nL = string.len(iList)
    local i = 1
    for L = 1, nL do
        for T = i, nT do
            if string.byte(iList, L) == string.byte(iText, T) then
                i = T + 1
                break
            end
        end
    end
    if nL < i then
        return true
    else
        return false
    end
end

local function TryRemoveUtf8BOM(ret)
    if string.byte(ret, 1) == 239 and string.byte(ret, 2) == 187 and string.byte(ret, 3) == 191 then
        ret = string.char(string.byte(ret, 4, string.len(ret)))
    end
    return ret
end

local function SpecialCharacters(Characters)
    local B = {}
    for i = 1, string.len(Characters) do
        local ret = string.sub(Characters, i, i)
        if ret == "^" then
            table.insert(B, "%^")
        elseif ret == "$" then
            table.insert(B, "%$")
        elseif ret == "(" then
            table.insert(B, "%(")
        elseif ret == ")" then
            table.insert(B, "%)")
        elseif ret == "%" then
            table.insert(B, "%%")
        elseif ret == "." then
            table.insert(B, "%.")
        elseif ret == "[" then
            table.insert(B, "%[")
        elseif ret == "]" then
            table.insert(B, "%]")
        elseif ret == "*" then
            table.insert(B, "%*")
        elseif ret == "+" then
            table.insert(B, "%+")
        elseif ret == "-" then
            table.insert(B, "%-")
        elseif ret == "?" then
            table.insert(B, "%?")
        else
            table.insert(B, ret)
        end
    end
    return table.concat(B, "")
end

--- 原中文 API：`TURING["字库_加载识别字库"]`
function TURING.Lib_Load(LibPath, iText)
    local Num, k, i, n, listLib, size
    local file = io.open(LibPath, "r")
    if file ~= nil then
        if iText == nil then
            iText = ""
        end
        LibData = {}
        local data = file:read("*all")
        listLib = Split(TryRemoveUtf8BOM(data), "\r\n")
        Num = #listLib
        n = 1
        for i = 1, Num do
            if listLib[i] ~= "" then
                local list = Split(listLib[i], "|")
                if string.find(iText, SpecialCharacters(list[1])) ~= nil or iText == "" then
                    if 3 < #list then
                        local One = {}
                        for k = 1, #list - 2 do
                            table.insert(One, list[k])
                        end
                        list[1] = table.concat(One, "|")
                        size = Split(list[#list - 1], ",")
                    else
                        size = Split(list[2], ",")
                    end
                    LibData[n] = {
                        list[1],
                        size[1],
                        size[2],
                        list[#list]
                    }
                    n = n + 1
                end
            end
        end
        file:close()
    else
        return 0
    end
    return n - 1
end

--- 原中文 API：`TURING["字库_加载识别字库_扩展"]`
function TURING.Lib_LoadEx(listLib, iText)
    local Num, k, i, n, size
    Num = #listLib
    if Num <= 0 then
        return 0
    end
    if iText == nil then
        iText = ""
    end
    LibData = {}
    n = 1
    for i = 1, Num do
        if listLib[i] ~= "" then
            local list = Split(listLib[i], "|")
            if string.find(iText, SpecialCharacters(list[1])) ~= nil or iText == "" then
                if 3 < #list then
                    local One = {}
                    for k = 1, #list - 2 do
                        table.insert(One, list[k])
                    end
                    list[1] = table.concat(One, "|")
                    size = Split(list[#list - 1], ",")
                else
                    size = Split(list[2], ",")
                end
                LibData[n] = {
                    list[1],
                    size[1],
                    size[2],
                    list[#list]
                }
                n = n + 1
            end
        end
    end
    return n - 1
end

--- 原中文 API：`TURING["字库_加载六十四进制识别字库"]`
function TURING.Lib_LoadBase64(listLib, iText)
    local Num, k, i, n, lib, size
    Num = #listLib
    if Num <= 0 then
        return 0
    end
    if iText == nil then
        iText = ""
    end
    LibData = {}
    n = 1
    for i = 1, Num do
        if listLib[i] ~= "" then
            local list = Split(listLib[i], "|")
            if string.find(iText, SpecialCharacters(list[1])) ~= nil or iText == "" then
                if 3 < #list then
                    local One = {}
                    for k = 1, #list - 2 do
                        table.insert(One, list[k])
                    end
                    list[1] = table.concat(One, "|")
                    size = Split(list[#list - 1], ",")
                else
                    size = Split(list[2], ",")
                end
                lib = TURING.Math_Base64toBIN(list[#list])
                lib = string.sub(lib, string.len(lib) - size[1] * size[2] + 1, string.len(lib))
                LibData[n] = {
                    list[1],
                    size[1],
                    size[2],
                    lib
                }
                n = n + 1
            end
        end
    end
    return n - 1
end

--- 原中文 API：`TURING["字库_加载十六进制识别字库_扩展"]`
function TURING.Lib_LoadExS(listLib, iText)
    local Num, k, i, n, lib, size
    Num = #listLib
    if Num <= 0 then
        return 0
    end
    if iText == nil then
        iText = ""
    end
    LibData = {}
    n = 1
    for i = 1, Num do
        if listLib[i] ~= "" then
            local list = Split(listLib[i], "|")
            if string.find(iText, SpecialCharacters(list[1])) ~= nil or iText == "" then
                if 3 < #list then
                    local One = {}
                    for k = 1, #list - 2 do
                        table.insert(One, list[k])
                    end
                    list[1] = table.concat(One, "|")
                    size = Split(list[#list - 1], ",")
                else
                    size = Split(list[2], ",")
                end
                lib = TURING.Math_HEXtoBIN(list[#list])
                lib = string.sub(lib, string.len(lib) - size[1] * size[2] + 1, string.len(lib))
                LibData[n] = {
                    list[1],
                    size[1],
                    size[2],
                    lib
                }
                n = n + 1
            end
        end
    end
    return n - 1
end

--- 原中文 API：`TURING["字库_加载十六进制识别字库_单个"]`
function TURING.Lib_LoadExC(LibText)
    local k, lib, size
    if LibText == nil or LibText == "" then
        return 0
    end
    LibData = {}
    local list = Split(LibText, "|")
    if 3 < #list then
        local One = {}
        for k = 1, #list - 2 do
            table.insert(One, list[k])
        end
        list[1] = table.concat(One, "|")
        size = Split(list[#list - 1], ",")
    else
        size = Split(list[2], ",")
    end
    lib = TURING.Math_HEXtoBIN(list[#list])
    lib = string.sub(lib, string.len(lib) - size[1] * size[2] + 1, string.len(lib))
    LibData[1] = {
        list[1],
        size[1],
        size[2],
        lib
    }
    return 1
end

--- 原中文 API：`TURING["字库_二进制转十六进制"]`
function TURING.Lib_BINtoHEX(listLib)
    local Num, k, i, n
    Num = #listLib
    if Num <= 0 then
        return 0
    end
    local libs = {}
    n = 1
    for i = 1, Num do
        if listLib[i] ~= "" then
            local list = Split(listLib[i], "|")
            if 3 < #list then
                local One = {}
                for k = 1, #list - 2 do
                    table.insert(One, list[k])
                end
                list[1] = table.concat(One, "|")
                list[2] = list[#list - 1]
            end
            libs[n] = list[1] .. "|" .. list[2] .. "|" .. TURING.Math_BINtoHEX(list[#list])
            n = n + 1
        end
    end
    return libs
end

--- 原中文 API：`TURING["字库_字符切割数据"]`
function TURING.Lib_OneCharData(Num)
    local n, k
    n = #IncData
    if n <= 0 then
        return ""
    end
    if Num == nil or Num < 1 then
        Num = 1
    end
    k = Num
    if k < 1 then
        k = 1
    end
    if n < k then
        k = n
    end
    local IncW = IncData[k][3]
    local IncH = IncData[k][4]
    return IncW .. "," .. IncH .. "|" .. IncData[k][7]
end

local function Bytes(FileName)
    local size = 0
    pcall(function()
        local f = io.open(FileName, "r")
        if f == nil then
            return nil
        end
        size = f:seek("end")
        f:close()
    end)
    return size
end

--- 原中文 API：`TURING["字库_存储识别字库"]`
function TURING.Lib_Save(Text, Lattice, FileName)
    pcall(function()
        local f = io.open(FileName, "a")
        if f == nil then
            return false
        end
        local LibText
        LibText = fileSize(FileName)
        if 0 < LibText then
            LibText = "\r\n" .. Text .. "|" .. Lattice
        else
            LibText = Text .. "|" .. Lattice
        end
        local arg = { LibText }
        for i, v in ipairs(arg) do
            f:write(tostring(v))
        end
        f:close()
    end)
    return true
end

--- 原中文 API：`TURING["识别"]`
function TURING.OCR(Similar, Model, Interval)
    local results, IncNum, LibNum, k, i, w, h
    local JieGuo = {}
    local ZuoBiao = {}
    local a = 1
    local kk = 1
    if Similar == nil then
        Similar = 0
    end
    if Model == nil then
        Model = 0
    end
    if Interval == nil then
        Interval = 0
    end
    local ChrData = {}
    local ZhanBi = {}
    IncNum = #IncData
    if IncNum <= 0 then
        return ""
    end
    for k = 1, IncNum do
        local OcrData = {}
        local ii = 1
        local nMax = 1
        local ZBI = 0
        local IncW = IncData[k][3]
        local IncH = IncData[k][4]
        local ysIncW = IncData[k][5]
        local ysIncH = IncData[k][6]
        LibNum = #LibData
        if LibNum <= 0 then
            return ""
        end
        for i = 1, LibNum do
            if LibData[i][4] ~= "" then
                local LibW = LibData[i][2]
                local LibH = LibData[i][3]
                if not (math.abs(LibW - IncW) > (LibW + IncW) / 2) and not (math.abs(LibH - IncH) > (LibH + IncH) / 2) then
                    local IncZ = 1
                    local LibZ = 1
                    local m = 1
                    local Num = 0
                    for w = 1, LibW do
                        if w > IncW then
                            break
                        end
                        for h = 1, LibH do
                            if h > IncH then
                                break
                            end
                            if string.sub(IncData[k][7], IncZ, IncZ) == string.sub(LibData[i][4], LibZ, LibZ) then
                                Num = Num + 1
                            end
                            IncZ = IncZ + 1
                            LibZ = LibZ + 1
                        end
                        IncZ = w * IncH + 1
                        LibZ = w * LibH + 1
                    end
                    local bfBI = NewRound(Num / (LibW * LibH) * 100)
                    local yxBI = NewRound(Num / (IncW * IncH) * 100)
                    OcrData[ii] = {
                        LibData[i][1],
                        IncData[k][1],
                        IncData[k][2],
                        IncW,
                        IncH,
                        ysIncW,
                        ysIncH,
                        Num,
                        bfBI,
                        yxBI
                    }
                    if 100 <= OcrData[ii][9] and 100 <= OcrData[ii][10] then
                        nMax = ii
                        break
                    end
                    if ZBI < OcrData[ii][8] + OcrData[ii][9] + OcrData[ii][10] then
                        nMax = ii
                        ZBI = OcrData[ii][8] + OcrData[ii][9] + OcrData[ii][10]
                    end
                    ii = ii + 1
                end
            end
        end
        LibNum = nMax
        local BaiFenShu
        if 0 < #OcrData and Similar <= OcrData[LibNum][9] and Similar <= OcrData[LibNum][10] then
            if OcrData[LibNum][9] > OcrData[LibNum][10] then
                BaiFenShu = OcrData[LibNum][10]
            else
                BaiFenShu = OcrData[LibNum][9]
            end
            if 2 <= Model and Model <= 6 and Model ~= 4 and 0 < Interval then
                ChrData[kk] = {
                    OcrData[LibNum][1],
                    OcrData[LibNum][2],
                    OcrData[LibNum][3],
                    OcrData[LibNum][4],
                    OcrData[LibNum][5],
                    OcrData[LibNum][6],
                    OcrData[LibNum][7],
                    BaiFenShu
                }
                if 1 < kk then
                    if Interval >= math.abs(ChrData[kk][2] - (ChrData[kk - 1][2] + ChrData[kk - 1][4])) and 0 >= ChrData[kk][3] - (ChrData[kk - 1][3] + ChrData[kk - 1][5]) then
                        JieGuo[a] = JieGuo[a] .. ChrData[kk][1]
                    else
                        ZuoBiao[a] = JieGuo[a] .. "," .. ZuoBiao[a]
                        if Model == 3 or Model == 6 then
                            ZhanBi[a] = ZuoBiao[a] .. "," .. ZhanBi[a]
                        end
                        a = a + 1
                        JieGuo[a] = ChrData[kk][1]
                        if Model == 5 then
                            ZuoBiao[a] = ChrData[kk][2] ..
                                "," .. ChrData[kk][3] .. "," .. ChrData[kk][4] .. "," .. ChrData[kk][5]
                        elseif Model == 6 then
                            ZuoBiao[a] = ChrData[kk][2] ..
                                "," ..
                                ChrData[kk][3] ..
                                "," ..
                                ChrData[kk][4] .. "," .. ChrData[kk][5] .. "," .. ChrData[kk][6] .. "," .. ChrData[kk]
                                [7]
                        else
                            ZuoBiao[a] = ChrData[kk][2] .. "," .. ChrData[kk][3]
                        end
                        if Model == 3 or Model == 6 then
                            ZhanBi[a] = ChrData[kk][8]
                        end
                    end
                else
                    JieGuo[a] = ChrData[kk][1]
                    if Model == 5 then
                        ZuoBiao[a] = ChrData[kk][2] ..
                            "," .. ChrData[kk][3] .. "," .. ChrData[kk][4] .. "," .. ChrData[kk][5]
                    elseif Model == 6 then
                        ZuoBiao[a] = ChrData[kk][2] ..
                            "," ..
                            ChrData[kk][3] ..
                            "," ..
                            ChrData[kk][4] .. "," .. ChrData[kk][5] .. "," .. ChrData[kk][6] .. "," .. ChrData[kk][7]
                    else
                        ZuoBiao[a] = ChrData[kk][2] .. "," .. ChrData[kk][3]
                    end
                    if Model == 3 or Model == 6 then
                        ZhanBi[a] = ChrData[kk][8]
                    end
                end
                kk = kk + 1
            else
                JieGuo[a] = OcrData[LibNum][1]
                if Model == 1 then
                    ZuoBiao[a] = OcrData[LibNum][2] .. "," .. OcrData[LibNum][3]
                elseif 2 <= Model then
                    if Model == 5 then
                        ZuoBiao[a] = JieGuo[a] ..
                            "," ..
                            OcrData[LibNum][2] ..
                            "," .. OcrData[LibNum][3] .. "," .. OcrData[LibNum][4] .. "," .. OcrData[LibNum][5]
                    elseif Model == 6 then
                        ZuoBiao[a] = JieGuo[a] ..
                            "," ..
                            OcrData[LibNum][2] ..
                            "," ..
                            OcrData[LibNum][3] ..
                            "," ..
                            OcrData[LibNum][4] ..
                            "," .. OcrData[LibNum][5] .. "," .. ChrData[kk][6] .. "," .. ChrData[kk]
                            [7]
                    else
                        ZuoBiao[a] = JieGuo[a] .. "," .. OcrData[LibNum][2] .. "," .. OcrData[LibNum][3]
                    end
                    if Model == 3 or Model == 6 then
                        ZhanBi[a] = ZuoBiao[a] .. "," .. BaiFenShu
                    end
                end
                a = a + 1
            end
        end
        if k == IncNum and 2 <= Model and Model <= 6 and Model ~= 4 and 0 < Interval then
            if ZuoBiao == nil then
                return ""
            end
            if ZuoBiao[a] == nil then
                return ""
            end
            if JieGuo[a] == nil then
                return ""
            end
            ZuoBiao[a] = JieGuo[a] .. "," .. ZuoBiao[a]
            if Model == 3 or Model == 6 then
                ZhanBi[a] = ZuoBiao[a] .. "," .. ZhanBi[a]
            end
        end
    end
    if 1 < a or 1 < kk then
        if Model == 0 then
            return table.concat(JieGuo, "")
        elseif Model == 1 then
            return table.concat(JieGuo, "") .. "|" .. table.concat(ZuoBiao, "|")
        elseif Model == 2 then
            return table.concat(ZuoBiao, "|")
        elseif Model == 3 then
            return table.concat(ZhanBi, "|")
        elseif Model == 4 then
            return table.concat(JieGuo, "|")
        elseif Model == 5 then
            return table.concat(ZuoBiao, "|")
        elseif Model == 6 then
            return table.concat(ZhanBi, "|")
        else
            return table.concat(JieGuo, "|")
        end
    else
        return ""
    end
end

--- 原中文 API：`TURING["图灵识别"]`
function TURING.OCR_TURING(Model)
    local LaiYuan = Model[1]
    local LvJing = Model[2]
    local QieGe = Model[3]
    local ZiKu = Model[4]
    local ShiBie = Model[5]
    if LaiYuan["屏幕范围"] ~= nil then
        TURING.Pixel_FromScreen(LaiYuan["屏幕范围"][1], LaiYuan["屏幕范围"][2], LaiYuan["屏幕范围"][3], LaiYuan["屏幕范围"][4])
    else
        return ""
    end
    for i = 1, #LvJing do
        if LvJing[i]["二值化"] ~= nil then
            TURING.Filter_Binaryzation(LvJing[i]["二值化"][1])
        elseif LvJing[i]["灰度"] ~= nil then
            TURING.Filter_Gray(LvJing[i]["灰度"][1])
        elseif LvJing[i]["色调分离"] ~= nil then
            TURING.Filter_Posterization(LvJing[i]["色调分离"][1])
        elseif LvJing[i]["通道图层"] ~= nil then
            TURING.Filter_ChannelLayer(LvJing[i]["通道图层"][1])
        elseif LvJing[i]["清除杂点"] ~= nil then
            TURING.Filter_Despeckle(LvJing[i]["清除杂点"][1])
        elseif LvJing[i]["获取轮廓"] ~= nil then
            TURING.Filter_Outline(LvJing[i]["获取轮廓"][1], LvJing[i]["获取轮廓"][2], LvJing[i]["获取轮廓"][3], LvJing[i]["获取轮廓"][4])
        elseif LvJing[i]["提取色块"] ~= nil then
            TURING.Filter_ExtractBlock(LvJing[i]["提取色块"][1], LvJing[i]["提取色块"][2], LvJing[i]["提取色块"][3])
        elseif LvJing[i]["颠倒颜色"] ~= nil then
            TURING.Filter_InverseColor(LvJing[i]["颠倒颜色"][1])
        elseif LvJing[i]["膨胀腐蚀"] ~= nil then
            TURING.Filter_DilationErosion(LvJing[i]["膨胀腐蚀"][1])
        elseif LvJing[i]["等比放大"] ~= nil then
            TURING.Filter_ZoomIn(LvJing[i]["等比放大"][1], LvJing[i]["等比放大"][2])
        elseif LvJing[i]["等比缩小"] ~= nil then
            TURING.Filter_ZoomOut(LvJing[i]["等比缩小"][1], LvJing[i]["等比缩小"][2])
        elseif LvJing[i]["缩放归一化"] ~= nil then
            TURING.Filter_ZoomOne(LvJing[i]["缩放归一化"][1], LvJing[i]["缩放归一化"][2])
        elseif LvJing[i]["缩放自适应"] ~= nil then
            TURING.Filter_ZoomAdaptive(LvJing[i]["缩放自适应"][1], LvJing[i]["缩放自适应"][2])
        elseif LvJing[i]["固定旋转"] ~= nil then
            TURING.Filter_Rotate(LvJing[i]["固定旋转"][1])
        elseif LvJing[i]["延伸裁剪"] ~= nil then
            TURING.Filter_Tailor(LvJing[i]["延伸裁剪"][1], LvJing[i]["延伸裁剪"][2], LvJing[i]["延伸裁剪"][3], LvJing[i]["延伸裁剪"][4])
        elseif LvJing[i]["颜色选留"] ~= nil then
            TURING.Filter_ColorChoose(LvJing[i]["颜色选留"][1])
        elseif LvJing[i]["固定柔化"] ~= nil then
            TURING.Filter_Softness(LvJing[i]["固定柔化"][1])
        elseif LvJing[i]["电影底片"] ~= nil then
            TURING.Filter_Negative()
        elseif LvJing[i]["固定镜像"] ~= nil then
            TURING.Filter_Mirror(LvJing[i]["固定镜像"][1])
        else
            return ""
        end
    end
    if QieGe["固定位置"] ~= nil then
        TURING.Incise_FixedLocation(QieGe["固定位置"][1], QieGe["固定位置"][2], QieGe["固定位置"][3], QieGe["固定位置"][4],
            QieGe["固定位置"][5], QieGe["固定位置"][6], QieGe["固定位置"][7], QieGe["固定位置"][8])
    elseif QieGe["随机方位"] ~= nil then
        TURING.Incise_RandomOrientation(QieGe["随机方位"][1], QieGe["随机方位"][2], QieGe["随机方位"][3])
    elseif QieGe["连通区域"] ~= nil then
        TURING.Incise_ConnectedArea(QieGe["连通区域"][1], QieGe["连通区域"][2], QieGe["连通区域"][3])
    elseif QieGe["范围投影"] ~= nil then
        TURING.Incise_ScopeAisle(QieGe["范围投影"][1], QieGe["范围投影"][2], QieGe["范围投影"][3], QieGe["范围投影"][4])
    else
        return ""
    end
    if ZiKu["字库文件"] ~= nil then
        TURING.Lib_Load(ZiKu["字库文件"][1], ZiKu["字库文件"][2])
    elseif ZiKu["字库数组"] ~= nil then
        TURING.Lib_LoadEx(ZiKu["字库数组"][1], ZiKu["字库数组"][2])
    elseif ZiKu["六十四进制字库数组"] ~= nil then
        TURING.Lib_LoadBase64(ZiKu["六十四进制字库数组"][1], ZiKu["六十四进制字库数组"][2])
    elseif ZiKu["十六进制字库数组"] ~= nil then
        TURING.Lib_LoadExS(ZiKu["十六进制字库数组"][1], ZiKu["十六进制字库数组"][2])
    elseif ZiKu["十六进制字库文本"] ~= nil then
        TURING.Lib_LoadExC(ZiKu["十六进制字库文本"][1])
    else
        return ""
    end
    if ShiBie ~= nil then
        return TURING.OCR(ShiBie[1], ShiBie[2], ShiBie[3])
    else
        return ""
    end
end

--- 原中文 API：`TURING["识别_返回绝对坐标"]`
function TURING.OCR_AbsCoords(JieGuo)
    local iLeft, iTop, iRight, iBottom
    iLeft = R_Left
    iTop = R_Top
    iRight = R_Right
    iBottom = R_Bottom
    R_Left = 0
    R_Top = 0
    R_Right = 0
    R_Bottom = 0
    if JieGuo == nil then
        return ""
    end
    local Ret = {}
    local List = Split(JieGuo, "|")
    if 1 < #List then
        Ret = Split(List[2], ",")
    elseif #List == 1 then
        Ret = Split(List[1], ",")
    end
    local Results = {}
    if 1 < #Ret then
        local Num = #List
        if #Ret == 2 then
            for i = 1, Num do
                if List[i + 1] == nil then
                    break
                end
                Results = Split(List[i + 1], ",")
                if R_Model == 1 then
                    List[i + 1] = {
                        iLeft + (iRight - iLeft) - Results[2],
                        iTop + Results[1]
                    }
                else
                    List[i + 1] = {
                        iLeft + Results[1],
                        iTop + Results[2]
                    }
                end
            end
        elseif #Ret == 3 then
            for i = 1, Num do
                if List[i] == nil then
                    break
                end
                Results = Split(List[i], ",")
                if R_Model == 1 then
                    List[i] = {
                        Results[1],
                        iLeft + (iRight - iLeft) - Results[3],
                        iTop + Results[2]
                    }
                else
                    List[i] = {
                        Results[1],
                        iLeft + Results[2],
                        iTop + Results[3]
                    }
                end
            end
        elseif #Ret == 4 then
            for i = 1, Num do
                if List[i] == nil then
                    break
                end
                Results = Split(List[i], ",")
                if R_Model == 1 then
                    List[i] = {
                        Results[1],
                        iLeft + (iRight - iLeft) - Results[3],
                        iTop + Results[2],
                        Results[4]
                    }
                else
                    List[i] = {
                        Results[1],
                        iLeft + Results[2],
                        iTop + Results[3],
                        Results[4]
                    }
                end
            end
        elseif #Ret == 5 then
            for i = 1, Num do
                if List[i] == nil then
                    break
                end
                Results = Split(List[i], ",")
                if R_Model == 1 then
                    List[i] = {
                        Results[1],
                        iLeft + (iRight - iLeft) - Results[3],
                        iTop + Results[2],
                        Results[4],
                        Results[5]
                    }
                else
                    List[i] = {
                        Results[1],
                        iLeft + Results[2],
                        iTop + Results[3],
                        Results[4],
                        Results[5]
                    }
                end
            end
        elseif #Ret == 8 then
            for i = 1, Num do
                if List[i] == nil then
                    break
                end
                Results = Split(List[i], ",")
                if R_Model == 1 then
                    List[i] = {
                        Results[1],
                        iLeft + (iRight - iLeft) - Results[3],
                        iTop + Results[2],
                        Results[4],
                        Results[5],
                        Results[6],
                        Results[7],
                        Results[8]
                    }
                else
                    List[i] = {
                        Results[1],
                        iLeft + Results[2],
                        iTop + Results[3],
                        Results[4],
                        Results[5],
                        Results[6],
                        Results[7],
                        Results[8]
                    }
                end
            end
        end
    end
    R_Model = 0
    Results = List
    return Results
end

--- 原中文 API：`TURING["识别返回绝对坐标"]`
function TURING.OCR_AbsCoordinates(JieGuo)
    local iLeft, iTop, iRight, iBottom
    iLeft = R_Left
    iTop = R_Top
    iRight = R_Right
    iBottom = R_Bottom
    R_Left = 0
    R_Top = 0
    R_Right = 0
    R_Bottom = 0
    if JieGuo == nil then
        return ""
    end
    local Ret = {}
    local List = Split(JieGuo, "|")
    if 1 < #List then
        Ret = Split(List[2], ",")
    elseif #List == 1 then
        Ret = Split(List[1], ",")
    end
    local Results = {}
    if 1 < #Ret then
        local Num = #List
        if #Ret == 2 then
            for i = 1, Num do
                if List[i + 1] == nil then
                    break
                end
                Results = Split(List[i + 1], ",")
                if R_Model == 1 then
                    List[i + 1] = iLeft + (iRight - iLeft) - Results[2] .. "," .. iTop + Results[1]
                else
                    List[i + 1] = iLeft + Results[1] .. "," .. iTop + Results[2]
                end
            end
        elseif #Ret == 3 then
            for i = 1, Num do
                if List[i] == nil then
                    break
                end
                Results = Split(List[i], ",")
                if R_Model == 1 then
                    List[i] = Results[1] .. "," .. iLeft + (iRight - iLeft) - Results[3] .. "," .. iTop + Results[2]
                else
                    List[i] = Results[1] .. "," .. iLeft + Results[2] .. "," .. iTop + Results[3]
                end
            end
        elseif #Ret == 4 then
            for i = 1, Num do
                if List[i] == nil then
                    break
                end
                Results = Split(List[i], ",")
                if R_Model == 1 then
                    List[i] = Results[1] ..
                        "," .. iLeft + (iRight - iLeft) - Results[3] .. "," .. iTop + Results[2] .. "," .. Results[4]
                else
                    List[i] = Results[1] .. "," .. iLeft + Results[2] .. "," .. iTop + Results[3] .. "," .. Results[4]
                end
            end
        elseif #Ret == 5 then
            for i = 1, Num do
                if List[i] == nil then
                    break
                end
                Results = Split(List[i], ",")
                if R_Model == 1 then
                    List[i] = Results[1] ..
                        "," ..
                        iLeft + (iRight - iLeft) - Results[3] ..
                        "," .. iTop + Results[2] .. "," .. Results[4] .. "," .. Results[5]
                else
                    List[i] = Results[1] ..
                        "," .. iLeft + Results[2] .. "," .. iTop + Results[3] .. "," .. Results[4] .. "," .. Results[5]
                end
            end
        elseif #Ret == 8 then
            for i = 1, Num do
                if List[i] == nil then
                    break
                end
                Results = Split(List[i], ",")
                if R_Model == 1 then
                    List[i] = Results[1] ..
                        "," ..
                        iLeft + (iRight - iLeft) - Results[3] ..
                        "," ..
                        iTop + Results[2] ..
                        "," ..
                        Results[4] .. "," .. Results[5] .. "," .. Results[6] .. "," .. Results[7] .. "," .. Results
                        [8]
                else
                    List[i] = Results[1] ..
                        "," ..
                        iLeft + Results[2] ..
                        "," ..
                        iTop + Results[3] ..
                        "," ..
                        Results[4] .. "," .. Results[5] .. "," .. Results[6] .. "," .. Results[7] .. "," .. Results
                        [8]
                end
            end
        end
    end
    R_Model = 0
    Results = List
    return Results
end

--- 原中文 API：`TURING["绘图_图像数据备份"]`
function TURING.Draw_Backups(index)
    local W, H
    local width = #ImgData
    if width <= 0 then
        return
    end
    local height = #ImgData[1]
    if height <= 0 then
        return
    end
    if index == 1 then
        BakData1 = {}
        for W = 1, width do
            BakData1[W] = {}
            for H = 1, height do
                BakData1[W][H] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
            end
        end
    elseif index == 2 then
        BakData2 = {}
        for W = 1, width do
            BakData2[W] = {}
            for H = 1, height do
                BakData2[W][H] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
            end
        end
    elseif index == 3 then
        BakData3 = {}
        for W = 1, width do
            BakData3[W] = {}
            for H = 1, height do
                BakData3[W][H] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
            end
        end
    elseif index == 4 then
        BakData4 = {}
        for W = 1, width do
            BakData4[W] = {}
            for H = 1, height do
                BakData4[W][H] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
            end
        end
    elseif index == 5 then
        BakData5 = {}
        for W = 1, width do
            BakData5[W] = {}
            for H = 1, height do
                BakData5[W][H] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
            end
        end
    elseif index == 6 then
        BakData6 = {}
        for W = 1, width do
            BakData6[W] = {}
            for H = 1, height do
                BakData6[W][H] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
            end
        end
    elseif index == 7 then
        BakData7 = {}
        for W = 1, width do
            BakData7[W] = {}
            for H = 1, height do
                BakData7[W][H] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
            end
        end
    elseif index == 8 then
        BakData8 = {}
        for W = 1, width do
            BakData8[W] = {}
            for H = 1, height do
                BakData8[W][H] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
            end
        end
    elseif index == 9 then
        BakData9 = {}
        for W = 1, width do
            BakData9[W] = {}
            for H = 1, height do
                BakData9[W][H] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
            end
        end
    else
        BakData0 = {}
        for W = 1, width do
            BakData0[W] = {}
            for H = 1, height do
                BakData0[W][H] = {
                    ImgData[W][H][1],
                    ImgData[W][H][2],
                    ImgData[W][H][3]
                }
            end
        end
    end
end

--- 原中文 API：`TURING["绘图_图像数据恢复"]`
function TURING.Draw_Recover(index)
    local W, H, width, height
    if index == 1 then
        width = #BakData1
        if width <= 0 then
            return
        end
        height = #BakData1[1]
        if height <= 0 then
            return
        end
        ImgData = {}
        for W = 1, width do
            ImgData[W] = {}
            for H = 1, height do
                ImgData[W][H] = {
                    BakData1[W][H][1],
                    BakData1[W][H][2],
                    BakData1[W][H][3]
                }
            end
        end
    elseif index == 2 then
        width = #BakData2
        height = #BakData2[1]
        if width <= 0 or height <= 0 then
            return
        end
        ImgData = {}
        for W = 1, width do
            ImgData[W] = {}
            for H = 1, height do
                ImgData[W][H] = {
                    BakData2[W][H][1],
                    BakData2[W][H][2],
                    BakData2[W][H][3]
                }
            end
        end
    elseif index == 3 then
        width = #BakData3
        height = #BakData3[1]
        if width <= 0 or height <= 0 then
            return
        end
        ImgData = {}
        for W = 1, width do
            ImgData[W] = {}
            for H = 1, height do
                ImgData[W][H] = {
                    BakData3[W][H][1],
                    BakData3[W][H][2],
                    BakData3[W][H][3]
                }
            end
        end
    elseif index == 4 then
        width = #BakData4
        height = #BakData4[1]
        if width <= 0 or height <= 0 then
            return
        end
        ImgData = {}
        for W = 1, width do
            ImgData[W] = {}
            for H = 1, height do
                ImgData[W][H] = {
                    BakData4[W][H][1],
                    BakData4[W][H][2],
                    BakData4[W][H][3]
                }
            end
        end
    elseif index == 5 then
        width = #BakData5
        height = #BakData5[1]
        if width <= 0 or height <= 0 then
            return
        end
        ImgData = {}
        for W = 1, width do
            ImgData[W] = {}
            for H = 1, height do
                ImgData[W][H] = {
                    BakData5[W][H][1],
                    BakData5[W][H][2],
                    BakData5[W][H][3]
                }
            end
        end
    elseif index == 6 then
        width = #BakData6
        height = #BakData6[1]
        if width <= 0 or height <= 0 then
            return
        end
        ImgData = {}
        for W = 1, width do
            ImgData[W] = {}
            for H = 1, height do
                ImgData[W][H] = {
                    BakData6[W][H][1],
                    BakData6[W][H][2],
                    BakData6[W][H][3]
                }
            end
        end
    elseif index == 7 then
        width = #BakData7
        height = #BakData7[1]
        if width <= 0 or height <= 0 then
            return
        end
        ImgData = {}
        for W = 1, width do
            ImgData[W] = {}
            for H = 1, height do
                ImgData[W][H] = {
                    BakData7[W][H][1],
                    BakData7[W][H][2],
                    BakData7[W][H][3]
                }
            end
        end
    elseif index == 8 then
        width = #BakData8
        height = #BakData8[1]
        if width <= 0 or height <= 0 then
            return
        end
        ImgData = {}
        for W = 1, width do
            ImgData[W] = {}
            for H = 1, height do
                ImgData[W][H] = {
                    BakData8[W][H][1],
                    BakData8[W][H][2],
                    BakData8[W][H][3]
                }
            end
        end
    elseif index == 9 then
        width = #BakData9
        height = #BakData9[1]
        if width <= 0 or height <= 0 then
            return
        end
        ImgData = {}
        for W = 1, width do
            ImgData[W] = {}
            for H = 1, height do
                ImgData[W][H] = {
                    BakData9[W][H][1],
                    BakData9[W][H][2],
                    BakData9[W][H][3]
                }
            end
        end
    else
        width = #BakData0
        height = #BakData0[1]
        if width <= 0 or height <= 0 then
            return
        end
        ImgData = {}
        for W = 1, width do
            ImgData[W] = {}
            for H = 1, height do
                ImgData[W][H] = {
                    BakData0[W][H][1],
                    BakData0[W][H][2],
                    BakData0[W][H][3]
                }
            end
        end
    end
end

local function num_to_hex_str(value)
    return string.format("%02X", value)
end

--- 原中文 API：`TURING["图色_获取指定点颜色"]`
function TURING.GetPixelColor(x, y, model)
    if x == nil then
        x = 0
    end
    if y == nil then
        y = 0
    end
    if model == nil then
        model = 0
    end
    local hex
    if model == 2 then
        local width = #ImgData
        if width <= 0 then
            return ""
        end
        local height = #ImgData[1]
        if height <= 0 then
            return ""
        end
        if 0 <= x and x < width and 0 <= y and y < height then
            hex = num_to_hex_str(ImgData[x + 1][y + 1][1])
            hex = hex .. num_to_hex_str(ImgData[x + 1][y + 1][2])
            hex = hex .. num_to_hex_str(ImgData[x + 1][y + 1][3])
            return hex
        else
            return ""
        end
    else
        local r, g, b = colorToRGB(getPixelColor(x, y))
        hex = num_to_hex_str(r)
        hex = hex .. num_to_hex_str(g)
        hex = hex .. num_to_hex_str(b)
        return hex
    end
end

--- 原中文 API：`TURING["图色_获取圆边点颜色"]`
function TURING.GetRoundPointColor(x0, y0, Radius, Degree)
    local width = #ImgData
    if width <= 0 then
        return ""
    end
    local height = #ImgData[1]
    if height <= 0 then
        return ""
    end
    if Radius == nil then
        Radius = 0
    end
    if Degree == nil then
        Degree = 0
    end
    local x2 = NewRound(x0 + 1 - Radius * math.sin(math.rad(Degree)))
    local y2 = NewRound(y0 + 1 - Radius * math.cos(math.rad(Degree)))
    if 0 <= x2 and width >= x2 and 0 <= y2 and height >= y2 then
        local hex = num_to_hex_str(ImgData[x2][y2][1])
        hex = hex .. num_to_hex_str(ImgData[x2][y2][2])
        hex = hex .. num_to_hex_str(ImgData[x2][y2][3])
        return {
            hex,
            x2 - 1,
            y2 - 1
        }
    else
        return ""
    end
end

--- 原中文 API：`TURING["二进制转十六进制"]`
function TURING.Math_BINtoHEX(BinStr)
    local i, ret, str
    local n = string.len(BinStr) % 4
    if n ~= 0 then
        str = string.rep("0", 4 - n) .. BinStr
    else
        str = BinStr
    end
    local One = {}
    for i = 1, string.len(str), 4 do
        ret = string.sub(str, i, i + 3)
        if ret == "0000" then
            table.insert(One, "0")
        elseif ret == "0001" then
            table.insert(One, "1")
        elseif ret == "0010" then
            table.insert(One, "2")
        elseif ret == "0011" then
            table.insert(One, "3")
        elseif ret == "0100" then
            table.insert(One, "4")
        elseif ret == "0101" then
            table.insert(One, "5")
        elseif ret == "0110" then
            table.insert(One, "6")
        elseif ret == "0111" then
            table.insert(One, "7")
        elseif ret == "1000" then
            table.insert(One, "8")
        elseif ret == "1001" then
            table.insert(One, "9")
        elseif ret == "1010" then
            table.insert(One, "A")
        elseif ret == "1011" then
            table.insert(One, "B")
        elseif ret == "1100" then
            table.insert(One, "C")
        elseif ret == "1101" then
            table.insert(One, "D")
        elseif ret == "1110" then
            table.insert(One, "E")
        elseif ret == "1111" then
            table.insert(One, "F")
        end
    end
    return table.concat(One, "")
end

--- 原中文 API：`TURING["十六进制转二进制"]`
function TURING.Math_HEXtoBIN(HexStr)
    local i, ret, str
    str = string.upper(HexStr)
    local B = {}
    for i = 1, string.len(str) do
        ret = string.sub(str, i, i)
        if ret == "0" then
            table.insert(B, "0000")
        elseif ret == "1" then
            table.insert(B, "0001")
        elseif ret == "2" then
            table.insert(B, "0010")
        elseif ret == "3" then
            table.insert(B, "0011")
        elseif ret == "4" then
            table.insert(B, "0100")
        elseif ret == "5" then
            table.insert(B, "0101")
        elseif ret == "6" then
            table.insert(B, "0110")
        elseif ret == "7" then
            table.insert(B, "0111")
        elseif ret == "8" then
            table.insert(B, "1000")
        elseif ret == "9" then
            table.insert(B, "1001")
        elseif ret == "A" then
            table.insert(B, "1010")
        elseif ret == "B" then
            table.insert(B, "1011")
        elseif ret == "C" then
            table.insert(B, "1100")
        elseif ret == "D" then
            table.insert(B, "1101")
        elseif ret == "E" then
            table.insert(B, "1110")
        elseif ret == "F" then
            table.insert(B, "1111")
        end
    end
    return table.concat(B, "")
end

--- 原中文 API：`TURING["二进制转六十四进制"]`
function TURING.Math_BINtoBASE64(BinStr)
    local i, ret, str
    local n = string.len(BinStr) % 6
    if n ~= 0 then
        str = string.rep("0", 6 - n) .. BinStr
    else
        str = BinStr
    end
    local One = {}
    for i = 1, string.len(str), 6 do
        ret = string.sub(str, i, i + 5)
        if ret == "000000" then
            table.insert(One, "0")
        elseif ret == "000001" then
            table.insert(One, "1")
        elseif ret == "000010" then
            table.insert(One, "2")
        elseif ret == "000011" then
            table.insert(One, "3")
        elseif ret == "000100" then
            table.insert(One, "4")
        elseif ret == "000101" then
            table.insert(One, "5")
        elseif ret == "000110" then
            table.insert(One, "6")
        elseif ret == "000111" then
            table.insert(One, "7")
        elseif ret == "001000" then
            table.insert(One, "8")
        elseif ret == "001001" then
            table.insert(One, "9")
        elseif ret == "001010" then
            table.insert(One, "A")
        elseif ret == "001011" then
            table.insert(One, "B")
        elseif ret == "001100" then
            table.insert(One, "C")
        elseif ret == "001101" then
            table.insert(One, "D")
        elseif ret == "001110" then
            table.insert(One, "E")
        elseif ret == "001111" then
            table.insert(One, "F")
        elseif ret == "010000" then
            table.insert(One, "G")
        elseif ret == "010001" then
            table.insert(One, "H")
        elseif ret == "010010" then
            table.insert(One, "I")
        elseif ret == "010011" then
            table.insert(One, "J")
        elseif ret == "010100" then
            table.insert(One, "K")
        elseif ret == "010101" then
            table.insert(One, "L")
        elseif ret == "010110" then
            table.insert(One, "M")
        elseif ret == "010111" then
            table.insert(One, "N")
        elseif ret == "011000" then
            table.insert(One, "O")
        elseif ret == "011001" then
            table.insert(One, "P")
        elseif ret == "011010" then
            table.insert(One, "Q")
        elseif ret == "011011" then
            table.insert(One, "R")
        elseif ret == "011100" then
            table.insert(One, "S")
        elseif ret == "011101" then
            table.insert(One, "T")
        elseif ret == "011110" then
            table.insert(One, "U")
        elseif ret == "011111" then
            table.insert(One, "V")
        elseif ret == "100000" then
            table.insert(One, "W")
        elseif ret == "100001" then
            table.insert(One, "X")
        elseif ret == "100010" then
            table.insert(One, "Y")
        elseif ret == "100011" then
            table.insert(One, "Z")
        elseif ret == "100100" then
            table.insert(One, "a")
        elseif ret == "100101" then
            table.insert(One, "b")
        elseif ret == "100110" then
            table.insert(One, "c")
        elseif ret == "100111" then
            table.insert(One, "d")
        elseif ret == "101000" then
            table.insert(One, "e")
        elseif ret == "101001" then
            table.insert(One, "f")
        elseif ret == "101010" then
            table.insert(One, "g")
        elseif ret == "101011" then
            table.insert(One, "h")
        elseif ret == "101100" then
            table.insert(One, "i")
        elseif ret == "101101" then
            table.insert(One, "j")
        elseif ret == "101110" then
            table.insert(One, "k")
        elseif ret == "101111" then
            table.insert(One, "l")
        elseif ret == "110000" then
            table.insert(One, "m")
        elseif ret == "110001" then
            table.insert(One, "n")
        elseif ret == "110010" then
            table.insert(One, "o")
        elseif ret == "110011" then
            table.insert(One, "p")
        elseif ret == "110100" then
            table.insert(One, "q")
        elseif ret == "110101" then
            table.insert(One, "r")
        elseif ret == "110110" then
            table.insert(One, "s")
        elseif ret == "110111" then
            table.insert(One, "t")
        elseif ret == "111000" then
            table.insert(One, "u")
        elseif ret == "111001" then
            table.insert(One, "v")
        elseif ret == "111010" then
            table.insert(One, "w")
        elseif ret == "111011" then
            table.insert(One, "x")
        elseif ret == "111100" then
            table.insert(One, "y")
        elseif ret == "111101" then
            table.insert(One, "z")
        elseif ret == "111110" then
            table.insert(One, "#")
        elseif ret == "111111" then
            table.insert(One, "&")
        end
    end
    return table.concat(One, "")
end

--- 原中文 API：`TURING["六十四进制转二进制"]`
function TURING.Math_Base64toBIN(Base64Str)
    local i, ret
    local B = {}
    for i = 1, string.len(Base64Str) do
        ret = string.sub(Base64Str, i, i)
        if ret == "0" then
            table.insert(B, "000000")
        elseif ret == "1" then
            table.insert(B, "000001")
        elseif ret == "2" then
            table.insert(B, "000010")
        elseif ret == "3" then
            table.insert(B, "000011")
        elseif ret == "4" then
            table.insert(B, "000100")
        elseif ret == "5" then
            table.insert(B, "000101")
        elseif ret == "6" then
            table.insert(B, "000110")
        elseif ret == "7" then
            table.insert(B, "000111")
        elseif ret == "8" then
            table.insert(B, "001000")
        elseif ret == "9" then
            table.insert(B, "001001")
        elseif ret == "A" then
            table.insert(B, "001010")
        elseif ret == "B" then
            table.insert(B, "001011")
        elseif ret == "C" then
            table.insert(B, "001100")
        elseif ret == "D" then
            table.insert(B, "001101")
        elseif ret == "E" then
            table.insert(B, "001110")
        elseif ret == "F" then
            table.insert(B, "001111")
        elseif ret == "G" then
            table.insert(B, "010000")
        elseif ret == "H" then
            table.insert(B, "010001")
        elseif ret == "I" then
            table.insert(B, "010010")
        elseif ret == "J" then
            table.insert(B, "010011")
        elseif ret == "K" then
            table.insert(B, "010100")
        elseif ret == "L" then
            table.insert(B, "010101")
        elseif ret == "M" then
            table.insert(B, "010110")
        elseif ret == "N" then
            table.insert(B, "010111")
        elseif ret == "O" then
            table.insert(B, "011000")
        elseif ret == "P" then
            table.insert(B, "011001")
        elseif ret == "Q" then
            table.insert(B, "011010")
        elseif ret == "R" then
            table.insert(B, "011011")
        elseif ret == "S" then
            table.insert(B, "011100")
        elseif ret == "T" then
            table.insert(B, "011101")
        elseif ret == "U" then
            table.insert(B, "011110")
        elseif ret == "V" then
            table.insert(B, "011111")
        elseif ret == "W" then
            table.insert(B, "100000")
        elseif ret == "X" then
            table.insert(B, "100001")
        elseif ret == "Y" then
            table.insert(B, "100010")
        elseif ret == "Z" then
            table.insert(B, "100011")
        elseif ret == "a" then
            table.insert(B, "100100")
        elseif ret == "b" then
            table.insert(B, "100101")
        elseif ret == "c" then
            table.insert(B, "100110")
        elseif ret == "d" then
            table.insert(B, "100111")
        elseif ret == "e" then
            table.insert(B, "101000")
        elseif ret == "f" then
            table.insert(B, "101001")
        elseif ret == "g" then
            table.insert(B, "101010")
        elseif ret == "h" then
            table.insert(B, "101011")
        elseif ret == "i" then
            table.insert(B, "101100")
        elseif ret == "j" then
            table.insert(B, "101101")
        elseif ret == "k" then
            table.insert(B, "101110")
        elseif ret == "l" then
            table.insert(B, "101111")
        elseif ret == "m" then
            table.insert(B, "110000")
        elseif ret == "n" then
            table.insert(B, "110001")
        elseif ret == "o" then
            table.insert(B, "110010")
        elseif ret == "p" then
            table.insert(B, "110011")
        elseif ret == "q" then
            table.insert(B, "110100")
        elseif ret == "r" then
            table.insert(B, "110101")
        elseif ret == "s" then
            table.insert(B, "110110")
        elseif ret == "t" then
            table.insert(B, "110111")
        elseif ret == "u" then
            table.insert(B, "111000")
        elseif ret == "v" then
            table.insert(B, "111001")
        elseif ret == "w" then
            table.insert(B, "111010")
        elseif ret == "x" then
            table.insert(B, "111011")
        elseif ret == "y" then
            table.insert(B, "111100")
        elseif ret == "z" then
            table.insert(B, "111101")
        elseif ret == "#" then
            table.insert(B, "111110")
        elseif ret == "&" then
            table.insert(B, "111111")
        end
    end
    return table.concat(B, "")
end

--- 原中文 API：`TURING["时间戳转换日期"]`
function TURING.Time_StampToDate(t)
    t = tostring(t or os.time())
    if #t == 10 then
        return os.date("%Y-%m-%d %H:%M:%S", t)
    elseif #t == 13 then
        return os.date("%Y-%m-%d %H:%M:%S", t / 1000) .. "." .. t:sub(-3, -1) .. "000"
    end
end

--- 原中文 API：`TURING["日期转换时间戳"]`
function TURING.Time_DateToStamp(d)
    local dt = {}
    local i = 0
    for t in d:gmatch("%d+") do
        i = i + 1
        dt[i] = t
    end
    if dt[7] then
        millisecond = "." .. dt[7]
    else
        millisecond = ""
    end
    return os.time({
        year = dt[1],
        month = dt[2],
        day = dt[3],
        hour = dt[4],
        minute = dt[5],
        second = dt[6]
    }) .. millisecond
end

local function LinearInterpolation(p1, p2, t)
    local x = p1[1] + (p2[1] - p1[1]) * t
    local y = p1[2] + (p2[2] - p1[2]) * t
    return { x, y }
end

local function BezierCurveFormula(p, t)
    p = {
        table.unpack(p)
    }
    while #p ~= 1 do
        for i = 1, #p - 1 do
            p[i] = LinearInterpolation(p[i], p[i + 1], t)
        end
        table.remove(p)
    end
    return p[1]
end

--- 原中文 API：`TURING["贝塞尔曲线轨迹"]`
function TURING.BezierCurve(point, step)
    local n = 1
    local tracks = {}
    local temp = {}
    tracks[n] = {
        point[1][1],
        point[1][2]
    }
    for i = 1, math.floor(1 / step) - 1 do
        temp = BezierCurveFormula(point, i * step)
        n = n + 1
        tracks[n] = {
            math.floor(temp[1]),
            math.floor(temp[2])
        }
    end
    n = n + 1
    tracks[n] = {
        point[#point][1],
        point[#point][2]
    }
    return tracks
end

--- 原中文 API：`TURING["算法_角度计算"]`
function TURING.AngleCalc(aX, aY, bX, bY)
    local PI, X, Y, ret
    PI = 3.14159265358979
    X = bX - aX
    Y = aY - bY
    if X == 0 and 0 < Y then
        ret = 0
    elseif 0 < X and Y == 0 then
        ret = 90
    elseif X == 0 and Y < 0 then
        ret = 180
    elseif X < 0 and Y == 0 then
        ret = 270
    elseif 0 < X and 0 < Y then
        ret = math.atan(X / Y) * 180 / PI
    elseif 0 < X and Y < 0 then
        ret = math.atan(math.abs(Y) / X) * 180 / PI + 90
    elseif X < 0 and Y < 0 then
        ret = math.atan(math.abs(X) / math.abs(Y)) * 180 / PI + 180
    elseif X < 0 and 0 < Y then
        ret = math.atan(math.abs(Y) / math.abs(X)) * 180 / PI + 270
    end
    return ret
end

--- 原中文 API：`TURING["算法_坐标系旋转"]`
function TURING.xyRotate(qx, qy, sWidth, sHeight, degree)
    local x, y
    if sWidth == nil then
        sWidth = 0
    end
    if sHeight == nil then
        sHeight = 0
    end
    if degree == nil then
        degree = 270
    end
    if degree == 90 then
        if qy < sHeight then
            x = sHeight - (qy + 1)
        else
            x = 0
        end
        y = qx
    elseif degree == 180 then
        if qx < sWidth then
            x = sWidth - (qx + 1)
        else
            x = 0
        end
        if qy < sHeight then
            y = sHeight - (qy + 1)
        else
            y = 0
        end
    elseif degree == 270 or degree == -90 then
        x = qy
        if qx < sWidth then
            y = sWidth - (qx + 1)
        else
            y = 0
        end
    else
        x = qx
        y = qy
    end
    return { x, y }
end

杀敌数字库 = function(h)
    local 识别库 = {}
    if h == 1080 then
        识别库[1] = "5|17,25|000O03uF3&#7p&#0zy60Eu603y301#1W0&0m0VWO0FmC07u703y3W3k0y3t0F&p03&m00&W"
        识别库[2] = "2|17,24|3003FW07F00FS00Vu00&u01pm01pm03Zm073m0E3m0U3u0y3y1u3U7m3F&W37&031u03"
        识别库[3] = "3|17,25|0W0O1m0V1y07nu00um00Eu003O0W1y0O0#0C0V060FW707u3W3y1u3d3#3p&p&m&n&m7WFm"
        识别库[4] = "1|9,24|0G000u001m003W007000E000V&&&&&&&&&&&"
        识别库[5] = "8|18,25|007u3y7#3&77ZXd0vWV0DW706m3W1u1m0y0u0U0S0F0E07W706u7m3E7O3Z&73W&3&m60&W0070"
        识别库[6] = "4|19,24|007000F000V000&001p007Z00E300S300u301m307W30E030U03W&&&&&&&&007W003000300030"
        识别库[7] = "7|17,24|m000u000u001u003u00Fu00#u03uu07mu0V0u1y0u7m0uFW0m#00pu00&W00#000y000"
        识别库[8] = "6|18,25|00&m01&#01&VW3y1m3y0S3y067c03dZ01tXW0V1m0V0O0E0C06070701W3W0y7W0F&W03&W00E0"
        识别库[9] = "0|21,25|03&m07&&0Fy&mFW1y700F7003p000xW00DW007m003u001y000#000VW00Dm00ES007700F3u0F0&W&07&&00&#0"
        识别库[10] = "9|18,24|1#007&W0F&m0U1u0S0u0u0S0m0C1m0C3m0CFm0CUm0Cym0Dmu0VWO0V0S0#0Fdy07&m03&00"
        识别库[11] = "/|14,24|00010007000V001y007m00V001y007u00VW01#007u00VW00#000u000"
        识别库[12] = "2|17,26|0O00OV00EFW07pW03zm01&S00vs00UTW077u03Xs01mTm0y7S0U1tWF0S#FW77&m1m&u0S3u06"
    elseif h == 720 then
        识别库[1] = "1|6,16|300S03W0S01&&&&&"
        识别库[2] = "0|14,17|0Vm3&uE0um0x00s01i01u03m0DW0PW1nm71&y0&W"
        识别库[3] = "4|12,16|0300S03m0v0740mG610mC7&&&&y0C00G"
        识别库[4] = "6|12,16|0Fm3&WU77mCw0M81mW430mC30OO0&00m"
        识别库[5] = "8|12,17|03mUFndms70e61GC3WO5Wm93WpzpXn#00m"
        识别库[6] = "2|11,16|0G0t07O0V03y0Rm3F0Oy3ZOSD&Wnu1"
        识别库[7] = "9|11,16|0&W770OC30OS1Zm6R0VC1uOF1xu3#0"
        识别库[8] = "3|11,17|081Wm3Z01i03O02mO7WmB1Wt7Xdx#7Zu"
        识别库[9] = "5|11,17|001W&Zd&1iC3OG2mW7X0B30s31i7#07u"
        识别库[10] = "7|11,16|300C01m0V07i1umE33WCy0&03m0400"
        识别库[11] = "/|8,16|000m0F03m0y0F03W0u0E00"
        识别库[12] = "1|5,15|0m0C0700&&&&&"
        识别库[13] = "/|8,15|00O0E0703W1m0u0S0600"
    else
        log.warn("本地字库不支持的分辨率")
    end
    return 识别库
end

cost字库 = function(h)
    local 识别库 = {}
    if h == 1080 then
        识别库[1] =
        "5|35,50|000000F00000303y0000&u0&W00F&#0V#03&&&W7&m&&&&y0VyF&&&#01&Z&&#&007y&&mFW00&F#07m007xy01u001#&00#000Flm0F0003&y07m000&&01y0007&m0V0001&y07m000V&01y0007&m0V0001&y07m000V&01y000F&m0V0003&y03u000#&00#000Vlm0Fm00Fxy01#003y&00Vm03&Fm03&01&Zy00V#3&u&007&&&yFm00&&&#3u007&&&00000V&&000001&&0000003#00"
        识别库[2] =
        "8|37,51|000000VW000000V&000F00F&#00F&03&&u07&y0&&&W1&&mF&&#0V&&1&0Vu7&&yVm0&0&WFpu03yFm0##00FXy03&m01#V00Fy007pu01&W00#U007y003&m00&000V#007u003&m00&000V#007u003&m00&000V#007u003&m00&000V#007u003&m00&000VU007y003xu01&W00#V00Fy007ny03&m01#Fm0##00FW&WFpu03y7&&yVW0&WV&&X&0Vu1&&uF&&#07&#0&&&m0F&03&&y00V00F&#000000V&W000000&W0"
        识别库[3] =
        "2|35,50|0080000000F00000V0Fm0000Fm7y00007y7&00003&3&m0001&m&u0000&yVu0000F&Fy00007&py00003&z&00001#VVW0000&dtm0000Vn&y00007uV&00003y7&m0001&1&u0000&WV#0000Vm7&W000Fu1&u0003#0V&0001&07&m000&W1&y000Vm0VVW00Fu07tu007#01z&003&00VFu01&W07p&01&m01yV#3&u00V3&&&y007mV&&#001y3&&&000V0V&&0007m1&&0001y03#0000V"
        识别库[4] =
        "1|19,49|000O0000000U0000000VW000000Vm000000Vm000000Vm000000Vm000000Vm000000Vm000000Vm000000Vm000000Vm000000Vu000000V&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
        识别库[5] =
        "0|45,51|0000&u000003&&#00001&&&y0001&&&&y000V&&&&m00F&&&&&W03&&mV&#00&&003&u0F&0007&W3&W000F#0&u0000Vu7y00001&1&000007yFu00000&Z#000003#VW00000Fpy000001#VW00000F&u000000&&0000007&u000000&&0000007&u000000&&0000007&u000000&&0000007&u000000&VW00000Fxy000001#Vm00000Fp#000003#Fu00000&X&W0000Fy7#00003&0Vu0000&m3&m000F#0F&W00F&W0&&W0F&u03&&&&&#007&&&&&000V&&&&m000&&&&u0001&&&y00000&&y00000020000"
        识别库[6] =
        "4|39,49|000001y0000001#0000001&0000001&W000003&m000003&u000003&y000003&#000003#V000007#FW00007#7m00007#3u00007#1y00007y1#0000Fy0&0000Fy0VW000Fy0Fm000Fy07u000Fy03y000Vu01#000Vu00&000Vu00VW00Vu00Fm00Vm007u00&m003y00&m001#00&v&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#00000&0000000VW000000Fm0000007u0000003y0000001#0000000V00"
        识别库[7] =
        "3|36,51|000000G00040003m007m000&W01#0007#00&m000&u0F#0007&W3&m000F#0&u0000Vu7y00000&X&000003yFm00000VZy000001#VW00000Fpu000000#&003u007&u00V000&#003u003&m00V000V#003u003&m00V000V#003u003&u00V000&&003y007&u00VW00&VW07y00Fpy00&m01#Vm0F#00Vn&03xu07yFy1&VW1&W&&&n&1&u7&&#F&&&0V&&W&&&m1&&u3&&y03&#0F&#007&00&&W000001&W0"
        识别库[8] =
        "7|36,49|#0000000VW000000Fm0000007u0000003y0000003#0000007&000000F&W00000V&m00000V&u00000&&y00001&&#00003&y&00007&uVW0007&mFm000F&W7u000V&W3y000&&01#000&#00&001&y00VW03&u00Fm07&u007u07&m003y0F&W001#0V&0000&0&&0000VW&#0000FX&y00007p&u00003&&m00001&&m00000&&W00000V&000000F#0000007#0000003y0000001u0000000"
        识别库[9] =
        "6|37,50|000007#000000V&y00000V&&m0000V&&#0000V&&&m000F&&&#0007&y3&m007&y07#003&y00&m01&#007y01&&000&W0&&W007u0V&u001#0Vyy000FmF#V0003y7&7m000&7&1y0007p&WV0001z&m7m000V&m3y0007&u0V0001&y07m000Vy01y000F#00V0003&007u000#001#000VW00Fm00Fu003#003y000Vm03&0007#01&W000&u3&m0007&&&y0000&&&#00007&&#00000V&&000003&&0000003#00"
        识别库[10] =
        "9|37,50|001&W000003&&000003&&y00001&&&W0000&&&#0000V&&&W000F&0Vy0007#01&W003&00Fu000&W01&000Fm00Fm00Nu001#00D#000VW07V0003u03&m000#03&y000FW1&&0003y0&&W000V0Vxu0007mFy#0001y7#FW000#7&3y000FZ&W&0003v&WFm000y&m1y000VVu0VW007&y07y003&#00&000&&00Fu00V&001&W0V&W00V#0V&m003&&&&m000V&&&u0003&&&u0000F&&y00001&&u000003&u0000"
    elseif h == 720 then
        识别库[1] =
        "4|26,33|0007W0001y0000VW0007y0003&W000&y000F&W003yy000&7W00Vmy007y7W01#0y00VW7W07u0y01#07W0&W0y0Fm07W3&&&&&&&&&&&&&&&&&&&&&x&&&&&0007W0000y00007W0000y0"
        识别库[2] =
        "8|25,34|0001#0080V#07y3&y1&uV&uF&n&&n&&lWV7mVy0##0&W1xm1#07l07m0Fu0V00&W1y03#03m0Fu0F00&W1y03&07m0Fy0VW1xu3#07dmVy0#V&xu7m&&F&&1&uV&u1&0&&01W1&u0001#0"
        识别库[3] =
        "5|24,34|0000m000C3m00&uFm3&&X&X&&#3#F&&u3y&&&07x&3u0FlWF00U#0y01&u3W07&WU00F#1u00&u7W07&WE00V#0y01xu3m0FlWFW0##0VWFpu1&&&FW3&&uy07&&000F&u000F#0"
        识别库[4] =
        "2|24,33|0O000uF000F3u003u&W00&Fu00Fxy003&V000&&m007&#001z&W00VFy007n&W01yFy00VX&W03uFy00#1&W0FWF#03y1xu1&0FVm&m1v&&y0F7&&01uV&m0F1&u01u1u007"
        识别库[5] = "1|14,33|0200000u0000FW0003y0000&0000Fm0003y0000&0000Fm0003&&&&&&&&&&&&&&&&&&&&&x&&&&&"
        识别库[6] =
        "9|26,33|07W0007&W003&&000&&y00F&&m01#1#00VW3u03m0F01#01y0VW07WFy00y3&W07W&y00yFtW07Zyy00y&7W07&my00&y7m0F#0V03&W3y0&u0FuV#01&&&W07&&m00V&u000&y00008000"
        识别库[7] =
        "7|24,33|y00007m0000#0000Vm0007#0003&m001&#000&&m00V##007&7m03&W#01&m7m0&u0#0F#07m7&00#3&W07X&m00yVu007&#000&&0007&W000&m0007y0000#0000200000"
        识别库[8] =
        "6|25,34|0007u0003&y000&&u00F&&m01&&&W0F#1&03&m1y0V#03u3&m07W&&00U7zu01y&dW03tuU00F&1u00&u7W07#0U00Um0y01u03m0FW0FW1y00VWFm01&&#003&&m007&#0007&m0007u0"
        识别库[9] =
        "3|24,34|0000m03W03m0#00VW7y01&0&m03#3#003yVW007pu000FlW000Uy0701xm0y07&03m0Vy0F00&m0y03&03m0Vy0F01&u1#07lW7u0#VW&m7v&&&p&3&#V&u7&n&&WF#3&u0FW3&0"
        识别库[10] =
        "0|30,34|00&u000V&y007&&y01&&&y0F&&&u1&m1&mFu00&W&000&7u001yV0003xu000FlW000Uy0001&m0007&0000Vy0001&m0007&0000V#0001xu000Fdm000#V0007m&000&3#00Fu7&03&0F&&&u0V&&&00V&&m00V&y000F#00"
    else
        log.warn("本地字库不支持的分辨率")
    end
    return 识别库
end

return TURING
