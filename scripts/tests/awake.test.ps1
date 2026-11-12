$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../device/device-session.ps1"
$script:fakePower = 'mWakefulness=Dozing'
function Invoke-Crown([string[]]$Command) { return $script:fakePower }
$rejected = $false
try { Assert-DeviceAwake } catch { $rejected = $_.Exception.Message -match 'Wake and unlock' }
if (-not $rejected) { throw 'Sleeping device was not rejected with actionable guidance' }
$script:fakePower = 'mWakefulness=Awake'
Assert-DeviceAwake
Write-Host 'PASS awake prerequisite'
