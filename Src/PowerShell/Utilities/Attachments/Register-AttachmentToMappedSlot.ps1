function Register-AttachmentToMappedSlot {
    param (
        [Parameter(Mandatory)]
        [Conductor]$Conductor,

        [Parameter(Mandatory)]
        [object]$Attachment
    )

    $signal = [Signal]::new("Register-AttachmentToMappedSlot")

    try {
        # ░▒▓█ RESOLVE KIND FROM JACKET █▓▒░
        $kindSignal = Resolve-PathFromDictionary -Dictionary $Attachment -Path "Jacket.Kind" | Select-Object -Last 1
        if (-not $signal.MergeSignalAndVerifySuccess($kindSignal)) {
            return $signal.LogCritical("❌ Attachment does not contain a resolvable 'Jacket.Kind' path.").Signal
        }

        $kind = $kindSignal.GetResult()
        if ([string]::IsNullOrWhiteSpace($kind)) {
            return $signal.LogCritical("❌ Attachment Jacket.Kind is empty or null.").Signal
        }

        # ░▒▓█ RESOLVE MAPPED ATTACHMENT CONTAINER █▓▒░
        $mappedPath = "MappedAttachments.$kind"
        $mappedSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path $mappedPath | Select-Object -Last 1
        if (-not $signal.MergeSignalAndVerifySuccess($mappedSignal)) {
            return $signal.LogCritical("❌ MappedAttachment path '$mappedPath' not found in Conductor.").Signal
        }

        $mappedAttachmentContainer = $mappedSignal.GetResult()
        if ($null -eq $mappedAttachmentContainer) {
            return $signal.LogCritical("❌ MappedAttachment container at '$mappedPath' is null.").Signal
        }

        # ░▒▓█ REGISTER ATTACHMENT █▓▒░
        $registerSignal = $mappedAttachmentContainer.RegisterAttachment($Attachment) | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifySuccess($registerSignal)) {
            $signal.LogInformation("✅ Attachment registered to MappedAttachment slot '$kind'.")
        } else {
            $signal.LogWarning("⚠️ Attachment registration returned warning or soft failure.")
        }

        # ░▒▓█ RESULT █▓▒░
        $signal.SetResult($mappedAttachmentContainer)
    }
    catch {
        $signal.LogCritical("🔥 Unhandled exception during MappedAttachment registration: $($_.Exception.Message)")
    }

    return $signal
}
