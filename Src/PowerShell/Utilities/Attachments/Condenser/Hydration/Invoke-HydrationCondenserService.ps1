function Invoke-HydrationCondenserService {
    param (
        [Parameter(Mandatory)][Graph]$Graph,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Intent
    )
    $signal = [Signal]::new("Invoke-HydrationCondenserService")
    foreach ($entry in $Intent) {
        if ($null -eq $entry -or -not ($entry -is [hashtable])) {
            $signal.LogWarning("⚠️ Invalid or null hydration entry — skipping.")
            continue
        }
        try {
            $kind  = $entry.Kind  ?? "Storage"
            $slot  = $entry.Slot  ?? "PrimaryContent"
            $format = $entry.Format ?? "json"
            $mode   = $entry.Mode   ?? "Replace"
            $targetPath = $entry.TargetPath ?? "Memory.$($slot)"
            $pathSignal = Resolve-HydrationSourcePath -Graph $Graph -Intent $entry -Kind $kind -Slot $slot | Select-Object -Last 1
            if ($signal.MergeSignalAndVerifyFailure($pathSignal)) {
                $signal.LogCritical("❌ Failed to resolve path for: $($entry.RelativePath)")
                continue
            }
            $fullPath = $pathSignal.GetResult()
            $readSignal = Read-HydrationFile -Path $fullPath -Format $format | Select-Object -Last 1
            if ($signal.MergeSignalAndVerifyFailure($readSignal)) {
                $signal.LogCritical("❌ Failed to read: $($entry.RelativePath)")
                continue
            }
            $parsed = $readSignal.GetResult()
            $writeSignal = Apply-HydrationToGraph -Graph $Graph -ParsedObject $parsed -TargetPath $targetPath -Mode $mode | Select-Object -Last 1
            $signal.MergeSignal($writeSignal)
            if ($writeSignal.Success()) {
                $signal.LogInformation("📥 Hydrated '$($entry.RelativePath)' → '$targetPath'")
            } else {
                $signal.LogWarning("⚠️ Write failed for '$targetPath'")
            }
        } catch {
            $signal.LogCritical("🔥 Exception during hydration pass: $($_.Exception.Message)")
        }
    }
    return $signal
}