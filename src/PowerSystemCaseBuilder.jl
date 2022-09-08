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
export PSSEParsingTestSystems
export MatpowerTestSystems

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

abstract type PowerSystemCaseBuilderType <: IS.InfrastructureSystemsType end

abstract type SystemCategory <: PowerSystemCaseBuilderType end
struct PSYTestSystems <: SystemCategory end
struct PSSEParsingTestSystems <: SystemCategory end
struct MatpowerTestSystems <: SystemCategory end
struct PSITestSystems <: SystemCategory end
struct PSIDTestSystems <: SystemCategory end

struct PSISystems <: SystemCategory end
struct PSIDSystems <: SystemCategory end

# includes

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
