"""Export strategy metadata from a local game-data snapshot."""

import argparse
import hashlib
import json
import re
from collections import Counter
from pathlib import Path


HERE = Path(__file__).resolve().parent
EXCEL = HERE.parent / "ArknightsGameResource" / "gamedata" / "excel"
OUTPUT = HERE / "autochess_strategy_data.json"
SEMANTICS = HERE / "autochess_strategy_semantics.json"

TRIGGERS = {
    "IN_BATTLE": "battle",
    "SERVER_BATTLE_FIN": "prep_start",
    "SERVER_CHESS_SOLD": "sell",
    "SERVER_GAIN": "gain",
    "SERVER_PREP_FIN": "prep_end",
    "SERVER_PREP_START": "prep_start",
    "SERVER_REFRESH_SHOP": "refresh",
}
PLACEMENT = {"MELEE": ["ground"], "RANGED": ["high"], "ALL": ["ground", "high"]}
PROFESSION_ROLES = {
    "PIONEER": ["damage"],
    "WARRIOR": ["damage"],
    "TANK": ["blocker"],
    "SNIPER": ["damage"],
    "CASTER": ["damage"],
    "MEDIC": ["heal"],
    "SUPPORT": [],
    "SPECIAL": [],
}
# These Caster branches focus their basic attacks on one target. Skills can still hit multiple enemies.
SINGLE_TARGET_CASTER_BRANCHES = {"corecaster", "funnel", "mystic"}
CONDITION_MODES = {
    "count_threshold_upward": "distinct",
    "count_threshold_downward": "distinct",
    "count_threshold_upward_golden": "elite",
}
TAGS = {"growth", "production", "damage", "survival"}


def read_json(path):
    return json.loads(path.read_bytes())


def strip_tags(text):
    return re.sub(r"<[@$][^>]+>|</>", "", text or "")


def blackboard(values):
    return {
        value["key"]: value["value"] if value.get("valueStr") is None else value["valueStr"]
        for value in values
    }


def select_season(activity, activity_id, version):
    seasons = activity["activity"]["AUTOCHESS"]
    if not activity_id:
        activity_id = max(
            seasons, key=lambda key: (activity["basicInfo"][key]["startTime"], key)
        )
    versions = seasons[activity_id]
    if not version:
        info = activity["autoChessData"]["versionInfoDict"]
        version = max(versions, key=lambda key: (
            info.get(key, {}).get("startTime", 0),
            info.get(key, {}).get("sortId", 0),
            key,
        ))
    return activity_id, version, versions[version]


def effect_targets(values):
    return values.replace(" ", "").split(",") if values else []


def unit_effect(effect_id, data, memberships):
    # 结构字段提供触发和参数，说明文本补充整备区和临时层语义。无法归类时由调用方保留效果 ID。
    event_type = data["eventType"]
    effect_type = data["effectType"]
    trigger = TRIGGERS.get(event_type)
    params = blackboard(data.get("blackboard", []))
    description = strip_tags(data.get("description"))
    if not trigger:
        return None
    condition = params.get("conditionkey")
    if condition not in (None, "character_target_inboard"):
        return None
    zone = "board"
    if trigger in ("gain", "sell") or "此干员在整备区也生效" in description:
        zone = "any"
    effect = {"sourceId": effect_id, "trigger": trigger, "zone": zone}

    if effect_type == "SERVER_ADD_BOND":
        effect.update(kind="stacks", amount=params["count"], targets=effect_targets(params["bond"]))
    elif effect_type == "SERVER_ADD_BOND_ACTIVATED_MOST_LAYER":
        effect.update(kind="stacks", amount=params["count"], targetMode="active_highest")
    elif effect_type == "SERVER_GAIN_BOND_LAYER_BY_REFRESH_CNT":
        effect.update(
            kind="stacks", amount=params["layer"], targets=effect_targets(params["bond"]),
            refreshCount=params["refresh_cnt"],
        )
    elif effect_type == "ADD_BOND" and params.get("bond_add_type") == "by_count":
        targets = effect_targets(params.get("bond_id"))
        if params.get("bond_type") == "bond_self":
            targets = memberships
        event = params.get("garrison_event_key")
        if not targets or not event:
            return None
        effect.update(kind="stacks", amount=params["bond_add_count"], targets=targets, event=event)
        cap = params.get("max_add_count_per_battle")
        if cap is not None and cap > 0:
            effect["cap"] = cap
    elif effect_type == "SERVER_GAIN_FREE_REFRESH_COUNT":
        effect.update(kind="free_refresh", amount=params["count"])
    elif effect_type == "SERVER_ONCE_GOLD":
        effect.update(kind="gold", amount=params["count"], nextRound=True)
    elif effect_type in ("SERVER_GAIN_EQUIP", "SERVER_POOL_EQUIP") and trigger == "gain":
        amount = params.get("count", 1)
        if not isinstance(amount, (int, float)) or amount < 1:
            return None
        effect.update(kind="resource", amount=amount, resource="equipment")
    else:
        return None

    if effect["kind"] == "stacks":
        effect["activeOnly"] = trigger != "gain" or "已激活" in description
        effect["temporary"] = params.get("bond_add_as_tmp") == 1 or "临时层数" in description
    return effect


