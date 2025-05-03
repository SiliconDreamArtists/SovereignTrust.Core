
# =============================================================================
# 🧠 Graph (Working Memory + Condensation Output)
# =============================================================================
# The Graph object represents the live working memory during a condensation run.
# It holds the parsed XML document (`XmlRepresentation`), tracks unresolved
# mappings and structural anomalies, and logs the entire condensation lifecycle
# through its internal Signal (`GraphSignal`). It is the ceremonial output of a
# GraphCondenser — able to be persisted, reviewed, or executed upon. Graphs are
# where dimensional input becomes applied memory, ready for sovereign evolution.

class OldGraph {
    [object]$Metadata
    [object[]]$BlockContext
    [object]$XmlRepresentation
    [string]$GraphContent
    [Signal]$GraphSignal
    [hashtable]$UnresolvedRequiredMappings
    [object[]]$BlocksWithUnresolvedDictionaries
    [object[]]$BlocksWithUnresolvedBlockContexts

    Graph() {
        $this.Metadata = $null
        $this.BlockContext = @() 
        $this.XmlRepresentation = $null
        $this.GraphContent = ""
        $this.GraphSignal = [Signal]::new("GraphProcessingSignal")
        $this.UnresolvedRequiredMappings = @{ }
        $this.BlocksWithUnresolvedDictionaries = @()
        $this.BlocksWithUnresolvedBlockContexts = @() 
    }

    [void] Start() {
        # Initialize BlockContext if null
        if (-not $this.BlockContext) { 
            $this.BlockContext = @() 
        }

        # Basic validation and initialization
        if (-not $this.Metadata) {
            $this.GraphSignal.LogCritical("Metadata is unresolved. Cannot Start Graph.")
            throw "Metadata is unresolved. Cannot Start Graph."
        }
    }

    [void] Finalize() {  
        $this.SignalUnresolvedStatus() 
    }

    [void] SignalUnresolvedStatus() {
        # Expanded summary logic with additional checks
        if ($this.UnresolvedRequiredMappings.Count -gt 0) {
            $this.GraphSignal.LogWarning("Unresolved Required Mappings Detected.")
        }
        if ($this.BlocksWithUnresolvedDictionaries.Count -gt 0) {
            $this.GraphSignal.LogWarning("Unresolved Dictionaries Detected.")
        }
        if ($this.BlocksWithUnresolvedBlockContexts.Count -gt 0) {
            $this.GraphSignal.LogWarning("Unresolved Block Contexts Detected.") 
        }
    }

    [void] SetUnresolvedMappingFeedback([object]$MetadataBlock, [object]$MetadataMapping) {
        if (-not $this.UnresolvedRequiredMappings.ContainsKey($MetadataBlock)) {
            $this.UnresolvedRequiredMappings[$MetadataBlock] = @()
        }
        $this.UnresolvedRequiredMappings[$MetadataBlock] += $MetadataMapping
        $this.GraphSignal.LogInformation("Unresolved mapping feedback set for $($MetadataBlock).")
    }

    [void] ReportUnresolvedDictionary([object]$MetadataBlock) {
        $this.BlocksWithUnresolvedDictionaries += $MetadataBlock
        $this.GraphSignal.LogInformation("Reported unresolved dictionary for $($MetadataBlock).")
    }

    [void] ReportUnresolvedBlockNode([object]$MetadataBlock) {
        $this.BlocksWithUnresolvedBlockContexts += $MetadataBlock
        $this.GraphSignal.LogInformation("Reported unresolved block context for $($MetadataBlock).")  
    }

    [void] ReportException([Exception]$ex) {
        $this.GraphSignal.LogCritical("Exception occurred: $($ex.Message)")
        if ($this.GraphSignal) {
            $this.GraphSignal.MergeSignal(@($this.GraphSignal))
        }
    }
}
