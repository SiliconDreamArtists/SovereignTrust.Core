class MappedNetworkAttachment {
    [Conductor]$Conductor
    [hashtable]$ServiceCollection
    $MyName = "MappedNetworkAttachment"

    MappedNetworkAttachment([Conductor]$conductor) {
        $this.ServiceCollection = @{}
        $this.Conductor = $conductor
    }

    [Signal] RegisterAttachment([object]$networkService) {
        return Register-MappedAttachment -ServiceCollection $this.ServiceCollection -Attachment $networkService -Label "NetworkService"
    }
    
    [Signal] SendAsync([string]$channel, [string]$message, $messageDynamic) {
        $signal = [Signal]::new("SendAsync")

        foreach ($service in $this.ServiceCollection.Keys) {
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
        $signal = [Signal]::new("CompleteMessageAsync")

        foreach ($service in $this.ServiceCollection.Keys) {
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
        foreach ($service in $this.ServiceCollection.Keys) {
            if ($service -and ($service | Get-Member -Name "StartListening")) {
                $service.StartListening($autoComplete)
            }
        }
    }
}
