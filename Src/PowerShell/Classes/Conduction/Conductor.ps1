# =============================================================================
# 🚦 Conductor (SovereignTrust Execution Core)
#  License: MIT License • Copyright (c) 2025 Silicon Dream Artists / BDDB
#  Authors: Shadow PhanTom ☠️🧁👾️/🤖 • Neural Alchemist ⚗️☣️🐲 • Version: 2025.5.4.8
# =============================================================================

class Conductor {
    [Signal]$Signal  # 🧠 Sovereign memory vessel for this Conductor

    Conductor([Conductor]$hostConductor = $null, $conduction) {
        $this.Signal = [Signal]::new("Conductor")
        $this.Signal.SetJacket($conduction)

        Add-PathToDictionary -Dictionary $this -Path "#.%.HostConductor"   -Value $hostConductor        | Out-Null
        Add-PathToDictionary -Dictionary $this -Path "#.%.IsHostConductor" -Value ($null -eq $hostConductor) | Out-Null

        if ($this.Signal.MergeAndVerifyFailure(($this.InitializeMemory()    | Select-Object -Last 1))) { return }
        if ($this.Signal.MergeAndVerifyFailure(($this.LoadMappedAdapters() | Select-Object -Last 1))) { return }
        if ($this.Signal.MergeAndVerifyFailure(($this.LoadAgentGraph()     | Select-Object -Last 1))) { return }
    }

    [Signal] InitializeMemory() {
        $opSignal = [Signal]::new("Conductor.InitializeMemory")

        $envSignal = Resolve-PathFromDictionary -Dictionary $this -Path "#.%.Environment" | Select-Object -Last 1
        if ($envSignal.Failure()) { return $opSignal.MergeSignal($envSignal) }

        $graph = [Graph]::new($envSignal.GetResult())
        $this.Signal.SetPointer($graph)

        return $opSignal
    }

    [Signal] LoadMappedAdapters() {
        $opSignal = [Signal]::new("Conductor.LoadMappedAdapters")

        $mapped = $this.LoadMappedCondenserAdapter() | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($mapped)) { return $opSignal }

        $graphSignal = Resolve-PathFromDictionary -Dictionary $this -Path "#.*" | Select-Object -Last 1
        $graph = $graphSignal.GetResult()

        $graph.RegisterResultAsSignal("Mapped.Storage", [MappedStorageAdapter]::new($this)) | Out-Null
        $graph.RegisterResultAsSignal("Mapped.Network", [MappedNetworkAdapter]::new($this)) | Out-Null

        return $opSignal
    }

    [Signal] LoadAgentGraph() {
        $opSignal = [Signal]::new("Conductor.LoadAgentGraph")

        $ctx = [Signal]::new("AgentGraph.Context")
        $ctx.SetResult($this)
        $ctx.SetJacket($this.Signal.GetJacket())
        $ctx.SetPointer($this.Signal.Pointer)

        $agentGraphSignal = Resolve-PathFormulaGraphForAgentRoles -WirePath "#.%.Environment.%.Agents" -ConductionSignal $ctx | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($agentGraphSignal)) { return $opSignal }

        $graphSignal = Resolve-PathFromDictionary -Dictionary $this -Path "#.*" | Select-Object -Last 1
        $graph = $graphSignal.GetResult()
        $graph.RegisterSignal("AgentGraph", $agentGraphSignal)

        return $opSignal
    }

    [Signal] LoadMappedCondenserAdapter() {
        $opSignal = [Signal]::new("Conductor.LoadMappedCondenserAdapter")

        $condenserSignal = New-MappedCondenserAdapterFromGraph -Conductor $this | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($condenserSignal)) { return $opSignal }

        $graphSignal = Resolve-PathFromDictionary -Dictionary $this -Path "#.*" | Select-Object -Last 1
        $graph = $graphSignal.GetResult()
        $graph.RegisterSignal("Mapped.Condenser", $condenserSignal)

        return $opSignal
    }

    [Signal] AttachPrimaryConduit([Conduit]$conduit) {
        $opSignal = [Signal]::new("Conductor.AttachPrimaryConduit")

        $graphSignal = Resolve-PathFromDictionary -Dictionary $this -Path "#.*" | Select-Object -Last 1
        $graph = $graphSignal.GetResult()
        $graph.RegisterResultAsSignal("PrimaryConduit", $conduit)

        $opSignal.LogInformation("🧵 Primary conduit attached to graph memory.")
        return $opSignal
    }

    [Signal] AttachSecondaryAgent([object]$agent) {
        $opSignal = [Signal]::new("Conductor.AttachSecondaryAgent")

        $agentsPath = "#.*.SecondaryAgents"
        $listSignal = Resolve-PathFromDictionary -Dictionary $this -Path $agentsPath | Select-Object -Last 1

        $agentList = $listSignal.GetResult()
        if ($null -eq $agentList) {
            $agentList = [System.Collections.Generic.List[object]]::new()
            Add-PathToDictionary -Dictionary $this -Path $agentsPath -Value $agentList | Out-Null
        }

        $agentList.Add($agent)
        $opSignal.LogInformation("➕ Secondary agent added.")
        return $opSignal
    }
}
