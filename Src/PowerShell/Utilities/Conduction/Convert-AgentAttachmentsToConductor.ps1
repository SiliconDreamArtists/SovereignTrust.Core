function Convert-AgentAttachmentsToConductor {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Agent,

        [Parameter(Mandatory = $true)]
        [hashtable]$Conductor
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

        if (-not $Conductor.AttachmentJackets) {
            $Conductor.AttachmentJackets = @{}
        }

        # Migrate Agent-level Attachment Jackets
        if ($Agent.Attachments) {
            foreach ($attachmentJacket in $Agent.Attachments) {
                $Conductor.AttachmentJackets[$attachmentJacket.Name] = $attachmentJacket
                $signal.LogVerbose("Mapped Agent Attachment Jacket: $($attachmentJacket.Name)")
            }
            $signal.LogInformation("Agent-level attachment jackets migrated to Conductor.")
        }

        # Migrate CurrentRole-level Attachment Jackets
        if ($Agent.CurrentRole -and $Agent.CurrentRole.Attachments) {
            foreach ($roleAttachmentJacket in $Agent.CurrentRole.Attachments) {
                $Conductor.AttachmentJackets[$roleAttachmentJacket.Name] = $roleAttachmentJacket
                $signal.LogVerbose("Mapped Role Attachment Jacket: $($roleAttachmentJacket.Name)")
            }
            $signal.LogInformation("Role-level attachment jackets migrated to Conductor.")
        }

        $signal.Result = $Conductor
    }
    catch {
        $signal.LogCritical("Unhandled critical failure in Convert-AgentAttachmentsToConductor: $_")
    }

    return $signal
}
