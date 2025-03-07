# Exploring and Loading Power System Data Sets

## Show all systems for all categories.

```@example pscb
using PowerSystemCaseBuilder
using PowerSystems
```

## Show all categories.

[`show_categories`](@ref)
```@example pscb
show_categories()
```

## Show all systems for one category.
[`show_systems`](@ref)

```@example pscb
show_systems(PSISystems)
```

## Build a system
[`build_system`](@ref)
```@example pscb
sys = build_system(PSISystems, "5_bus_hydro_ed_sys")
```
