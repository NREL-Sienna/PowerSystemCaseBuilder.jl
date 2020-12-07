module PowerSystemBuilder

# exports
export SystemCategorys
export SystemBuildStats
export SystemDescriptor
export build_system

export get_name
export get_description
export get_category
export get_raw_data
export get_build_function
export get_serialized_file
export get_stats

export set_stats!
export update_serialized!
export update_stats!
export is_serialized
export get_serialzed_file_name
export get_system_descriptor
export avg_deserialize_time

export parse_system_descriptor
export parse_system_library
export parse_build_function

# export deserialize
# export serialize
export check_for_serialized_descriptor
export clear_serialized_system_library
export make_system_label
export clear_serialized_system

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

include("definations.jl")
include("label.jl")
include("system_library.jl")


include("structs/SystemBuildStats.jl")
include("structs/SystemDescriptor.jl")

include("utils/print.jl")
include("utils/parse.jl")
include("utils/utils.jl")

include("serialize.jl")
include("deserialize.jl")

include("build_system.jl")

end # module
