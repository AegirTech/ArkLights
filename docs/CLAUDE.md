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
python3 ./0.py rs         # Windows：基建技能图标包skill.zip 发布
python3 ./0.py rm         # Windows：地图包maps.zip 发布
./0.sh release            # Linux

# 地图数据更新：优先读 res/ArknightsGameResource 子模块的 levels.json（缺失时回退在线拉取），内存打包输出 res/maps.zip（不生成中间 json）
python res/maps/maps.py            # 生成并调用 0.py rm 发布（GitHub Action 每日调用；--no-upload 仅生成）

# 干员数据更新
python res\char_type\parse_character_table.py

# 资源提取
./extract.py buildingskill                   # 基建数据一步生成 res/skill.zip（图标默认取子模块 building_skill，中间产物仅保留 res/skillicon2operator.json）
./0.sh recruit                               # 提取公招组合
./extract.py screencap 1                     # 活动关卡截图（满右滑首页起，逐页左滑，自动存720p）
./extract.py screencap_distance2             # 计算活动关卡点位与滑动距离
./extract.py auto_center                     # 按 point 分布自动补齐 center 表九宫格锚点（write=False 仅预览）
```

基建图标单独处理仍可用原方法：`process_transparent_pixels(input_folder, output_folder)`（去透明化）与 `skillicon2operator()`（映射 json 写入 `ArknightsGameResource/new` 并打包）。

活动关卡坐标约定：`screencap_distance2` 读取 `screencap/*.png`（720p，第一张必须是满右滑后的首页，相邻页需有重叠关卡），输出 `point.作战列表` 与 `distance` 两张表。`-ST-`、`TR-`、`-P-`、`-MO-` 关输出蓝色六边形比色点，其余输出点击坐标；首页已可见且横坐标小于 `point_x` 的关卡 `distance` 输出 0 并使用真实坐标；`-EX-`、`-S-`、`-MO-` 关单独成页，默认不滑动、直接输出当前页真实坐标且不输出 `distance`。滑动距离 = `(720p实测距离 + shift_right) × distance_coefficient`，默认系数 1.11，落点不符时按实测微调。

center 锚点约定（非16:9 适配）：center 表为 point 条目指定小键盘 1-9 九宫格定位（1=左下 2=下 3=右下 4=左 5=中 6=右 7=左上 8=上 9=右上），值为裸数字，或 `{ 数字, "缩放模式" }`（模式 `"maxscale"`/`"maxscalex"`/`"anisotropy"`，缺省按 minscale 等比）。模式反映目标屏幕如何渲染该界面（如系统设置页、基建设施页会拉伸），无法从点位几何推断，须人工指定；无 center 的条目默认锚点 7（左上）。`point2center` 纯数字驱动：列 `(锚点-1)%3`、行 `(锚点-1)//3`，参考点=序号×端点（origin 用 1920x1080 基线端点，new 用实际屏幕端点）；`convert_coords` 据此把基线坐标换算到实际分辨率。旧词组（`left_top` 等）与显式坐标对写法已废弃。

## 架构概览

- **`main.lua`** — 入口。通过 `require` 加载所有模块；顶部设置调试、日志、计时等开关，`always_enable_log` 可开启详细日志。
- **`util.lua`** — 主要工具层。重点函数：`findOne`、`findAny`、`tap`、`wait`、`appear`、`disappear`、`update`、`auto`、`deploy`、`scale`。接入新逻辑时优先复用，不要重复造轮子。
- **`point.lua`** — 全局识图点位、颜色模板、点击锚点。开发前先查此处是否已有对应点位，优先复用，不要随意新造重复点名。
- **`path.lua`** — 主要操作函数与状态跳转入口。`path.base`、`path.fallback`、各业务路径表均由此调度。对接自动机时需兼容此处的调用方式。
- **`interface.lua`** — 动态 UI 构建。涉及参数开关、输入框、任务入口时先参考此处已有布局和命名。
- **`lr_api.lua`** — 懒人精灵 API 声明文挡，包含 `sleep`、`clickPoint`、UI 接口等底层非标准lua库能力签名。
- **`func.lua`** — 游戏交互工具函数。
- **`raise.lua`** — 干员培养逻辑函数。
- **`prts.lua`** — 地图/代理作战操作：在线/本地地图包更新（`fetchMaps`、`fetchLocalMaps`）、通过 `https://prts.maa.plus/copilot` API 拉取和点赞代理作战作业。
- **`skill.lua`** — 基建技能识别与选择逻辑。
- **`skland.lua`** — 森空岛平台集成。
- **`0.py` / `0.sh`** — 构建/发布/调试工具脚本。
- **`extract.py`** — 资源解包与数据提取（依赖 UnityPy、pycryptodome）。
- **`res/ArknightsGameResource`** — 游戏数据子模块（稀疏检出，仅 building_skill、6 个 excel 表与 levels.json）。`extract.py`、`res/char_type/parse_character_table.py`、地图脚本优先读它，子模块缺失时回退在线拉取。稀疏模式不随仓库分发：其他开发者首次检出后运行 `python 0.py agrinit`（或 `./0.sh agrinit`）完成初始化+稀疏检出；0.py 与 0.sh 各持一份模式列表，**需与本地 `.git/modules/.../info/sparse-checkout` 三处同步**，改数据需求时缺一不可。同步最新数据用 `git submodule update --remote res/ArknightsGameResource`（重生成 maps.zip 前必须先同步，否则用的是固定快照）。
- **`.env`** — 本地配置（路径、打包、token，已 gitignore）；模板见 `.env.example`。

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

- 在 1920 \* 1080 分辨率环境下开发，为了稳定性和多分辨率适应，取色应该保证像素点与周围8个像素颜色一致
- 优先使用 `findOne` / `findAny` 做检测，使用 `tap` 执行点击。
- point表中已经声明的键值对可以直接调用键值字符串，比如 `findOne(key)`,`tap(key)`,等价于`findOne(point.key)`,`tap(point.key)`
- 新增点位后 center 通常不用手写：运行 `python extract.py auto_center` 自动补齐（点位按点组主要分布区域投票、第一个点计两票；范围取中心位置），生成行尾带"自动补齐"注释的条目；`--refresh` 删旧自动补齐行按当前规则重算，`--modes='{"键":"模式"}'` 注入已知缩放模式
- 状态机优先兼容 `auto(update(path.base, ...))` 这套速通风格。
- 新增注释优先使用中文，说明"为什么这样接"，而不是只描述表面动作。
- 地图与代理作战数据使用 JSON 格式；地图更新可通过 GitHub Action `map_update.yml` 同步。

## 需要避免的事情

- 不要假设该项目能在通用 Lua 环境直接运行。
- 不要绕过 `util.lua` 自己实现一套新的 `wait`/`find`/`tap`/`auto`。
- 不要忽略 `point.lua` 里已有的同名或近似点位。
