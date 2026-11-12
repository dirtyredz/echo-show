# Connection

Use the SDK ADB consistently. Scripts resolve the optional `adbPath` in `config/device.local.json` first, then ANDROID_HOME/platform-tools, then `%LOCALAPPDATA%/Android/Sdk/platform-tools/adb.exe`. The SDK binary reported **37.0.1-15733141 / protocol 1.0.41** on 2026-11-12; no mismatch observed. Different client/server versions can restart each other's server, so do not mix versions.


## Local device config

Device-specific values never live in tracked files. Copy `config/device.example.json` to `config/device.local.json` (git-ignored) and set `serial` (the device serial from Settings or `adb devices`); optional `adbPath` overrides ADB resolution. Scripts that select a device fail with a message pointing here when the file is missing. Dry runs do not need it.

## Rediscover, connect, verify

```powershell
./scripts/device/connect.ps1 -DryRun
./scripts/device/connect.ps1
```

The script runs `adb mdns services`, selects this serial's `_adb-tls-connect._tcp` service, connects to its live IP:port, then requires boot_completed=1 and a crown Lineage version. Services look like `adb-<serial>-<suffix>._adb-tls-connect._tcp`. Do not hardcode this endpoint; IP and port can change. A legacy `_adb._tcp` advertisement also exists on port 5555; scripts use paired TLS.

Valhalla was already paired. To re-pair only if needed: on the device open Settings > Developer options > Wireless debugging > Pair device with pairing code. Use the fresh pairing IP:port in `adb pair <IP:pairing-port>` and type the temporary code at the prompt (never pass it in scripts or save it in logs). Pairing port differs from connection port. Then rediscover/connect. No pairing was performed during this task.

## Troubleshooting

- No mDNS service: check same reachable LAN and Wireless debugging state; do not reboot or reset as a troubleshooting shortcut. Refresh discovery. A stale pairing code cannot be reused.
- Unauthorized/offline: inspect `adb devices -l`, refresh device pairing UI when needed; use the selected SDK client. Never kill a pre-existing ADB server casually.
- Duplicate mDNS/IP rows can refer to the same hardware after explicit connect. Scripts verify ro.serialno for every crown row and select one alias. Any other crown serial causes refusal.
- Every operation uses `-s`; never rely on the only-device default once aliases or other devices exist.
- Auto-reconnect after power loss is UNTESTED; no power cycle was performed.

No machine/user environment is edited. Logs are in .tmp/owner-runs and contain no pairing codes. ADB server was already running and is intentionally retained.
