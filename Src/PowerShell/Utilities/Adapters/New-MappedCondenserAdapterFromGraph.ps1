function New-MappedCondenserAdapterFromGraph {
    param (
        [Parameter(Mandatory)]
        [object]$Conductor
    )

    $signal = [Signal]::new("New-MappedCondenserAdapterFromGraph")

    try {
        # ░▒▓█ INIT EMPTY MAPPED CONDENSER █▓▒░
        $mappedAdapter = [MappedCondenserAdapter]::new($Conductor)

        # ░▒▓█ REGISTER IN CONDUCTOR FOR INTROSPECTION █▓▒░
        $registerSignal = $Conductor.MappedAdapters.RegisterResultAsSignal("Condenser", $mappedAdapter)
        if ($signal.MergeSignalAndVerifyFailure($registerSignal)) {
            $signal.LogCritical("❌ Failed to register empty Condenser adapter.")
            return $signal
        }

        # ░▒▓█ POPULATE CONDENSERS USING ACCESSIBLE MAPPED STATE █▓▒░
        $graphSignal = Resolve-PathFormulaGraphCondenserAdapter -Conductor $Conductor | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($graphSignal)) {
            $signal.LogCritical("❌ Failed to resolve Condenser graph with full context.")
            return $signal
        }

        $graph = Resolve-PathFromDictionary -Dictionary $graphSignal -Path "Graph" | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($graph)) {
            $signal.LogCritical("❌ Condenser graph object missing from result.")
            return $signal
        }

        $graphObject = $graph.GetResult()

        # ░▒▓█ REGISTER EACH CONDENSER █▓▒░
        foreach ($key in $graphObject.SignalGrid.Keys) {
            $adapterSignal = $graphObject.SignalGrid[$key]
            $adapter = $adapterSignal.GetResult()

            if ($null -ne $adapter) {
                $registerAdapterSignal = $mappedAdapter.RegisterAdapter($key, $adapter)
                $signal.MergeSignal($registerAdapterSignal)
            } else {
                $signal.LogWarning("⚠️ Null condenser '$key' encountered during registration.")
            }
        }

        $signal.SetResult($mappedAdapter)
        $signal.LogInformation("🧪 MappedCondenserAdapter fully initialized and mounted.")
    }
    catch {
        $signal.LogCritical("🔥 Exception during MappedCondenserAdapter construction: $($_.Exception.Message)")
    }

    return $signal
}
