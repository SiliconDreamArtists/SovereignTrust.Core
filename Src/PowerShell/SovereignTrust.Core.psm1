# Load all files (functions + classes)
. "$PSScriptRoot/Classes/Conduction/Conduction.ps1"
. "$PSScriptRoot/Classes/Conduction/ConductionFeedback.ps1"
. "$PSScriptRoot/Classes/Conduction/ConductionResult.ps1"
. "$PSScriptRoot/Classes/Conduction/Conductor.ps1"
. "$PSScriptRoot/Classes/Conduit/Complete-Conduction.ps1"
. "$PSScriptRoot/Classes/Conduit/Conduit.ps1"
. "$PSScriptRoot/Classes/Conduit/Invoke-Conduction.ps1"
. "$PSScriptRoot/Classes/Conduit/Start-Conduction.ps1"
. "$PSScriptRoot/Classes/Memory/Jacket.ps1"
. "$PSScriptRoot/Classes/Memory/Wire.ps1"

. "$PSScriptRoot/Classes/Attachments/BaseAttachment.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/CondenserGraphHelper.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/JsonHelper.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Graph/Context.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Graph/ContextReplacement.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Graph/Graph.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Graph/GraphReplacementType.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/GlobalCondenserFeedback.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/GlobalCondenserProposal.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/MapCondenserFeedback.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/MapCondenserProposal.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/MergeCondenserFeedbackSettings.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/MergeCondenserFeedback.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/MergeCondenserProposal.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Services/GlobalCondenserService.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Services/GraphCondenserService.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Services/TokenCondenserService.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Services/MergeCondenserService.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Services/MappedCondenserService.ps1"
. "$PSScriptRoot/Utilities/Conduction/Convert-AgentAttachmentsToConductor.ps1"
. "$PSScriptRoot/Utilities/Conduction/Get-AgentForConductor.ps1"
. "$PSScriptRoot/Utilities/Conduction/Start-BondingConductor.ps1"
. "$PSScriptRoot/Utilities/Json/Add-JsonPropertyValue.ps1"
. "$PSScriptRoot/Utilities/Json/Convert-JsonToHashtable.ps1"
. "$PSScriptRoot/Utilities/Json/Get-DictionaryValue.ps1"
. "$PSScriptRoot/Utilities/Json/Get-VirtualValueFromJson.ps1"
. "$PSScriptRoot/Utilities/Json/Load-JsonObjectFromFile.ps1"
. "$PSScriptRoot/Utilities/Json/Resolve-PathFromDictionary.ps1"
. "$PSScriptRoot/Utilities/Json/Resolve-RegexPlaceholders.ps1"
. "$PSScriptRoot/Utilities/Json/Set-DictionaryValue.ps1"

# Export public utility functions
Export-ModuleMember -Function Convert-AgentAttachmentsToConductor
Export-ModuleMember -Function Get-AgentForConductor
Export-ModuleMember -Function Start-BondingConductor
Export-ModuleMember -Function Add-JsonPropertyValue
Export-ModuleMember -Function Convert-JsonToHashtable
Export-ModuleMember -Function Get-DictionaryValue
Export-ModuleMember -Function Get-VirtualValueFromJson
Export-ModuleMember -Function Load-JsonObjectFromFile
Export-ModuleMember -Function Resolve-PathFromDictionary
Export-ModuleMember -Function Resolve-RegexPlaceholders
Export-ModuleMember -Function Set-DictionaryValue
