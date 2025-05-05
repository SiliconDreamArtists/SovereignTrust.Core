function Resolve-DependencyModuleFromGraph {
    param (
        [Parameter(Mandatory = $true)]
        [object]$ConductionContext,

        [Parameter(Mandatory = $true)]
        [string]$WirePath
    )

    $signal = [Signal]::new("Resolve-DependencyModuleFromGraph:$WirePath")

    # ░▒▓█ RESOLVE PATH FORMULA GRAPH FOR MODULE █▓▒░
    $pathFormulaSignal = Resolve-PathFormulaGraph -WirePath $WirePath -StrategyType "Module" -Environment $ConductionContext.Environment | Select-Object -Last 1
    if (-not $signal.MergeSignalAndVerifySuccess($pathFormulaSignal)) {
        $signal.LogCritical("❌ Failed to resolve path formula graph for module wire path: $WirePath")
        return $signal
    }

    $formulaGraphSignal = Resolve-PathFromDictionary -Dictionary $pathFormulaSignal -Path "Graph" | Select-Object -Last 1
    $manifestSignal = Resolve-PathFromDictionary -Dictionary $formulaGraphSignal -Path "Manifest" | Select-Object -Last 1
    if (-not $signal.MergeSignalAndVerifySuccess($manifestSignal)) {
        $signal.LogCritical("❌ Manifest node not found in module formula graph.")
        return $signal
    }

    # ░▒▓█ MODULE CLASS RESOLUTION █▓▒░

    # 1. Resolve full type path from manifest
    $fullTypeSignal = Resolve-PathFromDictionary -Dictionary $manifestSignal -Path "FullType" | Select-Object -Last 1

    if ($signal.MergeSignalAndVerifyFailure($fullTypeSignal)) {
        $signal.LogCritical("❌ Failed to resolve FullType from manifest.")
        return $signal
    }

    # 2. Check if class is already loaded
    $className = $fullTypeSignal.GetResult()
    $isAlreadyLoadedSignal = Test-IsClassDefined -ClassName $className | Select-Object -Last 1

    if ($signal.MergeSignalAndVerifyFailure($isAlreadyLoadedSignal)) {
        $signal.LogCritical("❌ Class check failed for type: $className")
        return $signal
    }

    if ($isAlreadyLoadedSignal.GetResult()) {
        $signal.LogInformation("✅ Class '$className' already loaded; skipping import.")
        <#
        $graph = $formulaGraphSignal.GetResult()

        # ░▒▓█ REGISTER MODULE NODE █▓▒░
        $nodeSignal = [Signal]::new($fileStem)
        $nodeSignal.SetResult([ordered]@{
            Instance            = $project
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
        $graph.RegisterSignal("Module", $nodeSignal)
        #>
    }
    else {
        $manifest = $manifestSignal.GetResult()
        $moduleNameSignal = Resolve-PathFromDictionary -Dictionary $manifest -Path "Module.Name" | Select-Object -Last 1
        $moduleRelPathSignal = Resolve-PathFromDictionary -Dictionary $manifest -Path "RelativeFilePath" | Select-Object -Last 1
        $moduleRootPathSignal = Resolve-PathFromDictionary -Dictionary $ConductionContext -Path "Environment.DevModulePath" | Select-Object -Last 1

        if (-not $signal.MergeSignalAndVerifySuccess(@($moduleNameSignal, $moduleRelPathSignal, $moduleRootPathSignal))) {
            $signal.LogCritical("❌ Required module fields missing from manifest: Name, RelativePath, Entry.")
            return $signal
        }

        $modName = $moduleNameSignal.GetResult()
        $relPath = $moduleRelPathSignal.GetResult()
        $rootPath = $moduleRootPathSignal.GetResult()

        $fullModulePath = Join-Path (Join-Path $rootPath $relPath)

        # ░▒▓█ CHECK AND IMPORT MODULE █▓▒░
        $checkSignal = Test-ModuleLoaded -ModulesGraph $ConductionContext -ModuleName $modName | Select-Object -Last 1
        $signal.MergeSignal($checkSignal)

        if (-not $checkSignal.Success()) {
            try {
                Import-Module -Name $fullModulePath -ErrorAction Stop
                $regSignal = Register-ModuleLoaded -ModulesGraph $ConductionContext -ModuleName $modName -FullPath $fullModulePath -Version "1.0.0" | Select-Object -Last 1
                $signal.MergeSignal($regSignal)
                $signal.LogInformation("📦 Module '$modName' loaded successfully from '$fullModulePath'.")
            }
            catch {
                $signal.LogCritical("❌ Import failed for module '$modName': $($_.Exception.Message)")
                return $signal
            }
        }
        else {
            $signal.LogVerbose("✅ Module '$modName' already loaded.")
        }
    }


    $signal.SetResult($formulaGraphSignal)
    return $signal
}
