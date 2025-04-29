class TokenCondenserService {
    [object]$ConduitJacket

    TokenCondenserService() {
        $this.ConduitJacket = $null
    }

    [object] GetMergeCondenserSettings() {
        if ($this.ConduitJacket -and $this.ConduitJacket.MappedCondenserService -and $this.ConduitJacket.MappedCondenserService.MergeCondenser) {
            return $this.ConduitJacket.MappedCondenserService.MergeCondenser.Settings
        } else {
            return [PSCustomObject]@{} # empty settings object
        }
    }

    [object] GetToken($Value, $CondenserFeedback, [bool]$ThrowExceptionOnEmpty = $true, [int]$RetryAttempts = 2) {
        $signal = [Signal]::Start($Value)

        if ([string]::IsNullOrWhiteSpace($Value)) { return $signal }

        $firstLookup = $Value.IndexOf(".")
        if ($firstLookup -lt 0) { return $signal }

        $tokenGraphFilePath = $Value.Substring(0, $firstLookup)
        $xpath = "/" + $Value.Substring($firstLookup).Replace(".", "/").Replace("[", "[@").Replace("[@@", "[@")

        $matchingNavigators = $CondenserFeedback.Context.FindMatchingContextDictionary($tokenGraphFilePath)
        if (-not $matchingNavigators.Result -or $matchingNavigators.Result.Count -eq 0) {
            $signal.LogCritical("Token graph dictionary not found for lookup: $Value")
            return $signal
        }

        foreach ($navigator in $matchingNavigators.Result) {
            try {
                $node = $navigator.SelectSingleNode($xpath)
                if ($node) {
                    $signal.Result = $node.InnerXml
                    return $signal
                }
            } catch {
                $signal.LogCritical("Error selecting node '$xpath': $_")
            }
        }

        $signal.LogCritical("Token node not found: $xpath")
        return $signal
    }

    [object] GetContext($CondensedWire, $CircuitWireTokenGraphs, $OverloadGraphVirtualPath = $null) {
        $signal = [Signal]::Start([Context]::new())

        try {
            $settings = $this.GetMergeCondenserSettings()
            $nodeName = $settings.CondenserSettingsNodeName

            $tokenGraphsToken = if ($CondensedWire -is [Newtonsoft.Json.Linq.JToken]) {
                $CondensedWire.SelectToken($nodeName)
            } else {
                ($CondensedWire | ConvertFrom-Json).$nodeName
            }

            if (-not $tokenGraphsToken) {
                $signal.LogWarning("Tokens node '$nodeName' not found.")
                return $signal
            }

            $tokenGraphs = $CondensedWire.$nodeName
            if (-not $tokenGraphs) { return $signal }

            $tokenGraphs = $tokenGraphs[$settings.TokensNodeName][$settings.GraphNodeName]
            if (-not $tokenGraphs) {
                $signal.LogWarning("Graph node not found under tokens.")
                return $signal
            }

            $baseImportPath = $tokenGraphs[$settings.BaseImportPathNodeName]
            $importListDynamic = $tokenGraphs[$settings.ImportNodeName]

            if (-not $baseImportPath -or -not $importListDynamic) {
                $signal.LogWarning("Missing baseImportPath or importList.")
                return $signal
            }

            $replacements = $tokenGraphs["replacements"]
            if ($replacements) {
                $signal.Result.Replacements += (ConvertFrom-Json (ConvertTo-Json $replacements))
            }

            $tokenGraphList = (ConvertFrom-Json (ConvertTo-Json $importListDynamic)) ?? @()

            if ($CircuitWireTokenGraphs) {
                $overrideImportListDynamic = $CircuitWireTokenGraphs[$settings.ImportNodeName]
                if ($overrideImportListDynamic) {
                    $overrideImportList = (ConvertFrom-Json (ConvertTo-Json $overrideImportListDynamic))
                    $tokenGraphList += ($overrideImportList ?? @())

                    $overrideReplacements = $CircuitWireTokenGraphs["replacements"]
                    if ($overrideReplacements) {
                        $signal.Result.Replacements += (ConvertFrom-Json (ConvertTo-Json $overrideReplacements))
                    }
                }
            }

            foreach ($tokenGraph in ($tokenGraphList | Sort-Dictionary -Unique)) {
                $relativePath = $tokenGraph.Replace("\", "/")
                $fullPath = $relativePath
                $adjustedBasePath = $baseImportPath

                if ($relativePath.Contains("/")) {
                    $splitParts = $relativePath.Split("/")
                    $relativePath = $splitParts[-1]
                    $adjustedBasePath = Join-Path -Path $baseImportPath -ChildPath ($fullPath.Replace($relativePath, ""))
                }

                $tokenGraphResult = $this.ConduitJacket.MappedStorageService.ReadXmlXpath($relativePath, $null, $adjustedBasePath, $null, "Documents")

                if ($signal.MergeSignalAndVerifySuccess($tokenGraphResult)) {
                    $signal.Result.ContextNavigator[$relativePath] = $tokenGraphResult.Result.CreateNavigator()
                } else {
                    break
                }
            }
        } catch {
            $signal.LogCritical($_.Exception.Message)
        }

        return $signal
    }
}
