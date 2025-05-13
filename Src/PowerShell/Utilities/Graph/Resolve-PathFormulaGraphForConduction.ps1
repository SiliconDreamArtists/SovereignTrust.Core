function Resolve-PathFormulaGraphForConduction {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Signal]$ConductionSignal
    )

    $opSignal = [Signal]::Start("Resolve-PathFormulaGraphForConduction", $ConductionSignal) | Select-Object -Last 1
    $opSignal.LogVerbose("📦 Resolving formula graph for Conduction memory layout.")

    # ░▒▓█ UNWRAP CONDUCTION OBJECT █▓▒░
    $conduction = $ConductionSignal.GetResult()
    if ($null -eq $conduction) {
        $opSignal.LogCritical("❌ ConductionSignal does not contain a valid result object.")
        return $opSignal
    }

    # ░▒▓█ START GRAPH █▓▒░
    $graphSignal = [Graph]::Start("GSG:ConductionGraph", $opSignal, $true) | Select-Object -Last 1
    $graph = $graphSignal.Pointer
    $opSignal.MergeSignal($graphSignal) | Out-Null

    # ░▒▓█ REGISTER STANDARD SIGNAL NODES █▓▒░
    $signalMap = @{}

    $parts = @(
        @{ Name = "Environment"; Value = $conduction.Jacket },
        @{ Name = "Conductor";   Value = $conduction.Conductor },
        @{ Name = "Conduit";     Value = $conduction.Conduit },
        @{ Name = "Context";     Value = $conduction.Context },
        @{ Name = "Graph";       Value = $conduction.Graph }
    )

    foreach ($part in $parts) {
        $name = "Conduction:$($part.Name)"
        $val = $part.Value
        if ($null -ne $val) {
            $sig = [Signal]::Start($name, $opSignal, $null, $val) | Select-Object -Last 1
            $graph.RegisterSignal($name, $sig) | Out-Null
            $signalMap[$part.Name] = $sig
        } else {
            $opSignal.LogWarning("⚠️ Missing part '$($part.Name)' in conduction object.")
        }
    }

    # ░▒▓█ FINALIZE GRAPH AND RETURN █▓▒░
    $graph.Finalize()
    $opSignal.SetResult($graph)
    $opSignal.LogInformation("✅ Conduction memory graph resolved and finalized.")
    return $opSignal
}
<#
[Signal] $opSignal
│
├── .Name = "Resolve-PathFormulaGraphForConduction"
├── .ReversePointer = $ConductionSignal
├── .Result = $graph (Graph)
│   ├── .SignalGrid = @{
│   │     "Conduction:Environment" = [Signal]
│   │     │   ├── .Name = "Conduction:Environment"
│   │     │   ├── .Jacket = $conduction.Jacket (environment object)
│   │     │   └── .Pointer = $null
│   │     │
│   │     "Conduction:Conductor" = [Signal]
│   │     │   ├── .Name = "Conduction:Conductor"
│   │     │   ├── .Jacket = $conduction.Conductor
│   │     │   └── .Pointer = $null
│   │     │
│   │     "Conduction:Conduit" = [Signal]
│   │     │   ├── .Name = "Conduction:Conduit"
│   │     │   ├── .Jacket = $conduction.Conduit
│   │     │   └── .Pointer = $null
│   │     │
│   │     "Conduction:Context" = [Signal]
│   │     │   ├── .Name = "Conduction:Context"
│   │     │   ├── .Jacket = $conduction.Context
│   │     │   └── .Pointer = $null
│   │     │
│   │     "Conduction:Graph" = [Signal]
│   │         ├── .Name = "Conduction:Graph"
│   │         ├── .Jacket = $conduction.Graph
│   │         └── .Pointer = $null
│   └── .Finalized = $true
├── .Entries = [SignalEntry[]]
 
Description
$opSignal contains the Graph as its .Result, built from the flat parts of the Conduction object.
Each Conduction:<Part> is a Signal that wraps the respective value and is inserted into the .SignalGrid of the Graph.
All .Pointer values are left null for now — they can be set later via phase routing or Condensers.
#>