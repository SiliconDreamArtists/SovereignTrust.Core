function Merge-CondenserFromSignals {
    param (
        [Parameter(Mandatory)][Signal]$PrimarySignal,
        [Parameter(Mandatory)][Signal]$OverlaySignal
    )

    $signal = [Signal]::new("Merge-CondenserFromSignals")
    try {
        $primary = $PrimarySignal.GetResult()
        $overlay = $OverlaySignal.GetResult()

        $mergeSignal = Merge-CondenserDictionaries -Primary $primary -Overlay $overlay | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($mergeSignal)) {
            return $signal
        }

        $graph = [Graph]::new($null)
        $graph.RegisterResultAsSignal("Merged", $mergeSignal.GetResult()) | Out-Null
        $signal.SetResult($graph)
        $signal.LogInformation("✅ Merged graph created from Signals.")
    } catch {
        $signal.LogCritical("🔥 Exception: $($_.Exception.Message)")
    }
    return $signal
}

