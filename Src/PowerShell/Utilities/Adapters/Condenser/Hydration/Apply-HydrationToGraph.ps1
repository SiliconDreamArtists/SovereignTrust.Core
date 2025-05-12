function Apply-HydrationToGraph {
    param (
        [Parameter(Mandatory)][Graph]$Graph,
        [Parameter(Mandatory)]$ParsedObject,
        [Parameter(Mandatory)][string]$TargetPath,
        [Parameter()][string]$Mode = "Replace"
    )
    $signal = [Signal]::Start("Apply-HydrationToGraph") | Select-Object -Last 1
    try {
        if ($Mode -eq "Replace") {
            $writeSignal = Add-PathToDictionary -Dictionary $Graph -Path $TargetPath -Value $ParsedObject | Select-Object -Last 1
            return $signal.MergeSignal($writeSignal)
        } elseif ($Mode -eq "Overlay") {
            $existingSignal = Resolve-PathFromDictionary -Dictionary $Graph -Path $TargetPath | Select-Object -Last 1
            $existing = if ($existingSignal.Success()) { $existingSignal.GetResult() } else { @{} }
            $merged = $existing + $ParsedObject
            $writeSignal = Add-PathToDictionary -Dictionary $Graph -Path $TargetPath -Value $merged | Select-Object -Last 1
            return $signal.MergeSignal($writeSignal)
        } else {
            return $signal.LogCritical("❌ Unsupported mode: $Mode")
        }
    } catch {
        $signal.LogCritical("🔥 Failed to write hydration output: $($_.Exception.Message)")
    }
    return $signal
}