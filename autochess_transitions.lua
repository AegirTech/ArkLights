local transitions = {}

local function copy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local result = {}
    seen[value] = result
    for key, item in pairs(value) do
        result[key] = copy(item, seen)
    end
    return result
end

local function clone(state)
    local result = {}
    for key, value in pairs(state) do
        if key == "tiles" or key == "blockedTiles" or key == "benchSlots" then
            result[key] = value -- 搜索分支共享只读格位数据。阵容和资金等可变状态独立复制。
        else
            result[key] = copy(value)
        end
    end
    result.board = result.board or {}
    result.bench = result.bench or {}
    return result
end

local function slotLess(a, b)
    if type(a) == type(b) then return a < b end
    return type(a) == "number"
end

local function orderedSlots(slots, accept)
    local result = {}
    for slot, value in pairs(slots or {}) do
        if value and (not accept or accept(value)) then
            result[#result + 1] = slot
        end
    end
    table.sort(result, slotLess)
    return result
end

transitions.clone = clone
transitions.orderedKeys = orderedSlots

local function occupiedCount(slots)
    local count = 0
    for _, value in pairs(slots or {}) do
        if value then count = count + 1 end
    end
    return count
end

local function firstBenchSlot(state, limit)
    local bench = state.bench or {}
    if occupiedCount(bench) >= limit then return end
    if state.benchSlots then
        for _, slot in ipairs(state.benchSlots) do
            if not bench[slot] then return slot end
        end
        return
    end

    -- 回放快照可能使用数字或数字字符串作为格位 ID。新增格位沿用已有键的格式。
    local stringSlots = bench[1] == nil and bench["1"] ~= nil
    if not stringSlots then
        local hasNumber, hasNumericString = false, false
        for slot in pairs(bench) do
            if type(slot) == "number" then hasNumber = true end
            if type(slot) == "string" and tostring(tonumber(slot)) == slot then
                hasNumericString = true
            end
        end
        stringSlots = hasNumericString and not hasNumber
    end
    local zeroBased = (stringSlots and bench["0"] ~= nil) or (not stringSlots and bench[0] ~= nil)
    local first = zeroBased and 0 or 1
    for index = first, first + limit - 1 do
        local slot = stringSlots and tostring(index) or index
        if not bench[slot] then return slot end
    end
end

local function frontmostFirst(tiles, a, b)
    local tileA, tileB = tiles[a] or {}, tiles[b] or {}
    local rowA, rowB = tonumber(tileA.row) or math.huge, tonumber(tileB.row) or math.huge
    if rowA ~= rowB then return rowA < rowB end
    local colA, colB = tonumber(tileA.col) or math.huge, tonumber(tileB.col) or math.huge
    if colA ~= colB then return colA < colB end
    return slotLess(a, b)
end

local function upgradePlan(state, rules, id)
    local unit = rules.units[id]
    local count = unit and unit.upgradeCount
    local elite = unit and unit.upgradeTo
    local eliteUnit = rules.units[elite]
    if type(count) ~= "number" or count < 2 or count % 1 ~= 0 or elite == id or not eliteUnit then return end
    if unit.elite == true or eliteUnit.elite == false then return end
    if unit.group and eliteUnit.group and unit.group ~= eliteUnit.group then return end

    -- 合成按基础棋子 ID 匹配副本。盟约的人数统计另按同组去重。
    local isCopy = function(unitId) return unitId == id end
    local fieldCopies = orderedSlots(state.board, isCopy)
    local benchCopies = orderedSlots(state.bench, isCopy)
    if #fieldCopies + #benchCopies + 1 < count then return end

    local tiles = state.tiles or {}
    table.sort(fieldCopies, function(a, b) return frontmostFirst(tiles, a, b) end)
    if state.benchSlots then
        local order = {}
        for index, slot in ipairs(state.benchSlots) do order[slot] = index end
        table.sort(benchCopies, function(a, b)
            local left, right = order[a] or math.huge, order[b] or math.huge
            if left ~= right then return left < right end
            return slotLess(a, b)
        end)
    end
    return { id = elite, copies = count - 1, field = fieldCopies, bench = benchCopies }
end

local function applyUpgrade(result, upgrade)
    local remaining = upgrade.copies
    for _, slot in ipairs(upgrade.field) do
        if remaining == 0 then break end
        result.board[slot] = nil
        if result.equipment then result.equipment[slot] = nil end
        remaining = remaining - 1
    end
    for _, slot in ipairs(upgrade.bench) do
        if remaining == 0 then break end
        result.bench[slot] = nil
        remaining = remaining - 1
    end

    -- 回放按前排优先落回场上，纯整备区合成则留在首个副本格。之后等待实际奖励选项。
    if upgrade.field[1] ~= nil then
        result.board[upgrade.field[1]] = upgrade.id
    else
        result.bench[upgrade.bench[1]] = upgrade.id
    end
    result.shop = {}
    result.choices = nil
    result.choicesPending = true
end

local function validAmount(amount)
    return type(amount) == "number" and amount >= 0 and amount < math.huge
end

local function buyPrice(state, offer)
    if state.spendingUnconfirmed or offer.affordable == false then return false end
    local price = offer.price
    if not validAmount(price) then price = nil end

    if validAmount(state.coins) and price ~= nil then
        return price <= state.coins or offer.affordable == true, price
    end
    return offer.affordable == true, price
end

local function acquire(state, rules, mode, offer, index, claim, onAcquire)
    if not rules.units[offer.id] or offer.slot == nil then return end
    local price = 0
    if not claim then
        local allowed
        allowed, price = buyPrice(state, offer)
        if not allowed then return end
    elseif offer.affordable == false then
        return
    end

    -- 先判断本次买入能否直接合成，满整备区仍可接受能合成的副本。
    local upgrade = upgradePlan(state, rules, offer.id)
    local benchSlot = not upgrade and firstBenchSlot(state, mode.benchLimit or 10) or nil
    if not upgrade and benchSlot == nil then return end

    local result = clone(state)
    if claim then
        result.choices = nil
        result.choicesPending = nil
    else
        table.remove(result.shop, index)
        if validAmount(result.coins) and price ~= nil and price <= result.coins then
            result.coins = result.coins - price
        else
            -- 金额不可确认时丢弃预算账本，等下一份快照恢复后再评估后续购买。
            result.coins = nil
            result.spendingUnconfirmed = true
        end
        for _, card in ipairs(result.shop) do
            if card.affordable == true then card.affordable = nil end
        end
    end

    if upgrade then
        applyUpgrade(result, upgrade)
    else
        result.bench[benchSlot] = offer.id
    end
    if onAcquire then
        onAcquire(result, offer.id, false)
        if upgrade then onAcquire(result, upgrade.id, true) end
    end

    return result, {
        type = claim and "claim" or "buy",
        slot = offer.slot,
        unit = offer.id,
        price = price,
        priceObserved = price ~= nil,
    }, benchSlot
end

local function hasChoice(state)
    return state.choicesPending == true or (state.choices ~= nil and next(state.choices) ~= nil)
end

local function offersFor(state, choosing)
    if choosing then return state.choices or {} end
    return state.shop or {}
end

local function matchesPlacement(unit, placement)
    local allowed = unit and unit.placement
    if type(allowed) ~= "table" then return allowed == placement end
    if allowed[placement] == true then return true end
    for _, tileKind in ipairs(allowed) do
        if tileKind == placement then return true end
    end
    return false
end

local function legalPlacement(state, unit, target)
    local tile = state.tiles and state.tiles[target]
    if not tile or tile.blocked or (state.blockedTiles and state.blockedTiles[target]) then return false end
    if tile.placement ~= "ground" and tile.placement ~= "high" then return false end
    return matchesPlacement(unit, tile.placement)
end

local function moveAction(state, rules, openCapacity, slot, id, target)
    if not legalPlacement(state, rules.units[id], target) then return end
    local occupant = state.board and state.board[target]
    if not occupant and not openCapacity then return end
    if occupant == id then return end
    return {
        type = occupant and "swap" or "deploy",
        slot = slot,
        target = target,
        unit = id,
        replacedUnit = occupant or nil,
    }
end

function transitions.hasPlacement(state, unit, mode)
    local openCapacity = occupiedCount(state.board) < (mode.boardLimit or 8)
    for slot in pairs(state.tiles or {}) do
        if (openCapacity or (state.board and state.board[slot])) and legalPlacement(state, unit, slot) then
            return true
        end
    end
    return false
end

local function applyMove(state, action)
    local result = clone(state)
    -- 离线替换把原场上棋子移回新棋子腾出的整备格。
    result.bench[action.slot] = result.board[action.target] or nil
    result.board[action.target] = action.unit
    if result.equipment then result.equipment[action.target] = nil end
    return result
end

function transitions.apply(state, rules, mode, action, onAcquire)
    local choosing = hasChoice(state)
    if action.type == "buy" or action.type == "claim" then
        local claim = action.type == "claim"
        if claim ~= choosing then return end
        for index, offer in ipairs(offersFor(state, choosing)) do
            if offer.slot == action.slot and offer.id == action.unit then
                local livePrice = claim and 0 or offer.price
                if not validAmount(livePrice) then livePrice = nil end
                if action.price ~= nil and action.price ~= livePrice then return end
                if action.priceObserved == false and livePrice ~= nil then return end
                return (acquire(state, rules, mode, offer, index, claim, onAcquire))
            end
        end
    elseif not choosing and (action.type == "deploy" or action.type == "swap") then
        local id = state.bench and state.bench[action.slot]
        if not id or id ~= action.unit or action.target == nil then return end
        local openCapacity = occupiedCount(state.board) < (mode.boardLimit or 8)
        local legal = moveAction(state, rules, openCapacity, action.slot, id, action.target)
        if legal and legal.type == action.type
            and (action.replacedUnit == nil or legal.replacedUnit == action.replacedUnit) then
            return applyMove(state, legal)
        end
    end
end

function transitions.candidates(state, rules, mode, onAcquire)
    local result = {}
    local choosing = hasChoice(state)
    local openCapacity = occupiedCount(state.board) < (mode.boardLimit or 8)
    local targets = orderedSlots(state.tiles)
    for index, offer in ipairs(offersFor(state, choosing)) do
        local nextState, action, landing = acquire(state, rules, mode, offer, index, choosing, onAcquire)
        if nextState then
            local cost = action.price or 0
            result[#result + 1] = { action = action, state = nextState, cost = cost, moves = 1 }
            if not choosing and landing ~= nil then
                -- 同一层同时评估保留在整备区和买后立即上场，执行端按实际落位重新决策。
                for _, target in ipairs(targets) do
                    local followOn = moveAction(nextState, rules, openCapacity, landing, offer.id, target)
                    if followOn then
                        local purchase = copy(action)
                        purchase.next = followOn
                        result[#result + 1] = {
                            action = purchase,
                            state = applyMove(nextState, followOn),
                            cost = cost,
                            moves = 2,
                        }
                    end
                end
            end
        end
    end
    if not choosing then
        for _, slot in ipairs(orderedSlots(state.bench)) do
            for _, target in ipairs(targets) do
                local action = moveAction(state, rules, openCapacity, slot, state.bench[slot], target)
                if action then
                    result[#result + 1] = { action = action, state = applyMove(state, action), cost = 0, moves = 1 }
                end
            end
        end
    end
    return result
end

return transitions
