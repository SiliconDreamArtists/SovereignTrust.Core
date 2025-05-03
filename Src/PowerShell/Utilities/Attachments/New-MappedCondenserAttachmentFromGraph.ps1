function New-MappedCondenserAttachmentFromGraph {
    param (
        [Parameter(Mandatory)]
        [object]$Conductor
    )

    $signal = [Signal]::new("New-MappedCondenserAttachmentFromGraph")

    try {
        # ░▒▓█ INIT EMPTY MAPPED CONDENSER █▓▒░
        $mappedAttachment = [MappedCondenserAttachment]::new($Conductor)

        # ░▒▓█ REGISTER IN CONDUCTOR FOR INTROSPECTION █▓▒░
        $registerSignal = $Conductor.MappedAttachments.RegisterResultAsSignal("Condenser", $mappedAttachment)
        if ($signal.MergeSignalAndVerifyFailure($registerSignal)) {
            $signal.LogCritical("❌ Failed to register empty Condenser attachment.")
            return $signal
        }

        # ░▒▓█ POPULATE CONDENSERS USING ACCESSIBLE MAPPED STATE █▓▒░
        $graphSignal = Resolve-PathFormulaGraphCondenserAttachment -Conductor $Conductor | Select-Object -Last 1
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
            $attachmentSignal = $graphObject.SignalGrid[$key]
            $attachment = $attachmentSignal.GetResult()

            if ($null -ne $attachment) {
                $registerAttachmentSignal = $mappedAttachment.RegisterAttachment($key, $attachment)
                $signal.MergeSignal($registerAttachmentSignal)
            } else {
                $signal.LogWarning("⚠️ Null condenser '$key' encountered during registration.")
            }
        }

        $signal.SetResult($mappedAttachment)
        $signal.LogInformation("🧪 MappedCondenserAttachment fully initialized and mounted.")
    }
    catch {
        $signal.LogCritical("🔥 Exception during MappedCondenserAttachment construction: $($_.Exception.Message)")
    }

    return $signal
}
