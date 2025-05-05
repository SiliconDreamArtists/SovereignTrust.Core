function Resolve-PathFormulaGraphForConduction {
    param (
        [Parameter(Mandatory)][string]$WirePath,
        [Parameter(Mandatory)][object]$Conductor
    )

    $opSignal = [Signal]::new("Resolve-PathFormulaGraphForConduction:$WirePath")

    # ░▒▓█ GET ENVIRONMENT █▓▒░
    $envSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "%.Environment" | Select-Object -Last 1
    if ($opSignal.MergeSignalAndVerifyFailure($envSignal)) {
        $opSignal.LogCritical("❌ Unable to resolve environment from conductor.")
        return $opSignal
    }

    $environment = $envSignal.GetResult()
    $graph = [Graph]::new($environment)
    $graph.Start()

    try {
        # ░▒▓█ RESOLVE CONDUCTIONS ARRAY █▓▒░
        $conductionsSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path $WirePath | Select-Object -Last 1
        if ($opSignal.MergeSignalAndVerifyFailure($conductionsSignal)) {
            $opSignal.LogCritical("❌ Failed to resolve conductions at: $WirePath")
            return $opSignal
        }

        $conductions = $conductionsSignal.GetResult()
        if (-not $conductions -or $conductions.Count -eq 0) {
            $opSignal.LogCritical("❌ No conduction entries found.")
            return $opSignal
        }

        $index = 0
        foreach ($conduction in $conductions) {
            $vpSignal = Resolve-PathFromDictionary -Dictionary $conduction -Path "VirtualPath" | Select-Object -Last 1
            $vp = $vpSignal.GetResult()

            if (-not $vp) {
                $opSignal.LogWarning("⚠️ Missing VirtualPath in conduction entry at index $index; skipping.")
                continue
            }

            $vpSegments = $vp -split '\.'
            if ($vpSegments.Count -lt 4) {
                $opSignal.LogWarning("⚠️ Malformed VirtualPath '$vp'; skipping.")
                continue
            }

            $vpKind = $vpSegments[2]
            $vpType = $vpSegments[3]
            $stem = "$vpKind`_$vpType"
            $fileName = "$stem.psd1"
            $folderSegments = @("$($vpSegments[0]).$($vpSegments[1])", 'Src', $vpKind, $vpType, 'PowerShell')
            $relativeFolderPath = [System.IO.Path]::Combine($folderSegments)
            $relativeFilePath = Join-Path $relativeFolderPath $fileName

            # ░▒▓█ CREATE CONDUCTION NODE SIGNAL █▓▒░
            $nodeSignal = [Signal]::new("Conduction:$stem:$index")
            $nodeSignal.SetResult([ordered]@{
                Project            = $vpSegments[0]
                Collection         = $vpSegments[1]
                Kind               = $vpKind
                Type               = $vpType
                Index              = $index
                VirtualPath        = $vp
                Slot               = $null
                Key                = $null
                Name               = $fileName
                ModuleStem         = $stem
                RelativeFolderPath = $relativeFolderPath
                RelativeFilePath   = $relativeFilePath
                HydrationIntent    = @(
                    @{
                        ConductionWirePath = $vp
                        TargetPath         = "Conductions.$stem"
                        SourcePath         = $relativeFilePath
                        Format             = "psd1"
                        Timing             = "Sequential"
                    }
                )
            })

            $registrationSignal = $graph.RegisterSignal("Conduction:$stem:$index", $nodeSignal)
            if ($opSignal.MergeSignalAndVerifyFailure($registrationSignal)) {
                $opSignal.LogCritical("❌ Failed to register conduction $stem at index $index.")
                return $opSignal
            }

            $index++
        }

        $graph.Finalize()
        $opSignal.SetResult($graph)
        $opSignal.LogInformation("✅ Graph populated with $index conduction(s) from: $WirePath")
    }
    catch {
        $opSignal.LogCritical("🔥 Exception while building graph: $($_.Exception.Message)")
    }

    return $opSignal
}