def unit_roles(character, memberships, effects, sources, bonds):
    roles = list(PROFESSION_ROLES.get(character["profession"], []))
    if character.get("subProfessionId") in SINGLE_TARGET_CASTER_BRANCHES:
        roles.append("single_target")
    if memberships:
        roles.append("bond_member")
    if any(effect["kind"] == "stacks" for effect in effects) or any(
        source["effectType"] == "ADD_BOND"
        or source["effectType"].startswith(("SERVER_ADD_BOND", "SERVER_CONVERT_TEMP_BOND"))
        for source in sources
    ):
        roles.append("stacker")
    if any(
        "弱点伤害" in strip_tags(source.get("description"))
        or (source["effectType"] == "GAIN_BUFF" and blackboard(source["blackboard"]).get("atk", 0) > 0)
        for source in sources
    ):
        roles.append("carry")
    if any(
        effect["zone"] == "any" and effect["trigger"] in ("prep_end", "prep_start", "refresh")
        for effect in effects
    ) or any(bonds[bond_id]["countZone"] == "board_bench" for bond_id in memberships):
        roles.append("bench")
    return roles


def export_units(season, characters, bonds):
    levels = season["shopCharChessInfoData"]
    chess_data = season["charChessDataDict"]
    garrisons = season["garrisonDataDict"]
    units = {}
    skipped = Counter()
    for base_id, shop in season["charShopChessDatas"].items():
        if shop.get("isHidden"):
            skipped["hidden"] += 1
            continue
        char_id = shop.get("charId")
        if not char_id:
            skipped["custom"] += 1
            continue
        character = characters[char_id]
        tier = shop["chessLevel"]
        for chess_id in (base_id, shop["goldenChessId"]):
            raw = chess_data[chess_id]
            elite = raw["isGolden"]
            price = next(
                (entry["purchasePrice"] for entry in levels[str(tier)] if entry["isGolden"] == elite),
                None,
            )
            memberships = list(raw.get("bondIds") or [])
            effects, unsupported, sources = [], [], []
            for effect_id in raw.get("garrisonIds") or []:
                data = garrisons[effect_id]
                sources.append(data)
                description = strip_tags(data.get("description"))
                if data["effectType"] == "SERVER_CHESS_PRICE":
                    fixed_price = re.fullmatch(r"购买价格为\s*(\d+)", description)
                    if fixed_price:
                        price = int(fixed_price[1])
                        continue
                if data["effectType"] == "NONE":
                    continue
                try:
                    effect = unit_effect(effect_id, data, memberships)
                except KeyError:
                    effect = None
                if effect is None:
                    unsupported.append(effect_id)
                else:
                    effects.append(effect)
            unit = {
                "name": character["name"],
                "charId": char_id,
                "prof": character["profession"],
                "tier": tier,
                "group": base_id,
                "elite": elite,
                "upgradeCount": raw["upgradeNum"],
                "bonds": memberships,
                "roles": unit_roles(character, memberships, effects, sources, bonds),
                "effects": effects,
            }
            if raw.get("upgradeChessId"):
                unit["upgradeTo"] = raw["upgradeChessId"]
            if price is not None:
                unit["price"] = price
            if character.get("position") in PLACEMENT:
                unit["placement"] = PLACEMENT[character["position"]]
            if unsupported:
                unit["unsupportedEffectIds"] = unsupported
            units[chess_id] = unit
    return units, dict(skipped)


def alliance_tiers(minimum, phase, semantic):
    phase_type = phase["phaseType"]
    thresholds = phase["bondPhaseCountList"]
    if phase_type == 1:
        tiers = [{"count": count} for count in sorted({minimum, *thresholds})]
    elif phase_type == 2:
        tiers = [{"count": minimum}]
        tiers.extend({"count": minimum, "stacks": limit} for limit in sorted(set(thresholds) - {0}))
    elif phase_type == 0:
        tiers = [{"count": minimum}]
    else:
        return [{"count": minimum, "tags": [], "scope": "members", "unscored": True}]
    styles = semantic.get("tiers", [])
    for index, tier in enumerate(tiers):
        tier.update(tags=[], scope="members", unscored=True)
        if index < len(styles):
            tier.pop("unscored")
            tier.update(styles[index])
    tiers.extend(semantic.get("extraTiers", []))
    return tiers


