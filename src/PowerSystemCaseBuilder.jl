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
export SPISystems

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
import JSON3
import SHA

using DocStringExtensions

@template (FUNCTIONS, METHODS) = """
                                 $(TYPEDSIGNATURES)
                                 $(DOCSTRING)
                                 """

const PSY = PowerSystems
const IS = InfrastructureSystems

abstract type PowerSystemCaseBuilderType <: IS.InfrastructureSystemsType end

"""
Supertype of categories that group test [`PowerSystems.System`](@extref)s for similar use
    cases

Current subtypes with example `System`s for running test simulations include:
- [`PSISystems`](@ref)
- [`PSIDSystems`](@ref)

Subtypes for testing other packages include:
- [`PSYTestSystems`](@ref)
- [`PSSEParsingTestSystems`](@ref)
- [`MatpowerTestSystems`](@ref)
- [`PSITestSystems`](@ref)
- [`PSIDTestSystems`](@ref)
"""
abstract type SystemCategory <: PowerSystemCaseBuilderType end

"""
Category of [`PowerSystems.System`](@extref)s for
[`PowerSystems.jl`](https://nrel-sienna.github.io/PowerSystems.jl/stable/) package testing.

!!! warning
    Not all `System`s are functional.
"""
struct PSYTestSystems <: SystemCategory end

"""
Category of [`PowerSystems.System`](@extref)s to test parsing PSSe .raw files. 

`System`s only include data for the power flow case.
"""
struct PSSEParsingTestSystems <: SystemCategory end

"""
Category of [`PowerSystems.System`](@extref)s to test parsing Matpower files.

`System`s only include data for the power flow case.
"""
struct MatpowerTestSystems <: SystemCategory end

"""
Category of [`PowerSystems.System`](@extref)s for
[`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/stable/) package testing.
    
!!! warning
    Not all `System`s are functional.
"""
struct PSITestSystems <: SystemCategory end

"""
Category of [`PowerSystems.System`](@extref)s for
[`PowerSimulationsDynamics.jl`](https://nrel-sienna.github.io/PowerSimulationsDynamics.jl/stable/)
package testing.

!!! warning
    Not all `System`s are functional.
"""
struct PSIDTestSystems <: SystemCategory end

"""
Category of example [`PowerSystems.System`](@extref)s for running
    [`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/stable/)
    operations problems and simulations.
"""
struct PSISystems <: SystemCategory end

"""
Category of example [`PowerSystems.System`](@extref)s for running
    [`PowerSimulationsDynamics.jl`](https://nrel-sienna.github.io/PowerSimulationsDynamics.jl/stable/)
    simulations.
"""
struct PSIDSystems <: SystemCategory end

"""
Category for SiennaPRASInterface.jl examples.
"""
struct SPISystems <: SystemCategory end

# includes

include("definitions.jl")
include("system_library.jl")

include("system_build_stats.jl")
include("system_descriptor.jl")
include("system_catalog.jl")

include("utils/download.jl")
include("utils/print.jl")
include("utils/utils.jl")
include("utils/spi_library_utils.jl")

include("build_system.jl")
include("system_descriptor_data.jl")

end # module
