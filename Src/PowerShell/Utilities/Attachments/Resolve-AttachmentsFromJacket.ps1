function Resolve-AttachmentFromJacket {
    param (
        [Parameter(Mandatory)]
        [object]$ConductionContext,

        [Parameter(Mandatory)]
        [object]$Jacket
    )

    $signal = [Signal]::new("ResolveAttachment:$($Jacket.Name)")

    try {
        # ░▒▓█ RESOLVE VIRTUAL PATH █▓▒░
        $virtualPathSignal = Resolve-PathFromDictionary -Dictionary $Jacket -Path "VirtualPath" | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($virtualPathSignal)) {
            $signal.LogCritical("❌ Jacket is missing a valid VirtualPath.")
            return $signal
        }

        $wirePath = $virtualPathSignal.GetResult()

        # ░▒▓█ LOAD MODULE MANIFEST GRAPH █▓▒░
        $manifestSignal = Resolve-DependencyModuleFromGraph -ConductionContext $ConductionContext -WirePath $wirePath | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($manifestSignal)) {
            $signal.LogCritical("❌ Failed to load manifest from WirePath: $wirePath")
            return $signal
        }

        $manifest = $manifestSignal.GetResult()

        # ░▒▓█ RESOLVE CLASS TYPE FROM MANIFEST █▓▒░
        $typeSignal = Resolve-PathFromDictionary -Dictionary $manifest -Path "Classes.0.Name" | Select-Object -Last 1
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

        # ░▒▓█ CONSTRUCT METHOD (OPTIONAL) █▓▒░
        if ($instance -and ($instance | Get-Member -Name "Construct" -MemberType Method)) {
            $constructCall = $instance.Construct($Jacket)
            $constructSignal = $constructCall | Select-Object -Last 1

            if ($signal.MergeSignalAndVerifySuccess($constructSignal)) {
                $signal.LogInformation("✅ Attachment '$($Jacket.Name)' constructed successfully.")
            } else {
                $signal.LogWarning("⚠️ Construct() failed on attachment '$($Jacket.Name)'.")
            }
        } else {
            $signal.LogVerbose("No Construct() method found for '$($Jacket.Name)'. Proceeding without initialization.")
        }

        # ░▒▓█ RESULT █▓▒░
        $signal.SetResult($instance)
        $signal.LogInformation("📦 Attachment '$($Jacket.Name)' resolved and returned successfully.")
    }
    catch {
        $signal.LogCritical("🔥 Unhandled exception during attachment resolution: $($_.Exception.Message)")
    }

    return $signal
}
