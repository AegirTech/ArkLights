import datetime
import hashlib
import os
import re
import sys
from time import sleep

import requests
import win32api
import win32com.client
import win32con
import win32gui

# win环境下的快速开发脚本
API = "http://ark.aegirtech.com:8080"

# 检查localConfig.py是否存在
if not os.path.exists("localConfig.py"):
    print("localConfig.py不存在，已自动创建，请配置路径")
    with open("localConfig.py", "w", encoding="utf-8") as f:
        f.write(
            "# main工程路径: \n"
            + "# 例: mainProjectPath = r"
            + r'"C:\Users\DazeCake\Documents\Tools\懒人精灵3.8.3\script\main"'
            + "\n"
            + 'mainProjectPath = r""\n'
            + "# 打包的main.lr路径: \n"
            + "# 例: lrPath = r"
            + r'"C:\Users\DazeCake\Documents\Tools\懒人精灵3.8.3\out\main.lr"'
            + "\n"
            + 'lrPath = r""\n\n'
            + "# 热更新token: \n"
            + 'token = ""\n'
        )
        exit()

# 检查localConfig.py是否配置
import localConfig as lc

if lc.mainProjectPath == "" or lc.lrPath == "":
    print("localConfig.py未配置，请配置路径")
    exit()
else:
    path = lc.mainProjectPath
    pkgPath = lc.lrPath


class WindowMgr:
    """Encapsulates some calls to the winapi for window management"""

    def __init__(self):
        """Constructor"""
        self._handle = None

    def find_window(self, class_name, window_name=None):
        """基于类名来查找窗口"""
        self._handle = win32gui.FindWindow(class_name, window_name)

    def _window_enum_callback(self, hwnd, class_name_wildcard_list):
        """传递给win32gui.EnumWindows()，检查所有打开的顶级窗口"""
        class_name, wildcard = class_name_wildcard_list
        if re.match(wildcard, str(win32gui.GetWindowText(hwnd))) is not None:
            self._handle = hwnd

    def find_window_wildcard(self, class_name, wildcard):
        """根据类名，查找一个顶级窗口，确保其类名相符，且标题可以用正则表达式匹配对应的通配符"""
        self._handle = None
        win32gui.EnumWindows(self._window_enum_callback, [class_name, wildcard])
        return self._handle

    def set_foreground(self):
        """put the window in the foreground"""
        win32gui.SetForegroundWindow(self._handle)

    def get_hwnd(self):
        """return hwnd for further use"""
        return self._handle


def run(now=True):
    """自动运行调试 需提前打开任意lua文件"""
    myWindowMgr = WindowMgr()
    hwnd = myWindowMgr.find_window_wildcard(None, ".*?懒人精灵 - .*?")
    if hwnd != None:
        win32gui.BringWindowToTop(hwnd)
        # 先发送一个alt事件，否则会报错导致后面的设置无效：pywintypes.error: (0, 'SetForegroundWindow', 'No error message is available')
        shell = win32com.client.Dispatch("WScript.Shell")
        shell.SendKeys("%")
        # 设置为当前活动窗口
        win32gui.SetForegroundWindow(hwnd)
        # 最大化窗口
        # win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)
        # F6
        win32api.keybd_event(117, win32api.MapVirtualKey(117, 0), 0, 0)
        win32api.keybd_event(
            117, win32api.MapVirtualKey(117, 0), win32con.KEYEVENTF_KEYUP, 0
        )
        sleep(0.1)
        # F5
        if now:
            win32api.keybd_event(116, win32api.MapVirtualKey(116, 0), 0, 0)
            win32api.keybd_event(
                116, win32api.MapVirtualKey(116, 0), win32con.KEYEVENTF_KEYUP, 0
            )


