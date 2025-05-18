# =============================================================================
# 🚦 Conductor (SovereignTrust Execution Core)
#  License: MIT License • Copyright (c) 2025 Silicon Dream Artists / BDDB
#  Authors: Shadow PhanTom 🤖/☠️🧁👾️ • Neural Alchemist ⚗️☣️🐲 • Version: 2025.5.4.8
# =============================================================================

class Conductor {
    [Signal]$Signal  # 🧠 Sovereign memory vessel for this Conductor

    Conductor() {
        # Instance constructor should not be used directly
    }

    static [Signal] Start([Conductor]$hostConductor, $conductionSignal) {
        $opSignal = [Signal]::Start("Conductor.Start") | Select-Object -Last 1

        $conductor = [Conductor]::new()
        $conductor.Signal = [Signal]::Start("Conductor") | Select-Object -Last 1

        $jacketSignal = Resolve-PathFromDictionary -Dictionary $conductionSignal -Path "@.%" | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure(@($jacketSignal))) { return $opSignal }

        $conductor.Signal.SetJacket($jacketSignal)

        Add-PathToDictionary -Dictionary $conductor -Path "$.%.HostConductor"   -Value $hostConductor        | Out-Null
        Add-PathToDictionary -Dictionary $conductor -Path "$.%.IsHostConductor" -Value ($null -eq $hostConductor) | Out-Null

        if ($conductor.Signal.MergeSignalAndVerifyFailure(@($conductor.InitializeMemory()    | Select-Object -Last 1))) { return $opSignal }
        if ($conductor.Signal.MergeSignalAndVerifyFailure(@($conductor.LoadMappedAdapters() | Select-Object -Last 1))) { return $opSignal }
        if ($conductor.Signal.MergeSignalAndVerifyFailure(@($conductor.LoadAgentGraph()     | Select-Object -Last 1))) { return $opSignal }

        $opSignal.SetResult($conductor)
        $opSignal.LogInformation("✅ Conductor initialized and ready.")
        return $opSignal
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
        $newGraphSignal = Add-PathToDictionary -Dictionary $this -Path "$.*.#.Adapters.*" | Select-Object -Last 1

        $mapped = $this.LoadMappedCondenserAdapter() | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($mapped)) { return $opSignal }

        $graphSignal = Resolve-PathFromDictionary -Dictionary $this -Path "$.*.#.Adapters.*" | Select-Object -Last 1
        $graph = $graphSignal.GetResult()

        $graph.RegisterResultAsSignal("Mapped.Storage", [MappedStorageAdapter]::Start($this)) | Out-Null
        $graph.RegisterResultAsSignal("Mapped.Network", [MappedNetworkAdapter]::Start($this)) | Out-Null

        Invoke-TraceSignalTree -Signal $this.Signal -VisualizeFinal $true

        return $opSignal
    }

    [Signal] LoadAgentGraph() {
        $opSignal = [Signal]::Start("Conductor.LoadAgentGraph") | Select-Object -Last 1

        try {
            # 🧠 Resolve FormulaGraphCondenser from memory
            $condenserSignal = Resolve-PathFromDictionary -Dictionary $this.Signal -Path "*.MappedAdapters.MappedCondenserAdapter.FormulaGraphCondenser" | Select-Object -Last 1
            if ($opSignal.MergeSignalAndVerifyFailure($condenserSignal)) {
                return $opSignal.LogCritical("❌ Could not resolve FormulaGraphCondenser.")
            }

            $condenser = $condenserSignal.GetResult()

            # 🔁 Create new signal: Jacket = source context, Result = target graph
            $inputSignal = [Signal]::Start("GraphCondenser.AgentGraph", $this.Signal) | Select-Object -Last 1
            $inputSignal.SetJacket($this.Signal.GetJacket()) | Out-Null
            $inputSignal.SetResult($this.Signal.GetPointer()) | Out-Null

            # 🧬 Run the formula graph condenser on the declared plan path
            $resultSignal = $condenser.InvokeFromPlanPath("%.GraphFormulas.Agent", $inputSignal) | Select-Object -Last 1
            if ($opSignal.MergeSignalAndVerifyFailure($resultSignal)) {
                return $opSignal.LogCritical("❌ Failed to generate AgentGraph via condenser.")
            }

            # 💾 Register result into pointer graph
            $graphSignal = Resolve-PathFromDictionary -Dictionary $this -Path "$.*" | Select-Object -Last 1
            $graph = $graphSignal.GetResult()
            $graph.RegisterSignal("AgentGraph", $resultSignal) | Out-Null

            $opSignal.LogInformation("✅ AgentGraph registered into conductor pointer.")
        }
        catch {
            $opSignal.LogCritical("🔥 Exception in LoadAgentGraph: $($_.Exception.Message)")
        }

        return $opSignal
    }

    [Signal] LoadMappedCondenserAdapter() {
        $opSignal = [Signal]::Start("Conductor.LoadMappedCondenserAdapter") | Select-Object -Last 1

        # 🔧 Create the actual condenser adapter
        $condenserSignal = New-MappedCondenserAdapterFromGraph -Conductor $this | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($condenserSignal)) {
            return $opSignal.LogCritical("❌ Failed to create MappedCondenserAdapter.")
        }

        # 🔍 Resolve or create Adapters node
        $graphSignal = Resolve-PathFromDictionary -Dictionary $this -Path "$.*" | Select-Object -Last 1
        $graph = $graphSignal.GetResult()

        # 📦 Check if Adapters container already exists
        $adaptersSignal = Resolve-PathFromDictionary -Dictionary $graph -Path "Adapters" | Select-Object -Last 1
        if ($adaptersSignal.Failure()) {
            # 🛠 Create Adapters signal if it doesn't exist
            $adaptersSignal = [Signal]::Start("Adapters") | Select-Object -Last 1
            $adaptersSignal.SetPointer([Graph]::Start("Adapters.Pointer", $graphSignal, $false)) | Out-Null
            $graph.RegisterSignal("Adapters", $adaptersSignal) | Out-Null
        }

        # 🧱 Register the condenser under: Adapters.Pointer.Condensers.FormulaGraphCondenser
        $adaptersGraphSignal = Resolve-PathFromDictionary -Dictionary $this -Path "$.*.#.Adapters.*" | Select-Object -Last 1
        $adaptersGraph = $adaptersGraphSignal.GetResult()
        $adaptersGraph.RegisterSignal("Condensers.FormulaGraphCondenser", $condenserSignal) | Out-Null

        $opSignal.LogInformation("✅ FormulaGraphCondenser registered under Adapters.Condensers.FormulaGraphCondenser.")
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
