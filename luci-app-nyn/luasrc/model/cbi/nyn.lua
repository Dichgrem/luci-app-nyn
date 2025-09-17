-- /usr/lib/lua/luci/model/cbi/nyn.lua
local m, s, o
local sys = require "luci.sys"

m = Map("nyn", "NYN 802.1x 认证客户端",
    "配置使用 NYN 客户端进行网络访问的 802.1x 认证")

-- Authentication Settings
s = m:section(TypedSection, "auth", "认证设置")
s.anonymous = true
s.addremove = false

-- Service Status
o = s:option(DummyValue, "_status", "当前状态")
o.rawhtml = true
o.cfgvalue = function()
    local sys = require "luci.sys"
    local running = sys.call("pgrep nyn >/dev/null") == 0
    if running then
        return "<span style='color:green;font-weight:bold'>✔ 正在运行中</span>"
    else
        return "<span style='color:red;font-weight:bold'>✘ 未运行</span>"
    end
end

-- Enable/Disable
o = s:option(Flag, "enabled", "启用服务")
o.rmempty = false

-- Username
o = s:option(Value, "user", "用户名", "802.1x 认证用户名")
o.password = true
o.rmempty = false

-- Password
o = s:option(Value, "password", "密码", "802.1x 认证密码")
o.password = true
o.rmempty = false

-- Network Device
o = s:option(ListValue, "device", "网络接口", "用于认证的网络接口")
o.rmempty = false
o:value("eth0", "eth0")
o:value("eth1", "eth1")
o:value("wan", "WAN")

-- Add network interface
local interfaces = sys.net.devices()
for _, iface in ipairs(interfaces) do
    if iface ~= "lo" then
        o:value(iface, iface)
    end
end

return m
