# ░▒▓════════════════════════════════════════════════════════════════════▓▒░
# File: Convert-AgentAttachmentsToConductor.ps1 • Project: SovereignTrust Core
# License: MIT • Authors: Shadow PhanTom, Neural Alchemist • Generated: 2025-04-30
# Lineage: SovereignTrust.Core.Attachments.Convert-AgentAttachmentsToConductor
# ░▒▓════════════════════════════════════════════════════════════════════▓▒░
# 🧠 SIGNAL USAGE EXEMPLAR
# This file demonstrates the full spectrum of SovereignTrust signal recursion patterns:
#   • 📦 Structured Signal creation, propagation, and conditional merging
#   • 🔁 Flow-controlled MergeSignalAndVerifySuccess with optional mute gates
#   • ❌ Critical logging for invalid invocation and halt conditions
#   • 🛠 Recovery-based de-escalation via LogRecovery for self-healing surfaces
#   • 🔕 Conditional muting of expected Criticals via LogMute (non-blocking trace carry)
#   • 🧱 Sovereign-safe dictionary construction with signal-confirmed attachment
#   • 📚 Result memory attachment and lineage export via SetResult
#
# ✅ Recommended as the reference exemplar for memory-driven initialization logic,
#    and a canonical implementation of sovereign flow using living Signals.

function Convert-AgentAttachmentsToConductor {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Agent,

        [Parameter(Mandatory = $true)]
        [object]$Conductor
    )

    $signal = [Signal]::new("Convert-AgentAttachmentsToConductor")

    function Add-AttachmentJacket {
        param (
            [string]$name,
            [object]$jacket
        )
        $addSignal = Add-PathToDictionary -Dictionary $Conductor -Path "AttachmentJackets.$name" -Value $jacket | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifySuccess($addSignal)) {
            $signal.LogVerbose("Mapped Attachment Jacket: $name")
        } else {
            $signal.LogWarning("Failed to map attachment jacket: $name")
        }
    }

    try {
        if (-not $Agent) {
            $signal.LogCritical("Agent is null. Cannot process attachments.")
            return $signal
        }

        if (-not $Conductor) {
            $signal.LogCritical("Conductor is null. Cannot assign attachments.")
            return $signal
        }

        # ░▒▓█ INITIALIZE ATTACHMENTJACKETS MEMORY █▓▒░
        $attachmentJacketsSignal = Resolve-PathFromDictionary -Dictionary $Conductor -Path "AttachmentJackets" | Select-Object -Last 1
        if (-not $signal.MergeSignalAndVerifySuccess($attachmentJacketsSignal)) {
            $initSignal = Add-PathToDictionary -Dictionary $Conductor -Path "AttachmentJackets" -Value ([System.Collections.Generic.List[object]]::new()) | Select-Object -Last 1
            if ($signal.MergeSignalAndVerifySuccess($initSignal)) {
                $signal.LogRecovery("🔁 AttachmentJackets path was missing but was recovered via initialization.")
            } else {
                $signal.LogWarning("⚠️ Failed to initialize AttachmentJackets memory space.")
            }
        }

        # ░▒▓█ AGENT ATTACHMENTS █▓▒░
        $agentAttachmentsSignal = Resolve-PathFromDictionary -Dictionary $Agent -Path "Attachments" | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifySuccess($agentAttachmentsSignal, $true, "Agent-level attachments are optional and were safely muted.")) {
            $agentAttachments = $agentAttachmentsSignal.GetResult()
            foreach ($attachmentJacket in $agentAttachments) {
                if ($attachmentJacket.Name) {
                    Add-AttachmentJacket -name $attachmentJacket.Name -jacket $attachmentJacket
                } else {
                    $signal.LogWarning("Skipped Agent attachment jacket with missing name.")
                }
            }
            $signal.LogInformation("Agent-level attachment jackets migrated to Conductor.")
        }

        # ░▒▓█ ROLE ATTACHMENTS █▓▒░
        $roleAttachmentsSignal = Resolve-PathFromDictionary -Dictionary $Agent -Path "CurrentRole.Attachments" | Select-Object -Last 1
        if ($signal.MergeSignalAndVerifySuccess($roleAttachmentsSignal, $true, "Role-level attachments are optional and were safely muted.")) {
            $roleAttachments = $roleAttachmentsSignal.GetResult()
            foreach ($roleAttachmentJacket in $roleAttachments) {
                if ($roleAttachmentJacket.Name) {
                    Add-AttachmentJacket -name $roleAttachmentJacket.Name -jacket $roleAttachmentJacket
                } else {
                    $signal.LogWarning("Skipped Role attachment jacket with missing name.")
                }
            }
            $signal.LogRecovery("Role-level attachment jackets migrated to Conductor.")
        }

        $signal.SetResult($Conductor)
    }
    catch {
        $signal.LogCritical("Unhandled critical failure in Convert-AgentAttachmentsToConductor: $($_.Exception.Message)")
    }

    return $signal
}
