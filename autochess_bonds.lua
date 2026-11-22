local bonds = {}

local empty = {}

function bonds.set(values)
    local result = {}
    for _, value in ipairs(values or empty) do result[value] = true end
    return result
end

function bonds.isElite(unit, id)
    return unit.elite == true or (unit.group and unit.group ~= id and unit.upgradeCount == 0)
end

local function countMembers(state, units, id, rule)
    local seen = {}
    local count = 0
    local function countZone(zone)
        for _, unitId in pairs(zone or empty) do
            local unit = units[unitId]
            if unit then
                local group = unit.group or unitId
                local member = rule.countMode == "elite" and bonds.isElite(unit, unitId)
                if rule.countMode ~= "elite" then
                    for _, unitBond in ipairs(unit.bonds or empty) do
                        if unitBond == id then member = true break end
                    end
                end
                if member and (rule.countMode == "copies" or rule.countMode == "elite" or not seen[group]) then
                    seen[group] = true
                    count = count + 1
                end
            end
        end
    end
    countZone(state.board)
    if rule.countZone == "board_bench" then countZone(state.bench) end
    return count
end

local function stackParts(state, id)
    local value = (state.stacks or empty)[id]
    if type(value) == "number" then return value, 0 end
    if type(value) == "table" then return value.permanent, value.temporary end
end

function bonds.observe(state, rules, mode)
    local observed = {}
    local allowed = mode.activeBonds and bonds.set(mode.activeBonds)
    for id, rule in pairs(rules.bonds) do
        if not allowed or allowed[id] then
            local permanent, temporary = stackParts(state, id)
            observed[id] = {
                count = countMembers(state, rules.units, id, rule),
                permanent = permanent,
                temporary = temporary,
                stacks = permanent ~= nil and temporary ~= nil and permanent + temporary or nil,
                tags = {},
            }
        end
    end
    local core = observed[state.coreBond]
    if core then
        for id, value in pairs(observed) do
            local rule = rules.bonds[id]
            local bonus = rule.activationCountBonus
            if id ~= state.coreBond and bonus and bonus.target == "core_bond" and value.count >= rule.minCount
                and (not rule.maxCount or value.count <= rule.maxCount) then
                core.count = core.count + bonus.amount
            end
        end
    end
    for id, value in pairs(observed) do
        local rule = rules.bonds[id]
        value.active = value.count >= (rule.minCount or 1) and (not rule.maxCount or value.count <= rule.maxCount)
        if value.active then
            for index, tier in ipairs(rule.tiers or empty) do
                if value.count >= (tier.count or 0)
                    and (not tier.stacks or tier.stacks == 0 or (value.stacks and value.stacks >= tier.stacks)) then
                    value.tier = index
                    for _, tag in ipairs(tier.tags or empty) do value.tags[tag] = true end
                end
            end
        end
    end
    return observed
end

local function targets(effect, observed)
    if effect.targetMode == "active_highest" then
        local highest, best
        for id, value in pairs(observed) do
            if value.active then
                if value.stacks == nil then return {} end
                if highest == nil or value.stacks > highest then
                    highest, best = value.stacks, id
                elseif value.stacks == highest then
                    best = nil
                end
            end
        end
        return best and { best } or {}
    end
    if effect.targetMode == "active_all" then
        local active = {}
        for id, value in pairs(observed) do
            if value.active then active[#active + 1] = id end
        end
        table.sort(active)
        return active
    end
    return effect.targets or empty
end

local function visitEffects(state, rules, observed, trigger, visit, acquired, refreshCount)
    local function visitEffectsOf(source, zone, count)
        for _, effect in ipairs(source.effects or empty) do
            if effect.trigger == trigger and (not effect.zone or effect.zone == "any" or effect.zone == zone)
                and (not effect.minCount or count and count >= effect.minCount)
                and (not effect.maxCount or count and count <= effect.maxCount)
                and (not effect.refreshCount or effect.refreshCount == (refreshCount or state.refreshCount)) then
                visit(effect)
            end
        end
    end
    if acquired then
        visitEffectsOf(rules.units[acquired], "bench")
        return
    end
    for _, unit in pairs(state.board or empty) do
        if rules.units[unit] then visitEffectsOf(rules.units[unit], "board") end
    end
    for _, unit in pairs(state.bench or empty) do
        if rules.units[unit] then visitEffectsOf(rules.units[unit], "bench") end
    end
    for id, value in pairs(observed) do
        if value.active then visitEffectsOf(rules.bonds[id], "board", value.count) end
    end
end

local function amountFor(effect)
    local amount = effect.amount or 0
    return effect.cap and math.min(amount, effect.cap) or amount
end

local function eachGain(effect, observed, apply)
    if effect.kind == "stacks" then
        for _, id in ipairs(targets(effect, observed)) do
            local value = observed[id]
            if value and (not effect.activeOnly or value.active) then apply(id, amountFor(effect)) end
        end
    else
        apply(nil, amountFor(effect))
    end
end

function bonds.apply(state, rules, mode, trigger, acquired)
    local observed = bonds.observe(state, rules, mode)
    state.earnedStacks = state.earnedStacks or {}
    state.stacks = state.stacks or {}
    visitEffects(state, rules, observed, trigger, function(effect)
        -- 战斗条件和跨回合产出没有在当前局面兑现。
        if effect.event or effect.nextRound or effect.conditional then return end
        eachGain(effect, observed, function(id, amount)
            if id then
                local permanent, temporary = stackParts(state, id)
                local key = effect.temporary and "temporary" or "permanent"
                local parts = { permanent = permanent, temporary = temporary }
                if parts[key] ~= nil then parts[key] = parts[key] + amount end
                state.stacks[id] = parts
                if not effect.temporary then
                    state.earnedStacks[id] = (state.earnedStacks[id] or 0) + amount
                end
            elseif effect.kind == "gold" and state.coins ~= nil then
                state.coins = state.coins + amount
            elseif effect.kind == "free_refresh" then
                state.freeRefreshes = (state.freeRefreshes or 0) + amount
            elseif effect.kind == "resource" and trigger == "gain" then
                state.earnedResources = (state.earnedResources or 0) + amount
            end
        end)
    end, acquired)
end

function bonds.growth(state, rules, observed)
    local growth = 0
    local function value(effect, weight)
        if effect.conditional then return end
        eachGain(effect, observed, function(id, amount)
            if id then
                if not effect.temporary then
                    growth = growth + weight * math.min(amount, 12) * (observed[id].active and 1 or 0.5)
                end
            elseif effect.kind == "gold" or effect.kind == "free_refresh" or effect.kind == "resource" then
                growth = growth + weight * math.min(amount, 5)
            end
        end)
    end
    visitEffects(state, rules, observed, "prep_end", function(effect) value(effect, 1) end)
    visitEffects(state, rules, observed, "prep_start", function(effect) value(effect, 0.75) end)
    visitEffects(state, rules, observed, "refresh", function(effect) value(effect, 0.5) end,
        nil, (state.refreshCount or 0) + 1)
    visitEffects(state, rules, observed, "battle", function(effect) value(effect, 0.2) end)
    for id, amount in pairs(state.earnedStacks or empty) do
        local entry = observed[id]
        if entry then growth = growth + math.min(amount, 12) * (entry.active and 1 or 0.5) end
    end
    return growth + (state.freeRefreshes or 0) + (state.earnedResources or 0)
end

return bonds
