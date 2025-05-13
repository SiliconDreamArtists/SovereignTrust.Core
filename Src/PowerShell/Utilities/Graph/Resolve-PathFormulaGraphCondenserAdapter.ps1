function Resolve-PathFormulaGraphCondenserAdapter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]$Conductor
    )

    $opSignal = [Signal]::Start("Resolve-PathFormulaGraph:CondenserAdapter") | Select-Object -Last 1

    # ░▒▓█ RESOLVE REQUIRED CONTEXT █▓▒░
    $pointerSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "$.*" | Select-Object -Last 1
    $adapterSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "$.*.#.MappedCondenser" | Select-Object -Last 1

    if ($opSignal.MergeSignalAndVerifyFailure(@($pointerSignal, $adapterSignal))) {
        $opSignal.LogCritical("❌ Unable to resolve required context from Conductor.")
        return $opSignal
    }

    $mappedAdapter = $adapterSignal.GetResult() | Select-Object -Last 1
    if ($mappedAdapter -is [Signal]) {
        $mappedAdapter = $mappedAdapter.GetResult() | Select-Object -Last 1
    }

    try {
        # ░▒▓█ BUILD AND POPULATE CONDENSER GRAPH █▓▒░
        $graphSignal = [Graph]::Start("MappedCondenserAdapter.Graph", $Conductor, $false) | Select-Object -Last 1
        $graph = $graphSignal.GetResult() | Select-Object -Last 1

        $graph.RegisterResultAsSignal("MergeCondenser",     [MergeCondenser]::new($mappedAdapter, $Conductor))     | Out-Null
        $graph.RegisterResultAsSignal("MapCondenser",       [MapCondenser]::new($mappedAdapter, $Conductor))       | Out-Null
        $graph.RegisterResultAsSignal("TokenCondenser",     [TokenCondenser]::new($mappedAdapter, $Conductor))     | Out-Null
        $graph.RegisterResultAsSignal("HydrationCondenser", [HydrationCondenser]::new($mappedAdapter, $Conductor)) | Out-Null
        $graph.RegisterResultAsSignal("GraphCondenser",     [GraphCondenser]::new($mappedAdapter, $Conductor))     | Out-Null
        $graph.RegisterResultAsSignal("FormulaGraphCondenser", [FormulaGraphCondenser]::new($mappedAdapter, $Conductor)) | Out-Null

        $graph.Finalize()
        $opSignal.SetResult($graph)
        $opSignal.LogInformation("✅ Condenser formula graph created and populated with condenser adapters.")
    }
    catch {
        $opSignal.LogCritical("🔥 Exception while building condenser graph: $($_.Exception.Message)")
    }

    return $opSignal
}
