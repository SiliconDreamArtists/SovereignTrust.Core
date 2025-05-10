function Resolve-ConductorAdapters {
    param (
        [Parameter(Mandatory)]
        [object]$Conductor
    )

    $signal = [Signal]::Start("ResolveConductorAdapters")

    try {
        # ░▒▓█ MEMORY PREPARATION █▓▒░
        $adapterDictSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "Adapters" | Select-Object -Last 1
        $jacketListSignal     = Resolve-PathFromDictionary -Dictionary $Conductor -Path "AdapterJackets" | Select-Object -Last 1

        $signal.MergeSignal(@($adapterDictSignal, $jacketListSignal))

        if ($adapterDictSignal.Failure()) {
            Add-PathToDictionary -Dictionary $Conductor -Path "Adapters" -Value @{} | Out-Null
            $signal.LogRecovery("Initialized missing AdapterDictionary on Conductor.")
        }

        if ($jacketListSignal.Failure()) {
            $signal.LogCritical("AdapterJackets  not found on the conductor.")
            return $signal
        }

        $jacketList = $jacketListSignal.GetResult()

        # ░▒▓█ ATTACHMENT JACKET RESOLUTION █▓▒░
        foreach ($jacket in $jacketList) {
            if ($null -ne $jacket) {

                $nameSignal = Resolve-PathFromDictionary -Dictionary $jacket -Path "Name" | Select-Object -Last 1

                if ($signal.MergeSignalAndVerifySuccess($nameSignal)) {
                    $name = $nameSignal.GetResult()
                
                    $resolveSignal = Resolve-AdapterFromJacket -ConductionContext $Conductor -Jacket $jacket | Select-Object -Last 1
                
                    if ($signal.MergeSignalAndVerifySuccess($resolveSignal)) {
                        $resolvedAdapter = $resolveSignal.GetResult()
                        $resolvedType = $resolvedAdapter.GetType().Name
                        $signal.LogVerbose("Adapter '$name' resolved as type '$resolvedType'.")
                
                        $addSignal = Register-AdapterToMappedSlot -Conductor $Conductor -Adapter $resolveSignal | Select-Object -Last 1
                
                        if ($signal.MergeSignalAndVerifySuccess($addSignal)) {
                            $signal.LogInformation("Adapter '$name' mounted successfully.")
                        } else {
                            $signal.LogWarning("Failed to mount '$name' into Conductor memory.")
                        }
                    } else {
                        $signal.LogWarning("Adapter '$name' failed resolution.")
                    }
                } else {
                    $signal.LogWarning("Skipped jacket — 'Name' field unresolved.")
                }
                
            } else {
                $signal.LogWarning("Null jacket encountered during iteration — skipping.")
            }
        }

        $signal.LogInformation("All conductor adapters processed.")
    }
    catch {
        $signal.LogCritical("Unhandled critical failure in Resolve-ConductorAdapters: $($_.Exception.Message)")
    }

    return $signal
}
