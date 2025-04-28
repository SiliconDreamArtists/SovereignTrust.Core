class GraphCondenserFeedback {
    [Graph]$Graph
    [object]$Context
    [hashtable]$Feedback

    GraphCondenserFeedback() {
        $this.Feedback = @{}
    }
}
