<#
.SYNOPSIS
Save allowlisted device properties and inventory to timestamped .tmp evidence.
.PARAMETER DryRun
Only log the plan. Exit 0 success, 1 failure.
#>
[CmdletBinding()] param([switch]$DryRun)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/device-session.ps1"
try {
    Start-DeviceRun 'inventory'
    if ($DryRun) { Write-Log 'DRY RUN: collect device inventory (no account or Wi-Fi credentials).' }
    else {
        Select-Crown
        $dir = New-EvidenceDirectory 'inventory'
        $commands = @('getprop ro.product.model; getprop ro.product.device; getprop ro.serialno; getprop ro.board.platform; getprop ro.lineage.version; getprop ro.build.version.sdk; getprop ro.build.version.security_patch; getprop ro.build.type; getprop ro.build.tags; getprop ro.product.cpu.abilist','df -h /data','cat /proc/meminfo','wm size; wm density','getenforce; id','pm list packages')
        foreach ($c in $commands) { Add-Content "$dir/inventory.txt" "$c`n$(Invoke-Crown @('shell',$c))" }
        Write-Log "Inventory saved: $dir/inventory.txt (package list stays local)."
    }
    Complete-OwnerRun 0
} catch { Complete-OwnerRun 1 $_.Exception.Message }
