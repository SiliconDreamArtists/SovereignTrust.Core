function Evaluate-AgainstDoctrine {
    param (
        [Parameter(Mandatory = $true)][string]$ScriptText,
        [Parameter()][string]$SourceName = "UnnamedScript"
    )

    $signal = [Signal]::Start("Evaluate-AgainstDoctrine:$SourceName")
    $score = 100
    $flags = @()

    # ░▒▓█ CHECK: MergeSignal enforcement █▓▒░
    if ($ScriptText -notmatch '\.MergeSignal\(') {
        $score -= 15
        $flags += "❌ No .MergeSignal() found — risk of signal loss or memory orphaning."
    }

    # ░▒▓█ CHECK: SetResult usage █▓▒░
    if ($ScriptText -notmatch '\.SetResult\(') {
        $score -= 10
        $flags += "⚠️ Missing .SetResult() — output may be undefined or untracked."
    }

    # ░▒▓█ CHECK: Raw property access (anti-pattern) █▓▒░
    if ($ScriptText -match '\.\w+\.\w+') {
        $score -= 20
        $flags += "🚫 Raw property traversal detected — use Resolve-PathFromDictionary for sovereign safety."
    }

    # ░▒▓█ CHECK: Signal creation █▓▒░
    if ($ScriptText -notmatch '\[Signal\]::new') {
        $score -= 25
        $flags += "❌ No signal initialized — function is non-sovereign or uncontrolled."
    }

    # ░▒▓█ CHECK: Logging discipline █▓▒░
    if ($ScriptText -notmatch '\.Log') {
        $score -= 10
        $flags += "ℹ️ No logging detected — traceability compromised."
    }

    # ░▒▓█ CHECK: Return value is a Signal █▓▒░
    if ($ScriptText -notmatch 'return \$\w+\s*$') {
        $score -= 10
        $flags += "⚠️ Return statement is not signal-tracked."
    }

    # ░▒▓█ COMPILE REPORT █▓▒░
    $signal.SetResult(@{
        Score = $score
        Flags = $flags
        Passed = ($score -ge 85)
    })

    if ($score -ge 85) {
        $signal.LogInformation("✅ Doctrine alignment strong — score $score/100.")
    }
    else {
        $signal.LogWarning("⚠️ Doctrine misalignment detected — score $score/100.")
        foreach ($flag in $flags) {
            $signal.LogWarning($flag)
        }
    }

    return $signal
}
