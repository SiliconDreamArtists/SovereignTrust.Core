# =============================================================================
# 🧠 Graph (Working Memory using a SignalGrid)
#  License: MIT License • Copyright (c) 2025 Silicon Dream Artists / BDDB
#  Authors: Shadow PhanTom ☠️🧁👾️/🤖 • Neural Alchemist ⚗️☣️🐲 • Last Generated: 05/02/2025
# =============================================================================
# The Graph object represents the live working memory during a conduction which can have an infiniate amount of internal conductions, so a user or ai may open a conduction with a graph and then perform a series of .
# The Graph is a ordered dictionary of Signals, which are the building blocks of the Graph. The Graph has a central Signal itself for tracking current state.
# The Signals in the grid have a Result which is a jacket for the hidden object in the Signal a _Memory which holds the memory of the signal and is transparently accessed with Resolve-PathFromDictionary and Add-PathToDictionary.
# The Result contains the settings for the signal in a dictionary, such as a physical file path, a VirtualPath that provides the wire hierarchy and anything else required, also easily accessible via Resolve-PathFromDictionary and Add-PathToDictionary.

class Graph {
    [object]$Environment
    [Signal]$ControlSignal
    [ordered]$SignalGrid
    [ordered]$_Memory

    Graph([object]$environment) {
        $this.Environment = $environment
        $this.ControlSignal = [Signal]::new("Signal")
        $this.SignalGrid = [ordered]@{}
        $this._Memory = $this.SignalGrid
    }

    [Signal] Start() {
        $signal = [Signal]::new("Graph.Start")
        $signal.LogInformation("🧠 Graph condensation process started.")
        $this.ControlSignal.MergeSignal($signal)
        return $signal
    }
    
    [Signal] Finalize() {
        $signal = [Signal]::new("Graph.Finalize")
        $signal.LogInformation("✅ Graph condensation finalized. Total registered signals: $($this.SignalGrid.Count)")
        $this.ControlSignal.MergeSignal($signal)
        return $signal
    }
    
    [Signal] RegisterSignal([string]$Key, [Signal]$Signal) {
        $opSignal = [Signal]::new("RegisterSignal:$Key")

        if ($this.SignalGrid.Contains($Key)) {
            $opSignal.LogWarning("⚠️ Overwriting existing signal at key: $Key")
        }

        $this.SignalGrid[$Key] = $Signal
        $opSignal.LogVerbose("🔗 Signal registered under key: $Key")

        $this.ControlSignal.MergeSignal($opSignal)
        return $opSignal
    }

    [Signal] UnRegisterSignal([string]$Key) {
        $opSignal = [Signal]::new("UnRegisterSignal:$Key")

        if ($this.SignalGrid.Contains($Key)) {
            $this.SignalGrid.Remove($Key)
            $opSignal.LogVerbose("🔓 Signal unregistered at key: $Key")
        }
        else {
            $opSignal.LogWarning("⚠️ Attempted to unregister missing signal at key: $Key")
        }

        $this.ControlSignal.MergeSignal($opSignal)
        return $opSignal
    }

    [Signal] RegisterResultAsSignal([string]$Key, [object]$Result) {
        $resultSignal = [Signal]::new($Key)
        $resultSignal.SetResult($Result)
        $this.ControlSignal.MergeSignal($resultSignal)
        return $this.RegisterSignal($Key, $resultSignal)
    }
    
    [string] ToJson([bool]$IgnoreInternalObjects = $false) {
        $signal = [Signal]::new("Graph.ToJson")
    
        try {
            $jsonObjectSignal = Convert-GraphToJsonObject -Graph $this -IgnoreInternalObjects:$IgnoreInternalObjects | Select-Object -Last 1
            if ($signal.MergeSignalAndVerifyFailure($jsonObjectSignal)) {
                $signal.LogCritical("❌ Failed to convert Graph to JSON object.")
                return $null
            }
    
            $json = $jsonObjectSignal.GetResult() | ConvertTo-Json -Depth 25
            return $json
        }
        catch {
            $signal.LogCritical("🔥 Exception during Graph.ToJson(): $($_.Exception.Message)")
            return $null
        }
    }
    
    static [Signal] FromJson([string]$json, [bool]$IgnoreInternalObjects = $false) {
        $signal = [Signal]::new("Graph.FromJson")
    
        try {
            $jsonObject = $json | ConvertFrom-Json -Depth 25
    
            $conversionSignal = Convert-JsonObjectToGraph -JsonObject $jsonObject -IgnoreInternalObjects:$IgnoreInternalObjects | Select-Object -Last 1
            $signal.MergeSignal($conversionSignal)
    
            if ($conversionSignal.Failure()) {
                $signal.LogCritical("❌ Failed to reconstruct Graph from JSON.")
                $signal.IsTerminal = $true
                return $signal
            }
    
            $graph = $conversionSignal.GetResult()
            $signal.SetResult($graph)
            $signal.LogInformation("✅ Successfully reconstructed Graph from JSON.")
        }
        catch {
            $signal.LogCritical("🔥 Exception in Graph.FromJson: $($_.Exception.Message)")
            $signal.IsTerminal = $true
        }
    
        return $signal
    }
}
