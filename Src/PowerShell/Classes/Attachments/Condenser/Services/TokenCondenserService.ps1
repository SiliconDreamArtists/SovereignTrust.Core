class TokenCondenserService {
    [object]$Conductor

    TokenCondenserService() {
        $this.Conductor = $null
    }

    [object] GetMergeCondenserSettings() {
        if ($this.Conductor -and $this.Conductor.MappedCondenserService -and $this.Conductor.MappedCondenserService.MergeCondenser) {
            return $this.Conductor.MappedCondenserService.MergeCondenser.Settings
        } else {
            return [PSCustomObject]@{} # empty settings object
        }
    }

    [Signal] GetToken([string]$Value, $CondenserFeedback, [bool]$ThrowExceptionOnEmpty = $true, [int]$RetryAttempts = 2) {
        $signal = [Signal]::new("GetToken:$Value")
    
        if ([string]::IsNullOrWhiteSpace($Value)) {
            $signal.LogWarning("Token value was empty or null.")
            return $signal
        }
    
        $firstLookup = $Value.IndexOf(".")
        if ($firstLookup -lt 0) {
            $signal.LogWarning("Token missing required lookup structure (e.g., no dot separator): $Value")
            return $signal
        }
    
        $tokenGraphFilePath = $Value.Substring(0, $firstLookup)
        $xpath = "/" + $Value.Substring($firstLookup).Replace(".", "/").Replace("[", "[@").Replace("[@@", "[@")
    
        $matchingNavigators = $CondenserFeedback.Context.FindMatchingContextDictionary($tokenGraphFilePath)
        $signal.MergeSignal(@($matchingNavigators))
    
        $navigators = $matchingNavigators.GetResult()
        if (-not $navigators -or $navigators.Count -eq 0) {
            $signal.LogCritical("Token graph dictionary not found for: $Value")
            return $signal
        }
    
        foreach ($navigator in $navigators) {
            try {
                $node = $navigator.SelectSingleNode($xpath)
                if ($node) {
                    $signal.SetResult($node.InnerXml)
                    $signal.LogInformation("Token successfully resolved: $Value → $($node.InnerXml)")
                    return $signal
                }
            } catch {
                $signal.LogWarning("Navigator exception for path '$xpath': $_")
            }
        }
    
        $signal.LogCritical("Token not resolved — node not found at: $xpath")
        return $signal
    }
    
    [Signal] GetContext($TokenDocument, $TokenGraphOverrides, $OverloadGraphVirtualPath = $null) {
        $signal = [Signal]::new("GetContext")
    
        try {
            # ░▒▓█ SETTINGS RETRIEVAL █▓▒░
            $settings = $this.GetMergeCondenserSettings()
            $nodeName = $settings.CondenserSettingsNodeName
    
            # ░▒▓█ TOKEN NODE RESOLUTION █▓▒░
            $tokenGraphsSignal = if ($TokenDocument -is [Newtonsoft.Json.Linq.JToken]) {
                [Signal]::Start($TokenDocument.SelectToken($nodeName))
            } else {
                Resolve-PathFromDictionary -Dictionary $TokenDocument -Path $nodeName
            }
    
            $signal.MergeSignal(@($tokenGraphsSignal))
            $tokenGraphs = $tokenGraphsSignal.GetResult()
    
            if (-not $tokenGraphs) {
                $signal.LogWarning("Tokens node '$nodeName' not found in TokenDocument.")
                return $signal
            }
    
            $graphsNode = $tokenGraphs[$settings.TokensNodeName][$settings.GraphNodeName]
            if (-not $graphsNode) {
                $signal.LogWarning("Graph node '$($settings.GraphNodeName)' not found under Tokens.")
                return $signal
            }
    
            # ░▒▓█ IMPORT CONFIG █▓▒░
            $tokenGraphRoot = $graphsNode[$settings.TokenGraphRootNodeName]
            $importListRaw = $graphsNode[$settings.ImportNodeName]
    
            if (-not $tokenGraphRoot -or -not $importListRaw) {
                $signal.LogWarning("Missing tokenGraphRoot or importList.")
                return $signal
            }
    
            $context = @{}
    
            # ░▒▓█ REPLACEMENTS █▓▒░
            $replacements = $graphsNode["replacements"]
            if ($replacements) {
                $context.Replacements += (ConvertFrom-Json (ConvertTo-Json $replacements))
            }
    
            # ░▒▓█ IMPORT LIST █▓▒░
            $importList = @(ConvertFrom-Json (ConvertTo-Json $importListRaw))
    
            # ░▒▓█ CIRCUIT OVERRIDES █▓▒░
            if ($TokenGraphOverrides) {
                $overrideImports = $TokenGraphOverrides[$settings.ImportNodeName]
                if ($overrideImports) {
                    $importList += @(ConvertFrom-Json (ConvertTo-Json $overrideImports))
                }
    
                $overrideReplacements = $TokenGraphOverrides["replacements"]
                if ($overrideReplacements) {
                    $context.Replacements += (ConvertFrom-Json (ConvertTo-Json $overrideReplacements))
                }
            }
    
            # ░▒▓█ TOKEN GRAPH IMPORT █▓▒░
            foreach ($tokenGraph in ($importList | Sort-Dictionary -Unique)) {
                $relativePath = $tokenGraph.Replace("\", "/")
                $adjustedBasePath = $tokenGraphRoot
    
                if ($relativePath.Contains("/")) {
                    $splitParts = $relativePath.Split("/")
                    $relativePath = $splitParts[-1]
                    $adjustedBasePath = Join-Path -Path $tokenGraphRoot -ChildPath ($tokenGraph.Replace($relativePath, ""))
                }
    
                $graphSignal = $this.Conductor.MappedStorageService.ReadXmlXpath(
                    $relativePath, $null, $adjustedBasePath, $null, "Documents"
                )
    
                if ($signal.MergeSignalAndVerifySuccess(@($graphSignal))) {
                    $context.ContextNavigator[$relativePath] = $graphSignal.GetResult().CreateNavigator()
                } else {
                    $signal.LogCritical("Aborted graph loading due to failed resolution of: $relativePath")
                    return $signal
                }
            }
    
            $signal.SetResult($context)
            $signal.LogInformation("✅ Token context environment built successfully.")
        }
        catch {
            $signal.LogCritical("Unhandled exception in GetContext: $($_.Exception.Message)")
        }
    
        return $signal
    }
}
