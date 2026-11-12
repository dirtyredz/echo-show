# Echo Show 8 device kit

Shared device docs and PowerShell tooling for the household Echo Show 8 (2019, `crown`), currently running LineageOS 18.1 / Android 11. Apps live here as **separate nested Git repositories**. Work on an app in its innermost repo; this root supplies device context.

Start with [device inventory](docs/DEVICE.md), [connection](docs/CONNECTION.md), [workflow](docs/WORKFLOW.md), and [capability results](docs/CAPABILITIES.md). [New app](docs/NEW-APP.md), [Home Assistant options](docs/HOME-ASSISTANT.md), [gotchas](docs/GOTCHAS.md), [decisions](docs/DECISIONS.md), [architecture](docs/ARCHITECTURE.md), [structure](STRUCTURE.md).

```powershell
./scripts/device/connect.ps1
./scripts/device/inventory.ps1
./scripts/apps/new-app.ps1 -Name MyPanel -DryRun
```

All owner commands run from any directory, support `-DryRun`, write redacted local logs and finish with OK/FAILED plus exit code and log path. Evidence is private, ignored `.tmp/` data. App sources are ignored by the root: clone/backup their independent histories separately. This root alone cannot restore an app.

## App index

HelloCrown's durable checkout is `<repo>/apps/HelloCrown`; linked root worktrees may have no `apps/` directory.

<!-- app-index -->
| App | Package | Status |
|---|---|---|
| [HelloCrown](apps/HelloCrown/README.md) | dev.crown.hellocrown | Device workflow and media probe sample; independent local repo |
