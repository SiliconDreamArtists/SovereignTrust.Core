# =============================================================================
# 🧠 Graph (Working Memory using a SignalGrid)
# =============================================================================
# The Graph object represents the live working memory during a conduction which can have an infiniate amount of internal conductions, so a user or ai may open a conduction with a graph and then perform a series of .
# The Graph is a ordered dictionary of Signals, which are the building blocks of the Graph. The Graph has a central Signal itself for tracking current state.
# The Signals in the grid have a Result which is a jacket for the hidden object in the Signal a _Memory which holds the memory of the signal and is transparently accessed with Resolve-PathFromDictionary and Add-PathToDictionary.
# The Result contains the settings for the signal in a dictionary, such as a physical file path, a VirtualPath that provides the wire hierarchy and anything else required, also easily accessible via Resolve-PathFromDictionary and Add-PathToDictionary.

class Graph {
    [object]$Environment
    [Signal]$GraphSignal
    [ordered]$SignalGrid
    [ordered]$_Memory

    Graph([object]$environment) {
        $this.Environment = $environment
        $this.GraphSignal = [Signal]::new("GraphSignal")
        $this.SignalGrid = [ordered]@{}
        $this._Memory = $this.SignalGrid
    }

    [void] Start() {
        $this.GraphSignal.LogInformation("🧠 Graph condensation process started.")
    }

    [void] Finalize() {
        $this.GraphSignal.LogInformation("✅ Graph condensation finalized. Total Signals: $($this.SignalGrid.Count)")
    }

    [void] RegisterSignal([string]$Key, [Signal]$Signal) {
        if ($this.SignalGrid.Contains($Key)) {
            $this.GraphSignal.LogWarning("⚠️ Overwriting existing signal at key: $Key")
        }
        $this.SignalGrid[$Key] = $Signal
        $this.GraphSignal.LogVerbose("🔗 Signal registered under key: $Key")
    }

    [void] UnRegisterSignal([string]$Key) {
        if ($this.SignalGrid.Contains($Key)) {
            $this.SignalGrid.Remove($Key)
            $this.GraphSignal.LogVerbose("🔓 Signal unregistered at key: $Key")
        } else {
            $this.GraphSignal.LogWarning("⚠️ Attempted to unregister missing signal at key: $Key")
        }
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
    
    static [Graph] FromJson([string]$json, [bool]$IgnoreInternalObjects = $false) {
        $signal = [Signal]::new("Graph.FromJson")
    
        try {
            $jsonObject = $json | ConvertFrom-Json -Depth 25
            $_graphSignal = Convert-JsonObjectToGraph -JsonObject $jsonObject -IgnoreInternalObjects:$IgnoreInternalObjects | Select-Object -Last 1
    
            if ($signal.MergeSignalAndVerifyFailure($_graphSignal)) {
                $signal.LogCritical("❌ Failed to reconstruct Graph from JSON object.")
                return $null
            }
    
            $graph = $_graphSignal.GetResult()
            return $graph
        }
        catch {
            $signal.LogCritical("🔥 Exception during Graph.FromJson(): $($_.Exception.Message)")
            return $null
        }
    }
}
