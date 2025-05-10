class MappedNetworkAdapter {
    [object]$Conductor
    [Graph]$ServiceCollection
    [object]$Environment
    $MyName = "MappedNetworkAdapter"

    MappedNetworkAdapter([object]$conductor) {
        $this.Conductor = $conductor

        $envSignal = Resolve-PathFromDictionary -Dictionary $conductor -Path "Environment" | Select-Object -Last 1
        if ($envSignal.Failure()) {
            throw "❌ Unable to resolve Environment from Conductor."
        }

        $this.Environment = $envSignal.GetResult()
        $this.ServiceCollection = [Graph]::new($this.Environment)
    }

    [Signal] RegisterAdapter([object]$networkService) {
        return Register-MappedAdapter -ServiceCollection $this.ServiceCollection -Adapter $networkService -Label "NetworkService"
    }

    [Signal] SendAsync([string]$channel, [string]$message, $messageDynamic) {
        $signal = [Signal]::Start("SendAsync")

        foreach ($key in $this.ServiceCollection.Grid.Keys) {
            $serviceSignal = $this.ServiceCollection.Grid[$key]
            $service = $serviceSignal.GetResult()

            if ($service -and ($service | Get-Member -Name "SendAsync")) {
                $result = $service.SendAsync($channel, $message, $messageDynamic)
                $signal.MergeSignal(@($result))

                if ($result.Success()) {
                    $signal.SetResult($result.GetResult())
                    break
                }
            }
        }

        if (-not $signal.Success()) {
            $signal.LogCritical("All network services failed to send async message.")
        }

        return $signal
    }

    [Signal] CompleteMessageAsync([object]$message) {
        $signal = [Signal]::Start("CompleteMessageAsync")

        foreach ($key in $this.ServiceCollection.Grid.Keys) {
            $serviceSignal = $this.ServiceCollection.Grid[$key]
            $service = $serviceSignal.GetResult()

            if ($service -and ($service | Get-Member -Name "CompleteMessageAsync")) {
                $result = $service.CompleteMessageAsync($message)
                $signal.MergeSignal(@($result))

                if ($result.Success()) {
                    $signal.SetResult($result.GetResult())
                    break
                }
            }
        }

        if (-not $signal.Success()) {
            $signal.LogCritical("All network services failed to complete message.")
        }

        return $signal
    }

    [void] StartListening([bool]$autoComplete) {
        foreach ($key in $this.ServiceCollection.Grid.Keys) {
            $serviceSignal = $this.ServiceCollection.Grid[$key]
            $service = $serviceSignal.GetResult()

            if ($service -and ($service | Get-Member -Name "StartListening")) {
                $service.StartListening($autoComplete)
            }
        }
    }
}
