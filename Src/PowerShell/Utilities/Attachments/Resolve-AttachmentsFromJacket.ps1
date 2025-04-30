function Resolve-AttachmentFromJacket {
    param (
        [Parameter(Mandatory)]
        [object]$Jacket
    )

    $signal = [Signal]::new("ResolveAttachment:$($Jacket?.Name ?? 'Unknown')")

    try {
        # ░▒▓█ RESOLVE JACKETS █▓▒░
        $typeSignal     = Resolve-PathFromDictionary -Dictionary $Jacket -Path "Type"
        $addressSignal  = Resolve-PathFromDictionary -Dictionary $Jacket -Path "Address"
        $assemblySignal = Resolve-PathFromDictionary -Dictionary $Jacket -Path "Assembly"

        $signal.MergeSignal(@($typeSignal, $addressSignal, $assemblySignal))

        $typeName    = $typeSignal.GetResult()
        $address     = $addressSignal.GetResult()
        $assembly    = $assemblySignal.GetResult()

        if (-not $typeName) {
            $signal.LogCritical("Attachment jacket is missing the 'Type' field.")
            return $signal
        }

        # ░▒▓█ MODULE LOAD █▓▒░
        if ($assembly) {
            try {
                Import-Module -Name $assembly -ErrorAction Stop
                $signal.LogInformation("Assembly '$assembly' loaded successfully.")
            } catch {
                $signal.LogCritical("Failed to load PowerShell module '$assembly': $($_.Exception.Message)")
                return $signal
            }
        }

        # ░▒▓█ INSTANCE CREATION █▓▒░
        $type = [Type]::GetType($typeName, $false)
        if ($null -eq $type) {
            $signal.LogCritical("Attachment type '$typeName' could not be resolved.")
            return $signal
        }

        $instance = [Activator]::CreateInstance($type)
        if ($null -eq $instance) {
            $signal.LogCritical("Failed to instantiate type '$typeName'.")
            return $signal
        }

        # ░▒▓█ INITIALIZATION █▓▒░
        if ($address -and ($instance | Get-Member -Name "Init" -MemberType Method)) {
            $instance.Init($address)
            $signal.LogInformation("Attachment '$($Jacket.Name)' initialized with address.")
        } else {
            $signal.LogVerbose("Attachment '$($Jacket.Name)' created without initialization step.")
        }

        # ░▒▓█ RESULT █▓▒░
        $signal.SetResult($instance)
        $signal.LogInformation("Attachment '$($Jacket.Name)' resolved and returned successfully.")
    }
    catch {
        $signal.LogCritical("Unhandled exception resolving attachment: $($_.Exception.Message)")
    }

    return $signal
}
