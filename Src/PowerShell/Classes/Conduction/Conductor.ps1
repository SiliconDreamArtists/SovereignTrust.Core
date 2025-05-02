# Conductor.ps1
# SovereignTrust Minimal Conductor Class

class Conductor {
    [string]$Id
    [hashtable]$ContextModel
    [Conduit]$PrimaryConduit
    [bool]$IsHostConductor = $false
    [Conductor]$HostConductor
    [hashtable]$MappedAttachments
    [hashtable]$Attachments
    [System.Collections.Generic.List[object]]$AttachmentJackets
    [string]$Status
    
    # New properties for full bonding
    [object]$Environment
    [string]$AgentName
    [string]$RoleName
    [object]$PrimaryAgent
    [System.Collections.Generic.List[object]]$SecondaryAgents

    Conductor([string]$id, [Conductor]$hostConductor = $null) {
        $this.Id = $id
        $this.HostConductor = $hostConductor
        $this.IsHostConductor = $null -eq $hostConductor
        $this.MappedAttachments = @{}
        $this.AttachmentJackets = [System.Collections.Generic.List[object]]::new()
        $this.Status = "Initialized"
        $this.SecondaryAgents = [System.Collections.Generic.List[object]]::new()

        $this.LoadMappedAttachments()
    }

    [void] LoadMappedAttachments() {
        $mappedStorage = [MappedStorageAttachment]::new($this)
        Add-PathToDictionary -Dictionary $this.MappedAttachments -Path "Storage" -Value $mappedStorage

        $mappedNetwork = [MappedNetworkAttachment]::new($this)
        Add-PathToDictionary -Dictionary $this.MappedAttachments -Path "Network" -Value $mappedNetwork
    }

    [void] AttachPrimaryConduit([Conduit]$conduit) {
        $this.PrimaryConduit = $conduit
    }
}
