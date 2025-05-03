function Register-AttachmentToMappedSlot {
    param (
        [Parameter(Mandatory)]
        [Conductor]$Conductor,

        [Parameter(Mandatory)]
        [object]$Attachment
    )

    $signal = [Signal]::new("Register-AttachmentToMappedSlot")

    try {
        # ░▒▓█ UNWRAP SIGNAL IF NECESSARY █▓▒░
        $resolvedAttachment = if ($Attachment -is [Signal]) {
            $Attachment.GetResult()
        } else {
            $Attachment
        }

        # ░▒▓█ RESOLVE KIND FROM JACKET █▓▒░
        $kindSignal = Resolve-PathFromDictionary -Dictionary $resolvedAttachment -Path "Jacket.Kind" | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($kindSignal)) {
            return $signal.LogCritical("❌ Attachment does not contain a resolvable 'Jacket.Kind' path.")
        }

        $kind = $kindSignal.GetResult()
        if ([string]::IsNullOrWhiteSpace($kind)) {
            return $signal.LogCritical("❌ Attachment Jacket.Kind is empty or null.")
        }

        # ░▒▓█ RESOLVE MAPPED ATTACHMENT CONTAINER █▓▒░
        $mappedPath = "MappedAttachments.$kind"
        $mappedSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path $mappedPath | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifyFailure($mappedSignal)) {
            return $signal.LogCritical("❌ MappedAttachment path '$mappedPath' not found in Conductor.")
        }

        $mappedAttachmentContainer = $mappedSignal.GetResult()
        if ($null -eq $mappedAttachmentContainer) {
            return $signal.LogCritical("❌ MappedAttachment container at '$mappedPath' is null.")
        }

        # ░▒▓█ REGISTER ATTACHMENT █▓▒░
        $registerSignal = $mappedAttachmentContainer.RegisterAttachment($resolvedAttachment) | Select-Object -Last 1
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

    # ░▒▓█ OPTIONAL: MERGE INTO CONDUCTOR CONTROL SIGNAL █▓▒░
    if ($Conductor -and $Conductor.ControlSignal) {
        $Conductor.ControlSignal.MergeSignal($signal)
    }

    return $signal
}
