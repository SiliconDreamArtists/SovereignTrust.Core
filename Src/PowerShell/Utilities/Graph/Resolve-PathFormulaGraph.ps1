function Resolve-PathFormulaGraph {
    param (
        [Parameter(Mandatory)][string]$WirePath,
        [Parameter(Mandatory)][string]$StrategyType,
        [Parameter()][object]$Environment
    )

    $signal = [Signal]::new("Resolve-PathFormulaGraph:$WirePath")

    switch ($StrategyType) {
        "Publisher" {
            $innerSignal = Resolve-PathFormulaGraphForPublisher -WirePath $WirePath -Environment $Environment | Select-Object -Last 1
            if ($signal.MergeSignalAndVerifySuccess($innerSignal)) {
                $signal.SetResult(@{
                    Strategy = "Publisher"
                    WirePath = $WirePath
                    Graph    = $innerSignal.GetResult()
                })
            } else {
                $signal.LogCritical("❌ Failed to resolve graph using strategy 'Publisher'.")
            }
        }
        "Module" {
            $innerSignal = Resolve-PathFormulaGraphForModule -WirePath $WirePath -Environment $Environment | Select-Object -Last 1
            if ($signal.MergeSignalAndVerifySuccess($innerSignal)) {
                $signal.SetResult(@{
                    Strategy = "Modules"
                    WirePath = $WirePath
                    Graph    = $innerSignal.GetResult()
                })
            } else {
                $signal.LogCritical("❌ Failed to resolve graph using strategy 'Modules'.")
            }
        }
        default {
            $signal.LogCritical("❌ Unknown strategy type: $StrategyType")
        }
    }

    return $signal
}
