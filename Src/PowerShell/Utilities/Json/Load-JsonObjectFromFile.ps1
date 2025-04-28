#May Be Obsolete

function Get-JsonObjectFromFile {
    param (
        [Parameter(Mandatory)][string]$RootFolder,
        [Parameter(Mandatory)][string]$VirtualPath
    )

    $fullPath = Join-Path $RootFolder $VirtualPath

    if (-not (Test-Path $fullPath)) {
        throw "JSON file not found: $fullPath"
    }

    try {
        $rawJson = Get-Content -Path $fullPath -Raw -Encoding UTF8
        $jsonArray = $rawJson | ConvertFrom-Json -Depth 20 -ErrorAction Stop

        if ($jsonArray -isnot [System.Collections.IEnumerable] -or $jsonArray -is [string]) {
            throw "Invalid JSON: Root must be an array of objects."
        }

        return $jsonArray
    } catch {
        throw "Error parsing JSON file at $($fullPath): $($_.Exception.Message)"
    }
}
