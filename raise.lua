-- ===========================================
--               自动化练干员
-- ===========================================


--[[培养计划json举例
[                                   -- 数组
    {
        "skills": 7,                -- 通用技能升级
        "name": "逻各斯"            -- 干员名字
    },
    {
        "skill": 2,                 -- 几技能
        "skill_master": 3,          -- 专精等级
        "name": "维什戴尔"
    },
    {
        "name": "号角",
        "elite": 2                   -- 干员精英化等级
    }
]
]]



raise = {}

--初始化高级材料与低级材料映射关系表
高级材料2低级材料 = {
    ["30062"] = { child = { ["30061"] = 3 }, level = 1, name = "装置" },
    ["30061"] = { level = 0, name = "破损装置" },
    ["30024"] = { child = { ["30023"] = 2, ["30043"] = 1, ["30083"] = 1 }, level = 4, name = "糖聚块" },
    ["30145"] = { child = { ["31014"] = 2, ["31024"] = 1, ["31034"] = 1 }, level = 4, name = "晶体电子单元" },
    ["30023"] = { child = { ["30022"] = 4 }, level = 2, name = "糖组" },
    ["30103"] = { level = 2, name = "RMA70-12" },
    ["30064"] = { child = { ["30013"] = 2, ["30063"] = 1, ["30093"] = 1 }, level = 3, name = "改量装置" },
    ["30063"] = { child = { ["30062"] = 4 }, level = 2, name = "全新装置" },
    ["30022"] = { child = { ["30021"] = 3 }, level = 1, name = "糖" },
    ["31034"] = { child = { ["31013"] = 1, ["31023"] = 1, ["31033"] = 2 }, level = 3, name = "晶体电路" },
    ["30021"] = { level = 0, name = "代糖" },
    ["31033"] = { level = 2, name = "晶体元件" },
    ["30104"] = { child = { ["30013"] = 2, ["30103"] = 1, ["30053"] = 1 }, level = 3, name = "RMA70-24" },
    ["30093"] = { level = 2, name = "研磨石" },
    ["30051"] = { level = 1, name = "双酮" },
    ["31063"] = { level = 2, name = "转质盐组" },
    ["30094"] = { child = { ["30063"] = 1, ["30043"] = 1, ["30093"] = 1 }, level = 3, name = "五水研磨石" },
    ["30013"] = { child = { ["30012"] = 5 }, level = 2, name = "固源岩组" },
    ["30012"] = { child = { ["30011"] = 3 }, level = 1, name = "固源岩" },
    ["31024"] = { child = { ["30063"] = 1, ["31023"] = 1, ["30093"] = 1 }, level = 3, name = "炽合金块" },
    ["30135"] = { child = { ["30084"] = 1, ["30094"] = 1, ["30104"] = 1 }, level = 4, name = "D32钢" },
    ["30014"] = { child = { ["30013"] = 4 }, level = 3, name = "提纯源岩" },
    ["30053"] = { child = { ["30052"] = 4 }, level = 3, name = "酮凝集组" },
    ["30052"] = { child = { ["30051"] = 3 }, level = 2, name = "酮凝集" },
    ["31064"] = { child = { ["30023"] = 1, ["31043"] = 1, ["31063"] = 1 }, level = 3, name = "转质盐聚块" },
    ["30011"] = { level = 0, name = "源岩" },
    ["31023"] = { level = 2, name = "炽合金" },
    ["30054"] = { child = { ["30023"] = 1, ["30053"] = 2, ["30083"] = 1 }, level = 3, name = "酮阵列" },
    ["30084"] = { child = { ["30033"] = 1, ["30073"] = 1, ["30083"] = 2 }, level = 3, name = "三水锰矿" },
    ["30083"] = { level = 3, name = "轻锰矿" },
    ["31014"] = { child = { ["31013"] = 1, ["31023"] = 1, ["30043"] = 1 }, level = 3, name = "聚合凝胶" },
    ["31013"] = { level = 2, name = "凝胶" },
    ["30125"] = { child = { ["30064"] = 1, ["30074"] = 2 }, level = 4, name = "双极纳米片" },
    ["30042"] = { child = { ["30041"] = 3 }, level = 1, name = "异铁" },
    ["31054"] = { child = { ["30103"] = 1, ["31053"] = 1, ["31033"] = 1 }, level = 3, name = "切削原液" },
    ["30041"] = { level = 0, name = "异铁碎片" },
    ["31053"] = { level = 2, name = "化合切削液" },
    ["30044"] = { child = { ["30063"] = 1, ["30033"] = 1, ["30043"] = 2 }, level = 3, name = "异铁块" },
    ["30043"] = { child = { ["30042"] = 4 }, level = 2, name = "异铁组" },
    ["30073"] = { level = 3, name = "扭转醇" },
    ["30034"] = { child = { ["30053"] = 1, ["30033"] = 2, ["30073"] = 1 }, level = 4, name = "聚酸酯块" },
    ["30155"] = { child = { ["31054"] = 1, ["31064"] = 1, ["31044"] = 2 }, level = 4, name = "烧结核凝晶" },
    ["30031"] = { level = 1, name = "酯原料" },
    ["31043"] = { level = 2, name = "半自然溶剂" },
    ["30074"] = { child = { ["30023"] = 1, ["30103"] = 1, ["30073"] = 1 }, level = 3, name = "白马醇" },
    ["30033"] = { child = { ["30032"] = 4 }, level = 3, name = "聚酸酯组" },
    ["30032"] = { child = { ["30031"] = 3 }, level = 2, name = "聚酸酯" },
    ["31044"] = { child = { ["31013"] = 1, ["31043"] = 1, ["31053"] = 1 }, level = 3, name = "精炼溶剂" },
    ["31073"] = { level = 2, name = "褐素纤维" },
    ["31074"] = { child = { ["30013"] = 1, ["31033"] = 2, ["31063"] = 1 }, level = 3, name = "固化纤维板" },
    ["31083"] = { level = 2, name = "环烃聚质" },
    ["31084"] = { child = { ["31063"] = 1, ["31073"] = 1, ["31083"] = 1 }, level = 3, name = "环烃预制体" },
    ["30115"] = { child = { ["30014"] = 1, ["30044"] = 1, ["30054"] = 1 }, level = 4, name = "聚合剂" },
    ["32001"] = { level = 3, name = "芯片助剂" },
    ["3211"] = { level = 2, name = "先锋芯片" },
    ["3212"] = { level = 3, name = "先锋芯片组" },
    ["3213"] = { child = { ["32001"] = 1, ["3212"] = 2 }, level = 4, name = "先锋双芯片" },
    ["3221"] = { level = 2, name = "近卫芯片" },
    ["3222"] = { level = 3, name = "近卫芯片组" },
    ["3223"] = { child = { ["32001"] = 1, ["3222"] = 2 }, level = 4, name = "近卫双芯片" },
    ["3231"] = { level = 2, name = "重装芯片" },
    ["3232"] = { level = 3, name = "重装芯片组" },
    ["3233"] = { child = { ["32001"] = 1, ["3232"] = 2 }, level = 4, name = "重装双芯片" },
    ["3241"] = { level = 2, name = "狙击芯片" },
    ["3242"] = { level = 3, name = "狙击芯片组" },
    ["3243"] = { child = { ["32001"] = 1, ["3242"] = 2 }, level = 4, name = "狙击双芯片" },
    ["3251"] = { level = 2, name = "术师芯片" },
    ["3252"] = { level = 3, name = "术师芯片组" },
    ["3253"] = { child = { ["32001"] = 1, ["3252"] = 2 }, level = 4, name = "术师双芯片" },
    ["3261"] = { level = 2, name = "医疗芯片" },
    ["3262"] = { level = 3, name = "医疗芯片组" },
    ["3263"] = { child = { ["32001"] = 1, ["3262"] = 2 }, level = 4, name = "医疗双芯片" },
    ["3271"] = { level = 2, name = "辅助芯片" },
    ["3272"] = { level = 3, name = "辅助芯片组" },
    ["3273"] = { child = { ["32001"] = 1, ["3272"] = 2 }, level = 4, name = "辅助双芯片" },
    ["3281"] = { level = 2, name = "特种芯片" },
    ["3282"] = { level = 3, name = "特种芯片组" },
    ["3283"] = { child = { ["32001"] = 1, ["3282"] = 2 }, level = 4, name = "特种双芯片" },
}
--定义日常材料与刷取副本的期望映射关系
daily_materials_stage_json =
'{"30062":{"codes":[{"code":"6-11","stageId":"main_06-10","stdDev":0.8367},{"code":"M8-6","stageId":"main_08-09","stdDev":0.6094},{"code":"10-4","stageId":"main_10-03","stdDev":0.5375},{"code":"1-12","stageId":"main_01-12","stdDev":0.5273},{"code":"S3-4","stageId":"sub_03-2-2","stdDev":0.515}],"id":"30062","name":"装置"},"30084":{"codes":[{"code":"10-7","stageId":"tough_10-06","stdDev":0.2137},{"code":"13-11","stageId":"tough_13-09","stdDev":0.2041},{"code":"13-20","stageId":"tough_13-18","stdDev":0.1923},{"code":"4-7","stageId":"main_04-07","stdDev":0.1882},{"code":"R8-10","stageId":"main_08-11","stdDev":0.183}],"id":"30084","name":"三水锰矿"},"30061":{"codes":[{"code":"2-3","stageId":"main_02-03","stdDev":0.7501},{"code":"1-5","stageId":"main_01-05","stdDev":0.5116},{"code":"S2-10","stageId":"sub_02-10","stdDev":0.382},{"code":"S2-5","stageId":"sub_02-05","stdDev":0.3768},{"code":"2-9","stageId":"main_02-09","stdDev":0.3711}],"id":"30061","name":"破损装置"},"30083":{"codes":[{"code":"10-16","stageId":"main_10-14","stdDev":0.5032},{"code":"7-16","stageId":"main_07-14","stdDev":0.5012},{"code":"10-7","stageId":"tough_10-06","stdDev":0.4979},{"code":"13-11","stageId":"tough_13-09","stdDev":0.4967},{"code":"13-20","stageId":"main_13-18","stdDev":0.4954}],"id":"30083","name":"轻锰矿"},"30024":{"codes":[{"code":"10-10","stageId":"main_10-09","stdDev":0.205},{"code":"12-14","stageId":"tough_12-12","stdDev":0.2013},{"code":"13-17","stageId":"tough_13-15","stdDev":0.1981},{"code":"4-2","stageId":"main_04-02","stdDev":0.1909},{"code":"5-2","stageId":"main_05-02","stdDev":0.1842}],"id":"30024","name":"糖聚块"},"31014":{"codes":[{"code":"11-12","stageId":"tough_11-10","stdDev":0.2356},{"code":"10-3","stageId":"tough_10-02","stdDev":0.2213},{"code":"12-5","stageId":"tough_12-04","stdDev":0.2193},{"code":"JT8-2","stageId":"main_08-16","stdDev":0.2183},{"code":"7-8","stageId":"main_07-06","stdDev":0.2048}],"id":"31014","name":"聚合凝胶"},"30023":{"codes":[{"code":"10-10","stageId":"main_10-09","stdDev":0.552},{"code":"11-6","stageId":"tough_11-05","stdDev":0.5297},{"code":"13-17","stageId":"main_13-15","stdDev":0.5208},{"code":"M8-7","stageId":"main_08-12","stdDev":0.5159},{"code":"4-2","stageId":"main_04-02","stdDev":0.5039}],"id":"30023","name":"糖组"},"31013":{"codes":[{"code":"12-5","stageId":"main_12-04","stdDev":0.5047},{"code":"11-12","stageId":"main_11-10","stdDev":0.4962},{"code":"10-3","stageId":"main_10-02","stdDev":0.486},{"code":"JT8-2","stageId":"main_08-16","stdDev":0.4805},{"code":"R8-8","stageId":"main_08-08","stdDev":0.4668}],"id":"31013","name":"凝胶"},"30103":{"codes":[{"code":"9-19","stageId":"main_09-17","stdDev":0.5059},{"code":"R8-9","stageId":"main_08-10","stdDev":0.489},{"code":"7-10","stageId":"main_07-08","stdDev":0.4833},{"code":"12-7","stageId":"main_12-06","stdDev":0.4669},{"code":"11-5","stageId":"main_11-04","stdDev":0.4655}],"id":"30103","name":"RMA70-12"},"30042":{"codes":[{"code":"11-6","stageId":"main_11-05","stdDev":1.1589},{"code":"M8-7","stageId":"main_08-12","stdDev":1.126},{"code":"5-7","stageId":"main_05-07","stdDev":0.9001},{"code":"S3-3","stageId":"sub_03-2-1","stdDev":0.5704},{"code":"9-16","stageId":"main_09-14","stdDev":0.5308}],"id":"30042","name":"异铁"},"30064":{"codes":[{"code":"11-20","stageId":"tough_11-18","stdDev":0.1783},{"code":"4-10","stageId":"main_04-10","stdDev":0.1698},{"code":"7-9","stageId":"main_07-07","stdDev":0.1683},{"code":"13-10","stageId":"main_13-08","stdDev":0.1608}],"id":"30064","name":"改量装置"},"31054":{"codes":[{"code":"11-16","stageId":"main_11-14","stdDev":0.2218},{"code":"12-17","stageId":"main_12-15","stdDev":0.2205},{"code":"9-6","stageId":"main_09-05","stdDev":0.2057}],"id":"31054","name":"切削原液"},"30063":{"codes":[{"code":"11-7","stageId":"main_11-06","stdDev":0.5075},{"code":"M8-8","stageId":"main_08-14","stdDev":0.4797},{"code":"7-15","stageId":"main_07-13","stdDev":0.4724},{"code":"9-10","stageId":"main_09-08","stdDev":0.4719},{"code":"6-16","stageId":"main_06-14","stdDev":0.468}],"id":"30063","name":"全新装置"},"30041":{"codes":[{"code":"S2-8","stageId":"sub_02-08","stdDev":0.5913},{"code":"1-3","stageId":"main_01-03","stdDev":0.4857},{"code":"S2-9","stageId":"sub_02-09","stdDev":0.4334},{"code":"S2-6","stageId":"sub_02-06","stdDev":0.4295},{"code":"S2-11","stageId":"sub_02-11","stdDev":0.4167}],"id":"30041","name":"异铁碎片"},"31053":{"codes":[{"code":"10-17","stageId":"tough_10-15","stdDev":0.5122},{"code":"12-17","stageId":"tough_12-15","stdDev":0.5105},{"code":"11-16","stageId":"main_11-14","stdDev":0.4854},{"code":"9-6","stageId":"main_09-05","stdDev":0.452},{"code":"12-13","stageId":"main_12-11","stdDev":0.1226}],"id":"31053","name":"化合切削液"},"30044":{"codes":[{"code":"10-11","stageId":"main_10-10","stdDev":0.2038},{"code":"11-11","stageId":"tough_11-09","stdDev":0.1873},{"code":"13-16","stageId":"main_13-14","stdDev":0.1836},{"code":"S4-1","stageId":"sub_04-1-1","stdDev":0.1766},{"code":"5-5","stageId":"main_05-05","stdDev":0.1731}],"id":"30044","name":"异铁块"},"30022":{"codes":[{"code":"11-2","stageId":"main_11-02","stdDev":1.2131},{"code":"7-6","stageId":"main_07-05","stdDev":0.9454},{"code":"5-3","stageId":"main_05-03","stdDev":0.9078},{"code":"S3-1","stageId":"sub_03-1-1","stdDev":0.6259},{"code":"R8-5","stageId":"main_08-05","stdDev":0.5413}],"id":"30022","name":"糖"},"31034":{"codes":[{"code":"12-19","stageId":"tough_12-17","stdDev":0.2084},{"code":"12-3","stageId":"tough_12-02","stdDev":0.2022},{"code":"R8-11","stageId":"main_08-13","stdDev":0.193},{"code":"13-7","stageId":"main_13-06","stdDev":0.1879},{"code":"S5-9","stageId":"sub_05-4-3","stdDev":0.1834}],"id":"31034","name":"晶体电路"},"30043":{"codes":[{"code":"10-11","stageId":"main_10-10","stdDev":0.531},{"code":"7-18","stageId":"main_07-16","stdDev":0.5058},{"code":"11-11","stageId":"main_11-09","stdDev":0.5016},{"code":"13-16","stageId":"main_13-14","stdDev":0.4958},{"code":"S4-1","stageId":"sub_04-1-1","stdDev":0.474}],"id":"30043","name":"异铁组"},"30021":{"codes":[{"code":"S2-6","stageId":"sub_02-06","stdDev":0.5872},{"code":"S2-11","stageId":"sub_02-11","stdDev":0.4534},{"code":"2-7","stageId":"main_02-07","stdDev":0.4505},{"code":"S2-8","stageId":"sub_02-08","stdDev":0.4489},{"code":"2-8","stageId":"main_02-08","stdDev":0.4481}],"id":"30021","name":"代糖"},"31033":{"codes":[{"code":"R8-11","stageId":"main_08-13","stdDev":0.5139},{"code":"9-14","stageId":"main_09-12","stdDev":0.5057},{"code":"12-19","stageId":"main_12-17","stdDev":0.5045},{"code":"13-7","stageId":"main_13-06","stdDev":0.5001},{"code":"12-3","stageId":"tough_12-02","stdDev":0.4981}],"id":"31033","name":"晶体元件"},"30104":{"codes":[{"code":"12-7","stageId":"main_12-06","stdDev":0.2112},{"code":"4-9","stageId":"main_04-09","stdDev":0.2032},{"code":"10-5","stageId":"main_10-04","stdDev":0.1951},{"code":"11-5","stageId":"main_11-04","stdDev":0.1938},{"code":"6-15","stageId":"main_06-13","stdDev":0.1799}],"id":"30104","name":"RMA70-24"},"30093":{"codes":[{"code":"10-12","stageId":"main_10-11","stdDev":0.535},{"code":"13-21","stageId":"main_13-19","stdDev":0.512},{"code":"9-16","stageId":"main_09-14","stdDev":0.5118},{"code":"4-8","stageId":"main_04-08","stdDev":0.4899},{"code":"5-7","stageId":"main_05-07","stdDev":0.4869}],"id":"30093","name":"研磨石"},"30073":{"codes":[{"code":"11-13","stageId":"main_11-11","stdDev":0.5257},{"code":"13-19","stageId":"main_13-17","stdDev":0.5132},{"code":"6-11","stageId":"main_06-10","stdDev":0.5061},{"code":"10-15","stageId":"main_10-13","stdDev":0.5046},{"code":"12-6","stageId":"main_12-05","stdDev":0.5043}],"id":"30073","name":"扭转醇"},"30051":{"codes":[{"code":"S2-9","stageId":"sub_02-09","stdDev":0.5635},{"code":"10-9","stageId":"main_10-08","stdDev":0.5113},{"code":"13-20","stageId":"main_13-18","stdDev":0.4971},{"code":"13-21","stageId":"main_13-19","stdDev":0.4927},{"code":"12-10","stageId":"tough_12-09","stdDev":0.4922}],"id":"30051","name":"双酮"},"31063":{"codes":[{"code":"11-3","stageId":"tough_11-03","stdDev":0.4782},{"code":"12-13","stageId":"tough_12-11","stdDev":0.4744},{"code":"11-15","stageId":"tough_11-13","stdDev":0.4742},{"code":"13-13","stageId":"main_13-11","stdDev":0.4723},{"code":"S9-2","stageId":"sub_09-1-2","stdDev":0.4246}],"id":"31063","name":"转质盐组"},"30094":{"codes":[{"code":"4-8","stageId":"main_04-08","stdDev":0.2079},{"code":"13-21","stageId":"main_13-19","stdDev":0.2079},{"code":"7-17","stageId":"main_07-15","stdDev":0.2068},{"code":"12-8","stageId":"main_12-07","stdDev":0.2037}],"id":"30094","name":"五水研磨石"},"30013":{"codes":[{"code":"11-18","stageId":"main_11-16","stdDev":0.5411},{"code":"12-15","stageId":"main_12-13","stdDev":0.5337},{"code":"13-3","stageId":"tough_13-02","stdDev":0.5205},{"code":"5-1","stageId":"main_05-01","stdDev":0.5205},{"code":"4-6","stageId":"main_04-06","stdDev":0.5151}],"id":"30013","name":"固源岩组"},"30012":{"codes":[{"code":"S3-7","stageId":"sub_03-3-2","stdDev":1.3678},{"code":"5-10","stageId":"main_05-10","stdDev":1.3319},{"code":"S2-12","stageId":"sub_02-12","stdDev":0.998},{"code":"7-16","stageId":"main_07-14","stdDev":0.9622},{"code":"S6-2","stageId":"sub_06-1-2","stdDev":0.7886}],"id":"30012","name":"固源岩"},"31024":{"codes":[{"code":"13-18","stageId":"tough_13-16","stdDev":0.2216},{"code":"11-14","stageId":"main_11-12","stdDev":0.211},{"code":"13-6","stageId":"tough_13-05","stdDev":0.206},{"code":"10-14","stageId":"main_10-12","stdDev":0.2052},{"code":"12-12","stageId":"main_12-10","stdDev":0.2039}],"id":"31024","name":"炽合金块"},"30034":{"codes":[{"code":"12-18","stageId":"main_12-16","stdDev":0.1983},{"code":"13-12","stageId":"main_13-10","stdDev":0.1971},{"code":"3-8","stageId":"main_03-08","stdDev":0.1769},{"code":"9-7","stageId":"main_09-06","stdDev":0.1752},{"code":"6-4","stageId":"main_06-04","stdDev":0.1706}],"id":"30034","name":"聚酸酯块"},"30014":{"codes":[{"code":"11-18","stageId":"main_11-16","stdDev":0.2305},{"code":"12-15","stageId":"tough_12-13","stdDev":0.2296},{"code":"13-3","stageId":"tough_13-02","stdDev":0.2276},{"code":"4-6","stageId":"main_04-06","stdDev":0.2182},{"code":"R8-3","stageId":"main_08-03","stdDev":0.213}],"id":"30014","name":"提纯源岩"},"30053":{"codes":[{"code":"12-20","stageId":"main_12-18","stdDev":0.5226},{"code":"10-4","stageId":"main_10-03","stdDev":0.5209},{"code":"13-4","stageId":"main_13-03","stdDev":0.5109},{"code":"JT8-3","stageId":"main_08-17","stdDev":0.5024},{"code":"3-1","stageId":"main_03-01","stdDev":0.4843}],"id":"30053","name":"酮凝集组"},"30031":{"codes":[{"code":"S2-7","stageId":"sub_02-07","stdDev":0.6608},{"code":"10-9","stageId":"main_10-08","stdDev":0.5437},{"code":"11-11","stageId":"main_11-09","stdDev":0.5187},{"code":"13-6","stageId":"main_13-05","stdDev":0.5185},{"code":"13-21","stageId":"main_13-19","stdDev":0.5179}],"id":"30031","name":"酯原料"},"31043":{"codes":[{"code":"12-10","stageId":"tough_12-09","stdDev":0.4995},{"code":"11-8","stageId":"main_11-07","stdDev":0.4963},{"code":"13-14","stageId":"main_13-12","stdDev":0.4753},{"code":"9-18","stageId":"main_09-16","stdDev":0.4723},{"code":"9-4","stageId":"main_09-03","stdDev":0.4541}],"id":"31043","name":"半自然溶剂"},"30052":{"codes":[{"code":"10-9","stageId":"main_10-08","stdDev":0.9934},{"code":"7-18","stageId":"main_07-16","stdDev":0.9927},{"code":"7-12","stageId":"main_07-10","stdDev":0.8555},{"code":"6-16","stageId":"main_06-14","stdDev":0.801},{"code":"R8-8","stageId":"main_08-08","stdDev":0.7136}],"id":"30052","name":"酮凝集"},"30074":{"codes":[{"code":"10-15","stageId":"tough_10-13","stdDev":0.2366},{"code":"13-19","stageId":"tough_13-17","stdDev":0.2192},{"code":"11-13","stageId":"tough_11-11","stdDev":0.219},{"code":"12-6","stageId":"tough_12-05","stdDev":0.2172},{"code":"4-4","stageId":"main_04-04","stdDev":0.2096}],"id":"30074","name":"白马醇"},"31064":{"codes":[{"code":"12-13","stageId":"main_12-11","stdDev":0.2453},{"code":"11-15","stageId":"tough_11-13","stdDev":0.242},{"code":"13-13","stageId":"main_13-11","stdDev":0.2255},{"code":"11-3","stageId":"main_11-03","stdDev":0.2251}],"id":"31064","name":"转质盐聚块"},"30011":{"codes":[{"code":"S2-5","stageId":"sub_02-05","stdDev":1.2376},{"code":"0-9","stageId":"main_00-09","stdDev":0.749},{"code":"2-3","stageId":"main_02-03","stdDev":0.5131},{"code":"2-9","stageId":"main_02-09","stdDev":0.501},{"code":"S2-7","stageId":"sub_02-07","stdDev":0.4972}],"id":"30011","name":"源岩"},"30033":{"codes":[{"code":"13-12","stageId":"tough_13-10","stdDev":0.5265},{"code":"9-7","stageId":"main_09-06","stdDev":0.5073},{"code":"12-18","stageId":"main_12-16","stdDev":0.5067},{"code":"3-8","stageId":"main_03-08","stdDev":0.5052},{"code":"7-4","stageId":"main_07-03","stdDev":0.5037}],"id":"30033","name":"聚酸酯组"},"31023":{"codes":[{"code":"13-18","stageId":"main_13-16","stdDev":0.5679},{"code":"11-14","stageId":"main_11-12","stdDev":0.5271},{"code":"13-6","stageId":"main_13-05","stdDev":0.5112},{"code":"11-2","stageId":"main_11-02","stdDev":0.5086},{"code":"S3-6","stageId":"sub_03-3-1","stdDev":0.4985}],"id":"31023","name":"炽合金"},"30032":{"codes":[{"code":"6-5","stageId":"main_06-05","stdDev":0.9378},{"code":"10-16","stageId":"main_10-14","stdDev":0.911},{"code":"S3-2","stageId":"sub_03-1-2","stdDev":0.6281},{"code":"S5-3","stageId":"sub_05-2-1","stdDev":0.4976},{"code":"1-8","stageId":"main_01-08","stdDev":0.4764}],"id":"30032","name":"聚酸酯"},"30054":{"codes":[{"code":"12-20","stageId":"main_12-18","stdDev":0.1988},{"code":"12-4","stageId":"main_12-03","stdDev":0.1876},{"code":"13-4","stageId":"main_13-03","stdDev":0.187},{"code":"4-5","stageId":"main_04-05","stdDev":0.1786},{"code":"S9-1","stageId":"sub_09-1-1","stdDev":0.1772}],"id":"30054","name":"酮阵列"},"31044":{"codes":[{"code":"11-8","stageId":"main_11-07","stdDev":0.2386},{"code":"13-14","stageId":"main_13-12","stdDev":0.2358},{"code":"12-10","stageId":"main_12-09","stdDev":0.2297},{"code":"9-18","stageId":"main_09-16","stdDev":0.2159},{"code":"9-4","stageId":"main_09-03","stdDev":0.2137}],"id":"31044","name":"精炼溶剂"}}'
--初始化日常材料与刷取副本的期望映射关系表
daily_materials_stage = jsonLib.decode(daily_materials_stage_json)

