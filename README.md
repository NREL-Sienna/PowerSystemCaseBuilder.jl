# PowerSystemCaseBuilder.jl

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
