# Conductor.ps1
# SovereignTrust Minimal Conductor Class

class Conductor {
    [string]$Id
    [hashtable]$RunModel
    [object]$PrimaryConduit
    [System.Collections.Generic.List[object]]$ServiceConduits
    [hashtable]$Attachments
    [System.Collections.Queue]$QueueSurface
    [string]$ExecutionMode  # 'Sequential' or 'Parallel'
    [string]$Status

    Conductor([string]$id) {
        $this.Id = $id
        $this.RunModel = @{}
        $this.ServiceConduits = [System.Collections.Generic.List[object]]::new()
        $this.Attachments = @{}
        $this.QueueSurface = [System.Collections.Queue]::new()
        $this.ExecutionMode = "Sequential"
        $this.Status = "Initialized"
    }

    [void] AttachPrimaryConduit([object]$conduit) {
        $this.PrimaryConduit = $conduit
    }

    [void] AddServiceConduit([object]$conduit) {
        $this.ServiceConduits.Add($conduit)
    }

    [void] MountAttachment([string]$name, [object]$attachment) {
        $this.Attachments[$name] = $attachment
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
