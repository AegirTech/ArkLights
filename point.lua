coord_delimeter = ','
point_delimeter = '|'
swip_right_max = 10000
swip_left_max = -swip_right_max

hscale = screen.height / 1080
wscale = screen.width / 1920
minscale = min(hscale, wscale)
maxscale = max(hscale, wscale)

point = {

  小蓝圈 = "339,1010,#2C2E2C",
  等级升 = "1205,80,#303030",

  干员界面 = "1883,31,#313131|1675,91,#313131|1795,75,#FFFFFF",

  邮件提示采样列表 = {{1917, 141}},
  等级采样列表 = {{1190, 66}},
  等级 = {1190, 66},

  升级 = "1825,138,#FFFFFF",
  干员1 = "142,354,#AAAAAA",
  录像列表 = {
    "1247,181,#2B2B2B", "938,767,#2B2B2B", "939,471,#2B2B2B", "939,177,#2B2B2B",
  },

  当期委托 = {892, 467},
  当前委托侧边栏 = "1136,50,#180000",
  切换 = "1754,1001,#000000|1754,1038,#000000|1789,997,#000000|1795,1038,#000000",

  -- 开始行动 = "1902,20,#242424",
  开始行动 = "1902,20,#242424|1895,980,#242424|1890,886,#242424|1895,599,#242424|1895,436,#242424|1915,810,#0B0B0B",

  活动签到返回 = "1873,119,#595959|1907,150,#595959|1876,182,#595959|1842,153,#595959",
  抽签返回 = "1848,97,#595959|1879,123,#595959|1820,123,#595959|1851,154,#595959",
  确定抽取 = {1672, 815},

  副手确认蓝 = "1770,969,#0075A8",
  清空选择 = "753,982,#313131",
  -- 确认蓝 = "1769,982,#0075A8",
  确认蓝 = "1860,979,#0075A8|1885,1013,#0075A8",
  筛选采样列表 = {
    {1745, 36}, {1745, 37}, {1745, 37}, {1745, 42}, {1745, 44}, {1745, 46},
    {1788, 68}, {1788, 70},
  },
  筛选 = "1793,53,#FFFFFF|1764,46,#3C3C3C",
  正在提交反馈至神经 = "960,958,#FFFFFF|997,996,#FFFFFF|959,1034,#FFFFFF|919,996,#FFFFFF",
  进驻采样列表 = {
    {1007, 145}, {1148, 165}, {995, 293}, {1174, 298}, {1019, 437}, {1171, 516},
    {992, 590}, {1012, 815}, {1162, 799}, {1012, 696},
  },
  线索搜集提示 = "1467,200,#FFFFFF",
  基建右上角 = {1832, 53},
  好友 = {99, 613},
  缩放结束 = "947,381,#F1F0F1|1451,385,#F1F0F1",
  信赖采样列表 = {{1438, 64}},
  心情采样列表 = {{1559, 69}},

  宿舍列表 = {
    "1047,454,#FFFFFF", "1168,574,#FFFFFF", "1047,694,#FFFFFF",
    "1168,814,#FFFFFF",
  },
  入驻干员底部 = "1830,769,#747474|1879,922,#717171",
  入驻干员顶部 = "1879,125,#595959",
  入驻干员 = "1615,229,#898989|1605,229,#313131|1615,219,#313131|1753,367,#898989|1751,374,#313131|1761,365,#313131|1682,367,#898989|1668,367,#898989|1682,376,#313131|1699,374,#313131|1626,241,#898989|1641,257,#898989|1656,273,#898989|1710,277,#898989|1728,250,#898989|1745,233,#898989|1742,340,#898989|1709,354,#898989|1640,351,#898989|1634,304,#898989",
  入驻干员范围 = {900, 124, 1800, 1080},
  宿舍范围 = {629, 102, 918, 1069},
  本次线索交流活动 = "46,139,#CE6200|543,186,#CE6200",
  无人机加速 = "325,571,#FFFFFF",

  公开招募确认蓝 = "1389,870,#0098DC",
  -- 公开招募取消 = "1400,977,#313131",
  公开招募取消 = "1480,972,#FFFFFF|1586,948,#313131|1338,1000,#313131",
  公开招募列表 = {
    "487,435,#FFFFFF", "1434,435,#FFFFFF", "487,852,#FFFFFF",
    "1434,842,#FFFFFF",
  },
  聘用候选人列表 = {
    "576,564,#FFFFFF", "1524,564,#FFFFFF", "576,981,#FFFFFF",
    "1524,981,#FFFFFF",
  },
  开包skip = {1838, 52},
  公开招募标签框列表 = {
    {566, 544, 774, 606}, {817, 544, 1025, 606}, {1068, 544, 1276, 606},
    {566, 653, 774, 715}, {817, 653, 1025, 715}, {1068, 653, 1276, 715},
  },

  公开招募 = "1356,106,#313131|1357,144,#313131",
  公开招募箭头 = "1811,535,#FFFFFF",
  公开招募标签刷新蓝 = "1455,611,#0098DC",
  消耗一次联络机会确认 = {1044, 795},
  公开招募时间加 = {677, 233},
  公开招募时间减 = "750,463,#313131",
  公开招募标签范围 = {552, 530, 1290, 728},

  可露希尔推荐 = "80,122,#9A0101",

  -- 干员解锁进度 = "598,1039,#0098DC",
  -- 干员解锁进度 = "571,1001,#0098DC",
  信用交易所2 = "1646,122,#FF6801",

  信用交易所已购列表1 = "195,270,#ACACAC",
  信用交易所 = function()
    return (findOne("信用交易所已购列表1") or
             findOne("信用交易所列表1"))
  end,

  -- 干员解锁进度 = "345,988,#313131|347,1002,#0098DC",

  收取信用 = {1530, 60},
  收取信用有 = "1480,42,#DB6211",

  信用交易所列表 = {
    "195,270,#313131", "575,270,#313131", "955,270,#313131", "1340,270,#313131",
    "1715,270,#313131", "195,650,#313131", "575,650,#313131", "955,650,#313131",
    "1340,650,#313131", "1715,650,#313131",
  },
  购买物品 = "1252,863,#FF6800",
  购买物品面板 = "1567,874,#313131",
  -- 信用不足 = "1917,94,#090909",
  信用不足 = "1917,255,#262626",

  干员选中 = "273,267,#FFFFFF",
  干员未选中 = "273,267,#989898",
  信赖 = "1453,77,#01A1E9",
  基建副手 = {149, 684},
  基建副手简报 = "1719,77,#0099DC",
  基建副手列表 = {
    {600, 300}, {300, 800}, {500, 800}, {800, 800}, {1000, 800},
  },
  收集全部 = "1505,239,#0098DC",
  任务有列表 = {
    "1253,21,#FF6801", "1558,21,#FF6801", -- "1862,21,#FF6801", -- 4标签
    "1000,21,#FF6801", "1406,21,#FF6801", -- "1812,21,#FF6801", -- 3标签
  },
  任务无列表 = {
    "1253,21,#313131", "1558,21,#313131", -- "1862,21,#313131", -- 4标签
    "1000,21,#313131", "1406,21,#313131", -- "1812,21,#313131", -- 3标签
  },
  任务未选中列表 = {
    "1253,21,#E1E1E1", "1558,21,#E1E1E1", -- "1862,21,#E1E1E1", -- 4标签
    "1000,21,#E1E1E1", "1406,21,#E1E1E1", -- "1812,21,#E1E1E1", -- 3标签
  },
  任务第一个 = "703,55,#313131|1260,33,#E1E1E1",

  面板好友 = {656, 875},
  面板作战活动上 = {1827, 193},
  面板作战活动下 = {1827, 354},
  面板作战 = {1353, 290},
  面板采购中心 = {1162, 720},
  面板公开招募 = {1400, 767},
  面板干员 = {1400, 530},
  面板任务 = {1145, 908},
  面板基建 = {1478, 924},
  面板邮件 = {288, 57},

  访问下位橘 = "1791,1013,#D15806",
  访问下位灰 = "1651,959,#2C2C2C|1889,965,#2C2C2C|1903,1006,#2C2C2C|1676,1010,#2C2C2C",
  个人名片 = "124,197,#313131|97,345,#FFFFFF|88,478,#FFFFFF|86,615,#FDFDFD|275,58,#313131",
  好友列表 = "100,349,#313131",
  访问基建 = "1475,235,#FFFFFF",
  今日参与交流已达上限 = "1815,127,#FFFFFF",

  右确认 = {1260, 743},
  公开招募右确认 = {980, 780},
  左取消 = {671, 746},
  解锁线索 = "1018,972,#FFFFFF",
  线索库列表 = {{1645, 470}},
  -- 解锁线索上 = {179, 963},
  解锁线索上 = {1008, 900},
  线索布置按下列表 = {
    "148,233,#FFFFFF", "451,339,#FFFFFF", "753,203,#FFFFFF", "1078,268,#FFFFFF",
    "570,665,#FFFFFF", "880,578,#FFFFFF", "229,612,#FFFFFF",
  },
  线索布置左列表 = {
    "240,216,#FF6801", "543,322,#FF6801", "844,186,#FF6801", "1173,255,#FF6801",
    "663,648,#FF6801", "972,567,#FF6801", "319,599,#FF6801",
  },
  线索布置列表 = {
    "665,216,#FF6801", "968,322,#FF6801", "1269,186,#FF6801",
    "1598,255,#FF6801", "1088,648,#FF6801", "1397,567,#FF6801",
    "744,599,#FF6801",
  },
  全部 = "1285,43,#FFFFFF",
  全部收取 = "1499,1013,#FFFFFF",

  线索传递右白2 = "1812,991,#E5E5E5",
  线索传递右白 = "1812,991,#EFEFEF",
  线索传递左白 = {1682, 1019},
  线索传递橙框 = "1339,363,#D6B097|1376,417,#D5B198",
  今日登录列表 = {
    "1222,245,#0075A9", "1216,470,#0075A9", "1222,686,#0075A9",
    "1216,908,#0075A9",
  },
  线索列表 = {{329, 375}, {329, 651}, {329, 972}},
  线索传递数字重复 = "565,568,#434343",
  线索传递返回 = "1888,73,#FFFFFF",
  线索传递数字列表 = {
    "142,127,#FFFFFF", "220,130,#FFFFFF", "298,130,#FFFFFF", "376,130,#FFFFFF",
    "453,130,#FFFFFF", "532,130,#FFFFFF", "607,130,#FFFFFF", "71,130,#FFFFFF",
  },

  -- 线索传递数字右列表 = {
  --   "1419,133,#FFFFFF", "1494,127,#FFFFFF", "1575,130,#FFFFFF",
  --   "1652,130,#FFFFFF", "1730,130,#FFFFFF", "1806,127,#FFFFFF",
  --   "1881,133,#FFFFFF", "1348,130,#FFFFFF",
  -- },

  传递列表 = {{1791, 260}, {1791, 472}, {1791, 720}, {1791, 932}},
  信用奖励有 = "1794,254,#FFFFFF|1835,239,#7D0022",
  接收线索有 = "1796,407,#FFFFFF|1833,396,#7D0022",
  线索传递 = "1764,600,#FFFFFF",
  信用奖励领取 = "1286,864,#0075A8",
  未达线索上限 = "521,914,#E9E9E9",
  未达线索上限2 = "793,906,#E1E1E1",
  -- 信用奖励返回 = "1481,124,#595959",
  信用奖励返回 = "478,177,#E8E8E8|478,929,#E9E9E9|1445,929,#E9EAEA",
  会客厅有 = "1797,245,#FF6802",
  会客厅 = {1523, 359},

  无人机加速最小 = "889,484,#1A1A19",
  无人机加速最大 = "1444,473,#535353",
  无人机加速确定 = {1431, 876},
  制造站加速 = "1831,789,#FFFFFF",
  制造站进度 = {720, 942},
  建造模式开 = "304,304,#F5F5F5",
  排班调整提示 = "660,391,#FFFFFF|1277,422,#FFFFFF",
  入驻干员右侧 = {1881, 170},
  筛选确认 = {1418, 831},
  -- 筛选 = {1778, 70},
  筛选未进驻 = "713,565,#323232",
  筛选技能 = "615,277,#323232",
  筛选取消 = "1161,827,#FFFFFF|1130,827,#393939",
  -- 入驻干员 = "1685,829,#898989|1614,902,#898989|1684,964,#898989|1755,902,#898989|1641,972,#313131|1738,972,#313131|1738,818,#313131|1628,818,#313131|1605,898,#313131|1763,904,#313131",
  -- 入驻干员 = "1012,838,#FFFFFF|986,866,#FFFFFF|1037,866,#FFFFFF|1012,889,#FFFFFF|1010,928,#898989|1012,939,#313131",
  -- 入驻干员 = "1012,794,#898989|1012,928,#898989|996,928,#898989|1027,926,#898989|942,928,#898989|1080,929,#898989",
  --  入驻干员 = "940,245,#898989|934,245,#313131|940,239,#313131|1082,385,#898989|1012,385,#898989",
  撤下干员 = "1641,78,#7D0022",
  心情 = {1572, 33},
  心情降序 = "1571,80,#0C8BC4",
  技能 = {1443, 33},
  -- 清空选择 = "760,988,#313131",
  -- 当前房间入住信息 = "1238,49,#FFFFFF",
  当前房间入住信息 = "1791,1,#FFFFFF",
  进驻第一人 = {1791, 229},

  基建灯泡蓝 = "1800,135,#FFFFFF",
  基建灯泡蓝2 = "1800,203,#FFFFFF",

  基建灯泡灰 = "1800,135,#ECEBEC",
  基建灯泡灰2 = "1800,203,#ECEBEC",

  待办事项 = "1910,1040,#2C2E2C",
  -- 活动公告返回 = "1854,60,#595959",
  活动公告返回 = "1854,48,#595959|1824,83,#595959|1854,113,#595959|1885,88,#595959",
  -- 签到返回 = "1804,85,#595959",
  签到返回 = "1804,89,#595959|1777,114,#595959|1802,143,#595959|1838,113,#595959",

  正在释放神经递质 = "0,950,#E7D602",
  下载资源确认 = "1174,669,#1D6485|1339,727,#313131|966,725,#313131|574,722,#313131|579,351,#313131|1344,353,#313131",
  主页列表 = {
    首页 = {142, 417},
    干员 = {454, 264},
    终端 = {795, 115},
    基建 = {1032, 115},
    公开招募 = {1434, 404},
    采购中心 = {1810, 404},
    -- 任务 = "1645,68,#FFFFFF|1784,426,#FFFFFF|1630,429,#FFFFFF|1412,401,#FFFFFF|675,440,#FFFFFF",
    -- 任务 = "1814,69,#FEFEFE|1876,85,#494949|1726,19,#494949",
    任务 = "1626,50,#FFFFFF|1703,83,#494949|1559,20,#494949",
    好友 = {1810, 79},
  },

  演习券 = "1331,60,#FFFFFF|1910,56,#242424",
  返回 = "210,44,#313131",
  返回2 = "210,44,#2F2F2F",
  返回3 = "210,44,#FFFFFF",
  返回4 = "210,44,#F5F5F5",
  主页 = "545,29,#313131|549,84,#313131|259,32,#313131|259,80,#313131|402,56,#D8D8D8",
  主页按下 = "545,29,#444444|549,84,#444444|259,32,#444444|259,80,#444444|402,56,#D4D4D4",
  主页按过 = "545,29,#2F2F2F|549,84,#2F2F2F|259,32,#2F2F2F|259,80,#2F2F2F|402,56,#CFCFCF",
  主页右侧 = {960, 29},
  提示 = "637,56,#313131",
  右上角 = {1919, 1079},
  右下角确认 = {1821, 1018},

  怒号光明 = "97,9,#000000",
  二次呼吸 = "454,421,#000000",
  终端 = "138,125,#313131|738,125,#7D0022|1543,131,#313131|188,56,#313131",
  跳转 = "534,62,#313131|534,62,#313131|272,62,#313131|137,62,#313131",
  设置 = "341,43,#000000|143,546,#FFFFFF|143,689,#FFFFFF|161,68,#F5F5F5|1602,74,#313131",
  面板邮件有 = "327,34,#FF6801",
  用户名或密码错误 = "956,742,#FFFFFF",
  确认白 = "956,742,#FFFFFF",
  密码不能为空 = "1216,722,#FFFFFF",
  账号不能为空 = "1227,645,#FFFFFF",
  enter = {1920 - 20, 1090 - 20},
  正在加载网络配置 = "880,1005,#010101|874,1023,#000000|910,1017,#757575|928,1017,#636363|964,1023,#3A3A3A|994,1023,#000000|1030,1023,#4F4F4F|1048,1035,#B5B5B5|1054,1035,#2E2E2E|844,1029,#000000|952,1023,#FEFEFE|922,1023,#A4A4A4",
  网络异常稍后重试 = "659,446,#FFFFFF|713,452,#B4B4B4|743,440,#FFFFFF|779,446,#363636|857,452,#373737|911,452,#FFFFFF|941,446,#FFFFFF|977,440,#CCCCCC|1055,440,#FFFFFF|1085,440,#FFFFFF|1133,440,#353535|1181,446,#353535|1217,458,#686868",

  药剂恢复理智取消 = "1193,870,#313131|1625,845,#313131|1362,157,#FFFFFF",
  源石恢复理智取消 = "1193,870,#313131|1625,845,#313131|1506,150,#FFFFFF",
  药剂恢复理智确认 = {1625, 845},

  点击全部收取 = "365,1011,#27A0D7|435,1011,#27A0D7|328,1011,#27A0D7",
  报酬合成玉已满 = "582,1027,#FFFFFF",
  报酬合成玉已满2 = "1460,353,#C32A36",
  排班调整确认 = "1338,1009,#FFFFFF",
  作战主线章节列表 = {
    ["0"] = {955, 500},
    ["1"] = {478, 500},
    ["2"] = {955, 500},
    ["3"] = {1406, 500},
    ["4"] = {478, 500},
    ["5"] = {955, 500},
    ["6"] = {478, 500},
    ["7"] = {955, 500},
    ["8"] = {1406, 500},
  },

  滴水湖周边 = {1440, 585},
  作战列表 = {
    积水潮窟 = {1432, 177},
    龙门外环 = {1445, 389},
    龙门市区 = {1469, 553},
    切尔诺伯格 = {1456, 690},
    废弃矿区 = {1419, 929},
    大骑士领郊外 = {1445, 1040},

    ["PR-A-1"] = "588,638,#000000|1193,356,#000000|1330,385,#FFFFFF|727,671,#FFFFFF",
    ["PR-B-1"] = "663,637,#000000|1349,342,#000000|1352,367,#FFFFFF|675,662,#FFFFFF",
    ["PR-C-1"] = "654,599,#000000|1324,364,#000000|670,624,#FFFFFF|1328,389,#FFFFFF",
    ["PR-D-1"] = "694,627,#000000|1334,370,#000000|1334,405,#FFFFFF|697,649,#FFFFFF",
    ["AP-1"] = "242,829,#000000|657,757,#000000|958,583,#000000|1200,411,#000000|1357,238,#000000|1312,436,#FFFFFF|1062,615,#FFFFFF",

    ["0-1"] = {960, 500},
    ["0-3"] = {960, 500},
    ["0-5"] = {960, 500},
    ["0-6"] = {960, 500},
    ["0-8"] = {960, 500},
    ["0-9"] = {960, 500},
    ["0-10"] = {960, 500},
    ["0-11"] = {960, 500},
    ["0-2"] = {960, 650},
    ["0-7"] = {960, 650},
    ["0-4"] = {960, 350},

    ["1-1"] = {960, 500},
    ["1-2"] = {960, 500},
    ["1-6"] = {960, 500},
    ["1-9"] = {960, 500},
    -- TODO: not support 1-11 yet
    ["1-11"] = {960, 500},
    ["1-12"] = {960, 500},
    ["1-3"] = {960, 650},
    ["1-4"] = {960, 650},
    ["1-10"] = {960, 650},
    ["1-5"] = {960, 650},
    ["1-7"] = {960, 350},
    ["1-8"] = {960, 350},

    ["2-1"] = {960, 650},
    ["S2-1"] = {960, 650},
    ["S2-4"] = {960, 650},
    ["2-3"] = {960, 650},
    ["S2-6"] = {960, 650},
    ["S2-7"] = {960, 650},
    ["2-5"] = {960, 650},
    ["2-6"] = {960, 650},
    ["2-7"] = {960, 650},
    ["S2-8"] = {960, 650},
    ["S2-9"] = {960, 650},
    ["S2-12"] = {960, 650},
    ["2-10"] = {960, 650},
    ["2-2"] = {960, 480},
    ["S2-2"] = {960, 480},
    ["S2-3"] = {960, 480},
    ["2-4"] = {960, 480},
    ["S2-5"] = {960, 480},
    ["2-8"] = {960, 480},
    ["2-9"] = {960, 480},
    ["S2-11"] = {960, 480},
    ["S2-10"] = {960, 300},

    ["3-1"] = {960, 530},
    ["3-2"] = {960, 530},
    ["3-3"] = {960, 530},
    ["S3-1"] = {960, 800},
    ["S3-2"] = {960, 800},
    ["3-4"] = {960, 630},
    ["3-5"] = {960, 630},
    ["3-6"] = {960, 630},
    ["S3-3"] = {960, 630},
    ["S3-4"] = {960, 630},
    ["S3-5"] = {960, 630},
    ["S3-6"] = {960, 630},
    ["S3-7"] = {960, 630},
    ["3-7"] = {960, 460},
    ["3-8"] = {960, 350},

    ["S4-7"] = {960, 230},
    ["4-5"] = {960, 360},
    ["4-8"] = {960, 360},
    ["S4-8"] = {960, 360},
    ["S4-9"] = {960, 360},
    ["S4-10"] = {960, 360},
    ["4-1"] = {960, 500},
    ["4-3"] = {960, 500},
    ["4-4"] = {960, 500},
    ["4-6"] = {960, 500},
    ["4-7"] = {960, 500},
    ["4-9"] = {960, 500},
    ["4-10"] = {960, 500},
    ["4-2"] = {960, 670},
    ["S4-1"] = {960, 670},
    ["S4-3"] = {960, 670},
    ["S4-4"] = {960, 650},
    ["S4-5"] = {960, 650},
    ["S4-6"] = {960, 650},
    ["S4-2"] = {960, 800},

    ["5-1"] = {960, 600},
    ["5-2"] = {960, 470},
    ["5-3"] = {960, 470},
    ["5-5"] = {960, 470},
    ["S5-1"] = {960, 670},
    ["S5-2"] = {960, 670},
    ["S5-5"] = {960, 700},
    ["S5-6"] = {960, 700},
    ["S5-7"] = {960, 700},
    ["S5-8"] = {960, 700},
    ["S5-9"] = {960, 700},

    ["5-4"] = {960, 600},
    ["5-6"] = {960, 380},
    ["5-7"] = {960, 380},
    ["S5-3"] = {960, 550},
    ["S5-4"] = {960, 550},

    ["5-8"] = {960, 550},
    ["5-9"] = {960, 550},
    ["5-10"] = {960, 550},

    ["6-1"] = {960, 420},
    ["6-2"] = {960, 420},
    ["6-3"] = {960, 530},
    ["6-5"] = {960, 530},
    ["S6-1"] = {960, 530},
    ["S6-2"] = {960, 530},
    ["6-12"] = {960, 500},
    ["6-14"] = {960, 500},
    ["6-15"] = {960, 500},
    ["6-16"] = {960, 500},
    ["6-4"] = {960, 660},
    ["6-9"] = {960, 660},
    ["6-10"] = {960, 660},
    ["6-11"] = {960, 660},
    ["S6-3"] = {960, 660},
    ["S6-4"] = {960, 660},
    ["6-8"] = {960, 350},

    ["7-2"] = {960, 520},
    ["7-3"] = {960, 370},
    ["7-4"] = {960, 700},
    ["7-5"] = {960, 700},
    ["7-12"] = {960, 700},
    ["7-14"] = {960, 700},
    ["S7-1"] = {960, 700},
    ["S7-2"] = {960, 700},
    ["7-6"] = {960, 570},
    ["7-8"] = {960, 570},
    ["7-11"] = {960, 570},
    ["7-13"] = {960, 570},
    ["7-15"] = {960, 570},
    ["7-17"] = {960, 530},
    ["7-18"] = {960, 530},

    ["7-9"] = {960, 380},
    ["7-10"] = {960, 380},
    ["7-16"] = {960, 380},

    ["R8-1"] = {960, 360},
    ["R8-2"] = {960, 360},
    ["R8-3"] = {960, 360},
    ["R8-4"] = {960, 360},
    ["R8-5"] = {960, 360},
    ["R8-6"] = {960, 360},
    ["R8-8"] = {960, 360},
    ["R8-9"] = {960, 360},
    ["R8-10"] = {960, 360},
    ["R8-11"] = {960, 360},
    ["R8-7"] = {960, 240},
    ["JT8-1"] = {960, 530},
    ["JT8-2"] = {960, 530},
    ["JT8-3"] = {960, 530},
    ["M8-8"] = {960, 700},
    ["M8-7"] = {960, 700},
    ["M8-6"] = {960, 700},
  },
  主题曲 = {400, 1000},
  插曲 = {700, 1000},
  资源收集 = {1200, 1000},
  每周部署 = {1500, 1000},
  觉醒 = {95, 198},
  幻灭 = {95, 349},
  炎国龙门 = {460, 700},
  乌萨斯 = {55, 640},
  卡西米尔 = {175, 810},
  汐斯塔 = {1541, 123},
  当前进度列表左 = {1472, 993},
  当前进度列表右 = {1772, 993},
  当前进度列表 = {
    -- 00
    "1781,1011,#2F2F2F|1754,1013,#2F2F2F|1754,1042,#2F2F2F|1781,1042,#2F2F2F|1767,1018,#2F2F2F|1790,1011,#2F2F2F|1789,1028,#2F2F2F|1794,1026,#2F2F2F|1793,1041,#2F2F2F|1807,1041,#2F2F2F|1811,1024,#2F2F2F|1808,1011,#2F2F2F",
    -- 01
    "1457,1018,#2F2F2F|1450,1027,#2F2F2F|1457,1026,#2F2F2F|1463,1026,#2F2F2F|1457,1035,#2F2F2F|1492,1026,#2F2F2F|1492,1017,#2F2F2F|1486,1026,#2F2F2F|1499,1026,#2F2F2F|1492,1035,#2F2F2F",
    -- 02
    "1464,1018,#2F2F2F|1457,1026,#2F2F2F|1469,1026,#2F2F2F|1464,1035,#2F2F2F|1464,1026,#2F2F2F|1486,1011,#2F2F2F|1486,1029,#2F2F2F|1488,1027,#2F2F2F|1487,1041,#2F2F2F|1504,1042,#2F2F2F|1504,1029,#2F2F2F|1503,1011,#2F2F2F",
    -- 03
    "1460,1017,#2F2F2F|1454,1027,#2F2F2F|1460,1025,#2F2F2F|1466,1026,#2F2F2F|1460,1035,#2F2F2F|1492,1017,#2F2F2F|1496,1020,#2F2F2F|1486,1024,#2F2F2F|1482,1031,#2F2F2F|1502,1034,#2F2F2F|1497,1035,#2F2F2F|1503,1009,#2F2F2F",
    -- 04
    "1764,1017,#2F2F2F|1758,1027,#2F2F2F|1764,1027,#2F2F2F|1769,1027,#2F2F2F|1764,1036,#2F2F2F|1797,1017,#2F2F2F|1805,1019,#2F2F2F|1796,1033,#2F2F2F|1784,1031,#2F2F2F",
    -- 05
    "1764,1019,#2F2F2F|1757,1027,#2F2F2F|1765,1027,#2F2F2F|1769,1027,#2F2F2F|1764,1035,#2F2F2F|1797,1033,#2F2F2F|1803,1017,#2F2F2F|1808,1013,#2F2F2F|1789,1011,#2F2F2F",
    -- 06
    "1460,1019,#2F2F2F|1460,1036,#2F2F2F|1454,1025,#2F2F2F|1459,1025,#2F2F2F|1465,1027,#2F2F2F|1494,1019,#2F2F2F|1503,1020,#2F2F2F|1494,1033,#2F2F2F|1479,1031,#2F2F2F",
    -- 07
    "1460,1017,#2F2F2F|1454,1025,#2F2F2F|1460,1025,#2F2F2F|1465,1025,#2F2F2F|1458,1035,#2F2F2F|1480,1011,#2F2F2F|1502,1013,#2F2F2F|1493,1033,#2F2F2F|1504,1019,#2F2F2F",
    -- 08
    "1454,1027,#2F2F2F|1459,1027,#2F2F2F|1467,1027,#2F2F2F|1459,1019,#2F2F2F|1461,1035,#2F2F2F|1483,1019,#2F2F2F|1490,1020,#2F2F2F|1479,1036,#2F2F2F|1503,1035,#2F2F2F|1495,1041,#2F2F2F",
  },
  按下当前进度列表 = {
    -- 00
    "1781,1011,#313131|1754,1013,#313131|1754,1042,#313131|1781,1042,#313131|1767,1018,#313131|1790,1011,#313131|1789,1028,#313131|1794,1026,#313131|1793,1041,#313131|1807,1041,#313131|1811,1024,#313131|1808,1011,#313131",
    -- 01
    "1457,1018,#313131|1450,1027,#313131|1457,1026,#313131|1463,1026,#313131|1457,1035,#313131|1492,1026,#313131|1492,1017,#313131|1486,1026,#313131|1499,1026,#313131|1492,1035,#313131",
    -- 02
    "1464,1018,#313131|1457,1026,#313131|1469,1026,#313131|1464,1035,#313131|1464,1026,#313131|1486,1011,#313131|1486,1029,#313131|1488,1027,#313131|1487,1041,#313131|1504,1042,#313131|1504,1029,#313131|1503,1011,#313131",
    -- 03
    "1460,1017,#313131|1454,1027,#313131|1460,1025,#313131|1466,1026,#313131|1460,1035,#313131|1492,1017,#313131|1496,1020,#313131|1486,1024,#313131|1482,1031,#313131|1502,1034,#313131|1497,1035,#313131|1503,1009,#313131",
    -- 04
    "1764,1017,#313131|1758,1027,#313131|1764,1027,#313131|1769,1027,#313131|1764,1036,#313131|1797,1017,#313131|1805,1019,#313131|1796,1033,#313131|1784,1031,#313131",
    -- 05
    "1764,1019,#313131|1757,1027,#313131|1765,1027,#313131|1769,1027,#313131|1764,1035,#313131|1797,1033,#313131|1803,1017,#313131|1808,1013,#313131|1789,1011,#313131",
    -- 06
    "1460,1019,#313131|1460,1036,#313131|1454,1025,#313131|1459,1025,#313131|1465,1027,#313131|1494,1019,#313131|1503,1020,#313131|1494,1033,#313131|1479,1031,#313131",
    -- 07
    "1460,1017,#313131|1454,1025,#313131|1460,1025,#313131|1465,1025,#313131|1458,1035,#313131|1480,1011,#313131|1502,1013,#313131|1493,1033,#313131|1504,1019,#313131",
    -- 08
    "1454,1027,#313131|1459,1027,#313131|1467,1027,#313131|1459,1019,#313131|1461,1035,#313131|1483,1019,#313131|1490,1020,#313131|1479,1036,#313131|1503,1035,#313131|1495,1041,#313131",

  },
  -- 登录
  start黄框 = "958,985,#FFD802|995,1021,#FFD802|958,1057,#FFD802|924,1021,#FFD802|958,1011,#FFD802",
  start黄框暗 = "958,985,#AF9401|995,1021,#AF9401|958,1057,#AF9401|924,1021,#AF9401|958,1011,#AF9401",
  开始唤醒 = "861,734,#555555|1071,804,#565656|1397,754,#E9E9E9",
  账号登录 = "508,728,#565656|743,800,#565656",
  -- 登录 = "758,848,#353535|1164,885,#353535|960,1070,#060606",
  登录 = "758,848,#353535|1164,885,#353535|960,1070,#060606",
  手机验证码登录 = "1523,1037,#246684|1717,1036,#246684",
  左上角 = {0, 0},
  账号左侧 = {672, 652},
  账号 = {1045, 652},
  密码 = {1045, 727},

  面板 = "158,526,#323232|172,520,#323232|150,517,#FFFFFF|150,534,#FFFFFF|160,534,#FFFFFF",

  -- 基建
  进驻总览 = "234,213,#FFFFFF|231,311,#FFFFFF|271,213,#FFFFFF|269,154,#FFFFFF|274,57,#313131",
  基建左侧列表 = {
    {200, 520}, {440, 520}, {680, 520}, {80, 640}, {320, 640}, {559, 640},
    {200, 760}, {440, 760}, {680, 760},
  },

  控制中枢 = {1207, 317},
  进驻信息 = "76,412,#FFFFFF|717,28,#2E2E2E",
  进驻信息选中 = "76,412,#000000|717,28,#171717",
  干员选择列表 = {
    {746, 286}, {746, 718}, {950, 286}, {950, 718}, {1169, 286}, {1169, 718},
  },
  制造站收取 = {1700, 1000},

  -- 作战
  开始行动蓝 = {1722, 990},
  开始行动红 = "1628,715,#FFFFFF",
  代理失误放弃行动 = "586,738,#FFFFFF|577,743,#FFFFFF|578,775,#FFFFFF|587,776,#FFFFFF|599,775,#FFFFFF|630,752,#FFFFFF|661,753,#FFFFFF|653,762,#FFFFFF|644,736,#FFFFFF|3,250,#E5E5CD|1912,247,#E8E8E8|1909,811,#6D0A0A|15,805,#313129",
  接管作战 = "954,105,#FFFFFF|1062,195,#FFFFFF|959,307,#FFFFFF",
  -- 任务
  理智兑换取消 = "398,810,#191717|408,810,#FFFFFF|483,790,#1F1F17|658,770,#0C0C0C|893,280,#FFFFFF|988,165,#FFFFFF|1068,210,#FFFFFF|1073,305,#FFFFFF|1897,407,#E8E8E8",

  未能同步到相关战斗记录 = "624,492,#FEFEFE|666,474,#333333|684,480,#373737|702,480,#FFFFFF|732,480,#393939|768,504,#373737|792,504,#393939|846,504,#414141|930,522,#383838|984,486,#363636|1020,486,#FFFFFF|1068,480,#363636|1140,486,#FFFFFF|1188,492,#353535|1194,492,#343434|1218,492,#E1E1E1",
  我知道了 = "903,816,#E2E2E2|910,819,#A5A5A5|918,825,#787878|921,809,#757575|936,818,#3E3E3E|935,814,#2C2C2C|446,783,#060606|1476,780,#060606|55,1026,#FFFFFF|46,1041,#FFFFFF|1010,812,#989898|998,832,#D8D8D8",
  删除缓存返回 = "65,40,#ABABAB|77,34,#343434|95,34,#A7A7A7|125,46,#AEAEAE|149,52,#222222|161,46,#393939",
  登入错误 = "965,765,#FFFFFF|803,460,#393939|845,454,#363636|845,454,#363636|863,454,#363636|875,454,#353535|875,454,#353535|881,454,#FFFFFF|1001,454,#353535|1085,448,#FEFEFE|1157,442,#343434|917,526,#FFFFFF|995,532,#C0C0C0|977,556,#3A3A3A",
  战斗记录未能同步返回 = "658,739,#FFFFFF|732,399,#333333|816,399,#363636|864,399,#E8E8E8|924,399,#333333|990,405,#B4B4B4|1026,405,#333333|1062,405,#8B8B8B|1128,411,#ECECEC|1176,411,#ECECEC|1206,405,#363636|882,481,#F6F6F6|912,481,#F7F7F7|972,499,#333333|996,481,#333333",
  返回确认 = "947,453,#333333|745,460,#333333",
  返回确认2 = "926,486,#313131|1105,478,#313131|745,490,#313131|1139,479,#313131",
  代理指挥关 = "1844,921,#EEEEEE",
  代理指挥开 = "1601,886,#FFFFFF",

  收取所有邮件 = {1628, 989},
  邮件信封 = "320,52,#313131|377,53,#313131|377,91,#313131|337,80,#313131",

  源石理智兑换次数上限 = "1913,923,#FDFDFD|1909,87,#FFFFFF|1325,333,#CED0D6|1343,529,#898989|1325,568,#FEFEFE|1345,556,#FBFBFB|1378,566,#F3F3F3|1347,591,#898989|1554,683,#898989|1339,672,#898989|1524,672,#898989|1593,679,#898989",
  源石不足 = "1309,548,#898989|1464,463,#898989|1344,598,#FBFBFB|1349,608,#FCFCFC|1483,687,#898989|1474,583,#FDFDFD|965,254,#676767|964,255,#FCFCFC|1428,474,#F9F9F9|1402,474,#898989|252,345,#FFFFFF|922,904,#C5C5CD",

  跳过剧情 = "1820,79,#FFFFFF",
  跳过剧情确认 = {1197, 547},
  两倍速 = {1650, 75},

  资源收集列表 = {
    {-166, 200}, {142, 200}, {450, 200}, {767, 200}, {960, 200}, {1156, 200},
    {1469, 200}, {1770, 200}, {2071, 200},
  },
  资源收集最左列表 = {
    {354, 200}, {656, 200}, {955, 200}, {1294, 200}, {1594, 200}, {1882, 200},
    {2194, 200}, {2494, 200}, {2794, 200},
  },
  资源收集最右列表 = {
    {-856, 200}, {-556, 200}, {-256, 200}, {41, 200}, {320, 200}, {656, 200},
    {955, 200}, {1244, 200}, {1556, 200},
  },
}
--[[
如何实现全分辨率支持：
节点精灵提供OCR、图像特征搜索，但速度较慢。
autojs提供OCR、图像匹配、速度没测过。OCR看现有明日方舟辅助实现耗时在1到3秒，和节点精灵同一量级。
本工具致力于低等待耗时实现，因此采用多点找色方案，保证所有point围绕着某个中心进行缩放。
开发过程中测试3种分辨率 720x1280、1920x1080、2400x1080。
--]]

