class GlobalCondenserFeedback {
    [System.Collections.ArrayList]$WireOutputDictionary
    [System.Collections.ArrayList]$WireMergeCondenserOutputDictionary
    [System.Collections.ArrayList]$WireGraphCondenserOutputDictionary
    [System.Collections.ArrayList]$WireConductionOutputDictionary
    [object]$Context

    hidden [System.Collections.ArrayList]$_ResultOutputs

    GlobalCondenserFeedback() {
        $this.WireOutputDictionary = [System.Collections.ArrayList]::new()
        $this.WireMergeCondenserOutputDictionary = [System.Collections.ArrayList]::new()
        $this.WireGraphCondenserOutputDictionary = [System.Collections.ArrayList]::new()
        $this.WireConductionOutputDictionary = [System.Collections.ArrayList]::new()
        $this._ResultOutputs = [System.Collections.ArrayList]::new()
        $this.Context = $null
    }

    [System.Collections.ArrayList] get_ResultOutputs() {
        if ($null -eq $this._ResultOutputs) {
            $this._ResultOutputs = [System.Collections.ArrayList]::new()
        }
        return $this._ResultOutputs
    }

    [void] set_ResultOutputs([System.Collections.ArrayList]$value) {
        $this._ResultOutputs = $value
    }
}
