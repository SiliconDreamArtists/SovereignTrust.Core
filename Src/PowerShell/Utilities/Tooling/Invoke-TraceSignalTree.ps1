<# This is used totrace a Signal Tree Trace and optionally visualize it.
It's usually used inside of utilities to perform traces and then use environment 
variables to determine if it should be visualized or not according to the circumstance.

Example:
Invoke-TraceSignalTree -Signal $SignalToTrace $VisualizeFinal $environmentVariablesForVisualizing
#>

function Invoke-TraceSignalTree {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][Signal]$Signal,
        [string]$TraceID = "",
        [string]$Prefix = "",
        [string]$KeyHint = "",
        [bool]$VisualizeFinal = $false
    )

    # ░▒▓█ WRAPPED SIGNAL █▓▒░
    $opSignal = [Signal]::Start("TraceSignalTree") | Select-Object -Last 1
    $opSignal.SetJacket($Signal)

    # ░▒▓█ FLAT DIAGRAM COLLECTOR █▓▒░
    $diagramSignal = [Signal]::Start("SignalTree:Diagram") | Select-Object -Last 1
    $diagramSignal.SetJacket($Signal)

    if (-not $TraceID) {
        $TraceID = $opSignal.Name
    }

    $labelPrefix = if ($KeyHint) { "[Key: $KeyHint] " } else { "" }
    $branch = if ($Prefix -eq "") { "[Signal]" } else { "├──" }

    # ░▒▓█ BUILD MAIN DIAGRAM BLOCK █▓▒░
    $lines = @()

    #v1
    # Optional key label if provided
    if ($KeyHint) {
        $lines += "$Prefix│   ├── [Key: $KeyHint]"
        $subPrefix = "$Prefix│   │   "
    } else {
        $subPrefix = "$Prefix│   "
    }

    $lines += "$subPrefix├── .Name = `"$($Signal.Name)`""
    $lines += "$subPrefix├── .Jacket = " + ($(if ($null -ne $Signal.Jacket) { "`$Jacket" } else { "`$null" }))

    #v2
    # ░▒▓█ BUILD MAIN DIAGRAM BLOCK █▓▒░
    $lines = @()
    $lines += "$Prefix│   ├── .Name = `"$($Signal.Name)`""
    $lines += "$Prefix│   ├── .Jacket = " + ($(if ($null -ne $Signal.Jacket) { "`$Jacket" } else { "`$null" }))
    
    $resultLabel = "`$null"
    if ($Signal.Result -is [Signal]) {
        $resultLabel = "`$Result (Signal)"
    } elseif ($null -ne $Signal.Result) {
        $resolved = Resolve-PathFromDictionary -Dictionary $Signal.Result -Path "Signal" | Select-Object -Last 1
        if ($resolved.Success() -and $resolved.GetResult() -is [Signal]) {
            $sourceName = $resolved.Name
            $resultLabel = "`$Result (Resolved→Signal:$sourceName)"
        } else {
            $resultLabel = "`$Result ($($Signal.Result.GetType().Name))"
        }
    }

    $lines += "$Prefix│   ├── .Result = $resultLabel"
    $lines += "$Prefix│   ├── .Pointer = " + ($(if ($null -ne $Signal.Pointer) { "`$Pointer" } else { "`$null" }))
    $lines += "$Prefix│   ├── .ReversePointer = " + ($(if ($null -ne $Signal.ReversePointer) { "`$ReversePointer" } else { "`$null" }))
    $lines += "$Prefix│   └── .Entries = [$($Signal.Entries.Count) entries]"

    foreach ($line in $lines) {
        $emit = Emit-SignalTreeLine -Target $diagramSignal -Line $line -TraceID $TraceID -TraceScope "Trace" | Select-Object -Last 1
        $diagramSignal.MergeSignal(@($emit))
    }

    # ░▒▓█ FLAT RECURSION INTO CHILD SIGNALS █▓▒░
    foreach ($child in @(
        @{ Label = "Result";        Value = $Signal.Result },
        @{ Label = "Pointer";       Value = $Signal.Pointer },
        @{ Label = "ReversePointer";Value = $Signal.ReversePointer }
    )) {
        if ($child.Value -is [Signal]) {
            $childSignal = Invoke-TraceSignalTree -Signal $child.Value -TraceID $TraceID -Prefix "$Prefix│   " | Select-Object -Last 1
            $diagramSignal.MergeSignal(@($childSignal))
        }
    }

    if ($null -ne $Signal.Grid) {
        foreach ($key in $Signal.Grid.Keys) {
            $child = $Signal.Grid[$key]
            if ($child -is [Signal]) {
                $gridSignal = Invoke-TraceSignalTree -Signal $child -TraceID $TraceID -Prefix "$Prefix│   │   " -KeyHint $key | Select-Object -Last 1
                $diagramSignal.MergeSignal(@($gridSignal))
            }
        }
    }

    if ($Signal.Result -is [MappedCondenserAdapter]) {
        $adapterGraph = $Signal.Result.AdapterGraph
        if ($adapterGraph -is [Graph] -and $null -ne $adapterGraph.Grid) {
            foreach ($key in $adapterGraph.Grid.Keys) {
                $nested = $adapterGraph.Grid[$key]
                if ($nested -is [Signal]) {
                    $nestedSignal = Invoke-TraceSignalTree -Signal $nested -TraceID $TraceID -Prefix "$Prefix│   │   " -KeyHint $key | Select-Object -Last 1
                    $diagramSignal.MergeSignal(@($nestedSignal))
                }
            }
        }
    }

    $opSignal.SetResult($diagramSignal)
    $opSignal.MergeSignal(@($diagramSignal))

    if ($VisualizeFinal) {
        Invoke-VisualizeSignalTreeTrace -JacketSignal $opSignal -ResultSignal $diagramSignal | Out-Null
    }

    return $opSignal
}
