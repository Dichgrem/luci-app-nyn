local m, s, o
local sys = require("luci.sys")
local zzz = require("luci.model.zzz_cron")

m = Map(
	"zzz",
	translate("ZZZ 802.1x Authentication Client"),
	translate("Configure 802.1x authentication for network access using zzz client")
)

s = m:section(TypedSection, "auth", translate("Authentication Settings"))
s.anonymous = true
s.addremove = false

o = s:option(DummyValue, "_status", translate("Current Status"))
o.rawhtml = true
o.cfgvalue = function()
	if zzz.get_service_status() then
		return "<span style='color:green;font-weight:bold'>" .. translate("Running") .. "</span>"
	else
		return "<span style='color:red;font-weight:bold'>" .. translate("Not Running") .. "</span>"
	end
end

o = s:option(DummyValue, "_control", translate("Service Control"))
o.rawhtml = true
o.cfgvalue = function()
	return [[
		<div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
			<button type="button" class="cbi-button cbi-button-apply" onclick="fetch('/cgi-bin/luci/admin/network/zzz/service_control',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=start'}).then(r=>r.json()).then(d=>{alert(d.message);if(d.success)location.reload();});return false;">]] .. translate(
		"Start Service"
	) .. [[</button>
			<button type="button" class="cbi-button cbi-button-remove" onclick="fetch('/cgi-bin/luci/admin/network/zzz/service_control',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=stop'}).then(r=>r.json()).then(d=>{alert(d.message);if(d.success)location.reload();});return false;">]] .. translate(
		"Stop Service"
	) .. [[</button>
			<button type="button" class="cbi-button cbi-button-reload" onclick="fetch('/cgi-bin/luci/admin/network/zzz/service_control',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=restart'}).then(r=>r.json()).then(d=>{alert(d.message);if(d.success)location.reload();});return false;">]] .. translate(
		"Restart Service"
	) .. [[</button>
		</div>
	]]
end

o = s:option(
	Value,
	"username",
	translate("Username"),
	translate("802.1x authentication username")
		.. [[
<span style="cursor: help; color: #007bff; font-weight: bold;" title="]]
		.. translate("Format: studentID@carrier, e.g. 212306666@cucc; Mobile=cmcc, Unicom=cucc, Telecom=ctcc")
		.. [[">?</span>]]
)
o.rmempty = false
function o.validate(self, value)
	value = (value:match("^%s*(.-)%s*$") or value)
	if #value < 3 or #value > 64 then
		return nil, translate("Username must be 3-64 characters")
	end
	if not value:match("^[a-zA-Z0-9@._-]+$") then
		return nil, translate("Username can only contain letters, numbers, @, ., _ and -")
	end
	return value
end

o = s:option(
	Value,
	"password",
	translate("Password"),
	translate("802.1x authentication password")
		.. [[
<span style="cursor: help; color: #007bff; font-weight: bold;" title="]]
		.. translate("Default is last 6 digits of ID card, can be changed in official iNode client")
		.. [[">?</span>]]
)
o.password = true
o.rmempty = false
function o.validate(self, value)
	if #value < 4 or #value > 128 then
		return nil, translate("Password must be 4-128 characters")
	end
	return value
end

o = s:option(
	Value,
	"device",
	translate("Network Interface"),
	translate("Network interface for authentication")
		.. [[
<span style="cursor: help; color: #007bff; font-weight: bold;" title="]]
		.. translate("Use 'ip addr' to check, look for interface with 10.38.x.x IP")
		.. [[">?</span>]]
)
o.rmempty = false
o:value("eth0", "eth0")
o:value("eth1", "eth1")
o:value("wan", "WAN")

local interfaces = sys.net.devices()
for _, iface in ipairs(interfaces) do
	if iface ~= "lo" and iface:match("^[a-zA-Z0-9]+$") then
		o:value(iface, iface)
	end
end

function o.validate(self, value)
	if not value:match("^[a-zA-Z0-9]+$") then
		return nil, translate("Network interface can only contain letters and numbers")
	end
	return value
end

auto_start = s:option(Flag, "auto_start", translate("Enable Scheduled Start"))
auto_start.description = translate("When enabled, service will auto-start at scheduled time on weekdays (Mon-Fri)")
auto_start.rmempty = false

auto_start.cfgvalue = function(self, section)
	return zzz.is_cron_enabled() and "1" or "0"
end

auto_start.write = function(self, section, value)
	local schedule_time_val = self.map:formvalue("cbid.zzz." .. section .. ".schedule_time") or "07:00"
	zzz.set_cron(value, schedule_time_val)
end

schedule_time = s:option(Value, "schedule_time", translate("Schedule Time"))
schedule_time.description = translate("Daily auto-start time (format: HH:MM, e.g. 07:30)")
schedule_time.placeholder = "07:00"
schedule_time.rmempty = false
schedule_time.default = "07:00"

schedule_time.cfgvalue = function(self, section)
	local value = self.map:get(section, "schedule_time")
	return value or "07:00"
end

function schedule_time.validate(self, value)
	if not value:match("^[0-9][0-9]:[0-9][0-9]$") then
		return nil, translate("Time format must be HH:MM (e.g. 07:30)")
	end
	local hour = tonumber(value:sub(1, 2))
	local minute = tonumber(value:sub(4, 5))
	if hour < 0 or hour > 23 then
		return nil, translate("Hour must be 0-23")
	end
	if minute < 0 or minute > 59 then
		return nil, translate("Minute must be 0-59")
	end
	return value
end

schedule_time:depends("auto_start", "1")

o = s:option(DummyValue, "_timer_status", translate("Scheduled Task Status"))
o.rawhtml = true
o.cfgvalue = function()
	if zzz.is_cron_enabled() then
		local min, hr = zzz.get_cron_time()
		return "<span style='color:green;font-weight:bold'>"
			.. string.format(translate("Enabled (Auto-start at %s:%s on weekdays)"), hr or "07", min or "00")
			.. "</span>"
	else
		return "<span style='color:red;font-weight:bold'>" .. translate("Disabled") .. "</span>"
	end
end

m.on_commit = function(self)
	sys.call("/etc/init.d/zzz restart >/dev/null 2>&1 &")
end

return m