center = {
  邮件提示采样列表 = "right_top",
  线索布置按下列表 = "center_center",
  小蓝圈 = "left_bottom",
  主页按下 = "left_top",
  主页按过 = "left_top",
  等级升 = "right_top",
  干员界面 = "right_top",
  等级采样列表 = "right_top",
  等级 = "right_top",
  升级 = "right_top",
  干员1 = "left_center",
  录像列表 = "left_center",
  报酬合成玉已满 = "left_bottom",
  报酬合成玉已满2 = "center_center",

  源石恢复理智取消 = "center_center",
  药剂恢复理智取消 = "center_center",
  药剂恢复理智确认 = "center_center",
  跳过剧情 = "right_top",
  跳过剧情确认 = "center_center",
  两倍速 = "right_top",
  当期委托 = "center_center",
  当前委托侧边栏 = "right_center",
  切换 = "right_bottom",

  开始行动 = "right_center",
  剿灭提示 = "center_center",
  二次呼吸 = "left_center",
  怒号光明 = "left_center",

  确定抽取 = "center_center",
  干员解锁进度 = "left_bottom",
  活动签到返回 = "center_center",
  抽签返回 = "center_center",
  筛选采样列表 = "right_top",
  排序 = "right_top",
  正在提交反馈至神经 = "center_bottom",
  进驻采样列表 = "right_center",
  作战列表 = "center_center",
  作战中心范围 = "center_center",
  线索搜集提示 = "right_top",
  基建右上角 = "right_top",
  控制中枢 = "center_center_maxscale",
  缩放结束 = "center_center_maxscale",

  心情采样列表 = "right_top",
  信赖采样列表 = "right_top",

  宿舍范围 = "right_center",
  宿舍标识 = "left_top",
  宿舍标识2 = "left_top",
  入驻干员底部 = "right_bottom",
  入驻干员顶部 = "right_bottom",
  入驻干员范围 = "right_center",
  收取信用有 = "right_center",
  本次线索交流活动 = "left_top",
  无人机加速 = "center_center",
  邮件提示 = "right_top",
  邮件提示2 = "right_top",
  邮件提示3 = "right_top",
  公开招募确认蓝 = "center_center",
  公开招募取消 = "center_center",
  公开招募列表 = "center_center",
  聘用候选人列表 = "center_center",
  开包skip = "right_top",
  公开招募标签框列表 = "center_center",
  公开招募 = "right_top",
  公开招募箭头 = "center_center",
  公开招募标签刷新蓝 = "center_center",
  消耗一次联络机会确认 = "center_center",
  公开招募时间加 = "center_center",
  公开招募时间减 = "center_center",

  可露希尔推荐 = "center_center",
  信用交易所 = "center_center",
  信用交易所2 = "center_center",
  收取信用 = "right_center",
  信用交易所列表 = "left_center",
  信用交易所已购列表1 = "left_center",
  购买物品 = "center_center",
  购买物品面板 = "center_center",
  信用不足 = "right_center",

  干员选中 = "left_center",
  干员未选中 = "left_center",
  信赖 = "right_center",
  基建副手 = "left_center",
  基建副手简报 = "right_center",
  基建副手列表 = "center_center",

  收集全部 = "center_center",
  任务有列表 = "center_center",
  任务无列表 = "center_center",
  任务未选中列表 = "center_center",
  任务第一个 = "center_center",

  访问下位橘 = "right_bottom",
  访问下位灰 = "right_bottom",
  个人名片 = "left_center",

  访问基建 = "left_center",
  今日参与交流已达上限 = "right_center",

  制造站收取 = "right_center",
  解锁线索 = "center_center",
  线索库列表 = "right_center",
  解锁线索上 = "center_center",
  线索布置左列表 = "center_center",
  线索布置列表 = "center_center",
  全部 = "right_center",
  全部收取 = "right_center",

  线索传递右白2 = "right_center",
  线索传递右白 = "right_center",
  线索传递左白 = "right_center",
  今日登录列表 = "center_center",
  线索列表 = "left_center",
  线索传递数字重复 = "left_center",
  线索传递返回 = "right_center",
  线索传递数字列表 = "left_center",
  线索传递数字右列表 = "right_center",
  传递列表 = "center_center",
  信用奖励有 = "right_center",
  接收线索有 = "right_center",
  线索传递 = "right_center",
  信用奖励领取 = "center_center",
  未达线索上限 = "center_center",
  未达线索上限2 = "center_center",
  信用奖励返回 = "center_center",
  会客厅有 = "center_center_maxscale",
  会客厅 = "center_center_maxscale",

  无人机加速最小 = "center_center",
  无人机加速最大 = "center_center",
  无人机加速确认 = "center_center",
  制造站加速 = "right_center",
  制造站进度 = "left_bottom",

  建造模式开 = "left_top",
  基建左侧列表 = "center_center_maxscale",
  当前房间入住信息 = "right_top",
  排班调整提示 = "center_center",
  入驻干员右侧 = "right_top",
  筛选确认 = "center_center",
  筛选技能 = "center_center",
  筛选未进驻 = "center_center",
  筛选取消 = "center_center",
  筛选 = "right_top",
  撤下干员 = 'right_top',
  排班调整确认 = "right_bottom",
  确认蓝 = "right_bottom",
  副手确认蓝 = "right_bottom",
  干员选择列表 = "left_center",
  心情 = "right_top",
  技能 = "right_top",
  清空选择 = "left_bottom",
  进驻第一人 = "right_top",

  宿舍列表 = "center_center_maxscale",

  进驻信息 = "left_top",
  进驻信息选中 = "left_top",

  基建灯泡蓝 = "right_top",
  基建灯泡蓝2 = "right_top",

  待办事项 = "left_bottom",
  返回确认 = "center_center",
  返回确认2 = "center_center",
  活动公告返回 = "center_center",
  签到返回 = "center_center",
  -- 右确认 = "1469,"..(1469-1920+screen.width).."_center_anisotropy",
  右确认 = "center_center",
  公开招募右确认 = "center_center",
  左取消 = "center_center",
  进驻总览 = "left_top",
  演习券 = "right_top",
  收取所有邮件 = "center_bottom",
  邮件信封 = "center_top",
  正在释放神经递质 = "left_bottom",
  下载资源确认 = "center_center",

  主页列表 = 'center_top',
  主页右侧 = 'center_top',
  资源收集列表 = "center_center",
  资源收集最左列表 = "left_center",
  资源收集最右列表 = "right_center",
  物资筹备列表 = "center_center",
  行动结束 = "left_bottom",
  代理指挥关 = "right_bottom",
  代理指挥开 = "right_bottom",
  开始行动蓝 = "right_bottom",
  开始行动红 = "center_center",
  接管作战 = "center_top",

  当前进度列表 = "right_bottom",
  当前进度列表右 = "right_bottom",
  当前进度列表左 = "right_bottom",
  按下当前进度列表 = "right_bottom",
  觉醒 = "left_center",
  幻灭 = "left_center",

  主题曲 = "center_bottom_maxscale",
  资源收集 = "center_bottom_maxscale",
  插曲 = "center_bottom_maxscale",
  别传 = "center_bottom_maxscale",
  每周部署 = "center_bottom_maxscale",

  面板作战 = "right_center",
  面板作战活动上 = "right_center",
  面板作战活动下 = "right_center",
  面板采购中心 = "right_center",
  面板公开招募 = "right_center",
  面板干员 = "right_center",
  面板任务 = "right_center",
  面板基建 = "right_center",

  面板好友 = "left_center",
  面板 = "left_center",

  start黄框 = "center_bottom",
  start黄框暗 = "center_bottom",
  开始唤醒 = "center_center",
  账号登录 = "center_center",
  登录 = "center_center",
  手机验证码登录 = "right_bottom",
  账号 = "center_center",
  账号左侧 = "center_center",
  密码 = "center_center",
  密码不能为空 = "center_center",
  账号不能为空 = "center_center",
  右下角确认 = "right_bottom",
  右上角 = "right_top",

  -- TODO need test
  代理失误放弃行动 = "center_center",
  战斗记录未能同步返回 = "center_center",
}

