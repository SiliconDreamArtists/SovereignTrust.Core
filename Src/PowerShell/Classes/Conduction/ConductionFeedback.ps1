class ConductionFeedback {
    [string]$CallStatusCode
    [datetime]$ConductionDate
    [Guid]$ConductionIdentifier
    [object]$ConductionResult    
    [Guid]$ConduitVersion
    [string]$ExternalCallResult
    [string]$ExternalCallId
    [Guid]$JacketIdentifier
    [bool]$PersistConductionResult
    [bool]$PerformRelay
    [Nullable[datetime]]$RejoinderStartDate
    [hashtable]$RelayData        
    [Guid]$RelayConductionVersion
    [string]$RelayName
    [bool]$SkipCheckingExternalCallResult
    [Nullable[Guid]]$TriggerIdentifier
    [Guid]$Version
    [Guid]$WireIdentifier
    [string]$WireName

    ConductionFeedback() {
        # Default initialization
        $this.PersistConductionResult = $false
        $this.PerformRelay = $true
        $this.SkipCheckingExternalCallResult = $false
        $this.RelayData = @{}
    }
}
