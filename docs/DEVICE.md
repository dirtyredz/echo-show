# Device inventory

Snapshot: 2026-11-12. This describes the current device only. Owner facts are distinguished from ADB observations.

| Item | Current state | Evidence |
|---|---|---|
| Hardware | Amazon Echo Show 8, 1st gen (2019), crown | Owner; ADB model/device confirmed |
| Serial | in git-ignored config/device.local.json | ADB confirmed |
| SoC / nominal memory | MediaTek MT8163; 2 GB RAM; 8 GB eMMC | Owner; ADB board platform / meminfo |
| Visible RAM | 1,933,380 kB MemTotal | /proc/meminfo |
| Data storage | 3.7 GB total, 563 MB used, 3.0 GB available before sample | df -h /data; varies with apps |
| Display | 1280x800, 213 dpi | wm size / wm density |
| OS | Unofficial LineageOS 18.1 release v0.7; build 18.1-20261101-UNOFFICIAL-crown | Release v0.7 owner-provided; build ADB confirmed |
| Android / security patch | Android 11 / API 30; 2024-02-05 | ADB |
| CPU ABIs | armeabi-v7a, armeabi (32-bit only) | ro.product.cpu.abilist |
| Build / SELinux | userdebug, test-keys; Permissive | ADB |
| Recovery | TWRP 3.7.0_9-0 | Owner; recovery not booted/tested |
| Google services | No Play Store or Google Play services | Owner and package inventory |
| Shell | UID 2000; elevated access UNTESTED | id; adb root deliberately not run |
| Radios / media | Wi-Fi and wireless ADB working; audio inputs/outputs and one camera exposed | Owner plus capability evidence |

Device-specific ROM/source configuration is available from its maintainers (owner fact; no external lookup in this task). No discrepancies observed in the rechecked inventory. Inventory evidence: `.tmp/inventory-20261112-094651-369/inventory.txt`; package listing stays local.

App constraints: minSdk <=30, ARMv7 for all native dependencies, no GMS assumption. Modern compile/target SDK is fine only with API/version guards and runtime permission handling. Treat this as a resource-constrained tablet-sized display, not a phone or 64-bit Android target.
