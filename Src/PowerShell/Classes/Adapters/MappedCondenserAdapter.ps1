class MappedCondenserAdapter {
    [Signal]$Signal

    MappedCondenserAdapter() {
        # Use static Start() to initialize
    }

    static [Signal] Start() {
        return [Signal]::Start($null)
    }

    static [Signal] Start([object]$conductor) {
        $opSignal = [Signal]::Start("MappedCondenserAdapter.Start") | Select-Object -Last 1

        if (-not $conductor) {
            $opSignal.LogCritical("❌ Null Conductor passed to Start().")
            return $opSignal
        }

        try {
            $adapter = [MappedCondenserAdapter]::new()
            $adapter.Signal = [Signal]::Start("MappedCondenserAdapter") | Select-Object -Last 1
            $adapter.Signal.SetJacket($conductor)
            $adapter.Signal.SetReversePointer($conductor)

            $graphSignal = [Graph]::Start("MappedCondenserAdapter", $adapter, $false)
            $adapter.Signal.SetResult($graphSignal, $true)

            $opSignal.SetResult($adapter)
            $opSignal.LogInformation("✅ MappedCondenserAdapter initialized successfully.")
        }
        catch {
            $opSignal.LogCritical("💥 Exception during adapter setup: $_")
        }

        return $opSignal
    }

    [Signal] RegisterAdapter([string]$Key, [object]$CondenserAdapter) {
        $opSignal = [Signal]::Start("RegisterMappedAdapter:$Key") | Select-Object -Last 1
        $adapterSignal = [Signal]::Start("Adapter:$Key") | Select-Object -Last 1
        $adapterSignal.SetResult($CondenserAdapter)

        $graph = $this.Signal.GetResult() | Select-Object -Last 1
        $registerSignal = $graph.RegisterSignal($Key, $adapterSignal)
        $opSignal.MergeSignal($registerSignal)

        if ($registerSignal.Success()) {
            $opSignal.LogInformation("✅ Registered Condenser adapter under key: '$Key'")
        } else {
            $opSignal.LogWarning("⚠️ Failed to register adapter at key: '$Key'")
        }

        $this.Signal.MergeSignal($opSignal)
        return $opSignal
    }

    [Signal] Invoke([object]$Context) {
        $opSignal = [Signal]::Start("MappedCondenserAdapter.Invoke") | Select-Object -Last 1
        $graph = $this.Signal.GetResult() | Select-Object -Last 1

        foreach ($key in $graph.Grid.Keys) {
            $subSignal = $graph.Grid[$key]
            $adapter = $subSignal.GetResult() | Select-Object -Last 1

            if ($null -ne $adapter -and ($adapter | Get-Member -Name "Invoke")) {
                $resultSignal = $adapter.Invoke($Context)
                $opSignal.MergeSignal($resultSignal)

                if ($resultSignal.Success()) {
                    $opSignal.SetResult($resultSignal, $true)
                    $opSignal.LogInformation("🎯 Adapter '$key' invoked successfully.")
                    break
                } else {
                    $opSignal.LogWarning("⚠️ Adapter '$key' failed to produce a result.")
                }
            } else {
                $opSignal.LogVerbose("⏭️ Adapter '$key' does not support Invoke().")
            }
        }

        if (-not $opSignal.Success()) {
            $opSignal.LogCritical("❌ No Condenser adapter produced a valid result.")
        }

        $this.Signal.MergeSignal($opSignal)
        return $opSignal
    }
}
