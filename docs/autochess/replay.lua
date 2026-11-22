local strategy = require("autochess_strategy")
local fixture = require("docs.autochess.fixtures")
local rules, snapshot, offer = fixture.rules, fixture.snapshot, fixture.offer

local total, failures = 0, 0
local function check(name, run)
    total = total + 1
    local ok, reason = pcall(run)
    if ok then
        print("ok " .. name)
    else
        failures = failures + 1
        io.stderr:write("FAIL ", name, " — ", tostring(reason), "\n")
    end
end

local function expect(actual, expected, field)
    if type(expected) == "table" then
        assert(type(actual) == "table", field .. " must be a table")
        for key, value in pairs(expected) do
            expect(actual[key], value, field .. "." .. key)
        end
    else
        assert(actual == expected,
            field .. " expected " .. tostring(expected) .. ", got " .. tostring(actual))
    end
end

local function score(state, expected, preferences)
    expect(strategy.score(state, rules, preferences), expected, "score")
end

local function choose(state, expected, preferences)
    local action, report = strategy.decide(state, rules, preferences)
    expect(action, expected, "action")
    return action, report
end

local function apply(state, action)
    return assert(strategy.apply(state, rules, action),
        "action " .. action.type .. " must be legal")
end

local function has(items, value)
    for _, item in ipairs(items or {}) do
        if item == value then return true end
    end
    return false
end

-- 按已识别的局面复现旧策略首笔购买。回放只区分高台和地面。
local function oldFirstPurchase(state)
    local coreNames, coreCount, tanks, benchCount = {}, 0, 0, 0
    for _, id in pairs(state.board) do
        local unit = rules.units[id]
        if unit and unit.prof == "TANK" then tanks = tanks + 1 end
        if unit and has(unit.bonds, "precision") and not coreNames[unit.group] then
            coreNames[unit.group] = true
            coreCount = coreCount + 1
        end
    end
    for _ in pairs(state.bench) do benchCount = benchCount + 1 end

    local best, bestPriority, bestTier
    for _, card in ipairs(state.shop) do
        local unit = rules.units[card.id]
        if unit and card.affordable and card.price <= state.coins then
            local core = has(unit.bonds, "precision")
            local deployable = false
            for tile, grid in pairs(state.tiles) do
                local occupant = rules.units[state.board[tile]]
                if has(unit.placement, grid.placement) and (not occupant
                    or core and (not has(occupant.bonds, "precision")
                        or unit.tier >= 4 and occupant.tier <= 3)) then
                    deployable = true
                    break
                end
            end
            local priority
            if core and not coreNames[unit.group] then
                if deployable then priority = 1
                elseif benchCount < 10 then priority = 4 end
            elseif core then
                if coreCount >= 3 and deployable then priority = 2
                elseif benchCount < 10 then priority = 5 end
            elseif deployable and (unit.prof ~= "TANK" or tanks < 2) then
                priority = 3
            end
            if priority and (not bestPriority or priority < bestPriority
                or priority == bestPriority and unit.tier > bestTier) then
                best, bestPriority, bestTier = card.id, priority, unit.tier
            end
        end
    end
    return best
end

check("mode schedule and R8/R14/R15 stages", function()
    for _, case in ipairs({
        { 2, "growth", false },
        { 3, "growth", true, "mode_single_9" },
        { 5, "growth", false },
        { 6, "formation", true },
        { 7, "formation", false },
        { 8, "hard", false },
        { 9, "hard", true },
        { 11, "hard", true, "mode_single_9" },
        { 13, "hard", false },
        { 14, "boss", false, "mode_single_1" },
        { 14, "boss", false },
        { 15, "boss", false },
    }) do
        score(snapshot({ round = case[1], modeId = case[4] or "mode_single_5" }),
            { stage = case[2], specialPrep = case[3] })
    end
    assert(not pcall(strategy.advance, snapshot({ round = 14, modeId = "mode_single_1" }), rules, 15))
    local after = strategy.advance(snapshot({ round = 14 }), rules, 15)
    expect(after.round, 15, "optional final round")
end)

check("distinct members and stacked alliance tiers", function()
    local board = { [3] = "scout", [4] = "scout_elite", [5] = "aim" }
    score(snapshot({ board = board, stacks = { precision = 20 } }),
        { bonds = { precision = { count = 2, active = false } } })
    board[6] = "ace"
    score(snapshot({ board = board, stacks = { precision = 3 } }),
        { bonds = { precision = { count = 3, active = true, stacks = 3, tier = 1 } } })
    score(snapshot({ board = board, stacks = { precision = { permanent = 3, temporary = 1 } } }),
        { bonds = { precision = { count = 3, active = true, stacks = 4,
            permanent = 3, temporary = 1, tier = 2 } } })
end)

