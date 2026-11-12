# Working here

This is a container repo. Work on an app = the **innermost repo** under `apps/<Name>`; device constraints and workflow live in the root docs. Root tracks shared scripts/docs and the README app index; apps are independent, ignored repositories. No skill is required: Claude Code reads parent instructions.

Read STRUCTURE.md, docs/GOTCHAS.md, then docs/DEVICE.md, CONNECTION.md and WORKFLOW.md. Flow changes also require ARCHITECTURE.md and DECISIONS.md. Scope searches with `git ls-files --cached --others --exclude-standard`.

## App checklist
- Android 11/API 30: minSdk <=30 (default 24); compile/target 36 with compatibility handling.
- 32-bit ARM only: include armeabi-v7a for native dependencies. Sample has no native code.
- No GMS/Play Store: avoid dependencies on Google services.
- Landscape 1280x800, 213 dpi; use density-independent layout and verify on hardware.
- Rediscover with scripts/device/connect.ps1; install with install-run.ps1 -Apk <absolute-path> -Activity <package/.Activity>.
- Inspect each app's AGP/Gradle requirements before choosing JDK. Never change global environment.
- No reboot, remount, system partition writes or Bluetooth pairing. Restore temporary probe state.

## Fast gate
Root: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/fast-gate.ps1`, then `dk check` and `git diff --check`. No root build/typecheck beyond PowerShell parsing. Sample: from its repo, set process JAVA_HOME to the installed Microsoft JDK 21 and ANDROID_HOME to the installed SDK, then `./gradlew.bat --no-daemon assembleDebug testDebugUnitTest`. Never run long suites or real soaks as a fast gate. Check running Java/Gradle processes before builds; stop your Gradle daemons afterward.

Work items live in docs/items and are changed through dk only. Run `docket guide` before writes, read before changes, close completed items and run `dk check`. Commit root work on its assigned branch; apps have independent history. Do not push or merge. Evidence and logs stay in ignored .tmp; never publish recordings or account data.
