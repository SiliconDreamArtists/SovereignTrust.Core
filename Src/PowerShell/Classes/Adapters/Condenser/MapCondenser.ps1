# ░▒▓█ SDA MapCondenser █▓▒░
# PowerShell implementation of MapCondenser for SovereignTrust
# Performs template condensation using dynamic mappings and embedded context.

class MapCondenser {
    [Conductor]$Conductor
    [MappedCondenserAdapter]$MappedCondenserAdapter
    [Signal]$ControlSignal

    MapCondenser([MappedCondenserAdapter]$mappedAdapter, [Conductor]$conductor) {
        $this.MappedCondenserAdapter = $mappedAdapter
        $this.Conductor = $conductor
        $this.ControlSignal = [Signal]::new("MergeCondenser.Control")
    }

    [Signal] CondenseTemplate([object]$Proposal, [object]$Context) {
        $signal = [Signal]::new("CondenseTemplate")

        if (-not $Proposal -or -not $Proposal.Content) {
            $signal.LogCritical("Invalid or missing Proposal.Content for condensation.")
            return $signal
        }

        $variableTags = $this.GetVariableTags($Proposal.Content, $Proposal.ReplacementType)

        foreach ($tag in $variableTags) {
            foreach ($source in $Proposal.SourceRelayList) {
                $relayData = $Proposal.RelayData | Where-Object { $_.Key.RelayFilename -eq $source }

                if ($relayData.Value) {
                    $resolved = Resolve-PathFromDictionary -Dictionary $relayData.Value -Path $tag
                    $signal.MergeSignal(@($resolved))

                    if ($resolved.Success()) {
                        $Proposal.Content = $this.ReplaceTagInContent($Proposal.Content, $resolved.GetResult(), $tag, $Proposal.MappingType, $Proposal.ReplacementType)
                    }
                }
            }
        }

        $signal.SetResult(@{
            Content = $Proposal.Content
        })

        $signal.LogInformation("Condensation completed.")
        return $signal
    }

    [string] ReplaceTagInContent([string]$Input, [string]$Value, [string]$Tag, [string]$MappingType, [string]$ReplacementType) {
        if ($MappingType -eq 'Set') {
            return $Value
        }

        $tags = $this.GetReplacementPatterns($Tag, $ReplacementType)
        foreach ($pattern in $tags) {
            $Input = $Input.Replace($pattern, $Value)
        }

        return $Input
    }

    [string[]] GetReplacementPatterns([string]$Tag, [string]$Type) {
        switch ($Type) {
            'XmlTag'       { return @("<$Tag />", "&lt;$Tag /&gt;") }
            'HashHashtag'  { return @("##$Tag") }
            'AtAttag'      { return @("@@$Tag") }
            default        { return @() }
        }

        return @()
    }

    [string[]] GetVariableTags([string]$Content, [string]$Type) {
        if (-not $Content) { return @() }

        switch ($Type) {
            'AtAttag'     { return [regex]::Matches($Content, "@@[a-zA-Z0-9-]+") | ForEach-Object { $_.Value.Substring(2) } }
            'HashHashtag' { return [regex]::Matches($Content, "##[a-zA-Z0-9_.-]+") | ForEach-Object { $_.Value.Substring(2) } }
            default       { return @() }
        }
 
        return @()
    }
}
