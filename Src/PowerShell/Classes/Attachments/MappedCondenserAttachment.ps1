class MappedCondenserAttachment {
    [object]$Conductor
    [Graph]$AttachmentGraph
    [Signal]$ControlSignal
    $MyName = "MappedCondenserAttachment"

    MappedCondenserAttachment([object]$conductor) {
        $this.Conductor = $conductor
        $this.ControlSignal = [Signal]::new("MappedCondenserAttachment.Control")
        $this.AttachmentGraph = [Graph]::new($conductor.Environment)
        $this.AttachmentGraph.Start() | Out-Null
    }

    [Signal] RegisterAttachment([string]$Key, [object]$CondenserAttachment) {
        $signal = [Signal]::new("RegisterMappedAttachment:$Key")

        $attachmentSignal = [Signal]::new("Attachment:$Key")
        $attachmentSignal.SetResult($CondenserAttachment)

        $registerSignal = $this.AttachmentGraph.RegisterSignal($Key, $attachmentSignal)
        $signal.MergeSignal($registerSignal)

        if ($registerSignal.Success()) {
            $signal.LogInformation("✅ Registered Condenser attachment under key: '$Key'")
        } else {
            $signal.LogWarning("⚠️ Failed to register attachment at key: '$Key'")
        }

        $this.ControlSignal.MergeSignal($signal)
        return $signal
    }

    [Signal] Invoke([object]$Context) {
        $signal = [Signal]::new("MappedCondenserAttachment.Invoke")

        foreach ($key in $this.AttachmentGraph.SignalGrid.Keys) {
            $subSignal = $this.AttachmentGraph.SignalGrid[$key]
            $service = $subSignal.GetResult()

            if ($null -ne $service -and ($service | Get-Member -Name "Invoke")) {
                $resultSignal = $service.Invoke($Context)
                $signal.MergeSignal($resultSignal)

                if ($resultSignal.Success()) {
                    $signal.SetResult($resultSignal.GetResult())
                    $signal.LogInformation("🎯 Attachment '$key' invoked successfully.")
                    break
                } else {
                    $signal.LogWarning("⚠️ Attachment '$key' failed to produce a result.")
                }
            } else {
                $signal.LogVerbose("⏭️ Attachment '$key' does not support Invoke().")
            }
        }

        if (-not $signal.Success()) {
            $signal.LogCritical("❌ No Condenser attachment produced a valid result.")
        }

        $this.ControlSignal.MergeSignal($signal)
        return $signal
    }
}
