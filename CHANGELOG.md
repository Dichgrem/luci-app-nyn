# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-05-26

### Added

- Adjustable schedule time (user-configurable HH:MM instead of hardcoded 07:00)
- Shared cron management module extracted from CBI form
- Development tooling: justfile with `fmt` and `check` recipes (shfmt + stylua)
- CI builds across 7 architectures

### Changed

- Extract status checking and cron logic into dedicated `zzz_cron` library
- Build zzz daemon from upstream source (Meson) instead of prebuilt binary
- Use `/etc/init.d/zzz` paths throughout instead of `/etc/rc.d/S99zzz` symlinks
- Pipe zzz output through `logger` instead of unreliably relying on procd stdout

### Fixed

- CBI form: changing both auto-start toggle and schedule time in one submission
  used stale (old) schedule time in cron entry
- Service not responding to UCI config changes — added `service_triggers()`
- `pgrep -f zzz` matched unrelated processes (grep, zzz-device-info) —
  replaced with `pidof zzz` for exact process name match
- Cron entry path hardcoded instead of reusing `INIT_SCRIPT` variable
- `math.randomseed` second argument silently ignored on Lua 5.1
- `zzz_cron.lua` not installed — `luci.mk` ignores `libraries/` directory;
  moved to `model/` which the build system handles
- i18n: PO translations out of sync with changed schedule-related strings

### Security

- Shell injection in `generate_config()`: unquoted heredoc expanded `$()` and
  backticks in password values — replaced with `printf %s` for literal output
- Predictable temp file name in cron manager could be symlink-attacked —
  replaced with `nixio.open` using `O_EXCL` for atomic creation with random suffix

## [2.0.2] - 2026-04-07

### Added

- Package feed support (apk + opkg) for direct router updates
- CI builds both APK (25.12) and IPK (24.10) formats

### Changed

- Build from source for both ARM and MIPS targets

### Fixed

- XSS in service control output
- Crontab logic for auto-start
- Username validation

## [2.0.1] - 2025

### Added

- Auto-start scheduling with cron (07:00 weekdays)
- Service control buttons in LuCI (start/stop/restart)

## [2.0] - 2025

### Added

- Initial release of luci-app-zzz with zzz 802.1X client
- LuCI CBI configuration interface
- zh-cn translation

[2.1.0]: https://github.com/Dichgrem/luci-app-zzz/compare/v2.0.2...v2.1.0
[2.0.2]: https://github.com/Dichgrem/luci-app-zzz/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/Dichgrem/luci-app-zzz/compare/v2.0...v2.0.1
[2.0]: https://github.com/Dichgrem/luci-app-zzz/releases/tag/v2.0