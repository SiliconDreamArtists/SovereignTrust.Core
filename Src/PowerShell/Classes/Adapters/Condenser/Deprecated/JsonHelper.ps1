class JsonHelper {

    static [Newtonsoft.Json.Linq.JObject] FromObject([object]$object) {
        return [Newtonsoft.Json.Linq.JObject]::FromObject($object)
    }

    static [Newtonsoft.Json.Linq.JToken] ParseJson([string]$jsonString) {
        return [Newtonsoft.Json.Linq.JToken]::Parse($jsonString)
    }

    static [Newtonsoft.Json.Linq.JToken] SelectToken([Newtonsoft.Json.Linq.JToken]$jtoken, [string]$path) {
        return $jtoken.SelectToken($path)
    }

    static [void] MergeTokens([Newtonsoft.Json.Linq.JObject]$target, [Newtonsoft.Json.Linq.JObject]$source) {
        $settings = [Newtonsoft.Json.Linq.JsonMergeSettings]::new()
        $settings.MergeArrayHandling = [Newtonsoft.Json.Linq.MergeArrayHandling]::Merge
        $settings.MergeNullValueHandling = [Newtonsoft.Json.Linq.MergeNullValueHandling]::Merge
        $target.Merge($source, $settings)
    }

    static [void] SetProperty([Newtonsoft.Json.Linq.JObject]$jobject, [string]$key, [object]$value) {
        $jobject[$key] = $value
    }
}

# =============================================================================
# 🔱 Triple Entry Merge Pattern — Sovereign MergeCondenser Entrypoints
# =============================================================================
# Provides 3 canonical entry points for merging overlay structures in SovereignTrust
# Each function returns a Signal with a merged Graph in Signal.Result
# Result is accessible at: $Signal.Result.SignalGrid["Merged"].Result
# =============================================================================

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
