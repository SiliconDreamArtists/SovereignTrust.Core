# TODO: Replace [Signal]$ControlSignal with [Graph]$SignalGraph to enable sovereign lineage tracking.
#       Each method should register its signal as a node in the Graph using RegisterSignal().
#       This elevates the signal from a linear log to a queryable, memory-safe signal map.

<#
.SYNOPSIS
Performs recursive, additive overlay merging between structured memory types.

.DESCRIPTION
These MergeCondenser functions provide sovereign, doctrinally-aligned memory merging for:
- Hashtables (primitive object graphs)
- Signals (memory-bearing execution units)
- Graphs (sovereign memory surfaces)
- Hybrid formats (mixed runtime memory containers)

Key behavior includes:
✔ Overlay values overwrite base values
✔ Nested hashtables merge recursively
✔ Graph memory and signal result memory are resolved and preserved
✔ Input normalization is traceable via signals
✔ Memory lineage is maintained through result Signals

These are used in SovereignTrust Condensers to safely condense jacket metadata,
overlay manifests, evolve agent configuration states, and unify memory without
violating the sovereign boundaries of adapters or signals.

.EXAMPLES
$merged = Merge-CondenserUnifiedMemory -Base $defaults -Overlay $runtimeOverrides
$signal = [MergeCondenser]::new(...).InvokeByParameter($graphA, $graphB)

.NOTES
Doctrine Alignment:
• Sovereign Memory: ✅ (No mutation outside structured signal flow)
• Living Signals: ✅ (All operations return traceable signals)
• Adapter Evolution: ✅ (Used in recursive configuration layering)
• Temporal Recursion: ✅ (Supports merging lineage versions safely)

See also:
- Convert-ToUnifiedHashtable
- Merge-CondenserGraphs (planned)
- Merge-CondenserSignals (planned)
- SDA Graph Memory Layer Documentation
#>


class MergeCondenser {
    [Conductor]$Conductor
    [MappedCondenserAdapter]$MappedCondenserAdapter
    [Signal]$ControlSignal

    MergeCondenser([MappedCondenserAdapter]$mappedAdapter, [Conductor]$conductor) {
        $this.MappedCondenserAdapter = $mappedAdapter
        $this.Conductor = $conductor
        $this.ControlSignal = [Signal]::Start("MergeCondenser.Control") | Select-Object -Last 1
    }

    [Signal] InvokeByParameter([object]$Base, [object]$Overlay, [bool]$IgnoreInternalObjects = $true) {
        $signal = [Signal]::Start("MergeCondenser.Invoke-ByParameter") | Select-Object -Last 1

        $mergeSignal = Merge-CondenserUnifiedMemory -Base $Base -Overlay $Overlay | Select-Object -Last 1

        if ($signal.MergeSignalAndVerifySuccess($mergeSignal)) {
            $signal.SetResult($mergeSignal.GetResult())
            $signal.LogInformation("✅ Merge completed successfully via unified invocation.")
        } else {
            $signal.LogWarning("⚠️ Merge operation failed in Invoke-ByParameter.")
        }

        $this.ControlSignal.MergeSignal($signal)
        return $signal
    }
}
