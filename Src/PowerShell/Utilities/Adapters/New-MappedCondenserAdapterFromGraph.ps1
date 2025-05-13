function New-MappedCondenserAdapterFromGraph {
    param (
        [Parameter(Mandatory)]
        [object]$Conductor
    )

    $opSignal = [Signal]::Start("New-MappedCondenserAdapterFromGraph") | Select-Object -Last 1

    try {
        # ░▒▓█ INIT EMPTY MAPPED CONDENSER █▓▒░
        $mappedAdapterSignal = [MappedCondenserAdapter]::Start($Conductor) | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($mappedAdapterSignal)) {
            $opSignal.LogCritical("❌ Failed to initialize empty MappedCondenserAdapter.")
            return $opSignal
        }

        $mappedAdapter = $mappedAdapterSignal.GetResult() | Select-Object -Last 1
        $adapterGraph   = $mappedAdapter.Signal.GetResult() | Select-Object -Last 1

        # ░▒▓█ MOUNT MAPPED CONDENSER ON CONDUCTOR'S GRAPH █▓▒░
        $conductorGraphSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "$.*" | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($conductorGraphSignal)) {
            $opSignal.LogCritical("❌ Could not resolve Conductor pointer graph.")
            return $opSignal
        }

        $conductorGraph = $conductorGraphSignal.GetResult() | Select-Object -Last 1
        $registerMountSignal = $conductorGraph.RegisterResultAsSignal("MappedCondenser", $mappedAdapter) | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($registerMountSignal)) {
            $opSignal.LogCritical("❌ Failed to register MappedCondenser on Conductor.")
            return $opSignal
        }

        # ░▒▓█ RESOLVE CONDENSER POPULATION GRAPH █▓▒░
        $graphSourceSignal = Resolve-PathFormulaGraphCondenserAdapter -Conductor $Conductor | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($graphSourceSignal)) {
            $opSignal.LogCritical("❌ Failed to resolve Condenser adapter source graph.")
            return $opSignal
        }

        $graphSignal = Resolve-PathFromDictionary -Dictionary $graphSourceSignal -Path "@.#" | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($graphSignal)) {
            $opSignal.LogCritical("❌ Condenser adapter graph missing from resolved source.")
            return $opSignal
        }

        $graphObject = $graphSignal.GetResult() | Select-Object -Last 1

        # ░▒▓█ REGISTER EACH CONDENSER █▓▒░
        foreach ($key in $graphObject.Keys) {
            $adapterSignal = $graphObject[$key]
            $adapter = $adapterSignal.GetResult() | Select-Object -Last 1

            if ($null -ne $adapter) {
                $registerAdapterSignal = $adapterGraph.RegisterSignal($key, $adapterSignal) | Select-Object -Last 1
                $opSignal.MergeSignal($registerAdapterSignal)
            } else {
                $opSignal.LogWarning("⚠️ Null condenser '$key' encountered during registration.")
            }
        }

        $opSignal.SetResult($mappedAdapter)
        $opSignal.LogInformation("🧪 MappedCondenserAdapter fully initialized and mounted.")
    }
    catch {
        $opSignal.LogCritical("🔥 Exception during MappedCondenserAdapter construction: $($_.Exception.Message)")
    }

    Invoke-TraceSignalTree -Signal $opSignal -VisualizeFinal $true
    return $opSignal
}