def resave():
    """从懒人精灵工程文件夹保存到此目录"""
    # 获取懒人目录下所有的.lua文件
    lua_files = [
        f for f in os.listdir(os.path.join(path, "脚本")) if f.endswith(".lua")
    ]
    for lua_file in lua_files:
        # 以GB18030的格式打开lua_file，然后以utf-8的格式写入到当前目录下
        with open(os.path.join(path, "脚本", lua_file), "r", encoding="GB18030") as f:
            with open(os.path.join(os.getcwd(), lua_file), "w", encoding="utf-8") as f1:
                f1.write(f.read())

    # 获取懒人目录下所有的.ui文件
    ui_files = [f for f in os.listdir(os.path.join(path, "界面")) if f.endswith(".ui")]
    for ui_file in ui_files:
        # 以GB18030的格式打开ui_file，然后以utf-8的格式写入到当前目录下
        with open(os.path.join(path, "界面", ui_file), "r", encoding="GB18030") as f:
            with open(os.path.join(os.getcwd(), ui_file), "w", encoding="utf-8") as f1:
                f1.write(f.read())
    print("反向保存完成")


def save():
    """保存到懒人精灵工程文件夹"""
    with open("main.lua", "r", encoding="utf-8") as f:
        lines = f.readlines()
        ss = ""
        for line in lines:
            if re.match('release_date = ".*"', line):
                line = (
                    'release_date = "'
                    + str(datetime.datetime.now().strftime("%m.%d %H:%M"))
                    + '"\n'
                )
            ss += line
    with open("main.lua", "w", encoding="utf-8") as f:
        f.write(ss)

    # 获取当前目录下所有的.lua文件
    def get_lua_files(directory):
        return [
            os.path.abspath(os.path.join(directory, f))
            for f in os.listdir(directory)
            if f.endswith(".lua")
        ]

    all_lua_files = get_lua_files(".") + get_lua_files("roguelike")
    for lua_file in all_lua_files:
        # 把lua_file以utf-8的格式打开，然后以GB18030的格式写入到"D:\ArkLights\main\脚本"目录下
        with open(lua_file, "r", encoding="utf-8") as f:
            file_name = os.path.basename(lua_file)
            with open(
                os.path.join(path, "脚本", file_name), "w", encoding="GB18030"
            ) as f1:
                f1.write(f.read())

    # 获取当前目录下所有的.ui文件
    ui_files = [f for f in os.listdir(".") if f.endswith(".ui")]
    for ui_file in ui_files:
        # 把ui_file以utf-8的格式打开，然后以GB18030的格式写入到path+界面目录下
        with open(ui_file, "r", encoding="utf-8") as f:
            with open(
                os.path.join(path, "界面", ui_file), "w", encoding="GB18030"
            ) as f1:
                f1.write(f.read())

    print("保存完成")


def saverun():
    """保存并运行"""
    save()
    run()


def release(type):
    with open("main.lua", "r", encoding="utf-8") as f:
        lines = f.readlines()
        for line in lines:
            if re.match("--\s*hotUpdate\(\)", line):
                print("检测到热更新被注释,请重新打包")
                return
    if type == "RELEASE":
        print(
            """
1.请验证文件大小,在1.5m左右或以内
2.请将res/char_type/里的json和res/ui/里的png放在懒人脚本资源/main.rc里面"""
        )
        newLrMD5 = input("请输入md5值: ")
        # 输出pkgPath的文件的md5
        md5 = hashlib.md5()
        with open(pkgPath, "rb") as f:
            md5.update(f.read())
        md5Text = md5.hexdigest()

        # 判断输入值是否与md5Text相等
        if newLrMD5 == md5Text:
            print("md5值正确")
            # 上传
            upload(md5Text, type, "false")
        else:
            print("md5值错误")
    elif type == "SKILL":
        upload("", type, "false")
    elif type == "MAPS":
        upload_to_backup_server(type)


