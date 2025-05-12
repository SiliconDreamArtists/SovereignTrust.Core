function Invoke-VisualizeSignalTreeTrace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Signal]$JacketSignal,
        [Signal]$ResultSignal
    )

    $opSignal = [Signal]::Start("VisualizeSignalTreeTrace") | Select-Object -Last 1
    $opSignal.SetJacket($JacketSignal)

    if ($null -eq $ResultSignal) {
        $ResultSignal = Invoke-TraceSignalTree -Signal $JacketSignal | Select-Object -Last 1
    }

    $diagramSignal = [Signal]::Start("SignalTree:Diagram") | Select-Object -Last 1
    $diagramSignal.SetJacket($ResultSignal)


    $allDiagramLines = @()
    $entryQueue = [System.Collections.Generic.Queue[object]]::new()
    $entryQueue.Enqueue($ResultSignal)

    while ($entryQueue.Count -gt 0) {
        $current = $entryQueue.Dequeue()
        $entries = $current.GetEntries()

        $begin = Emit-SignalTreeBoundary -Target $diagramSignal -Direction "Begin" -TraceID $opSignal.Name -TraceScope "Replay" | Select-Object -Last 1
        foreach ($entry in $entries) {
            if ($entry -is [SignalEntry]) {
                if ($entry.Level -in @("Information", "ignoreVerbose") -and $entry.Message -like "SignalTree:*") {
                    $emitLine = Emit-SignalTreeLine -Target $diagramSignal -Line $entry.Message -Level $entry.Level -TraceID $ResultSignal.Name -TraceScope "Replay" -Minimal $true | Select-Object -Last 1
                    $allDiagramLines += $emitLine
                }
            }
        }

        $diagramSignal.MergeSignal(@($begin))
        $diagramSignal.MergeSignal($allDiagramLines)
    
        $end   = Emit-SignalTreeBoundary -Target $diagramSignal -Direction "End"   -TraceID $opSignal.Name -TraceScope "Replay" | Select-Object -Last 1
        $diagramSignal.MergeSignal(@($end))
    }


    $opSignal.SetResult($diagramSignal)
    return $opSignal
}
