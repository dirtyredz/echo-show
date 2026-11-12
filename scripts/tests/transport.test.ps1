# Offline regression: an explicit connect can add an IP transport beside the mDNS transport.
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../device/device-session.ps1"
function Get-DeviceConfig { [pscustomobject]@{ serial = 'TESTSERIAL000000' } }
function Write-Log([string]$Message) { }
function Invoke-Adb([string[]]$Arguments) {
    if ($Arguments[0] -eq 'devices') { return "List of devices attached`n10.0.0.2:5555 device product:lineage_crown model:Echo_Show_8 device:crown`nadb-TESTSERIAL000000-abc123._adb-tls-connect._tcp device product:lineage_crown model:Echo_Show_8 device:crown" }
    return 'TESTSERIAL000000'
}
Select-Crown
if ($script:Target -ne '10.0.0.2:5555') { throw 'Did not select the IP alias for the same physical crown' }
Write-Host 'PASS duplicate transport regression'
