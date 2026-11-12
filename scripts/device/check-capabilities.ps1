<#
.SYNOPSIS
Run bounded HelloCrown media probes and read-only Bluetooth/Wi-Fi checks.
.DESCRIPTION
Requires installed HelloCrown. Does not pair or toggle Bluetooth. Leaves app installed, force-stops probes on failure.
.PARAMETER DryRun
Only log the plan. Exit 0 collection completed, 1 operational failure. Inspect each probe result separately.
#>
[CmdletBinding()] param([switch]$DryRun)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/device-session.ps1"
$started = $false; $revoke = @()
try {
    Start-DeviceRun 'check-capabilities'
    if ($DryRun) { Write-Log 'DRY RUN: read radio state; run speaker/mic/camera; pull private evidence and screenshot.' }
    else {
        Select-Crown
        Assert-DeviceAwake
        $dir = New-EvidenceDirectory 'capabilities'
        # Filter radio dumps before persisting: never store nearby device names, SSIDs or addresses.
        $bt = Invoke-Crown @('shell','dumpsys bluetooth_manager')
        ($bt -split "`n" | Where-Object { $_ -match '^\s*(enabled:|state:|Bluetooth Status|time since enabled:)' }) | Set-Content "$dir/bluetooth.txt"
        (Invoke-Crown @('shell','cmd bluetooth_manager help')) | Set-Content "$dir/bluetooth-command-help.txt"
        $wifi = Invoke-Crown @('shell','cmd wifi status')
        (Protect-WifiStatus $wifi) | Set-Content "$dir/wifi.txt"
        $package = 'dev.crown.hellocrown'
        $packageState = Invoke-Crown @('shell','dumpsys','package',$package)
        foreach ($permission in @('android.permission.RECORD_AUDIO','android.permission.CAMERA')) {
            if ($packageState -notmatch ([regex]::Escape($permission) + ': granted=true')) { $revoke += $permission }
            [void](Invoke-Crown @('shell','pm','grant',$package,$permission))
        }
        $started = $true
        foreach ($probe in @('speaker','mic','camera')) {
            [void](Invoke-Crown @('shell','run-as',$package,'rm','-f',"files/$probe.txt"))
            $launch = Invoke-Crown @('shell','am','start','-S','-W','-n',"$package/.MainActivity",'--es','probe',$probe)
            if ($launch -match 'Error:|Exception') { throw $launch }
            $result = $null
            for ($attempt = 0; $attempt -lt 25; $attempt++) {
                Start-Sleep -Seconds 1
                try { $result = Invoke-Crown @('shell','run-as',$package,'cat',"files/$probe.txt"); break } catch { }
            }
            if (-not $result) { throw "$probe did not complete within 25 seconds" }
            $result | Set-Content "$dir/$probe.txt"
            Write-Log "$probe : $result"
            if ($result -notmatch '^(PASS|NEEDS-OWNER-CONFIRM):') { throw "$probe reported failure: $result" }
        }
        Invoke-Crown @('exec-out','run-as',$package,'cat','files/mic.pcm') -BinaryPath "$dir/mic.pcm"
        Invoke-Crown @('exec-out','run-as',$package,'cat','files/camera.jpg') -BinaryPath "$dir/camera.jpg"
        Invoke-Crown @('exec-out','screencap','-p') -BinaryPath "$dir/screenshot.png"
        # Independently validate the pulled evidence, not only the app's report.
        $pcm = [IO.File]::ReadAllBytes("$dir/mic.pcm")
        if ($pcm.Length -ne 96000) { throw "Unexpected PCM size: $($pcm.Length)" }
        $sum = 0.0; $peak = 0
        for ($i = 0; $i -lt $pcm.Length; $i += 2) {
            $sample = [BitConverter]::ToInt16($pcm,$i)
            $sum += [double]$sample * $sample
            $peak = [Math]::Max($peak,[Math]::Abs([int]$sample))
        }
        $rms = [Math]::Sqrt($sum / ($pcm.Length / 2))
        Add-Type -AssemblyName System.Drawing
        $bitmap = New-Object Drawing.Bitmap "$dir/camera.jpg"
        try {
            $total = 0.0; $count = 0
            for ($y = 0; $y -lt $bitmap.Height; $y += 10) {
                for ($x = 0; $x -lt $bitmap.Width; $x += 10) {
                    $pixel = $bitmap.GetPixel($x,$y); $total += ($pixel.R+$pixel.G+$pixel.B)/3; $count++
                }
            }
            $mean = $total / $count
            $validation = "Host validation: PCM bytes=$($pcm.Length) RMS=$rms peak=$peak; JPEG=$($bitmap.Width)x$($bitmap.Height) sampled meanRGB=$mean"
            Write-Log $validation
            $validation | Set-Content "$dir/host-validation.txt"
            if ($rms -le 1 -or $mean -le 1) { throw 'Silent audio or black image; inspect evidence.' }
        } finally { $bitmap.Dispose() }
        [void](Invoke-Crown @('shell','am','force-stop',$package)); $started = $false
        foreach ($permission in $revoke) { [void](Invoke-Crown @('shell','pm','revoke',$package,$permission)) }
        $revoke = @()
    }
    Complete-OwnerRun 0
} catch {
    $failure = $_.Exception.Message
    foreach ($permission in $revoke) { try { [void](Invoke-Crown @('shell','pm','revoke','dev.crown.hellocrown',$permission)) } catch { Write-Log "Permission cleanup failed: $_" } }
    if ($started) { try { [void](Invoke-Crown @('shell','am','force-stop','dev.crown.hellocrown')) } catch { Write-Log "Probe cleanup failed: $_" } }
    Complete-OwnerRun 1 $failure
}
