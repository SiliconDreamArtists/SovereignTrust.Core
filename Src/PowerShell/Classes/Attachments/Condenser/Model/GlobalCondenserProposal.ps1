class GlobalCondenserProposal {
    [object]$Wire
    [string]$WireMergeType
    [bool]$Reload
    [int]$LoadLevel
    [int]$AutoRunConductionLevel
    [bool]$AutoRunConduction
    [object]$GetWires  # Stored as a scriptblock or delegate-style object

    GlobalCondenserProposal() {
        $this.Reload = $false
        $this.LoadLevel = 0
        $this.AutoRunConductionLevel = -1
        $this.AutoRunConduction = $false
        $this.WireMergeType = 'Unspecified'
        $this.GetWires = $null
    }
}
