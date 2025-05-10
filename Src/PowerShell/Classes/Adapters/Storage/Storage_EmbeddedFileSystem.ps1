class Storage_EmbeddedFileSystem {
    [MappedStorageAdapter]$MappedAdapter
    [object]$Jacket

    Storage_EmbeddedFileSystem() {
    }

    Storage_EmbeddedFileSystem([MappedStorageAdapter]$mappedAdapter) {
        $this.MappedAdapter = $mappedAdapter
    }

    [Signal] Construct([object]$dictionary) {
        $signal = [Signal]::Start("Construct-EmbeddedFileSystem")

        try {
            if ($null -eq $dictionary) {
                return $signal.LogCritical("Cannot construct EmbeddedFileSystem — provided dictionary is null.")
            }

            $this.Jacket = $dictionary
            $signal.LogInformation("EmbeddedFileSystem constructed successfully with provided jacket.")
        }
        catch {
            $signal.LogCritical("Error constructing EmbeddedFileSystem: $_")
        }

        return $signal
    }

    [Signal] ReadObjectAsJson([string]$virtualPath) {
        $signal = [Signal]::Start("EmbeddedFileSystem.ReadObjectAsJson")

        try {
            $pathWithExtension = "$virtualPath.json"
            $jsonSignal = Get-JsonObjectFromFile -RootFolder $this.Jacket.Address -VirtualPath $pathWithExtension | Select-Object -Last 1
            $signal.MergeSignal($jsonSignal)

            if ($jsonSignal.Success()) {
                $signal.SetResult($jsonSignal.GetResult())
                $signal.LogInformation("📄 JSON content read from embedded file system: $pathWithExtension")
            } else {
                $signal.LogWarning("⚠️ Failed to read JSON from: $pathWithExtension")
            }
        }
        catch {
            $signal.LogCritical("🔥 Exception in EmbeddedFileSystem.ReadObjectAsJson: $($_.Exception.Message)")
        }

        return $signal
    }
}
