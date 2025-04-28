
function Set-DictionaryValue {
    param (
        [Parameter(Mandatory)]
        [ref]$Object,

        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        $Value
    )

    $target = $Object.Value

    if ($target -is [System.Collections.Specialized.OrderedDictionary] -or $target -is [hashtable]) {
        $target[$Key] = $Value
    }
    elseif ($target -is [pscustomobject]) {
        if ($target.PSObject.Properties[$Key]) {
            $target.$Key = $Value
        }
        else {
            $null = Add-Member -InputObject $target -MemberType NoteProperty -Name $Key -Value $Value -Force
        }
    }
    else {
        throw "[agent] Unsupported object type for Set-DictionaryValue: $($target.GetType().Name)"
    }

    $Object.Value = $target
}

