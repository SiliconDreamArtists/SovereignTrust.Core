class MergeCondenserProposal {
    [bool]$PerformMergeOnly
    [hashtable]$ModifyContextDictionary
    [string]$CircuitToken
    [string]$CircuitTokenBackup
    [string]$BaseToken
    [string]$BaseTokenBackup
    [string]$BaseNestPath
    [object]$CondensedWire
    [object]$BaseWire
    [object]$CircuitWire
    [string]$MergeArrayFormatType
    [hashtable]$RelayDataDictionary

    MergeCondenserProposal() {
        $this.PerformMergeOnly = $false
        $this.ModifyContextDictionary = @{}
        $this.RelayDataDictionary = @{}
    }

    [Signal] NestWireDynamics([string]$NestNodePath) {
        $signal = [Signal]::Start()

        if (![string]::IsNullOrWhiteSpace($this.BaseNestPath)) {
            $result = [MergeCondenserProposal]::NestInnerTokens($this.BaseWire, $this.BaseNestPath)

            if ($signal.MergeSignalAndVerify($result)) {
                $this.BaseWire = $result.Result
                $this.BaseNestPath = $null
            }
        }

        return $signal
    }

    [Signal] ReduceWireDynamics([string]$TokenNodeName) {
        $signal = [Signal]::Start()

        if (![string]::IsNullOrWhiteSpace($this.CircuitToken)) {
            $result = [MergeCondenserProposal]::RetrieveInnerTokens($this.CircuitWire, $this.CircuitToken, $TokenNodeName)
            if (-not $result.Result -and $this.CircuitTokenBackup) {
                $result = [MergeCondenserProposal]::RetrieveInnerTokens($this.CircuitWire, $this.CircuitTokenBackup, $TokenNodeName)
            }

            if ($signal.MergeSignalAndVerify($result)) {
                $this.CircuitWire = $result.Result
                $this.CircuitToken = $null
            }
        }

        if (![string]::IsNullOrWhiteSpace($this.BaseToken)) {
            $result = [MergeCondenserProposal]::RetrieveInnerTokens($this.BaseWire, $this.BaseToken, $TokenNodeName)
            if (-not $result.Result -and $this.BaseTokenBackup) {
                $result = [MergeCondenserProposal]::RetrieveInnerTokens($this.BaseWire, $this.BaseTokenBackup, $TokenNodeName)
            }

            if ($signal.MergeSignalAndVerify($result)) {
                $this.BaseWire = $result.Result
                $this.BaseToken = $null
            }
        }

        return $signal
    }

    static [Signal] RetrieveInnerTokens([object]$TokenDictionaryDynamic, [string]$TokenKey, [string]$TokenNodeName) {
        $signal = [Signal]::Start($null, "VerboseInformation", "Retrieve Token Graph Fragment for $TokenKey")

        try {
            if (![string]::IsNullOrWhiteSpace($TokenKey)) {
                $jtoken = [JsonHelper]::FromObject($TokenDictionaryDynamic)
                $vals = [JsonHelper]::SelectToken($jtoken, $TokenNodeName)
                foreach ($val in $vals) {
                    $tokenSet = $val[$TokenKey]
                    if ($tokenSet) {
                        $signal.Result = $tokenSet
                        return $signal
                    }
                }
            }
        } catch {
            $signal.LogCritical("RetrieveInnerTokens Exception for $TokenKey : $_")
        }

        $signal.Result = $TokenDictionaryDynamic
        return $signal
    }

    static [Signal] NestInnerTokens([object]$TokenDictionaryDynamic, [string]$NestNodePath) {
        $signal = [Signal]::Start($null, "VerboseInformation", "Nest Token Graph Fragment for $NestNodePath")

        try {
            if (![string]::IsNullOrWhiteSpace($NestNodePath)) {
                $jtoken = [JsonHelper]::FromObject($TokenDictionaryDynamic)
                $segments = $NestNodePath -split '\.' | Sort-Dictionary -Descending
                foreach ($segment in $segments) {
                    $wrapper = [Newtonsoft.Json.Linq.JObject]::new()
                    [JsonHelper]::SetProperty($wrapper, $segment, $jtoken)
                    $jtoken = $wrapper
                }
                $signal.Result = $jtoken
            } else {
                $signal.Result = $TokenDictionaryDynamic
            }
        } catch {
            $signal.LogCritical("NestInnerTokens Exception for $NestNodePath : $_")
        }

        return $signal
    }
}
