function Ensure-HydrationIntentInSignal {
    param (
        [Parameter(Mandatory)][Signal]$GraphSignal,
        [Parameter(Mandatory)][Graph]$Graph,
        [Parameter(Mandatory)][Signal]$Signal
    )
    $result = $Signal.GetResult()
    if ($null -eq $result -or -not ($result.ContainsKey("HydrationIntent"))) {
        return
    }
    $intentBlock = $result["HydrationIntent"]
    $intentArray = if ($intentBlock -is [System.Collections.IEnumerable]) { $intentBlock } else { @($intentBlock) }
    foreach ($intent in $intentArray) {
        $timing = $intent.Timing ?? "Sequential"
        switch ($timing) {
            "Sequential" {
                $hydrateSignal = Invoke-HydrationCondenserService -Graph $Graph -Intent @($intent) | Select-Object -Last 1
                $GraphSignal.MergeSignal($hydrateSignal)
            }
            default {
                Add-PathToDictionary -Dictionary $Graph -Path "HydrationQueue[]" -Value $intent | Out-Null
                $GraphSignal.LogInformation("🕓 Deferred hydration for '$($intent.RelativePath)' queued.")
            }
        }
    }
}