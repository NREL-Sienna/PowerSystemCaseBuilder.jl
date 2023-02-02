# PowerSystemCaseBuilder.jl

[![Master - CI](https://github.com/NREL-SIIP/PowerSystemCaseBuilder.jl/workflows/Master%20-%20CI/badge.svg)](https://github.com/NREL-SIIP/PowerSystemCaseBuilder.jl/actions/workflows/master-tests.yml)
[![codecov](https://codecov.io/gh/NREL-SIIP/PowerSystemCaseBuilder.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/NREL-SIIP/PowerSystemCaseBuilder.jl)
[![PowerSystemCaseBuilder.jl Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/PowerSystemCaseBuilder)](https://pkgs.genieframework.com?packages=PowerSystemCaseBuilder)

## Show all systems for all categories.

```julia
using PowerSystemCaseBuilder

show_systems()
```

## Show all categories.

```julia
using PowerSystemCaseBuilder

show_categories()
```

## Show all systems for one category.

```julia
using PowerSystemCaseBuilder

show_systems(SIIPExampleSystems)
```

## Build a system

```julia
sys = build_system(SIIPExampleSystems, "5_bus_hydro_ed_sys")
```
