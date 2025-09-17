-- /usr/lib/lua/luci/controller/nyn.lua
module("luci.controller.nyn", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/nyn") then
        return
    end

    -- Menu
    entry({"admin", "network", "nyn"}, firstchild(), _("NyN-Client"), 60).dependent = false

    -- Settings
    entry({"admin", "network", "nyn", "config"}, cbi("nyn"), _("Settings"), 1).leaf = true

    -- Status API
    entry({"admin", "network", "nyn", "get_status"}, call("act_status")).leaf = true
end

function act_status()
    local sys = require "luci.sys"
    local util = require "luci.util"
    local status = {}

    -- Get status
    status.running = (sys.call("pgrep -f nyn >/dev/null") == 0)

    -- Get process info
    if status.running then
        status.process_info = util.trim(sys.exec("ps | grep -v grep | grep nyn"))
    end

    -- Get log
    local log_file = "/tmp/nyn.log"
    if nixio.fs.access(log_file) then
        status.log = util.trim(sys.exec("tail -20 " .. log_file))
    else
        status.log = util.trim(sys.exec("logread | grep nyn | tail -10"))
    end

    luci.http.prepare_content("application/json")
    luci.http.write_json(status)
end


