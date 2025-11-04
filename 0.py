import datetime
import hashlib
import os
import random
import re
import string
import sys
from pathlib import Path
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


def upload_to_image_hosting(file_path: Path, host="gitcode"):
    """上传图片到图床 返回链接"""

    def generate_random_string(length=16):
        return "".join(random.choices(string.ascii_letters, k=length))

    image_host = {
        "gitcode": {
            "cors": False,
            "params": {"filename": "ciallo", "mimeType": "image/jpeg"},
            "max": 104857600,
        },
        "udesk": {"cors": False, "params": {}, "max": 104857600},
        "kgqq": {"cors": True, "params": {}},
        "yuanbao": {"cors": True, "params": {}},
        "xinkaoyun": {
            "cors": False,
            "params": {"filename": "ciallo"},
            "max": 1047527424,
        },
        "xingye": {
            "cors": False,
            "params": {"filename": "ciallo", "mimeType": "image/jpeg"},
        },
        "skland": {"cors": False, "params": {}, "max": 20971520},
        "hupu": {
            "cors": True,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
        },
        "keep": {
            "cors": False,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
            "max": 1047527424,
        },
        "weights": {"cors": True, "params": {}},
        "qiyukf": {
            "cors": False,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
            "max": 104857600,
        },
        "nuanpaper": {
            "cors": True,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
        },
        "qqsonglist": {
            "cors": True,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
        },
        "ukaka": {
            "cors": False,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
            "max": 1047527424,
        },
        "snssdk": {
            "cors": False,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
        },
        "58tc": {
            "cors": False,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
        },
        "yyimgs": {
            "cors": False,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
        },
        "aippt": {
            "cors": False,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
        },
        "tyqw": {
            "cors": False,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
        },
        "168play": {
            "cors": True,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
        },
        "logosc": {
            "cors": False,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
        },
        "logosc1": {
            "cors": False,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
        },
        "beisu": {
            "cors": False,
            "params": {"mimeType": "image/jpeg", "filename": "ciallo"},
        },
    }

    max_size = image_host[host].get("max", 104857600)
    if os.path.getsize(file_path) > max_size:
        print(f"文件大小超过限制，最大支持{max_size / 1048576}MB，请更换图床源")
        return None
    filename = generate_random_string()
    file_type = file_path.suffix
    if file_type == "":
        file_type = ".jpeg"
    mime = "image/jpeg"
    url = f"https://bed-sign.vercel.0013107.xyz/sign?module={host}&filename={filename}{file_type}&mimeType={mime}"
    content_type = image_host[host]["params"].get("mimeType", mime)
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0",
        "X-Obs-Acl": "public-read",
        "Content-Type": content_type,
        "Accept": "*/*",
        "Connection": "keep-alive",
        "origin": "https://bed.vercel.0013107.xyz",
        "sec-fetch-mode": "cors",
    }
    print("正在上传至文件托管服务器")
    response = requests.get(url, headers=headers, timeout=25)
    # print(response.text)
    file_url = response.json().get("url")
    cdn_url = response.json().get("resourceUrl")
    body = response.json().get("body", {})
    dict.pop(body, "file", None)
    module = response.json().get("module", "POST")
    with open(file_path, "rb") as f:
        payload = f.read()
        files = {"file": (file_path.name, payload, "application/octet-stream")}
        if module == "PUT":
            response = requests.put(
                file_url, headers=headers, data=payload, timeout=200
            )
        else:
            response = requests.request(
                module, file_url, files=files, data=body, timeout=20
            )
    if response.status_code == 200:
        if "gitcode.com" in cdn_url:
            cdn_url = cdn_url.replace("gitcode.com", "gitcode.host")
        return cdn_url
    else:
        return None


def run(now=True):
    """自动运行调试 需提前打开任意lua文件"""
    myWindowMgr = WindowMgr()
    hwnd = myWindowMgr.find_window_wildcard(None, ".*?懒人精灵 - .*?")
    if hwnd is not None:
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


