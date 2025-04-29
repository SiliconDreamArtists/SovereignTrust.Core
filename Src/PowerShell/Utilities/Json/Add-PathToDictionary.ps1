function Add-PathToDictionary {
    param (
        [Parameter(Mandatory)]
        $Dictionary,

        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter()]
        $Value
    )

    $signal = [Signal]::new("Add-PathToDictionary")

    try {
        $parts = $Path -split '\.'
        $current = $Dictionary

        for ($i = 0; $i -lt $parts.Length; $i++) {
            $key = $parts[$i]
            $isLast = ($i -eq $parts.Length - 1)

            if ($current -is [System.Collections.IDictionary]) {
                if ($isLast) {
                    $current[$key] = $Value
                }
                elseif (-not $current.Contains($key)) {
                    $current[$key] = @{}
                }
                $current = $current[$key]
            }
            elseif ($current -is [System.Collections.IEnumerable] -and -not ($current -is [string])) {
                if ($current -is [System.Collections.IList]) {
                    if ($isLast) {
                        $found = $null
                        $index = 0

                        foreach ($item in $current) {
                            if (($item -is [pscustomobject] -or $item -is [hashtable]) -and $item.Name -eq $key) {
                                $found = $item
                                break
                            }
                            $index++
                        }

                        if ($null -ne $found) {
                            $current[$index] = $Value
                        }
                        else {
                            $current.Add($Value)
                        }
                    }
                    else {
                        $found = $null
                        foreach ($item in $current) {
                            if (($item -is [pscustomobject] -or $item -is [hashtable]) -and $item.Name -eq $key) {
                                $found = $item
                                break
                            }
                        }

                        if ($null -eq $found) {
                            $signal.LogWarning("No item with Name '$key' found in array segment.")
                            return $signal
                        }

                        $current = $found
                    }
                }
                else {
                    $signal.LogCritical("Cannot add to non-list enumerable at path segment '$key'.")
                    return $signal
                }
            }
            elseif ($current -is [PSCustomObject] -or $current -is [System.Management.Automation.PSObject]) {
                $existingProp = $current.PSObject.Properties[$key]
                if ($isLast) {
                    if ($existingProp) {
                        $current.$key = $Value
                    }
                    else {
                        Add-Member -InputObject $current -MemberType NoteProperty -Name $key -Value $Value
                    }
                }
                else {
                    if (-not $existingProp) {
                        $child = [PSCustomObject]@{}
                        Add-Member -InputObject $current -MemberType NoteProperty -Name $key -Value $child
                        $current = $child
                    }
                    else {
                        $current = $current.$key
                    }
                }
            }
            elseif ($current.GetType().IsClass -and $current.GetType().Namespace -ne "System") {
                $propInfo = $current.GetType().GetProperty($key)
                if ($null -eq $propInfo) {
                    $signal.LogCritical("Class $($current.GetType().Name) does not have a property named '$key'.")
                    return $signal
                }
                if ($isLast) {
                    $propInfo.SetValue($current, $Value, $null)
                }
                else {
                    $next = $propInfo.GetValue($current, $null)
                    if ($null -eq $next) {
                        $signal.LogCritical("Intermediate class property '$key' is null; cannot proceed.")
                        return $signal
                    }
                    $current = $next
                }
            }
            else {
                $signal.LogCritical("Unsupported object type: $($current.GetType().FullName) at path '$Path'.")
                return $signal
            }
        }

        $signal.SetResult($true)
        $signal.LogInformation("Path '$Path' successfully added to dictionary.")
    }
    catch {
        $signal.LogCritical("Critical failure while adding path to dictionary: $_")
    }

    return $signal
}