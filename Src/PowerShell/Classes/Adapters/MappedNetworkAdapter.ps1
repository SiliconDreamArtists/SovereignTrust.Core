class MappedNetworkAdapter {
    [Signal]$Signal

    MappedNetworkAdapter() {
        # Static Start() pattern only
    }

    static [Signal] Start([object]$Conductor) {
        $opSignal = [Signal]::Start("MappedNetworkAdapter.Start") | Select-Object -Last 1

        if (-not $Conductor) {
            $opSignal.LogCritical("❌ Null Conductor passed to MappedNetworkAdapter.Start()")
            return $opSignal
        }

        try {
            $adapter = [MappedNetworkAdapter]::new()
            $adapter.Signal = [Signal]::Start("MappedNetworkAdapter") | Select-Object -Last 1
            $adapter.Signal.SetJacket($Conductor)
            $adapter.Signal.SetReversePointer($Conductor)

#            $envSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "Environment" | Select-Object -Last 1
#            if ($opSignal.MergeSignalAndVerifyFailure(@($envSignal))) { return $opSignal }

#            $adapter.Signal.LogInformation("✅ Environment resolved for MappedNetworkAdapter")
            $graphSignal = [Graph]::Start("MappedNetworkAdapter.Services", $adapter, $false)
            $adapter.Signal.SetResult($graphSignal.GetResult())

            $opSignal.SetResult($adapter)
            $opSignal.LogInformation("✅ MappedNetworkAdapter initialized.")
        }
        catch {
            $opSignal.LogCritical("💥 Exception in MappedNetworkAdapter.Start(): $_")
        }

        return $opSignal
    }

    [Signal] RegisterAdapter([object]$networkService, [string]$Key = "NetworkService") {
        $opSignal = [Signal]::Start("RegisterMappedAdapter:$Key") | Select-Object -Last 1
        $adapterSignal = [Signal]::Start("Adapter:$Key") | Select-Object -Last 1
        $adapterSignal.SetResult($networkService)

        $graph = $this.Signal.GetResult()
        $registerSignal = $graph.RegisterSignal($Key, $adapterSignal)
        $opSignal.MergeSignal($registerSignal)

        if ($registerSignal.Success()) {
            $opSignal.LogInformation("✅ Registered network adapter at key: '$Key'")
        } else {
            $opSignal.LogWarning("⚠️ Failed to register network adapter at key: '$Key'")
        }

        $this.Signal.MergeSignal($opSignal)
        return $opSignal
    }

    [Signal] SendAsync([string]$channel, [string]$message, $messageDynamic) {
        return $this.InvokeAdapterMethod("SendAsync", @($channel, $message, $messageDynamic))
    }

    [Signal] CompleteMessageAsync([object]$message) {
        return $this.InvokeAdapterMethod("CompleteMessageAsync", @($message))
    }

    [void] StartListening([bool]$autoComplete) {
        $graph = $this.Signal.GetResult()
        foreach ($key in $graph.Grid.Keys) {
            $adapterSignal = $graph.Grid[$key]
            $adapter = $adapterSignal.GetResult()

            if ($adapter -and ($adapter | Get-Member -Name "StartListening")) {
                $adapter.StartListening($autoComplete)
            }
        }
    }

    [Signal] InvokeAdapterMethod([string]$MethodName, [object[]]$Args) {
        $opSignal = [Signal]::Start("MappedNetworkAdapter.Invoke:$MethodName") | Select-Object -Last 1
        $graph = $this.Signal.GetResult()

        foreach ($key in $graph.Grid.Keys) {
            $adapterSignal = $graph.Grid[$key]
            $adapter = $adapterSignal.GetResult()

            if ($null -ne $adapter -and ($adapter | Get-Member -Name $MethodName)) {
                $result = $adapter.InvokeMethod($MethodName, $Args)
                $opSignal.MergeSignal($result)

                if ($result.Success()) {
                    $opSignal.SetResult($result.GetResult())
                    $opSignal.LogInformation("🎯 Network adapter '$key' successfully invoked '$MethodName'")
                    break
                } else {
                    $opSignal.LogWarning("⚠️ Network adapter '$key' failed on method '$MethodName'")
                }
            } else {
                $opSignal.LogVerbose("⏭️ Network adapter '$key' does not implement '$MethodName'")
            }
        }

        if (-not $opSignal.Success()) {
            $opSignal.LogCritical("❌ No network adapter succeeded for method '$MethodName'")
        }

        $this.Signal.MergeSignal($opSignal)
        return $opSignal
    }
}
