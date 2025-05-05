function Resolve-HydrationSourcePath {
    param (
        [Parameter(Mandatory)][Graph]$Graph,
        [Parameter(Mandatory)][hashtable]$Intent,
        [Parameter()][string]$Kind = "Storage",
        [Parameter()][string]$Slot = "PrimaryContent"
    )
    $signal = [Signal]::new("Resolve-HydrationSourcePath")
    try {
        $relativePath = $Intent.RelativePath
        if (-not $relativePath) {
            return $signal.LogCritical("❌ Missing RelativePath in HydrationIntent.")
        }
        $mappedPath = "Mapped${Kind}Adapters.$Slot"
        $adapterSignal = Resolve-PathFromDictionary -Dictionary $Graph -Path $mappedPath | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($adapterSignal)) {
            return $signal.LogCritical("❌ Mapped adapter '$mappedPath' not found.")
        }
        $adapter = $adapterSignal.GetResult()
        $base = $adapter.BasePath ?? $adapter.Address ?? $adapter.Path
        if (-not $base) {
            return $signal.LogCritical("❌ No usable base path found in adapter.")
        }
        $fullPath = Join-Path $base $relativePath
        $signal.SetResult($fullPath)
        $signal.LogInformation("📁 Resolved source path: $fullPath")
    } catch {
        $signal.LogCritical("🔥 Unhandled exception in Resolve-HydrationSourcePath: $($_.Exception.Message)")
    }
    return $signal
}