function Resolve-PathFormulaGraphForAgentRoles {
    param (
        [Parameter(Mandatory)][string]$WirePath,
        [Parameter(Mandatory)][Signal]$ConductionSignal
    )

    $opSignal = [Signal]::Start("Resolve-AgentRolesGraph:$WirePath") | Select-Object -Last 1

    # ░▒▓█ EXTRACT ROOT AGENTS ARRAY █▓▒░
    $agentSetSignal = Resolve-PathFromDictionary -Dictionary $ConductionSignal -Path $WirePath | Select-Object -Last 1
    if ($opSignal.MergeSignalAndVerifyFailure($agentSetSignal)) {
        $opSignal.LogCritical("❌ Failed to resolve Agents array from path: $WirePath")
        return $opSignal
    }

    $agents = $agentSetSignal.GetResult()

    # ░▒▓█ GET ENVIRONMENT █▓▒░
    $envSignal = Resolve-PathFromDictionary -Dictionary $ConductionSignal -Path "%.Environment" | Select-Object -Last 1
    if ($opSignal.MergeSignalAndVerifyFailure($envSignal)) {
        $opSignal.LogCritical("❌ Environment resolution failed.")
        return $opSignal
    }

    $environment = $envSignal.GetResult()
    $agentGraph = [Graph]::new($environment)
    $agentGraph.Start()

    $agentIndex = 0
    foreach ($agent in $agents) {
        # Resolve agent name via path instead of direct property
        $agentNameSignal = Resolve-PathFromDictionary -Dictionary $agent -Path "Name" | Select-Object -Last 1
        $agentName = $agentNameSignal.GetResult()
        if (-not $agentName) {
            $opSignal.LogWarning("⚠️ Agent at index $agentIndex missing Name; skipping.")
            continue
        }

        # ░▒▓█ CREATE ROLE GRAPH FOR AGENT █▓▒░
        $roleGraph = [Graph]::new($environment)
        $roleGraph.Start()

        $rolesSignal = Resolve-PathFromDictionary -Dictionary $agent -Path "Roles" | Select-Object -Last 1
        $roles = $rolesSignal.GetResult()
        $roleIndex = 0

        foreach ($role in $roles) {
            $roleNameSignal = Resolve-PathFromDictionary -Dictionary $role -Path "Name" | Select-Object -Last 1
            $roleName = $roleNameSignal.GetResult()

            if (-not $roleName) {
                $opSignal.LogWarning("⚠️ Role at index $roleIndex in Agent '$agentName' missing Name; skipping.")
                continue
            }

            $roleSignal = [Signal]::Start("$agentName.$roleName") | Select-Object -Last 1
            $roleSignal.SetJacket($role)
            $roleGraph.RegisterSignal($roleName, $roleSignal)

            $roleIndex++
        }

        $roleGraph.Finalize()

        # ░▒▓█ WRAP AGENT WITH ROLE POINTER █▓▒░
        $agentSignal = [Signal]::new($agentName)
        $agentSignal.SetJacket($agent)
        $agentSignal.SetPointer($roleGraph)

        $agentGraph.RegisterSignal($agentName, $agentSignal)
        $agentIndex++
    }

    $agentGraph.Finalize()
    $opSignal.SetResult($agentGraph)
    $opSignal.LogInformation("✅ AgentRoles graph built with $agentIndex agent(s).")
    return $opSignal
}
