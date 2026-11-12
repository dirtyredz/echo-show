# Capability ledger

Observed 2026-11-12 on crown. PASS means only the stated automated check passed. No physical perception is inferred from an API return value. Private evidence lives in the ignored `.tmp/device-kit-evidence/` folder of this repo.

| Capability | Method | Result | Evidence summary |
|---|---|---|---|
| Paired wireless ADB | mDNS discovery, TLS connect, boot/property query | PASS | live IP:port from mDNS; boot_completed=1; expected crown Lineage build; serial verified |
| Wi-Fi | cmd wifi status, connected transport | PASS | 5220 MHz, RSSI -35 dBm, reported link 780 Mbps at final probe; not a throughput benchmark; SSID/MAC redacted |
| Build/install/launch | Gradle fast gate, install-run, am start -W | PASS | APK installed; cold launch Status: ok, 879 ms on verified camera-probe build; screenshot captured |
| Speaker | ToneGenerator 1.5 s tone, finally release/restore | PASS | Owner confirmed the tone was audible on 2026-11-12. Playback started cleanly; original music volume 5 restored; host dumpsys confirms 5. Owner must confirm audible output |
| Microphone signal | AudioRecord 3 s, pull PCM, independent host RMS | PASS | 96,000 bytes, PCM16LE mono 16 kHz, 48,000 samples; RMS 1773.9784, peak 17074; signal present; owner confirmed the mic test worked on 2026-11-12 |
| Camera capture | SurfaceHolder-ready preview, Camera JPEG, host decode/pixel samples | PASS | Valid 1600x1200 JPEG, 209,848 bytes; host mean RGB 4.5504/255, non-zero but very dark. Owner confirmed the camera test worked on 2026-11-12 |
| Bluetooth adapter | Filtered dumpsys bluetooth_manager | PASS | Enabled=true, state=ON before and after; unchanged |
| Bluetooth enable/scan feasibility | cmd bluetooth_manager help plus dumpsys | UNTESTED | Help returned no command guidance (exit 0, empty output). Adapter already on; no toggle, scan or pairing attempted without supported reversible interface |
| Short monitor | soak.ps1 -Samples 2 -IntervalMinutes 0.02 | PASS | Both samples reachable; uptime, MemAvailable, load, raw thermal, AC/battery fields and Wi-Fi enabled recorded |
| Prolonged operation | Real soak | UNTESTED | Only two short samples; no stability conclusion |
| Power-cycle reconnect | No power cycle permitted | UNTESTED | Pairing persistence and automatic reconnect remain open |
| Elevated shell | id only | UNTESTED | UID 2000 confirmed; adb root not attempted |
| Home Assistant | Package inventory | UNTESTED | Companion not installed; options only in HOME-ASSISTANT |

Evidence set (under `.tmp/device-kit-evidence/`): `capabilities-20261112-095631-273/` contains speaker/mic/camera results, mic.pcm, camera.jpg, host-validation.txt, redacted radio summaries and screenshot.png. That first screenshot includes Android's immersive tutorial; final clean UI evidence is `.tmp/hello-crown-final.png`. Raw media stays private. Inventory: `.tmp/inventory-20261112-094651-369/`. Latest monitor smoke: `.tmp/soak-20261112-095754-850/samples.csv`.

Initial failures were retained locally: sleeping device caused launch timeout and missing speaker completion; camera initially failed `Preview surface not ready`. Awake preflight, activity-scoped keep-screen-on, cold probe starts and a SurfaceHolder latch fixed these; final media run passed. No reboot/system changes. Probe permissions restored to denied, music volume 5, Bluetooth ON unchanged, sample force-stopped and prior Settings/sleep state restored after evidence collection. Owner confirmed speaker, mic and camera on hardware on 2026-11-12.