def upload(md5, type, force):
    token = lc.token
    if token == "":
        print("token未配置，请配置token")
        exit()
    upFile = ""
    if type == "RELEASE":
        upFile = pkgPath
    elif type == "SKILL":
        upFile = r"res\skill.zip"
    md5 = hashlib.md5()
    with open(upFile, "rb") as f:
        md5.update(f.read())
    md5Text = md5.hexdigest()
    url = (
        API
        + "/uploadHotUpdatePackage?token="
        + token
        + "&md5="
        + md5Text
        + "&type="
        + type
        + "&force="
        + force
    )
    fileName = ""
    if type == "RELEASE":
        fileName = "script.lr"
    elif type == "SKILL":
        fileName = "skill.zip"

    # payload = {}
    # files = [("file", (fileName, open(upFile, "rb"), "application/octet-stream"))]
    # headers = {"User-Agent": "Apifox/1.0.0 (https://apifox.com)"}
    # try:
    #     response = requests.request(
    #         "POST", url, headers=headers, data=payload, files=files
    #     )
    #     print(response.json().get("msg"))
    # except Exception as e:
    #     print("上传主更新服务器失败:", e)
    upload_to_backup_server(type)


def upload_to_backup_server(type):
    bearer_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlbmx5c3VyZSJ9.AoDoOVosfVJUl-mAE1G-KneyrZcnkcFeWfRwyTtaX74"
    url = "https://arkapi.enlysure.com:33033/ark/upload_file?cache=true"
    upFile = ""
    if type == "RELEASE":
        upFile = pkgPath
    elif type == "SKILL":
        upFile = r"res\skill.zip"
    elif type == "MAPS":
        upFile = r"res\maps.zip"

    headers = {
        "Authorization": "Bearer " + bearer_token,
        "Connection": "keep-alive",
    }
    files = [
        (
            "file",
            (
                "script" if type == "RELEASE" else "skill",
                open(upFile, "rb"),
                "application/octet-stream",
            ),
        )
    ]
    response = requests.post(url, headers=headers, files=files, timeout=6000)
    # print(response.text)
    print("备用更新服务器上传：", "成功" if response.status_code == 200 else "失败")
    print(response.text)


def statistician():
    token = lc.token
    if token == "":
        print("token未配置，请配置token")
        exit()
    url = API + "/getStatistician?token=" + token
    response = requests.request("GET", url)
    info = response.json()["data"]
    print("============统计信息============")
    print("24h下载量: \t" + str(info["downloadCount"]))
    print("终端数量:  \t" + str(info["alCount"]))
    print("账号数量:  \t" + str(info["accountCount"]))
    print("活跃终端数量:  \t" + str(info["activeAlCount"]))
    print("活跃账号数量:  \t" + str(info["activeAccountCount"]))


def update_version():
    token = lc.token
    if token == "":
        print("token未配置，请配置token")
        exit()
    url = API + "/updateApkVer"
    print("请输入最新的版本号（纯数字）")
    ver = input("版本号: ")
    params = {
        "token": token,
        "ver": ver,
    }
    response = requests.request("POST", url, params=params)
    print(response.json().get("msg"))


def point_check():
    point_start = False
    center_start = False
    all_point = []
    all_center = []
    with open("point.lua", "r", encoding="utf-8") as f:
        lines = f.readlines()
        for line in lines:
            if point_start or center_start:
                # 不是很好的判断方式，但是管用
                if (
                    " = " in line
                    and str.startswith(line, "    ")
                    and (not str.startswith(line, "        "))
                    and (not str.startswith(line, "    --"))
                ):
                    pp = line.split(" = ")[0].strip()
                    if point_start:
                        all_point.append(pp)
                    elif center_start:
                        all_center.append(pp)
            if "point = {" in line:
                point_start = True
                center_start = False
            if "center = {" in line:
                point_start = False
                center_start = True
            if "distance = {" in line:
                break
    print("获取完成")
    for p in all_point:
        if p not in all_center:
            print(p, "缺少center")


if __name__ == "__main__":
    try:
        arg = sys.argv[1]
        if arg == "run":
            run()
        elif arg == "resave":
            resave()
        elif arg == "save":
            save()
        elif arg == "saverun":
            saverun()
        elif arg == "r":
            release("RELEASE")
        elif arg == "rs":
            release("SKILL")
        elif arg == "rm":
            release("MAPS")
        elif arg == "s":
            statistician()
        elif arg == "ver":
            update_version()
        elif arg == "check":
            point_check()

    except Exception as e:
        print(e)
