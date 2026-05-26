sh_files := "zzz/files/etc/init.d/zzz zzz/files/usr/bin/zzz-device-info"
lua_files := "luci-app-zzz/luasrc/controller/zzz.lua luci-app-zzz/luasrc/model/cbi/zzz.lua luci-app-zzz/luasrc/libraries/zzz_cron.lua"

fmt:
	shfmt -w -s -ln=posix {{sh_files}}
	stylua {{lua_files}}

check:
	shfmt -l -s -ln=posix {{sh_files}}
	stylua --check {{lua_files}}
