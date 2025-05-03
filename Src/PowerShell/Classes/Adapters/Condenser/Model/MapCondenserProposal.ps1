class GraphCondenserProposal {
    [object]$Graph
    [object]$MapDynamic
    [string]$DocumentContainerSuffix
    [string]$RuntimeContainerSuffix
    [object]$ValueDynamic
    [Guid]$ExecutionIdentifier
    [string]$FileContents

    GraphCondenserProposal() {
        $this.ExecutionIdentifier = [guid]::NewGuid()
    }
}
