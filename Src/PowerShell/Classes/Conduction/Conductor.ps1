# Conductor.ps1
# SovereignTrust Minimal Conductor Class

class Conductor {
    [string]$Id
    [hashtable]$RunModel
    [object]$PrimaryConduit
    [System.Collections.Generic.List[object]]$ServiceConduits
    [hashtable]$MappedAttachments
    [hashtable]$Attachments
    [System.Collections.Generic.List[object]]$AttachmentJackets
    [System.Collections.Queue]$QueueSurface
    [string]$ExecutionMode  # 'Sequential' or 'Parallel'
    [string]$Status
    
    # New properties for full bonding
    [string]$Environment
    [string]$AgentName
    [string]$RoleName
    [object]$PrimaryAgent
    [System.Collections.Generic.List[object]]$SecondaryAgents

    Conductor([string]$id) {
        $this.Id = $id
        $this.RunModel = @{}
        $this.ServiceConduits = [System.Collections.Generic.List[object]]::new()
        $this.MappedAttachments = @{}
#        $this.Attachments = @{}
        $this.AttachmentJackets = [System.Collections.Generic.List[object]]::new()
        $this.QueueSurface = [System.Collections.Queue]::new()
        $this.ExecutionMode = "Sequential"
        $this.Status = "Initialized"
        $this.SecondaryAgents = [System.Collections.Generic.List[object]]::new()

        $this.LoadMappedAttachments()
    }

    [void] LoadMappedAttachments() {
        $mappedStorage = [MappedStorageAttachment]::new()
        Add-PathToDictionary -Dictionary $this.MappedAttachments -Path "Storage" -Value $mappedStorage
    }

    [void] AttachPrimaryConduit([object]$conduit) {
        $this.PrimaryConduit = $conduit
    }

    [void] AddServiceConduit([object]$conduit) {
        $this.ServiceConduits.Add($conduit)
    }

    [void] MountAttachment([string]$name, [object]$attachment) {
        Add-PathToDictionary -Dictionary $this.Attachments -Path $name -Value $attachment
    }

    [void] EnqueueSignal([object]$signal) {
        $this.QueueSurface.Enqueue($signal)
    }

    [object] DequeueSignal() {
        if ($this.QueueSurface.Count -gt 0) {
            return $this.QueueSurface.Dequeue()
        } else {
            return $null
        }
    }

    [void] StartConductionLoop() {
        $this.Status = "Active"

        while ($this.Status -eq "Active") {
            $signal = $this.DequeueSignal()

            if ($null -ne $signal) {
                if ($this.ExecutionMode -eq "Sequential") {
                    $this.ProcessSignalSequential($signal)
                } elseif ($this.ExecutionMode -eq "Parallel") {
                    $null = Start-Job { $this.ProcessSignalSequential($using:signal) }
                }
            } else {
                Start-Sleep -Milliseconds 100  # Idle sleep to prevent tight loop
            }
        }
    }

    [void] ProcessSignalSequential([object]$signal) {
        if ($null -ne $this.PrimaryConduit) {
            $this.PrimaryConduit.InvokeConduit($signal)
        }

        foreach ($serviceConduit in $this.ServiceConduits) {
            $serviceConduit.InvokeConduit($signal)
        }
    }

    [void] StopConductionLoop() {
        $this.Status = "Paused"
    }
}