def bond_fingerprint(raw, phase, parts):
    source = {
        "activation": [raw[key] for key in (
            "activeConditionTemplate", "activeParamList", "activeCount", "isActiveInDeck", "noStack"
        )],
        "description": strip_tags(raw.get("desc")),
        "phase": phase,
        "parts": parts,
    }
    encoded = json.dumps(source, ensure_ascii=False, sort_keys=True).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def export_bonds(season, semantics):
    bonds = {}
    for bond_id, raw in season["bondInfoDict"].items():
        source_id = raw["effectId"]
        template = raw["activeConditionTemplate"]
        minimum = raw["activeCount"]
        phase = season["effectDescParamDataDict"].get(
            source_id, {"phaseType": -1, "bondPhaseCountList": []}
        )
        parts = season["effectBuffInfoDataDict"].get(source_id, [])
        fingerprint = bond_fingerprint(raw, phase, parts)
        semantic = semantics.get(bond_id, {})
        # 效果 ID 与原表指纹都匹配才沿用人工标注，规则变更后重新复核。
        if semantic.get("sourceId") != source_id or semantic.get("sourceFingerprint") != fingerprint:
            semantic = {}
        bond = {
            "name": raw["name"],
            "sourceId": source_id,
            "sourceFingerprint": fingerprint,
            "countZone": "board_bench" if raw["isActiveInDeck"] else "board",
            "countMode": semantic.get("countMode", CONDITION_MODES.get(template, "distinct")),
            "minCount": minimum,
            "tiers": alliance_tiers(minimum, phase, semantic),
            "stackable": not raw["noStack"],
        }
        if template == "count_threshold_downward":
            bond["maxCount"] = int(raw["activeParamList"][1]) - 1
        if template not in CONDITION_MODES:
            for tier in bond["tiers"]:
                tier["unscored"] = True
        if "countZone" in semantic:
            bond["countZone"] = semantic["countZone"]
        for part in parts:
            params = blackboard(part["blackboard"])
            if part["key"] == "bond_activated_add_layer":
                low = {
                    "trigger": "prep_end", "zone": "board", "kind": "stacks",
                    "targetMode": "active_all", "activeOnly": True, "temporary": False,
                    "amount": params["layer"], "minCount": minimum, "maxCount": params["count"] - 1,
                }
                high = {
                    key: value for key, value in low.items() if key != "maxCount"
                }
                high.update(minCount=params["count"], amount=params["more_layer"])
                bond.setdefault("effects", []).extend((low, high))
            elif part["key"] == "other_bond_add_trigger_cnt":
                bond["activationCountBonus"] = {"amount": params["count"], "target": "core_bond"}
            elif part["key"] == "bond_layer_gain_coin":
                bond["stackReward"] = {"interval": params["layer"], "amount": params["count"], "kind": "gold"}
        bonds[bond_id] = bond
    return bonds


def export_modes(season, bonds):
    constants = season["constData"]
    modes = {}
    mode_ids = season["modeGroupDataDict"]["GROUP_SINGLE"]["modeIds"]
    for mode_id in mode_ids:
        battles = season["battleDataDict"][mode_id]
        shop = season["shopLevelDataDict"][mode_id]
        mode_data = season["modeDataDict"][mode_id]
        boss_rounds = sorted(int(round_no) for round_no, entries in battles.items() if any(
            entry.get("bossId") for entry in entries
        ))
        hard_rounds = sorted(int(round_no) for round_no, entries in battles.items() if any(
            re.search(r"_h\d+", entry["levelId"]) and not entry.get("bossId") for entry in entries
        ))
        active = mode_data["activeBondIdList"]
        if any(bond_id not in bonds for bond_id in active):
            raise ValueError(f"{mode_id} references an undefined active alliance")
        modes[mode_id] = {
            "firstHardRound": hard_rounds[0],
            "bossRound": boss_rounds[0],
            "bossRounds": boss_rounds,
            "maxRound": max(map(int, battles)),
            "specialRounds": sorted(
                int(round_no) for round_no, entries in battles.items() if any(
                    entry["isSpPrepare"] for entry in entries
                )
            ),
            "activeBonds": active,
            "maps": [key for key, value in season["stageDatasDict"].items() if mode_id in value["mode"]],
            "shop": [
                {
                    "level": shop[key]["shopLevel"],
                    "slots": shop[key]["charChessCount"],
                    "itemSlots": shop[key]["itemCount"],
                    "upgradePrice": shop[key]["initialUpgradePrice"],
                }
                for key in sorted(shop, key=int)
            ],
            "refreshPrice": constants["shopRefreshPrice"],
            "benchLimit": constants["maxDeckChessCnt"],
            "boardLimit": constants["maxBattleChessCnt"],
        }
    return modes


