class MappedCondenserAdapter {
    [object]$GlobalCondenser
    [object]$TokenCondenser
    [object]$MapCondenser
    [object]$MergeCondenser
    [object]$GraphCondenser
    [object]$FormulaGraphCondenser
    [object]$Conductor

    MappedCondenserAdapter([object]$Conductor) {
        $this.Conductor = $Conductor
        $this.GlobalCondenser = [GlobalCondenser]::new($this, $Conductor)
        $this.MergeCondenser = [MergeCondenser]::new($this, $Conductor)
        $this.TokenCondenser = [TokenCondenser]::new($this, $Conductor)
        $this.MapCondenser = [MapCondenser]::new($this, $Conductor)
        $this.GraphCondenser = [GraphCondenser]::new($this)
        $this.FormulaGraphCondenser = [FormulaGraphCondenser]::new($this)
    }

    [object] Invoke([string]$Slot, [object]$Proposal, [object]$CancellationToken = $null) {
        $condenser = switch ($Slot) {
            "GlobalCondenser" { $this.GlobalCondenser }
            "MergeCondenser" { $this.MergeCondenser }
            "TokenCondenser" { $this.TokenCondenser }
            "MapCondenser" { $this.MapCondenser }
            "GraphCondenser" { $this.GraphCondenser }
            "FormulaGraphCondenser" { $this.FormulaGraphCondenser }
            default { $this.GraphCondenser }
        }

        if ($condenser -eq $null) {
            $signal = [Signal]::Start($null) | Select-Object -Last 1
            $signal.LogCritical("No condenser service found for Slot: $Slot")
            return $signal
        }

        return $condenser.Invoke($Slot, $Proposal, $CancellationToken)
    }

    # Optional Placeholder for future slot references
    static [hashtable] GetSlots() {
        return @{
            MapCondenser = "MapCondenser"
            MergeCondenser = "MergeCondenser"
            GraphCondenser = "GraphCondenser"
            MiniGraphCondenser = "MiniGraphCondenser"
            GlobalCondenser = "GlobalCondenser"
        }
    }
}
