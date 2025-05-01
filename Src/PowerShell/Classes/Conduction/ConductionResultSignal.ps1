class ConductionResultSignal {
    [Guid]$WireIdentifier
    [Guid]$Version
    [Guid]$TriggerIdentifier
    [string]$WireName
    [Nullable[Guid]]$ConduitVersion
    [string]$ConductionSourceId
    [datetime]$DateTime
    [int]$RecordsCollected
    [string]$ConductionName
    [System.Collections.Generic.List[string]]$ResultMessages
    [bool]$ConductionSuccessful
    [bool]$ConductionResultSignalSuccessful
    [string]$RelayName
    [bool]$RelayConductionResultSignal
    [Guid]$ConductionIdentifier
    [Guid]$RelayConductionPlanVersion

    ConductionResultSignal() {
        # Default initialization
        $this.ResultMessages = New-Dictionary 'System.Collections.Generic.List[string]'
        $this.ConductionSuccessful = $false
        $this.ConductionResultSignalSuccessful = $false
        $this.RelayConductionResultSignal = $false
    }

    [string] GetConductionStatusCode() {
        if ($this.ConductionSuccessful) {
            return 'SUCCESS'
        } else {
            return 'FAILURE'
        }
    }
}
