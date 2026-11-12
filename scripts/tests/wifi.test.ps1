$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../device/device-session.ps1"
$sample = 'Wifi is connected to "PrivateNetwork"' + "`n" + 'WifiInfo: SSID: "PrivateNetwork", BSSID: 12:34:56:78:90:ab, MAC: 12:34:56:78:90:ab, RSSI: -33, Link speed: 866Mbps, Frequency: 5220MHz'
$result = Protect-WifiStatus $sample
if ($result -match 'PrivateNetwork|12:34:56:78:90:ab') { throw 'Radio identity leaked' }
if ($result -notmatch 'RSSI: -33') { throw 'Useful signal data lost' }
Write-Host 'PASS Wi-Fi identity redaction'
