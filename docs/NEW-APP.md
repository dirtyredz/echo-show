# New app

Run `scripts/apps/new-app.ps1 -Name MyPanel -DryRun` from any directory, then omit DryRun to create it. Names are ASCII letters/digits starting with a letter. The script copies versioned HelloCrown files, renames package `dev.crown.hellocrown` to `dev.crown.mypanel`, retains minSdk 24 / target 36 / ARMv7 filter, creates an independent repo on main with an initial commit, and adds a root README row. It never copies build output, local.properties, recordings, Git history or the sample-specific TESTING.md verification record. Existing destinations are refused.

The template is `apps/HelloCrown` in the current root or the main checkout reported by git worktree list. Restore that nested repo if absent. A worktree scaffold lands under that worktree's ignored apps folder: create lasting apps in a durable root checkout, or move/clone their independent repo before retiring the worktree. HelloCrown itself lives in the durable main checkout by owner ruling.

After scaffolding, work in the innermost repo. Read its CLAUDE plus root device docs. Replace the sample UI/probes as appropriate, audit every dependency for no-GMS and ARMv7 compatibility, then run its fast gate and the root install-run command with the new package/activity. The shared capability runner targets HelloCrown intentionally, not arbitrary new apps. Remove unnecessary camera/mic permissions when removing probes. Commit app changes independently and root index changes separately. Never add apps as root submodules.

Scaffolding was smoke-tested with DryRun only; creation is covered by inspection, not an end-to-end second app build.
