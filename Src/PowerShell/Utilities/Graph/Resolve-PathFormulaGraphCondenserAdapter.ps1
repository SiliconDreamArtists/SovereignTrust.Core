function Resolve-PathFormulaGraphCondenserAdapter {
    param (
        [Parameter(Mandatory)]
        [object]$Conductor
    )

    $signal = [Signal]::new("Resolve-PathFormulaGraph:CondenserAdapter")

    # ░▒▓█ RESOLVE REQUIRED CONTEXT █▓▒░
    $envSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "Environment" | Select-Object -Last 1
    $mappedSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "MappedAdapters.Condenser" | Select-Object -Last 1

    if ($signal.MergeSignalAndVerifyFailure(@($envSignal, $mappedSignal))) {
        $signal.LogCritical("❌ Unable to resolve Environment or Condenser Adapter from Conductor.")
        return $signal
    }

    $environment = $envSignal.GetResult()
    $mappedCondenserAdapter = $mappedSignal.GetResult()

    try {
        $graph = [Graph]::new($environment)
        $graph.Start()

        # ░▒▓█ REGISTER CONDENSER SERVICES █▓▒░
        $graph.RegisterResultAsSignal("MergeCondenser",     [MergeCondenser]::new($mappedCondenserAdapter, $Conductor))
        $graph.RegisterResultAsSignal("MapCondenser",       [MapCondenser]::new($mappedCondenserAdapter, $Conductor))
        $graph.RegisterResultAsSignal("TokenCondenser",     [TokenCondenser]::new($mappedCondenserAdapter, $Conductor))
        $graph.RegisterResultAsSignal("HydrationCondenser", [HydrationCondenser]::new($mappedCondenserAdapter, $Conductor))
        $graph.RegisterResultAsSignal("GraphCondenser",     [GraphCondenser]::new($mappedCondenserAdapter, $Conductor))  # Optional/Post-MVP

        $graph.Finalize()

        $signal.SetResult(@{
            Strategy = "Condenser"
            Graph    = $graph
        })

        $signal.LogInformation("✅ Condenser graph constructed using contextual resolution from Conductor.")
    }
    catch {
        $signal.LogCritical("🔥 Exception while building Condenser graph: $($_.Exception.Message)")
    }

    return $signal
}
