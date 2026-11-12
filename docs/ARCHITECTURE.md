# Architecture

PowerShell entry points dot-source device-session.ps1, which extends the verbatim owner-run logging template. ADB resolution prefers ANDROID_HOME, then the local SDK, then the owner fallback. Every device operation selects the crown serial explicitly; discovery never chooses another device. Text probes are bounded child processes; binary evidence uses direct stream copies, never Windows PowerShell text redirection.

HelloCrown is an independent Kotlin Android app. A foreground activity presents device information and runs explicit tone, AudioRecord and camera probes on demand. Evidence stays in its private files directory and is retrieved with run-as. No network permissions or native dependencies are needed. Root scripts orchestrate the installed debug app; they do not contain its source.

New-app copies only versioned HelloCrown source, renames package/display name, initializes independent history, and adds a README index row. It does not copy .git, local SDK configuration or build outputs.
