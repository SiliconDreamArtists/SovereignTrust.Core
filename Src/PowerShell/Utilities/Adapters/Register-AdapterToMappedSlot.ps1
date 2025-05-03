function Register-AdapterToMappedSlot {
    param (
        [Parameter(Mandatory)]
        [Conductor]$Conductor,

        [Parameter(Mandatory)]
        [object]$Adapter
    )

    $signal = [Signal]::new("Register-AdapterToMappedSlot")

    try {
        # ░▒▓█ UNWRAP SIGNAL IF NECESSARY █▓▒░
        $resolvedAdapter = if ($Adapter -is [Signal]) {
            $Adapter.GetResult()
        } else {
            $Adapter
        }

        # ░▒▓█ RESOLVE KIND FROM JACKET █▓▒░
        $kindSignal = Resolve-PathFromDictionary -Dictionary $resolvedAdapter -Path "Jacket.Kind" | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($kindSignal)) {
            return $signal.LogCritical("❌ Adapter does not contain a resolvable 'Jacket.Kind' path.")
        }

        $kind = $kindSignal.GetResult()
        if ([string]::IsNullOrWhiteSpace($kind)) {
            return $signal.LogCritical("❌ Adapter Jacket.Kind is empty or null.")
        }

        # ░▒▓█ RESOLVE MAPPED ATTACHMENT CONTAINER █▓▒░
        $mappedPath = "MappedAdapters.$kind"
        $mappedSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path $mappedPath | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($mappedSignal)) {
            return $signal.LogCritical("❌ MappedAdapter path '$mappedPath' not found in Conductor.")
        }

        $mappedAdapterContainer = $mappedSignal.GetResult()
        if ($null -eq $mappedAdapterContainer) {
            return $signal.LogCritical("❌ MappedAdapter container at '$mappedPath' is null.")
        }

        # ░▒▓█ REGISTER ATTACHMENT █▓▒░
        $registerSignal = $mappedAdapterContainer.RegisterAdapter($resolvedAdapter) | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifySuccess($registerSignal)) {
            $signal.LogInformation("✅ Adapter registered to MappedAdapter slot '$kind'.")
        } else {
            $signal.LogWarning("⚠️ Adapter registration returned warning or soft failure.")
        }

        # ░▒▓█ RESULT █▓▒░
        $signal.SetResult($mappedAdapterContainer)
    }
    catch {
        $signal.LogCritical("🔥 Unhandled exception during MappedAdapter registration: $($_.Exception.Message)")
    }

    # ░▒▓█ OPTIONAL: MERGE INTO CONDUCTOR CONTROL SIGNAL █▓▒░
    if ($Conductor -and $Conductor.ControlSignal) {
        $Conductor.ControlSignal.MergeSignal($signal)
    }

    return $signal
}
