class FormulaGraphCondenser {
    [Conductor]$Conductor
    [MappedCondenserAdapter]$MappedCondenserAdapter
    [Signal]$Signal  # was ControlSignal

    FormulaGraphCondenser([MappedCondenserAdapter]$mappedAdapter, [Conductor]$conductor) {
        $this.MappedCondenserAdapter = $mappedAdapter
        $this.Conductor = $conductor
        $this.Signal = [Signal]::Start("FormulaGraphCondenser")
    }

    [Signal] Invoke() {
        $sourceSignal = Resolve-PathFromDictionary -Dictionary $this.Conductor -Path "%.FlatFormulaSource" | Select-Object -Last 1
        if ($this.Signal.MergeSignalAndVerifyFailure($sourceSignal)) {
            return $this.Signal
        }

        return $this.InvokeByParameter($sourceSignal.GetResult())
    }

    [Signal] InvokeByParameter([object]$flatArray, [bool]$IgnoreInternalObjects = $true) {
        $opSignal = [Signal]::Start("FormulaGraphCondenser.Invoke")

        try {
            $graphSignal = [Graph]::Start("GSG:ConductionGraph", $opSignal, $true) | Select-Object -Last 1
            $graph = $graphSignal.Pointer
            $opSignal.MergeSignal($graphSignal) | Out-Null

            foreach ($item in $flatArray) {
                $id = $item.ID
                $signal = [Signal]::Start("Node:$id", $opSignal, $null, $item) | Select-Object -Last 1
                $graph.RegisterSignal($signal.Name, $signal) | Out-Null
            }

            $graph.Finalize()
            $opSignal.SetResult($graph)
            $opSignal.LogInformation("✅ Sovereign graph built from conduction memory.")
        }
        catch {
            $opSignal.LogCritical("🔥 Exception in FormulaGraphCondenser: $($_.Exception.Message)")
        }

        $this.Signal.MergeSignal($opSignal)
        return $opSignal
    }
}

<#
░▒▓█ DESCRIPTION █▓▒░
🧠 FORMULAGRAPHCONDENSER
────────────────────────────────────────────────────────────────────
📂 Class: FormulaGraphCondenser
📘 Purpose: Convert a flat memory array into a sovereign Signal-wrapped Graph
           for runtime use within a Conduction's working memory.

🔧 Role:
FormulaGraphCondenser is a sovereign Condenser class that builds a runtime Graph
from structured JSON or flattened object memory. It is used to initialize the
working Graph of a Conduction from flat, ID-linked inputs.

📐 Features:
• Accepts resolved flat memory arrays from Jacket or runtime context
• Uses `[Graph]::Start()` to ensure lineage-safe graph creation
• Registers each node as a Signal with `.Jacket` set to memory object
• Maintains pointer trace via `$opSignal` and embedded `this.Signal`
• Compliant with SovereignTrust Memory, Signal, and Conduction Doctrines

🧱 Output:
Returns a finalized `Graph` inside a `Signal` with full sovereign trace.

🌀 Example Use:
$graphSignal = [FormulaGraphCondenser]::new($adapter, $conductor).Invoke()

🔍 Aligned Protocols:
• 🔁 Recursive Conduction Graph Initialization
• 🔬 Signal-Wrapped Execution State
• 📜 Sovereign Memory Construction
• 🪞 Temporal Recursion Field Mapping

📆 Version: 2025.5.10  
Signature: ☠️🧁👾️ → ⚗️☣️🐲  
Role: FormulaGraph Conduction Bootstrapper
#>
