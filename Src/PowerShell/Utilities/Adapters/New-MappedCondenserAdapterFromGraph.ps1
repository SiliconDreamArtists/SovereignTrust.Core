function New-MappedCondenserAdapterFromGraph {
    param (
        [Parameter(Mandatory)]
        [object]$Conductor
    )

    $opSignal = [Signal]::Start("New-MappedCondenserAdapterFromGraph") | Select-Object -Last 1

    try {
        # ░▒▓█ INIT EMPTY MAPPED CONDENSER █▓▒░
        $mappedAdapterSignal = [MappedCondenserAdapter]::Start($Conductor)

        if ($opSignal.MergeSignalAndVerifyFailure($mappedAdapterSignal)) {
            $opSignal.LogCritical("❌ Failed to initialize empty MappedCondenserAdapter.")
            return $opSignal
        }

        $mappedAdapter = $mappedAdapterSignal.GetResult()

        # SP 05/11/2025: Apparently this says the Conductor should hold the Mapped Adapters in its own Graph which is the pointer on the Conductor.
        $graphSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "$.*" | Select-Object -Last 1
        $graph = $graphSignal.GetResult()
        $registerSignal = $graph.RegisterResultAsSignal("MappedCondenser", $mappedAdapter)

        if ($opSignal.MergeSignalAndVerifyFailure($registerSignal)) {
            $opSignal.LogCritical("❌ Failed to register empty Condenser adapter.")
            return $opSignal
        }

        # ░▒▓█ POPULATE CONDENSERS USING ACCESSIBLE MAPPED STATE █▓▒░
        $graphSignal = Resolve-PathFormulaGraphCondenserAdapter -Conductor $Conductor | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($graphSignal)) {
            $opSignal.LogCritical("❌ Failed to resolve Condenser graph with full context.")
            return $opSignal
        }

        $graph = Resolve-PathFromDictionary -Dictionary $graphSignal -Path "Graph" | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($graph)) {
            $opSignal.LogCritical("❌ Condenser graph object missing from result.")
            return $opSignal
        }

        $graphObject = $graph.GetResult()

        # ░▒▓█ REGISTER EACH CONDENSER █▓▒░
        foreach ($key in $graphObject.Keys) {
            $adapterSignal = $graphObject[$key]
            $adapter = $adapterSignal.GetResult()

            if ($null -ne $adapter) {
                $registerAdapterSignal = $mappedAdapter.RegisterAdapter($key, $adapter)
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
