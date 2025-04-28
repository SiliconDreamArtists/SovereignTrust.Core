class Wire {
    [string]$Name
    [string]$Key
    [string]$Nature
    [string]$Description

    [string]$VirtualPath
    [string[]]$VirtualPaths
    [string]$CondensedVirtualPath
    [string]$ContentString
    [object]$ContentDynamic
    [object]$CondensedDynamic
    [object]$ContentObject

    [string]$WireNestPath
    [string]$GroundNestPath

    [string]$Language
    [bool]$IsEnabled
    [bool]$IsReadOnlyContent
    [bool]$FlattenOutput
    [bool]$OutputIsConduction
    [bool]$MergeJacket

    [string]$AssignedToUserName
    [string]$UserName

    # Wire Relationships
    [Guid]$LeadWireIdentifier
    [Guid]$GroundWireIdentifier
    [Guid]$CrossWireIdentifier
    [Guid]$PrecursorWireIdentifier
    [Guid]$RelayControlWireIdentifier

    [Guid]$LeadVersion
    [Guid]$GroundVersion
    [Guid]$CrossVersion
    [Guid]$PrecursorVersion

    [string]$PrecursorRelayCollections

    # Relay Tracking
    [Guid]$RelaySourceWireIdentifier
    [string]$RelayFileName
    [string]$RelaySourceDataFolders
    [string]$RelayingConductionSourceId
    [Guid]$RelayingVersion
    [Guid]$RelayingWireIdentifier

    # Conduit and Control
    [Guid]$ConduitIdentifier
    [Guid]$ConduitVersion
    [Guid]$ProposalControlWireIdentifier

    # Merge Types
    [string]$LeadMergeType
    [string]$GroundMergeType
    [string]$JacketMergeType

    # Document Formats
    [string]$DocumentFormat
    [string]$WireFormat

    # Privacy and Status
    [string]$PrivacyType
    [bool]$HasTrigger
    [bool]$IncludesConductionTokens
    [bool]$IncludeUplink

    # Sync Metadata
    [datetime]$LastContentModifiedDate
    [datetime]$LastSyncDate
    [datetime]$LastAttemptedSyncDate
    [bool]$IsSyncSuccessful
    [bool]$ForceSync

    Wire() {
        $this.VirtualPaths = @()
    }

    [void] BuildVirtualPaths() {
        if (-not $this.VirtualPaths -and $this.VirtualPath) {
            $this.VirtualPaths = @($this.VirtualPath)
        }
    }
}
