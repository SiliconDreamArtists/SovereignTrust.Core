# Load all files (functions + classes)
. "$PSScriptRoot/Classes/Adapters/UX/ConsoleLogger.ps1"
#. "$PSScriptRoot/Classes/Adapters/Condenser/JsonHelper.ps1"

. "$PSScriptRoot/Classes/Adapters/MappedStorageAdapter.ps1"
. "$PSScriptRoot/Classes/Adapters/MappedNetworkAdapter.ps1"
. "$PSScriptRoot/Classes/Adapters/MappedCondenserAdapter.ps1"

. "$PSScriptRoot/Classes/Conduction/Conduit.ps1"
. "$PSScriptRoot/Classes/Conduction/Conductor.ps1"
. "$PSScriptRoot/Utilities/Conduction/Complete-Conduction.ps1"
. "$PSScriptRoot/Utilities/Conduction/Invoke-Conduction.ps1"
. "$PSScriptRoot/Utilities/Conduction/Start-BondingConduction.ps1"
. "$PSScriptRoot/Utilities/Conduction/Start-Conduction.ps1"

. "$PSScriptRoot/Classes/Adapters/Storage/Storage_EmbeddedFileSystem.ps1"


. "$PSScriptRoot/Utilities/Graph/Convert-GraphToJson.ps1"
. "$PSScriptRoot/Utilities/Graph/Convert-JsonToGraph.ps1"

. "$PSScriptRoot/Utilities/Adapters/Condenser/Hydration/Resolve-HydrationSourcePath.ps1"
. "$PSScriptRoot/Utilities/Adapters/Condenser/Hydration/Read-HydrationFile.ps1"
. "$PSScriptRoot/Utilities/Adapters/Condenser/Hydration/Apply-HydrationToGraph.ps1"
. "$PSScriptRoot/Utilities/Adapters/Condenser/Hydration/Invoke-HydrationCondenser.ps1"
. "$PSScriptRoot/Utilities/Adapters/Condenser/Hydration/Ensure-HydrationIntentInSignal.ps1"
. "$PSScriptRoot/Utilities/Adapters/Condenser/Hydration/Resolve-GraphHydrationQueue.ps1"

. "$PSScriptRoot/Classes/Adapters/BaseAdapter.ps1"

. "$PSScriptRoot/Classes/Adapters/Condenser/GlobalCondenser.ps1"
. "$PSScriptRoot/Classes/Adapters/Condenser/MapCondenser.ps1"
. "$PSScriptRoot/Classes/Adapters/Condenser/HydrationCondenser.ps1"
. "$PSScriptRoot/Classes/Adapters/Condenser/GraphCondenser.ps1"
. "$PSScriptRoot/Classes/Adapters/Condenser/FormulaGraphCondenser.ps1"
. "$PSScriptRoot/Classes/Adapters/Condenser/TokenCondenser.ps1"
. "$PSScriptRoot/Classes/Adapters/Condenser/MergeCondenser.ps1"

. "$PSScriptRoot/Utilities/Adapters/Condenser/Merge/Merge-CondenserCore.ps1"


. "$PSScriptRoot/Utilities/Adapters/Register-MappedAdapter.ps1"
. "$PSScriptRoot/Utilities/Adapters/Register-AdapterToMappedSlot.ps1"
. "$PSScriptRoot/Utilities/Adapters/Register-ModuleLoaded.ps1"
. "$PSScriptRoot/Utilities/Adapters/Resolve-AdaptersFromJacket.ps1"
. "$PSScriptRoot/Utilities/Adapters/Resolve-ConductorAdapters.ps1"
. "$PSScriptRoot/Utilities/Adapters/Test-ModuleLoaded.ps1"
. "$PSScriptRoot/Utilities/Adapters/Resolve-DependencyModuleFromGraph.ps1"
. "$PSScriptRoot/Utilities/Adapters/New-MappedCondenserAdapterFromGraph.ps1"

. "$PSScriptRoot/Utilities/Tooling/Ensure-DotNetLibraryFromNuget.ps1"
. "$PSScriptRoot/Utilities/Tooling/Invoke-TestGraph.ps1"
. "$PSScriptRoot/Utilities/Tooling/Test-IsClassDefined.ps1"
. "$PSScriptRoot/Utilities/Tooling/Invoke-VisualizeSignalTreeTrace.ps1"
. "$PSScriptRoot/Utilities/Tooling/Invoke-TraceSignalTree.ps1"
. "$PSScriptRoot/Utilities/Tooling/SovereignTrust.Foundation.Diagrams.ps1"

