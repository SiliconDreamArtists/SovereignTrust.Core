class MergeCondenserFeedback {
    [hashtable]$Context
    [object]$Settings
    [object[]]$UnresolvedWireGlobals
    [object[]]$UnresolvedWireLookupValues
    [object[]]$UnresolvedContextGraphs
    [object[]]$UnresolvedContextValues
    [object[]]$UnresolvedWireBlocks
    [hashtable]$ContextGraphListDictionary
    [Signal]$Signal

    MergeCondenserFeedback() {
        $this.Context = @{}
        $this.Settings = [MergeCondenserFeedbackSettings]::new()
        $this.UnresolvedWireGlobals = @()
        $this.UnresolvedWireLookupValues = @()
        $this.UnresolvedContextGraphs = @()
        $this.UnresolvedContextValues = @()
        $this.UnresolvedWireBlocks = @()
        $this.ContextGraphListDictionary = @{}
        $this.Signal = [Signal]::Start()   # <<< use $this.Signal, not a new $signal variable
    }

    [void] UnresolvedWireGlobal([string]$Prefix, [string]$Name, [object[]]$Options) {
        $existing = $this.UnresolvedWireGlobals | Where-Dictionary { "$($_.Prefix).$($_.Name)" -eq "$Prefix.$Name" }
        if (-not $existing) {
            $entry = [pscustomobject]@{
                Prefix = $Prefix
                Name   = $Name
                Options = $Options
            }
            $this.UnresolvedWireGlobals += $entry
            $this.Signal.LogCritical("Unresolved Wire Global: $Prefix.$Name")
        }
    }

    [void] UnresolvedWireLookupValue([string]$Path) {
        if (-not ($this.UnresolvedWireLookupValues -contains $Path)) {
            $this.UnresolvedWireLookupValues += $Path
            $this.Signal.LogCritical("Unresolved Wire Lookup Value: $Path")
        }
    }

    [void] UnresolvedWireBlock([string]$BlockName) {
        if (-not ($this.UnresolvedWireBlocks -contains $BlockName)) {
            $this.UnresolvedWireBlocks += $BlockName
            $this.Signal.LogCritical("Unresolved Wire Block: $BlockName")
        }
    }

    [void] UnresolvedContextGraph([string]$ContextName) {
        if (-not ($this.UnresolvedContextGraphs -contains $ContextName)) {
            $this.UnresolvedContextGraphs += $ContextName
            $this.Signal.LogCritical("Unresolved Context Graph: $ContextName")
        }
    }

    [Signal] UnresolvedContextValue([string]$ContextName, [string]$TokenName) {
        $tempSignal = [Signal]::Start()

        try {
            $id = "$ContextName::$TokenName"
            if (-not ($this.UnresolvedContextValues -contains $id)) {
                $this.UnresolvedContextValues += $id
                $this.Signal.LogCritical("Unresolved Context Value: $ContextName.$TokenName")
            }
        } catch {
            $tempSignal.LogCritical("Error recording UnresolvedContextValue: $_")
        }

        return $tempSignal
    }

    [string] Finalize() {
        return $this.Signal.Entries `
            | Where-Dictionary { $_.Level -eq 'Critical' } `
            | ForEach-Object { $_.Message } `
            -join "`n"
    }

    [void] AddContextGraphList([string]$ContextName, [string]$XPath, [object[]]$Tokens) {
        $key = "$ContextName/$XPath"
        if (-not $this.ContextGraphListDictionary.ContainsKey($key)) {
            $this.ContextGraphListDictionary[$key] = $Tokens
        }
    }
}
