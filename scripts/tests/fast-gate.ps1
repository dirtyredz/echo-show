<#
.SYNOPSIS
Offline fast gate: parse scripts, regression tests, owner command dry runs from an unrelated cwd.
#>
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path "$PSScriptRoot/../..").Path
$files = Get-ChildItem "$root/scripts" -Recurse -Filter *.ps1
foreach ($file in $files) {
    $tokens = $null; $errors = $null
    [void][Management.Automation.Language.Parser]::ParseFile($file.FullName,[ref]$tokens,[ref]$errors)
    if ($errors.Count) { throw "$($file.Name): $errors" }
}
& powershell -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot/transport.test.ps1"
if ($LASTEXITCODE) { throw 'Transport tests failed' }
& powershell -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot/wifi.test.ps1"
if ($LASTEXITCODE) { throw 'Wi-Fi redaction tests failed' }
& powershell -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot/awake.test.ps1"
if ($LASTEXITCODE) { throw 'Awake tests failed' }
$cases = @(
    @{Path='device/connect.ps1'; Args=@()},
    @{Path='device/inventory.ps1'; Args=@()},
    @{Path='device/install-run.ps1'; Args=@('-Apk','missing.apk','-Activity','dev.crown.hellocrown/.MainActivity')},
    @{Path='device/check-capabilities.ps1'; Args=@()},
    @{Path='device/soak.ps1'; Args=@('-Samples','2','-IntervalMinutes','0.02')},
    @{Path='apps/new-app.ps1'; Args=@('-Name','GateSample')}
)
$before = [IO.File]::ReadAllText("$root/README.md")
Push-Location $env:SystemRoot
try {
    foreach ($case in $cases) {
        $argsForCase = $case.Args
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File "$root/scripts/$($case.Path)" -DryRun @argsForCase 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Dry run failed: $($case.Path)`n$output" }
        $final = [string]($output | Select-Object -Last 1)
        if ($final -notmatch '^OK \(exit 0\) log: (.+)$') { throw "Missing final status: $final" }
        $log = $Matches[1]
        if (-not $log.StartsWith("$root\.tmp\owner-runs\") -or -not (Test-Path -LiteralPath $log)) { throw "Bad log path: $log" }
        Write-Host "PASS $($case.Path) DryRun from $env:SystemRoot"
    }
} finally { Pop-Location }
if (Test-Path "$root/apps/GateSample") { throw 'DryRun created app' }
if ($before -cne [IO.File]::ReadAllText("$root/README.md")) { throw 'DryRun changed README' }
. "$root/scripts/device/owner-run.ps1"
Add-LogSecret 'test-sensitive-code'
if ((Hide-Secrets 'value=test-sensitive-code') -ne 'value=[REDACTED]') { throw 'Redaction failed' }
Write-Host "PASS parsed $($files.Count) scripts; regression, six dry runs, no app/index mutations, secret redaction."
# Publication guard: tracked files must not contain the local device serial or LAN addresses.
$tracked = @(& git -C $root ls-files)
$patterns = @('\b192\.168\.\d+\.\d+')
$localCfg = "$root/config/device.local.json"
if (Test-Path $localCfg) { $s = (Get-Content $localCfg -Raw | ConvertFrom-Json).serial; if ($s) { $patterns += [regex]::Escape($s) } }
foreach ($f in $tracked) {
    if ($f -eq 'scripts/tests/fast-gate.ps1' -or -not (Test-Path -LiteralPath "$root/$f")) { continue }
    $hit = Select-String -LiteralPath "$root/$f" -Pattern $patterns | Select-Object -First 1
    if ($hit) { throw "Publication guard: $f line $($hit.LineNumber) contains a device serial or LAN address." }
}
Write-Host 'PASS publication guard'
