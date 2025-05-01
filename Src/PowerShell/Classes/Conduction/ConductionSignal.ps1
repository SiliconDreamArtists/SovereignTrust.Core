class ConductionSignal {
    [string]$CallStatusCode
    [datetime]$ConductionDate
    [Guid]$ConductionIdentifier
    [object]$ConductionResultSignal    
    [Guid]$ConduitVersion
    [string]$ExternalCallResult
    [string]$ExternalCallId
    [Guid]$JacketIdentifier
    [bool]$PersistConductionResultSignal
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

    ConductionSignal() {
        # Default initialization
        $this.PersistConductionResultSignal = $false
        $this.PerformRelay = $true
        $this.SkipCheckingExternalCallResult = $false
        $this.RelayData = @{}
    }
}
