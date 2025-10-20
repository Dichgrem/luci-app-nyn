-- /usr/lib/lua/luci/controller/zzz.lua
module("luci.controller.zzz", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/zzz") then
		return
	end

	-- Menu
	entry({ "admin", "network", "zzz" }, cbi("zzz"), "ZZZ", 60).dependent = false

	-- Settings
	entry({ "admin", "network", "zzz", "service_control" }, call("service_control")).leaf = true

	-- Status API
	entry({ "admin", "network", "zzz", "get_status" }, call("act_status")).leaf = true
end

function service_control()
	local sys = require("luci.sys")
	local action = luci.http.formvalue("action")
	local result = { success = false, message = "" }

	if action then
		local cmd = ""
		if action == "start" then
			cmd = "/etc/rc.d/S99zzz start"
		elseif action == "stop" then
			cmd = "/etc/rc.d/S99zzz stop"
		elseif action == "restart" then
			cmd = "/etc/rc.d/S99zzz stop && sleep 2 && /etc/rc.d/S99zzz start"
		end

		if cmd ~= "" then
			local ret = sys.call(cmd)
			if ret == 0 then
				result.success = true
				result.message = action .. " 成功"
			else
				result.success = false
				result.message = action .. " 失败"
			end
		end
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json(result)
end

function act_status()
	local sys = require("luci.sys")
	local util = require("luci.util")
	local status = {}

	-- Get status
	status.running = (sys.call("pgrep -f zzz >/dev/null") == 0)

	-- Get process info
	if status.running then
		status.process_info = util.trim(sys.exec("ps | grep -v grep | grep zzz"))
	end
	-- Get log
	local log_file = "/tmp/zzz.log"
	if nixio.fs.access(log_file) then
		status.log = util.trim(sys.exec("tail -20 " .. log_file))
	else
		status.log = util.trim(sys.exec("logread | grep zzz | tail -10"))
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json(status)
end