-- 初始化活动期间素材与活动关卡映射关系表
activity_materials_stage = {
    ["30043"] = { stdDev = 1, code = "hd-7" },
    ["31013"] = { stdDev = 0.6, code = "hd-8" }
}

-- 初始化数据及玩家信息
raise.init = function()
    --log(raise_plan_text)
    -- 读取培养计划
    local status
    status, raise_plan = pcall(JsonDecode, raise_plan_text)

    --log("培养计划", raise_plan)
    if not status then
        log("传入培养计划格式错误")
        return
    end
    if not character_table then
        -- 解包干员数据
        character_table = JsonDecode(readFile("char_table.json"))
    end
    干员类别 = { "PIONEER", "WARRIOR", "TANK", "SNIPER", "CASTER", "MEDIC", "SPECIAL", "SUPPORT" }
    if not 干员职业 then
        干员职业 = JsonDecode(readFile("character_type_list.json"))
    end
    -- 正在进行技能专精
    mastering = false

    if not character_name2id then
        character_name2id = {}
        for k, v in pairs(character_table) do
            local name = v["name"]
            character_name2id[name] = k
        end
    end

    if not item_name2id then
        item_name2id = {}
        for k, v in pairs(高级材料2低级材料) do
            local name = v["name"]
            item_name2id[name] = tostring(k)
        end
    end
    --log(item_name2id)
    --[[
    if not player_info_init(raise.get_player_info()) then
        log("玩家信息初始化错误")
        return
    end
    --log("干员数据", player_character_info)
    log("仓库数据", player_inventory_info)]]
    return true
