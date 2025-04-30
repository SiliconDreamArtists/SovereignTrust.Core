class MappedCondenserService {
    [object]$GlobalCondenser
    [object]$MergeCondenser
    [object]$GraphCondenser
    [object]$Conductor

    MappedCondenserService([object]$Conductor) {
        $this.Conductor = $Conductor
        $this.GlobalCondenser = [GlobalCondenserService]::new($this, $Conductor)
        $this.MergeCondenser = [MergeCondenserService]::new($this, $Conductor)
        $this.MapCondenser = [MapCondenserService]::new($this, $Conductor)
        $this.GraphCondenser = [GraphCondenserService]::new($this)
    }

    [object] Invoke([string]$Slot, [object]$Proposal, [object]$CancellationToken = $null) {
        $condenserService = switch ($Slot) {
            "GlobalCondenser" { $this.GlobalCondenser }
            "MergeCondenser" { $this.MergeCondenser }
            default { $this.GraphCondenser }
        }

        if ($condenserService -eq $null) {
            $signal = [Signal]::Start($null)
            $signal.LogCritical("No condenser service found for Slot: $Slot")
            return $signal
        }

        return $condenserService.Invoke($Slot, $Proposal, $CancellationToken)
    }

    # Optional Placeholder for future slot references
    static [hashtable] GetSlots() {
        return @{
            MergeCondenser = "MergeCondenser"
            GraphCondenser = "GraphCondenser"
            MiniGraphCondenser = "MiniGraphCondenser"
            GlobalCondenser = "GlobalCondenser"
        }
    }
}
