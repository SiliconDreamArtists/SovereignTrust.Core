function Invoke-TraceSignalTree {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][Signal]$Signal,
        [string]$TraceID = "",
        [string]$Prefix = "",
        [string]$KeyHint = "",
        [bool]$VisualizeFinal = $false
    )

    $opSignal = [Signal]::Start("TraceSignalTree", $Signal) | Select-Object -Last 1
    $opSignal.SetJacket($Signal)

    $diagramSignal = [Signal]::Start("SignalTree:Diagram", $Signal) | Select-Object -Last 1
    $diagramSignal.SetJacket($Signal)

    if (-not $TraceID) {
        $TraceID = $opSignal.Name
    }

    $branch = if ($Prefix -eq "") { "[Signal]" } else { "├──" }

    $lines = @()
    $lines += "$Prefix│   $branch .Name = `"$($Signal.Name)`"" + ($(if ($KeyHint) { " (key: $KeyHint)" } else { "" }))
    $lines += "$Prefix│   ├── .Jacket = " + ($(if ($null -ne $Signal.Jacket) { "`$Jacket" } else { "`$null" }))

    $resultLabel = "`$null"
    if ($Signal.Result -is [Signal]) {
        $resultLabel = "`$Result (Signal)"
    } elseif ($null -ne $Signal.Result) {
        $resolved = Resolve-PathFromDictionary -Dictionary $Signal.Result -Path "Signal" | Select-Object -Last 1
        if ($resolved.MergeSignalAndVerifySuccess(@())) {
            $resolvedResult = $resolved.GetResult()
            if ($resolvedResult -is [Signal]) {
                $resultLabel = "`$Result (Resolved→Signal:$($resolved.Name))"
            }
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
        if ($diagramSignal.MergeSignalAndVerifyFailure(@($emit))) { return $diagramSignal }
    }

    foreach ($child in @(
        @{ Label = "Result";        Value = $Signal.Result },
        @{ Label = "Pointer";       Value = $Signal.Pointer },
        @{ Label = "ReversePointer";Value = $Signal.ReversePointer }
    )) {
        if ($child.Value -is [Signal]) {
            $childSignal = Invoke-TraceSignalTree -Signal $child.Value -TraceID $TraceID -Prefix "$Prefix│   " | Select-Object -Last 1
            if ($diagramSignal.MergeSignalAndVerifyFailure(@($childSignal))) { return $diagramSignal }
        }
    }

    if ($null -ne $Signal.Grid) {
        foreach ($key in $Signal.Grid.Keys) {
            $child = $Signal.Grid[$key]
            if ($child -is [Signal]) {
                $gridSignal = Invoke-TraceSignalTree -Signal $child -TraceID $TraceID -Prefix "$Prefix│   │   " -KeyHint $key | Select-Object -Last 1
                if ($diagramSignal.MergeSignalAndVerifyFailure(@($gridSignal))) { return $diagramSignal }
            }
        }
    }

    $unwrapped = Resolve-PathFromDictionary -Dictionary $Signal -Path "@.$" | Select-Object -Last 1
    if ($unwrapped.MergeSignalAndVerifySuccess(@())) {
        $graphSignal = $unwrapped.GetResult() | Select-Object -Last 1
        $graphObject = $graphSignal.GetResult()
        if ($graphObject -is [Graph] -and $null -ne $graphObject.Grid) {
            foreach ($key in $graphObject.Grid.Keys) {
                $entry = $graphObject.Grid[$key]
                if ($entry -is [Signal]) {
                    $childTrace = Invoke-TraceSignalTree -Signal $entry -TraceID $TraceID -Prefix "$Prefix│   │   " -KeyHint $key | Select-Object -Last 1
                    if ($diagramSignal.MergeSignalAndVerifyFailure(@($childTrace))) { return $diagramSignal }
                }
            }
        }
    }

    $opSignal.SetResult($diagramSignal)
    if ($opSignal.MergeSignalAndVerifyFailure(@($diagramSignal))) {
        return $opSignal
    }

    if ($VisualizeFinal) {
        Invoke-VisualizeSignalTreeTrace -JacketSignal $opSignal -ResultSignal $diagramSignal | Out-Null
    }

    return $opSignal
}
