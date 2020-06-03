require("util")
require("point")
require("tag")

-- set bl true
bl = {}
-- for k, v in pairs(fight_type_all) do bl[v] = true end
cl = {}
-- for k, v in pairs(fight_type_all) do cl[v] = 0 end

path = {}

path.base = {
  客户端过时 = function()
    if not update_app() then
      log("更新客户端失败")
      stop()
    end
  end,
  限时活动返回 = function()
    local t = "限时活动列表"
    for i = 1, #point[t] do
      log(t .. i)
      tap(t .. i)
    end
    tap('限时活动返回')
  end,
  面板 = true,
  start黄框 = "删除缓存返回",
  进入游戏 = "进入游戏",
  账号登录 = "账号登录",
  登录 = function()
    local u = 用户名
    local p = 密码
    if u and #u > 0 then input("账号", u) end
    if not p or #p == 0 then
      log("未设置密码")
      stop()
    end
    input("密码", p)
    tap("登录")
    -- reset state
    already_update_station_list = false
    no_friend = false
  end,
  -- 维护
  登入错误 = restart,
  我知道了 = restart,
  密码错误 = function()
    tap("密码错误")
    stop()
  end,
  网络异常稍后重试 = stop,
  -- 断网
  获取网络配置失败 = function()
    tap("获取网络配置失败")
    return true
  end,
  删除缓存返回 = "删除缓存返回",
  登录认证失效 = "登录认证失效",
  今日配给 = "今日配给",
  签到返回 = "签到返回",
  活动公告返回 = "活动公告返回",
  系统公告返回 = "系统公告返回",
  撤下干员确认 = "撤下干员确认",
  其它 = "返回",
  离开基建确认 = "离开基建确认",
  返回自己基建确认 = "返回自己基建确认",
  返回好友列表确认 = "返回好友列表确认",
  理智兑换取消 = function()
    running = "理智不足"
    tap("理智兑换取消")
    return true
  end,
  源石理智兑换次数上限 = function()
    running = "理智不足"
    tap("理智兑换取消")
    return true
  end,
  源石不足 = function()
    running = "理智不足"
    tap('返回')
    return true
  end,
  药剂恢复理智取消 = function()
    running = "理智不足"
    tap("药剂恢复理智取消")
    return true
  end,
  源石恢复理智取消 = function()
    running = "理智不足"
    tap("药剂恢复理智取消")
    return true
  end,
  新手任务 = "右返回",
  代理失误放弃行动 = "代理失误放弃行动",
  提示关闭 = 提示关闭,
  战斗记录未能同步返回 = function()
    local i = 0
    while i < 5 do
      log("战斗记录同步重试")
      tap("右确认")
      if disappear("战斗记录未能同步返回", 30, 5) then break end
    end
  end,
  -- TODO: not work
  正在释放神经递质 = function()
    disappear("正在释放神经递质", 60 * 60, 5)
  end,
  线索传递返回 = "线索传递返回",
  无人机加速确定 = "无人机加速确定",
  接管作战 = function() disappear("接管作战", 60 * 60, 5) end,
  未能同步到相关战斗记录 = close,
  排序筛选确认 = 排序筛选确认,
}

path.移动停止按钮 = function()
  if getScreenDirection() == 0 then
    background()
    sleep(5)
  end
  local t = "停止按钮"
  if not appear(t, 10, 1) then log(t .. "未找到,忽略") end
  t = find(t)
  swip(t[1], t[2], 1920 - t[1], 1080 / 2 - t[2], .2)
  return true
