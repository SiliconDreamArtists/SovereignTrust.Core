class ConductionResult {
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
    [bool]$ConductionResultSuccessful
    [string]$RelayName
    [bool]$RelayConductionResult
    [Guid]$ConductionIdentifier
    [Guid]$RelayConductionPlanVersion

    ConductionResult() {
        # Default initialization
        $this.ResultMessages = New-Object 'System.Collections.Generic.List[string]'
        $this.ConductionSuccessful = $false
        $this.ConductionResultSuccessful = $false
        $this.RelayConductionResult = $false
    }

    [string] GetConductionStatusCode() {
        if ($this.ConductionSuccessful) {
            return 'SUCCESS'
        } else {
            return 'FAILURE'
        }
    }
}
