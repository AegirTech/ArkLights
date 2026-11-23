"""Run the offline Lua replays and validate the current generated strategy resource."""

import json
import os
from pathlib import Path

from lupa.lua54 import LuaRuntime


ROOT = Path(__file__).resolve().parents[2]


def lua_table(lua, value):
    if isinstance(value, dict):
        return lua.table_from({key: lua_table(lua, entry) for key, entry in value.items()})
    if isinstance(value, list):
        return lua.table_from([lua_table(lua, entry) for entry in value])
    return value


def main():
    os.chdir(ROOT)
    lua = LuaRuntime()
    lua.execute('dofile("docs/autochess/replay.lua")')
    resource = ROOT / "res/char_type/autochess_strategy_data.json"
    rules = json.loads(resource.read_text(encoding="utf-8"))
    lua.globals().currentRules = lua_table(lua, rules)
    lua.execute("""
        local strategy = require("autochess_strategy")
        local function members(bond, limit)
            local ids = {}
            for id, unit in pairs(currentRules.units) do
                if unit.upgradeTo then
                    for _, candidate in ipairs(unit.bonds) do
                        if candidate == bond then ids[#ids + 1] = id end
                    end
                end
            end
            table.sort(ids)
            assert(#ids >= limit, "棋子池中的盟约成员不足: " .. bond)
            return { table.unpack(ids, 1, limit) }
        end

        local precision = members("preciShip", 3)
        local vision = members("visiShip", 2)
        local state = { round = 7, modeId = "mode_single_5", coins = 5,
            board = { precision[1], precision[2] }, bench = vision, shop = {} }
        local before = strategy.score(state, currentRules)
        assert(before.bonds.preciShip.tier == 1 and before.bonds.preciShip.count == 2)
        assert(before.bonds.visiShip.active and before.bonds.visiShip.count == 2)
        state.board[3] = precision[3]
        state.round = 8
        local after = strategy.score(state, currentRules)
        assert(after.bonds.preciShip.tier == 2 and after.stage == "hard")
        assert(strategy.decide(state, currentRules).type == "end")

        state.modeId, state.round = "mode_single_9", 11
        assert(strategy.score(state, currentRules).specialPrep)
        state.round = 14
        assert(strategy.score(state, currentRules).stage == "boss")
        assert(strategy.advance(state, currentRules, 15).round == 15)
        print("OK  当前赛季资源与 Lua 模块联通")
    """)


if __name__ == "__main__":
    main()
