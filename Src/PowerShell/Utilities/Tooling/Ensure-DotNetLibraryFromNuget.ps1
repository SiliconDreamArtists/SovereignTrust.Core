function Ensure-DotNetLibraryFromNuget {
    param (
        [Parameter(Mandatory = $true)] [object]$ConductionContext,
        [Parameter(Mandatory = $true)] [string]$LibraryName,
        [Parameter(Mandatory = $true)] [string]$LibraryVersion,
        [Parameter(Mandatory = $true)] [string]$TargetFolder,
        [string]$TargetFramework = "netstandard2.0"
    )

    $signal = [Signal]::Start("Ensure-DotNetLibrary:$LibraryName")

    try {
        $nugetPath = Join-Path $TargetFolder "Tools"
        $nugetExe = Join-Path $nugetPath "nuget.exe"
        $dllPath = Join-Path $TargetFolder "$LibraryName\lib\$TargetFramework\$LibraryName.dll"

        # ░▒▓█ TOOLS FOLDER █▓▒░
        if (-not (Test-Path $nugetPath)) {
            $null = New-Item -ItemType Directory -Path $nugetPath -Force
            $signal.LogInformation("🛠 Created NuGet tools directory.")
        }

        # ░▒▓█ FETCH NUGET.EXE █▓▒░
        if (-not (Test-Path $nugetExe)) {
            try {
                Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $nugetExe
                $signal.LogInformation("⬇️ Downloaded nuget.exe")
            } catch {
                $signal.LogCritical("❌ Failed to download nuget.exe: $($_.Exception.Message)")
                return $signal
            }
        }

        # ░▒▓█ INSTALL PACKAGE █▓▒░
        if (-not (Test-Path $dllPath)) {
            try {
                $installResult = & $nugetExe install $LibraryName `
                    -Version $LibraryVersion `
                    -OutputDirectory $TargetFolder `
                    -ExcludeVersion `
                    -Source "https://api.nuget.org/v3/index.json"

                $signal.LogInformation("📦 Installed $LibraryName@$LibraryVersion")
            } catch {
                $signal.LogCritical("❌ Failed NuGet install: $($_.Exception.Message)")
                return $signal
            }
        }

        # ░▒▓█ LOAD DLL █▓▒░
        if (Test-Path $dllPath) {
            try {
                Add-Type -Path $dllPath
                $signal.SetResult($true)
                $signal.LogInformation("✅ Loaded $LibraryName from $dllPath")
            } catch {
                $signal.LogCritical("❌ Failed to load DLL: $($_.Exception.Message)")
                $signal.SetResult($false)
            }
        } else {
            $signal.LogCritical("❌ DLL not found: $dllPath")
            $signal.SetResult($false)
        }
    }
    catch {
        $signal.LogCritical("🔥 Unexpected failure: $($_.Exception.Message)")
    }

    return $signal
}
