-- /usr/lib/lua/luci/model/cbi/nyn.lua
local m, s, o
local sys = require "luci.sys"

-- control
local start_action = luci.http.formvalue("cbid.nyn.auth.start_service")
local stop_action = luci.http.formvalue("cbid.nyn.auth.stop_service")  
local restart_action = luci.http.formvalue("cbid.nyn.auth.restart_service")

if start_action then
    sys.call("/etc/rc.d/S99nyn start")
elseif stop_action then
    sys.call("/etc/rc.d/S99nyn stop")
elseif restart_action then
    sys.call("/etc/rc.d/S99nyn stop; sleep 2; /etc/rc.d/S99nyn start")
end

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

-- control buttons
control_buttons = s:option(DummyValue, "_control", "服务控制")
control_buttons.rawhtml = true
control_buttons.cfgvalue = function()
    return [[
        <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
            <input type="submit" class="cbi-button cbi-button-apply" 
                   name="cbid.nyn.auth.start_service" value="启动服务" />
            <input type="submit" class="cbi-button cbi-button-remove" 
                   name="cbid.nyn.auth.stop_service" value="停止服务" />
            <input type="submit" class="cbi-button cbi-button-reload" 
                   name="cbid.nyn.auth.restart_service" value="重启服务" />
        </div>
    ]]
end

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
