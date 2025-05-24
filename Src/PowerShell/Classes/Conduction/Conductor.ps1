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

        #        Add-PathToDictionary -Dictionary $conductor -Path "$.%.HostConductor"   -Value $hostConductor        | Out-Null
        #        Add-PathToDictionary -Dictionary $conductor -Path "$.%.IsHostConductor" -Value ($null -eq $hostConductor) | Out-Null

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

        # ░▒▓█ ENSURE ADAPTERS GRID EXISTS █▓▒░
        $adaptersGridSignal = Add-PathToDictionary -Dictionary $this.Signal -Path "*.#.Adapters.*" | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($adaptersGridSignal)) {
            return $opSignal.LogCritical("❌ Failed to initialize Adapters grid.")
        }

        # ░▒▓█ DEFINE ADAPTERS TO LOAD █▓▒░
        $adaptersToRegister = @(
            @{ Name = "MappedStorage"; Instance = [MappedStorageAdapter]::Start($this) },
            @{ Name = "MappedNetwork"; Instance = [MappedNetworkAdapter]::Start($this) }
        )

        # 🔁 Load MappedCondenserAdapter and add to list
        $mappedCondenserSignal = $this.LoadMappedCondenserAdapter() | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure(($mappedCondenserSignal))) {
            $opSignal.LogCritical("❌ Failed to load MappedCondenserAdapter.")
            return $opSignal
        }

        # ░▒▓█ REGISTER ADAPTERS INTO ADAPTERS GRID █▓▒░
        foreach ($entry in $adaptersToRegister) {
            $path = "*.#.Adapters.*.$($entry.Name)"
            $regSignal = Add-PathToDictionary -Dictionary $this.Signal -Path $path -Value $entry.Instance | Select-Object -Last 1
            if ($regSignal.Failure()) {
                $opSignal.LogWarning("⚠️ Failed to register adapter '$($entry.Name)'")
            }
            else {
                $opSignal.LogInformation("🔌 Registered adapter '$($entry.Name)'")
            }
        }

        Invoke-TraceSignalTree -Signal $this.Signal -VisualizeFinal $true
        return $opSignal
    }

    [Signal] LoadAgentGraph() {
        $opSignal = [Signal]::Start("Conductor.LoadAgentGraph") | Select-Object -Last 1

        try {
            $memoryCondenserSignal = Resolve-PathFromDictionary -Dictionary $this -Path "$.*.#.Adapters.*.#.MappedCondenser.@.$.*.#.MemoryCondenser.@.@" | Select-Object -Last 1

            # ░▒▓█ Resolve FormulaGraphCondenser from memory █▓▒░
            $condenserSignal = Resolve-PathFromDictionary -Dictionary $this -Path "$.*.#.Adapters.*.#.MappedCondenser.@.$.*.#.FormulaGraphCondenser" | Select-Object -Last 1

            if ($opSignal.MergeSignalAndVerifyFailure($condenserSignal)) {
                return $opSignal.LogCritical("❌ Could not resolve FormulaGraphCondenser.")
            }

            $condenserGraphSignal = $condenserSignal.GetResult()
            $condenser = $condenserGraphSignal.GetResult()

            # ░▒▓█ Launch Agent graph formula processing █▓▒░
            $graphPlanSignal = $condenser.InvokeFromPlanPath("%.%.@.GraphFormulas.Agents", $this.Signal) | Select-Object -Last 1
            if ($opSignal.MergeSignalAndVerifyFailure($graphPlanSignal)) {
                return $opSignal.LogCritical("❌ Failed to invoke Agent Graph plan from jacket.")
            }

            # ░▒▓█ Store result Graphs into Pointer Graph at *.#.Agents █▓▒░
            $pointerGraphSignal = Resolve-PathFromDictionary -Dictionary $this -Path "$.*" | Select-Object -Last 1
            $graph = $pointerGraphSignal.GetResult()

            $agentGraphs = $graphPlanSignal.GetResult().Graphs.Agents
            if ($null -eq $agentGraphs) {
                return $opSignal.LogCritical("❌ No agent graphs returned in expected location: .Graphs.Agents")
            }

            $graph.RegisterResultAsSignal("Agents", $agentGraphs) | Out-Null
            $opSignal.LogInformation("✅ Agent graphs injected into pointer graph under 'Agents'.")

        }
        catch {
            $opSignal.LogCritical("🔥 Exception during LoadAgentGraph: $($_.Exception.Message)")
        }

        return $opSignal
    }

    [Signal] LoadMappedCondenserAdapter() {
        $opSignal = [Signal]::Start("Conductor.LoadMappedCondenserAdapter") | Select-Object -Last 1

        # 🔧 Create the actual adapter instance
        $condenserSignal = New-MappedCondenserAdapterFromGraph -Conductor $this | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($condenserSignal)) {
            return $opSignal.LogCritical("❌ Failed to create MappedCondenserAdapter.")
        }

        # 🧬 Return adapter pair without mutating memory
        $adapterPair = @{
            Name     = "MappedCondenser"
            Instance = $condenserSignal
        }

        $opSignal.SetResult($adapterPair)
        $opSignal.LogInformation("🧬 MappedCondenserAdapter created and returned as pair. Not registered.")
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
