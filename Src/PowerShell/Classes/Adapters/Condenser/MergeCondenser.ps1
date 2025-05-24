# =============================================================================
# 🔄 MergeCondenser (Declarative Memory Overlay & Unification Engine)
#  License: MIT License • Copyright (c) 2025 Silicon Dream Artists / BDDB
#  Authors: Shadow PhanTom ☠️🧁👾️/🤖 • Neural Alchemist ⚗️☣️🐲 • Last Updated: 05/20/2025
# =============================================================================
# Performs recursive, additive overlay merging between structured sovereign memory types.
#
# This includes support for:
# - Hashtables (raw objects)
# - Signals (Jacket-bound memory containers)
# - Graphs (living memory meshes)
#
# TODO: Replace [Signal]$Signal with [Graph]$SignalGraph to enable sovereign lineage tracking.
#       Each method should register its signal as a node in the Graph using RegisterSignal().
#       This elevates the signal from a linear log to a queryable, memory-safe signal map.
#
# Doctrine Alignment:
# • Sovereign Memory: ✅
# • Living Signals: ✅
# • Adapter Evolution: ✅
# • Temporal Recursion: ✅
# =============================================================================

class MergeCondenser {
    [Conductor]$Conductor
    [MappedCondenserAdapter]$MappedCondenserAdapter
    [Signal]$Signal  # Sovereign control signal (previously ControlSignal)

    MergeCondenser() {
    }

    static [MergeCondenser] Start([MappedCondenserAdapter]$mappedAdapter, [Conductor]$conductor) {
        $instance = [MergeCondenser]::new()
        $instance.MappedCondenserAdapter = $mappedAdapter
        $instance.Conductor = $conductor
        $instance.Signal = [Signal]::Start("MergeCondenser.Control") | Select-Object -Last 1
        return $instance
    }


    [Signal] InvokeByParameter([object]$Base, [object]$Overlay, [bool]$IgnoreInternalObjects = $true) {
        $opSignal = [Signal]::Start("MergeCondenser.Invoke-ByParameter") | Select-Object -Last 1

        $mergeSignal = Merge-CondenserUnifiedMemory -Base $Base -Overlay $Overlay | Select-Object -Last 1

        if ($opSignal.MergeSignalAndVerifySuccess($mergeSignal)) {
            $opSignal.SetResult($mergeSignal.GetResult())
            $opSignal.LogInformation("✅ Merge completed successfully via unified invocation.")
        }
        else {
            $opSignal.LogWarning("⚠️ Merge operation failed in Invoke-ByParameter.")
        }

        $this.Signal.MergeSignal($opSignal)
        return $opSignal
    }
}
