<#
================================================================================
📦 MappedStorageAttachment • AI Trainer Block (Doctrine v1.0)
================================================================================

MappedStorageAttachment is the sovereign abstraction layer for accessing
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

🔁 Attachments are Evolving.
Each registered service is a dynamic attachment. Services can be replaced,
mutated, or upgraded without altering the conduction flow above.

♾️ Recursion is Home.
This object can defer to its owning Conductor. The Conductor can fall back
to its HostConductor. Together, they form the recursive memory fabric that
bootstraps Sovereign execution.

MappedStorageAttachment enables runtime access to all sovereign plans,
templates, modules, and data — using only memory and WirePath.

> “When memory becomes sovereign, storage becomes signal.”

#>

class MappedStorageAttachment {
    [object]$Conductor
    [hashtable]$ServiceCollection
    $MyName = "MappedStorageAttachment"

    MappedStorageAttachment([object]$conductor) {
        $this.ServiceCollection = @{}
        $this.Conductor = $conductor
    }

    [Signal] RegisterAttachment([object]$service) {
        return Register-MappedAttachment -ServiceCollection $this.ServiceCollection -Attachment $service -Label "StorageService"
    }

    [Signal] ReadObjectAsJson([string]$folder, [string]$fileName) {
        $signal = [Signal]::new("ReadObjectAsJson")

        foreach ($service in $this.ServiceCollection.Keys) {
            $result = $service.ReadObjectAsJson($folder, $fileName)
            $signal.MergeSignal(@($result))

            if ($result.Success()) {
                $signal.SetResult($result.GetResult())
                break
            }
        }

        if (-not $signal.Success()) {
            $signal.LogCritical("All storage services failed to read JSON object.")
        }

        return $signal
    }

    [Signal] ReadObjectAsXml([string]$folder, [string]$fileName) {
        $signal = [Signal]::new("ReadObjectAsXml")

        foreach ($service in $this.ServiceCollection.Keys) {
            $result = $service.ReadObjectAsXml($folder, $fileName)
            $signal.MergeSignal(@($result))

            if ($result.Success()) {
                $signal.SetResult($result.GetResult())
                break
            }
        }

        if (-not $signal.Success()) {
            $signal.LogCritical("All storage services failed to read XML object.")
        }

        return $signal
    }

    [Signal] DeleteFile([string]$folder, [string]$fileName) {
        $signal = [Signal]::new("DeleteFile")

        foreach ($service in $this.ServiceCollection.Keys) {
            $result = $service.DeleteFile($folder, $fileName)
            $signal.MergeSignal(@($result))

            if ($result.Success()) {
                $signal.SetResult($result.GetResult())
                break
            }
        }

        if (-not $signal.Success()) {
            $signal.LogCritical("All storage services failed to delete file.")
        }

        return $signal
    }

    [Signal] ListDirectoryObjects([string]$folder) {
        $signal = [Signal]::new("ListDirectoryObjects")

        foreach ($service in $this.ServiceCollection.Keys) {
            $result = $service.ListDirectoryObjects($folder)
            $signal.MergeSignal(@($result))

            if ($result.Success()) {
                $signal.SetResult($result.GetResult())
                break
            }
        }

        if (-not $signal.Success()) {
            $signal.LogCritical("All storage services failed to list directory objects.")
        }

        return $signal
    }
}
