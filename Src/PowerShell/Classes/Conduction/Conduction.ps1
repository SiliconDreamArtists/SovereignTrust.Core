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
    [Guid]$ConductionSignalIdentifier

    [string]$ConductionCallId
    [string]$ConductionName
    [string]$ConductionStatusCode
    [string]$Result
    [string]$CreatedBy
    [string]$LastModifiedBy
    [string]$ConductionSignalLevel

    [datetime]$CreatedDate
    [datetime]$LastModifiedDate

    [bool]$HasConductionRelayResult
    [bool]$PerformRelay
    [bool]$IsDeleted
    [bool]$IsReadOnly

    [object]$ConductionSignal
    [object]$ConductionResultSignal

    [Signal]$Signal

    Conduction() {
        # Preallocate a GUID directly at creation time
        $this.Identifier = [Guid]::NewGuid()

        # Defer the Signal object instantiation for optional attach if needed
        $this.Signal = [Signal]::Start()
    }
}
