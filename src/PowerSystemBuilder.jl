module PowerSystemBuilder

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

export SYSTEM_CATELOG

export get_name
export get_description
export get_category
export get_raw_data
export get_build_function
export get_download_function
export get_stats

export set_name!
export set_description!
export set_category!
export set_raw_data!
export set_build_function!
export set_download_function!
export set_stats!
export update_stats!

export is_serialized
export get_serialized_filepath
export get_serialization_dir
export avg_deserialize_time

export get_system_descriptor
export get_system_descriptors

export parse_system_descriptor
export parse_system_library
export parse_build_function

export check_serailized_storage
export verify_storage_dir
export clear_serialized_system
export list_systems
export print_stats

# imports
import InfrastructureSystems
import InfrastructureSystems: InfrastructureSystemsType
import PowerSystems
import PowerSimulations
import DataStructures: SortedDict
import DataFrames
import JSON3

#TimeStamp Management Imports
import TimeSeries
import Dates
import Dates: DateTime, Hour

const PSY = PowerSystems
const PSI = PowerSimulations
const IS = InfrastructureSystems

# includes
abstract type PowerSystemBuilderType <: IS.InfrastructureSystemsType end

include("definitions.jl")
include("system_library.jl")

include("system_build_stats.jl")
include("system_descriptor.jl")
include("system_catelog.jl")

include("system_descriptor_data.jl")
include("utils/print.jl")
include("utils/parse.jl")
include("utils/utils.jl")
include("build_system.jl")

end # module
