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

export PSISystems
export PSIDSystems

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
import LazyArtifacts

const PSY = PowerSystems
const IS = InfrastructureSystems

abstract type PowerSystemCaseBuilderType <: IS.InfrastructureSystemsType end

abstract type SystemCategory <: PowerSystemCaseBuilderType end

"""
Category for PowerSystems.jl testing. Not all cases are funcional
"""
struct PSYTestSystems <: SystemCategory end

"""
Category to test parsing of files in PSSe raw format. Only include data for the power flow case.
"""
struct PSSEParsingTestSystems <: SystemCategory end

"""
Category to test parsing of files in matpower format. Only include data for the power flow case.
"""
struct MatpowerTestSystems <: SystemCategory end

"""
Category for PowerSimulations.jl testing. Not all cases are funcional
"""
struct PSITestSystems <: SystemCategory end

"""
Category for PowerSimulationsDynamics.jl testing. Not all cases are funcional
"""
struct PSIDTestSystems <: SystemCategory end

"""
Category for PowerSimulations.jl examples.
"""
struct PSISystems <: SystemCategory end
"""
Category for PowerSimulationsDynamics.jl examples.
"""
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
