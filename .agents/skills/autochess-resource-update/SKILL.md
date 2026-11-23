---
name: autochess-resource-update
description: Updates and validates the offline strategy resources for Arknights Independent Simulation. Use when an Autochess season, operator pool, alliance, formation effect, or regulation mode changes.
---

# 更新卫戍协议策略资源

1. 记录解包来源、提交或版本、活动 ID 和赛季版本。`activity_table.json` 与 `character_table.json` 使用同一个快照。默认读取仓库已经检出的资源子模块，也可以通过命令参数传入同版本文件。
2. 先生成临时产物并和当前资源按 ID 比较。依次检查 `units`、`bonds`、`modes`、`teams` 和 `coverage` 的增删及语义变化。默认显示名发生变化时，按原始 ID 识别对应关系。
3. 优先读取结构字段。棋子的触发来源是 `garrisonDataDict` 及其 `blackboard`，盟约的门槛和受益范围来自 `bondInfoDict`、`effectDescParamDataDict` 和效果表。对照说明复核整备区是否生效、是否要求目标已激活、层数能否跨回合以及单次或单轮上限。例如，整备区参与激活以「远见」的说明为证据，人数档和层数档分别保存。
4. 只在来源有证据时补充 `res/char_type/autochess_strategy_semantics.json`。用原始效果 ID 和对应参数留出处。未知触发继续列入 `coverage.unsupportedEffectIds`，未知盟约条件列入待复核范围。确认普通与精锐棋子、合成张数、模式启用列表、特殊休整和首领回合。
5. 确定性生成并校验资源，运行离线回放。若原始规则修改了现有门槛或轮次，更新 `docs/autochess/run_offline.py` 中对应的实数据断言，再运行检查。生成器参数支持 `--activity-id`、`--version`、`--activity-table`、`--character-table` 和 `--output`。

```powershell
python res/char_type/autochess_strategy_data.py
python res/char_type/autochess_strategy_data.py --check
uv run --no-project --with lupa==2.8 -- python docs/autochess/run_offline.py
```

将资源差异、剩余未知效果和离线结果随版本变更一起记录。局面字段和验证范围见 [离线策略说明](../../../docs/autochess/README.md)。
