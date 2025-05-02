function Register-MappedAttachment {
    param (
        [Parameter(Mandatory)][hashtable]$ServiceCollection,
        [Parameter(Mandatory)][object]$Attachment,
        [string]$Label = "Attachment"
    )

    $signal = [Signal]::new("Register-$Label")

    try {
        if ($null -eq $Attachment) {
            return $signal.LogCritical("❌ Cannot register null $Label.")
        }

        if (-not $ServiceCollection.ContainsKey($Attachment)) {
            $ServiceCollection[$Attachment] = $Attachment.Jacket?.Slot
            $signal.LogInformation("✅ $Label registered successfully.")
        }
        else {
            $signal.LogWarning("⚠️ $Label already registered.")
        }
    }
    catch {
        $signal.LogCritical("🔥 Exception while registering $($Label): $($_.Exception.Message)")
    }

    return $signal
}
