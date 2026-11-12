# Home Assistant alongside your apps

Planning options only; **nothing installed** and no HA server/account configured during this task.

| Option | Fit | What to verify first |
|---|---|---|
| Companion minimal / F-Droid flavor | Native HA client without a Google Play services dependency | Obtain the official minimal build via the owner's chosen trusted source; minSdk <=30 and armeabi-v7a if native libraries are included. GMS-dependent features/push behavior differ; verify the chosen release's documentation. |
| WebView/kiosk dashboard | A focused tablet dashboard can coexist with custom apps | HA server URL, authentication, local TLS trust, installed WebView compatibility, screen sleep and navigation behavior. Do not store tokens in source or logs. |
| Launcher replacement | Choose between HA and custom apps on the home screen | Test a normal launcher install first, retain an accessible route to Settings and the existing launcher; changing the default launcher needs a separate owner decision. |

Sideload an owner-supplied APK with `scripts/device/install-run.ps1 -Apk <absolute-apk> -Activity <documented-component>`. Determine the actual package/activity from that APK; do not guess a component or install a Play-dependent flavor. Downloading or installing HA is separate follow-up work. Do not remove system apps, change system partitions, or assume a replacement launcher is necessary for coexistence.

No current release/version/source was fetched for this options map because network permission for this task covers only the sample's build dependencies. Recheck official HA distribution instructions when that installation is authorized.
