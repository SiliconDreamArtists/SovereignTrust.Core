# =============================================================================
# 🔐 TokenCondenser (Graph Context + XPath Token Resolution)
#  License: MIT License • Copyright (c) 2025 Silicon Dream Artists / BDDB
#  Authors: Shadow PhanTom ☠️🧁👾️/🤖 • Neural Alchemist ⚗️☣️🐲 • Last Updated: 05/20/2025
# =============================================================================
# Uses XPath-based token lookup with imported graph documents to resolve runtime
# variables within sovereign templates. This condenser class is central to hydration
# flows, token graph processing, and context-sensitive publishing.
# =============================================================================

class TokenCondenser {
    [Conductor]$Conductor
    [MappedCondenserAdapter]$MappedCondenserAdapter
    [Signal]$Signal

    TokenCondenser() {
        # Empty constructor — use Start()
    }

    static [TokenCondenser] Start([MappedCondenserAdapter]$mappedAdapter, [Conductor]$conductor) {
        $instance = [TokenCondenser]::new()
        $instance.MappedCondenserAdapter = $mappedAdapter
        $instance.Conductor = $conductor
        $instance.Signal = [Signal]::Start("TokenCondenser.Control") | Select-Object -Last 1
        return $instance
    }

    [object] GetMergeCondenserSettings() {
        if ($this.Conductor -and $this.Conductor.MappedCondenserAdapter -and $this.Conductor.MappedCondenserAdapter.MergeCondenser) {
            return $this.Conductor.MappedCondenserAdapter.MergeCondenser.Settings
        } else {
            return [PSCustomObject]@{}
        }
    }

    [Signal] GetToken([string]$Value, $CondenserSignal, [bool]$ThrowExceptionOnEmpty = $true, [int]$RetryAttempts = 2) {
        $opSignal = [Signal]::Start("GetToken:$Value") | Select-Object -Last 1

        if ([string]::IsNullOrWhiteSpace($Value)) {
            return $opSignal.LogWarning("Token value was empty or null.")
        }

        $firstLookup = $Value.IndexOf(".")
        if ($firstLookup -lt 0) {
            return $opSignal.LogWarning("Token missing required lookup structure (e.g., no dot separator): $Value")
        }

        $tokenGraphFilePath = $Value.Substring(0, $firstLookup)
        $xpath = "/" + $Value.Substring($firstLookup).Replace(".", "/").Replace("[", "[@").Replace("[@@", "[@")

        $matchingNavigators = $CondenserSignal.Context.FindMatchingContextDictionary($tokenGraphFilePath)
        $opSignal.MergeSignal(@($matchingNavigators))

        $navigators = $matchingNavigators.GetResult()
        if (-not $navigators -or $navigators.Count -eq 0) {
            return $opSignal.LogCritical("Token graph dictionary not found for: $Value")
        }

        foreach ($navigator in $navigators) {
            try {
                $node = $navigator.SelectSingleNode($xpath)
                if ($node) {
                    $opSignal.SetResult($node.InnerXml)
                    return $opSignal.LogInformation("Token successfully resolved: $Value → $($node.InnerXml)")
                }
            } catch {
                $opSignal.LogWarning("Navigator exception for path '$xpath': $_")
            }
        }

        return $opSignal.LogCritical("Token not resolved — node not found at: $xpath")
    }

    [Signal] GetContext($TokenDocument, $TokenGraphOverrides, $OverloadGraphVirtualPath = $null) {
        $opSignal = [Signal]::Start("GetContext") | Select-Object -Last 1

        try {
            $settings = $this.GetMergeCondenserSettings()
            $nodeName = $settings.CondenserSettingsNodeName

            $tokenGraphsSignal = if ($TokenDocument -is [Newtonsoft.Json.Linq.JToken]) {
                [Signal]::Start($TokenDocument.SelectToken($nodeName)) | Select-Object -Last 1
            } else {
                Resolve-PathFromDictionary -Dictionary $TokenDocument -Path $nodeName
            }

            $opSignal.MergeSignal(@($tokenGraphsSignal))
            $tokenGraphs = $tokenGraphsSignal.GetResult()

            if (-not $tokenGraphs) {
                return $opSignal.LogWarning("Tokens node '$nodeName' not found in TokenDocument.")
            }

            $graphsNode = $tokenGraphs[$settings.TokensNodeName][$settings.GraphNodeName]
            if (-not $graphsNode) {
                return $opSignal.LogWarning("Graph node '$($settings.GraphNodeName)' not found under Tokens.")
            }

            $tokenGraphRoot = $graphsNode[$settings.TokenGraphRootNodeName]
            $importListRaw = $graphsNode[$settings.ImportNodeName]
            if (-not $tokenGraphRoot -or -not $importListRaw) {
                return $opSignal.LogWarning("Missing tokenGraphRoot or importList.")
            }

            $context = @{}

            $replacements = $graphsNode["replacements"]
            if ($replacements) {
                $context.Replacements += (ConvertFrom-Json (ConvertTo-Json $replacements))
            }

            $importList = @(ConvertFrom-Json (ConvertTo-Json $importListRaw))

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

                if ($opSignal.MergeSignalAndVerifySuccess(@($graphSignal))) {
                    $context.ContextNavigator[$relativePath] = $graphSignal.GetResult().CreateNavigator()
                } else {
                    return $opSignal.LogCritical("Aborted graph loading due to failed resolution of: $relativePath")
                }
            }

            $opSignal.SetResult($context)
            return $opSignal.LogInformation("✅ Token context environment built successfully.")
        }
        catch {
            return $opSignal.LogCritical("Unhandled exception in GetContext: $($_.Exception.Message)")
        }
    }
}
