# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ArkLights is a fully managed Arknights (明日方舟) game automation helper. It runs on the 懒人精灵 (LR) automation framework for Android. The codebase is primarily Lua scripts with Python tooling for resource extraction and release management.

## Common Commands

```sh
# Debug (converts and loads into 懒人精灵 project)
python3 ./0.py saverun    # Windows
./0.sh saverun            # Linux

# Release
python3 ./0.py r          # Windows: script release
python3 ./0.py rs         # Windows: skill.zip release
./0.sh release            # Linux

# Map data update
python res/maps/maps.py

# Resource extraction
./0.sh buildingskill      # Extract base skill icons
./0.sh recruit            # Extract recruitment combos
./extract.py screencap 1,2,3          # Extract event stage coordinates
./extract.py process_transparent_pixels  # Extract base icons
./extract.py skillicon2operator          # Extract base JSON → skill.zip
```

## Architecture

- **`main.lua`** — Entry point. Loads all modules via `require`. Configuration flags (debug, logging, timing) are set at the top. `always_enable_log` enables debug logging.
- **`prts.lua`** — Map/copilot operations: online/local map package updates (`fetchMaps`, `fetchLocalMaps`), copilot homework fetching and liking via `https://prts.maa.plus/copilot` API.
- **`func.lua`, `util.lua`, `point.lua`, `path.lua`** — Core utility modules for game interaction, coordinate handling, and navigation.
- **`interface.lua`** — UI configuration interface (uses `main.ui` layout).
- **`skill.lua`, `raise.lua`** — Base building skill management and operator raising logic.
- **`skland.lua`** — Skland platform integration.
- **`0.py` / `0.sh`** — Build/release/debug tooling scripts.
- **`extract.py`** — Resource unpacking and data extraction (depends on UnityPy, pycryptodome).
- **`localConfig.py`** — Local configuration for paths, logging, packaging (gitignored).

### Key Directories

- **`ArknightsGameResource/`** — Game resource data (characters, skills, etc.)
- **`res/`** — Processed resources (UI assets, map data scripts)
- **`roguelike/`** — Integrated Security (肉鸽) mode data

## Dependencies

Python: `numpy`, `requests` (see `requirements.txt`). Some Windows-only deps: `win32gui`, `pywin32`.

## Key Patterns

- Lua modules are loaded via `require` from `main.lua`
- Map and copilot data uses JSON format
- Game resource data must be periodically synced from upstream; map updates can use GitHub Action `map_update.yml`
- The framework targets Android via 懒人精灵's accessibility mode; built-in functions are documented in the LR IDE
