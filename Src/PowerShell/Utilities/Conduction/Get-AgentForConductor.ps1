function Get-AgentForConductor {
    param (
        [Parameter(Mandatory = $true)]
        $Environment,

        [Parameter(Mandatory = $true)]
        [string]$AgentName,

        [Parameter(Mandatory = $true)]
        [string]$RoleName
    )

    $signal = [Signal]::new("Get-AgentForConductor")

    try {
        # Resolve the Agent
        $Agent = Resolve-PathFromDictionary -Dictionary $Environment -Path "Agents.$AgentName"

        if ($null -eq $Agent) {
            $signal.LogCritical("Agent '$AgentName' not found in Environment.")
            return $signal
        }

        # Resolve the Role
        $CurrentRole = Resolve-PathFromDictionary -Dictionary $Agent -Path "Roles.$RoleName"

        if ($null -eq $CurrentRole) {
            $signal.LogCritical("Role '$RoleName' not found for Agent '$AgentName'.")
            return $signal
        }

        # Attach CurrentRole to Agent
        Add-PathToDictionary -Dictionary $Agent -Path CurrentRole -Value $CurrentRole

        $signal.LogInformation("Agent '$AgentName' with Role '$RoleName' successfully resolved and bound.")
        Add-PathToDictionary -Dictionary $Agent -Path CurrentRole -Value $CurrentRole

        $signal.SetResult($Agent)
    }
    catch {
        $signal.LogCritical("Unhandled critical failure in Get-AgentForConductor: $_")
    }

    return $signal
}
