# Load all files (functions + classes)
. "$PSScriptRoot/Classes/Attachments/UX/ConsoleLogger.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/JsonHelper.ps1"

. "$PSScriptRoot/Classes/Conduit/Conduit.ps1"
. "$PSScriptRoot/Classes/Conduction/Conduction.ps1"
. "$PSScriptRoot/Classes/Conduction/ConductionSignal.ps1"
. "$PSScriptRoot/Classes/Conduction/ConductionResultSignal.ps1"
. "$PSScriptRoot/Classes/Conduction/Conductor.ps1"
. "$PSScriptRoot/Classes/Conduit/Complete-Conduction.ps1"
. "$PSScriptRoot/Classes/Conduit/Invoke-Conduction.ps1"
. "$PSScriptRoot/Classes/Conduit/Start-Conduction.ps1"
. "$PSScriptRoot/Classes/Memory/Jacket.ps1"
. "$PSScriptRoot/Classes/Memory/Wire.ps1"

. "$PSScriptRoot/Classes/Attachments/MappedStorageAttachment.ps1"
. "$PSScriptRoot/Classes/Attachments/MappedNetworkAttachment.ps1"

. "$PSScriptRoot/Classes/Attachments/Storage/Storage_EmbeddedFileSystem.ps1"


. "$PSScriptRoot/Utilities/Graph/Convert-GraphToJson.ps1"
. "$PSScriptRoot/Utilities/Graph/Convert-JsonToGraph.ps1"

. "$PSScriptRoot/Utilities/Hydration/Resolve-HydrationSourcePath.ps1"
. "$PSScriptRoot/Utilities/Hydration/Read-HydrationFile.ps1"
. "$PSScriptRoot/Utilities/Hydration/Apply-HydrationToGraph.ps1"
. "$PSScriptRoot/Utilities/Hydration/Invoke-HydrationCondenserService.ps1"
. "$PSScriptRoot/Utilities/Hydration/Ensure-HydrationIntentInSignal.ps1"
. "$PSScriptRoot/Utilities/Hydration/Resolve-GraphHydrationQueue.ps1"

. "$PSScriptRoot/Classes/Attachments/BaseAttachment.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/CondenserGraphHelper.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Graph/Context.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Graph/ContextReplacement.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Graph/Graph.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Graph/GraphReplacementType.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/GlobalCondenserSignal.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/GlobalCondenserProposal.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/MapCondenserSignal.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/MapCondenserProposal.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/MergeCondenserSignalSettings.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/MergeCondenserSignal.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Model/MergeCondenserProposal.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Services/GlobalCondenserService.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Services/MapCondenserService.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Services/GraphCondenserService.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Services/TokenCondenserService.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Services/MergeCondenserService.ps1"
. "$PSScriptRoot/Classes/Attachments/Condenser/Services/MappedCondenserService.ps1"

. "$PSScriptRoot/Utilities/Attachments/Register-MappedAttachment.ps1"
. "$PSScriptRoot/Utilities/Attachments/Register-AttachmentToMappedSlot.ps1"
. "$PSScriptRoot/Utilities/Attachments/Register-ModuleLoaded.ps1"
. "$PSScriptRoot/Utilities/Attachments/Resolve-AttachmentsFromJacket.ps1"
. "$PSScriptRoot/Utilities/Attachments/Resolve-ConductorAttachments.ps1"
. "$PSScriptRoot/Utilities/Attachments/Test-ModuleLoaded.ps1"
. "$PSScriptRoot/Utilities/Attachments/Resolve-DependencyModuleFromGraph.ps1"

. "$PSScriptRoot/Utilities/Tooling/Ensure-DotNetLibraryFromNuget.ps1"
. "$PSScriptRoot/Utilities/Tooling/Invoke-TestGraph.ps1"

. "$PSScriptRoot/Utilities/IO/LocalFileSystem/Wait-ForFileUnlock.ps1"
. "$PSScriptRoot/Utilities/Json/Get-JsonObjectFromFile.ps1"

. "$PSScriptRoot/Utilities/Conduction/Convert-AgentAttachmentsToConductor.ps1"
. "$PSScriptRoot/Utilities/Conduction/Get-AgentForConductor.ps1"
. "$PSScriptRoot/Utilities/Conduction/Start-BondingConductor.ps1"
. "$PSScriptRoot/Utilities/Json/Add-PathToDictionary.ps1"
. "$PSScriptRoot/Utilities/Json/Convert-JsonToHashtable.ps1"
. "$PSScriptRoot/Utilities/Json/Get-DictionaryValue.ps1"
. "$PSScriptRoot/Utilities/Json/Get-VirtualValueFromJson.ps1"
. "$PSScriptRoot/Utilities/Json/Resolve-PathFromDictionaryNoSignal.ps1"
. "$PSScriptRoot/Utilities/Json/Resolve-PathFromDictionary.ps1"
. "$PSScriptRoot/Utilities/Json/Resolve-RegexPlaceholders.ps1"
. "$PSScriptRoot/Utilities/Json/Set-DictionaryValue.ps1"

. "$PSScriptRoot/Utilities/Graph/Resolve-PathFormulaGraph.ps1"
. "$PSScriptRoot/Utilities/Graph/Resolve-PathFormulaGraphForModule.ps1"
. "$PSScriptRoot/Utilities/Graph/Resolve-PathFormulaGraphForPublisher.ps1"

# Export public utility functions
Export-ModuleMember -Function Convert-AgentAttachmentsToConductor
Export-ModuleMember -Function Get-AgentForConductor
Export-ModuleMember -Function Start-BondingConductor
Export-ModuleMember -Function Add-PathToDictionary
Export-ModuleMember -Function Convert-JsonToHashtable
Export-ModuleMember -Function Get-DictionaryValue
Export-ModuleMember -Function Get-VirtualValueFromJson
Export-ModuleMember -Function Load-JsonObjectFromFile
Export-ModuleMember -Function Resolve-PathFromDictionaryNoSignal
Export-ModuleMember -Function Resolve-RegexPlaceholders
Export-ModuleMember -Function Set-DictionaryValue
Export-ModuleMember -Function Ensure-DotNetLibraryFromNuget
Export-ModuleMember -Function Invoke-TestGraph
Export-ModuleMember -Function Get-JsonObjectFromFile
Export-ModuleMember -Function Wait-ForFileUnlock


Export-ModuleMember -Function  Resolve-DependencyModuleFromGraph
Export-ModuleMember -Function  Register-AttachmentToMappedSlot
Export-ModuleMember -Function  Register-ModuleLoaded
Export-ModuleMember -Function  Resolve-AttachmentsFromJacket
Export-ModuleMember -Function  Resolve-ConductorAttachments
Export-ModuleMember -Function  Test-ModuleLoaded

Export-ModuleMember -Function  Resolve-PathFormulaGraph
Export-ModuleMember -Function  Resolve-PathFormulaGraphForModule
Export-ModuleMember -Function  Resolve-PathFormulaGraphForPublisher
