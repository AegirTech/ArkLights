<h1 align="center">ArkLights</h1>

<p align="center">
<b>Lightning fast</b> and <b>fully managed</b> Arknights game helper
</p>

<p align="center">明日方舟速通 —— 高效的明日方舟全托管自动化助手</p>

![](cover.jpg)

## 功能特性

### 日常任务全自动

一键完成每日/每周任务、基建轮换、公招、信用商店、线索传递等日常操作，支持定时任务与多账号切换。

### 基建技能识别

自动识别并编排基建干员，基于技能图标匹配最优排班方案（[skill.lua](skill.lua)）。

### 集成战略（肉鸽）

支持多种集成战略模式的自动化攻略：

- 水月与深蓝之树（[roguelike/mizuki.lua](roguelike/mizuki.lua)）
- 探索者的银凇止境（[roguelike/sami.lua](roguelike/sami.lua)）
- 萨卡兹的无终奇语（[roguelike/sarkaz.lua](roguelike/sarkaz.lua)）
- 岁家集成战略（[roguelike/sui.lua](roguelike/sui.lua)）

### 生息演算

沙盘模式自动采集、建造与探索（[sand.lua](sand.lua)）。

### 促融共竞

多人合作模式自动化（[icebreaker.lua](icebreaker.lua)）。

### 自动作战

基于 [PRTS.MAA](https://prts.maa.plus/) 的作业站，支持在线/本地作业获取与自动代理作战（[prts.lua](prts.lua)）。

### 干员培养

自动识别待培养干员，按设定优先级完成升级、技能专精、模组等操作（[raise.lua](raise.lua)）。

### 云控

远程任务调度与状态同步，支持云端管理多设备（[cloud.lua](cloud.lua)）。

### 森空岛集成

自动完成森空岛签到与任务（[skland.lua](skland.lua)）。

### 飞桨 OCR

基于 PaddleOCR 的文字识别，用于作业站本地字库（[exOcr.lua](exOcr.lua)）。

## 快速开始

请参阅 [开发与使用指南](docs/CLAUDE.md) 了解环境搭建与基本用法。

> **运行环境要求**：懒人精灵（LazyRanger）Android 自动化框架，主体代码基于 Lua，需在安卓设备或模拟器上运行。

## 架构概览

```
ArkLightsPlus/
├── main.lua          # 入口，加载所有模块
├── path.lua          # 状态机与任务调度
├── point.lua         # 全局识图点位与颜色模板
├── util.lua          # 核心工具层（find/tap/wait/auto）
├── interface.lua     # 动态 UI 构建
├── func.lua          # 游戏交互工具函数
├── skill.lua         # 基建技能识别与编排
├── raise.lua         # 干员培养逻辑
├── prts.lua          # 代理作战 / PRTS 作业站
├── sand.lua          # 生息演算
├── icebreaker.lua    # 促融共竞
├── cloud.lua         # 云控
├── skland.lua        # 森空岛
├── exOcr.lua         # 飞桨 OCR
├── tag.lua           # 公招标签
├── lr_api.lua        # 懒人精灵 API 声明
├── roguelike/        # 集成战略（肉鸽）脚本
├── res/              # 处理后资源（地图/干员/图标数据）
├── 0.py / 0.sh       # 构建/调试/发布工具
└── extract.py        # 资源解包与数据提取
```

## 参与开发

### 环境准备

1. 安装 [懒人精灵 IDE](http://bbs.lrappsoft.com/)，新建项目 `main`
2. 配置 `localConfig.py`（首次运行 `0.py` 会自动生成模板）

### 调试

将 Lua 脚本转换为懒人精灵工程文件并加载运行：

```sh
# Windows
python3 ./0.py saverun

# Linux
./0.sh saverun
```

调试时在 [main.lua](main.lua) 中启用详细日志：

```lua
always_enable_log = true
```

### 发布

```sh
# Windows
python3 ./0.py r      # 脚本发版（打包脚本）
python3 ./0.py rs     # 基建技能压缩包发版（skill.zip）
python3 ./0.py rm     # 地图包发版（maps.zip）

# Linux
./0.sh release
```

地图数据更新通过 GitHub Action `map_update.yml` 每日自动同步并发布，也可本地运行：

```sh
python res/maps/maps.py           # 生成并发布（CI 使用；--no-upload 仅生成）
```

脚本从 [Arknights-Bot-Resource](https://github.com/yuanyan3060/Arknights-Bot-Resource) 在线拉取关卡数据，计算格子屏幕坐标后在内存中打包输出到 `res/maps.zip`，不在本地生成中间地图 json；发布使用 `python3 ./0.py rm`。

### 数据提取

```sh
# 解包工具
# https://github.com/jxr2006/ArkAssetsTool

# 提取基建技能图标
./0.sh buildingskill

# 提取公招保底组合
./0.sh recruit

# 提取活动关卡坐标
./extract.py screencap 1,2,3
./extract.py screencap_distance

# 提取基建数据
./extract.py process_transparent_pixels   # 基建图标
./extract.py skillicon2operator           # 基建 JSON → skill.zip
```

更多说明请参考 [开发指南](docs/CLAUDE.md)。

## 错误反馈

请详细描述错误的复现场景并简明扼要地阐述问题。一个好的 issue 有助于开发者快速定位和修复。

## 数据收集协议

使用本仓库的 Release 版本即视为您同意项目组收集以下信息用于数据统计：

- 唯一识别码
- 多账号数量

## 其他相关项目

- [伊比利亚审判庭](https://ark.aegirtech.com/) — 在线全日制云端托管，解放你的双手，使用本服务亦是对开发的支持
