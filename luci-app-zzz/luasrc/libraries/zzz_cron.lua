local sys = require("luci.sys")
local nixio = require("nixio")

local M = {}

local CRON_MARKER = "# zzz auto start"
local INIT_SCRIPT = "/etc/init.d/zzz"

function M.get_cron_time()
	local cron_line = sys.exec("crontab -l 2>/dev/null | grep '" .. INIT_SCRIPT .. "' | grep '" .. CRON_MARKER .. "'")
	if cron_line and cron_line ~= "" then
		local minute, hour = cron_line:match("^(%d+)%s+(%d+)")
		return minute, hour
	end
	return nil, nil
end

function M.is_cron_enabled()
	return sys.call("crontab -l 2>/dev/null | grep '" .. INIT_SCRIPT .. "' | grep '" .. CRON_MARKER .. "' >/dev/null")
		== 0
end

function M.set_cron(enable, schedule_time)
	local minute = "0"
	local hour = "7"

	if schedule_time then
		local h, m = schedule_time:match("^(%d+):(%d+)$")
		if h and m then
			hour = tonumber(h)
			minute = tonumber(m)
		end
	end

	local cron_content = ""
	local current = sys.exec("crontab -l 2>/dev/null")
	if current and current ~= "" then
		local lines = {}
		for line in current:gmatch("[^\r\n]+") do
			if not line:match(INIT_SCRIPT) and not line:match(CRON_MARKER) then
				lines[#lines + 1] = line
			end
		end
		cron_content = table.concat(lines, "\n") .. "\n"
	end

	if enable == "1" then
		cron_content = cron_content
			.. string.format("%d %d * * 1,2,3,4,5 /etc/init.d/zzz start %s\n", minute, hour, CRON_MARKER)
	end

	math.randomseed(os.time(), os.clock())
	local flags = nixio.open_flags("creat", "excl", "trunc", "wronly")
	local temp_cron
	for _ = 1, 5 do
		temp_cron = "/tmp/.zzz_cron_" .. os.time() .. "_" .. math.random(100000, 999999)
		local fd = nixio.open(temp_cron, flags, 600)
		if fd then
			fd:writeall(cron_content)
			fd:close()
			break
		end
		temp_cron = nil
	end
	if not temp_cron then
		return false
	end

	local ret = sys.call("crontab " .. temp_cron .. " 2>/dev/null")
	nixio.fs.unlink(temp_cron)

	if ret == 0 then
		sys.call("/etc/init.d/cron restart 2>/dev/null")
		return true
	end
	return false
end

function M.get_service_status()
	return sys.call("pidof zzz >/dev/null") == 0
end

function M.get_zzz_process_info()
	if M.get_service_status() then
		return sys.exec("ps | grep -v grep | grep zzz")
	end
	return nil
end

function M.get_status_log()
	local log_file = "/tmp/zzz.log"
	if nixio.fs.access(log_file) then
		return sys.exec("tail -20 " .. log_file)
	end
	return sys.exec("logread | grep zzz | tail -10")
end

return M
