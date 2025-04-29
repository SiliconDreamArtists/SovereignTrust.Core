function Convert-AgentAttachmentsToConductor {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Agent,

        [Parameter(Mandatory = $true)]
        [object]$Conductor
    )

    $signal = [Signal]::new("Convert-AgentAttachmentsToConductor")

    try {
        if (-not $Agent) {
            $signal.LogCritical("Agent is null. Cannot process attachments.")
            return $signal
        }

        if (-not $Conductor) {
            $signal.LogCritical("Conductor is null. Cannot assign attachments.")
            return $signal
        }

        # Ensure AttachmentJackets memory exists
        $attachmentJacketsSignal = Resolve-SignalPathFromDictionary -Dictionary $Conductor -Path "AttachmentJackets" | Select-Object -Last 1
        $attachmentJackets = $attachmentJacketsSignal.Result

        if ($null -eq $attachmentJackets) {
            $val = [System.Collections.Generic.List[object]]::new()
            Add-PathToDictionary -Dictionary $Conductor -Path "AttachmentJackets" -Value $val
            #$attachmentJackets = Resolve-PathFromDictionary -Dictionary $Conductor -Path "AttachmentJackets"
            $signal.LogVerbose("Initialized empty AttachmentJackets memory space on Conductor.")
        }

        # Migrate Agent-level Attachment Jackets
        $agentAttachments = Resolve-PathFromDictionary -Dictionary $Agent -Path "Attachments"
        if ($agentAttachments) {
            foreach ($attachmentJacket in $agentAttachments) {
                if ($attachmentJacket.Name) {
                    Add-PathToDictionary -Dictionary $Conductor -Path "AttachmentJackets.$($attachmentJacket.Name)" -Value $attachmentJacket
                    $signal.LogVerbose("Mapped Agent Attachment Jacket: $($attachmentJacket.Name)")
                } else {
                    $signal.LogWarning("Skipped Agent attachment jacket with missing name.")
                }
            }
            $signal.LogInformation("Agent-level attachment jackets migrated to Conductor.")
        } else {
            $signal.LogWarning("No Agent attachments found to migrate.")
        }

        # Migrate CurrentRole-level Attachment Jackets
        $roleAttachments = Resolve-PathFromDictionary -Dictionary $Agent -Path "Memory.CurrentRole.Attachments"
        if ($roleAttachments) {
            foreach ($roleAttachmentJacket in $roleAttachments) {
                if ($roleAttachmentJacket.Name) {
                    Add-PathToDictionary -Dictionary $Conductor -Path "Memory.AttachmentJackets.$($roleAttachmentJacket.Name)" -Value $roleAttachmentJacket
                    $signal.LogVerbose("Mapped Role Attachment Jacket: $($roleAttachmentJacket.Name)")
                } else {
                    $signal.LogWarning("Skipped Role attachment jacket with missing name.")
                }
            }
            $signal.LogInformation("Role-level attachment jackets migrated to Conductor.")
        } else {
            $signal.LogWarning("No CurrentRole attachments found to migrate.")
        }

        $signal.SetResult($Conductor)
    }
    catch {
        $signal.LogCritical("Unhandled critical failure in Convert-AgentAttachmentsToConductor: $_")
    }

    return $signal
}
