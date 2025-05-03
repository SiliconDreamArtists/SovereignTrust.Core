function Resolve-AdapterFromJacket {
    param (
        [Parameter(Mandatory)]
        [object]$ConductionContext,

        [Parameter(Mandatory)]
        [object]$Jacket
    )

    $signal = [Signal]::new("ResolveAdapter:$($Jacket.Name)")

    try {
        # ░▒▓█ RESOLVE VIRTUAL PATH █▓▒░
        $virtualPathSignal = Resolve-PathFromDictionary -Dictionary $Jacket -Path "VirtualPath" | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($virtualPathSignal)) {
            $signal.LogCritical("❌ Jacket is missing a valid VirtualPath.")
            return $signal
        }

        $wirePath = $virtualPathSignal.GetResult()

        # ░▒▓█ LOAD MODULE MANIFEST GRAPH █▓▒░
        $moduleGraphSignal = Resolve-DependencyModuleFromGraph -ConductionContext $ConductionContext -WirePath $wirePath | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($moduleGraphSignal)) {
            $signal.LogCritical("❌ Failed to load manifest from WirePath: $wirePath")
            return $signal
        }

        # ░▒▓█ RESOLVE CLASS TYPE FROM MANIFEST █▓▒░
        $typeSignal = Resolve-PathFromDictionary -Dictionary $moduleGraphSignal -Path "Manifest.FullType" | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($typeSignal)) {
            $signal.LogCritical("❌ Class name missing in manifest.")
            return $signal
        }

        $typeName = $typeSignal.GetResult()

        # ░▒▓█ INSTANCE CREATION █▓▒░
        try {
            $instance = New-Object -TypeName $typeName -ErrorAction Stop
        }
        catch {
            $signal.LogCritical("❌ Failed to instantiate type '$typeName': $_")
            return $signal
        }

        # ░▒▓█ MERGE $JACKET OVER $MANIFEST █▓▒░
        $manifestSignal = Resolve-PathFromDictionary -Dictionary $moduleGraphSignal -Path "Manifest" | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($manifestSignal)) {
            $signal.LogCritical("❌ Failed to extract Manifest dictionary from Graph.")
            return $signal
        }

        $mergeServiceSignal = Resolve-PathFromDictionary -Dictionary $ConductionContext -Path "MappedAdapters.Condenser.AdapterGraph.MergeCondenser" | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($mergeServiceSignal)) {
            $signal.LogCritical("❌ MergeCondenser not available on ConductionContext.")
            return $signal
        }

        $mergeService = $mergeServiceSignal.GetResult()
        $mergedSignal = $mergeService.InvokeByParameter($manifestSignal.GetResult(), $Jacket, $true) | Select-Object -Last 1

        if ($signal.MergeSignalAndVerifyFailure($mergedSignal)) {
            $signal.LogWarning("⚠️ Jacket-to-Manifest merge failed; continuing with original jacket.")
        } else {
            $Jacket = $mergedSignal.GetResult()
            $signal.LogInformation("🧬 Jacket successfully merged over Manifest.")
        }

        # ░▒▓█ CONSTRUCT METHOD (OPTIONAL) █▓▒░
        if ($instance -and ($instance | Get-Member -Name "Construct" -MemberType Method)) {
            $constructCall = $instance.Construct($Jacket)
            $constructSignal = $constructCall | Select-Object -Last 1

            if ($signal.MergeSignalAndVerifySuccess($constructSignal)) {
                $signal.LogInformation("✅ Adapter '$($Jacket.Name)' ($($Jacket.VirtualPath)) constructed successfully.")
            } else {
                $signal.LogWarning("⚠️ Construct() failed on adapter '$($Jacket.Name)'.")
            }
        } else {
            $signal.LogVerbose("No Construct() method found for '$($Jacket.Name)'. ($($Jacket.VirtualPath)) Proceeding without initialization.")
        }

        # ░▒▓█ RESULT █▓▒░
        $signal.SetResult($instance)
        $signal.LogInformation("📦 Adapter '$($Jacket.Name)' resolved and returned successfully.")
    }
    catch {
        $signal.LogCritical("🔥 Unhandled exception during adapter resolution: $($_.Exception.Message)")
    }

    return $signal
}
