function Resolve-ConductorAttachments {
    param (
        [Parameter(Mandatory)]
        [object]$Conductor
    )

    $signal = [Signal]::new("ResolveConductorAttachments")

    try {
        # Resolve sovereign paths
        $attachmentDictionary = Resolve-PathFromDictionary -Dictionary $Conductor -Path "Memory.Attachments"
        $attachmentJacketList = Resolve-PathFromDictionary -Dictionary $Conductor -Path "Memory.AttachmentJackets"

        if ($null -eq $attachmentDictionary) {
            Add-PathToDictionary -Dictionary $Conductor -Path "Memory.Attachments" -Value @{}
            $attachmentDictionary = Resolve-PathFromDictionary -Dictionary $Conductor -Path "Memory.Attachments"
            $signal.LogVerbose("Initialized missing AttachmentDictionary on Conductor.")
        }

        if ($null -eq $attachmentJacketList) {
            $signal.LogCritical("AttachmentJacketList not found in conductor memory.")
            return $signal
        }

        foreach ($jacket in $attachmentJacketList) {
            if ($null -ne $jacket) {
                $name = Resolve-PathFromDictionary -Dictionary $jacket -Path "Name"
                $type = Resolve-PathFromDictionary -Dictionary $jacket -Path "Type"

                if ($name -and $type) {
                    $subSignal = Resolve-AttachmentFromJacket -Jacket $jacket

                    if ($signal.MergeSignalAndVerifySuccess(@($subSignal))) {
                        if ($subSignal.Result) {
                            Add-PathToDictionary -Dictionary $Conductor -Path "Memory.Attachments.$name" -Value $subSignal.Result
                            $signal.LogInformation("Attachment '$name' resolved and added to conductor memory.")
                        } else {
                            $signal.LogWarning("Attachment '$name' resolved but produced no service instance.")
                        }
                    } else {
                        $signal.LogWarning("Failed to resolve attachment '$name'.")
                    }
                } else {
                    $signal.LogWarning("Skipped jacket missing Name or Type during resolution.")
                }
            } else {
                $signal.LogWarning("Null jacket encountered during conductor attachment resolution.")
            }
        }
    }
    catch {
        $signal.LogCritical("Unhandled critical failure in Resolve-ConductorAttachments: $($_.Exception.Message)")
    }

    return $signal
}
