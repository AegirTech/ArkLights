local bonds = require("autochess_bonds")
local transitions = require("autochess_transitions")

local strategy = {}
local empty = {}
local searchDepth, searchWidth = 3, 24

local function context(snapshot, rules)
    local modeId = snapshot.modeId or "mode_single_5"
    local mode = assert(rules.modes[modeId], "未知规程 " .. modeId)
    local round = assert(snapshot.round, "缺少当前回合")
    assert(round >= 1 and round <= mode.maxRound, "回合超出规程范围")
    local hard = mode.firstHardRound or 8
    local boss = mode.bossRound or 14
    local stage = round >= boss and "boss" or round >= hard and "hard"
        or round >= hard - 2 and "formation" or "growth"
    return mode, stage
end

local function rolesOf(unit)
    local roles = bonds.set(unit.roles)
    if roles.carry then roles.damage = true end
    return roles
end

local function coverLanes(covered, lanes, primary)
    for _, lane in ipairs(lanes or primary) do covered[lane] = true end
end

-- 用已确认的棋盘覆盖评估阻挡、输出和治疗。没有主要路线时以全场角色数量估算缺口。
local function assessBoard(state, rules, stage)
    local primary = state.primaryLanes or empty
    local occupants = {}
    local healedLanes, healedSlots = {}, {}
    local blocked, attacked = {}, {}
    local damage, survival = 0, 0
    local blockers, attackers, medics, elites = 0, 0, 0, 0
    for _, slot in ipairs(transitions.orderedKeys(state.board)) do
        local id = state.board[slot]
        local unit = rules.units[id]
        if unit then
            local tile = (state.tiles or empty)[slot] or empty
            local roles = rolesOf(unit)
            occupants[slot] = { unit = unit, roles = roles }
            local elite = bonds.isElite(unit, id) and 1 or 0
            elites = elites + elite
            if roles.blocker then
                blockers = blockers + 1
                coverLanes(blocked, tile.blockLanes or tile.lanes, #primary == 0 and { 1 } or empty)
                survival = survival + 2 + elite
            end
            if roles.damage then
                local lanes = tile.damageLanes or tile.lanes
                local reachesLane = #primary == 0
                for _, lane in ipairs(lanes or empty) do
                    for _, listed in ipairs(primary) do
                        if lane == listed then reachesLane = true end
                    end
                end
                if reachesLane then
                    attackers = attackers + 1
                    coverLanes(attacked, lanes, #primary == 0 and { 1 } or empty)
                    damage = damage + 1 + math.min(unit.tier or 0, 6) * 0.25 + elite
                        + (roles.carry and 0.5 or 0) + (stage == "boss" and roles.single_target and 1 or 0)
                end
            end
            if roles.heal then
                if tile.healTargets then
                    for _, target in ipairs(tile.healTargets) do healedSlots[target] = true end
                else
                    coverLanes(healedLanes, tile.healLanes or tile.lanes, #primary == 0 and { 1 } or empty)
                end
            end
        end
    end
    for slot, occupant in pairs(occupants) do
        if occupant.roles.blocker then
            local tile = (state.tiles or empty)[slot] or empty
            local healed = healedSlots[slot] == true or #primary == 0 and healedLanes[1] == true
            for _, lane in ipairs(tile.blockLanes or tile.lanes or empty) do
                if healedLanes[lane] then healed = true end
            end
            if healed then medics = medics + 1 end
        end
    end
    local blockerGaps = blockers == 0 and 1 or 0
    local damageGaps = 0
    if #primary > 0 then
        blockerGaps = 0
        for _, lane in ipairs(primary) do
            if not blocked[lane] then blockerGaps = blockerGaps + 1 end
            if not attacked[lane] then damageGaps = damageGaps + 1 end
        end
    end
    return {
        damage = damage, survival = survival + medics * 2, elites = elites,
        occupants = occupants, blockers = blockers, attackers = attackers, healedFronts = medics,
        blockerGaps = blockerGaps, damageGaps = damageGaps,
    }
end

local function tierApplies(tier, state, id, board, tag)
    if tier.unscored then return false end
    for slot, occupant in pairs(board.occupants) do
        local roles = occupant.roles
        local unit = occupant.unit
        local eligible = tier.scope == "team" or bonds.set(unit.bonds)[id]
            or tier.scope == "elite" and bonds.isElite(unit, state.board[slot])
        local equipped = not tier.requiresEquipment or (state.equipment or empty)[slot]
        if eligible and equipped and (tag ~= "damage" or roles.damage) then return true end
    end
    return false
end

-- 盟约激活后还要检查场上受益者。整备区成员可以提供人数，战斗覆盖取决于场上阵容。
local function effectsOnBoard(state, rules, observed, board)
    local coverage = { damage = false, survival = false }
    local bonuses = { damage = 0, survival = 0 }
    local productive = 0
    local preferenceReady = {}
    for _, id in ipairs(transitions.orderedKeys(observed)) do
        local observation = observed[id]
        if observation.active then
            local best = {}
            for index = 1, observation.tier or 0 do
                local tier = rules.bonds[id].tiers[index]
                if observation.count >= (tier.count or 0)
                    and (not tier.stacks or tier.stacks == 0 or observation.stacks and observation.stacks >= tier.stacks)
                    and not tier.unscored then
                    for _, tag in ipairs(tier.tags or empty) do
                        if (tag == "growth" or tag == "production") and not tier.requiresEquipment then
                            productive = productive + 1
                        elseif (tag == "damage" or tag == "survival") and tierApplies(tier, state, id, board, tag) then
                            best[tag] = math.max(best[tag] or 0, index)
                        end
                    end
                end
            end
            for tag, tier in pairs(best) do
                coverage[tag] = true
                bonuses[tag] = bonuses[tag] + tier + math.min(observation.stacks or 0, 100) / 25
            end
            preferenceReady[id] = best
        end
    end
    return coverage, bonuses, productive, preferenceReady
end

local function nearestGoals(state, rules, observed, preferences, preferenceReady)
    local progress = { damage = 0, survival = 0 }
    local preferred = 0
    local interests = {}
    local available = {}
    for _, id in pairs(state.bench or empty) do available[id] = true end
    for _, card in ipairs(state.shop or empty) do
        if card.id and card.affordable ~= false then available[card.id] = true end
    end
    for id, observation in pairs(observed) do
        local rule = rules.bonds[id]
        local ready = preferenceReady[id] or empty
        if not rule.maxCount or observation.count <= rule.maxCount then
            for _, tier in ipairs(rule.tiers or empty) do
                for _, tag in ipairs(tier.tags or empty) do
                    if progress[tag] ~= nil and not tier.unscored and not ready[tag]
                        and (not tier.stacks or tier.stacks == 0 or observation.stacks and observation.stacks >= tier.stacks) then
                        local target = math.max(tier.count or 0, rule.minCount or 1)
                        local deficit = math.max(0, target - observation.count)
                        if observation.count > 0 and deficit > 0 then
                            local support = 0
                            for unitId in pairs(available) do
                                local unit = rules.units[unitId]
                                if unit and bonds.set(unit.bonds)[id] then support = support + 1 end
                            end
                            progress[tag] = math.max(progress[tag], 1 / deficit + math.min(support, deficit) * 0.25)
                            interests[id] = true
                        end
                    end
                end
            end
        end
        if preferences.damageBond == id and ready.damage then preferred = preferred + 1 end
        if preferences.survivalBond == id and ready.survival then preferred = preferred + 1 end
    end
    return progress.damage + progress.survival, preferred, interests
end

local function benchValue(state, rules, interests, stage)
    local units = {}
    local count = 0
    for _, zone in ipairs({ state.board or empty, state.bench or empty }) do
        for _, id in pairs(zone) do units[id] = (units[id] or 0) + 1 end
    end
    local value = 0
    for _, id in pairs(state.bench or empty) do
        count = count + 1
        local unit = rules.units[id]
        if unit and stage ~= "boss" then
            if unit.upgradeTo and unit.upgradeCount and units[id] == unit.upgradeCount - 1 then value = value + 0.5 end
            for _, bondId in ipairs(unit.bonds or empty) do
                if interests[bondId] then value = value + 0.25 end
            end
        end
    end
    return value, count
end

local function healthy(state)
    local result = state.recentResults or empty
    local last, previous = result[#result], result[#result - 1]
    return last and previous and last.hpLoss == 0 and previous.hpLoss == 0
end

local function evaluate(state, rules, mode, stage, preferences)
    local board = assessBoard(state, rules, stage)
    local observed = bonds.observe(state, rules, mode)
    local coverage, bonuses, productive, preferredReady = effectsOnBoard(state, rules, observed, board)
    local progress, preferred, interests = nearestGoals(state, rules, observed, preferences, preferredReady)
    local waitingValue, waitingCount = benchValue(state, rules, interests, stage)
    local damage, survival = board.damage + bonuses.damage, board.survival + bonuses.survival
    local missing = {
        blocker = board.blockerGaps,
        damage = math.max(board.damageGaps, math.max(0, (state.round <= 2 and 1 or 2) - board.attackers)),
        survival = state.round >= 3 and board.healedFronts == 0 and board.blockers < 2 and not coverage.survival and 1 or 0,
    }
    local deficits = missing.blocker + missing.damage + missing.survival
    local growth = bonds.growth(state, rules, observed) + productive
    local paired = (coverage.damage and 1 or 0) + (coverage.survival and 1 or 0)
    local capacityCost = math.max(0, waitingCount - math.max(0, (mode.benchLimit or 10) - 2))
    local safe = deficits == 0
    local team = (rules.teams or empty)[state.teamId] or empty
    local cash = state.coins or 0
    local preservesInterest = safe and stage ~= "boss" and team.carryGold and team.interestThreshold
        and cash >= team.interestThreshold and 1 or 0
    -- 评分向量逐项比较。各阶段共用战力底线，后续分项决定发育、成型或首领战的取舍。
    local score = { -deficits, -missing.blocker, -missing.survival, -missing.damage }
    local function rank(...)
        for _, criterion in ipairs({ ... }) do score[#score + 1] = criterion end
    end
    if stage == "growth" then
        rank(preservesInterest, growth + board.elites - capacityCost, progress, preferred, damage + survival, paired, waitingValue)
    elseif stage == "formation" then
        rank(paired, preservesInterest, progress, damage + survival, preferred, growth - capacityCost, waitingValue)
    elseif stage == "hard" and safe and healthy(state) then
        rank(paired, preservesInterest, damage + survival + growth * 0.5, preferred, progress, waitingValue - capacityCost)
    elseif stage == "hard" then
        rank(paired, survival, damage, preferred, progress, preservesInterest, waitingValue - capacityCost)
    else
        rank(paired, math.min(damage, survival), damage + survival, -capacityCost)
    end
    return {
        stage = stage, specialPrep = bonds.set(mode.specialRounds)[state.round] == true,
        missing = missing, bonds = observed, coverage = coverage, growth = growth,
        damage = damage, survival = survival, safe = safe, interests = interests, rank = score,
    }
end

--- 评估当前局面的覆盖、战力缺口和排序分项，供回放和实机日志使用。
---@param snapshot table 当前整备快照
---@param rules table 已解码的策略资源
---@param preferences table? 开局偏好的输出和生存盟约
---@return table report 当前局面的评估
function strategy.score(snapshot, rules, preferences)
    local mode, stage = context(snapshot, rules)
    return evaluate(snapshot, rules, mode, stage, preferences or empty)
end

local function better(left, right)
    for index, value in ipairs(left.report.rank) do
        if value ~= right.report.rank[index] then return value > right.report.rank[index] end
    end
    if (left.state.spendingUnconfirmed == true) ~= (right.state.spendingUnconfirmed == true) then
        return right.state.spendingUnconfirmed == true
    end
    if left.cost ~= right.cost then return left.cost < right.cost end
    if left.moves ~= right.moves then return left.moves < right.moves end
    return left.key < right.key
end

local function actionKey(action)
    return table.concat({ tostring(action.unit or ""), tostring(action.slot or ""), tostring(action.target or ""),
        action.type }, ":")
end

local function acquisition(rules, mode)
    return function(state, id, isUpgrade)
        -- 精锐奖励由下一份快照提供。
        if not isUpgrade then bonds.apply(state, rules, mode, "gain", id) end
    end
end

local function search(rules, mode, stage, preferences, root, onAcquire)
    local beam = { root }
    -- 把原局面也作为候选。可见操作都无法改善评分时，交给经济判断或结束整备。
    local best = root
    for _ = 1, searchDepth do
        local expanded = {}
        for _, node in ipairs(beam) do
            for _, candidate in ipairs(transitions.candidates(node.state, rules, mode, onAcquire)) do
                local report = evaluate(candidate.state, rules, mode, stage, preferences)
                -- 已满足底线时，逐步维持战力。待领取奖励会占据当前操作界面，因此单独允许领取。
                if not root.report.safe or report.safe or candidate.action.type == "claim" then
                    local path = { table.unpack(node.path) }
                    path[#path + 1] = candidate.action
                    local extra = candidate.action.next and ">" .. actionKey(candidate.action.next) or ""
                    local item = {
                        state = candidate.state, report = report, path = path,
                        cost = node.cost + candidate.cost, moves = node.moves + candidate.moves,
                        key = node.key .. "/" .. actionKey(candidate.action) .. extra,
                    }
                    expanded[#expanded + 1] = item
                    if better(item, best) then best = item end
                end
            end
        end
        table.sort(expanded, better)
        beam = {}
        for index = 1, math.min(#expanded, searchWidth) do beam[index] = expanded[index] end
        if #beam == 0 then break end
    end
    return best
end

local function canAccess(unit, level, mode)
    local shop = (mode.shop or empty)[level] or empty
    if shop.poolTiers then return bonds.set(shop.poolTiers)[unit.tier] == true end
    return unit.tier ~= nil and unit.tier <= level
end

local function economy(snapshot, rules, mode, report, preferences)
    local coins = snapshot.coins
    local level = snapshot.shopLevel
    if coins == nil or not level or snapshot.stage == "settled" then return end
    local team = (rules.teams or empty)[snapshot.teamId] or empty
    local reserve = report.safe and report.stage ~= "boss" and team.carryGold and team.interestThreshold or 0
    -- 记录两种操作各自能触及的最便宜目标。经济操作的预算包含后续购卡和已确认的分队留存门槛。
    local refreshGoal, upgradeGoal
    for _, unit in pairs(rules.units) do
        if unit.upgradeTo and unit.price ~= nil then
            local target = false
            for _, bondId in ipairs(unit.bonds or empty) do
                if report.bonds[bondId] and (report.interests[bondId] or bondId == preferences.damageBond
                    or bondId == preferences.survivalBond) then target = true end
            end
            local roles = rolesOf(unit)
            local fillsGap = report.missing.blocker > 0 and roles.blocker
                or report.missing.damage > 0 and roles.damage or report.missing.survival > 0 and (roles.heal or roles.blocker)
            if (target or fillsGap) and transitions.hasPlacement(snapshot, unit, mode) then
                if canAccess(unit, level, mode) then
                    refreshGoal = math.min(refreshGoal or unit.price, unit.price)
                elseif target and report.safe and canAccess(unit, level + 1, mode) then
                    upgradeGoal = math.min(upgradeGoal or unit.price, unit.price)
                end
            end
        end
    end
    local upgradePrice = snapshot.upgradePrice
    if report.stage ~= "boss" and snapshot.upgradeAvailable ~= false and (mode.shop or empty)[level + 1]
        and upgradeGoal and upgradePrice and upgradePrice >= 0 and coins - upgradePrice - upgradeGoal >= reserve then
        return { type = "upgrade", price = upgradePrice }, "升本可解锁目标档位且保留购买预算"
    end
    local refreshPrice = snapshot.refreshPrice
    if refreshPrice == nil and (snapshot.freeRefreshes or 0) > 0 then refreshPrice = 0 end
    if snapshot.refreshAvailable ~= false and refreshGoal and refreshPrice and refreshPrice >= 0
        and coins - refreshPrice - refreshGoal >= reserve then
        return { type = "refresh", price = refreshPrice }, "刷新后仍有目标棋子的购买预算"
    end
end

--- 在当前可见局面中搜索并返回第一步。买入动作的 next 记录评分时假设的部署。
---@param snapshot table 当前整备快照
---@param rules table 已解码的策略资源
---@param preferences table? 开局偏好的输出和生存盟约
---@return table action 当前建议动作
---@return table report 搜索路径、整条路径的预计花费和选择理由
function strategy.decide(snapshot, rules, preferences)
    preferences = preferences or empty
    local mode, stage = context(snapshot, rules)
    local root = { state = snapshot, report = evaluate(snapshot, rules, mode, stage, preferences),
        path = {}, cost = 0, moves = 0, key = "" }
    if snapshot.stage == "settled" then
        return { type = "end" }, { before = root.report, after = root.report, path = {}, cost = 0, reason = "本局已结算" }
    end
    local onAcquire = acquisition(rules, mode)
    local best = search(rules, mode, stage, preferences, root, onAcquire)
    if #best.path == 0 and #(snapshot.choices or empty) > 0 then
        local candidates = transitions.candidates(snapshot, rules, mode, onAcquire)
        for _, candidate in ipairs(candidates) do
            local item = { state = candidate.state, report = evaluate(candidate.state, rules, mode, stage, preferences),
                path = { candidate.action }, cost = candidate.cost, moves = candidate.moves, key = actionKey(candidate.action) }
            if #best.path == 0 or better(item, best) then best = item end
        end
    end
    local action = best.path[1]
    local reason
    if action then
        if action.type == "claim" then
            reason = "领取符合当前阵容的晋级奖励"
        elseif not root.report.safe and best.report.rank[1] > root.report.rank[1] then
            reason = "补足阻挡、输出或生存缺口"
        elseif best.report.coverage.damage and not root.report.coverage.damage
            or best.report.coverage.survival and not root.report.coverage.survival then
            reason = "激活新的输出或生存效果"
        elseif best.report.growth > root.report.growth and stage ~= "boss" then
            reason = "增加叠层或生产收益"
        else
            reason = "提高即时战力或推进目标盟约"
        end
    elseif not snapshot.choicesPending and #(snapshot.choices or empty) == 0 then
        action, reason = economy(snapshot, rules, mode, root.report, preferences)
    else
        action, reason = { type = "observe" }, "等待可确认的晋级奖励选项"
    end
    return action or { type = "end" }, {
        before = root.report, after = best.report, path = best.path, cost = action and action.price and #best.path == 0
            and action.price or best.cost, reason = reason or "结束整备",
    }
end

--- 在离线回放中复核并推演一个动作。买入之后的部署由下一次调用单独处理。
---@param snapshot table 动作发生前的快照
---@param rules table 已解码的策略资源
---@param action table 需要复核的单步动作
---@return table? snapshot 推演后的快照，动作待观察或失效时返回 nil
function strategy.apply(snapshot, rules, action)
    local mode = context(snapshot, rules)
    if action.type == "end" then return transitions.clone(snapshot) end
    if snapshot.stage == "settled" or action.type == "observe" then return nil end
    if action.type == "upgrade" or action.type == "refresh" then
        if action.price == nil or action.price < 0 or snapshot.coins == nil or snapshot.coins < action.price
            or snapshot.choicesPending or #(snapshot.choices or empty) > 0 then return nil end
        local state = transitions.clone(snapshot)
        state.coins = state.coins - action.price
        state.shop = {}
        if action.type == "upgrade" then
            if state.upgradeAvailable == false or not state.shopLevel or not (mode.shop or empty)[state.shopLevel + 1]
                or state.upgradePrice ~= action.price then return nil end
            state.shopLevel = state.shopLevel + 1
            state.upgradePrice = nil
        else
            local price = state.refreshPrice
            if price == nil and (state.freeRefreshes or 0) > 0 then price = 0 end
            if state.refreshAvailable == false or price ~= action.price then return nil end
            if price == 0 and (state.freeRefreshes or 0) > 0 then state.freeRefreshes = state.freeRefreshes - 1 end
            state.refreshCount = (state.refreshCount or 0) + 1
            state.refreshPrice = nil
            bonds.apply(state, rules, mode, "refresh")
        end
        return state
    end
    return transitions.apply(snapshot, rules, mode, action, acquisition(rules, mode))
end

--- 离线结算休整结束与下轮开始的触发。调用方根据回放提供下一回合和收入。
---@param snapshot table 本轮整备快照
---@param rules table 已解码的策略资源
---@param nextRound integer 回放中确认的后续回合
---@param nextRoundIncome number? 已知的下轮新增资金
---@return table snapshot 下轮快照
function strategy.advance(snapshot, rules, nextRound, nextRoundIncome)
    local mode = context(snapshot, rules)
    assert(nextRound > snapshot.round and nextRound <= mode.maxRound, "无效的后续回合")
    local state = transitions.clone(snapshot)
    if not state.choicesPending and #(state.choices or empty) == 0 then
        bonds.apply(state, rules, mode, "prep_end")
    end
    for id, value in pairs(state.stacks or empty) do
        -- 临时层在换轮时清零。永久层继续沿用已知数值或 nil。
        if type(value) == "table" then state.stacks[id] = { permanent = value.permanent, temporary = 0 } end
    end
    local team = (rules.teams or empty)[state.teamId] or empty
    local carriedCoins = 0
    if team.carryGold == true then
        carriedCoins = state.coins
        if carriedCoins and team.interestThreshold and carriedCoins >= team.interestThreshold then
            carriedCoins = carriedCoins + (team.interestAmount or 0)
        end
    end
    state.coins = nextRoundIncome and carriedCoins and carriedCoins + nextRoundIncome or nil
    state.round = nextRound
    state.shop, state.choices, state.choicesPending = {}, {}, nil
    state.spendingUnconfirmed = nil
    state.refreshPrice, state.upgradePrice = nil, nil
    state.refreshAvailable, state.upgradeAvailable = nil, nil
    state.refreshCount, state.earnedStacks = 0, {}
    state.earnedResources = nil
    bonds.apply(state, rules, mode, "prep_start")
    return state
end

return strategy
