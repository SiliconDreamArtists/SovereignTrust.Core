function Resolve-AttachmentFromJacket {
    param (
        [Parameter(Mandatory)]
        [object]$Jacket
    )

    $signal = [Signal]::new("ResolveAttachment:$($Jacket.Name)")

    try {
        # Always resolve through sovereign path access
        $typeName = Resolve-PathFromDictionary -Dictionary $Jacket -Path "Type"
        $address = Resolve-PathFromDictionary -Dictionary $Jacket -Path "Address"

        if (-not $typeName) {
            $signal.LogCritical("Attachment jacket missing 'Type' field.")
            return $signal
        }

        $type = [Type]::GetType($typeName, $false)
        if ($null -eq $type) {
            $signal.LogCritical("Attachment type '$typeName' could not be found.")
            return $signal
        }

        $instance = [Activator]::CreateInstance($type)

        if ($instance) {
            if ($address -and ($instance | Get-Member -Name "Init" -MemberType Method)) {
                $instance.Init($address)
                $signal.LogInformation("Attachment '$($Jacket.Name)' initialized with address input.")
            } else {
                $signal.LogVerbose("Attachment '$($Jacket.Name)' created without initialization.")
            }
        } else {
            $signal.LogCritical("Failed to instantiate type '$typeName'.")
            return $signal
        }

        $signal.SetResult($instance)
        $signal.LogInformation("Attachment '$($Jacket.Name)' resolved and attached successfully.")
    }
    catch {
        $signal.LogCritical("Unhandled exception resolving attachment: $($_.Exception.Message)")
    }

    return $signal
}
