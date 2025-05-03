function Resolve-ConductorAttachments {
    param (
        [Parameter(Mandatory)]
        [object]$Conductor
    )

    $signal = [Signal]::new("ResolveConductorAttachments")

    try {
        # ░▒▓█ MEMORY PREPARATION █▓▒░
        $attachmentDictSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "Attachments" | Select-Object -Last 1
        $jacketListSignal     = Resolve-PathFromDictionary -Dictionary $Conductor -Path "AttachmentJackets" | Select-Object -Last 1

        $signal.MergeSignal(@($attachmentDictSignal, $jacketListSignal))

        if ($attachmentDictSignal.Failure()) {
            Add-PathToDictionary -Dictionary $Conductor -Path "Attachments" -Value @{} | Out-Null
            $signal.LogRecovery("Initialized missing AttachmentDictionary on Conductor.")
        }

        if ($jacketListSignal.Failure()) {
            $signal.LogCritical("AttachmentJackets  not found on the conductor.")
            return $signal
        }

        $jacketList = $jacketListSignal.GetResult()

        # ░▒▓█ ATTACHMENT JACKET RESOLUTION █▓▒░
        foreach ($jacket in $jacketList) {
            if ($null -ne $jacket) {

                $nameSignal = Resolve-PathFromDictionary -Dictionary $jacket -Path "Name" | Select-Object -Last 1

                if ($signal.MergeSignalAndVerifySuccess($nameSignal)) {
                    $name = $nameSignal.GetResult()
                
                    $resolveSignal = Resolve-AttachmentFromJacket -ConductionContext $Conductor -Jacket $jacket | Select-Object -Last 1
                
                    if ($signal.MergeSignalAndVerifySuccess($resolveSignal)) {
                        $resolvedAttachment = $resolveSignal.GetResult()
                        $resolvedType = $resolvedAttachment.GetType().Name
                        $signal.LogVerbose("Attachment '$name' resolved as type '$resolvedType'.")
                
                        $mergeCondenserSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "MappedAttachments.Condenser.MergeCondenser" | Select-Object -Last 1
                        $addSignal = Register-AttachmentToMappedSlot -Conductor $Conductor -Attachment $resolveSignal | Select-Object -Last 1
                
                        if ($signal.MergeSignalAndVerifySuccess($addSignal)) {
                            $signal.LogInformation("Attachment '$name' mounted successfully.")
                        } else {
                            $signal.LogWarning("Failed to mount '$name' into Conductor memory.")
                        }
                    } else {
                        $signal.LogWarning("Attachment '$name' failed resolution.")
                    }
                } else {
                    $signal.LogWarning("Skipped jacket — 'Name' field unresolved.")
                }
                
            } else {
                $signal.LogWarning("Null jacket encountered during iteration — skipping.")
            }
        }

        $signal.LogInformation("All conductor attachments processed.")
    }
    catch {
        $signal.LogCritical("Unhandled critical failure in Resolve-ConductorAttachments: $($_.Exception.Message)")
    }

    return $signal
}
