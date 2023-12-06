<h1 align="center"> ArkLights</h1>

<p align="center">
ArkLights is the <b> lightning fast</b> and <b> fully managed</b> Arknights game helper</a>
</p>

<p align="center">明日方舟速通 —— 高效的明日方舟全托管APP</a> </p>


![](cover.jpg)

## 使用指南

[【必读】快速开始使用ArkLights](docs/guide.md)

## 参与开发

1. 内置函数参考[懒人精灵无障碍模式IDE](http://bbs.lrappsoft.com/forum.php?mod=forumdisplay&fid=2)内文档

1. 调试

    懒人精灵中新建项目main，利用saverun转码为项目文件后调试
    ```sh
    # in linux
    ./0.sh saverun
    # in windows
    python3 ./0.py saverun
    ```
    调试时在main.lua中启用日志
    ```txt
    always_enable_log
    ```

1. 发布
    ```sh
    # in linux
    ./0.sh release
    # in windows
    python3 ./0.py release
    ```
    
1. 数据提取
    ```sh
    # 解包
    https://github.com/jxr2006/ArkAssetsTool
    # 提取基建图标数据
    ./0.sh buildingskill
    # 提取公招保底组合
    ./0.sh recruit
    # 提取活动关卡坐标
    ./extract.py screencap 1,2,3
    ./extract.py screencap_distance
    ```
    
    更多说明请参考 [开发与贡献指南](./docs/development.md)

## 错误反馈

请详细的描述错误的复现场景并简明扼要的阐述你的问题，一个好的issue有助于开发者快速解决问题。

## 数据收集协议
使用本仓库的Release版本即视为您同意项目组收集以下信息用于数据统计
- 唯一识别码
- 多账号数量

## 其他相关项目

- [伊比利亚审判庭](https://ark.aegirtech.com/) 在线全日制云端托管，解放你的双手，使用本服务亦是对开发的支持



