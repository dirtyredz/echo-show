<# Shared ADB selection, bounded execution and evidence transport. Dot-source only. #>
. (Join-Path $PSScriptRoot 'owner-run.ps1')
function Start-DeviceRun([string]$Name, [switch]$WithoutAdb) {
    Initialize-OwnerRun $Name
    $script:LogFile = Join-Path $script:RepoRoot ('.tmp/owner-runs/{0}-{1}-{2}.log' -f (Get-Date -Format yyyyMMdd-HHmmss-fff),$Name,$PID)
    if (-not $WithoutAdb) { $script:Adb = Resolve-Adb; Write-Log "ADB: $script:Adb" }
}
function Get-DeviceConfig {
    # Device-specific values live in git-ignored config/device.local.json (template: config/device.example.json).
    $path = Join-Path $script:RepoRoot 'config/device.local.json'
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing $path. Copy config/device.example.json to config/device.local.json and set your device serial (see docs/CONNECTION.md)."
    }
    $config = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    if (-not $config.serial -or $config.serial -match '^YOUR_') { throw "config/device.local.json must set a real 'serial'." }
    return $config
}
function Resolve-Adb {
    $paths = @()
    $local = Join-Path $script:RepoRoot 'config/device.local.json'
    if (Test-Path -LiteralPath $local) { $override = (Get-Content -LiteralPath $local -Raw | ConvertFrom-Json).adbPath; if ($override) { $paths += $override } }
    if ($env:ANDROID_HOME) { $paths += Join-Path $env:ANDROID_HOME 'platform-tools/adb.exe' }
    $paths += "$env:LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe"
    foreach ($p in $paths) { if (Test-Path -LiteralPath $p) { return $p } }
    throw 'ADB missing: install platform-tools separately; no automatic downloads.'
}
function Invoke-Adb([string[]]$Arguments, [string]$BinaryPath, [int]$TimeoutSeconds = 30) {
    # Arguments originate in fixed commands or validated identifiers. Quote Windows argv safely.
    $quoted = foreach ($a in $Arguments) { '"' + ($a -replace '(\\*)"','$1$1\"' -replace '(\\+)$','$1$1') + '"' }
    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = $script:Adb
    $psi.Arguments = $quoted -join ' '
    $psi.UseShellExecute = $false; $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true
    $p = New-Object Diagnostics.Process; $p.StartInfo = $psi
    $stream = $null
    try {
        [void]$p.Start()
        $err = $p.StandardError.ReadToEndAsync()
        if ($BinaryPath) {
            $stream = [IO.File]::Create($BinaryPath)
            $out = $p.StandardOutput.BaseStream.CopyToAsync($stream)
        } else { $out = $p.StandardOutput.ReadToEndAsync() }
        if (-not $p.WaitForExit($TimeoutSeconds * 1000)) { $p.Kill(); $p.WaitForExit(); throw "ADB timed out after $TimeoutSeconds seconds" }
        $out.GetAwaiter().GetResult() | ForEach-Object { $result = $_ }
        $errorText = $err.GetAwaiter().GetResult()
        if ($p.ExitCode -ne 0) { throw "ADB exit $($p.ExitCode): $errorText $result" }
        if (-not $BinaryPath) { return [string]$result }
    } finally { if ($stream) { $stream.Dispose() }; $p.Dispose() }
}
function Select-Crown {
    $lines = Invoke-Adb @('devices','-l')
    $found = @($lines -split "`n" | Where-Object { $_ -match '\sdevice\s.*device:crown(?:\s|$)' })
    if ($found.Count -eq 0) { throw 'No online crown. Run connect.ps1 first.' }
    $expected = [string](Get-DeviceConfig).serial
    $targets = @($found | ForEach-Object { ($_ -split '\s+')[0] } | Sort-Object)
    foreach ($target in $targets) {
        $serial = (Invoke-Adb @('-s',$target,'shell','getprop','ro.serialno')).Trim()
        if ($serial -ne $expected) { throw "Unexpected crown serial: $serial; refusing ambiguous device selection." }
    }
    $script:Target = $targets[0]
    Write-Log "Target: $script:Target"
}
function Invoke-Crown([string[]]$Command, [string]$BinaryPath) {
    Invoke-Adb (@('-s',$script:Target) + $Command) -BinaryPath $BinaryPath
}
function New-EvidenceDirectory([string]$Name) {
    $path = Join-Path $script:RepoRoot ('.tmp/{0}-{1}' -f $Name,(Get-Date -Format yyyyMMdd-HHmmss-fff))
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    Write-Log "Evidence: $path"
    return $path
}

function Protect-WifiStatus([string]$Status) {
    $lines = $Status -split "`r?`n" | Where-Object { $_ -match '^Wifi is enabled|^Wifi is disabled|^Wifi scanning|^WifiInfo:' }
    return (($lines -join "`n") -replace 'SSID:.*?BSSID:', 'SSID: [REDACTED], BSSID:' -replace '(?i)([0-9a-f]{2}:){5}[0-9a-f]{2}','[REDACTED]')
}
function Assert-DeviceAwake {
    $power = Invoke-Crown @('shell','dumpsys','power')
    if ($power -notmatch 'mWakefulness=Awake') { throw 'Wake and unlock the device before launching or probing; no settings changed.' }
}