end

---接口获取玩家信息
---@param isLocal bool 是否本地测试
---@return table player_data 玩家数据
raise.get_player_info = function(isLocal)
    if not isLocal or auto_raise_api_select == 3 then
        if auto_raise_api_select == 0 then
            data = get_game_info(username, password)
            log("data:", data)
            return data
        elseif auto_raise_api_select == 1 then
            if (not a60_token_offcial) or (not a60_token_bili) then return end
            if server == 0 then
                local url = "http://pyark.a60.one:88/login/offcial?username=%s&password=%s&token=%s"
                url = string.format(url, username, password, a60_token_offcial)
            else
                local url = "http://pyark.a60.one:88/login/bilibili?username=%s&password=%s&token=%s"
                url = string.format(url, username, password, a60_token_bili)
            end
            local ret, code = httpGet(url)
            if code ~= 200 then return end
            local status, player_data = pcall(JsonDecode, ret)
            if not status then return end
            return player_data
        elseif auto_raise_api_select == 2 then

        end
    else
        -- 本地测试数据
        local player_data = JsonDecode(readFile("data1.json"))
        return player_data["data"]
    end
end

-- 初始化玩家干员数据
player_info_init = function(player_data)
    player_character_info = {} -- 玩家干员数据
    player_inventory_info = {} -- 玩家仓库数据
    if type(player_data) ~= "table" or player_data == {} or player_data["characters"] == nil then
        log("player_data解析出错")
        return
    end
    if auto_raise_api_select == 0 then
        for _, v in pairs(player_data["characters"]) do
            local name = v["id"]
            player_character_info[name] = v
        end
        -- 根据building数据更新训练室干员的专精等级
        for _, v in pairs(player_data["items"]) do
            local itemId = v["id"]
            local count = tonumber(v["count"])
            player_inventory_info[itemId] = count
        end
    elseif auto_raise_api_select == 1 then
        -- 仓库数据,{材料id:数量}
        player_inventory_info = player_data["user"]["inventory"]

        local ori_player_character_info = player_data["user"]["troop"]["chars"]
        for _, v in pairs(ori_player_character_info) do
            local name = v["charId"]
            player_character_info[name] = v
        end
    end
    return true
end

-- 材料ID转换材料名
material_id2name = function(id)
    return 高级材料2低级材料[id]["name"]
end

-- 材料名转换材料ID
material_name2id = function(name)
    --print(item_name2id)
    return item_name2id[name]
end

-- 干员ID转换干员名
char_id2name = function(id)
    return character_table[id]["name"]
end

-- 干员名字转换到ID
char_name2id = function(name)
    return character_name2id[name]
end

---获取指定干员ID的现有精英化等级
---@return number
raise.get_char_elite = function(id)
    return player_character_info[id]["evolvePhase"]
end

-- 获取指定干员ID的现有技能信息
---@param id string 干员id
---@param skill_id_index number 该干员的第几个技能
---@return table {通用技能等级，专精等级}
raise.get_char_skill = function(id, skill_id_index)
    skill_id_index = skill_id_index or 1
    -- 通用技能等级
    local common_skill_level = player_character_info[id]["mainSkillLevel"]
    if common_skill_level == 7 then
        return { 7, player_character_info[id]["skills"][skill_id_index]["level"] }
    else
        return { common_skill_level, 0 }
    end
end

-- 获取指定干员指定技能的升级材料
---@param id string 干员id
---@param skill_id number 该干员的第几个技能
---@param target_level number 目标专精等级
---@return table t {id:count} 其中id 4位数字的是技能书
raise.char_skill_master_material = function(id, skill_id, target_level)
    local skill_info = character_table[id]["skills"][skill_id]["levelUpCostCond"][target_level]["levelUpCost"]
    --log("需要材料",skill_info)
    local t = {}
    for i = 1, #skill_info do
        t[skill_info[i]["id"]] = skill_info[i]["count"]
    end
    return t
end

raise.char_skill_upgrade_material = function(id, skill_id_index)

end


---计算角色技能升级所需材料总量
---@param id number 干员ID
---@param skill_id_index number 几技能
---@param target_level number 目标专精等级
---@return table total_material 包含材料ID和对应数量的表
raise.char_skill_upgrade_material_total = function(id, skill_id_index, target_level)
    -- 通用技能等级
    local common_skill_level = player_character_info[id]["mainSkillLevel"]
    -- 指定技能当前专精等级
    local current_skill_level
    if common_skill_level < 7 then
        current_skill_level = 0
    else
        current_skill_level = player_character_info[id]["skills"][skill_id_index]["level"]
    end

    local skill_info = raise.char_skill_upgrade_material(id, skill_id_index)
    if target_level == current_skill_level then return {} end
    total_material = {}
    for i = target_level, current_skill_level + 1, -1 do
        local levelUpCostCond = skill_info["levelUpCostCond"][i]["levelUpCost"]
        for k, v in pairs(levelUpCostCond) do
            if v["type"] == "MATERIAL" then
                local id = v["id"]
                local count = v["count"]
                if total_material[id] then
                    total_material[id] = total_material[id] + count
                else
                    total_material[id] = count
                end
            end
        end
    end
    return total_material
end

-- 获取指定干员的精英化材料
raise.char_phase_upgrade_material = function(id)
    return character_table[id]["phases"]
end

---获取干员指定精英化等级所需材料
---@return table t 材料id:数量
raise.get_char_elite_material = function(id, target_phase)
    local cost = character_table[id]["phases"][target_phase + 1]["evolveCost"]
    local t = {}
    for i = 1, #cost do
        t[cost[i]["id"]] = cost[i]["count"]
    end
    log(t)
    return t
end

-- 计算指定干员精英化材料总数
raise.char_phase_upgrade_material_total = function(id, target_phase)
    local total_material = {}
    local current_char_phase = raise.char_phase_level(id)
    if target_phase == current_char_phase then return {} end
    local phase_info = raise.char_phase_upgrade_material(id)
    table.remove(phase_info, 1)
    total_material = {}
    for i = target_phase, current_char_phase + 1, -1 do
        local levelUpCostCond = phase_info[i]["evolveCost"]
        for k, v in pairs(levelUpCostCond) do
            if v["type"] == "MATERIAL" then
                local id = v["id"]
                local count = v["count"]
                if total_material[id] then
                    total_material[id] = total_material[id] + count
                else
                    total_material[id] = count
                end
            end
        end
    end
    return total_material
end

---计算仓库材料缺失总数
---@param materials table 材料id:数量
raise.calculate_materials_need = function(materials)
    local need_materials = {}
    --log(player_inventory_info)
    for k, v in pairs(materials) do
        --log(k, v)
        local current_count = player_inventory_info[k] or 0
        if current_count < v then
            need_materials[k] = v - current_count
        end
    end
    return need_materials
end

-- 根据材料生成需要刷的关卡 默认缺一个材料刷一次关
raise.generate_fight_plan = function(materials)
    local plan = {}
end

-- 生成刷图计划 传入干员名和计划名 返回作战列表
raise.generate_fight_plan = function(待养成干员, 养成计划)
    local fight_plan = {}
    local char_id = raise.char_name_to_id(待养成干员)
    if char_id == nil then return end
    if 养成计划.plan == "精英化" then
        local 精英化等级 = tonumber(养成计划.level)
        local 材料需求 = raise.char_phase_upgrade_material_total(char_id, 精英化等级)
        if 材料需求 == {} then return {} end
        材料需求 = raise.calculate_materials_need(材料需求)
    elseif 养成计划.plan == "专精" then
        local 专精等级 = tonumber(养成计划.level)
        local 专精技能 = tonumber(养成计划.index)
        local 材料需求 = raise.char_skill_upgrade_material_total(char_id, 专精技能, 专精等级)
        if 材料需求 == {} then return {} end
        材料需求 = raise.calculate_materials_need(材料需求)
    end
end


---计算刷图计划与合成计划
---@param material_need table {id:count}
---@return table table 刷图计划
---@return table final_synthesis_materials_result 存放需要合成的子材料 数据格式level:{id:count}
raise.get_fight_plan = function(material_need)
    log(353, "需要材料列表", material_need)
    local final_materials_result = {}
    -- 存放需要合成的子材料 数据格式level:{id:count}
    local final_synthesis_materials_result = {}

    for id, count in pairs(material_need) do
        -- 存放当前材料的子材料 数据格式id:count
        local current_fight_materials_result = {}
        --递归计算当前材料所需的子材料,收集到current_fight_materials_result
        calc_fight_materials(id, count, 1, current_fight_materials_result, final_synthesis_materials_result)

        -- 将每个顶级材料解析出来的2级或3级材料统一收集,避免精英化或专精时多个4级材料依赖同一个2或3级材料的情况
        -- 避免同一个材料生成两条作战配置
        -- 合并子材料所需的数量
        for m_id, m_count in pairs(current_fight_materials_result) do
            final_materials_result[m_id] = final_materials_result[m_id] + m_count
        end
    end
    log(final_materials_result)
    -- 将子材料转换成具体的刷图配置
    -- eg. {{hd-7*5,6-11*10},{hd-6*5,6-12*10}}
    -- 案例表示返回了两个材料对应的两组刷图副本,如果前面的没有代理,可尝试后面的,每个材料尝试分组内的关卡
    return calc_fight_plan(final_materials_result), final_synthesis_materials_result
end



