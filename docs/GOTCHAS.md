# Gotchas and open work

- Root apps/ is ignored; nested app history must be backed up independently. A throwaway root worktree does not preserve app sources. HelloCrown is in the durable main checkout by owner exception.
- ADB may list IP and mDNS aliases for one device. Selection checks each crown row against the device serial from config/device.local.json before choosing an alias. Two different crown devices are refused.
- **Wake/unlock before launch.** This device was Dozing while its panel still reported ON. am start -W initially timed out after 30s. Scripts now reject non-Awake power state; wake via normal device controls (or KEYCODE_WAKEUP and dismiss a non-secure keyguard), never bypass credentials. Sample keeps screen awake only while its activity is visible. No persistent timeout setting is changed.
- Probe automation cold-starts each action (`am start -S`) because warm launch extras did not produce a completion file in this session. Cold starts are verified. Camera waits for SurfaceHolder creation before opening; initial capture reproduced `Preview surface not ready`.
- Save Kotlin/source as UTF-8 explicitly: Windows PowerShell 5 Set-Content defaults can damage non-ASCII text. The sample uses ASCII separators and both repos declare UTF-8 in .editorconfig.
- PowerShell 5 redirects native binary output as text: use the shared BaseStream helper for JPEG/PNG/PCM. Package lists and media stay ignored; Wi-Fi names and MACs are stripped before saving radio evidence.
- Android 11/API30, ARMv7-only and no GMS are hard constraints. New target SDK alone does not grant newer runtime APIs. Check all native/transitive dependencies.
- Thermal sysfs includes negative/unusable readings; record raw values rather than treating every number as a real temperature. AC-powered device reports battery 100%/0 temperature; that is not evidence of a physical battery.
- ADB versions match today; mixing future versions can restart the server. Leave the pre-existing server running.
- No root build existed initially. Root gate is PowerShell parsing + focused regression tests + six command dry runs + dk check + git diff --check. Sample gate is assembleDebug + three unit tests. Android deprecation warnings are expected for legacy Camera/immersive API on API30.
- Reference-doc drift noticed: Moonlight Peaks README still says flat src files while its CLAUDE/STRUCTURE require responsibility folders. This kit follows the declared container model, not that stale README sentence; unrelated repo untouched.

## Open items

Use `dk list` / `dk show`; change docs/items only through dk. Auto-reconnect/power cycle (dk-237e5916), elevated ADB access (dk-18c5855d), real soak (dk-77bbeecb), owner audible/visual confirmations (dk-db907df9), HA client installation (dk-8e629a69), and Bluetooth discovery feasibility (dk-3a1ea81f) remain open. None is implicitly authorized by a routine app fast gate.
