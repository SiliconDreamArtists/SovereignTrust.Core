function Start-BondingConductor {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Environment,

        [Parameter(Mandatory = $true)]
        [string]$AgentName,

        [Parameter(Mandatory = $true)]
        [string]$RoleName
    )

    $signal = [Signal]::new("Start-BondingConductor")

    try {
        # Get the Agent and Role binding
        $agentSignal = Get-AgentForConductor -Environment $Environment -AgentName $AgentName -RoleName $RoleName
        $null = $signal.MergeSignal(@($agentSignal))

        if ($agentSignal.Failure()) {
            return $signal
        }

        $PrimaryAgent = $agentSignal.Result

        # Initialize BondingConductor memory structure
        $BondingConductor = @{
            Environment = $Environment
            AgentName = $AgentName
            RoleName = $RoleName
            PrimaryAgent = $PrimaryAgent
            SecondaryAgents = [System.Collections.Generic.List[object]]::new()
            Status = "Initializing"
            Conductor = $null
            RunModel = $null
            PrimaryConduit = $null
            ServiceConduits = @()
            AttachmentJackets = @{}
            Attachments = @{}
            QueueSurface = $null
        }

        $signal.LogInformation("BondingConductor memory structure created for Agent: $AgentName with Role: $RoleName.")

        # Migrate Agent Attachment Jackets
        foreach ($attachmentJacket in $PrimaryAgent.Attachments) {
            $BondingConductor.AttachmentJackets[$attachmentJacket.Name] = $attachmentJacket
        }

        # Migrate CurrentRole Attachment Jackets
        if ($PrimaryAgent.CurrentRole.Attachments) {
            foreach ($roleAttachmentJacket in $PrimaryAgent.CurrentRole.Attachments) {
                $BondingConductor.AttachmentJackets[$roleAttachmentJacket.Name] = $roleAttachmentJacket
            }
        }

        $signal.LogInformation("Agent and Role attachment jackets mapped into BondingConductor.")

        # Set output result
        $signal.Result = $BondingConductor

        $signal.LogInformation("Start-BondingConductor initialization phase completed successfully.")
    }
    catch {
        $signal.LogCritical("Start-BondingConductor encountered a critical failure: $_")
    }

    return $signal
}
