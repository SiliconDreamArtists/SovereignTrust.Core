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
        $mappedPath = "Mapped${Kind}Attachments.$Slot"
        $attachmentSignal = Resolve-PathFromDictionary -Dictionary $Graph -Path $mappedPath | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($attachmentSignal)) {
            return $signal.LogCritical("❌ Mapped attachment '$mappedPath' not found.")
        }
        $attachment = $attachmentSignal.GetResult()
        $base = $attachment.BasePath ?? $attachment.Address ?? $attachment.Path
        if (-not $base) {
            return $signal.LogCritical("❌ No usable base path found in attachment.")
        }
        $fullPath = Join-Path $base $relativePath
        $signal.SetResult($fullPath)
        $signal.LogInformation("📁 Resolved source path: $fullPath")
    } catch {
        $signal.LogCritical("🔥 Unhandled exception in Resolve-HydrationSourcePath: $($_.Exception.Message)")
    }
    return $signal
}