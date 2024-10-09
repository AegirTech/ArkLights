$directories = @('.venv', 'venv', 'env')
$pyPath = $null

foreach ($d in $directories) {
    if (Test-Path "$d\Scripts\python.exe") {
        $pyPath = "$d\Scripts\python.exe"
        break
    }
}

if (-not $pyPath) {
    Write-Host "未找到 Python 可执行文件。"
    exit
}

Write-Host "找到 Python 可执行文件: $pyPath"

Write-Host "请选择一个选项:"
Write-Host "1) 关卡distance计算"
Write-Host "2) 基建技能数据转换"
Write-Host "3) 基建图标转换(透明背景）"
Write-Host "4) 公招组合提取"
Write-Host "5) 干员数据提取(抄作业）"
Write-Host "6) 地图数据(抄作业）"

$choice = Read-Host "请输入你的选择"

switch ($choice) {
    '1' { & $pyPath extract.py screencap_distance }
    '2' { & $pyPath extract.py skillicon2operator }
    '3' {
        $userPath = Read-Host "请输入图标文件夹路径"
		$parentPath = [System.IO.Path]::GetDirectoryName((Get-Item $userPath).FullName)
		$newPath = Join-Path $parentPath "skill_new"
        & $pyPath extract.py process_transparent_pixels $userPath $newPath
    }
    '4' { & $pyPath extract.py recruit }
    '5' { & $pyPath res\char_type\parse_character_table.py }
    '6' { & $pyPath res\maps\maps.py }
    default { Write-Host "无效的选择，请重新运行脚本并选择有效选项。" }
}

Pause
