function Invoke-Conduction {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Conduit]$Conduit,

        [Parameter(Mandatory = $true)]
        [object]$Phase  # Typically a small PSObject or Phase class in the future
    )

    if (-not $Conduit.IsRunning) {
        throw "Conduction is not running. Cannot invoke Phase."
    }

    try {
        # Execute the Phase inside the living Context
        $Conduit.ExecutePhase($Phase)
    }
    catch {
        Write-Warning "Failed to invoke Phase: $_"
    }
}
