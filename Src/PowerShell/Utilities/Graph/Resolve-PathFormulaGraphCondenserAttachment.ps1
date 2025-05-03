function Resolve-PathFormulaGraphCondenserAttachment {
    param (
        [Parameter(Mandatory)]
        [object]$Conductor
    )

    $signal = [Signal]::new("Resolve-PathFormulaGraph:CondenserAttachment")

    # ░▒▓█ RESOLVE REQUIRED CONTEXT █▓▒░
    $envSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "Environment" | Select-Object -Last 1
    $mappedSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "MappedAttachments.Condenser" | Select-Object -Last 1

    if ($signal.MergeSignalAndVerifyFailure(@($envSignal, $mappedSignal))) {
        $signal.LogCritical("❌ Unable to resolve Environment or Condenser Attachment from Conductor.")
        return $signal
    }

    $environment = $envSignal.GetResult()
    $mappedCondenserAttachment = $mappedSignal.GetResult()

    try {
        $graph = [Graph]::new($environment)
        $graph.Start()

        # ░▒▓█ REGISTER CONDENSER SERVICES █▓▒░
        $graph.RegisterResultAsSignal("MergeCondenser",     [MergeCondenserService]::new($mappedCondenserAttachment, $Conductor))
        $graph.RegisterResultAsSignal("MapCondenser",       [MapCondenserService]::new($mappedCondenserAttachment, $Conductor))
        $graph.RegisterResultAsSignal("TokenCondenser",     [TokenCondenserService]::new($mappedCondenserAttachment, $Conductor))
        $graph.RegisterResultAsSignal("HydrationCondenser", [HydrationCondenserService]::new($mappedCondenserAttachment, $Conductor))
        $graph.RegisterResultAsSignal("GraphCondenser",     [GraphCondenserService]::new($mappedCondenserAttachment, $Conductor))  # Optional/Post-MVP

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
