class Jacket {
    [string]$Type                # Wire, Trigger, Metadata, etc.
    [guid]$Identifier             # Unique ID for this jacket
    [guid]$Version                # Version ID (optional for versioned items)
    [string]$Name                 # Friendly name
    [string]$Environment          # For environment-specific items (optional)
    [string]$UserName             # Who created or owns it (optional)

    [hashtable]$Attributes        # Dynamic key-value store for anything
    [hashtable]$Relationships     # Pointer IDs to other jackets/wires (like LeadWire, GroundWire, CrossWire, etc.)

    Jacket() {
        $this.Attributes = @{}
        $this.Relationships = @{}
    }

    [void] SetAttribute([string]$Key, [object]$Value) {
        $this.Attributes[$Key] = $Value
    }

    [object] GetAttribute([string]$Key) {
        return $this.Attributes[$Key]
    }

    [void] AddRelationship([string]$RelationType, [guid]$TargetIdentifier) {
        $this.Relationships[$RelationType] = $TargetIdentifier
    }

    [guid] GetRelationship([string]$RelationType) {
        return $this.Relationships[$RelationType]
    }
}
