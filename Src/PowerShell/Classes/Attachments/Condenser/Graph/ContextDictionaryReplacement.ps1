class ContextDictionaryReplacement {
    [string]$GraphName
    [string]$Replaces

    ContextDictionaryReplacement() {
        $this.GraphName = ""
        $this.Replaces = ""
    }
}