def export_teams(season):
    teams = {}
    for team_id, raw in season["bandDataListDict"].items():
        description = strip_tags(raw.get("bandDesc"))
        interest = re.search(r"剩余至少\s*(\d+)\s*资金时，每回合额外获得\s*(\d+)\s*资金", description)
        if "剩余的资金可以继承" in description and interest:
            teams[team_id] = {
                "carryGold": True,
                "interestThreshold": int(interest[1]),
                "interestAmount": int(interest[2]),
                "sourceId": raw["effectId"],
            }
    return teams


def validate(units, bonds, modes):
    for unit_id, unit in units.items():
        if set(unit["bonds"]) - bonds.keys() or unit["group"] not in units:
            raise ValueError(f"{unit_id} references an undefined alliance or merge group")
        upgrade = unit.get("upgradeTo")
        if upgrade and (
            upgrade not in units
            or not units[upgrade]["elite"]
            or units[upgrade]["group"] != unit["group"]
            or unit["upgradeCount"] < 2
        ):
            raise ValueError(f"{unit_id} has an invalid merge")
        for effect in unit["effects"]:
            if set(effect.get("targets", [])) - bonds.keys() or effect["amount"] < 0:
                raise ValueError(f"{unit_id} has an invalid normalized effect")
    for bond_id, bond in bonds.items():
        for tier in bond["tiers"]:
            if set(tier["tags"]) - TAGS or tier["scope"] not in ("team", "members"):
                raise ValueError(f"{bond_id} has an invalid semantic category")
    for mode_id, mode in modes.items():
        if not 1 <= mode["firstHardRound"] <= mode["bossRound"] <= mode["maxRound"]:
            raise ValueError(f"{mode_id} has an invalid round progression")


def export(activity, characters, semantics, activity_id=None, version=None):
    activity_id, version, season = select_season(activity, activity_id, version)
    bonds = export_bonds(season, semantics)
    units, skipped = export_units(season, characters, bonds)
    modes = export_modes(season, bonds)
    validate(units, bonds, modes)
    return {
        "schemaVersion": 1,
        "season": f"{activity_id} {version}",
        "units": units,
        "bonds": bonds,
        "modes": modes,
        "teams": export_teams(season),
        "coverage": {
            "skippedShopUnits": skipped,
            "unsupportedEffectIds": sorted({
                effect_id for unit in units.values() for effect_id in unit.get("unsupportedEffectIds", [])
            }),
            "unscoredBondIds": sorted(
                bond_id for bond_id, bond in bonds.items() if any(tier.get("unscored") for tier in bond["tiers"])
            ),
        },
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--activity-table", type=Path, default=EXCEL / "activity_table.json")
    parser.add_argument("--character-table", type=Path, default=EXCEL / "character_table.json")
    parser.add_argument("--semantics", type=Path, default=SEMANTICS)
    parser.add_argument("--activity-id")
    parser.add_argument("--version")
    parser.add_argument("--output", type=Path, default=OUTPUT)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    try:
        data = export(
            read_json(args.activity_table), read_json(args.character_table), read_json(args.semantics),
            args.activity_id, args.version,
        )
        # 导出和 --check 共用确定性序列化，便于按 ID 检查两版资源差异。
        payload = json.dumps(data, ensure_ascii=False, sort_keys=True, indent=2) + "\n"
        if args.check:
            if not args.output.is_file() or args.output.read_text(encoding="utf-8") != payload:
                parser.exit(1, f"Resource differs from the current inputs: {args.output}\n")
        else:
            args.output.write_bytes(payload.encode("utf-8"))
    except (OSError, KeyError, ValueError) as error:
        parser.exit(1, f"Export failed: {error}\n")
    print(f"{data['season']}: {len(data['units'])} unit variants, {len(data['bonds'])} alliances, "
          f"{len(data['modes'])} modes, {len(data['coverage']['unsupportedEffectIds'])} unsupported effects")


if __name__ == "__main__":
    main()
