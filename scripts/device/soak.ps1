<#
.SYNOPSIS
Sample device health into CSV. Default is only two samples, not a prolonged soak.
.PARAMETER IntervalMinutes
Minutes between samples; use 0.02 for a two-sample smoke test.
.PARAMETER Samples
Finite sample count. Real prolonged operation is owner-scheduled work.
.PARAMETER DryRun
Only log the plan. Exit 0 all samples reachable, 1 failure (CSV retained).
#>
[CmdletBinding()] param([ValidateRange(0.01,1440)][double]$IntervalMinutes=1,[ValidateRange(2,10080)][int]$Samples=2,[switch]$DryRun)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/device-session.ps1"
try {
    Start-DeviceRun 'soak'
    if ($DryRun) { Write-Log "DRY RUN: $Samples samples at $IntervalMinutes minute intervals." }
    else {
        Select-Crown
        $dir = New-EvidenceDirectory 'soak'
        $failed = $false
        for ($n=0; $n -lt $Samples; $n++) {
            $row = [ordered]@{Time=(Get-Date).ToString('o');Reachable=$false;Uptime='';Memory='';Load='';Thermal='';Battery='';Wifi='';Error=''}
            try {
                $row.Uptime = (Invoke-Crown @('shell','cat /proc/uptime')).Trim()
                $row.Memory = (Invoke-Crown @('shell',"grep -E 'MemTotal|MemAvailable' /proc/meminfo")).Trim() -replace "`r?`n",'; '
                $row.Load = (Invoke-Crown @('shell','cat /proc/loadavg')).Trim()
                $row.Thermal = (Invoke-Crown @('shell','for f in /sys/class/thermal/thermal_zone*/temp; do if [ -r "$f" ]; then cat "$f"; fi; done')).Trim() -replace "`r?`n",'; '
                $battery = Invoke-Crown @('shell','dumpsys battery')
                $row.Battery = ($battery -split "`n" | Where-Object { $_ -match 'level:|temperature:|powered:' }) -join '; '
                $wifi = Invoke-Crown @('shell','cmd wifi status')
                $row.Wifi = ($wifi -split "`n" | Where-Object { $_ -match '^(Wifi|Wi-Fi) is (enabled|disabled)\s*$' }) -join '; '
                $row.Reachable = $true
            } catch { $row.Error = $_.Exception.Message; $failed=$true }
            [pscustomobject]$row | Export-Csv "$dir/samples.csv" -NoTypeInformation -Append
            Write-Log "Sample $($n+1)/$Samples reachable=$($row.Reachable)"
            if ($n -lt $Samples-1) { Start-Sleep -Milliseconds ([int]($IntervalMinutes*60000)) }
        }
        if ($failed) { throw 'One or more samples unreachable; inspect CSV.' }
    }
    Complete-OwnerRun 0
} catch { Complete-OwnerRun 1 $_.Exception.Message }
