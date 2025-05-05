class GraphCondenser {
    [Conductor]$Conductor
    [MappedCondenserAdapter]$MappedCondenserAdapter
    [Signal]$ControlSignal

    GraphCondenser([MappedCondenserAdapter]$mappedAdapter, [Conductor]$conductor) {
        $this.MappedCondenserAdapter = $mappedAdapter
        $this.Conductor = $conductor
        $this.ControlSignal = [Signal]::new("GraphCondenser.Control")
    }

    GraphCondenser([object]$mappedCondenserAdapter) {
        $this.MappedCondenserAdapter = $mappedCondenserAdapter
    }

    [Signal] CondenseMini([object]$Proposal, [object]$CancellationToken, [string]$OverrideTemplatePath = $null) {
        $signal = [Signal]::new("CondenseMini")
        $signal.Result = [PSCustomObject]@{ Content = "" }

        $variableTags = $this.GetVariableTags($Proposal.Content, $Proposal.ReplacementType)

        foreach ($tag in $variableTags) {
            foreach ($source in $Proposal.SourceRelayList) {
                $relayData = $Proposal.RelayData | Where-Dictionary { $_.Key.RelayFilename -eq $source }
                if ($relayData.Value) {
                    $sourceItem = Resolve-PathFromDictionaryNoSignal -Dictionary $relayData.Value -Path $tag
                    if ($sourceItem) {
                        $Proposal.Content = $this.UpdateStringValues($Proposal.Content, $sourceItem.ToString(), $tag, $Proposal.MappingType, $Proposal.ReplacementType)
                    }
                }
            }
        }

        $signal.Result.Content = $Proposal.Content
        return $signal
    }

    [string] UpdateStringValues([string]$InputValue, [string]$AugmentedValue, [string]$LookupTag, [string]$MappingType, [string]$ReplacementType) {
        if ($null -eq $InputValue) { return $null }

        switch ($MappingType) {
            'Set' {
                return $AugmentedValue
            }
            default {
                $replacements = $this.GetReplacementStrings($LookupTag, $ReplacementType)
                foreach ($r in $replacements) {
                    $InputValue = $InputValue.Replace($r, $AugmentedValue)
                }
                return $InputValue
            }
        }

        return $null
    }

    [string[]] GetReplacementStrings([string]$LookupTag, [string]$ReplacementType) {
        $list = @()
        switch ($ReplacementType) {
            'XmlTag' { $list += "&lt;$LookupTag /&gt;"; $list += "<$LookupTag />" }
            'AtAttag' { $list += "@@$LookupTag" }
            'HashHashtag' { $list += "##$LookupTag" }
            default { }
        }
        return $list
    }

    [string[]] GetVariableTags([string]$InputValue, [string]$ReplacementType) {
        if ($null -eq $InputValue) { return @() }
            # TODO Add support for all specified replacement types through a plugin system.

        switch ($ReplacementType) {
            'AtAttag' {
                return [regex]::Matches($InputValue, "@@[a-zA-Z0-9-]+") | ForEach-Object { $_.Value.Substring(2) }
            }
            'HashHashtag' {
                return [regex]::Matches($InputValue, "##[a-zA-Z0-9_.-]+") | ForEach-Object { $_.Value.Substring(2) }
            }
            default {
                return @()
            }
        }

        return $null
    }
}
