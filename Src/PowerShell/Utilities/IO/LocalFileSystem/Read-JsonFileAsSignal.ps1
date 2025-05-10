function Read-JsonFileAsSignal {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )

    $signal = [Signal]::Start("Read-JsonFileAsSignal")
    $signal.LogVerbose("📖 Reading JSON file from: $Path")

    if (-not (Test-Path -Path $Path)) {
        $signal.LogError("❌ File does not exist at path: $Path")
        return $signal
    }

    try {
        $rawContent = Get-Content -Raw -Path $Path
        $json = $rawContent | ConvertFrom-Json -Depth 20
        $signal.SetResult($json)
        $signal.LogInformation("✅ JSON successfully parsed from: $Path")
    }
    catch {
        $signal.LogException("💥 Failed to parse JSON at path: $Path", $_)
    }

    return $signal
}
