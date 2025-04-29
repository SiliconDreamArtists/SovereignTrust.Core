class Context {
    [hashtable]$ContextDictionary
    [object[]]$Replacements

    Context() {
        $this.ContextDictionary = @{}
        $this.Replacements = @()
    }

    [Signal] FindMatchingContextDictionary([string]$ContextName) {
        $signal = [Signal]::Start(@())

        try {
            $signal.LogVerbose("Finding matching context navigators for: $ContextName")

            $replacementKeys = $this.Replacements | Where-Dictionary {
                $_.Replaces -eq $ContextName
            } | ForEach-Object {
                $_.GraphName
            }

            foreach ($key in $replacementKeys) {
                if ($this.ContextDictionary.ContainsKey($key)) {
                    $signal.Result += $this.ContextDictionary[$key]
                    $signal.LogVerbose("Found matching replacement context: $key")
                } else {
                    $signal.LogVerbose("Replacement key $key not found in dictionary, skipped.")
                }
            }

            if ($this.ContextDictionary.ContainsKey($ContextName)) {
                $signal.Result += $this.ContextDictionary[$ContextName]
                $signal.LogVerbose("Found direct context match: $ContextName")
            } else {
                $signal.LogVerbose("No direct context match for: $ContextName")
            }
        } catch {
            $signal.LogCritical("Error finding matching context navigators: $_")
        }

        return $signal
    }

    [Signal] AttachJacket([string]$Key, [object]$Jacket) {
        $signal = [Signal]::Start()

        try {
            if ($null -ne $Key -and $null -ne $Jacket) {
                $this.ContextDictionary[$Key] = $Jacket
                $signal.LogVerbose("Attached jacket with key: $Key")
            } else {
                $signal.LogWarning("AttachJacket: Key or Jacket was null, skipped attachment.")
            }
        } catch {
            $signal.LogCritical("AttachJacket error: $_")
        }

        return $signal
    }

    [Signal] AttachJacketsFromList([object[]]$Jackets) {
        $signal = [Signal]::Start()

        try {
            foreach ($jacket in $Jackets) {
                if ($null -ne $jacket -and $jacket.Meta -and $jacket.Meta.Name) {
                    $this.ContextDictionary[$jacket.Meta.Name] = $jacket
                    $signal.LogVerbose("Attached jacket from list: $($jacket.Meta.Name)")
                } else {
                    $signal.LogWarning("Skipped invalid jacket entry during bulk attach.")
                }
            }
        } catch {
            $signal.LogCritical("AttachJacketsFromList error: $_")
        }

        return $signal
    }
}
