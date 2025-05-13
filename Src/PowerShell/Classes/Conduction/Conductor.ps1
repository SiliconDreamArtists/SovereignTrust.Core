# =============================================================================
# 🚦 Conductor (SovereignTrust Execution Core)
#  License: MIT License • Copyright (c) 2025 Silicon Dream Artists / BDDB
#  Authors: Shadow PhanTom ☠️🧁👾️/🤖 • Neural Alchemist ⚗️☣️🐲 • Version: 2025.5.4.8
# =============================================================================

class Conductor {
    [Signal]$Signal  # 🧠 Sovereign memory vessel for this Conductor

    Conductor([Conductor]$hostConductor, $conductionSignal) {
        $this.Signal = [Signal]::Start("Conductor") | Select-Object -Last 1

        $jacketSignal = Resolve-PathFromDictionary -Dictionary $conductionSignal -Path "@.%" | Select-Object -Last 1
        if ($this.Signal.MergeSignalAndVerifyFailure(@($jacketSignal))) { return }
        
        $this.Signal.SetJacket($jacketSignal)

        Add-PathToDictionary -Dictionary $this -Path "$.%.HostConductor"   -Value $hostConductor        | Out-Null
        Add-PathToDictionary -Dictionary $this -Path "$.%.IsHostConductor" -Value ($null -eq $hostConductor) | Out-Null

        if ($this.Signal.MergeSignalAndVerifyFailure(@($this.InitializeMemory()    | Select-Object -Last 1))) { return }
        if ($this.Signal.MergeSignalAndVerifyFailure(@($this.LoadMappedAdapters() | Select-Object -Last 1))) { return }
        if ($this.Signal.MergeSignalAndVerifyFailure(@($this.LoadAgentGraph()     | Select-Object -Last 1))) { return }
    }
    

    [Signal] InitializeMemory() {
        $opSignal = [Signal]::Start("Conductor.InitializeMemory") | Select-Object -Last 1

        $envSignal = Resolve-PathFromDictionary -Dictionary $this -Path "$.%" | Select-Object -Last 1
        if ($envSignal.Failure()) { return $opSignal.MergeSignal($envSignal) }

        $graph = [Graph]::Start("Conductor:Memory", $envSignal.GetResult(), $true) | Select-Object -Last 1
        $this.Signal.SetPointer($graph)

        return $opSignal
    }

    [Signal] LoadMappedAdapters() {
        $opSignal = [Signal]::Start("Conductor.LoadMappedAdapters") | Select-Object -Last 1

        $mapped = $this.LoadMappedCondenserAdapter() | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($mapped)) { return $opSignal }

        $graphSignal = Resolve-PathFromDictionary -Dictionary $this -Path "$.*" | Select-Object -Last 1
        $graph = $graphSignal.GetResult()

        $graph.RegisterResultAsSignal("Mapped.Storage", [MappedStorageAdapter]::new($this)) | Out-Null
        $graph.RegisterResultAsSignal("Mapped.Network", [MappedNetworkAdapter]::new($this)) | Out-Null

        Invoke-TraceSignalTree -Signal $opSignal -VisualizeFinal $true

        return $opSignal
    }

    [Signal] LoadAgentGraph() {
        $opSignal = [Signal]::Start("Conductor.LoadAgentGraph") | Select-Object -Last 1

        $ctx = [Signal]::Start("AgentGraph.Context") | Select-Object -Last 1
        $ctx.SetResult($this)
        $ctx.SetJacket($this.Signal.GetJacket())
        $ctx.SetPointer($this.Signal.Pointer)

        $agentGraphSignal = Resolve-PathFormulaGraphForAgentRoles -WirePath "$.%.Environment.%.Agents" -ConductionSignal $ctx | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($agentGraphSignal)) { return $opSignal }

        $graphSignal = Resolve-PathFromDictionary -Dictionary $this -Path "$.*" | Select-Object -Last 1
        $graph = $graphSignal.GetResult()
        $graph.RegisterSignal("AgentGraph", $agentGraphSignal)

        return $opSignal
    }

    [Signal] LoadMappedCondenserAdapter() {
        $opSignal = [Signal]::Start("Conductor.LoadMappedCondenserAdapter") | Select-Object -Last 1

        $condenserSignal = New-MappedCondenserAdapterFromGraph -Conductor $this | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($condenserSignal)) { return $opSignal }

        $graphSignal = Resolve-PathFromDictionary -Dictionary $this -Path "$.*" | Select-Object -Last 1
        $graph = $graphSignal.GetResult()
        $graph.RegisterSignal("MappedCondenser", $condenserSignal)

        return $opSignal
    }

    [Signal] AttachPrimaryConduit([Conduit]$conduit) {
        $opSignal = [Signal]::Start("Conductor.AttachPrimaryConduit") | Select-Object -Last 1

        $graphSignal = Resolve-PathFromDictionary -Dictionary $this -Path "$.*" | Select-Object -Last 1
        $graph = $graphSignal.GetResult()
        $graph.RegisterResultAsSignal("PrimaryConduit", $conduit)

        $opSignal.LogInformation("🧵 Primary conduit attached to graph memory.")
        return $opSignal
    }

    [Signal] AttachSecondaryAgent([object]$agent) {
        $opSignal = [Signal]::Start("Conductor.AttachSecondaryAgent") | Select-Object -Last 1

        $agentsPath = "$.*.SecondaryAgents"
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
