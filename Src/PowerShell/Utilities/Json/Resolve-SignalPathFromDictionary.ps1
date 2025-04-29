function Resolve-SignalPathFromDictionary {
    param (
        [Parameter(Mandatory)] $Dictionary,
        [Parameter(Mandatory)] [string]$Path,
        [bool]$IgnoreInternalObjects = $true,
        [string]$InternalObjectsPrefix = "_"
    )

    $signal = [Signal]::new("Resolve-SignalPathFromDictionary")

    try {
        $parts = $Path -split '\.'
        $current = $Dictionary

        foreach ($part in $parts) {
            if ($null -eq $current) {
                $signal.LogWarning("Current object is null while traversing path segment '$part'.")
                return $signal
            }

            if ($IgnoreInternalObjects) {
                if ($current -is [hashtable]) {
                    foreach ($key in @($current.Keys)) {
                        if ($key.StartsWith($InternalObjectsPrefix)) {
                            $current.Remove($key)
                        }
                    }
                }
                elseif ($current -is [pscustomobject]) {
                    foreach ($prop in @($current.PSObject.Properties)) {
                        if ($prop.Name.StartsWith($InternalObjectsPrefix)) {
                            $current.PSObject.Properties.Remove($prop.Name)
                        }
                    }
                }
            }

            if ($current -is [System.Collections.IDictionary] -and $current.Contains($part)) {
                $current = $current[$part]
            }
            elseif ($current -is [hashtable]) {
                if ($current.Contains($part)) {
                    $current = $current[$part]
                } else {
                    $signal.LogWarning("Hashtable segment missing key '$part'.")
                    return $signal
                }
            }
            elseif ($current -is [pscustomobject]) {
                if ($current.PSObject.Properties.Name -contains $part) {
                    $current = $current.$part
                } else {
                    $signal.LogWarning("PSCustomObject segment missing property '$part'.")
                    return $signal
                }
            }
            elseif ($current -is [System.Collections.IEnumerable] -and -not ($current -is [string])) {
                $found = $null
                foreach ($item in $current) {
                    if (($item -is [pscustomobject] -or $item -is [hashtable]) -and ($item.Name -eq $part)) {
                        $found = $item
                        break
                    }
                }

                if ($found) {
                    $current = $found
                } else {
                    $signal.LogWarning("Array segment missing item with Name '$part'.")
                    return $signal
                }
            }
            elseif ($current.GetType().IsClass -and $current.GetType().Namespace -ne "System") {
                $propInfo = $current.GetType().GetProperty($part)
                if ($null -eq $propInfo) {
                    $signal.LogWarning("Class $($current.GetType().Name) does not have a property named '$part'.")
                    return $signal
                }
                $next = $propInfo.GetValue($current, $null)
                if ($null -eq $next) {
                    $signal.LogWarning("Property '$part' is null in class $($current.GetType().Name).")
                    return $signal
                }
                $current = $next
            }
            else {
                $signal.LogCritical("Unsupported object type encountered while traversing path '$Path'. Type: $($current.GetType().FullName)")
                return $signal
            }
        }

        $signal.SetResult($current)
        $signal.LogInformation("Successfully resolved path '$Path'.")
    }
    catch {
        $signal.LogCritical("Critical failure during path resolution: $_")
    }

    return $signal
}
