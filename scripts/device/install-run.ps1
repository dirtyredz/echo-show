<#
.SYNOPSIS
Install a debug APK, launch a component and optionally collect bounded tag-filtered logcat.
.PARAMETER Apk
Absolute APK path (relative paths resolve from the repo root).
.PARAMETER Activity
Explicit package/activity component.
.PARAMETER LogTag
Optional single logcat tag; collects existing buffer then exits.
.PARAMETER DryRun
Only log the plan. Exit 0 success, 1 failure.
#>
[CmdletBinding()] param([string]$Apk,[string]$Activity,[string]$LogTag,[switch]$DryRun)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/device-session.ps1"
try {
    Start-DeviceRun 'install-run'
    if ($Activity -notmatch '^[A-Za-z][\w.]*/[A-Za-z.][\w.]*$') { throw 'Supply a package/activity component.' }
    if (-not $Apk) { throw 'Supply -Apk.' }
    if (-not [IO.Path]::IsPathRooted($Apk)) { $Apk = Join-Path $script:RepoRoot $Apk }
    if ($LogTag -and $LogTag -notmatch '^\w+$') { throw 'LogTag must be a single alphanumeric tag.' }
    if ($DryRun) { Write-Log "DRY RUN: install $Apk; launch $Activity; optional log tag $LogTag" }
    else {
        if (-not (Test-Path -LiteralPath $Apk -PathType Leaf)) { throw "APK missing: $Apk" }
        Select-Crown
        Assert-DeviceAwake
        Write-Log (Invoke-Crown @('install','-r',$Apk))
        $launch = Invoke-Crown @('shell','am','start','-W','-n',$Activity)
        Write-Log $launch
        if ($launch -match 'Error:|Exception') { throw 'Activity launch failed.' }
        if ($LogTag) { Write-Log (Invoke-Crown @('logcat','-d','-t','200',"${LogTag}:I",'*:S')) }
    }
    Complete-OwnerRun 0
} catch { Complete-OwnerRun 1 $_.Exception.Message }
