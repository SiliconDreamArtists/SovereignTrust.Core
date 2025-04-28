class JsonHelper {

    static [Newtonsoft.Json.Linq.JObject] FromObject([object]$object) {
        return [Newtonsoft.Json.Linq.JObject]::FromObject($object)
    }

    static [Newtonsoft.Json.Linq.JToken] ParseJson([string]$jsonString) {
        return [Newtonsoft.Json.Linq.JToken]::Parse($jsonString)
    }

    static [Newtonsoft.Json.Linq.JToken] SelectToken([Newtonsoft.Json.Linq.JToken]$jtoken, [string]$path) {
        return $jtoken.SelectToken($path)
    }

    static [void] MergeTokens([Newtonsoft.Json.Linq.JObject]$target, [Newtonsoft.Json.Linq.JObject]$source) {
        $settings = [Newtonsoft.Json.Linq.JsonMergeSettings]::new()
        $settings.MergeArrayHandling = [Newtonsoft.Json.Linq.MergeArrayHandling]::Merge
        $settings.MergeNullValueHandling = [Newtonsoft.Json.Linq.MergeNullValueHandling]::Merge
        $target.Merge($source, $settings)
    }

    static [void] SetProperty([Newtonsoft.Json.Linq.JObject]$jobject, [string]$key, [object]$value) {
        $jobject[$key] = $value
    }
}
