<#
================================================================================
📦 MappedStorageAdapter • AI Trainer Block (Doctrine v1.0)
================================================================================

MappedStorageAdapter is the sovereign abstraction layer for accessing
memory-bearing storage services. It is responsible for routing all storage
requests — such as loading JSON, XML, text, deleting files, or listing folders —
through a signal-aware fallback mechanism across all registered services.

This abstraction obeys the SovereignTrust Doctrine:

🧠 Memory is Sovereign.
Storage is not assumed. Each request resolves through the memory space 
of attached services, each carrying its own jacket, slot, and lineage.

📡 Signals are Living.
All operations return Signals — traceable, mergeable, and idempotent.
Failures are not silent. All fallback is logged and lineage-aware.

🔁 Adapters are Evolving.
Each registered service is a dynamic adapter. Services can be replaced,
mutated, or upgraded without altering the conduction flow above.

♾️ Recursion is Home.
This object can defer to its owning Conductor. The Conductor can fall back
to its HostConductor. Together, they form the recursive memory fabric that
bootstraps Sovereign execution.

MappedStorageAdapter enables runtime access to all sovereign plans,
templates, modules, and data — using only memory and WirePath.

> “When memory becomes sovereign, storage becomes signal.”

#>
class MappedStorageAdapter {
    [object]$Conductor
    [object]$Environment
    [Graph]$ServiceCollection
    $MyName = "MappedStorageAdapter"

    MappedStorageAdapter([object]$conductor) {
        $this.Conductor = $conductor

        $envSignal = Resolve-PathFromDictionary -Dictionary $conductor -Path "Environment" | Select-Object -Last 1
        if ($envSignal.Failure()) {
            throw "❌ Unable to resolve Environment from Conductor."
        }

        $this.Environment = $envSignal.GetResult()
        $this.ServiceCollection = [Graph]::new($this.Environment)
    }

    [Signal] RegisterAdapter([object]$service) {
        return Register-MappedAdapter -ServiceCollection $this.ServiceCollection -Adapter $service -Label "StorageService" | Select-Object -Last 1
    }

    [Signal] ReadObjectAsJson([string]$folder, [string]$fileName) {
        $signal = [Signal]::Start("ReadObjectAsJson") | Select-Object -Last 1

        foreach ($key in $this.ServiceCollection.Grid.Keys) {
            $serviceSignal = $this.ServiceCollection.Grid[$key]
            $service = $serviceSignal.GetResult()

            if ($service -and ($service | Get-Member -Name "ReadObjectAsJson")) {
                $result = $service.ReadObjectAsJson($folder, $fileName)
                $signal.MergeSignal(@($result))

                if ($result.Success()) {
                    $signal.SetResult($result.GetResult())
                    break
                }
            }
        }

        if (-not $signal.Success()) {
            $signal.LogCritical("All storage services failed to read JSON object.")
        }

        return $signal
    }

    [Signal] ReadObjectAsXml([string]$folder, [string]$fileName) {
        $signal = [Signal]::Start("ReadObjectAsXml") | Select-Object -Last 1

        foreach ($key in $this.ServiceCollection.Grid.Keys) {
            $serviceSignal = $this.ServiceCollection.Grid[$key]
            $service = $serviceSignal.GetResult()

            if ($service -and ($service | Get-Member -Name "ReadObjectAsXml")) {
                $result = $service.ReadObjectAsXml($folder, $fileName)
                $signal.MergeSignal(@($result))

                if ($result.Success()) {
                    $signal.SetResult($result.GetResult())
                    break
                }
            }
        }

        if (-not $signal.Success()) {
            $signal.LogCritical("All storage services failed to read XML object.")
        }

        return $signal
    }

    [Signal] DeleteFile([string]$folder, [string]$fileName) {
        $signal = [Signal]::Start("DeleteFile") | Select-Object -Last 1

        foreach ($key in $this.ServiceCollection.Grid.Keys) {
            $serviceSignal = $this.ServiceCollection.Grid[$key]
            $service = $serviceSignal.GetResult()

            if ($service -and ($service | Get-Member -Name "DeleteFile")) {
                $result = $service.DeleteFile($folder, $fileName)
                $signal.MergeSignal(@($result))

                if ($result.Success()) {
                    $signal.SetResult($result.GetResult())
                    break
                }
            }
        }

        if (-not $signal.Success()) {
            $signal.LogCritical("All storage services failed to delete file.")
        }

        return $signal
    }

    [Signal] ListDirectoryObjects([string]$folder) {
        $signal = [Signal]::Start("ListDirectoryObjects") | Select-Object -Last 1

        foreach ($key in $this.ServiceCollection.Grid.Keys) {
            $serviceSignal = $this.ServiceCollection.Grid[$key]
            $service = $serviceSignal.GetResult()

            if ($service -and ($service | Get-Member -Name "ListDirectoryObjects")) {
                $result = $service.ListDirectoryObjects($folder)
                $signal.MergeSignal(@($result))

                if ($result.Success()) {
                    $signal.SetResult($result.GetResult())
                    break
                }
            }
        }

        if (-not $signal.Success()) {
            $signal.LogCritical("All storage services failed to list directory objects.")
        }

        return $signal
    }
}
