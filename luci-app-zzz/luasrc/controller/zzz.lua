module("luci.controller.zzz", package.seeall)

local zzz_lib = require("luci.library.zzz_cron")

function index()
	if not nixio.fs.access("/etc/config/zzz") then
		return
	end

	entry({ "admin", "network", "zzz" }, cbi("zzz"), _("ZZZ"), 60).dependent = false

	entry({ "admin", "network", "zzz", "service_control" }, call("service_control")).leaf = true

	entry({ "admin", "network", "zzz", "get_status" }, call("get_status")).leaf = true
end

function service_control()
	local http = require("luci.http")
	local sys = require("luci.sys")

	local action = http.formvalue("action")
	local result = { success = false, message = "" }

	local valid_actions = { start = true, stop = true, restart = true }

	if action and valid_actions[action] then
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
			result.success = (ret == 0)
			result.message = result.success and action .. " succeeded" or action .. " failed"
		end
	else
		result.message = "Invalid action"
	end

	http.prepare_content("application/json")
	http.write_json(result)
end

function get_status()
	local http = require("luci.http")

	local status = {
		running = zzz_lib.get_service_status(),
		process_info = zzz_lib.get_zzz_process_info(),
		log = zzz_lib.get_status_log(),
		auto_start = zzz_lib.is_cron_enabled(),
	}

	http.prepare_content("application/json")
	http.write_json(status)
end
