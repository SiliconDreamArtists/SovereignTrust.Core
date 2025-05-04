function Resolve-PathFormulaGraphForAgentRoles {
    param (
        [Parameter(Mandatory)][string]$WirePath,
        [Parameter(Mandatory)][Signal]$ConductionSignal
    )

    $signal = [Signal]::new("Resolve-AgentRolesGraph:$WirePath")

    # ░▒▓█ EXTRACT ROOT STRUCTURE █▓▒░
    $agentSetSignal = Resolve-PathFromDictionary -Dictionary $ConductionSignal -Path $WirePath | Select-Object -Last 1
    if ($signal.MergeSignalAndVerifyFailure($agentSetSignal)) {
        $signal.LogCritical("❌ Failed to resolve Agents array from: $WirePath")
        return $signal
    }

    $agents = $agentSetSignal.GetResult()

    # ░▒▓█ GET ENVIRONMENT █▓▒░
    $envSignal = Resolve-PathFromDictionary -Dictionary $ConductionSignal -Path "Environment" | Select-Object -Last 1
    if ($signal.MergeSignalAndVerifyFailure($envSignal)) {
        $signal.LogCritical("❌ Missing Environment from ConductionSignal.")
        return $signal
    }

    $environment = $envSignal.GetResult()
    $agentGraph = [Graph]::new($environment)
    $agentGraph.Start()

    # ░▒▓█ TRAVERSE AGENTS █▓▒░
    $agentIndex = 0
    foreach ($agent in $agents) {
        $agentName = $agent.Name
        if (-not $agentName) {
            $signal.LogWarning("⚠️ Agent at index $agentIndex missing Name; skipping.")
            continue
        }

        # ░▒▓█ CREATE ROLE GRAPH FOR THIS AGENT █▓▒░
        $roleGraph = [Graph]::new($environment)
        $roleGraph.Start()

        $roleIndex = 0
        foreach ($role in $agent.Roles) {
            $roleName = $role.Name
            if (-not $roleName) {
                $signal.LogWarning("⚠️ Role at index $roleIndex in Agent $agentName is unnamed; skipping.")
                continue
            }

            $roleSignal = [Signal]::new("$agentName.$roleName")
            $roleSignal.SetJacket($role)
            $roleGraph.RegisterSignal($roleName, $roleSignal)
            $roleIndex++
        }

        $roleGraph.Finalize()

        # ░▒▓█ WRAP AGENT SIGNAL WITH ROLE GRAPH POINTER █▓▒░
        $agentSignal = [Signal]::new($agentName)
        $agentSignal.SetJacket($agent)
        $agentSignal.SetPointer($roleGraph)

        $agentGraph.RegisterSignal($agentName, $agentSignal)
        $agentIndex++
    }

    $agentGraph.Finalize()
    $signal.SetResult($agentGraph)
    $signal.LogInformation("✅ AgentRoles Graph built with $agentIndex agent(s).")

    return $signal
}
