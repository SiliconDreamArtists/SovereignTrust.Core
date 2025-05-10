function Resolve-PathFormulaGraphCondenserAdapter {
    param (
        [Parameter(Mandatory)]
        [object]$Conductor
    )

    $opSignal = [Signal]::Start("Resolve-PathFormulaGraph:CondenserAdapter")

    # ░▒▓█ RESOLVE REQUIRED CONTEXT █▓▒░
    $conductorJacketSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "$.%" | Select-Object -Last 1
    $adapterSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "$.*.#.MappedCondenser" | Select-Object -Last 1

    if ($opSignal.MergeSignalAndVerifyFailure(@($conductorJacketSignal, $adapterSignal))) {
        $opSignal.LogCritical("❌ Unable to resolve Environment or MappedCondenser from Conductor.")
        return $opSignal
    }

    $conductorJacket = $conductorJacketSignal.GetResult()
    $condenser = $adapterSignal.GetResult()

    try {
        $graph = [Graph]::new($conductorJacket)
        $graph.Start()

        # ░▒▓█ REGISTER CONDENSER SERVICES █▓▒░
        $graph.RegisterResultAsSignal("MergeCondenser",     [MergeCondenser]::new($condenser, $Conductor))     | Out-Null
        $graph.RegisterResultAsSignal("MapCondenser",       [MapCondenser]::new($condenser, $Conductor))       | Out-Null
        $graph.RegisterResultAsSignal("TokenCondenser",     [TokenCondenser]::new($condenser, $Conductor))     | Out-Null
        $graph.RegisterResultAsSignal("HydrationCondenser", [HydrationCondenser]::new($condenser, $Conductor)) | Out-Null
        $graph.RegisterResultAsSignal("GraphCondenser",     [GraphCondenser]::new($condenser, $Conductor))     | Out-Null

        $graph.Finalize()

        $opSignal.SetResult(@{
            Strategy = "Condenser"
            Graph    = $graph
        })

        $opSignal.LogInformation("✅ Condenser formula graph created and populated with condenser adapters.")
    }
    catch {
        $opSignal.LogCritical("🔥 Exception while building condenser graph: $($_.Exception.Message)")
    }

    return $opSignal
}
