<#
.SYNOPSIS
Rediscover the paired crown, connect and verify boot and Lineage version.
.PARAMETER DryRun
Log the plan without invoking ADB. Exit 0 success, 1 failure.
#>
[CmdletBinding()] param([switch]$DryRun)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/device-session.ps1"
try {
    Start-DeviceRun 'connect'
    if ($DryRun) { Write-Log 'DRY RUN: discover crown TLS mDNS, connect, verify boot and OS.' }
    else {
        $serial = [regex]::Escape([string](Get-DeviceConfig).serial)
        $services = Invoke-Adb @('mdns','services')
        $matchesFound = @([regex]::Matches($services,"(?m)^adb-${serial}[^\s]*\s+_adb-tls-connect\._tcp\.?\s+(\d+\.\d+\.\d+\.\d+:\d+)"))
        if ($matchesFound.Count -ne 1) { throw 'No unique paired TLS crown service. Check Wireless debugging; re-pair interactively if needed.' }
        $endpoint = $matchesFound[0].Groups[1].Value
        Write-Log (Invoke-Adb @('connect',$endpoint))
        $script:Target = $endpoint
        $boot = (Invoke-Crown @('shell','getprop','sys.boot_completed')).Trim()
        $os = (Invoke-Crown @('shell','getprop','ro.lineage.version')).Trim()
        if ($boot -ne '1' -or $os -notmatch 'crown') { throw "Unexpected boot/OS: $boot / $os" }
        Write-Log "Live endpoint: $endpoint; boot_completed=$boot; Lineage=$os"
    }
    Complete-OwnerRun 0
} catch { Complete-OwnerRun 1 $_.Exception.Message }
