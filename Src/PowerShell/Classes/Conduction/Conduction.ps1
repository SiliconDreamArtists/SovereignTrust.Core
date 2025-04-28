class Conduction {
    [Guid]$Identifier
    [Guid]$MemorySlice
    [Guid]$WireIdentifier
    [Guid]$Version
    [Guid]$TriggerIdentifier
    [Guid]$ConductionIdentifier
    [Guid]$ConduitVersion
    [Guid]$ConduitIdentifier
    [Guid]$WireVersion
    [Guid]$ConductionFeedbackIdentifier

    [string]$ConductionCallId
    [string]$ConductionName
    [string]$ConductionStatusCode
    [string]$Result
    [string]$CreatedBy
    [string]$LastModifiedBy
    [string]$ConductionFeedbackLevel

    [datetime]$CreatedDate
    [datetime]$LastModifiedDate

    [bool]$HasConductionRelayResult
    [bool]$PerformRelay
    [bool]$IsDeleted
    [bool]$IsReadOnly

    [object]$ConductionFeedback
    [object]$ConductionResult

    [Signal]$Signal

    Conduction() {
        # Preallocate a GUID directly at creation time
        $this.Identifier = [Guid]::NewGuid()

        # Defer the Signal object instantiation for optional attach if needed
        $this.Signal = [Signal]::Start()
    }
}
