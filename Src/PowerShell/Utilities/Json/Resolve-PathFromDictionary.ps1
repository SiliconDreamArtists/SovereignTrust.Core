function Resolve-PathFromDictionary {
    param (
        $Dictionary,
        [string]$Path,
        [bool]$IgnoreJsonObject = $false
    )

    $parts = $Path -split '\.'
    $current = $Dictionary

    foreach ($part in $parts) {
        if ($null -eq $current) { return $null }

        if (-not $IgnoreJsonObject) {
            # Step 1: Dive into _JsonObject if present
            if ($current -is [hashtable] -and $current.Contains("_JsonObject")) {
                $current = $current["_JsonObject"]
            }
            elseif ($current -is [pscustomobject] -and $current.PSObject.Properties.Name -contains "_JsonObject") {
                $current = $current._JsonObject
            }
        }

        # Step 2: Navigate next node
        if ($current -is [System.Collections.IDictionary] -and $current.Contains($part)) {
            $current = $current[$part]
        }
        elseif ($current -is [hashtable]) {
            if ($current.Contains($part)) {
                $current = $current[$part]
            }
            else {
                return $null
            }
        }
        elseif ($current -is [pscustomobject]) {
            if ($current.PSObject.Properties.Name -contains $part) {
                $current = $current.$part
            }
            else {
                return $null
            }
        }
        elseif ($current -is [System.Collections.IEnumerable]) {
            # 🚨 New: If current node is an array, find item where Name matches $part
            $found = $null
            foreach ($item in $current) {
                if (($item -is [pscustomobject] -or $item -is [hashtable]) -and `
                    ($item.Name -eq $part)) {
                    $found = $item
                    break
                }
            }
            if ($found) {
                $current = $found
            }
            else {
                return $null
            }
        }
        else {
            return $null
        }
    }

    return $current
}


function Resolve-PathFromDictionary-Previous {
    param (
        $Dictionary,
        [string]$Path,
        [bool]$IgnoreJsonObject = $false
    )

    $parts = $Path -split '\.'
    $current = $Dictionary

    foreach ($part in $parts) {
        if ($null -eq $current) { return $null }

        if (-not $IgnoreJsonObject) {
            # Step 1: Dive into _JsonObject if present
            if ($current -is [hashtable] -and $current.Contains("_JsonObject")) {
                $current = $current["_JsonObject"]
            }
            elseif ($current -is [pscustomobject] -and $current.PSObject.Properties.Name -contains "_JsonObject") {
                $current = $current._JsonObject
            }
        }

        # Step 2: Access next key
        if ($current -is [System.Collections.IDictionary] -and $current.Contains($part)) {
            $current = $current[$part]
        }
        elseif ($current -is [hashtable]) {
            if ($current.Contains($part)) {
                $current = $current[$part]
            }
            else {
                return $null
            }
        }
        elseif ($current -is [pscustomobject]) {
            if ($current.PSObject.Properties.Name -contains $part) {
                $current = $current.$part
            }
            else {
                return $null
            }
        }
        else {
            return $null
        }
    }

    return $current
}
