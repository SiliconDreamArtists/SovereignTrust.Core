
function Merge-CondenserFromJsonBlobs {
    param (
        [Parameter(Mandatory)][string]$PrimaryJson,
        [Parameter(Mandatory)][string]$OverlayJson
    )

    $signal = [Signal]::new("Merge-CondenserFromJsonBlobs")
    try {
        $primaryHash = $PrimaryJson | ConvertFrom-Json -Depth 25
        $overlayHash = $OverlayJson | ConvertFrom-Json -Depth 25

        $mergeSignal = Merge-CondenserDictionaries -Primary $primaryHash -Overlay $overlayHash | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($mergeSignal)) {
            return $signal
        }

        $graph = [Graph]::new($null)
        $graph.RegisterResultAsSignal("Merged", $mergeSignal.GetResult()) | Out-Null
        $signal.SetResult($graph)
        $signal.LogInformation("✅ Merged graph created from JSON blobs.")
    } catch {
        $signal.LogCritical("🔥 Exception: $($_.Exception.Message)")
    }
    return $signal
}
