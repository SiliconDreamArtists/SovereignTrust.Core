class GraphCondenserSignal {
    [Graph]$Graph
    [object]$Context
    [hashtable]$Feedback

    GraphCondenserSignal() {
        $this.Feedback = @{}
    }
}
