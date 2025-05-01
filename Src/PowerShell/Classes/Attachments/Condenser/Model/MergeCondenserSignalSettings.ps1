class MergeCondenserSignalSettings {
    [string]$UnresolvedWireGlobalError
    [string]$UnresolvedWireLookupValueError
    [string]$UnresolvedContextGraphError
    [string]$UnresolvedContextValueError
    [string]$UnresolvedWireBlockError

    MergeCondenserSignalSettings() {
        $this.UnresolvedWireGlobalError        = "Unresolved Wire Global: {0}"
        $this.UnresolvedWireLookupValueError   = "Unresolved Wire Lookup Value: {0}"
        $this.UnresolvedContextGraphError      = "Unresolved Context Graph: {0}"
        $this.UnresolvedContextValueError      = "Unresolved Context Value: {0}.{1}"
        $this.UnresolvedWireBlockError         = "Unresolved Wire Block: {0}"
    }
}
