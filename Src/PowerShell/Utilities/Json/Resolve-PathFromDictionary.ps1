function Resolve-PathFromDictionary {
    param (
        [Parameter(Mandatory)] $Dictionary,
        [Parameter(Mandatory)] [string]$Path,
        [bool]$IgnoreInternalObjects = $true,
        [string]$InternalObjectsPrefix = "_"
    )

    $signal = [Signal]::new("Resolve-PathFromDictionary")

    try {
        $parts = $Path -split '\.'
        $current = $Dictionary

        foreach ($part in $parts) {
            if ($null -eq $current) {
                $signal.LogCritical("Current object is null while traversing path segment '$part'.")
                return $signal
            }

            # ░▒▓█ POINTER DEREFERENCE █▓▒░
            if ($part -eq "*") {
                if ($current -is [Signal] -and $current.PSObject.Properties["Pointer"]) {
                    $current = $current.Pointer
                    $signal.LogVerbose("🔗 Dereferenced *Pointer in signal.")
                    continue
                }
                else {
                    $signal.LogCritical("❌ '*' used but no Pointer found in current object.")
                    return $signal
                }
            }

            # ░▒▓█ INTERNAL DESCENT █▓▒░
            if ($IgnoreInternalObjects) {
                $checkIsInternal = $true
                while ($checkIsInternal) {
                    $checkIsInternal = $false

                    if ($current -is [hashtable]) {
                        foreach ($key in @($current.Keys)) {
                            if ($key.StartsWith($InternalObjectsPrefix)) {
                                $signal.LogVerbose("🔽 Descending into internal hashtable key: '$key'")
                                $current = $current[$key]
                                $checkIsInternal = $true
                                break
                            }
                        }
                    }
                    elseif ($current -is [Graph]) {
                        $signal.LogVerbose("🧠 Descending into Graph.SignalGrid from Graph object.")
                        $current = $current.SignalGrid
                        $checkIsInternal = $true
                    }
                    elseif ($current -is [Signal]) {
                        $signal.LogVerbose("🌀 Descending into Signal result object.")
                        $current = $current.GetResult()
                        $checkIsInternal = $true
                    }
                    elseif ($current -is [pscustomobject]) {
                        foreach ($prop in $current.PSObject.Properties) {
                            if ($prop.Name.StartsWith($InternalObjectsPrefix)) {
                                $signal.LogVerbose("📦 Descending into internal PSCustomObject property: '$($prop.Name)'")
                                $current = $prop.Value
                                $checkIsInternal = $true
                                break
                            }
                        }
                    }
                }
            }
        

            # ░▒▓█ FILTERED OR STANDARD SEGMENT █▓▒░
            $parsed = Parse-FilterSegment $part

            if ($parsed.IsFilter) {
                # Try to resolve the array container
                if ($current -is [System.Collections.IDictionary] -and $current.ContainsKey($parsed.ArrayKey)) {
                    $array = $current[$parsed.ArrayKey]
                }
                elseif ($current -is [pscustomobject] -and $current.PSObject.Properties.Name -contains $parsed.ArrayKey) {
                    $array = $current.$($parsed.ArrayKey)
                }
                else {
                    $signal.LogCritical("Missing array key '$($parsed.ArrayKey)' while applying filters.")
                    return $signal
                }

                # Apply filters
                $match = Resolve-FilteredArrayItem -Array $array -Filters $parsed.Filters -Signal $signal
                if ($null -eq $match) {
                    return $signal
                }

                $current = $match
                continue
            }

            # ░▒▓█ STANDARD SEGMENT TRAVERSAL █▓▒░
            $partName = $parsed.Raw
            if ($current -is [System.Collections.IDictionary] -and $current.Contains($partName)) {
                $current = $current[$partName]
            }
            elseif ($current -is [hashtable]) {
                if ($current.Contains($partName)) {
                    $current = $current[$partName]
                }
                else {
                    $signal.LogCritical("Hashtable segment missing key '$partName'.")
                    return $signal
                }
            }
            elseif ($current -is [pscustomobject]) {
                if ($current.PSObject.Properties.Name -contains $partName) {
                    $current = $current.$partName
                }
                else {
                    $signal.LogCritical("PSCustomObject segment missing property '$partName'.")
                    return $signal
                }
            }
            elseif ($current -is [System.Collections.IEnumerable] -and -not ($current -is [string])) {
                $found = $null
                foreach ($item in $current) {
                    if (($item -is [pscustomobject] -or $item -is [hashtable]) -and ($item.Name -eq $partName)) {
                        $found = $item
                        break
                    }
                }

                if ($found) {
                    $current = $found
                }
                else {
                    $signal.LogCritical("Array segment missing item with Name '$partName'.")
                    return $signal
                }
            }
            elseif ($current.GetType().IsClass -and $current.GetType().Namespace -ne "System") {
                $propInfo = $current.GetType().GetProperty($partName)
                if ($null -eq $propInfo) {
                    $signal.LogCritical("Class $($current.GetType().Name) does not have a property named '$partName'.")
                    return $signal
                }
                $next = $propInfo.GetValue($current, $null)
                if ($null -eq $next) {
                    $signal.LogCritical("Property '$partName' is null in class $($current.GetType().Name).")
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