---需要刷图的材料集合fight_materials_result
--  final_synthesis_materials_result
---@param item_id string 材料id
---@param need_count number 需要的数量
---@param minLevel number (暂时默认绿色等级)材料,仅支持刷图获取,不支持合成
---@param fight_materials_result table
---@param final_synthesis_materials_result table 合成路线计划集合
calc_fight_materials = function(item_id, need_count, minLevel, fight_materials_result, final_synthesis_materials_result)
    local current_materials_info = 高级材料2低级材料[item_id]
    -- log("材料", item_id, "需要数量", need_count, minLevel, fight_materials_result, final_synthesis_materials_result)
    -- 如果当前材料在材料合成关系表中不存在,直接返回,且设置一个error的标志位
    if not current_materials_info then
        fight_materials_result["error"] = true
        return
    end

    -- todo 如果是龙门币或者狗粮,直接进行结算,转换成具体的刷图关卡及次数
    local current_count = player_inventory_info[item_id] or 0

    --扣减仓库材料,仓库足够直接返回,停止递归
    -- log("现有数量", current_count)
    if current_count >= need_count then
        player_inventory_info[item_id] = player_inventory_info[item_id] - need_count
        return
    else
        --先扣减仓库,不足的部分,判断是刷图获取还是合成获取
        need_count = need_count - player_inventory_info[item_id]
        player_inventory_info[item_id] = 0
    end

    local level = current_materials_info["level"]

    --如果当前材料是蓝色或者刷图获取的材料,直接添到结果集中
    --或者当前材料是不可合成的,即无下级子材料的直接添加到结果集中
    if level <= minLevel then
        fight_materials_result[item_id] = need_count
        return
    end

    local childs = current_materials_info["child"]

    if childs == nil then
        fight_materials_result[item_id] = need_count
        return
    end

    -- 收集需要合成获取得材料
    local current_fight_materials = final_synthesis_materials_result[tostring(level)]
    if current_fight_materials ~= nil then
        current_fight_materials[item_id] = current_fight_materials[item_id] + need_count
    else
        local temp = {}
        temp[item_id] = need_count
        final_synthesis_materials_result[tostring(level)] = temp
    end
    -- 循环递归子材料
    for id, count in pairs(childs) do
        local need = count * need_count
        --递归子材料
        calc_fight_materials(id, need, minLevel, fight_materials_result, final_synthesis_materials_result)
    end
end

-- 活动期间的材料副本映射关系activity_materials_stage,全局变量
-- 日常期间副材料副本映射关系daily_materials_stage,全局变量
calc_fight_plan = function(final_materials_result)
    local fight_plan = {};

    -- 优化将活动掉落的材料放在最前面执行,避免因为刷其他材料错过活动期间的高掉率
    -- 查找目标元素在表中的位置
    local index = 1
    local target = nil
    for m_id, m_count in pairs(final_materials_result) do
        -- 如果需要刷图的材料中有一个在活动中出现
        target = activity_materials_stage[m_id]
        if target then
            break
        end
        index = index + 1
    end

    -- 如果找到了目标元素
    if index <= #final_materials_result then
        -- 从原位置移除目标元素
        table.remove(final_materials_result, index)
        -- 将目标元素插入到第一个位置
        table.insert(final_materials_result, 1, target)
    end

    -- 遍历最终需要刷图的材料 key:材料id count:数量
    for id, count in pairs(final_materials_result) do
        local current_fight_plan = {};
        -- 遍历codes数组
        for _, codeInfo in ipairs(daily_materials_stage[id]["codes"]) do
            -- 使用数量除以期望(掉落概率)获取实际应刷图的次数 例如hd-7*10
            local str = codeInfo["code"] .. "*" .. math.ceil(count / codeInfo["stdDev"])
            table.insert(current_fight_plan, str) --在末尾添加
        end

        -- 如果当前材料在活动期间有掉落,则当前材料刷图副本组中,将活动排到第一的位置
        local firstStageInfo = activity_materials_stage[id]

        if firstStageInfo ~= nil then
            local activity_fight_str = firstStageInfo["code"] .. "*" .. math.ceil(count / firstStageInfo["stdDev"])
            table.insert(current_fight_plan, 1, activity_fight_str)
        end
        fight_plan[id] = current_fight_plan
    end
    return fight_plan
end

材料等级 = {
    金色材料 = {
        "烧结核凝晶",
        "晶体电子单元",
        "D32钢",
        "双极纳米片",
        "聚合剂",
    },
    紫色材料 = {
        "转质盐聚块",
        "环烃预制体",
        "切削原液",
        "固化纤维板",
        "精炼溶剂",
        "晶体电路",
        "炽合金块",
        "聚合凝胶",
        "三水锰矿",
        "五水研磨石",
        "RMA70-24",
        "提纯源岩",
        "改量装置",
        "聚酸酯块",
        "糖聚块",
        "异铁块",
        "白马醇",
        "酮阵列",
        "芯片助剂",
    },
    绿色材料 = {
        "异铁",
        "糖",
        "聚酸酯",
        "酮凝集",
        "固源岩",
        "装置",
    },
    灰色材料 = {
        "源岩",
        "破损装置",
        "酯原料",
        "代糖",
        "异铁碎片",
        "双酮",
    },
    蓝色材料 = {
        "半自然溶剂",
        "炽合金",
        "晶体元件",
        "凝胶",
        "扭转醇",
        "轻锰矿",
        "研磨石",
        "RMA70-12",
        "固源岩组",
        "全新装置",
        "聚酸酯组",
        "糖组",
        "异铁组",
        "酮凝集组",
        "环烃聚质",
        "转质盐组",
        "化合切削液",
        "褐素纤维",
    }

}

材料等级颜色 = {
    -- 灰色材料可信度很低，因为游戏多处用到灰色
    -- 灰色材料 = "A0A0A0",
    紫色材料 = "332344",
    绿色材料 = "DEE639",
    蓝色材料 = "00ACF0",
    金色材料 = "FCC708",
}

材料颜色点 = { -- 点位需要尽可能多，且保证准确
    源岩 = { "C9B888", "374040", "9D8D65" },
    破损装置 = { "3E3E36", "B86B6B", "752020", "812727" },
    酯原料 = { "7CA639", "F7FF83", "417A30" },
    代糖 = { "A0876E", "AAB5BA" },
    异铁碎片 = { "4F6073", "96C8E3", "1E2626" },
    双酮 = { "F5DA45", "AC8A57" },

    异铁 = { "5385BE", "545C5C", "6188A1" },
    糖 = { "91C31E", "8F765D" },
    聚酸酯 = { "B7D92F", "B4C4BC", "6A9B18" },
    酮凝集 = { "A46A11", "779898", "FFEC16" },
    固源岩 = { "7A7251", "202830", "D7C7A6" },
    装置 = { "414949", "912B2B", "B23636" },

    环烃聚质 = { "454555", "74749D", "0E0E15", "ACACB3" },
    转质盐组 = { "E9E9E9", "787878", "6993B4", "324354" },
    化合切削液 = { "45688B", "45B8FA", "1727F5" },
    褐素纤维 = { "CDAB4E", "938271", "0B0804" },
    半自然溶剂 = { "E877A0", "FDF5ED", "FECCC8" },
    炽合金 = { "D6C9BC", "647495", "203051", "A48B7B" },
    晶体元件 = { "2F906F", "56674E", "16A179" },
    凝胶 = { "A1FDFD", "005A8B", "12C7FF" },
    扭转醇 = { "C2631C", "CD3604", "FEDB15", "F5BB68" },
    轻锰矿 = { "2F284A", "A29AB6", "3B3257", "2110A5" },
    研磨石 = { "CB9797", "CB999B", "35364F" },
    ["RMA70-12"] = { "FFFED5", "AFAF8E", "503727", "9D7453" },
    固源岩组 = { "424242", "D9C18F", "B79F65" },
    全新装置 = { "CB3636", "BB2F2F", "641A1A" },
    聚酸酯组 = { "96C72A", "EAF287", "A5CE39" },
    糖组 = { "927958", "1CAECF", "684F2E" },
    异铁组 = { "6BA9D2", "517BA4", "2A3A42", "C1CAB9" },
    酮凝集组 = { "DCCC38", "324B5C", "553C1B" },
    芯片助剂 = { "529AAD", "7EB6CE", "6E9787" },

    烧结核凝晶 = { "292931", "CAB9E8", "6D5E73", "DED3F7" },
    晶体电子单元 = { "284949", "D37046", "1F1616" },
    D32钢 = { "E8F6F9", "387283", "2A637C" },
    双极纳米片 = { "450505", "EABE95", "D30906", "FFEF95" },
    聚合剂 = { "435454", "2C878F", "3DAA04" },

    转质盐聚块 = { "9D5295", "3B333E", "BEAFB6" },
    环烃预制体 = { "8989AA", "C5C5CD", "626293" },
    切削原液 = { "3E7DFC", "45454D", "438FFE" },
    固化纤维板 = { "93835A", "A8A697", "B39258", "D2CAA9", "787026" },
    精炼溶剂 = { "FF71A7", "FFFCFC" },
    晶体电路 = { "8CA988", "ECAA5F", "388B72" },
    炽合金块 = { "D0F8F8", "FBC23E", "55869F" },
    聚合凝胶 = { "0386BE", "9BFFFF", "DEFFFF" },
    白马醇 = { "727A82", "BF2222", "CC8282" },
    三水锰矿 = { "7D7D95", "0000E7" },
    五水研磨石 = { "D19E7C", "7E9494", "AC6846" },
    ["RMA70-24"] = { "D6B5B5", "DD0700", "CFB6B7" },
    提纯源岩 = { "CFB68D", "D4B381", "755C3B" },
    改量装置 = { "3E4646", "B63535", "A93131" },
    聚酸酯块 = { "BFDD50", "92BB1F", "245E35" },
    糖聚块 = { "5C4C33", "9A8261", "EFEFEF", "F0CE03" },
    异铁块 = { "4677AE", "66A8E1", "273748" },
    酮阵列 = { "D26E00", "415149", "F7DC00" },
}

材料颜色点_不存在 = { -- 极少数的可能存在误判
    源岩 = {},
    破损装置 = {},
    酯原料 = {},
    代糖 = { "8F4A00", "A07D53" },
    异铁碎片 = {},
    双酮 = {},

    异铁 = {},
    糖 = { "ADBEB5" },
    聚酸酯 = {},
    酮凝集 = {},
    固源岩 = {},
    装置 = {},

    环烃聚质 = { "4089E3", "C7AFE3", "D6A3A7", "2110A5" },
    转质盐组 = { "D9A8B0", "129675", "8C6B28", "3587EE" },
    化合切削液 = {},
    褐素纤维 = { "CE3B00" },
    半自然溶剂 = {},
    炽合金 = {},
    晶体元件 = {},
    凝胶 = {},
    扭转醇 = {},
    轻锰矿 = {},
    研磨石 = {},
    ["RMA70-12"] = { "8C6B28" },
    固源岩组 = { "BB8833", "E7D8D2" },
    全新装置 = {},
    聚酸酯组 = {},
    糖组 = { "D5C430", "C33501" },
    异铁组 = {},
    酮凝集组 = {},
    芯片助剂 = {},

    烧结核凝晶 = {},
    晶体电子单元 = { "A92111" },
    D32钢 = {},
    双极纳米片 = {},
    聚合剂 = {},

    转质盐聚块 = { "FF72A5" },
    环烃预制体 = { "398BFE", "0000AD", "B2A0D0" },
    切削原液 = {},
    固化纤维板 = { "C38F21" },
    精炼溶剂 = {},
    晶体电路 = {},
    炽合金块 = {},
    聚合凝胶 = {},
    白马醇 = { "E80202" },
    三水锰矿 = {},
    五水研磨石 = {},
    ["RMA70-24"] = {},
    提纯源岩 = {},
    改量装置 = { "EB6704", "E50707" },
    聚酸酯块 = {},
    糖聚块 = { "D26E00" },
    异铁块 = {},
    酮阵列 = {},
}

-- 在指定区域内寻找，存在所有特征点，返回材料名 根据材料等级判断用于降低错误率，查找时颜色可信度均为1
raise.find_material = function(area)
    local material = ""
    local skip = false
    local material_level = ""
    for k, v in pairs(材料等级颜色) do
        if find_color(area, v, 1, 0.98) ~= nil then
            material_level = k
            break
        end
    end
    if material_level == "" then material_level = "灰色材料" end
    -- log("material_level", material_level)
    local test_material = function(test_material_level)
        for k, v in pairs(材料等级[test_material_level]) do
            skip = false
            -- log("开始尝试" .. v)
            for _, j in pairs(材料颜色点[v]) do
                if find_color(area, j, 1, 0.98) == nil then
                    skip = true
                    break
                end
            end
            if not skip then
                if 材料颜色点_不存在[v] ~= {} then
                    for _, j in pairs(材料颜色点_不存在[v]) do
                        if find_color(area, j, 1, 0.98) ~= nil then
                            skip = true
                            break
                        end
                    end
                end
                if not skip then
                    material = v
                    break
                end
            end
        end
    end
    test_material(material_level)
    -- if material == "" then
    --     for k, v in pairs(材料等级) do
    --         if k ~= material_level then
    --             test_material(k)
    --         end
    --     end
    -- end
    -- table.removev(材料等级[material_level], material)
    -- log("material", material)
    if material == "" then
        material = raise.inventory_identify_xinpian(area)
    end
    return material
end

-- 基建材料识别
raise.material_identify = function()
    -- 从x 945/1686  y=120 开始y++ 识别 22BBFF 减去一定x值得到区域初始坐标
end