distance = {
  right = swip_right_max,
  left = swip_left_max,
  ["资源收集列表1"] = swip_right_max,
  ["资源收集列表9"] = swip_left_max,

  ["0-1"] = swip_right_max,
  ["0-2"] = {swip_right_max, -550},
  ["0-3"] = {swip_right_max, -1100},
  ["0-4"] = {swip_right_max, -1650},
  ["0-5"] = {swip_right_max, -2200},
  ["0-6"] = {swip_right_max, -2550},
  ["0-7"] = {swip_right_max, -3100},
  ["0-8"] = {swip_right_max, -3700},
  ["0-9"] = {swip_right_max, -4050},
  ["0-10"] = {swip_right_max, -4550},
  ["0-11"] = {swip_right_max, -4850},

  ["1-1"] = swip_right_max,
  ["1-2"] = {swip_right_max, -300},
  ["1-3"] = {swip_right_max, -500},
  ["1-4"] = {swip_right_max, -850},
  ["1-5"] = {swip_right_max, -1200},
  ["1-6"] = {swip_right_max, -1750},
  ["1-7"] = {swip_right_max, -2250},
  ["1-8"] = {swip_right_max, -2600},
  ["1-9"] = {swip_right_max, -3150},
  ["1-10"] = {swip_right_max, -3450},
  ["1-11"] = {swip_right_max, -3650},
  ["1-12"] = {swip_right_max, -4000},

  ["2-1"] = {swip_right_max, -200},
  ["S2-1"] = {swip_right_max, -550},
  ["2-2"] = {swip_right_max, -750},
  ["S2-2"] = {swip_right_max, -1100},
  ["S2-3"] = {swip_right_max, -1400},
  ["S2-4"] = {swip_right_max, -1600},
  ["2-3"] = {swip_right_max, -1950},
  ["2-4"] = {swip_right_max, -2450},
  ["S2-5"] = {swip_right_max, -2750},
  ["S2-6"] = {swip_right_max, -3000},
  ["S2-7"] = {swip_right_max, -3350},
  ["2-5"] = {swip_right_max, -3750},
  ["2-6"] = {swip_right_max, -4100},
  ["2-7"] = {swip_right_max, -4500},
  ["S2-8"] = {swip_right_max, -4850},
  ["S2-9"] = {swip_right_max, -5200},
  ["2-8"] = {swip_right_max, -5450},
  ["2-9"] = {swip_right_max, -5750},
  ["S2-10"] = {swip_right_max, -6050},
  ["S2-11"] = {swip_right_max, -6300},
  ["S2-12"] = {swip_right_max, -6550},
  ["2-10"] = {swip_right_max, -6800},

  ["3-1"] = swip_right_max,
  ["3-2"] = {swip_right_max, -350},
  ["3-3"] = {swip_right_max, -650},
  ["S3-1"] = {swip_right_max, -1300},
  ["S3-2"] = {swip_right_max, -1650},
  ["3-4"] = {swip_right_max, -1950},
  ["3-5"] = {swip_right_max, -2300},
  ["3-6"] = {swip_right_max, -2600},
  ["3-7"] = {swip_right_max, -2850},
  ["S3-3"] = {swip_right_max, -3200},
  ["3-8"] = {swip_right_max, -3300},
  ["S3-4"] = {swip_right_max, -3550},
  ["S3-5"] = {swip_right_max, -3800},
  ["S3-6"] = {swip_right_max, -4150},
  ["S3-7"] = {swip_right_max, -4450},

  ["4-1"] = swip_right_max,
  ["4-2"] = {swip_right_max, -200},
  ["4-3"] = {swip_right_max, -450},
  ["S4-1"] = {swip_right_max, -650},
  ["S4-2"] = {swip_right_max, -900},
  ["S4-3"] = {swip_right_max, -1100},
  ["4-4"] = {swip_right_max, -1350},
  ["4-5"] = {swip_right_max, -1600},
  ["4-6"] = {swip_right_max, -1850},
  ["S4-4"] = {swip_right_max, -2050},
  ["S4-5"] = {swip_right_max, -2350},
  ["S4-6"] = {swip_right_max, -2700},
  ["4-7"] = {swip_right_max, -2900},
  ["4-8"] = {swip_right_max, -3150},
  ["4-9"] = {swip_right_max, -3400},
  ["S4-7"] = {swip_right_max, -3600},
  ["S4-8"] = {swip_right_max, -3850},
  ["S4-9"] = {swip_right_max, -4150},
  ["S4-10"] = {swip_right_max, -4450},
  ["4-10"] = {swip_right_max, -4700},

  ["5-1"] = swip_right_max,
  ["5-2"] = {swip_right_max, -350},
  ["S5-1"] = {swip_right_max, -550},
  ["S5-2"] = {swip_right_max, -900},
  ["5-3"] = {swip_right_max, -1150},
  ["5-4"] = {swip_right_max, -1500},
  ["5-5"] = {swip_right_max, -1850},
  ["5-6"] = {swip_right_max, -2150},
  ["S5-3"] = {swip_right_max, -2400},
  ["S5-4"] = {swip_right_max, -2750},
  ["5-7"] = {swip_right_max, -3000},
  ["5-8"] = {swip_right_max, -3300},
  ["5-9"] = {swip_right_max, -3600},
  ["S5-5"] = {swip_right_max, -3900},
  ["S5-6"] = {swip_right_max, -4200},
  ["S5-7"] = {swip_right_max, -4550},
  ["S5-8"] = {swip_right_max, -4850},
  ["S5-9"] = {swip_right_max, -5150},
  ["5-10"] = {swip_right_max, -5100},

  ["6-1"] = swip_right_max,
  ["6-2"] = {swip_right_max, -300},
  ["6-3"] = {swip_right_max, -550},
  ["6-4"] = {swip_right_max, -750},
  ["6-5"] = {swip_right_max, -1000},
  ["6-8"] = {swip_right_max, -1800},
  ["6-9"] = {swip_right_max, -2400},
  ["6-10"] = {swip_right_max, -2750},
  ["S6-1"] = {swip_right_max, -2900},
  ["S6-2"] = {swip_right_max, -3250},
  ["6-11"] = {swip_right_max, -3500},
  ["6-12"] = {swip_right_max, -3700},
  ["6-14"] = {swip_right_max, -4200},
  ["6-15"] = {swip_right_max, -4550},
  ["S6-3"] = {swip_right_max, -4800},
  ["S6-4"] = {swip_right_max, -5100},
  ["6-16"] = {swip_right_max, -5350},

  ["7-1"] = {swip_right_max},
  ["7-2"] = {swip_right_max, -300},
  ["7-3"] = {swip_right_max, -500},
  ["7-4"] = {swip_right_max, -650},
  ["7-5"] = {swip_right_max, -1000},
  ["7-6"] = {swip_right_max, -1350},
  ["7-8"] = {swip_right_max, -1900},
  ["7-9"] = {swip_right_max, -2100},
  ["7-10"] = {swip_right_max, -2450},
  ["7-11"] = {swip_right_max, -2700},
  ["7-12"] = {swip_right_max, -2950},
  ["7-13"] = {swip_right_max, -3150},
  ["7-14"] = {swip_right_max, -3350},
  ["7-15"] = {swip_right_max, -3600},
  ["7-16"] = {swip_right_max, -3850},
  ["S7-1"] = {swip_right_max, -4050},
  ["S7-2"] = {swip_right_max, -4350},
  ["7-17"] = {swip_right_max, -4550},
  ["7-18"] = {swip_right_max, -5200},

  ["R8-1"] = swip_right_max,
  ["R8-2"] = {swip_right_max, -350},
  ["R8-3"] = {swip_right_max, -650},
  ["R8-4"] = {swip_right_max, -950},
  ["R8-5"] = {swip_right_max, -1200},
  ["R8-6"] = {swip_right_max, -1500},
  ["R8-7"] = {swip_right_max, -1650},
  ["R8-8"] = {swip_right_max, -1800},
  ["R8-9"] = {swip_right_max, -2200},
  ["R8-10"] = {swip_right_max, -2400},
  ["R8-11"] = {swip_right_max, -2700},
  ["JT8-2"] = {swip_right_max, -3400},
  ["JT8-3"] = {swip_right_max, -3700},
  ["M8-6"] = {swip_right_max, -1800},
  ["M8-7"] = {swip_right_max, -2200},
  ["M8-8"] = {swip_right_max, -2650},

  -- chapter
  ["0"] = {
    {
      math.round(268 * minscale), screen.height // 2, screen.width - 1,
      screen.height // 2, 500,
    },
  },
  ["1"] = nil,
  ["2"] = nil,
  ["3"] = nil,
  ["4"] = {
    {
      math.round(268 * minscale), screen.height // 2, screen.width - 1,
      screen.height // 2, 500,
    },
  },
  ["5"] = {
    {
      math.round(268 * minscale), screen.height // 2, screen.width - 1,
      screen.height // 2, 500,
    },
  },
  ["6"] = nil,
  ["7"] = nil,
  ["8"] = nil,
}