check("deployment reserves count for bench alliances and production", function()
    local bench = strategy.score(snapshot({ bench = { "bank" } }), rules)
    local field = strategy.score(snapshot({ board = { [3] = "bank" } }), rules)
    expect(bench.bonds.market, { count = 1, active = true }, "bench alliance")
    expect(field.bonds.market, { count = 1, active = true }, "board alliance")
    assert(bench.growth > field.growth, "bench-only production must stay active on the bench")
end)

check("formation completes the damage and survival pair by R8", function()
    local state = snapshot({
        round = 7,
        coins = 4,
        board = { [1] = "guard", [2] = "veteran", [3] = "mentor", [5] = "medic" },
        bench = { "bank" },
        shop = { offer("apprentice", 1), offer("scout", 2) },
    })
    local preferences = { damageBond = "focus", survivalBond = "bulwark" }
    local purchase, plan = choose(state, { type = "buy", slot = 1, unit = "apprentice" }, preferences)
    expect(plan.before.coverage, { damage = false, survival = true }, "R7 coverage before purchase")
    local decisions = { purchase.type .. " " .. purchase.unit }
    local after = apply(state, purchase)
    for _ = 1, 2 do
        local action = strategy.decide(after, rules, preferences)
        if action.type == "end" then break end
        assert(action.type == "deploy" or action.type == "swap", "expected a formation move")
        decisions[#decisions + 1] = ("%s %s@%s"):format(action.type, action.unit, action.target)
        after = apply(after, action)
    end
    local roundEight = strategy.advance(after, rules, 8, 3)
    local finalScore = strategy.score(roundEight, rules, preferences)
    expect(finalScore, {
        stage = "hard",
        bonds = { precision = { active = false }, focus = { active = true },
            bulwark = { active = true } },
        coverage = { damage = true, survival = true },
        missing = { blocker = 0, damage = 0, survival = 0 },
    }, "R8 formation")
    assert(finalScore.growth > 0, "the setup still produces resources")
    print(("  R7→R8 %s (%d coins) | damage=%s survival=%s | gaps blocker=%d damage=%d survival=%d | growth=%g")
        :format(table.concat(decisions, ", "), plan.cost, tostring(finalScore.coverage.damage),
            tostring(finalScore.coverage.survival), finalScore.missing.blocker, finalScore.missing.damage,
            finalScore.missing.survival, finalScore.growth))
end)

check("early bench production versus legacy Precision purchase", function()
    local state = snapshot({
        round = 2,
        board = { "guard", "veteran", "mentor", "apprentice", "medic", "ace", false, "mentor" },
        coins = 1,
        shop = { offer("scout", 1), offer("bank", 2) },
    })
    expect(oldFirstPurchase(state), "scout", "legacy purchase")
    local action = choose(state, { type = "buy", slot = 2, unit = "bank" })
    local after = apply(state, action)
    assert(strategy.score(after, rules).growth > strategy.score(state, rules).growth)
    print("  R2 legacy=scout strategy=bank")
end)

check("R8 closes frontline gap before legacy Precision purchase", function()
    local state = snapshot({
        round = 8,
        board = { [2] = "veteran", [3] = "mentor", [4] = "apprentice", [5] = "medic" },
        coins = 3,
        shop = { offer("scout", 1), offer("guard", 2) },
        recentResults = { { hpLoss = 3 } },
    })
    expect(oldFirstPurchase(state), "scout", "legacy purchase")
    local action, plan = choose(state, { type = "buy", slot = 2, unit = "guard" })
    expect(plan.before.missing.blocker, 1, "initial frontline gap")
    local after = apply(state, action)
    for _ = 1, 2 do
        local nextAction = strategy.decide(after, rules)
        if nextAction.type == "end" then break end
        assert(nextAction.type == "deploy" or nextAction.type == "swap", "expected a formation move")
        after = apply(after, nextAction)
    end
    score(after, { missing = { blocker = 0 } })
    assert(state.board[1] == nil and state.board[7] == nil and state.coins == 3,
        "replay mutated the input")
    print("  R8 legacy=scout strategy=guard")
end)

check("unavailable offers and unreadable shop cards are skipped", function()
    local state = snapshot({
        round = 8,
        shop = { offer("unknown_ocr_name", 1), offer("guard", 2, false),
            { id = "mentor", slot = 3, price = 4 } },
        coins = 0,
    })
    choose(state, { type = "end" })
    assert(strategy.apply(state, rules,
        { type = "buy", unit = "guard", slot = 2 }) == nil)
end)

check("offer ordering gives a deterministic legal decision", function()
    local state = snapshot({ coins = 3, shop = { offer("guard_copy", 2), offer("guard", 1) } })
    local first = choose(state, { type = "buy" })
    local reversed = snapshot({ coins = 3, shop = { offer("guard", 1), offer("guard_copy", 2) } })
    choose(reversed, { type = first.type, slot = first.slot, unit = first.unit })
    apply(state, first)
end)

check("full bench can merge and pauses for the observed choice", function()
    local state = snapshot({
        coins = 1,
        bench = { "scout", "bank", "scout", "bank", "bank", "bank", "bank", "bank", "bank", "bank" },
        shop = { offer("scout", 1), offer("aim", 2) },
    })
    assert(strategy.apply(state, rules, { type = "buy", slot = 2, unit = "aim" }) == nil)
    local merged = apply(state, { type = "buy", slot = 1, unit = "scout" })
    expect(merged, { coins = 0, bench = { "scout_elite" }, choicesPending = true }, "merge")
    assert(merged.bench[3] == nil, "the merge should free a reserved slot")
    assert(strategy.apply(merged, rules,
        { type = "deploy", slot = 1, target = 3, unit = "scout_elite" }) == nil)
    merged.choices = { offer("unknown_ocr_name", 1) }
    local observe = choose(merged, { type = "observe" })
    assert(strategy.apply(merged, rules, observe) == nil)
    merged.choices = { offer("unknown_ocr_name", 1), offer("guard", 2) }
    local claim = choose(merged, { type = "claim", slot = 2, unit = "guard" })
    local claimed = apply(merged, claim)
    expect(claimed.bench[3], "guard", "claimed unit")
end)

check("illegal terrain and blocked tiles reject deployment", function()
    local state = snapshot({
        round = 8,
        bench = { "guard" },
        blockedTiles = { [1] = true, [7] = true },
        board = { [2] = "veteran" },
    })
    for _, tile in ipairs({ 1, 3, 7 }) do
        assert(strategy.apply(state, rules,
            { type = "deploy", slot = 1, target = tile, unit = "guard" }) == nil)
    end
end)

check("refresh reserves purchase money and waits for the next observation", function()
    local state = snapshot({ round = 8, coins = 1, refreshPrice = 1 })
    choose(state, { type = "end" })
    state.coins = 2
    local action = choose(state, { type = "refresh", price = 1 })
    local refreshed = apply(state, action)
    expect(refreshed, { coins = 1, refreshCount = 1 }, "refresh")
    assert(#refreshed.shop == 0, "no offer should be generated by replaying a refresh")
    choose(refreshed, { type = "end" })
    refreshed.shop = { offer("scout", 1) }
    choose(refreshed, { type = "buy", slot = 1, unit = "scout" })
end)

check("confirmed next-round gold clears the prior purchase uncertainty", function()
    local state = snapshot({
        round = 7,
        refreshPrice = 1,
        upgradePrice = 3,
        shop = { { id = "guard", slot = 1, affordable = true } },
    })
    state.coins = nil
    local purchase = choose(state, { type = "buy", slot = 1, unit = "guard" })
    local bought = apply(state, purchase)
    assert(bought.spendingUnconfirmed and bought.coins == nil)
    local deploy = choose(bought, { type = "deploy", unit = "guard" })
    local nextRound = strategy.advance(apply(bought, deploy), rules, 8, 4)
    assert(nextRound.spendingUnconfirmed == nil and nextRound.refreshPrice == nil
        and nextRound.upgradePrice == nil)
    nextRound.shop = { offer("mentor", 1) }
    local newPurchase = choose(nextRound, { type = "buy", slot = 1, unit = "mentor" })
    expect(apply(nextRound, newPurchase).coins, 0, "confirmed balance after purchase")
end)

check("the boss stage values single-target damage", function()
    local state = snapshot({
        round = 13,
        board = { "guard", "veteran", "mentor", "apprentice", "medic", false, false, "ace" },
    })
    local normal = strategy.score(state, rules).damage
    state.board[8] = "breaker"
    expect(strategy.score(state, rules).damage, normal, "ordinary combat")
    state.round = 14
    assert(strategy.score(state, rules).damage > normal)
    state.round = 15
    assert(strategy.score(state, rules).damage > normal)
end)

check("only eligible guaranteed effects advance round stacks", function()
    local board = { "stacker", "veteran", "scout", "aim", "ace" }
    local before = snapshot({ round = 7, board = board, stacks = {
        precision = { permanent = 3, temporary = 0 }, focus = { permanent = 2, temporary = 3 },
    } })
    local after = strategy.advance(before, rules, 8)
    expect(after.round, 8, "round")
    score(after, { bonds = { precision = { permanent = 4, temporary = 0 },
        focus = { permanent = 2, temporary = 0 } } })
    score(before, { bonds = { precision = { permanent = 3, temporary = 0 },
        focus = { permanent = 2, temporary = 3 } } })
    local inactive = snapshot({ round = 7, board = { "stacker", "veteran", "scout" },
        stacks = { precision = 0 } })
    score(strategy.advance(inactive, rules, 8), { bonds = { precision = { permanent = 0 } } })
end)

print(("%d/%d replay cases passed"):format(total - failures, total))
if failures > 0 then os.exit(1) end
