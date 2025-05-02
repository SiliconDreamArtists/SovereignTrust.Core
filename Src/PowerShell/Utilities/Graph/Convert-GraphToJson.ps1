function Convert-GraphToJson {
    param (
        [Parameter(Mandatory = $true)]
        [Graph]$Graph,

        [Parameter()]
        [bool]$IgnoreInternalObjects = $false
    )

    $signal = [Signal]::new("Convert-GraphToJson")

    try {
        $exportObject = @{
            Environment = if ($IgnoreInternalObjects) { $null } else { $Graph.Environment }
            GraphSignal = if ($IgnoreInternalObjects) { $null } else { $Graph.GraphSignal }
            SignalGrid  = @{}
        }

        foreach ($key in $Graph.SignalGrid.Keys) {
            $sig = $Graph.SignalGrid[$key]
            $exportObject.SignalGrid[$key] = if ($IgnoreInternalObjects) {
                $sig.Result  # Only export signal result, skip logs/pointers
            } else {
                $sig
            }
        }

        $json = $exportObject | ConvertTo-Json -Depth 25
        $signal.SetResult($json)
        $signal.LogInformation("✅ Graph successfully serialized into JSON.")
    }
    catch {
        $signal.LogCritical("🔥 Failed to convert Graph to JSON: $($_.Exception.Message)")
    }

    return $signal
}
