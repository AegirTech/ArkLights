local function unit(prof, tier, price, placement, roles, bonds, effects)
    return {
        prof = prof,
        tier = tier,
        price = price,
        placement = { placement },
        roles = roles,
        bonds = bonds,
        effects = effects or {},
    }
end

local units = {
    guard = unit("TANK", 3, 3, "ground", { "blocker" }, { "bulwark" }),
    guard_copy = unit("TANK", 3, 3, "ground", { "blocker" }, { "bulwark" }),
    veteran = unit("WARRIOR", 3, 3, "ground", { "blocker", "damage" }, { "bulwark" }),
    medic = unit("MEDIC", 3, 3, "high", { "heal" }, { "bulwark" }),
    scout = unit("SNIPER", 1, 1, "high", { "damage" }, { "precision" }),
    scout_elite = unit("SNIPER", 1, 0, "high", { "damage" }, { "precision" }),
    aim = unit("SNIPER", 1, 1, "high", { "damage" }, { "precision" }),
    ace = unit("SNIPER", 4, 4, "high", { "damage", "carry" }, { "precision" }),
    breaker = unit("SNIPER", 4, 4, "high", { "damage", "carry", "single_target" }, { "precision" }),
    mentor = unit("CASTER", 4, 4, "high", { "damage", "carry" }, { "focus" }),
    apprentice = unit("CASTER", 4, 4, "high", { "damage", "carry" }, { "focus" }),
    bank = unit("SUPPORT", 1, 1, "high", { "bench" }, { "market" }, {
        { trigger = "prep_end", zone = "bench", kind = "gold", amount = 2 },
    }),
    stacker = unit("WARRIOR", 3, 3, "ground", { "stacker", "blocker" }, { "bulwark" }, {
        { trigger = "prep_end", zone = "board", kind = "stacks", amount = 2,
            targets = { "precision" }, activeOnly = true, cap = 1 },
    }),
}
for id, item in pairs(units) do
    item.name = id
    item.group = id
    item.upgradeCount = 3
end
units.scout.upgradeTo = "scout_elite"
units.scout_elite.group = "scout"
units.scout_elite.upgradeCount = nil
units.scout_elite.elite = true

local bonds = {
    precision = {
        name = "精准",
        countZone = "board",
        countMode = "distinct",
        minCount = 3,
        tiers = {
            { count = 3, tags = { "damage" }, scope = "members" },
            { count = 3, stacks = 4, tags = { "damage" }, scope = "members" },
        },
    },
    focus = {
        name = "专注",
        countZone = "board",
        countMode = "distinct",
        minCount = 2,
        tiers = { { count = 2, tags = { "damage" }, scope = "team" } },
    },
    bulwark = {
        name = "壁垒",
        countZone = "board",
        countMode = "distinct",
        minCount = 2,
        tiers = { { count = 2, tags = { "survival" }, scope = "team" } },
    },
    market = {
        name = "集市",
        countZone = "board_bench",
        countMode = "distinct",
        minCount = 1,
        tiers = { { count = 1, tags = { "growth", "production" }, scope = "members" } },
    },
}

local function mode(bossRounds, specialRounds, maxRound)
    return {
        firstHardRound = 8,
        bossRound = 14,
        bossRounds = bossRounds,
        maxRound = maxRound,
        specialRounds = specialRounds,
        activeBonds = { "precision", "focus", "bulwark", "market" },
        refreshPrice = 1,
        benchLimit = 10,
        boardLimit = 8,
        shop = {
            { level = 1, slots = 4, upgradePrice = 3, itemSlots = 1 },
            { level = 2, slots = 4, itemSlots = 1 },
        },
    }
end

local rules = {
    schemaVersion = 1,
    season = "fixture",
    units = units,
    bonds = bonds,
    modes = {
        mode_single_1 = mode({ 14 }, { 6, 9 }, 14),
        mode_single_5 = mode({ 14, 15 }, { 6, 9 }, 15),
        mode_single_9 = mode({ 14, 15 }, { 3, 9, 11 }, 15),
    },
}

local tiles = {
    [1] = { placement = "ground", row = 1, col = 1, lanes = { "main" } },
    [2] = { placement = "ground", row = 2, col = 1, lanes = { "aux" } },
    [3] = { placement = "high", row = 1, col = 2, lanes = { "main" } },
    [4] = { placement = "high", row = 2, col = 2, lanes = { "main", "aux" } },
    [5] = { placement = "high", row = 1, col = 3, lanes = { "main" } },
    [6] = { placement = "high", row = 2, col = 3, lanes = { "aux" } },
    [7] = { placement = "ground", row = 1, col = 4, lanes = { "main" } },
    [8] = { placement = "high", row = 1, col = 5, lanes = { "main" } },
}

local function snapshot(fields)
    local state = {
        round = 1,
        modeId = "mode_single_5",
        board = {},
        bench = {},
        shop = {},
        coins = 0,
        shopLevel = 2,
        stacks = {},
        tiles = tiles,
        lanes = { "main", "aux" },
        primaryLanes = { "main" },
        recentResults = {},
    }
    for key, value in pairs(fields or {}) do
        state[key] = value
    end
    return state
end

local function offer(id, slot, affordable)
    return { id = id, slot = slot, price = units[id] and units[id].price,
        affordable = affordable ~= false }
end

return { rules = rules, snapshot = snapshot, offer = offer }
