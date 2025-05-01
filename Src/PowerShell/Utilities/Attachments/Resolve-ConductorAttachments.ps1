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
            $signal.LogCritical("AttachmentJacketList not found on the conductor.")
            return $signal
        }

        $jacketList = $jacketListSignal.GetResult()

        # ░▒▓█ ATTACHMENT JACKET RESOLUTION █▓▒░
        foreach ($jacket in $jacketList) {
            if ($null -ne $jacket) {

                $nameSignal = Resolve-PathFromDictionary -Dictionary $jacket -Path "Name" | Select-Object -Last 1
                $typeSignal = Resolve-PathFromDictionary -Dictionary $jacket -Path "Type" | Select-Object -Last 1
                $signal.MergeSignal(@($nameSignal, $typeSignal))

                if ($nameSignal.Success() -and $typeSignal.Success()) {
                    $name = $nameSignal.GetResult()
                    $resolveSignal = Resolve-AttachmentFromJacket -Jacket $jacket | Select-Object -Last 1

                    if ($signal.MergeSignalAndVerifySuccess($resolveSignal)) {
                        $resolvedAttachment = $resolveSignal.GetResult()
                        #$addSignal = Add-PathToDictionary -Dictionary $Conductor -Path "Attachments.$name" -Value $resolvedAttachment | Select-Object -Last 1

                        $addSignal = Register-AttachmentToMappedSlot -Conductor $Conductor -Attachment $resolvedAttachment | Select-Object -Last 1
                        
                        if ($signal.MergeSignalAndVerifySuccess($addSignal)) {
                            $signal.LogInformation("Attachment '$name' resolved and mounted.")
                        } else {
                            $signal.LogWarning("Failed to mount resolved attachment '$name' into Conductor memory.")
                        }
                    } else {
                        $signal.LogWarning("Attachment '$name' failed during resolution phase.")
                    }
                } else {
                    $signal.LogWarning("Skipped unresolved jacket (Name or Type missing).")
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
