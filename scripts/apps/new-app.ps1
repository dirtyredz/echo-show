<#
.SYNOPSIS
Create apps/Name as an independent repo from versioned HelloCrown source and index it.
.PARAMETER Name
ASCII letters and digits, starting with a letter; becomes a lowercase dev.crown package suffix.
.PARAMETER DryRun
Validate source and destination and log the plan; no app or index writes. Exit 0 success, 1 failure.
#>
[CmdletBinding()] param([string]$Name,[switch]$DryRun)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../device/device-session.ps1"
try {
    Start-DeviceRun 'new-app' -WithoutAdb
    if ($Name -notmatch '^[A-Za-z][A-Za-z0-9]{0,39}$' -or $Name -match '^(CON|PRN|AUX|NUL|COM[0-9]|LPT[0-9])$') { throw 'Name must be a safe ASCII app name (1-40 letters/digits).' }
    if ($Name.ToLowerInvariant() -in @('as','break','class','continue','do','else','false','for','fun','if','in','interface','is','null','object','package','return','super','this','throw','true','try','typealias','typeof','val','var','when','while')) { throw 'Name is a reserved Kotlin keyword.' }
    $destination = Join-Path $script:RepoRoot "apps/$Name"
    if (Test-Path -LiteralPath $destination) { throw "Destination exists: $destination" }
    $source = Join-Path $script:RepoRoot 'apps/HelloCrown'
    if (-not (Test-Path -LiteralPath "$source/.git")) {
        $trees = & git -C $script:RepoRoot worktree list --porcelain
        if ($LASTEXITCODE -ne 0) { throw 'Cannot locate main checkout template.' }
        $main = (($trees | Where-Object { $_ -like 'worktree *' } | Select-Object -First 1) -replace '^worktree ','')
        $source = Join-Path $main 'apps/HelloCrown'
    }
    if (-not (Test-Path -LiteralPath "$source/.git")) { throw 'HelloCrown nested repo missing. Restore it independently; root does not track apps.' }
    $files = @(& git -C $source ls-files)
    if ($LASTEXITCODE -ne 0 -or $files -notcontains 'app/build.gradle.kts') { throw 'Template must contain committed Android source.' }
    $readme = Join-Path $script:RepoRoot 'README.md'
    if (-not (Test-Path $readme)) { throw 'README app index missing.' }
    if ((Get-Content $readme -Raw) -notmatch '<!-- app-index -->') { throw 'README app index marker missing.' }
    $suffix = $Name.ToLowerInvariant()
    Write-Log "Template: $source; destination: $destination; package: dev.crown.$suffix"
    if ($DryRun) { Write-Log "DRY RUN: copy $($files.Count) versioned files, rename package, git init, and append app index. No app created." }
    else {
        New-Item -ItemType Directory -Path $destination | Out-Null
        foreach ($file in $files) {
            if ($file -eq 'TESTING.md') { continue } # Verification belongs to the original sample only.
            if ($file -match '^\.git/' -or $file -match '(^|/)\.\./') { throw 'Unsafe template path.' }
            $renamed = $file.Replace('hellocrown',$suffix)
            $target = Join-Path $destination $renamed
            New-Item -ItemType Directory -Force (Split-Path $target -Parent) | Out-Null
            if ($file.EndsWith('.jar')) { Copy-Item -LiteralPath (Join-Path $source $file) -Destination $target }
            else {
                $text = [IO.File]::ReadAllText((Join-Path $source $file)).Replace('hellocrown',$suffix).Replace('HelloCrown',$Name)
                [IO.File]::WriteAllText($target,$text,(New-Object Text.UTF8Encoding $false))
            }
        }
        if ((Invoke-Native 'git' @('init','-b','main') $destination) -ne 0) { throw 'git init failed.' }
        if ((Invoke-Native 'git' @('add','.') $destination) -ne 0) { throw 'git add failed.' }
        $message = "Scaffold $Name for crown`n`nCo-Authored-By: Astra (gpt-6-astra) <noreply@openai.com>"
        if ((Invoke-Native 'git' @('commit','-m',$message) $destination) -ne 0) { throw 'Initial commit failed; app preserved for repair. Index unchanged.' }
        Add-Content -LiteralPath $readme -Value "| [$Name](apps/$Name/README.md) | dev.crown.$suffix | Scaffolded; build/device verification pending |"
        Write-Log 'Created nested repo and updated root README. Commit the root index separately.'
    }
    Complete-OwnerRun 0
} catch { Complete-OwnerRun 1 $_.Exception.Message }
