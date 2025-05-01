class MappedStorageAttachment {
    [hashtable]$ServiceCollection
    $MyName = "MappedStorageAttachment"

    MappedStorageAttachment() {
        $this.ServiceCollection = @{}
    }

    [Signal] RegisterAttachment([object]$storageService) {
        $signal = [Signal]::new("Register-Service")

        try {
            if ($null -eq $storageService) {
                return $signal.LogCritical("Cannot register null storage service.")
            }

            if (-not $this.ServiceCollection.ContainsKey($storageService)) {
                $this.ServiceCollection[$storageService] = $storageService.Jacket?.Slot
                $signal.LogInformation("Storage service registered successfully.")
            } else {
                $signal.LogWarning("Storage service already registered.")
            }
        }
        catch {
            $signal.LogCritical("Error registering storage service: $_")
        }

        return $signal
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
