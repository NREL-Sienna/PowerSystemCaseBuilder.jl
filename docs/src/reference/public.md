# Public API Reference

## Reading the Catalog

```@autodocs
Modules = [PowerSystemCaseBuilder]
Pages   = ["print.jl"]
Public = true
Private = false
```

## Categories of `System`s

```@docs
SystemCategory
```
```@autodocs
Modules = [PowerSystemCaseBuilder]
Pages   = ["PowerSystemCaseBuilder.jl"]
Public = true
Private = false
Filter = t -> !(t in [SystemCategory])
```

## Building a `System`

```@autodocs
Modules = [PowerSystemCaseBuilder]
Pages   = ["build_system.jl"]
Public = true
Private = false
```