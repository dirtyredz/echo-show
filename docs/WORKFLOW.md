# Build, install, debug

## Choose the toolchain per app

Read that app's wrapper version, AGP and Kotlin plugin pins before choosing a JDK. Do not assume the newest Java matches an old Gradle build. This machine has Microsoft OpenJDK 21 at `C:\Program Files\Microsoft\jdk-21.0.13.21-hotspot` and Android SDK at `%LOCALAPPDATA%\Android\Sdk` (platform 36, build-tools 35.0.0). Set environment for the current command/process only; never machine/user settings. No SDK installs are automated.

HelloCrown pins Gradle 8.13, AGP 8.13.2, Kotlin 2.3.21, compile/target 36, minSdk 24, Java/Kotlin bytecode 17. See DECISIONS. Its durable repo is `<repo>/apps/HelloCrown`.

```powershell
# In the app repo; first inspect Win32_Process for other Java/Gradle builds.
$env:JAVA_HOME='C:\Program Files\Microsoft\jdk-21.0.13.21-hotspot'
$env:ANDROID_HOME="$env:LOCALAPPDATA\Android\Sdk"
$env:ANDROID_SDK_ROOT=$env:ANDROID_HOME
./gradlew.bat --no-daemon assembleDebug testDebugUnitTest
```

This is the sample fast gate, not a full test tier. Gradle wrapper and Maven dependencies may need authorized downloads on a fresh machine; do not automatically install SDK components. Do not overlap another build. APK: `app/build/outputs/apk/debug/app-debug.apk`. Debug signing is local and not a release distribution process.

## Install and launch

Wake and unlock the device first. The script checks Awake state; the sample keeps the display awake while visible. The panel can report ON even when the device is Dozing. Restore its previous sleep state after testing.

```powershell
# Invoke these via absolute paths if outside the root repo.
./scripts/device/connect.ps1
./scripts/device/install-run.ps1 -Apk '<repo>\apps\HelloCrown\app\build\outputs\apk\debug\app-debug.apk' -Activity 'dev.crown.hellocrown/.MainActivity' -LogTag HelloCrown
./scripts/device/check-capabilities.ps1
./scripts/device/soak.ps1 -Samples 2 -IntervalMinutes 0.02
```

Install-run uses `adb install -r`, `am start -W`, optional bounded `logcat -d -t 200 Tag:I *:S`. Use explicit component names, API guards, runtime permission checks. For debugging inspect app logs, `dumpsys activity activities`, and crash buffer with the explicitly selected `-s` transport. Avoid dumping unrelated personal data into tracked files.

Capability runner retrieves private probe files using `exec-out run-as`, and a PNG with `exec-out screencap -p`. Windows PowerShell 5 text redirection corrupts binary output: the shared transport copies BaseStream directly. Evidence stays in `.tmp/`; do not commit it. HelloCrown buttons request permissions on demand; test again after granting. Automated probes grant camera/mic access temporarily.

Stop app probes with `adb -s <transport> shell am force-stop dev.crown.hellocrown`. Stop your Gradle processes with `./gradlew.bat --stop`; retain a pre-existing ADB server. Do not run real soaks, reboot tests, or release builds as part of this gate.