rotate_point = function(x)
  local d = point_delimeter
  if type(x) ~= 'string' or not x:find(d) then return x end
  return x:gsub('([^' .. d .. ']+)' .. d .. '(.+)', '%2' .. d .. '%1')
end
expand_fight = function()
  local target = point["作战列表"]
  -- log(1114, target)
  local iter
  iter = {'A', 'B', 'C', 'D'}
  for i = 2, 2 do
    for _, x in pairs(iter) do
      target['PR-' .. x .. '-' .. i] = rotate_point(
                                         target['PR-' .. x .. '-' .. (i - 1)])
    end
  end
  for i = 2, 5 do target['AP-' .. i] = rotate_point(target['AP-' .. (i - 1)]) end
  iter = {'CE', 'CA', 'LS', 'SK'}
  for _, v in pairs(iter) do
    for i = 1, 5 do target[v .. '-' .. i] = target['AP-' .. i] end
  end
end
expand_fight()

flatten = function()
  local p = {}
  for k, v in pairs(point) do
    if k:endsWith('列表') and type(v) == 'table' then
      for k2, v2 in pairs(v) do
        p[k .. k2] = v2
        center[k .. k2] = center[k]
      end
      point[k] = {}
      for i = 1, #v do table.insert(point[k], k .. i) end
    end
  end
  update(point, p, true)