-- 加工站配方滑动,一次滑动3个
swip_formula = function(up)
    local duration
    local finger
    local delay
    if up then
        local x1 = scale(1110)
        local y1 = scale(159)
        local y2 = scale(6000 / 720 * 1080)
        duration = 400
        finger = { { point = { { x1, y1 }, { x1, y2 } }, duration = duration } }
        delay = 750
    else
        local x = scale(1200)
        local y = scale(217)
        local y2 = scale(1030)
        local x2 = scale(800)
        local x3 = scale(1110)
        local y3 = scale(1030)
        local slids = 50
        local slidd = 200
        local taps = slids + slidd + 150
        local tapd = 200
        local downd = taps + 100
        duration = downd
        finger = {
            { point = { { x, y }, { x2, y } },    start = 0,     duration = downd },
            { point = { { x, y2 }, { x3, y2 } },  start = slids, duration = slidd },
            { point = { { x3, y3 }, { x3, y3 } }, start = taps,  duration = tapd },
        }
        delay = 250
    end
    log(JsonEncode(finger))
    gesture(finger)
    sleep(duration + delay)
end

-- 材料合成
raise.material_synthesis = function(id, count)
    log("材料", material_id2name(id), "准备合成数量", count)
    if not raise.formula_choose(id) then return end
    local level = 高级材料2低级材料[id]["level"] or 3
    local emotion_cost = 24 / (2 ^ (level - 1))
    local times = count // emotion_cost
    log("最多次数", times)
    -- todo 根据返回的技能图标调整心情消耗
    for j = 1, times do
        emotion_cost = 24 / (2 ^ (level - 1))

        if not path.加工站选人("加工站", id, level) then
            log("选人失败")
            return
        end
        if not appear("加工站", 2) then return end
        tap("加工站最多")
        ssleep(.3)
        tap("开始加工")
        if not appearTap("获得物资", 10) then
            log("合成材料失败")
            return
        end
        appear("加工站", 3)
        ssleep(.3)
    end
    ssleep(2)
    -- 默认是1,所以减掉
    emotion_cost = 24 / (2 ^ (level - 1))
    local remainder = count % emotion_cost - 1
    log("剩下次数", remainder)
    if remainder >= 0 then
        if not path.加工站选人("加工站", id, level) then
            log("选人失败")
            return
        end
        if not appear("加工站", 2) then return end
        if remainder >= 1 then
            for i = 1, remainder do
                tap("加工站加")
                ssleep(.1)
            end
        end
        ssleep(.1)
        tap("开始加工")
        if appear("获得物资", 10) then
            ssleep(.2)
            tap("获得物资")
        end
        appear("加工站", 3)
        ssleep(.3)
    end
    appear("加工站", 3)
    return true
end

--选择配方
raise.formula_choose = function(id)
    local level = 高级材料2低级材料[id]["level"]
    log("选择配方", id, "等级", level)
    if not wait(function()
            tap("加工站选择配方")
            if not findOne("加工站") then return true end
        end, 5) then
        return
    end
    if not wait(function()
            if findOne("加工站选材料类") then return true end
            tap("加工站选材料类")
            --给按钮动画回弹
            ssleep(.3)
        end, 5) then
        return
    end
    if not appear("加工站选材料类", 1) then return end
    if level < 2 then
        if not wait(function()
                if findOne("材料类品质升序") then return true end
                tap("材料类品质升序")
                ssleep(.3)
            end, 3) then
            return
        end
    else
        if not wait(function()
                if findOne("材料类品质降序") then return true end
                tap("材料类品质升序")
                ssleep(.3)
            end, 3) then
            return
        end
    end
    --滑到最上面
    swip_formula(true)
    ssleep(.5)
    for i = 1, 5 do
        for j = 1, 6 do
            if material_id2name(id) == ocro("配方名称列表" .. j) then
                log(material_id2name(id), ocro("配方名称列表" .. j))
                tap("配方名称列表" .. j)
                return true
            end
        end

        swip_formula()
        ssleep(.3)
    end
    tap("返回")
end

