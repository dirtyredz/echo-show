# Structure

Root is shared device knowledge and tooling; `apps/` contains separately committed repositories and is ignored. A root worktree need not contain app checkouts.

## Layout
- `docs/` — inventory, connection, workflow, capabilities and living decisions.
- `docs/items/` — Docket-managed follow-up work.
- `scripts/device/` — ADB operations, monitoring, shared device functions and verbatim owner-run template 1.0.0 from ~/.claude/templates/scripts.
- `scripts/apps/` — nested app scaffolding.
- `scripts/tests/` — cheap offline PowerShell gate.
- `apps/<Name>/` — independent Android repositories (ignored).
- `.tmp/` — ignored logs, inventory, media evidence and handoff.

App layout: Gradle configuration/wrapper at app repo root; Android manifest and Kotlin source in app/src/main, tests in app/src/test. Root scripts never sweep nested repositories. README is the app index.
