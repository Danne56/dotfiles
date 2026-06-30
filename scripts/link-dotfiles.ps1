#Requires -Version 7.0

<#
.SYNOPSIS
Deploys dotfile symbolic links to the local Windows system with ANSI formatting.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateNotNullOrEmpty()]
    [string]$RepoDir = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

if (-not $IsWindows) {
    throw "Execution halted. This deployment is exclusive to Windows."
}

# Fix Pipeline Leak: Reverting to 'if' prevents Test-Path from emitting $true
$YaziValidationPath = Join-Path $RepoDir "yazi\.config\yazi"
if (-not (Test-Path $YaziValidationPath)) {
    throw "Repository validation failed. Missing: $YaziValidationPath"
}

# PowerShell 7 Native ANSI UI Definitions
$UI = @{
    Info = "$($PSStyle.Foreground.Cyan)::$($PSStyle.Reset)"
    Ok   = "$($PSStyle.Foreground.BrightGreen)✓$($PSStyle.Reset)"
    Skip = "$($PSStyle.Foreground.Yellow)~$($PSStyle.Reset)"
    Err  = "$($PSStyle.Foreground.Red)×$($PSStyle.Reset)"
    Path = $PSStyle.Foreground.BrightBlack
    Bold = $PSStyle.Formatting.Bold
    Off  = $PSStyle.Reset
}

function New-Symlink {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Target,
        [Parameter(Mandatory)][string]$Link
    )

    $parent = Split-Path $Link -Parent
    if (-not (Test-Path $parent)) {
        if ($PSCmdlet.ShouldProcess($parent, "Create directory")) {
            [void](New-Item -ItemType Directory -Path $parent -Force)
        }
    }

    if (Test-Path $Link) {
        $item = Get-Item -Path $Link -Force -ErrorAction SilentlyContinue

        if ($item.LinkType -eq 'SymbolicLink') {
            try {
                $resolvedCurrent = (Resolve-Path $item.Target -ErrorAction Stop).Path
                $resolvedTarget = (Resolve-Path $Target -ErrorAction Stop).Path

                if ($resolvedCurrent -eq $resolvedTarget) {
                    # Suppress output to the Verbose stream
                    Write-Verbose "Skip (Identical): $Link"
                    return
                }
            }   catch {
                Write-Host "$($UI.Skip) Replace (Broken) $($UI.Path)$Link$($UI.Off)"
            }

            if ($PSCmdlet.ShouldProcess($Link, "Remove existing symlink")) {
                [void](Remove-Item -Path $Link -Force)
            }
        } else {
            Write-Warning "Skipping deployment. Standard file detected at: $Link"
            return
        }
    }

    try {
        if ($PSCmdlet.ShouldProcess($Link, "Create symbolic link to $Target")) {
            [void](New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force)
            Write-Host "$($UI.Ok) Link $($UI.Path)$Link $($UI.Off)-> $($UI.Path)$Target$($UI.Off)"
        }
    } catch {
        Write-Host "$($UI.Err) Failed to link $Link"
        Write-Warning $_.Exception.Message
    }
}

function New-PackageLink {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$SourceDir,
        [Parameter(Mandatory)][string]$DestDir
    )

    if (-not (Test-Path $SourceDir)) {
        Write-Warning "Source directory missing: $SourceDir"
        return
    }

    $files = Get-ChildItem -Path $SourceDir -Recurse -File
    foreach ($file in $files) {
        $relPath = [System.IO.Path]::GetRelativePath($SourceDir, $file.FullName)
        $destPath = Join-Path $DestDir $relPath
        New-Symlink -Target $file.FullName -Link $destPath
    }
}

# Declarative configuration block
$Deployments = @(
    @{
        Type   = "Package"
        Source = Join-Path $RepoDir "yazi\.config\yazi"
        Dest   = "$env:APPDATA\yazi\config"
    },
    @{
        Type   = "Package"
        Source = Join-Path $RepoDir "helix\.config\helix"
        Dest   = "$env:APPDATA\helix"
    },
    @{
        Type   = "Package"
        Source = Join-Path $RepoDir "powershell"
        Dest   = "$HOME\Documents\PowerShell"
    },
    @{
        Type   = "File"
        Source = Join-Path $RepoDir "git\.config\git\config"
        Dest   = "$HOME\.gitconfig"
    }
)

Write-Host "`n$($UI.Info) $($UI.Bold)Deploying dotfiles from:$($UI.Off) $($UI.Path)$RepoDir$($UI.Off)`n"

# Execution loop
foreach ($Item in $Deployments) {
    switch ($Item.Type) {
        "Package" {
            $PackageName = Split-Path $Item.Source -Leaf
            Write-Host "$($UI.Info) Package: $($UI.Bold)$PackageName$($UI.Off)"
            New-PackageLink -SourceDir $Item.Source -DestDir $Item.Dest
        }
        "File" {
            New-Symlink -Target $Item.Source -Link $Item.Dest
        }
    }
}
Write-Host ""
