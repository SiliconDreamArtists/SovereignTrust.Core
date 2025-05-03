function Merge-CondenserFromGraphs {
    param (
        [Parameter(Mandatory)][Graph]$PrimaryGraph,
        [Parameter(Mandatory)][Graph]$OverlayGraph
    )

    $signal = [Signal]::new("Merge-CondenserFromGraphs")
    try {
        $primary = $PrimaryGraph.SignalGrid["Merged"].GetResult()
        $overlay = $OverlayGraph.SignalGrid["Merged"].GetResult()

        $mergeSignal = Merge-CondenserDictionaries -Primary $primary -Overlay $overlay | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($mergeSignal)) {
            return $signal
        }

        $graph = [Graph]::new($null)
        $graph.RegisterResultAsSignal("Merged", $mergeSignal.GetResult()) | Out-Null
        $signal.SetResult($graph)
        $signal.LogInformation("✅ Merged graph created from Graphs.")
    } catch {
        $signal.LogCritical("🔥 Exception: $($_.Exception.Message)")
    }
    return $signal
}
