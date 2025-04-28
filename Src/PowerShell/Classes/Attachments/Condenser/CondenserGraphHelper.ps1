class CondenserGraphHelper {

    static [Newtonsoft.Json.Linq.JObject] BuildGraph([object]$object) {
        return [JsonHelper]::FromObject($object)
    }

    static [void] MergeGraphs([Newtonsoft.Json.Linq.JObject]$target, [Newtonsoft.Json.Linq.JObject]$source) {
        [JsonHelper]::MergeTokens($target, $source)
    }

    static [void] ReplaceProperties([Newtonsoft.Json.Linq.JObject]$graph, [hashtable]$replacements) {
        foreach ($key in $replacements.Keys) {
            $token = [JsonHelper]::SelectToken($graph, $key)
            if ($token) {
                $token.Replace($replacements[$key])
            } else {
                [JsonHelper]::SetProperty($graph, $key, $replacements[$key])
            }
        }
    }

    static [Newtonsoft.Json.Linq.JToken] RetrieveGlobals([Newtonsoft.Json.Linq.JObject]$graph, [string]$tagNodePath) {
        return [JsonHelper]::SelectToken($graph, $tagNodePath)
    }

    static [void] NavigateAndReplaceStrings([Newtonsoft.Json.Linq.JToken]$graph, [scriptblock]$action) {
        foreach ($token in $graph.SelectTokens('..*')) {
            if ($token.Type -eq "String") {
                & $action $token
            }
        }
    }
}
