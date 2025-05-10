class MappedCondenserAdapter {
    [object]$Conductor
    [Graph]$AdapterGraph
    [Signal]$ControlSignal
    $MyName = "MappedCondenserAdapter"

    MappedCondenserAdapter([object]$conductor) {
        $this.Conductor = $conductor
        $this.ControlSignal = [Signal]::Start("MappedCondenserAdapter.Control")
        $this.AdapterGraph = [Graph]::new($conductor.Environment)
        $this.AdapterGraph.Start() | Out-Null
    }

    [Signal] RegisterAdapter([string]$Key, [object]$CondenserAdapter) {
        $signal = [Signal]::Start("RegisterMappedAdapter:$Key")

        $adapterSignal = [Signal]::Start("Adapter:$Key")
        $adapterSignal.SetResult($CondenserAdapter)

        $registerSignal = $this.AdapterGraph.RegisterSignal($Key, $adapterSignal)
        $signal.MergeSignal($registerSignal)

        if ($registerSignal.Success()) {
            $signal.LogInformation("✅ Registered Condenser adapter under key: '$Key'")
        } else {
            $signal.LogWarning("⚠️ Failed to register adapter at key: '$Key'")
        }

        $this.ControlSignal.MergeSignal($signal)
        return $signal
    }

    [Signal] Invoke([object]$Context) {
        $signal = [Signal]::Start("MappedCondenserAdapter.Invoke")

        foreach ($key in $this.AdapterGraph.Grid.Keys) {
            $subSignal = $this.AdapterGraph.Grid[$key]
            $service = $subSignal.GetResult()

            if ($null -ne $service -and ($service | Get-Member -Name "Invoke")) {
                $resultSignal = $service.Invoke($Context)
                $signal.MergeSignal($resultSignal)

                if ($resultSignal.Success()) {
                    $signal.SetResult($resultSignal.GetResult())
                    $signal.LogInformation("🎯 Adapter '$key' invoked successfully.")
                    break
                } else {
                    $signal.LogWarning("⚠️ Adapter '$key' failed to produce a result.")
                }
            } else {
                $signal.LogVerbose("⏭️ Adapter '$key' does not support Invoke().")
            }
        }

        if (-not $signal.Success()) {
            $signal.LogCritical("❌ No Condenser adapter produced a valid result.")
        }

        $this.ControlSignal.MergeSignal($signal)
        return $signal
    }
}
