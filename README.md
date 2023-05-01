# PowerSystemCaseBuilder.jl

[![Master - CI](https://github.com/NREL-Sienna/PowerSystemCaseBuilder.jl/workflows/Master%20-%20CI/badge.svg)](https://github.com/NREL-Sienna/PowerSystemCaseBuilder.jl/actions/workflows/master-tests.yml)
[![codecov](https://codecov.io/gh/NREL-Sienna/PowerSystemCaseBuilder.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/NREL-Sienna/PowerSystemCaseBuilder.jl)
[<img src="https://img.shields.io/badge/slack-@SIIP/PSB-blue.svg?logo=slack">](https://join.slack.com/t/nrel-sienna/shared_invite/zt-glam9vdu-o8A9TwZTZqqNTKHa7q3BpQ)
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

show_systems(PSISystems)
```

## Build a system

```julia
sys = build_system(PSISystems, "5_bus_hydro_ed_sys")
```
