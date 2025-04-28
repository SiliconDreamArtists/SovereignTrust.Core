class Conduit {
    [Guid]$ConduitIdentifier
    [string]$ConduitType = "Unspecified"
    [object]$Context
    [object]$Feedback
    [bool]$IsRunning = $false
    [hashtable]$TransientTypeDictionary = @{}
    [hashtable]$SingletonTypeDictionary = @{}
    [object]$ServiceContainer 
    [object]$ConduitJacket

    Conduit() {
        $this.ConduitIdentifier = [Guid]::NewGuid()
#        $this.Context = [ConductionContext]::new()
#        $this.Feedback = [ConductionFeedback]::new()
    }

    [void] EngageConduitJacket([object]$conduitJacket, [hashtable]$transientTypeDictionary, [hashtable]$singletonTypeDictionary) {
        $this.ConduitJacket = $conduitJacket
        if ($transientTypeDictionary) { $this.TransientTypeDictionary = $transientTypeDictionary }
        if ($singletonTypeDictionary) { $this.SingletonTypeDictionary = $singletonTypeDictionary }
    }

    [void] StartConduction() {
        $this.IsRunning = $true
        # Load or initialize context if needed
    }

    [void] ExecutePhase([object]$phase) {
        # Minimal stub — extend when you wire Phase classes
        if (-not $this.IsRunning) { throw "Conduit is not running." }
        
        # Example: process a Phase here
        $phaseName = $phase.PhaseName
        $this.Context.PhaseHistory += $phaseName
    }

    [void] CompleteConduction() {
        # Finalize conduction
        $this.Feedback.ConductionIdentifier = $this.ConduitIdentifier
        $this.Feedback.ConductionDate = (Get-Date)
        $this.IsRunning = $false
    }
}
