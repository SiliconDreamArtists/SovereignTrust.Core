
function Add-JsonPropertyValue {
    param (
        [Parameter(Mandatory)]
        $Object,

        [Parameter(Mandatory)]
        [string]$PropertyName,

        [Parameter()]
        $Value
    )

    $parts = $PropertyName -split '\.'
    $current = $Object

    for ($i = 0; $i -lt $parts.Length; $i++) {
        $key = $parts[$i]

        $isLast = ($i -eq $parts.Length - 1)

        # If it's dictionary-like
        if ($current -is [System.Collections.IDictionary]) {
            if ($isLast) {
                $current[$key] = $Value
            } elseif (-not $current.Contains($key)) {
                $current[$key] = @{}
            }
            $current = $current[$key]
        }
        # If it's a PSObject
        elseif ($current -is [PSCustomObject] -or $current -is [System.Management.Automation.PSObject]) {
            $existingProp = $current.PSObject.Properties[$key]
            if ($isLast) {
                if ($existingProp) {
                    $current.$key = $Value
                } else {
                    Add-Member -InputObject $current -MemberType NoteProperty -Name $key -Value $Value
                }
            } else {
                if (-not $existingProp) {
                    $child = [PSCustomObject]@{}
                    Add-Member -InputObject $current -MemberType NoteProperty -Name $key -Value $child
                    $current = $child
                } else {
                    $current = $current.$key
                }
            }
        }
        else {
            throw "Unsupported object type: $($current.GetType().FullName)"
        }
    }
}