class MergeCondenserSettings{

}

class MergeCondenserService {
    [TokenCondenserService]$TokenGraphService
    [MergeCondenserSettings]$Settings
    [Conductor]$Conductor

    MergeCondenserService([object]$MappedCondenserService, [Conductor]$Conductor) {
        $this.TokenGraphService = [TokenCondenserService]::new()
        $this.TokenGraphService.Conductor = $Conductor
        $this.Settings = [MergeCondenserSettings]::new()
        $this.Conductor = $Conductor
    }

    [Signal] RetrieveWire([object]$MappedStorageService, [Guid]$Version) {
        $signal = $MappedStorageService.DownloadWire($Version)
        if ($signal.Success) {
            $latestWire = $MappedStorageService.DownloadWire($signal.Result.Identifier)
            if ($latestWire.Success -and $latestWire.Result.Version -ne $signal.Result.Version) {
                $signal.LogInformation("Latest Version replaced: $($latestWire.Result.Version)")
                $signal.Result = $latestWire.Result
            }
        }
        return $signal
    }

    [Signal] ImportBlobs([array]$Blobs) {
        $signal = [Signal]::Start()
        $result = @{}

        foreach ($blob in $Blobs) {
            $itemDictionary = ($blob | ConvertTo-Json -Depth 10 | ConvertFrom-Json) -as [hashtable]
            foreach ($item in $itemDictionary.GetEnumerator()) {
                if (-not $result.ContainsKey($item.Key)) {
                    $result[$item.Key] = $item.Value
                }
            }
        }
        $signal.Result = $result
        return $signal
    }

    [Signal] RetrieveCircuitTokens([MergeCondenserProposal]$Proposal) {
        $signal = [Signal]::Start()
        try {
            $circuit = [CondenserGraphHelper]::BuildGraph($Proposal.CircuitWire)
            $vals = [JsonHelper]::SelectToken($circuit, $this.Settings.TokensPathNodeName)

            foreach ($val in $vals) {
                $tokenSet = $val[$Proposal.CircuitToken] ?? $val[$Proposal.CircuitTokenBackup]
                if ($tokenSet) {
                    $signal.Result = $tokenSet
                    return $signal
                }
            }
        } catch {
            $signal.LogCritical("RetrieveCircuitTokens Exception: $_")
        }
        return $signal
    }

    [Signal] Condense([object]$StorageService, [MergeCondenserProposal]$Proposal, [string]$OverrideGraphVirtualPath = $null, [bool]$ReturnRequiredValues = $false) {
        $feedback = [MergeCondenserFeedback]::new()
        $feedback.LogInformation("Condense Started")

        try {
            if (-not $Proposal.CircuitWire) {
                $feedback.LogCritical("Null CircuitWire.")
                return $feedback
            }

            if ($feedback.MergeSignalAndCheckForFail($Proposal.ReduceWireDynamics($this.Settings.TokensNodeName))) { return $feedback }
            if ($feedback.MergeSignalAndCheckForFail($Proposal.NestWireDynamics($this.Settings.TokensNodeName))) { return $feedback }

            if ($Proposal.LeadWire) {
                $lead = [CondenserGraphHelper]::BuildGraph($Proposal.LeadWire)
                $circuit = [CondenserGraphHelper]::BuildGraph($Proposal.CircuitWire)
                [CondenserGraphHelper]::MergeGraphs($lead, $circuit)
                $Proposal.TokenDocument = $lead
            } else {
                $Proposal.TokenDocument = $Proposal.CircuitWire
            }

            if (-not $Proposal.PerformMergeOnly) {
                $updatedWire = $this.ReplaceTagValues($Proposal, $feedback, $Proposal.TokenDocument, $ReturnRequiredValues)
                if ($feedback.MergeSignalAndCheckForFail($updatedWire)) { return $feedback }

                $outerParams = $this.ReplaceServiceTokens($updatedWire.Result, $feedback, $Proposal.CircuitWire, $OverrideGraphVirtualPath, $ReturnRequiredValues)
                if ($feedback.MergeSignalAndCheckForFail($outerParams)) { return $feedback }

                $updatedWire = $this.CondenseRelayTokenSetsIntoGraph($Proposal.RelayDataDictionary, $outerParams.Result)
                $feedback.Result = $updatedWire.Result
            } else {
                $feedback.Result = $Proposal.TokenDocument
            }
        } catch {
            $feedback.LogCritical($_)
        }

        return $feedback
    }

    [Signal] ReplaceTagValues([MergeCondenserProposal]$Proposal, [MergeCondenserFeedback]$Feedback, [object]$GlobalGraph, [bool]$ReturnRequiredValues) {
        $signal = [Signal]::Start([CondenserGraphHelper]::BuildGraph($GlobalGraph))

        if ($Proposal.ModifyJContext) {
            [CondenserGraphHelper]::ReplaceProperties($signal.Result, $Proposal.ModifyJContext)
        }

        $globals = [CondenserGraphHelper]::RetrieveGlobals($signal.Result, $this.Settings.TagNodeName)
        if ($globals) {
            [CondenserGraphHelper]::NavigateAndReplaceStrings($globals, {
                param($prop)
                # (custom derivation logic would go here)
            })
        }

        return $signal
    }

    [Signal] ReplaceServiceTokens([object]$CondensedTokenGraph, [MergeCondenserFeedback]$Feedback, [object]$OverloadTokens, [string]$OverrideGraphVirtualPath = $null, [bool]$ReturnRequiredValues = $false) {
        $signal = [Signal]::Start()

        try {
            $outerParams = [CondenserGraphHelper]::BuildGraph($CondensedTokenGraph)

            $tokenGraphResult = ($this.Conductor.MappedTokenService.TokenCondenserService ?? $this.TokenGraphService).GetContext(
                $CondensedTokenGraph, $OverloadTokens, $OverrideGraphVirtualPath
            )
            $signal.MergeSignalAndVerifySuccess($tokenGraphResult)

            if ($signal.Success) {
                $Feedback.Context = $tokenGraphResult.Result
                $signal.Result = $outerParams
            }
        } catch {
            $signal.LogCritical("ReplaceServiceTokens Exception: $_")
        }

        return $signal
    }

    [Signal] Invoke([string]$Slot, [object]$Proposal, [object]$CancellationToken) {
        $signal = [Signal]::Start()
        $condenseResult = $this.Condense($this.Conductor.MappedStorageService, $Proposal)
        $signal.Result = $condenseResult.Result
        return $signal
    }
}
