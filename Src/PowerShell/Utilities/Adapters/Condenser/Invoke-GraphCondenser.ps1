function Invoke-GraphCondenser {
    param (
        [Parameter(Mandatory)][object]$Conduction,
        [Parameter(Mandatory)][Graph]$Graph,
        [string]$WirePath = $null
    )

    $signal = [Signal]::Start("Invoke-GraphCondenser")

    # ░▒▓█ RESOLVE TARGET GRAPH REGION █▓▒░
    $GraphTarget = $Graph
    if ($WirePath) {
        $graphSignal = Resolve-PathFromDictionary -Dictionary $Graph -Path $WirePath | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($graphSignal)) {
            $signal.LogCritical("❌ Failed to resolve target path from WirePath: $WirePath")
            return $signal
        }
        $GraphTarget = $graphSignal.GetResult()
    }

    # ░▒▓█ VALIDATE GRAPH TARGET █▓▒░
    if (-not ($GraphTarget -is [Graph])) {
        $signal.LogCritical("❌ Target resolved from WirePath is not a Graph.")
        return $signal
    }

    # ░▒▓█ TRAVERSE SIGNAL GRID █▓▒░
    foreach ($entry in $GraphTarget.Grid.GetEnumerator()) {
        $name = $entry.Key
        $nodeSignal = $entry.Value

        # ░▒▓█ TOKEN PASS █▓▒░
        $tokenSignal = Invoke-TokenCondenser -Conduction $Conduction -Signal $nodeSignal | Select-Object -Last 1
        $signal.MergeSignal($tokenSignal)

        # ░▒▓█ HYDRATION PASS █▓▒░
        $hydrationSignal = Invoke-HydrationIntentCondenser -Conduction $Conduction -Signal $nodeSignal | Select-Object -Last 1
        $signal.MergeSignal($hydrationSignal)
    }

    $signal.LogInformation("🌐 GraphCondenser completed across signal grid.")
    return $signal
}
