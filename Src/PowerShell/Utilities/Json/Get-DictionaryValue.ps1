
function Get-DictionaryValue {
    param (
        [Parameter(Mandatory)]
        $Object,

        [Parameter(Mandatory)]
        [string]$Key
    )

    if ($Object -is [System.Collections.IDictionary] -and $Object.Contains($Key)) {
        return $Object[$Key]
    }
    elseif ($Object -is [pscustomobject] -and $Object.PSObject.Properties.Match($Key)) {
        return $Object.$Key
    }

    return $null
}