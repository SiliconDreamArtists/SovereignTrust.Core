function Resolve-AttachmentFromJacket {
    param (
        [Parameter(Mandatory)]
        [object]$ConductionContext,

        [Parameter(Mandatory)]
        [object]$Jacket
    )

    $signal = [Signal]::new("ResolveAttachment")

    try {
        # ░▒▓█ RESOLVE JACKETS █▓▒░
        $typeSignal = Resolve-PathFromDictionary -Dictionary $Jacket -Path "Type"            | Select-Object -Last 1
        $addressSignal = Resolve-PathFromDictionary -Dictionary $Jacket -Path "Address"         | Select-Object -Last 1
        $assemblySignal = Resolve-PathFromDictionary -Dictionary $Jacket -Path "Assembly"        | Select-Object -Last 1
        $sourceSignal = Resolve-PathFromDictionary -Dictionary $Jacket -Path "AssemblySource"  | Select-Object -Last 1

        if ($signal.MergeSignalAndVerifyFailure(@($typeSignal, $addressSignal, $assemblySignal))) {
            $signal.LogCritical("❌ One or more required jacket fields (Type, Address, Assembly) are missing.")
            return $signal
        }

        $typeName = $typeSignal.GetResult()
        $address = $addressSignal.GetResult()
        $assembly = $assemblySignal.GetResult()
        $sourceFolder = $sourceSignal.GetResult()

        # ░▒▓█ MODULE LOAD █▓▒░
        $importSignal = [Signal]::new("ImportModule:$assembly")

        try {
            if ($sourceFolder) {
                $fullPath = Join-Path $sourceFolder "$assembly.psd1"
                if (Test-Path $fullPath) {
                    Import-Module $fullPath -ErrorAction Stop
                    $importSignal.LogInformation("✅ Assembly '$assembly' loaded from override path '$sourceFolder'.")
                }
                else {
                    $importSignal.LogWarning("⚠️ AssemblySource specified but '$fullPath' not found — falling back.")
                    Import-Module -Name $assembly -ErrorAction Stop
                    $importSignal.LogInformation("✅ Assembly '$assembly' loaded via fallback to standard module path.")
                }
            }
            else {
                Import-Module -Name $assembly -ErrorAction Stop
                $importSignal.LogInformation("✅ Assembly '$assembly' loaded from default module path.")
            }
        }
        catch {
            $importSignal.LogCritical("❌ Failed to load PowerShell module '$assembly': $($_.Exception.Message)")
        }

        if ($signal.MergeSignalAndVerifyFailure($importSignal)) {
            return $signal
        }

        # ░▒▓█ INSTANCE CREATION █▓▒░
        try {
            $instance = New-Object -TypeName $typeName -ErrorAction Stop
        }
        catch {
            $signal.LogCritical("❌ Failed to instantiate type '$typeName': $_")
            return $signal
        }

        if ($null -eq $instance) {
            $instance = [Activator]::CreateInstance($type)
            if ($null -eq $instance) {
                $signal.LogCritical("❌ Failed to instantiate type '$typeName'.")
                return $signal
            }
        }

        # ░▒▓█ INITIALIZATION █▓▒░
        if ($null -ne $instance -and ($instance | Get-Member -Name "Construct" -MemberType Method)) {
            $constructCall = $instance.Construct($Jacket)
            $constructSignal = $constructCall | Select-Object -Last 1
        
            if ($signal.MergeSignalAndVerifySuccess($constructSignal)) {
                $signal.LogInformation("✅ Attachment '$($Jacket.Name)' constructed with jacket data.")
            }
            else {
                $signal.LogWarning("⚠️ Attachment '$($Jacket.Name)' was instantiated but failed Construct() step.")
            }
        }
        else {
            $signal.LogVerbose("Attachment '$($Jacket.Name)' created without Construct() method present.")
        }
        
        # ░▒▓█ RESULT █▓▒░
        $signal.SetResult($instance)
        $signal.LogInformation("📦 Attachment '$($Jacket.Name)' resolved and returned successfully.")
    }
    catch {
        $signal.LogCritical("🔥 Unhandled exception resolving attachment: $($_.Exception.Message)")
    }

    return $signal
}
