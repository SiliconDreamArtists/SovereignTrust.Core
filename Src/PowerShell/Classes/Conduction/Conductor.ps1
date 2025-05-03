# =============================================================================
# 🚦 Conductor (SovereignTrust Execution Core)
#  License: MIT License • Copyright (c) 2025 Silicon Dream Artists / BDDB
#  Authors: Shadow PhanTom ☠️🧁👾️/🤖 • Neural Alchemist ⚗️☣️🐲 • Last Generated: 05/02/2025
# =============================================================================
# The Conductor initializes memory bonding, maps storage/network layers,
# and manages primary/secondary agents via Conduits and Role graphs.
# It tracks all activity through a local Graph + Signal structure.
# =============================================================================

class Conductor {
    [string]$Id
    [bool]$IsHostConductor = $false
    [Conductor]$HostConductor
    [object]$Environment

    [Graph]$Graph
    [Signal]$ControlSignal
    [string]$Status

    # Bonded memory inputs
    [string]$AgentName
    [string]$RoleName
    [object]$PrimaryAgent
    [System.Collections.Generic.List[object]]$AdapterJackets

    [System.Collections.Generic.List[object]]$SecondaryAgents

    # Mapped Adapter memory (resolved into Graph)
    [Graph]$MappedAdapters

    # Core conduit
    [Conduit]$PrimaryConduit

    Conductor([string]$id, [Conductor]$hostConductor = $null, $environment) {
        $this.Id = $id
        $this.HostConductor = $hostConductor
        $this.Environment = $environment
        $this.IsHostConductor = $null -eq $hostConductor

        $this.ControlSignal = [Signal]::new("Conductor:$id")
        $this.Graph = [Graph]::new($environment)
        $this.MappedAdapters = [Graph]::new($environment)

        $this.AdapterJackets = [System.Collections.Generic.List[object]]::new()
        $this.SecondaryAgents = [System.Collections.Generic.List[object]]::new()
        $this.Status = "Initialized"

        $this.LoadMappedAdapters() | Out-Null
    }

    [Signal] LoadMappedAdapters() {
        $signal = [Signal]::new("Conductor.LoadMappedAdapters")
    
        # ░▒▓█ CONDENSER (IR–1) █▓▒░
        $condenserSignal = $this.LoadMappedCondenserAdapter() | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($condenserSignal)) {
            $signal.LogCritical("❌ Failed to load mapped condenser adapter.")
            return $signal
        }
    
        # ░▒▓█ STORAGE & NETWORK █▓▒░
        $this.MappedAdapters.RegisterResultAsSignal("Storage", [MappedStorageAdapter]::new($this)) | Out-Null
        $this.MappedAdapters.RegisterResultAsSignal("Network", [MappedNetworkAdapter]::new($this)) | Out-Null
    
        $signal.LogInformation("🔌 MappedAdapters initialized: Storage, Network, Condenser.")
        $this.ControlSignal.MergeSignal($signal)
        return $signal
    }
    
    [Signal] LoadMappedCondenserAdapter() {
        $signal = [Signal]::new("Conductor.LoadMappedCondenserAdapter")
    
        # ░▒▓█ BUILD + REGISTER CONDENSER WRAPPER █▓▒░
        $mappedSignal = New-MappedCondenserAdapterFromGraph -Conductor $this | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($mappedSignal)) {
            $signal.LogWarning("⚠️ Condenser adapter creation failed.")
            return $signal
        }
    
        $signal.LogInformation("🧪 Condenser adapter registered successfully.")
        return $signal
    }
        
    [Signal] AttachPrimaryConduit([Conduit]$conduit) {
        $signal = [Signal]::new("Conductor.AttachPrimaryConduit")

        $this.PrimaryConduit = $conduit
        $this.Status = "ConduitAttached"

        $signal.LogInformation("🧵 Primary conduit attached to Conductor: $($this.Id)")
        $this.ControlSignal.MergeSignal($signal)
        return $signal
    }

    [Signal] StartRole([string]$agentName, [string]$roleName, [object]$agent) {
        $signal = [Signal]::new("Conductor.StartRole:$roleName")

        $this.AgentName = $agentName
        $this.RoleName = $roleName
        $this.PrimaryAgent = $agent

        $signal.LogInformation("🎭 Role started for Agent '$agentName' with Role '$roleName'")
        $this.ControlSignal.MergeSignal($signal)
        return $signal
    }

    [Signal] AttachSecondaryAgent([object]$agent) {
        $signal = [Signal]::new("Conductor.AttachSecondaryAgent")

        $this.SecondaryAgents.Add($agent)
        $signal.LogInformation("➕ Secondary agent attached.")
        $this.ControlSignal.MergeSignal($signal)
        return $signal
    }
}
