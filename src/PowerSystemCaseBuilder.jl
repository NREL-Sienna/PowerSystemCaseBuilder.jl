module PowerSystemCaseBuilder

# exports
export SystemCategory
export SystemBuildStats
export SystemDescriptor

export SystemCatalog
export PSYTestSystems
export PSITestSystems
export SIIPExampleSystems
export PSIDTestSystems
export PSSETestSystems
export MatPowerTestSystems

export build_system
export list_categories
export show_categories
export list_systems
export show_systems

export SYSTEM_CATALOG

# imports
import InfrastructureSystems
import InfrastructureSystems: InfrastructureSystemsType
import PowerSystems
import DataStructures: SortedDict
import DataFrames
import PrettyTables

#TimeStamp Management Imports
import TimeSeries
import Dates
import Dates: DateTime, Hour, Minute
import CSV
import HDF5
import DataFrames: DataFrame
const PSY = PowerSystems
const IS = InfrastructureSystems

# includes
abstract type PowerSystemCaseBuilderType <: IS.InfrastructureSystemsType end

include("definitions.jl")
include("system_library.jl")

include("system_build_stats.jl")
include("system_descriptor.jl")
include("system_catalog.jl")



include("utils/download.jl")
include("utils/print.jl")
include("utils/utils.jl")

include("build_system.jl")
include("system_descriptor_data.jl")

end # module
