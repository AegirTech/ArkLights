# CLAUDE.md

本文件为 Claude Code 在此仓库工作时提供指导。

## 项目定位

ArkLightsPlus 是基于懒人精灵平台开发的明日方舟全托管自动化脚本。底层运行在安卓设备的懒人精灵（LR）自动化框架上，主体代码为 Lua，另有 Python 工具链负责资源提取和发包。

代码无法在普通 Lua 解释器中直接跑通，很多能力依赖懒人精灵运行时与设备环境。进行功能开发时，优先保证逻辑连贯、接口对齐、点位命名一致，不要求在当前工作区直接执行验证。

## 常用命令

```sh
# 调试（转换并加载到懒人精灵工程）
python3 ./0.py saverun    # Windows
./0.sh saverun            # Linux

# 发布
python3 ./0.py r          # Windows：脚本发布
python3 ./0.py rs         # Windows：skill.zip 发布
./0.sh release            # Linux

# 地图数据更新
python res/maps/maps.py

# 资源提取
./0.sh buildingskill                         # 提取基建技能图标
./0.sh recruit                               # 提取公招组合
./extract.py screencap 1,2,3                 # 提取活动关卡坐标
./extract.py process_transparent_pixels      # 提取基建图标
./extract.py skillicon2operator              # 基建 JSON → skill.zip
```

## 架构概览

- **`main.lua`** — 入口。通过 `require` 加载所有模块；顶部设置调试、日志、计时等开关，`always_enable_log` 可开启详细日志。
- **`util.lua`** — 主要工具层。重点函数：`findOne`、`findAny`、`tap`、`wait`、`appear`、`disappear`、`update`、`auto`、`deploy`、`scale`。接入新逻辑时优先复用，不要重复造轮子。
- **`point.lua`** — 全局识图点位、颜色模板、点击锚点。开发前先查此处是否已有对应点位，优先复用，不要随意新造重复点名。
- **`path.lua`** — 主要操作函数与状态跳转入口。`path.base`、`path.fallback`、各业务路径表均由此调度。对接自动机时需兼容此处的调用方式。
- **`interface.lua`** — 动态 UI 构建。涉及参数开关、输入框、任务入口时先参考此处已有布局和命名。
- **`lr_api.lua`** — 懒人精灵 API 声明文件，包含 `sleep`、`clickPoint`、UI 接口等底层能力签名。
- **`func.lua`** — 游戏交互工具函数。
- **`raise.lua`** — 培养逻辑函数。
- **`prts.lua`** — 地图/代理作战操作：在线/本地地图包更新（`fetchMaps`、`fetchLocalMaps`）、通过 `https://prts.maa.plus/copilot` API 拉取和点赞代理作战作业。
- **`skill.lua`、`raise.lua`** — 基建技能管理与干员培养逻辑。
- **`skland.lua`** — 森空岛平台集成。
- **`0.py` / `0.sh`** — 构建/发布/调试工具脚本。
- **`extract.py`** — 资源解包与数据提取（依赖 UnityPy、pycryptodome）。
- **`localConfig.py`** — 本地配置（路径、日志、打包，已 gitignore）。

### 关键目录

- **`res/`** — 处理后的资源（UI 素材、地图数据脚本、干员数据脚本）
- **`roguelike/`** — 集成战略（肉鸽）模式脚本

## 依赖

Python：`numpy`、`requests`（见 `requirements.txt`）。部分 Windows 专属依赖：`win32gui`、`pywin32`。

## 编写功能的建议顺序

1. 先查 `point.lua` 是否已有目标界面或按钮点位。
2. 再看 `util.lua` 是否已有可直接复用的通用函数。
3. 如果是路径跳转或自动机，参考 `path.lua` 现有组织方式。
4. 如果涉及参数开关或用户输入，再补 `interface.lua`。

## 常用调用模式

```lua
-- 单点等待并点击
wait(function() if findOne("某点") then tap("某按钮"); return true end end, 10)

-- 批量状态自动机
auto(update(path.base, { ["检测点"] = "点击点" }, nil, true), path.fallback)

-- 多候选识别
findAny({ "点1", "点2", "点3" })
```

## 开发约定

- 优先使用 `findOne` / `findAny` 做检测，使用 `tap` 执行点击。
- 状态机优先兼容 `auto(update(path.base, ...))` 这套速通风格。
- 新增注释优先使用中文，说明"为什么这样接"，而不是只描述表面动作。
- 地图与代理作战数据使用 JSON 格式；地图更新可通过 GitHub Action `map_update.yml` 同步。

## 需要避免的事情

- 不要假设该项目能在通用 Lua 环境直接运行。
- 不要绕过 `util.lua` 自己实现一套新的 `wait`/`find`/`tap`/`auto`。
- 不要忽略 `point.lua` 里已有的同名或近似点位。
