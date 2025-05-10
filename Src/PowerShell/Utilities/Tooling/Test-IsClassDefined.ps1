# =============================================================================
# 🧠 SovereignTrust Diagnostic Utility: Test-IsClassDefined
# =============================================================================
# Checks whether a PowerShell class is defined or resolvable from the current
# application domain. Returns a Signal with embedded result and diagnostics.
#
# ✅ Use this in dynamic loading, plugin detection, or conditional execution
# 📦 Supports namespace-style resolution from assemblies and runtime classes
# =============================================================================

function Test-IsClassDefined {
    param (
        [Parameter(Mandatory)]
        [string]$ClassName
    )

    $signal = [Signal]::Start("Test-IsClassDefined:$ClassName")

    try {
        # ░▒▓█ TYPE DIRECT QUERY █▓▒░
        $type = [Type]::GetType($ClassName, $false)
        if ($type) {
            $signal.LogVerbose("✅ Class found via [Type]::GetType(): $ClassName")
            $signal.SetResult($true)
            return $signal
        }

        # ░▒▓█ ASSEMBLY SCAN █▓▒░
        $signal.LogVerbose("🔍 Scanning assemblies for class: $ClassName")
        $type = [AppDomain]::CurrentDomain.GetAssemblies() |
            ForEach-Object { $_.GetType($ClassName, $false) } |
            Where-Object { $_ -ne $null } |
            Select-Object -First 1

        if ($type) {
            $signal.LogVerbose("✅ Class found in assembly: $($type.Assembly.FullName)")
            $signal.SetResult($true)
        }
        else {
            $signal.LogWarning("❌ Class not found: $ClassName")
            $signal.SetResult($false)
        }
    }
    catch {
        $signal.LogCritical("🔥 Error while checking class: $($_.Exception.Message)")
        $signal.SetResult($false)
    }

    return $signal
}