end
flatten()

point2center = function(src)
  local origin_center = {0, 0}
  local new_center = {0, 0}
  local position = (center[src] or "left_top")
  local x = position:match("^([^_]+)")
  local y = position:match("_([^_]+)")
  if x:find(coord_delimeter) then
    origin_center[1] = tonumber(x:match("(.+),"))
    new_center[1] = tonumber(x:match(",(.+)"))
  elseif x == 'left' then
    origin_center[1] = 0
    new_center[1] = 0
  elseif x == 'center' then
    origin_center[1] = 1919 / 2
    new_center[1] = (screen.width - 1) / 2
  elseif x == 'right' then
    origin_center[1] = 1919
    new_center[1] = screen.width - 1
  end

  if y:find(coord_delimeter) then
    origin_center[2] = tonumber(y:match("(.+),"))
    new_center[2] = tonumber(y:match(",(.+)"))
  elseif y == 'top' then
    origin_center[2] = 0
    new_center[2] = 0
  elseif y == 'center' then
    origin_center[2] = 1079 / 2
    new_center[2] = (screen.height - 1) / 2
  elseif y == 'bottom' then
    origin_center[2] = 1079
    new_center[2] = screen.height - 1
  end
  return origin_center, new_center
end

convert_coords = function(point)
  local origin_center, new_center
  local hs, ws
  for k, v in pairs(point) do
    if center[k] and center[k]:find("maxscale") then
      hs = maxscale
      ws = maxscale
    elseif center[k] and center[k]:find("anisotropy") then
      hs = hscale
      ws = wscale
    else
      hs = minscale
      ws = minscale
    end
    if type(v) == "table" and #v == 0 then
      convert_coords(v)
    elseif type(v) == "table" and
      table.all(v, function(x) return type(x) == 'number' end) then
      assert(#v % 2 == 0)
      origin_center, new_center = point2center(k)
      for i = 1, #v, 2 do
        v[i] = math.round((v[i] - origin_center[1]) * ws + new_center[1])
        v[i + 1] =
          math.round((v[i + 1] - origin_center[2]) * hs + new_center[2])
      end
    elseif type(v) == "string" and v:find(coord_delimeter) then
      origin_center, new_center = point2center(k)
      local dst = ''
      for x, y, c in v:gmatch("(%d+),(%d+),(#......)") do
        x, y = map(tonumber, x, y)
        x = math.round((x - origin_center[1]) * ws + new_center[1])
        y = math.round((y - origin_center[2]) * hs + new_center[2])
        dst = dst .. x .. ',' .. y .. ',' .. c .. '|'
      end
      dst = dst:sub(0, #dst - 1)
      point[k] = dst
    end
  end
end
convert_coords(point)

-- list for findColor globally
rfg = {
  线索传递橙框 = {0, 0, screen.width, screen.height},
  入驻干员 = point.入驻干员范围,
}

rfl = {}

point2region = function(v)
  local p, q, l, r, t, b = 0, 0, screen.width - 1, 0, screen.height - 1, 0
  local x, y
  while p do
    p = p + 1
    q = v:find(coord_delimeter, p)
    x = tonumber(v:sub(p, q - 1))
    y = tonumber(v:sub(q + 1, v:find(coord_delimeter, q + 1) - 1))
    l = min(l, x)
    r = max(r, x)
    t = min(t, y)
    b = max(b, y)
    p = v:find(point_delimeter, q + 1)
  end
  return {l, t, r + 1, b + 1}

end
update_rfl = function()
  -- region for findColor locally
  for k, v in pairs(point) do
    if type(v) == "string" and v:find(coord_delimeter) and not rfg[k] then
      rfl[k] = point2region(v)
    end
  end
end
update_rfl()