def release(file_type):
    with open("main.lua", "r", encoding="utf-8") as f:
        lines = f.readlines()
        for line in lines:
            if re.match("--\s*hotUpdate\(\)", line):
                print("检测到热更新被注释,请重新打包")
                return
    if file_type == "RELEASE":
        print(
            """
1.请验证文件大小,在1.5m左右或以内
2.请将res/char_type/里的json和res/ui/里的png放在懒人脚本资源/main.rc里面"""
        )
        new_lr_md5 = input("请输入md5值: ")
        # 输出pkgPath的文件的md5
        md5_text = hashlib.md5(open(pkgPath, "rb").read()).hexdigest()
        # 判断输入值是否与md5Text相等
        if new_lr_md5 == md5_text:
            print("md5值正确")
            # 上传
            upload(md5_text, file_type, "False")
            # upload_to_backup_server(file_type)
        else:
            print("md5值错误")
    elif file_type == "SKILL":
        upload("", file_type, "False")
        # upload_to_backup_server(file_type)
    elif file_type == "MAPS":
        upload_to_backup_server(file_type)


def upload(md5_text, file_type, force):
    token = lc.token
    if token == "":
        print("token未配置，请配置token")
        exit()
    up_file = ""
    if file_type == "RELEASE":
        up_file = pkgPath
    elif file_type == "SKILL":
        up_file = r"res\skill.zip"
    elif file_type == "MAPS":
        up_file = r"res\maps.zip"
    if not md5_text or md5_text == "":
        md5_text = hashlib.md5(open(up_file, "rb").read()).hexdigest()
    url = f"{API}/uploadHotUpdatePackage?token={token}&md5={md5_text}&type={file_type}&force={force}"
    file_name = ""
    if file_type == "RELEASE":
        file_name = "script.lr"
    elif file_type == "SKILL":
        file_name = "skill.zip"

    payload = {}
    files = [("file", (file_name, open(up_file, "rb"), "application/octet-stream"))]
    headers = {"User-Agent": "Apifox/1.0.0 (https://apifox.com)"}
    try:
        response = requests.request(
            "POST", url, headers=headers, data=payload, files=files, timeout=10
        )
        print(response.json().get("msg"))
    except Exception as e:
        print("上传审判庭服务器失败:", e)
    upload_to_backup_server(file_type)


def upload_to_backup_server(file_type):
    bearer_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlbmx5c3VyZSJ9.AoDoOVosfVJUl-mAE1G-KneyrZcnkcFeWfRwyTtaX74"
    # url = "https://arkapi.enlysure.com/ark/upload_file?cache=True"
    up_file = ""
    if file_type == "RELEASE":
        up_file = pkgPath
    elif file_type == "SKILL":
        up_file = r"res\skill.zip"
    elif file_type == "MAPS":
        up_file = r"res\maps.zip"
    headers = {
        "Authorization": "Bearer " + bearer_token,
        "Connection": "keep-alive",
    }
    # files = [
    #     (
    #         "file",
    #         (
    #             {"RELEASE": "script", "SKILL": "skill", "MAPS": "maps.zip"}.get(type),
    #             open(upFile, "rb"),
    #             "application/octet-stream",
    #         ),
    #     )
    # ]
    cdn_url = upload_to_image_hosting(Path(up_file), host="keep")
    if cdn_url is None:
        print("上传至文件服务器失败。")
        return
    url = "https://arkapi.enlysure.com/ark/set_file_url"
    params = {
        "file_name": {"RELEASE": "script", "SKILL": "skill", "MAPS": "maps.zip"}.get(
            file_type
        ),
        "url": cdn_url,
        "md5": hashlib.md5(open(up_file, "rb").read()).hexdigest(),
        "cache": {"RELEASE": True, "SKILL": True, "MAPS": False}.get(file_type),
    }
    response = requests.post(url, headers=headers, params=params, timeout=6000)
    # print(response.text)
    print("新加坡服务器上传：", "成功" if response.status_code == 200 else "失败")


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


if __name__ == "__main__":
    try:
        arg = sys.argv[1]
    except Exception as e:
        print(e)
        exit()
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
