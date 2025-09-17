-- /usr/lib/lua/luci/model/cbi/nyn.lua

local m, s, o
local sys = require "luci.sys"

m = Map("nyn", translate("NYN 802.1x Authentication Client"),
    translate("Configure 802.1x authentication for network access using NYN client"))

-- Authentication Settings
s = m:section(TypedSection, "auth", translate("Authentication Settings"))
s.anonymous = true
s.addremove = false

-- Service Status
o = s:option(DummyValue, "_status", translate("Current Status"))
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
o = s:option(Flag, "enabled", translate("Enable Service"))
o.rmempty = false

-- Username
o = s:option(Value, "user", translate("Username"), translate("802.1x authentication username"))
o.rmempty = false

-- Password
o = s:option(Value, "password", translate("Password"), translate("802.1x authentication password"))
o.password = true
o.rmempty = false

-- Network Device
o = s:option(ListValue, "device", translate("Network Device"), translate("Network device to use for authentication"))
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