. "$PSScriptRoot/Utilities/IO/LocalFileSystem/Wait-ForFileUnlock.ps1"
. "$PSScriptRoot/Utilities/IO/LocalFileSystem/Read-JsonFileAsSignal.ps1"
. "$PSScriptRoot/Utilities/Json/Get-JsonObjectFromFile.ps1"

. "$PSScriptRoot/Utilities/Conduction/Convert-AgentAdaptersToConductor.ps1"
. "$PSScriptRoot/Utilities/Conduction/Get-AgentForConductor.ps1"
. "$PSScriptRoot/Utilities/Conduction/Start-BondingConductor.ps1"
. "$PSScriptRoot/Utilities/Json/Convert-JsonToHashtable.ps1"
. "$PSScriptRoot/Utilities/Json/Get-DictionaryValue.ps1"
. "$PSScriptRoot/Utilities/Json/Get-VirtualValueFromJson.ps1"

. "$PSScriptRoot/Utilities/Json/Parse-FilterSegment.ps1"
. "$PSScriptRoot/Utilities/Json/Resolve-FilteredArrayItem.ps1"

. "$PSScriptRoot/Utilities/Json/Resolve-PathFromDictionaryNoSignal.ps1"
. "$PSScriptRoot/Utilities/Json/Resolve-RegexPlaceholders.ps1"
. "$PSScriptRoot/Utilities/Json/Set-DictionaryValue.ps1"

. "$PSScriptRoot/Utilities/Graph/Resolve-PathFormulaGraph.ps1"
. "$PSScriptRoot/Utilities/Graph/Resolve-PathFormulaGraphForModule.ps1"
. "$PSScriptRoot/Utilities/Graph/Resolve-PathFormulaGraphForPublisher.ps1"
. "$PSScriptRoot/Utilities/Graph/Resolve-PathFormulaGraphCondenserAdapter.ps1"

# Export public utility functions
Export-ModuleMember -Function Convert-AgentAdaptersToConductor
Export-ModuleMember -Function Get-AgentForConductor
Export-ModuleMember -Function Start-BondingConductor
Export-ModuleMember -Function Start-BondingConduction
Export-ModuleMember -Function Add-PathToDictionary
Export-ModuleMember -Function Convert-JsonToHashtable
Export-ModuleMember -Function Get-DictionaryValue
Export-ModuleMember -Function Get-VirtualValueFromJson
Export-ModuleMember -Function Load-JsonObjectFromFile

Export-ModuleMember -Function Parse-FilterSegment
Export-ModuleMember -Function Resolve-FilteredArrayItem

Export-ModuleMember -Function Resolve-PathFromDictionary
Export-ModuleMember -Function Resolve-PathFromDictionaryNoSignal
Export-ModuleMember -Function Resolve-RegexPlaceholders
Export-ModuleMember -Function Set-DictionaryValue
Export-ModuleMember -Function Ensure-DotNetLibraryFromNuget
Export-ModuleMember -Function Invoke-TestGraph
#Export-ModuleMember -Function Test-IsClassDefined
Export-ModuleMember -Function Invoke-VisualizeSignalTreeTrace
Export-ModuleMember -Function Invoke-TraceSignalTree

Export-ModuleMember -Function Get-JsonObjectFromFile
Export-ModuleMember -Function Wait-ForFileUnlock
Export-ModuleMember -Function Read-JsonFileAsSignal

Export-ModuleMember -Function  Resolve-DependencyModuleFromGraph
Export-ModuleMember -Function  Register-AdapterToMappedSlot
Export-ModuleMember -Function  Register-ModuleLoaded
Export-ModuleMember -Function  Resolve-AdaptersFromJacket
Export-ModuleMember -Function  Resolve-ConductorAdapters
Export-ModuleMember -Function  Test-ModuleLoaded

Export-ModuleMember -Function  Resolve-PathFormulaGraph
Export-ModuleMember -Function  Resolve-PathFormulaGraphForModule
Export-ModuleMember -Function  Resolve-PathFormulaGraphForPublisher
Export-ModuleMember -Function  Resolve-PathFormulaGraphCondenserAdapter
