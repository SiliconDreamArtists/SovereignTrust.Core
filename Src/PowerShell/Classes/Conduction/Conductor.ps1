# Conductor.ps1
# SovereignTrust Minimal Conductor Class

class Conductor {
    [string]$Id
    [hashtable]$ContextModel
    [Conduit]$PrimaryConduit
    [hashtable]$MappedAttachments
    [hashtable]$Attachments
    [System.Collections.Generic.List[object]]$AttachmentJackets
    [string]$Status
    
    # New properties for full bonding
    [string]$Environment
    [string]$AgentName
    [string]$RoleName
    [object]$PrimaryAgent
    [System.Collections.Generic.List[object]]$SecondaryAgents

    Conductor([string]$id) {
        $this.Id = $id
        $this.MappedAttachments = @{}
        $this.AttachmentJackets = [System.Collections.Generic.List[object]]::new()
        $this.Status = "Initialized"
        $this.SecondaryAgents = [System.Collections.Generic.List[object]]::new()

        $this.LoadMappedAttachments()
    }

    [void] LoadMappedAttachments() {
        $mappedStorage = [MappedStorageAttachment]::new()
        Add-PathToDictionary -Dictionary $this.MappedAttachments -Path "Storage" -Value $mappedStorage
    }

    [void] AttachPrimaryConduit([Conduit]$conduit) {
        $this.PrimaryConduit = $conduit
    }
}
