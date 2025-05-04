function Resolve-PathFormulaGraphForConduction {
    param (
        [Parameter(Mandatory)][string]$WirePath,
        [Parameter(Mandatory)][object]$Conductor
    )

    $signal = [Signal]::new("Resolve-PathFormulaGraphForConduction:$WirePath")
    $graph = [Graph]::new($Conductor.Environment)
    $graph.Start()

    try {
        # ░▒▓█ RESOLVE CONDUCTIONS ARRAY █▓▒░
        $conductionsSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path $WirePath
        if (-not ($signal.MergeAndVerifySuccess($conductionsSignal))) {
            return $signal
        }

        $conductions = $conductionsSignal.GetResult()
        if (-not $conductions -or $conductions.Count -eq 0) {
            $signal.LogCritical("❌ No conduction entries found at: $WirePath")
            return $signal
        }

        $index = 0
        foreach ($conduction in $conductions) {
            $vp = $conduction.VirtualPath
            $vpSegments = $vp -split '\.'
            if ($vpSegments.Count -lt 4) {
                $signal.LogWarning("⚠️ Skipping malformed VirtualPath: $vp")
                continue
            }

            $vpKind = $vpSegments[2]
            $vpType = $vpSegments[3]
            $stem = "$vpKind`_$vpType"
            $fileName = "$stem.psd1"
            $folderSegments = @("$($vpSegments[0]).$($vpSegments[1])", 'Src', $vpKind, $vpType, 'PowerShell')
            $relativeFolderPath = [System.IO.Path]::Combine($folderSegments)
            $relativeFilePath = Join-Path $relativeFolderPath $fileName

            $nodeSignal = [Signal]::new("Conduction:$($stem):$index")
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
            if (-not ($signal.MergeAndVerifySuccess($registrationSignal))) {
                return $signal
            }

            $index++
        }

        $graph.Finalize()
        $signal.SetResult($graph)
        $signal.LogInformation("✅ Graph populated with $index conduction(s) from: $WirePath")
    }
    catch {
        $signal.LogCritical("🔥 Exception during Resolve-PathFormulaGraphForConduction: $($_.Exception.Message)")
    }

    return $signal
}
