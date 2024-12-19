:: 可能需要手动处理一下编码问题，此脚本编码utf-8可能运行不了
@echo off
setlocal enabledelayedexpansion

set "directories=.venv venv env"

for %%d in (%directories%) do (
    if exist "%%d\Scripts\python.exe" (
        set "py_path=%%d\Scripts\python.exe"
        goto :found
    )
)

echo 未找到 Python 可执行文件。
exit /b

:found
echo 找到 Python 可执行文件: %py_path%

echo 请选择一个选项:
echo 1) 关卡distance计算
echo 2) 基建技能数据转换
echo 3) 基建图标转换(透明背景）
echo 4) 公招组合提取
echo 5) 干员数据提取(抄作业）
echo 6) 地图数据(抄作业）

set /p choice=请输入你的选择: 

if "%choice%"=="1" (
    "%py_path%" extract.py screencap_distance
) else if "%choice%"=="2" (
    "%py_path%" extract.py skillicon2operator
) else if "%choice%"=="3" (
    echo 请输入图标文件夹路径:
    set /p user_path=路径: 
	set "parent_path=!user_path!"
	if "!parent_path:~-1!"=="\" set "parent_path=!parent_path:~0,-1!"
	for %%i in ("!parent_path!") do set "parent_path=%%~dpi"
	set "parent_path=!parent_path:~0,-1!"
	set "new_path=!parent_path!\skill_new"
    "%py_path%" extract.py process_transparent_pixels "!user_path!" "!new_path!"
) else if "%choice%"=="4" (
    "%py_path%" extract.py recruit
) else if "%choice%"=="5" (
    "%py_path%" res\char_type\parse_character_table.py
) else if "%choice%"=="6" (
    "%py_path%" res\maps\maps.py
) else (
    echo 无效的选择，请重新运行脚本并选择有效选项。
)

pause
