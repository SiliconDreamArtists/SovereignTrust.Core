function Resolve-PathFromDictionary {
    param (
        [Parameter(Mandatory)] $Dictionary,
        [Parameter(Mandatory)] [string]$Path,
        [bool]$IgnoreInternalObjects = $true,
        [bool]$SkipFinalInternalUnwrap = $false
    )

    $signal = [Signal]::new("Resolve-PathFromDictionary")
    
    function Unwrap-InternalObjects {
        param ([object]$obj)
        $current = $obj
        $check = $true
        while ($check) {
            $check = $false
            if ($current -is [Signal]) {
                $current = $current.GetResult()
                $check = $true
            } elseif ($current -is [Graph]) {
                $current = $current.SignalGrid
                $check = $true
            }
        }
        return $current
    }

    function Expand-SymbolicPathSegments {
        param (
            [string[]]$RawSegments
        )
    
        $symbolMap = @{
            "%" = "Jacket"
            "*" = "Pointer"
            "@" = "Result"
            "#" = "ControlSignal"
        }
    
        $expanded = foreach ($segment in $RawSegments) {
            if ($symbolMap.ContainsKey($segment)) {
                $symbolMap[$segment]
            } else {
                $segment
            }
        }
    
        return $expanded
    }

    try {
        # ░▒▓█ AUTO-ADJUST FINAL UNWRAP BASED ON PATH SUFFIX █▓▒░
        if (-not $SkipFinalInternalUnwrap -and $Path -match '(?i)(Graph|Signal|SignalGrid)$') {
            $SkipFinalInternalUnwrap = $true
            $signal.LogVerbose("🧠 SkipFinalInternalUnwrap auto-enabled for path suffix match: '$Path'")
        }

        $parts = Expand-SymbolicPathSegments -RawSegments ($Path -split '\.')
        $current = $Dictionary

        foreach ($part in $parts) {
            if ($null -eq $current) {
                $signal.LogCritical("Current object is null while traversing path segment '$part'.")
                return $signal
            }

            # ░▒▓█ INTERNAL OBJECT UNWRAP (PER STEP) █▓▒░
            if ($IgnoreInternalObjects) {
                $current = Unwrap-InternalObjects $current
            }

            # ░▒▓█ SIGNAL POINTER SHORTCUT █▓▒░
            if ($part -eq "*") {
                if ($current -is [Signal] -and $current.PSObject.Properties["Pointer"]) {
                    $current = $current.Pointer
                    $signal.LogVerbose("🔗 Dereferenced *Pointer in signal.")
                    continue
                } else {
                    $signal.LogCritical("❌ '*' used but no Pointer found in current object.")
                    return $signal
                }
            }

            # ░▒▓█ FILTER SEGMENT HANDLING █▓▒░
            $parsed = Parse-FilterSegment $part

            if ($parsed.IsFilter) {
                # ░▒▓█ Resolve array for filter application █▓▒░
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

                # ░▒▓█ Apply structured filters and isolate match █▓▒░
                $match = Resolve-FilteredArrayItem -Array $array -Filters $parsed.Filters -Signal $signal
                if ($null -eq $match) {
                    return $signal
                }

                $current = $match
                continue
            }

            # ░▒▓█ RAW SEGMENT TRAVERSAL █▓▒░
            $partName = $parsed.Raw

            # ░▒▓█ Hashtable/Dictionary Access █▓▒░
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

            # ░▒▓█ PSCustomObject Property Access █▓▒░
            elseif ($current -is [pscustomobject]) {
                if ($current.PSObject.Properties.Name -contains $partName) {
                    $current = $current.$partName
                }
                else {
                    $signal.LogCritical("PSCustomObject segment missing property '$partName'.")
                    return $signal
                }
            }

            # ░▒▓█ Enumerable Named Lookup █▓▒░
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

            # ░▒▓█ Sovereign Class Object Descent █▓▒░
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

            # ░▒▓█ UNSUPPORTED TYPE HANDLING █▓▒░
            else {
                $signal.LogCritical("Unsupported object type encountered while traversing path '$Path'. Type: $($current.GetType().FullName)")
                return $signal
            }
        }

        # ░▒▓█ FINAL UNWRAP (IF ENABLED) █▓▒░
        if (-not $SkipFinalInternalUnwrap) {
            $current = Unwrap-InternalObjects $current
        }

        # ░▒▓█ SUCCESS RETURN █▓▒░
        $signal.SetResult($current)
        $signal.LogInformation("Successfully resolved path '$Path'.")
    }
    catch {
        $signal.LogCritical("Critical failure during path resolution: $_")
    }

    return $signal
}