-- 选择干员
char_choose = function(char_name)
    path.跳转("干员")
    ssleep(1)
    --只跳转一次会有概率无反应,多加一次
    path.跳转("干员")
    ssleep(1)
    if not findOne("干员界面") then return end
    if not findOne("职业选择") then
        tap("职业选择")
        appear("职业选择", 2)
    end
    if not findOne("干员等级降序") then
        tap("干员等级降序")
        appear("干员等级降序", 2)
    end


    for i = 1, 8 do
        if 干员职业[char_name] == 干员类别[i] then
            if not findOne("普通作战编队列表" .. i) then
                tap("普通作战编队列表" .. i)
                appear("普通作战编队列表" .. i)
                ssleep(.3)
            end
        end
    end

    local last_char
    local char_found = false
    while not char_found do
        ssleep(.1)
        local ret = 干员名ocr校正(ocrex("干员上"))
        log(ret)
        if ret == "" or #ret == 0 then return false end
        for i = 1, #ret do
            if ret[i]["text"] == char_name then
                char_found = true
                tap({ (ret[i]["l"] + ret[i]["r"]) / 2, ret[i]["t"] - scale(200) })
                appearTap("角色档案关闭", 1.5)
                appear("干员档案", 5)
                break
            end
        end
        if char_found then return true end

        ret = 干员名ocr校正(ocrex("干员下"))
        log(ret)
        if ret == "" or #ret == 0 then return false end
        for i = 1, #ret do
            if ret[i]["text"] == char_name then
                char_found = true
                tap({ (ret[i]["l"] + ret[i]["r"]) / 2, ret[i]["t"] - scale(200) })
                appearTap("角色档案关闭", 1.5)
                appear("干员档案", 5)
                break
            end
        end
        if char_found then return true end
        if ret[#ret]["text"] == last_char then break else last_char = ret[#ret]["text"] end
        swip_char()
    end
    log("未找到干员", char_name)
    path.跳转("首页")
    return false
end

-- 等级拉满一次
raise.upgrade_char = function()
    appear("干员档案", 2)
    if not wait(function()
            tap("进入升级页面")
            ssleep(.1)
            if findOne("干员升级页面max") then return true end
        end, 5) then
        log("当前阶段已满级")
        return true
    end
    if not wait(function()
            tap("干员升级页面max")
            tap("干员升级max确认")
            if findOne("干员升级提升等级") then return true end
        end, 5) then
        log("经验书或者龙门币不足")
        return false
    end

    if appear("干员升级提升等级", 3) then
        ssleep(.3)
        tap("干员升级提升等级")
        appear("干员档案", 3)
        ssleep(.3)
    else
        log("经验书或者龙门币不足")
        return false
    end
    return true
end

-- 买胶水
raise.buy_32001 = function(numb)
    path.跳转("采购中心")
    if not wait(function()
            if findOne("凭证交易所进入确认") then return true end
            tap("凭证交易所进入")
        end, 5) then
        return
    end
    disappear("正在提交反馈至神经", network_timeout)
    appear("绿票商店选中", 3)

    -- DCBB0C
    if not wait(function()
            if findOne("红票商店选中") then
                return true
            end
            tap("红票商店选中")
            ssleep(.3)
        end, 10) then
        return
    end
    disappear("正在提交反馈至神经", network_timeout)
    if not appear("红票商店面板", 1) then return end
    ssleep(.5)
    local p
    for i = 0, 3 do
        p = findOne("红票商店胶水")
        log("胶水位置", p)
        if p then
            break
        end
        path.swip_ticket_shop()
        ssleep(1.5)
    end
    if not p then return end

    if not wait(function()
            tap(p)
            if findOne("购买物品面板") then
                return true
            end
        end, 5) then
    end
    if findOne("凭证交易所进入") then
        log("未能进入商品，大概是售空了吧~")
        return
    end
    -- 点击购买
    if not wait(function()
            if findOne("购买物品面板", 3) then
                for i = 1, numb - 1 do
                    tap("交易所商品加")
                    ssleep(0.5)
                end
                tap("采购商店支付")
                -- tap("商店顶栏")
            end
            ssleep(1)
            if findOne("凭证交易所进入") then return true end
            if not findOne("购买物品面板") then return true end
        end, 3) then
    end
    if findOne("购买物品面板", 3) then
        log("胶水购买失败，大抵是没钱了吧~")
        return true
    end
    disappear("正在提交反馈至神经", network_timeout)
    appearTap("获得物资", 3)
    appear("红票商店面板", 5)
    tap("返回")
end


-- 精英化操作一次
raise.elite_one_phase = function(material_need)
    --计算后需要的材料
    --local material_need = {}
    --if materials_need then material_need = raise.calculate_materials_need(materials_need) end
    appear("干员档案", 2)

    if not wait(function()
            tap("进入精英化页面")
            if findOne("干员精英化页面") then return true end
        end, 5) then
        log("当前精英等级已满")
        return true
    end
    if findOne("干员精英化缺少材料") then
        if findOne("干员精英化芯片红") then
            tap("干员精英化芯片")
            ssleep(.3)
            log("缺少芯片,尝试合成")
            appear("干员精英化芯片白", 2)

            for k, v in pairs(material_need) do
                if #k == 4 and k:sub(4, 4) == "3" then
                    -- 识别已经拥有的芯片数量
                    local n = tonumber(ocro("干员精英化芯片数字") or 0)
                    v = v - n
                    if not wait(function()
                            tap("干员精英化芯片白")
                            if findOne("制造站设施列表1") then return true end
                        end, 5) then
                        return
                    end
                    appear("制造站设施列表1", 3)
                    if not wait(function()
                            tap("芯片站")
                            if not findOne("制造站设施列表1") then return true end
                        end, 5) then
                        return
                    end
                    if not wait(function()
                            tap("制造站选芯片类")
                            if findOne("制造站选芯片类") then return true end
                        end, 5) then
                        return
                    end

                    tap("芯片制造" .. k)
                    appear("芯片站", 3)
                    --使用森空岛接口数据
                    --local numb_32001 = player_inventory_info["32001"] or 0
                    --[[先点击v下加号看看
                    for i = 1, v - 1 do
                        tap("制造站加")
                        ssleep(.2)
                    end]]
                    local numb_32001 = tonumber(ocro("胶水数量识别范围") or 0)
                    local numb_32001_2 = tonumber(ocro("胶水库存识别范围") or 0)
                    if numb_32001 + numb_32001_2 < v then
                        raise.buy_32001(v - numb_32001 - numb_32001_2)
                    end
                    if findOne("制造站选芯片类") then
                        tap("芯片制造" .. k)
                        appear("芯片站", 3)
                    end
                    if not appear("制造站设施列表1", 2) then
                        return
                    end
                    for i = 1, v - 1 do
                        tap("制造站加")
                        ssleep(.2)
                    end
                    if not wait(function()
                            tap("制造站执行更改")
                            if not findOne("制造站设施列表1") then return true end
                        end, 5) then
                        return
                    end
                    if not wait(function(reset_wait_start_time)
                            tap("右确认")
                            if appear("制造站设施列表1", 1) then return true end
                            if findOne("正在提交反馈至神经") then
                                reset_wait_start_time()
                            end
                        end, 5) then
                        return
                    end
                    ssleep(.8)
                    appear("制造站设施列表1", 2)
                    ssleep(6) --最多一次造4个，等待要超过4s
                    tap("制造站收取")
                    break
                end
            end
            if not wait(function()
                    if findOne("干员精英化页面") then return true end
                    tap("返回")
                    ssleep(.3)
                    if findOne("干员精英化芯片白") then
                        tap("干员精英化芯片")
                        ssleep(.3)
                    end
                end, 5) then
                return
            end
        end
        local p1 = findOne("干员精英化材料1红")
        local p2 = findOne("干员精英化材料2红")

        if p1 then
            raise.jump_to_workshop("精英化", 1)
        end
        if p2 then
            raise.jump_to_workshop("精英化", 2)
        end
        if appear("干员精英化缺少材料", 1) then return false end
    end
    if not wait(function()
            tap("干员精英化页面")
            ssleep(.2)
            if findOne("干员档案") then return true end
        end, 10) then
        log("未完成精英化")
        return false
    end
    -- todo 仓库减除消耗的材料
    return true
end

---干员精英化
---@param id string 干员id
---@param start_phase number 当前精英等级
---@param target_phase number 目标精英等级
---@return bool bool true 为精英化完成,继续后续培养计划,false 为未完成(缺少材料,需要等待芯片合成)
raise.elite_char = function(id, start_phase, target_phase)
    local name = char_id2name(id)
    log(name)
    --[[if not char_choose(name) then
        log("未找到干员", name, ",跳过")
        path.跳转("首页")
        return ture
    end]]
    for i = 1, target_phase - start_phase do
        if not raise.upgrade_char() then return end
        --计算材料是否够
        local material_need = raise.get_char_elite_material(id, start_phase + i)
        log("需要材料", material_need)
        if not raise.elite_one_phase(material_need) then return end
    end
    log("精英化", target_phase, name, "已完成")
    path.跳转("干员")
    return true
end

-- 技能升级
raise.upgrade_skill = function(id, target_level, level)
    --暂时写成默认到7级
    local name = char_id2name(id)
    local start_level = level[1]
    log(level, start_level)
    --[[if not char_choose(name) then
        log("未找到干员", name, ",跳过")
        path.跳转("首页")
        return ture
    end]]
    if not wait(function()
            tap("进入技能升级页面")
            if not findOne("干员档案") then return true end
            if findOne("干员技能升级页面") then return true end
        end, 5) then
        log("无法升级技能")
        return true
    end
    if not wait(function()
            if findOne("干员技能升级页面") then return true end
            if findOne("干员技能专精完成") then tap("干员技能专精完成") end
            if findOne("干员技能专精页面") then return false end
        end, 10) then
        log("无法升级技能")
        return true
    end
    --todo计算材料
    if not wait(function()
            if findOne("干员技能升级页面") then tap("干员技能升级页面") end
            if findOne("干员技能升级红") then return false end
            if findOne("干员档案") then return true end
        end, 10) then
        log("无法升满技能")
        return false
    end
    log("升级技能", target_phase, name, "到7级已完成")
    path.跳转("干员")
    return true
end

-- 技能专精
raise.master_skill = function(id, skill_numb, start_level, level)
    local name = char_id2name(id)
    --local level = raise.get_char_skill(id, skill_numb)
    if level[1] < 7 then return false end
    --[[if not char_choose(name) then
        log("未找到干员", name, ",跳过")
        path.跳转("首页")
        return ture
    end]]
    if not wait(function()
            tap("进入技能升级页面")
            if not findOne("干员档案") then return true end
            if findOne("干员技能升级页面") then return false end
        end, 5) then
        log("无法升级技能")
        return true
    end
    if not wait(function()
            if findOne("干员技能升级页面") then return false end
            if findOne("干员技能专精完成") then tap("干员技能专精完成") end
            if findOne("干员技能专精页面") then return true end
        end, 10) then
        log("无法升级技能")
        return false
    end
    --[[
    --计算start_level+1的材料需求
    local material_need = raise.char_skill_master_material(id, skill_numb, start_level + 1)
    log("需要材料", material_need)
    --local materials_need = raise.calculate_materials_need(material_need)
    --log("缺少材料", materials_need)

    local m_need = {}
    local fight_plan, synthesis_plan
    if material_need ~= {} then
        for k, v in pairs(material_need) do
            if #k == 5 then --去除技能书
                m_need[k] = v
            end
        end
        log("缺少非技能书材料:", m_need)
        fight_plan, synthesis_plan = raise.get_fight_plan(m_need)
        log("合成计划:", synthesis_plan)
    end
    ]]
    --用prts自动编队逻辑选择要的干员和技能
    if not raise.choose_char_be_trained({
            {
                name = char_id2name(id),
                skill = skill_numb,
            } }) then
        return
    end
    appear("干员技能专精页面", 3)
    if not wait(function()
            tap("专精技能列表" .. skill_numb)
            if not findOne("干员技能专精页面") then return true end
            if findOne("干员技能升级页面") then return false end
        end, 5) then
        log("无法升级技能")
        return true
    end
    appear("专精技能确认", 5)
    -- 森空岛接口有延迟,这里用判断有没有红点来决定要不要合材料
    if findOne("干员技能专精红") then
        local p1 = findOne("干员专精材料1红")
        local p2 = findOne("干员专精材料2红")
        if p1 then
            raise.jump_to_workshop("专精", 1)
        end
        if p2 then
            raise.jump_to_workshop("专精", 2)
        end
    end
    if appear("干员技能专精红", 1) then return false end
    if not wait(function()
            tap("专精技能确认")
            ssleep(.2)
            if findOne("干员技能专精页面") then return true end
        end, 10) then
        log("未完成专精")
        return false
    end
    path.训练室换班("训练室", 干员职业[char_id2name(id)], start_level + 1)
    mastering = true
    return true
end

-- 选择要技能专精的干员,参考prts自动编队函数
raise.choose_char_be_trained = function(干员)
    local 编入数量 = 0
    local 未编入 = {}
    local 未编入干员 = {}
    local 未编入数量 = 0

    appear("干员技能专精页面", 3)
    if not wait(function()
            if findOne("编队确认") then return true end
            tap("选择被训练干员")
            sleep(10)
        end, 5) then
        --多次点击仍然进不去,说明正在专精
        mastering = true
        return
    end
    if not wait(function()
            if findOne("专精无干员选中") then return true end
            tap("专精第一干员未选中")
            ssleep(.5)
        end, 5) then
        return
    end
    if not findOne("职业选择") then
        tap("职业选择")
        appear("职业选择", 2)
    end
    if not findOne("等级降序") then
        tap("等级降序")
        appear("等级降序", 2)
    end
    local choseChar = function(干员)
        local 记录未编入数量
        --8个职业
        for i = 1, 8 do
            local 干员名字字符串 = ""
            local 干员目录 = {}
            if 干员职业[干员[1]["name"]] == 干员类别[i] then
                干员名字字符串 = 干员名字字符串 .. 干员[1]["name"]
                table.insert(干员目录, 干员[1]["name"] .. 干员[1]["skill"])
            end
            if 干员名字字符串 ~= "" then
                if not findOne("普通作战编队列表" .. i) then
                    tap("普通作战编队列表" .. i)
                    appear("普通作战编队列表" .. i)
                    sleep(200)
                end
                --print(干员目录)
                未编入 = 选择干员(干员目录, "待编队干员")
                未编入数量 = 未编入数量 + 未编入[1]
                if 未编入数量 == 1 and 未编入干员[1] == nil then
                    print(i, 未编入[2])
                    未编入干员 = { i, 未编入[2] }
                end
            end
            --print("编入数量", 编入数量)
        end
    end
    choseChar(干员)

    tap("编队确认")
    releaseCapture()
    appear("干员技能专精页面", 3)
    print(未编入干员)
    if 未编入数量 >= 1 then
        log("未能识别到待训练干员")
        return false
    end
    return true
end


-- 仓库识别 测试
raise.test = function()
    ssleep(1)
    -- local area = { 469, 722, 710, 969 }
    -- local material = raise.find_material(area)
    -- log(material)

    log("start")
    local ms = {}
    local sx, sy = 49, 173
    for x = 0, 7 do
        for y = 0, 2 do
            area = { sx + x * scale(230), sy + y * scale(280), sx + x * scale(230) + scale(200), sy + y * scale(280) +
            scale(200) }
            local material = raise.find_material(area)
            -- log(x, y, material)
            table.insert(ms, { x, y, material })
        end
    end
    log("end")
    log(ms)
    ssleep(300)
end

-- 基建合成识别
raise.test2 = function()
    ssleep(1)
    local ms = {}
    local sx, sy = 251, 87
    log("start")
    for x = 0, 1 do
        for y = 0, 2 do
            area = { sx + x * scale(740), sy + y * scale(270), sx + x * scale(740) + scale(250), sy + y * scale(270) +
            scale(250) }
            local material = raise.find_material(area)
            -- log(x, y, material)
            table.insert(ms, { x, y, material })
        end
    end
    log("end")
    log(ms)
    ssleep(300)
end

芯片识别数据 = {
    先锋芯片组 = {
        蓝色 = 1.39,
        比例 = 2.34,
    },
    近卫芯片组 = {
        蓝色 = 1.40,
        比例 = 2.35,
    },

    重装芯片组 = {
        蓝色 = 1.28,
        比例 = 2.15,
    },

    狙击芯片组 = {
        蓝色 = 1.40,
        比例 = 2.36,
    },

    术师芯片组 = {
        蓝色 = 1.44,
        比例 = 2.433,
    },

    医疗芯片组 = {
        蓝色 = 1.31,
        比例 = 2.182,
    },

    辅助芯片组 = {
        蓝色 = 1.24,
        比例 = 2.070,
    },

    特种芯片组 = {
        蓝色 = 1.42,
        比例 = 2.366,
    },
    先锋芯片 = {
        蓝色 = 0.39,
        比例 = 0.476,
    },
    近卫芯片 = {
        蓝色 = 0.40,
        比例 = 0.441,
    },
    重装芯片 = {
        蓝色 = 0.29,
        比例 = 0.357,
    },
    狙击芯片 = {
        蓝色 = 0.40,
        比例 = 0.486,
    },
    术师芯片 = {
        蓝色 = 0.43,
        比例 = 0.492,
    },
    医疗芯片 = {
        蓝色 = 0.32,
        比例 = 0.392,
    },
    辅助芯片 = {
        蓝色 = 0.28,
        比例 = 0.344,
    },
    特种芯片 = {
        蓝色 = 0.33,
        比例 = 0.461,
    },
}

raise.test3 = function()
    -- local pixel = getPixelColor(279, 792)
    -- print(pixel)
    -- local r, g, b = colorToRGB(pixel)
    -- print(r, g, b)

    -- local iswhite, isdis = false, false

    local area = {}
    local sx, sy = scale(210), scale(182)
    local ms = {}

    log(sx, sy)

    -- 计算两点之间的欧几里得距离
    function distance(point1, point2)
        local dx = point1[1] - point2[1]
        local dy = point1[2] - point2[2]
        return math.sqrt(dx * dx + dy * dy)
    end

    -- 计算给定数据点列表到参考点的距离，并返回距离列表
    function distances_to_reference(data, reference_point)
        local distances = {}
        for _, point in ipairs(data) do
            local dist = distance(point, reference_point)
            table.insert(distances, dist)
        end
        return distances
    end

    -- 计算距离列表的均值
    function mean_distance(distances)
        local sum = 0
        for _, dist in ipairs(distances) do
            sum = sum + dist
        end
        return sum / #distances
    end

    function getcent(area)
        local 绿色, 蓝色 = 0, 0, 0, 0
        local pixel, r, g, b = "", 0, 0, 0
        local cx, cy = nil, nil
        local 蓝色区域差值 = 0
        local 白色平均距离 = 0
        local coordinates = {}
        local 中心坐标x, 中心坐标y = (area[3] + area[1]) / 2, (area[4] + area[2]) / 2
        local 总长 = area[3] - area[1]
        local 总高 = area[4] - area[2]
        local 白色坐标 = {}
        local mx, my = 0, 0
        log(总长, 总高)
        for y = area[2], area[4], 1 do
            iswhite, isdis = false, false
            for x = area[1], area[3], 1 do
                pixel = getPixelColor(x, y)
                b, g, r = colorToRGB(pixel)
                --[[
            绿色，用于确定是否为小芯片
            28-103,35-120,20-73

            蓝色 用于确认芯片背景
            2-70,70-138,95-150

            蓝色之间的其他颜色为白色
            ]]
                --
                -- log(r, g, b)
                if r > 28 and r < 103 and g > 35 and g < 120 and b > 20 and b < 73 then
                    绿色 = 绿色 + 1
                elseif r > 2 and r < 70 and g > 70 and g < 138 and b > 95 and b < 150 then
                    蓝色 = 蓝色 + 1
                    mx = x
                    my = y
                    if not cx then
                        cx = x
                        cy = y
                    end
                    蓝色区域差值 = 蓝色区域差值 + x - cx + y - cy
                    -- table.insert(coordinates, { x, y })
                elseif cx and x - cx > 0 and y - cy > 0 and x - cx < 总长 * 0.6 and y - cy < 总高 * 0.6 then
                    -- log("白色")
                    -- log(x - cx > 0, y - cy > 0)
                    -- log(x - cx < 总长 * 0.5, y - cy < 总高 * 0.5)
                    -- 白色平均距离 = 白色平均距离 + scale(x - cx) + scale(y - cy)
                    table.insert(白色坐标, { x, y })
                    -- 白色
                end
            end
        end

        local ix, iy = (mx + cx) / 2, (my + cy) / 2
        log("白色坐标", { ix, iy }, #白色坐标)
        -- 计算距离列表
        local distances = distances_to_reference(白色坐标, { ix, iy })

        -- 计算平均距离
        local mean_dist = mean_distance(distances)

        return 绿色, 蓝色, 蓝色区域差值, 白色平均距离, mean_dist
    end

    -- area = { 1506, 449, 1752, 695 }
    -- local 绿色, 蓝色 = getcent(area)
    -- local 比例 = 蓝色 / (scale(200) * scale(200))
    -- table.insert(ms, { x, y, 蓝色, 比例 })
    log("start")
    local 区域集中度 = 0
    local xxx = screen.height / 720
    xxx = xxx ^ 3 + 0.4
    for x = 0, 5 do
        for y = 0, 2 do
            area = { sx + x * scale(236), sy + y * scale(280), sx + x * scale(236) + scale(210), sy + y * scale(280) +
            scale(210) }
            log(area)
            -- area = { 144, 304, 280, 451 }
            area = { 128, 506, 289, 638 }
            local 绿色, 蓝色, 蓝色区域差值, 白色平均距离, mean_dist = getcent(area)
            local 比例 = 蓝色 / (scale(100) * scale(100))
            local 绿色比例 = 绿色 / (scale(100) * scale(100))
            --log(绿色, 蓝色, 比例, 离散距离)
            -- table.insert(ms, { x, y, 蓝色, 比例, 蓝色差 / 蓝色 })
            if 蓝色 > 0 then
                -- 区域集中度 = 蓝色区域差值 / (scale(2000) * scale(100))
                -- 区域集中度 = 区域集中度 * (1 / (1080 / screen.height) * (1080 / screen.height))
                区域集中度 = 蓝色区域差值 / xxx
                区域集中度 = 区域集中度 / 200000
                table.insert(ms, { x, y, 绿色, 蓝色, 比例, 区域集中度, 蓝色区域差值, 白色平均距离, mean_dist })
            end
            break
        end
        log("end")
    end
    -- local 比例 = 白色 / (绿色 + 蓝色 + 白色)
    -- log(绿色, 蓝色, 白色, 比例)
    log(ms)
    ssleep(2000)
end

-- 仓库识别，芯片部分 返回芯片id:数量 在
raise.inventory_identify_xinpian = function(area)
    if type(area) ~= "table" or #area ~= 4 then
        log("area参数错误")
        return
    end

    local 中心坐标x, 中心坐标y = (area[3] + area[1]) / 2, (area[4] + area[2]) / 2
    local 总长 = area[3] - area[1]
    local 总宽 = area[4] - area[2]

    function getcent(area)
        local 绿色, 蓝色 = 0, 0, 0, 0
        local pixel, r, g, b = "", 0, 0, 0
        local 蓝色区域差值 = 0
        local 白色平均距离 = 0
        local coordinates = {}
        for y = area[2], area[4], 1 do
            for x = area[1], area[3], 1 do
                pixel = getPixelColor(x, y)
                b, g, r = colorToRGB(pixel)
                if r > 28 and r < 103 and g > 35 and g < 120 and b > 20 and b < 73 then
                    绿色 = 绿色 + 1
                elseif r > 2 and r < 70 and g > 70 and g < 138 and b > 95 and b < 150 then
                    蓝色 = 蓝色 + 1
                    if not cx then
                        cx = x
                        cy = y
                    else
                        蓝色区域差值 = 蓝色区域差值 + scale(x - cx) + scale(y - cy)
                    end
                elseif math.abs(中心坐标x - x) < 总长 * 0.25 and math.abs(中心坐标y - y) < 总宽 * 0.25 then
                    -- 白色
                    白色平均距离 = 白色平均距离 + scale(x - 中心坐标x) + scale(y - 中心坐标y)
                end
            end
        end
        return 绿色, 蓝色, 蓝色区域差值, 白色平均距离
    end

    log(area)
    local 区域集中度 = 0
    local 绿色, 蓝色, 蓝色区域差值 = getcent(area)
    local ret_xp = ""
    if 蓝色 > 0 then
        local 比例 = 蓝色 / (scale(100) * scale(100))
        local 绿色比例 = 绿色 / (scale(100) * scale(100))
        local xxx = screen.height / 720
        xxx = xxx ^ 3 + 0.4
        区域集中度 = 蓝色区域差值 / xxx
        区域集中度 = 区域集中度 / 200000
        log(绿色, 蓝色, 比例, 区域集中度, 蓝色区域差值)
        local cmin = 10
        for k, v in pairs(芯片识别数据) do
            log("测试开始", k, v)
            蓝色差值 = math.abs(v["蓝色"] - 比例)
            区域集中度差值 = math.abs(v["比例"] - 区域集中度)
            log(蓝色差值, 区域集中度差值)
            总差值 = 蓝色差值 + 区域集中度差值
            if 总差值 < cmin then
                cmin = 总差值
                ret_xp = k
            end
        end
    end
    if ret_xp ~= "" then
        return ret_xp
    end
    log(ms)
end

-- 仓库滑动
swip_inventory = function(left)
    local duration
    local finger
    local delay
    if left then
        local x1 = scale(600)
        local x2 = scale(10000 / 720 * 1080)
        local y1 = scale(533)
        duration = 400
        finger = { { point = { { x1, y1 }, { x2, y1 } }, duration = duration } }
        delay = 750
    else
        local x = scale(94)
        local y = scale(400)
        local y2 = scale(700)
        local x2 = scale(1720)
        local y3 = scale(700)
        local slids = 50
        local slidd = 200
        local taps = slids + slidd + 150
        local tapd = 200
        local downd = taps + 100
        duration = downd
        finger = {
            { point = { { x, y }, { x, y2 } },   start = 0,     duration = downd },
            { point = { { x2, y }, { x2, y3 } }, start = slids, duration = slidd },
            { point = { { x2, y }, { x2, y } },  start = taps,  duration = tapd },
        }
        delay = 250
    end
    log(JsonEncode(finger))
    gesture(finger)
    sleep(duration + delay)
end

-- 干员界面滑动
swip_char = function(left)
    local duration
    local finger
    local delay
    if left then
        local x1 = scale(600)
        local x2 = scale(10000 / 720 * 1080)
        local y1 = scale(533)
        duration = 400
        finger = { { point = { { x1, y1 }, { x2, y1 } }, duration = duration } }
        delay = 750
    else
        local x = scale(94)
        local y = scale(400)
        local y2 = scale(700)
        local x2 = scale(1720) --滑动6个干员距离
        local x3 = scale(1720)
        local y3 = scale(591)
        local slids = 50
        local slidd = 200
        local taps = slids + slidd + 150
        local tapd = 200
        local downd = taps + 100
        duration = downd
        finger = {
            { point = { { x, y }, { x, y2 } },    start = 0,     duration = downd },
            { point = { { x2, y }, { x2, y3 } },  start = slids, duration = slidd },
            { point = { { x3, y3 }, { x3, y3 } }, start = taps,  duration = tapd },
        }
        delay = 250
    end
    log(JsonEncode(finger))
    gesture(finger)
    sleep(duration + delay)
end

-- 仓库识别 给定材料列表 只ocr给定的材料数量
raise.inventory_identify = function(materials)
    local sx, sy = scale(85), scale(185)
    local ms = {}
    local ret = {}
    --if materials == nil or #materials == 0 then return end
    --log(materials)
    -- swip_inventory(true)
    path.跳转("首页")
    ssleep(.1)
    tap("面板仓库")
    if not wait(function()
            tap("仓库养成材料")
            ssleep(.1)
            if findOne("仓库养成材料") then return true end
        end, 5) then
        log("未进入养成材料页面")
        return {}
    end
    local page = 0
    -- swip_inventory(true)
    while true do
        if page >= 5 then break end

        if findOne("商店最后一页") then
            page = 5
            log("已经是最后一页")
            sx = scale(210)
        end

        keepCapture()
        for x = 0, 7 do
            for y = 0, 2 do
                area = { sx + x * scale(230), sy + y * scale(280), sx + x * scale(230) + scale(200), sy + y * scale(280) +
                scale(200) }
                local material = raise.find_material(area)
                log(x, y, material)
                table.insert(ms, { x, y, material })
                if type(material) == "string" and material ~= "" then
                    -- log(material)
                    --if table.includes(materials, material) then
                    if ret[material] == nil then
                        area[2] = area[2] + scale(150)
                        local num = ocrex(area)
                        if #num == 0 then
                            num = 0
                        else
                            num = num[1]["text"]
                        end
                        ret[material] = num
                        -- table.insert(ms, { x, y, material, num })
                    end
                    --end
                end
            end
        end
        releaseCapture()

        swip_inventory()
        ssleep(0.1)
        page = page + 1
    end
    --log("结束仓库识别")
    log(#ret, ret)
    --log(ms)

    --明日方舟工具箱格式：id：数量
    local t = {}
    for k, v in pairs(ret) do
        log(k, v)
        if v == "H" then v = 11 end
        t[material_name2id(k)] = tonumber(v)
    end
    path.跳转("首页")
    return t
end

-- 图色识别精英化等级
raise.recognize_elite_level = function(id)
    for i = 1, 3 do
        if findOne("干员档案精英化等级列表" .. i) then
            return i - 1
        end
    end
end
-- 图色识别技能等级
raise.recognize_char_skill = function(id, skill_numb)
    local common_level = 1
    if findOne("干员档案通用技能等级七", .85) then
        common_level = 7
    end
    local master_level = 0
    for i = 3, 1, -1 do
        if findOne("干员档案" .. skill_numb .. "技能专精列表" .. i) then
            master_level = i
            break
        end
    end
    return { common_level, master_level }
end

-- 跳转到加工站并合成
---@param actionType string 精英化/专精/模组
---@param sequence number 第几个材料
raise.jump_to_workshop = function(actionType, sequence)
    tap("干员" .. actionType .. "材料" .. sequence)
    ssleep(.3)
    appear("干员" .. actionType .. "材料白" .. sequence, 2)
    log("缺少材料，尝试合成")
    if not wait(function()
            if findOne("加工站") then return true end
            tap("干员" .. actionType .. "材料白" .. sequence .. "跳转")
        end, 5) then
        return
    end
    appear("加工站", 3)
    raise.材料合成()
    appear("加工站", 2)
    ssleep(.2)
    tap("返回")
    if appear("干员" .. actionType .. "材料白" .. sequence, 3) then
        tap("干员" .. actionType .. "材料" .. sequence)
        disappear("干员" .. actionType .. "材料白" .. sequence, 1)
        ssleep(.8)
        return true
    else
        ssleep(.8)
        return false
    end
end

-- 5.5周年后图色材料合成，支持递归合成，从加工站页面开始
raise.材料合成 = function()
    if not findOne("加工站") then
        log("未进入加工站")
        return
    end
    local 获取材料数量 = function()
        local 待合成数量 = ocro("加工数量识别范围")
        local t_number = string.match(待合成数量, "%d+")
        if t_number then
            log("合成数量", t_number)
            return tonumber(t_number)
        end
    end

    local 是否为低级材料 = false
    local 待合成数量 = 获取材料数量()
    if 待合成数量 == nil then return end
    if findOne("加工站返回上级材料") then
        是否为低级材料 = true
    end

    for i = 1, 3 do
        if findOne("加工站可加工列表" .. i) then
            合成材料采样 = sample("加工站中央物品")
            tap("加工站可加工列表" .. i)
            last_click_time = os.time()
            wait(function() -- 需要等待跳转
                if not findOne(合成材料采样) then return true end
                if os.time() - last_click_time > 3 then
                    tap("加工站可加工列表" .. i)
                    last_click_time = os.time()
                end
            end, 10)

            ssleep(1)
            raise.材料合成() -- 3个加工都得单独合成一遍
        end
    end

    if not appear("加工站", 2) then return end
    for i = 2, 待合成数量 do
        tap("加工站加")
        ssleep(.1)
    end
    ssleep(.1)
    if findOne("加工站干员心情不足") or findOne("加工站无人") then
        local id = material_name2id(ocro("加工材料识别范围"))
        local level = 高级材料2低级材料[id]["level"] or 3
        if not path.加工站选人("加工站", id, level) then
            log("选人失败")
            -- 选人失败也无所谓
        end
        for i = 2, 待合成数量 do
            tap("加工站加")
            ssleep(.1)
            if findOne("加工站干员心情不足") then
                tap("加工站减")
                break
            end
        end
    end
    if not appear("加工站", 2) then return end
    tap("开始加工")
    --[[if appear("加工站材料顶部获得物资", 15) then
        ssleep(0.5)
        tap("加工站材料顶部获得物资")
        disappear("加工站材料顶部获得物资", 5)
    end]]

    if appear("获得物资", 10) then
        ssleep(.2)
        tap("获得物资")
    end
    appear("加工站", 3)
    ssleep(.3)
    appear("加工站", 3)
    if not findOne("加工站材料已满足") then
        log("不满足")
        raise.材料合成()
    else
        if 是否为低级材料 then
            ssleep(2) -- 点太快会不跳转，左上角可能也需要进行采样判断
            appear("加工站返回上级材料", 5)
            tap("加工站返回上级材料")
            ssleep(0.5)
            return -- 低级材料合成完即可退出
        end
        log("fine")
        return true
    end
end

模组作业 = {
    夜烟 = 20990,
    远山 = 20996,
    杰西卡 = 41855,
    流星 = 20925,
    白雪 = 20850,
    讯使 = 20980,
    清道夫 = 20941,
    红豆 = 20888,
    杜宾 = 20866,
    缠丸 = 20857,
    霜叶 = 37695,
    艾丝黛尔 = 39023,
    砾 = 20919,
    暗索 = 20848,
    末药 = 20930,
    嘉维尔 = 20897,
    调香师 = 20865,
    角峰 = 20900,
    蛇屠箱 = 20948,
    古米 = 20876,
    深海色 = 20951,
    地灵 = 20864,
    白面鸮 = 20849,
    凛冬 = 20920,
    德克萨斯 = 20863,
    芙兰卡 = 20871,
    因陀罗 = 39024,
    拉普兰德 = 36644,
    幽灵鲨 = 30500,
    蓝毒 = 20916,
    白金 = 20847,
    陨星 = 20997,
    阿米娅 = 27376,
    天火 = 20962,
    梅尔 = 29012,
    赫默 = 20882,
    华法琳 = 20892,
    临光 = 22339,
    红 = 20889,
    雷蛇 = 34718,
    可颂 = 20910,
    火神 = 39025,
    普罗旺斯 = 20938,
    守林人 = 20954,
    崖心 = 32845,
    初雪 = 30503,
    真理 = 21001,
    空 = 42295,
    狮蝎 = 20953,
    食铁兽 = 30502,
    能天使 = 20932,
    推进之王 = 20965,
    推进之王 = 28900,
    伊芙利特 = 27970,
    伊芙利特 = 38298,
    艾雅法拉 = 20841,
    安洁莉娜 = 20844,
    安洁莉娜 = 20845,
    闪灵 = 28187,
    闪灵 = 28567,
    夜莺 = 20993,
    夜莺 = 39693,
    星熊 = 20976,
    星熊 = 28784,
    塞雷娅 = 20944,
    塞雷娅 = 20943,
    银灰 = 36643,
    暴行 = 39139,
    猎蜂 = 39142,
    夜魔 = 20989,
    格拉尼 = 20873,
    斯卡蒂 = 20958,
    斯卡蒂 = 20957,
    格雷伊 = 20875,
    诗怀雅 = 20952,
    陈 = 30525,
    陈 = 28072,
    苏苏洛 = 27794,
    锡兰 = 20972,
    格劳克斯 = 20874,
    黑 = 20885,
    黑 = 20886,
    桃金娘 = 24472,
    赫拉格 = 28190,
    赫拉格 = 24609,
    红云 = 20890,
    炎客 = 20984,
    送葬人 = 40157,
    麦哲伦 = 20927,
    麦哲伦 = 20926,
    伊桑 = 20991,
    微风 = 20967,
    梅 = 20929,
    拜松 = 31560,
    槐琥 = 27794,
    莫斯提马 = 39240,
    莫斯提马 = 29094,
    苇草 = 20966,
    布洛卡 = 39143,
    安比尔 = 27794,
    灰喉 = 20894,
    煌 = 25018,
    雪雉 = 20979,
    吽 = 20887,
    阿 = 28554,
    年 = 20933,
    年 = 29037,
    惊蛰 = 20904,
    刻俄柏 = 20908,
    刻俄柏 = 29659,
    清流 = 31560,
    宴 = 20986,
    柏喙 = 31560,
    慑砂 = 20949,
    风笛 = 20869,
    风笛 = 29650,
    断罪者 = 20868,
    刻刀 = 20909,
    巫恋 = 30501,
    傀影 = 20914,
    傀影 = 37484,
    极境 = 24491,
    温蒂 = 21422,
    温蒂 = 30719,
    W = 23019,
    W = 23020,
    月禾 = 39146,
    波登可 = 20856,
    苦艾 = 20913,
    莱恩哈特 = 41856,
    早露 = 21000,
    卡达 = 30679,
    亚叶 = 20981,
    断崖 = 37689,
    铃兰 = 28484,
    铃兰 = 30670,
    稀音 = 20971,
    蜜蜡 = 39147,
    贾维 = 20898,
    孑 = 29056,
    安哲拉 = 20846,
    棘刺 = 36641,
    酸糖 = 20961,
    特米米 = 20963,
    燧石 = 39148,
    森蚺 = 20946,
    森蚺 = 20945,
    芳汀 = 37694,
    薄绿 = 39149,
    四月 = 20959,
    泡泡 = 20936,
    鞭刃 = 20855,
    奥斯塔 = 40158,
    瑕光 = 29054,
    瑕光 = 20973,
    杰克 = 39150,
    絮雨 = 20975,
    泥岩 = 29633,
    迷迭香 = 29059,
    松果 = 40159,
    罗宾 = 39152,
    卡夫卡 = 20905,
    山 = 32418,
    豆苗 = 37690,
    爱丽丝 = 20842,
    空弦 = 20912,
    空弦 = 20911,
    图耶 = 20964,
    炎狱炎熔 = 20983,
    乌有 = 31560,
    嵯峨 = 28104,
    嵯峨 = 20861,
    夕 = 20970,
    夕 = 20969,
    战车 = 20999,
    闪击 = 35198,
    霜华 = 39153,
    灰烬 = 34866,
    灰烬 = 34883,
    暴雨 = 20853,
    熔泉 = 20942,
    异客 = 20992,
    异客 = 28190,
    赤冬 = 20860,
    歌蕾蒂娅 = 25760,
    歌蕾蒂娅 = 38297,
    凯尔希 = 27823,
    凯尔希 = 27823,
    浊心斯卡蒂 = 42223,
    深靛 = 39154,
    贝娜 = 20854,
    绮良 = 20937,
    卡涅利安 = 22468,
    卡涅利安 = 30673,
    帕拉斯 = 20934,
    帕拉斯 = 20935,
    羽毛笔 = 28133,
    水月 = 20956,
    水月 = 20955,
    假日威龙陈 = 39238,
    罗比菈塔 = 24556,
    桑葚 = 39694,
    琴柳 = 24636,
    灰毫 = 39157,
    远牙 = 20995,
    远牙 = 26499,
    布丁 = 20858,
    蜜莓 = 39695,
    野鬃 = 20988,
    蚀清 = 39158,
    焰尾 = 28187,
    焰尾 = 20985,
    耀骑士临光 = 20987,
    耀骑士临光 = 39159,
    耶拉 = 39140,
    极光 = 20896,
    灵知 = 29058,
    九色鹿 = 39160,
    寒芒克洛丝 = 20878,
    夜半 = 35952,
    老鲤 = 20917,
    老鲤 = 30714,
    令 = 20922,
    夏栎 = 32999,
    澄闪 = 30667,
    见行者 = 30512,
    风丸 = 20870,
    菲亚梅塔 = 29024,
    菲亚梅塔 = 20867,
    褐果 = 40160,
    海蒂 = 43089,
    洛洛 = 30674,
    号角 = 28923,
    号角 = 42287,
    掠风 = 39161,
    流明 = 20923,
    流明 = 24093,
    艾丽妮 = 40958,
    艾丽妮 = 20840,
    归溟幽灵鲨 = 20877,
    归溟幽灵鲨 = 20879,
    埃拉托 = 20839,
    濯尘芙蓉 = 30676,
    黑键 = 31560,
    黑键 = 20883,
    黑键 = 29027,
    星源 = 20977,
    承曦格雷伊 = 39162,
    多萝西 = 22467,
    至简 = 30678,
    鸿雪 = 20825,
    百炼嘉维尔 = 25769,
    但书 = 27794,
    罗小黑 = 39163,
    海沫 = 29061,
    铅踝 = 20939,
    达格达 = 39164,
    白铁 = 28133,
    白铁 = 42311,
    石英 = 41362,
    雪绒 = 20978,
    子月 = 21002,
    伺夜 = 35860,
    斥罪 = 29635,
    斥罪 = 38296,
    缄默德克萨斯 = 20899,
    和弦 = 20881,
    焰影苇草 = 30710,
    截云 = 20902,
    火哨 = 29159,
    林 = 25774,
    重岳 = 32414,
    铎铃 = 42312,
    仇白 = 36642,
    火龙S黑角 = 39166,
    麒麟R夜刀 = 29005,
    休谟斯 = 39168,
    摩根 = 39169,
    洋灰 = 39170,
    玫拉 = 39171,
    淬羽赫默 = 27939,
    霍尔海雅 = 29129,
    霍尔海雅 = 36005,
    缪尔赛思 = 35859,
    隐现 = 39172,
    空构 = 39173,
    圣约送葬人 = 25775,
    寒檀 = 40161,
    提丰 = 25367,
    凛视 = 43090,
    苍苔 = 28070,
    青枳 = 31559,
    琳琅诗怀雅 = 25773,
    琳琅诗怀雅 = 39239,
    纯烬艾雅法拉 = 39692,
    冰酿 = 39174,
    杏仁 = 39175,
    涤火杰西卡 = 34867,
    维荻 = 39176,
    戴菲恩 = 42316,
    刺玫 = 30680,
    赫德雷 = 40956,
    深律 = 39178,
    止颂 = 34205,
    止颂 = 43092,
    塑心 = 42968,
    哈洛德 = 40162,
    烈夏 = 37692,
    锏 = 30669,
    莱伊 = 38295,
    万顷 = 32417,
    小满 = 32419,
    左乐 = 32416,
    黍 = 32647,
    红隼 = 32420,
    导火索 = 35606,
    双月 = 34716,
    医生 = 39179,
    艾拉 = 34865,
    露托 = 39180,
    阿罗玛 = 39181,
    阿斯卡纶 = 36868,
    历阵锐枪芬 = 36647,
    魔王 = 42299,
    逻各斯 = 36646,
    维什戴尔 = 36645,
    深巡 = 39183,
    海霓 = 39184,
    乌尔比安 = 40957,
    渡桥 = 40164,
    衡沙 = 40165,
    森西 = 42331,
    齐尔查克 = 42333,
    莱欧斯 = 41976,
    玛露西尔 = 41110,
    凯瑟琳 = 42343,
    波卜 = 43095,
    裁度 = 43097,
    弑君者 = 39153,
    忍冬 = 43096,
    荒芜拉普兰德 = 44745,
    薇薇安娜 = 44234,
    史尔特尔 = 44232,
}

-- 自动做模组任务2
raise.auto_module = function(name)
    char_choose(name)
    ssleep(.2)
    if findOne("模组管理") then
        tap("模组管理")
    else
        return
    end
    -- 暂时只支持仅有1个模组的,有多个模组的需要读取json+ocr模组名字
    if appear("模组解锁", 2) then
        if not wait(function()
                if not findOne("模组解锁") then return true end
                tap("模组解锁")
                ssleep(.2)
            end, 5) then
            return
        end
    else
        return
    end
    if appear("模组任务2前往按钮", 2) then
        tap("模组任务2前往按钮")
        ssleep(1)
    else
        return
    end
    if appear("代理指挥开", 2) then
        tap("代理指挥开1")
        ssleep(.5)
    end
    tap("开始行动蓝")
    ssleep(.5)
    auto_prts(模组作业[name], true)
    -- 可以加入自动合成材料开模组
end

raise.auto_raise = function()
    if not raise.init() then return end
    -- player_inventory_info = raise.inventory_identify()
    log("培养计划:", raise_plan)
    if raise_plan == nil or type(raise_plan) ~= "table" or raise_plan == {} then return end
    char_do_not_have = {}
    for i = 1, #raise_plan do
        log(raise_plan[i])
        local name = raise_plan[i]["name"]
        local id
        if raise_plan[i]["id"] then
            id = raise_plan[i]["id"]
        elseif raise_plan[i]["name"] then
            id = char_name2id(raise_plan[i]["name"])
        else
            log("培养计划格式错误:未指定干员")
            return true
        end
        if not char_do_not_have[name] and ((i > 1 and findOne("干员档案") and name == raise_plan[i - 1]["name"]) or char_choose(name)) then
            local elite = raise.recognize_elite_level(id)
            if raise_plan[i]["elite"] then
                toast("精英化干员")
                local elite = raise.recognize_elite_level(id)
                log("精英化等级", elite)
                if elite >= raise_plan[i]["elite"] then
                    log(name, "已达到精英等级")
                else
                    raise.elite_char(id, elite, raise_plan[i]["elite"])
                end
            elseif raise_plan[i]["skills"] and elite >= 1 then
                toast("升级技能")
                local skill_level = raise.recognize_char_skill(id, 1)
                log(skill_level)
                if skill_level[1] >= (raise_plan[i]["skills"] or 7) then
                    log("技能已达到指定等级")
                else
                    raise.upgrade_skill(id, skill_numb, skill_level)
                end
            elseif raise_plan[i]["skill_master"] and elite >= 2 and not mastering then
                toast("专精技能")
                local skill_numb = raise_plan[i]["skill"] --几技能
                local skill_level = raise.recognize_char_skill(id, skill_numb)
                log("通用技能等级:", skill_level[1], ";" .. skill_numb .. "技能专精等级:", skill_level[2])
                if skill_level[2] >= raise_plan[i]["skill_master"] then
                    log(skill_numb, "技能已达到专精等级")
                else
                    raise.master_skill(id, skill_numb, skill_level[2], skill_level)
                end
            end
        else
            char_do_not_have[name] = true
            toast("未拥有或者未找到干员:" .. name)
        end
        --[[
        if player_character_info[id] then
            log("拥有干员", id)
            if raise_plan[i]["elite"] then
                log("精英化干员")
                local elite = raise.get_char_elite(id)
                if elite >= raise_plan[i]["elite"] then
                    log("已达到精英等级")
                else
                    return raise.elite_char(id, elite, raise_plan[i]["elite"])
                end
            elseif raise_plan[i]["skill_master"] and not mastering then
                log("专精技能")
                --几技能
                local skill_numb = raise_plan[i]["skill"]
                local skill_level = raise.get_char_skill(id, skill_numb)
                log("通用技能等级:", skill_level[1], ";" .. skill_numb .. "技能专精等级:", skill_level[2])
                if skill_level[2] >= raise_plan[i]["skill_master"] then
                    log(skill_numb, "技能已达到专精等级")
                else
                    return raise.master_skill(id, skill_numb, skill_level[2],skill_level)
                end
            elseif raise_plan[i]["skills"] then
                log("升级技能")
                local skill_level = raise.get_char_skill(id, 1)
                if skill_level[1] >= (raise_plan[i]["skills"] or 7) then
                    log("技能已达到指定等级")
                else
                    return raise.upgrade_skill(id, skill_numb, skill_level)
                end
            end
        end]]
    end
end
