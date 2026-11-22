# 卫戍协议独立模拟离线策略

策略模块使用独立模拟的棋子、盟约和回合规则评估购买与部署。默认规程等级为 5，离线用例也覆盖规程等级 9。第 1–5 回合优先建立场面再发育，第 6–7 回合补齐输出与生存效果，第 8–13 回合按局势补强。第 14 回合起优先处理能在当轮兑现的收益，隐秘核心使用单独的第 15 回合快照。

## Lua 接口

```lua
local strategy = require("autochess_strategy")
local action, report = strategy.decide(snapshot, rules, {
    damageBond = "preferred_damage_bond_id",
    survivalBond = "preferred_survival_bond_id",
})
```

`rules` 是 `res/char_type/autochess_strategy_data.json` 解码后的表。偏好表可省略。候选动作按场面缺口、当轮目标、花费和换位次数排序，最多前看三项决策，每层保留前 24 项。返回的 `action` 是当前的一步，买入动作的 `next` 仅描述评分中考虑的后续部署。`report` 包含前后战力缺口、盟约档位、成长收益、预计花费及选择理由。`score(snapshot, rules, preferences)` 可单独评估快照。

| 快照字段 | 约定 |
| --- | --- |
| `modeId`, `round` | 规程 ID 和当前回合。`modeId` 默认 `mode_single_5`。`stage = "settled"` 表示已结算。 |
| `board`, `bench` | 格位 ID 到 `chessId` 的映射。可用 `benchSlots` 指定整备区格位顺序。 |
| `tiles`, `primaryLanes` | 允许部署的地块及主要路线。地块提供 `placement`，可补充 `row`、`col`、`lanes`、`blockLanes`、`damageLanes`、`healLanes` 或 `healTargets`。用 `blockedTiles` 标记禁用格。`equipment` 用场上格位 ID 表示已确认装备。 |
| `shop`, `choices` | 普通商店和晋级奖励列表。条目包含 `id`、`slot`、可选的实际 `price` 和 `affordable`。`choicesPending` 表示奖励已触发且选项待观察。 |
| `coins`, `shopLevel`, `upgradePrice`, `refreshPrice` | 可确认的本轮资金、商店等级和实际价格。`freeRefreshes` 可表示已确认的免费刷新次数。缺失值保持未知。 |
| `stacks`, `teamId`, `coreBond`, `recentResults` | 已确认的层数、分队、核心盟约及近期战果。层数可用数字表示已知的永久层数且临时层为零，或用 `{ permanent, temporary }` 独立表示两项。`recentResults` 按时间顺序提供 `hpLoss`。 |

`action.type` 包含 `buy`、`claim`、`deploy`、`swap`、`upgrade`、`refresh`、`observe` 和 `end`。`apply(snapshot, rules, action)` 计算合法动作的离线结果，动作有待观察或已失效时返回 `nil`。合成后用下一份快照提供奖励选项。刷新和升本后用下一份快照提供当时的商店数据。`advance(snapshot, rules, nextRound, nextRoundIncome)` 结算可确认的休整触发并清理临时层，调用者提供下轮回合和可选的已知新收入。

## 离线验证

在仓库根目录执行以下命令，检查资源与当前解包表的一致性，并用 Lua 5.4 运行固定局面回放和当前资源联通检查。

```powershell
python res/char_type/autochess_strategy_data.py --check
uv run --no-project --with lupa==2.8 -- python docs/autochess/run_offline.py
```

已有独立 Lua 5.4 解释器时，也可运行 `lua5.4 docs/autochess/replay.lua`。回放用合成局面比较旧购买优先级和新策略，检查第 8 回合的场面补强、两类盟约覆盖、金币预算和首领回合选择。当前输出和生存评分以职业、棋子职责、精锐状态、站位覆盖和已知盟约为代理。获得的装备按确认的数量计入发育分，实际装备效果通过局面输入确认。解包缺少独立模拟的完整商店牌池概率，调度等级暂以棋子档位作为可达性近似。通关率需独立模拟实战数据验证。

换池和规则变更按 [版本更新 Skill](../../.agents/skills/autochess-resource-update/SKILL.md) 处理。
