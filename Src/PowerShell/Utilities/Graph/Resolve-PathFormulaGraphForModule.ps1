function Resolve-PathFormulaGraphForModule {
    param (
        [Parameter(Mandatory)][string]$WirePath,
        [Parameter()][object]$Environment
    )

    $signal = [Signal]::new("Resolve-PathFormulaGraphForModule:$WirePath")
    $graph = [Graph]::new($Environment)
    $graph.Start()

    try {
        # ░▒▓█ DECOMPOSE WIREPATH █▓▒░
        $segments = $WirePath -split '\.'
        if ($segments.Count -lt 4) {
            $signal.LogCritical("❌ WirePath must contain at least Project.Collection.Kind.Type (e.g., Org.Project.Domain.Component)")
            return $signal
        }

        # ░▒▓█ EXTRACT PRIMARY SEGMENTS █▓▒░
        $project     = $segments[0]
        $collection  = $segments[1]
        $kind        = $segments[2]
        $type        = $segments[3]
        $slot        = if ($segments.Count -ge 5) { $segments[4] } else { $null }
        $key         = if ($segments.Count -ge 6) { $segments[5] } else { $null }

        # ░▒▓█ DERIVE FILE NAME █▓▒░
        $fileStem = "$kind`_$type"
        $fileName = "$fileStem.psd1"

        # ░▒▓█ CONSTRUCT RELATIVE PATH █▓▒░
        $folderSegments = @("$project.$collection", 'Src') + @($kind, $type, 'PowerShell')
        $folderSegments = @("$project.$collection", 'Src', $kind, $type, 'PowerShell')
        $relativeFolderPath = [System.IO.Path]::Combine($folderSegments)
        $relativeFilePath   = Join-Path $relativeFolderPath $fileName

        # ░▒▓█ REGISTER MODULE NODE █▓▒░
        $nodeSignal = [Signal]::new($fileStem)
        $nodeSignal.SetResult([ordered]@{
            Project            = $project
            Collection         = $collection
            Kind               = $kind
            Type               = $type
            Slot               = $slot
            Key                = $key
            WirePath           = $WirePath
            FullType           = $fileStem
            Name               = $fileName
            RelativeFolderPath = $relativeFolderPath
            RelativeFilePath   = $relativeFilePath
            HydrationIntent    = @(
                @{
                    ConductionWirePath = "XYZ.Placeholder"
                    TargetPath          = "Modules.$fileStem"
                    SourcePath          = $relativeFilePath
                    Format              = "json"
                    Timing              = "Sequential"
                }
            )
        })
                
        $graph.RegisterSignal("Manifest", $nodeSignal)
        $graph.Finalize()

        $signal.SetResult($graph)
        $signal.LogInformation("✅ Module path graph constructed from WirePath: $WirePath")
    }
    catch {
        $signal.LogCritical("🔥 Unhandled exception during module graph resolution: $($_.Exception.Message)")
    }

    return $signal
}