end
comm_enough = false
update_comm = function() comm_enough = false end
update_station_list = function()
  if already_update_station_list then return end
  local a = point.基建标识
  local b = a.base
  local l = {"宿舍", "制造站", "贸易站", "发电站"}
  local r = {"会客厅", "控制中枢", "加工站", "办公室", "训练室"}
  -- all department
  la = {}
  -- flatten
  for k, v in pairs(l) do
    v = v .. '列表'
    if point[v] == nil then
      local a = 基建左侧
      local tx = {"贸易站", "发电站", "制造站"}
      local ix = {1, 1, 1}
      for i = 1, #tx do point[tx[i] .. "列表"] = {} end
      for i = 1, math.ceil(#a / 3) do
        local b = a:sub(3 * i - 2, 3 * i)
        local j = table.find(tx, function(x) return x:startsWith(b) end)
        if j then
          local k1 = tx[j] .. "列表"
          local k2 = k1 .. ix[j]
          insert(point[k1], k2)
          point[k2] = point.基建左侧[i]
          tap_extra_delay[k2] = tap_extra_delay[k1]
          ix[j] = ix[j] + 1
        end
      end
    end
    for i = 1, #point[v] do insert(la, v .. i) end
  end
  table.extend(la, r)
  already_update_station_list = true
end
path.更新设备列表 = update_station_list
path.更新参与交流次数 = update_comm
path.每日更新 = function()
  update_station_list()
  update_comm()
  update_open_time()
end
path.限时活动 = update(path.base, {
  面板 = function()
    if not findTap('面板限时活动') then return true end
    auto(path.base)
  end,
})

path.基建点击全部 = function()
  auto(update(path.base, {面板 = '面板基建', 进驻总览 = true}))
  if not appearTap('基建灯泡蓝', 3, 1) then return end
  -- TODO 仓满、疲劳 still work?
  local i = 1
  while i <= 5 and appearTap("点击全部收取", 3, 1) do
    findTap("点击全部收取")
    sleep(2)
    i = i + 1
  end
  auto(path.base)
end
-- 换信赖最低的5人
path.基建副手换人 = function()
  update_station_list()
  local p = update(path.base, {
    面板 = '面板基建',
    进驻总览 = "控制中枢",
    进驻信息3选中 = "进驻信息3选中",
    控制中枢界面 = "控制中枢基建副手",
    基建副手简报 = true,
  })
  for k, v in pairs(point.基建副手列表) do
    auto(p)
    tap(v)
    if not find("干员选择无选中") then tap("干员选择列表1") end
    tap("排序信赖")
    tap("排序信赖")
    tap("干员选择列表1")
    tap("干员选择确认")
    sleep(1)
  end
end

path.换人 = function()
  update_station_list()
  auto(update(path.base, {面板 = '面板基建', 进驻总览 = true}))
  already_after_dormitory = false
  local p, f
  for index, v in pairs(la) do
    -- ignore the last one(训练室)
    if v == "训练室" then break end
    p = update(path.base, {
      面板 = "面板基建",
      进驻总览 = v,
      进驻信息2 = "进驻信息2",
      进驻信息3 = "进驻信息3",
      进驻信息4 = "进驻信息4",
      有人清空 = function()
        -- 人满不清
        keepScreen(true)
        if index > #point.宿舍列表 and
          table.any(point.进驻人数满列表, find) then
          keepScreen(false)
          return true
        end
        tap("有人清空")
      end,
      清空完毕进驻 = function()
        -- check 进驻人数
        keepScreen(true)
        b = table.find(point.进驻人数列表, find) or 5
        keepScreen(false)
        tap("清空完毕进驻")
        if not appear("干员选择确认", 3, 1) then return end
        -- toggle tag after 宿舍
        if index > #point.宿舍列表 and not already_after_dormitory then
          tap("排序筛选按钮")
          sleep(1)
          findTap("排序筛选未进驻未选中")
          sleep(1)
          tap("排序筛选确认")
          sleep(1)
          already_after_dormitory = true
        end
        local dorm_index = #point.宿舍列表 - index + 1
        swipq('dorm' .. dorm_index)
        a = 1
        if dorm_index > 0 and dorm_index % 2 == 0 then a = 2 end
        for i = a, a + b - 1 do tap("干员选择列表" .. i) end
        tap("干员选择确认")
        return true
      end,
    })
    auto(p)
    auto(update(path.base, {面板 = "面板基建", 进驻总览 = true}))
  end
end

path.制造站加速 = function()
  update_station_list()
  if #point.制造站列表 == 0 then return end
  auto(update(path.base, {
    进驻总览 = "制造站列表1",
    面板 = "面板基建",
    制造站进度 = "制造站进度",
    制造站设施 = "制造站加速",
    进驻信息2选中 = "进驻信息2选中",
    无人机加速制造确定 = function()
      tap("无人机加速最大")
      tap("无人机加速制造确定")
      return true
    end,
  }))
end

path.取消进驻信息选中 = update(path.base, {
  面板 = "面板基建",
  进驻总览 = 会客厅,
  进驻信息2 = true,
  进驻信息2选中 = "进驻信息2选中",
  进驻信息3 = true,
  进驻信息3选中 = "进驻信息3选中",
  进驻信息4 = true,
  进驻信息4选中 = "进驻信息4选中",
})

path.线索接收 = function()
  update_station_list()
  if not point.会客厅 then return end
  local new = false
  auto(update(path.base, {
    会客厅线索搜集中 = "会客厅线索搜集中",
    线索全部收取有 = function()
      tap("线索全部收取有")
      new = true
    end,
    线索全部收取无 = function()
      tap("解锁线索右")
      return true
    end,
    会客厅信用奖励 = "会客厅线索接收",
    进驻总览 = "会客厅",
    面板 = "面板基建",
    进驻信息3选中 = "进驻信息3选中",
  }))
  if new then auto(path.线索布置) end
end

path.线索布置 = function()
  update_station_list()
  if not point.会客厅 then return end
  auto(update(path.base, {
    进驻信息3 = "线索",
    会客厅信用奖励 = function()
      keepScreen(true)
      local v = table.findv(point.线索布置列表, find)
      keepScreen(false)
      if not v then return true end
      -- offset -50,50
      v = point[v]
      local x = v:find('|')
      local y = v:sub(x + 1, v:find('|', x + 1) - 1)
      x = tonumber(v:sub(1, x - 1))
      y = tonumber(y)
      tap({x - 50, y + 50})
      sleep(.5)
      tap("线索库列表1")
      tap("解锁线索右")
      sleep(.5)
    end,
    进驻总览 = "会客厅",
    面板 = "面板基建",
    进驻信息3选中 = "进驻信息3选中",
  }))
  if findTap("解锁线索") then
    sleep(2)
    auto(path.线索布置)
  end
end

path.线索传递 = update(path.base, {
  面板 = "面板基建",
  进驻总览 = "会客厅",
  进驻信息3 = "线索",
  会客厅信用奖励 = "会客厅线索传递",
  线索传递返回 = function()
    local a = point.线索传递数字列表
    for k, v in pairs(a) do
      tap(v)
      sleep(.5)
      if find("线索传递数字重复") or k == #a then
        tap("线索列表1")
        break
      end
    end
    a = point.传递列表
    local count = 0
    local f = function(random)
      local p = find("线索传递橙框")
      local t
      if p then
        p = p[2]
        if 100 < p and p < 300 then
          t = a[1]
          log('给1')
        elseif p < 500 then
          t = a[2]
          log('给2')
        elseif p < 700 then
          t = a[3]
          log('给3')
        else
          t = a[4]
          log('给4')
        end
      elseif random then
        for i = 1, math.random(0, count) do findTap("线索传递左白") end
        t = a[math.random(#a)]
        log('给随机')
      end
      if t then
        tap(t)
        return true
      end
    end
    while count < 50 / 4 do
      -- 翻到末尾就随机给
      if not find("线索传递右白") and not find("线索传递右白2") then
        f(true)
        return true
      end
      -- 当前页看看有没有缺的
      if f() then return true end
      tap("线索传递右白")
      count = count + 1
    end
  end,
})

path.信用奖励 = function()
  update_station_list()
  if not point.会客厅 then return end
  no_friend = false
  auto(update(path.base, {
    信用奖励有 = function()
      if find("已达线索上限") then
        if no_friend then return true end
        auto(path.线索传递)
      end
      tap("信用奖励有")
      auto(path.线索布置)
    end,
    会客厅信用奖励 = "会客厅信用奖励",
    进驻信息3 = "线索",
    进驻总览 = "会客厅",
    信用奖励无 = function()
      if not find("已达线索上限") then return true end
      if no_friend then return true end
      auto(path.线索传递)
    end,
    面板 = "面板基建",
    进驻信息3选中 = "进驻信息3选中",
  }))
  auto(path.线索布置)
end

path.任务 = function()
  local l = {"日常任务", "周常任务"}
  for _, i in pairs(l) do
    local p = update(path.base, {
      面板 = "面板任务",
      见习任务 = i,
      日常任务 = i,
      活动任务 = i,
      周常任务 = i,
    })
    p[i] = function()
      findTap('任务蓝')
      if table.any({'任务黑', "任务灰"}, find) then return true end
    end
    p['活动任务'] = p["日常任务"]
    auto(p)
  end
end

path.信用购买 = function()
  auto(update(path.base, {
    面板 = "面板采购中心",
    可露希尔推荐 = "信用交易所",
    信用交易所 = function()
      keepScreen(true)
      if not findTap(unpack(point.信用交易所列表)) then
        -- if not findTap("信用交易所商品") then
        keepScreen(false)
        return true
      end
      -- keepScreen(false)
      findTap("购买物品")
      if find("信用不足") then return true end
    end,
  }))
  return true
end

path.信用收取 = update(path.base, {
  面板 = "面板采购中心",
  可露希尔推荐 = "信用交易所",
  收取信用 = "收取信用",
  收取信用无 = true,
})

path.邮件 = update(path.base, {
  面板 = function()
    tap("面板邮件")
    if appear("收取所有邮件", 3, 1) then
      tap("收取所有邮件")
      return true
    end
  end,
})

tick = 0
path.轮次作战 = function()
  while running ~= "理智不足" do
    set("tick", tick)
    tick = tick % #fight_type + 1
    path.作战(fight_type[tick])
  end
end

path.作战 = function(x)
  local f = startsWithX(x)
  if table.any({"PR", "CE", "CA", "AP", "LS", "SK"}, f) then
    path.物资芯片(x)
  elseif table.any({'龙门外环', '切尔诺伯格', '龙门市区'}, f) then
    path.剿灭(x)
  elseif f("DM") then
    if os.time() <
      os.time({year = 2020, month = 5, day = 15, hour = 4, min = 0, sec = 0}) then
      path.生于黑夜(x)
    else
      path.主线("1-7")
    end
  else
    path.主线(x)
  end
end

path.开始游戏 = function(x)
  log(tick, ' ', x)
  if x == "1-11" then return auto(path["1-11"]) end
  return auto(update(path.base, {
    面板 = true,
    代理指挥关 = "代理指挥关",
    代理指挥开 = "开始行动蓝",
    开始行动红 = function()
      -- log(x)
      -- if true then return true end
      tap("开始行动红")
      sleep(10)
    end,
    接管作战 = function()
      if disappear("接管作战", 60 * 60, 5) and
        not find("代理失误放弃行动") and
        not appear("战斗记录未能同步返回", 2, 1) and
        appear("行动结束", 10, 1) then
        log('代理成功', x)
        cl[x] = (cl[x] or 0) + 1
        sleep(3)
        tap("返回")
        sleep(4)
      else
        log('代理失误', x)
        bl[x] = false
      end
      return true
    end,
  }))
end

path.主线 = function(x)
  -- split s2-9 to 2 and 9
  local x0 = x
  local x1 = x0:find("-")
  local x2
  local t = "当前进度列表"
  if not x1 then return end
  x1, x2 = x0:sub(1, x1 - 1), x0:sub(x1 + 1)
  x1 = (x1:startsWith("S")) and x1:sub(2) or x1
  local x3 = tonumber(x1) + 1
  -- 面板=>开始游戏
  local p = update(path.base, {
    面板 = function()
      tap("面板作战")
      swipq(x1)
      tap("作战主线章节列表" .. x1)
    end,
    [t .. x3] = function()
      swipq(x0)
      local v = point.滑动距离[x0]
      v = v[#v]
      sleep(math.abs(v) / 500)
      if not findTap("作战列表" .. x) then
        -- distance or point error
        log(x .. "未找到")
        bl[x] = false
      end
      return true
    end,
  })
  -- switch chapter
  for i = 1, #point[t] do
    if x3 ~= i then p[t .. i] = t .. (i > x3 and "左" or "右") end
  end
  auto(p)
  path.开始游戏(x)
end
update_open_time = function()
  -- 芯片搜索
  pr_open_time = {
    A = {1, 4, 5, 7},
    B = {1, 2, 5, 6},
    C = {3, 4, 6, 7},
    D = {2, 3, 6, 7},
  }
  pr_open_time_r = table.reverseIndex(pr_open_time)
  -- pr_open_time_r[1]={"A","B"}
  -- pr_open_time_r[2]={"B","D"}
  -- pr_open_time_r[3]={"C","D"}
  -- pr_open_time_r[4]={"A","C"}
  -- pr_open_time_r[5]={"A","B"}
  -- pr_open_time_r[6]={"B","C","D"}
  -- pr_open_time_r[7]={"A","C","D}
  -- 物资筹备
  ls_open_time = {
    LS = {1, 2, 3, 4, 5, 6, 7},
    AP = {1, 4, 6, 7},
    CA = {2, 3, 5, 7},
    CE = {2, 4, 6, 7},
    SK = {1, 3, 5, 6},
  }
  ls_open_time_r = table.reverseIndex(ls_open_time)
  -- ls_open_time_r[1]={"LS","AP","SK"}
  -- ls_open_time_r[2]={"LS","CA","CE"}
  -- ls_open_time_r[3]={"LS","CA","SK"}
  -- ls_open_time_r[4]={"LS","AP","CE"}
  -- ls_open_time_r[5]={"LS","CA","SK"}
  -- ls_open_time_r[6]={"LS","AP","SK","CE"}
  -- ls_open_time_r[7]={"LS","AP","CA","CE"}
  -- move CE to last
  local lotr = ls_open_time_r
  for k, v in pairs(lotr) do
    table.remove(lotr[k], table.find(lotr[k], equalX("LS")))
    insert(lotr[k], 1, "LS")
    local p = table.find(lotr[k], equalX("CE"))
    if p then
      table.remove(lotr[k], p)
      insert(lotr[k], "CE")
    end
  end
  local a = os.time({
    year = 2020,
    month = 6,
    day = 2,
    hour = 16,
    min = 0,
    sec = 0,
  })
  local b = os.time({
    year = 2020,
    month = 6,
    day = 16,
    hour = 4,
    min = 0,
    sec = 0,
  })
  local t = os.time()
  if a <= t and t < b then
    log("全天开启时间表")
    pr_open_time = {
      A = {1, 2, 3, 4, 5, 6, 7},
      B = {1, 2, 3, 4, 5, 6, 7},
      C = {1, 2, 3, 4, 5, 6, 7},
      D = {1, 2, 3, 4, 5, 6, 7},
    }
    pr_open_time_r[1] = {"A", "B", "C", "D"}
    pr_open_time_r[2] = {"B", "D", "A", "C"}
    pr_open_time_r[3] = {"C", "D", "A", "B"}
    pr_open_time_r[4] = {"A", "C", "B", "D"}
    pr_open_time_r[5] = {"A", "B", "C", "D"}
    pr_open_time_r[6] = {"B", "C", "D", "A"}
    pr_open_time_r[7] = {"A", "C", "D", "B"}

    ls_open_time = {
      LS = {1, 2, 3, 4, 5, 6, 7},
      CA = {1, 2, 3, 4, 5, 6, 7},
      CE = {1, 2, 3, 4, 5, 6, 7},
      SK = {1, 2, 3, 4, 5, 6, 7},
      AP = {1, 2, 3, 4, 5, 6, 7},
    }
    ls_open_time_r[1] = {"LS", "AP", "SK", "CA", "CE"}
    ls_open_time_r[2] = {"LS", "CA", "CE", "AP", "SK"}
    ls_open_time_r[3] = {"LS", "CA", "SK", "AP", "CE"}
    ls_open_time_r[4] = {"LS", "AP", "CE", "CA", "SK"}
    ls_open_time_r[5] = {"LS", "CA", "SK", "AP", "CE"}
    ls_open_time_r[6] = {"LS", "AP", "SK", "CE", "CA"}
    ls_open_time_r[7] = {"LS", "AP", "CA", "CE", "SK"}
  end
end
update_open_time()
path.更新开启时间 = update_open_time

path.物资芯片 = function(x)
  -- split PR-A-1 to A and 1, split LS-1 to LS and 1
  local type = x:startsWith("PR") and "pr" or "ls"
  local x0 = type == "pr" and x:sub(4) or x
  local prls_open_time = _G[type .. "_open_time"]
  local prls_open_time_r = _G[type .. "_open_time_r"]
  local name = type == "pr" and "芯片搜索" or "物资筹备"
  local x1 = x0:find("-")
  local x2
  if not x1 then return end
  x1, x2 = x0:sub(1, x1 - 1), x0:sub(x1 + 1)
  -- check if open now
  local open_time = prls_open_time[x1]
  local cur_time = tonumber(os.date("%w", os.time() - 4 * 3600))
  if cur_time == 0 then cur_time = 7 end

  if not table.includes(open_time, cur_time) then return end
  -- get the index in 芯片搜索
  local cur_open = prls_open_time_r[cur_time]
  local index = table.find(cur_open, equalX(x1))
  -- 面板=>开始游戏
  local p = update(path.base, {
    面板 = function()
      tap("面板作战")
      tap("作战" .. name)
      tap(name .. "列表" .. index)
    end,
    ["作战列表" .. x] = function()
      tap("作战列表" .. x)
      return true
    end,
  })
  auto(p)
  path.开始游戏(x)
end

jwf = {full = false, week = nil}
path.剿灭 = function(x)
  -- 周一4点
  local start_week_time = os.time({
    year = 2019,
    month = 6,
    day = 17,
    hour = 4,
    min = 0,
    sec = 0,
  })
  local cur_week = math.ceil((os.time() - start_week_time) / (7 * 24 * 3600))
  if jwf.week ~= cur_week then jwf = {full = false, week = cur_week} end
  if jwf.full then return end
  local p = update(path.base, {
    面板 = function()
      tap("面板作战")
      tap("作战剿灭")
    end,
    ["作战列表" .. x] = function()
      if not find("报酬合成玉未满") then
        jwf.full = true
        log("本周合成玉已满")
      end
      tap("作战列表" .. x)
      return true
    end,
  })
  auto(p)
  if jwf.full then return end
  path.开始游戏(x)
end

path.访问好友基建 = function()
  if comm_enough then return end
  local loop_end = false
  auto(update(path.base, {
    面板 = '面板好友',
    个人名片 = '好友列表',
    好友列表 = function()
      if not appear('访问基建', 3, 1) then return true end
      tap("访问基建")
      while 1 do
        if not wait(nil, function()
          if find("今日参与交流已达上限") then
            comm_enough = true
            return true
          end
          if find("访问下位无") then
            loop_end = true
            return true
          end
          return findTap("访问下位橘", "访问下位")
        end, 10, 2) or comm_enough or loop_end then return true end
      end
    end,
  }))
end

-- show station list
showSL = function(not_show)
  local a = ''
  local l = {"宿舍", "制造站", "贸易站", "发电站"}
  local r = {"会客厅", "控制中枢", "加工站", "办公室", "训练室"}
  for k, v in pairs(l) do
    if point[v .. '列表'] then
      a = a .. v .. 'x' .. #point[v .. '列表'] .. ' '
    end
  end
  for k, v in pairs(r) do if point[v] then a = a .. v .. 'x1 ' end end
  if not_show then return a end
  show(a, 500)
end

-- show failed fight
showBL = function(not_show)
  local a = ''
  local b = ''
  for k, v in pairs(bl) do if not v then b = b .. k .. " " end end
  if #b > 0 then a = a .. '失败：' .. b end
  if not_show then return a end
  show(a, 500)
end

-- show success fight
showCL = function(not_show)
  local a = ''
  for k, v in pairs(cl) do if v > 0 then a = a .. k .. "x" .. v .. ' ' end end
  if #a > 0 then a = '已完成：' .. a end
  if not_show then return a end
  show(a, 500)
end

-- show all info
showALL = function()
  -- show(showSL(true) .. '\n' .. showBL(true) .. '\n' .. showCL(true), 500)
  show(taglog .. (#taglog and "\n" or "") .. showBL(true), 36)
end
path.关闭 = close
path.显示全部 = showALL
path.后台 = background

path["1-11"] = function()
  local x = "1-11"
  tap("开始行动蓝")
  -- wait 安德切尔
  if not findTap("开始行动红") then return end
  sleep(10)
  if not findTap("跳过剧情") then
    log("没找到跳过剧情")
    log('代理失误', x)
    bl[x] = false
    return false
  end
  sleep(.5)
  findTap("跳过剧情确认")
  -- start
  sleep(23)
  tap("速度2")
  -- 芬
  deploy(591, 807, 522)
  -- 翎羽
  deploy(447, 948, 516)
  -- 杰西卡
  sleep(2)
  deploy(585, 939, 373)
  -- 安塞尔
  sleep(6)
  deploy(1299, 801, 384)
  -- 玫兰莎
  sleep(8)
  deploy(945, 1227, 368)
  -- 黑角
  deploy(1122, 1216, 269)
  -- 米格鲁
  sleep(11)
  -- 黑角
  -- retreat(1110, 263, 894, 323)
  deploy(1482, 813, 314)
  -- 史都华德
  deploy(1656, 669, 407)
  sleep(6)
  -- 玫兰莎
  retreat(1110, 368, 894, 323)
  if appear("行动结束", 60, 1) then
    log('代理成功', x)
    cl[x] = (cl[x] or 0) + 1
    sleep(3)
    tap("返回")
    sleep(4)
  else
    log('代理失误', x)
    bl[x] = false
  end
end

path.公开招募聘用 = update(path.base, {
  面板 = function()
    if not findTap("面板公开招募有") then return true end
  end,
  公开招募 = function()
    keepScreen(true)
    if findTap(unpack(point["聘用候选人列表"])) then
      keepScreen(false)
      findTap("开包skip")
    end
    tap("返回")
  end,
})

taglog = ''
path.公开招募刷新 = function()
  taglog = ''
  auto(update(path.base, {面板 = "面板公开招募", 公开招募 = true}))
  -- if find("公开招募联络次数0") then return end
  local a, tt, t, flag
  for i = 1, #point.公开招募列表 do
    auto(update(path.base, {面板 = "面板公开招募", 公开招募 = true}))
    auto(update(path.base, {
      面板 = "面板公开招募",
      公开招募 = function()
        -- if find("公开招募联络次数0") then return true end
        if not findTap('公开招募列表' .. i) then return true end
      end,
      公开招募确认 = function()
        a = {}
        b = {}
        mr = 5 -- max retries for one tag
        for k, v in pairs(point.公开招募标签框列表) do
          v = point[v]
          t = ""
          r = 1
          while not table.includes(tag, t) and r < mr do
            r = r + 1
            t = binarizeImage({
              rect = v,
              diff = {"0xffffff-0x989898"}, -- background<=0x66
            })
            t = ocr(t)
          end
          if not table.includes(tag, t) then
            tt = 'invalid tag: ' .. table.concat(a, ',') .. ',' .. tostring(t)
            log(tt)
            taglog = taglog .. '\n' .. tt
            return true
          end
          insert(a, t)
        end
        tt = table.concat(a, ',')
        log(tt)
        -- discover at least 4 stars tags
        t = {}
        for k, v in pairs(tagk) do
          flag = true
          for k1, v1 in pairs(v) do
            if not table.includes(a, v1) then
              flag = false
              break
            end
          end
          if flag then insert(t, k) end
        end
        if #t ~= 0 then
          for k, v in pairs(t) do
            tt = table.concat(tagk[v], ',') .. '=>' .. tagv[v]
            log(tt)
            taglog = taglog .. '\n' .. tt
          end
          if #t == 1 then
            tt = tagk[t[1]]
            for k, v in pairs(tt) do
              p = table.find(a, function(x) return x == v end)
              tap("公开招募标签列表" .. p)
            end
            for i = 1, 8 do tap("公开招募时间加") end
            tap("公开招募确认")
          end
        else
          if findTap("公开招募标签刷新蓝") then
            tap("消耗一次联络机会确认")
            return false
          end
        end
        return true
      end,
    }))
  end
end

path["作战1-11"] = function() for i = 1, 14 do path.作战("1-11") end end

path.生于黑夜 = function(x)
  local p = update(path.base, {
    面板 = function()
      tap("面板作战")
      tap("作战生于黑夜")
      sleep(1)
      tap("生于黑夜阵中往事")
      sleep(1)
    end,
    ["作战列表" .. x] = function()
      tap("作战列表" .. x)
      return true
    end,
  })
  auto(p)
  path.开始游戏(x)
end

error = function()
  if find("返回x") then
    log("限时活动")
    local retry = 0, t
    local retry_m = 3
    while find("返回x") and retry < retry_m do
      t = "限时活动列表"
      for i = 1, #point[t] do tap(t .. i) end
      t = "限时活动横列表"
      for i = 1, #point[t] do tap(t .. i) end
      if findTap('返回x') then break end
      retry = retry + 1
    end
    if retry_m == retry then
      log("限时活动执行失败")
      stop()
    end
  else
    log("未知状态")
    stop()
  end
end

update_app = function()

  out_of_app = true
  -- delete app
  closeApp("com.android.settings")
  runApp("com.android.settings")
  if not appear("settings", 15, 1) then return end
  swip(1000, 500, 0, 10000, .4)
  swip(1000, 500, 0, -200, 1)
  tap("settings_Apps")
  if not appear("Apps", 15, 1) then return end
  if findTap("Apps_arknights") then
    if not appear("Appinfo", 15, 1) then return end
    tap("Appinfo_uninstall")
    if not appear("uninstall", 15, 1) then return end
    tap("uninstall_ok")
    sleep(15)
  end

  -- delete apk
  closeApp("com.cyanogenmod.filemanager")
  runApp("com.cyanogenmod.filemanager")
  if not appearTap("filemanager_search", 15, 1) then return end
  sleep(3)
  inputText("#CLEAR#")
  inputText("ark")
  inputText("#ENTER#")
  while appear("filemanager_search_ark", 15, 1) do
    touchDown(1, 200, 260)
    sleep(3)
    touchUp(1, 200, 260)
    tap("filemanager_delete")
    sleep(3)
    tap({1260, 740})
    sleep(3)
  end

  -- download
  -- closeApp("com.android.providers.downloads.ui")
  -- closeApp("com.android.providers.downloads")

  closeApp("com.android.browser")
  runApp("com.android.browser")
  if not appear("download", 15, 1) then return end
  tap({1000, 150}) -- address bar
  inputText("#CLEAR#")
  inputText("https://ak.hypergryph.com/downloads/android_lastest")
  inputText("#ENTER#")
  swip(290, 34, 0, 300, .4, .2)
  sleep(1)
  for i = 1, 5 do
    swip(446, 316, 10000, 0, .4, .2)
    sleep(1)
  end
  if not appear("downloading", 15, 1) then return end
  if not disappear("downloading", 4096, 60) then return end
  tap("返回")

  -- install
  closeApp("com.cyanogenmod.filemanager")
  runApp("com.cyanogenmod.filemanager")
  if not appearTap("filemanager_search", 15, 1) then return end
  sleep(3)
  inputText("#CLEAR#")
  inputText("ark")
  inputText("#ENTER#")
  if not appearTap("filemanager_search_ark", 15, 1) then return end
  while appear("install", 15, 1) do
    tap("install_btn")
    sleep(3)
  end
  sleep(30)
  out_of_app = false
  return true
end
