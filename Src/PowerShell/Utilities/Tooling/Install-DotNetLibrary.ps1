function Install-DotNetLibrary {
    param (
        [Parameter(Mandatory = $true)] [string]$LibraryName,
        [Parameter(Mandatory = $true)] [string]$LibraryVersion,
        [Parameter(Mandatory = $true)] [string]$TargetFolder,
        [string]$TargetFramework = "netstandard2.0"
    )

    $LibraryNameFull = $LibraryName

    $nugetPath = "$TargetFolder\Tools"
    # Ensure target folder exists
    if (-not (Test-Path $nugetPath)) {
        New-Item -ItemType Directory -Path $nugetPath -Force | Out-Null
    }

    # Ensure nuget.exe exists
    $nugetExe = "$TargetFolder\Tools\nuget.exe"
    if (-not (Test-Path $nugetExe)) {
        Write-Host "⬇️  Downloading nuget.exe..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $nugetExe
    }

    # Ensure target folder exists
    if (-not (Test-Path $TargetFolder)) {
        New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
    }

    # Construct expected DLL path
    $dllPath = Join-Path $TargetFolder "$LibraryName\lib\$TargetFramework\$($LibraryName).dll"

    if (-not (Test-Path $dllPath)) {
        # Download the package (exclude version from folder name)
        Write-Host "📦 Downloading $LibraryName@$LibraryVersion to $TargetFolder" -ForegroundColor Cyan
        & $nugetExe install $LibraryName `
            -Version $LibraryVersion `
            -OutputDirectory $TargetFolder `
            -ExcludeVersion `
            -Source "https://api.nuget.org/v3/index.json" | Out-Null
    }

    # Load DLL
    if (Test-Path $dllPath) {
        try {
            Add-Type -Path $dllPath
            Write-Host "✅ Loaded $LibraryName from $dllPath" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "❌ Exception: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "❌ Failed to find DLL: $dllPath" -ForegroundColor Red
        }
        }
    else {
        Write-Host "❌ Failed to find DLL: $dllPath" -ForegroundColor Red
    }

    return $false
}
