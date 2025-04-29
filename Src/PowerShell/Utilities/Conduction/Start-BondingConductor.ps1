function Start-BondingConductor {
    param (
        [Parameter(Mandatory = $true)]
        $Environment,

        [Parameter(Mandatory = $true)]
        [string]$AgentName,

        [Parameter(Mandatory = $true)]
        [string]$RoleName
    )

    $signal = [Signal]::new("Start-BondingConductor")

    try {
        # Get the Agent and Role binding
        $agentSignal = Get-AgentForConductor -Environment $Environment -AgentName $AgentName -RoleName $RoleName | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure(@($agentSignal))) {
            $signal.LogCritical("Failed to resolve Agent and Role binding.")
            return $signal
        }

        $PrimaryAgent = $agentSignal.Result

        # Generate a new Conductor instance
        $BondingConductor = [Conductor]::new([guid]::NewGuid().ToString())

        # Assign properties
        $BondingConductor.Environment    = $Environment
        $BondingConductor.AgentName       = $AgentName
        $BondingConductor.RoleName        = $RoleName
        $BondingConductor.PrimaryAgent    = $PrimaryAgent
        $BondingConductor.SecondaryAgents = [System.Collections.Generic.List[object]]::new()
        $BondingConductor.Status          = "Initializing"

        $signal.LogInformation("BondingConductor created for Agent: $AgentName with Role: $RoleName.")

        # Convert Agent Attachments
        Convert-AgentAttachmentsToConductor -Agent $PrimaryAgent -Conductor $BondingConductor

        $signal.LogInformation("Agent and Role attachment jackets mapped into BondingConductor.")

        # Set output result
        $signal.SetResult($BondingConductor)

        $signal.LogInformation("Start-BondingConductor initialization completed successfully.")
    }
    catch {
        $signal.LogCritical("Start-BondingConductor encountered a critical failure: $_")
    }

    return $signal
}