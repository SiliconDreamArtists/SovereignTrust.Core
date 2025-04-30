function Convert-AgentAttachmentsToConductor {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Agent,

        [Parameter(Mandatory = $true)]
        [object]$Conductor
    )

    $signal = [Signal]::new("Convert-AgentAttachmentsToConductor")

    function Add-AttachmentJacket {
        param (
            [string]$name,
            [object]$jacket
        )
        Add-PathToDictionary -Dictionary $Conductor -Path "AttachmentJackets.$name" -Value $jacket | Out-Null
        $signal.LogVerbose("Mapped Attachment Jacket: $name")
    }

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
        $attachmentJacketsSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "AttachmentJackets"
        $signal.MergeSignal(@($attachmentJacketsSignal))

        $attachmentJackets = $attachmentJacketsSignal.GetResult()

        if ($null -eq $attachmentJackets) {
            $val = [System.Collections.Generic.List[object]]::new()
            Add-PathToDictionary -Dictionary $Conductor -Path "AttachmentJackets" -Value $val | Out-Null
            $signal.LogVerbose("Initialized empty AttachmentJackets memory space on Conductor.")
        }

        # ░▒▓█ AGENT ATTACHMENTS █▓▒░

        $agentAttachmentsSignal = Resolve-PathFromDictionary -Dictionary $Agent -Path "Attachments"
        $signal.MergeSignal(@($agentAttachmentsSignal))

        if ($agentAttachmentsSignal.Success()) {
            $agentAttachments = $agentAttachmentsSignal.GetResult()
            foreach ($attachmentJacket in $agentAttachments) {
                if ($attachmentJacket.Name) {
                    Add-AttachmentJacket -name $attachmentJacket.Name -jacket $attachmentJacket
                } else {
                    $signal.LogWarning("Skipped Agent attachment jacket with missing name.")
                }
            }
            $signal.LogInformation("Agent-level attachment jackets migrated to Conductor.")
        } else {
            $signal.LogWarning("No Agent attachments found to migrate.")
        }

        # ░▒▓█ ROLE ATTACHMENTS █▓▒░

        $roleAttachmentsSignal = Resolve-PathFromDictionary -Dictionary $Agent -Path "CurrentRole.Attachments"
        $signal.MergeSignal(@($roleAttachmentsSignal))

        if ($roleAttachmentsSignal.Success()) {
            $roleAttachments = $roleAttachmentsSignal.GetResult()
            foreach ($roleAttachmentJacket in $roleAttachments) {
                if ($roleAttachmentJacket.Name) {
                    Add-AttachmentJacket -name $roleAttachmentJacket.Name -jacket $roleAttachmentJacket
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
