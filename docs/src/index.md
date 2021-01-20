# PowerSystemCaseBuilder.jl

```@meta
CurrentModule = PowerSystemCaseBuilder
```

## Overview

`PowerSystemCaseBuilder.jl` is a [`Julia`](http://www.julialang.org) package that provides a library
of power systems test cases using `PowerSystems.jl` data model. `PowerSystemCaseBuilder.jl` is a 
simple tool to build power system's ranging from 5-bus systems to entire US grid for the purpose 
of testing or prototyping power system models. This package facilitates open sharing of large number of data sets for Power Systems modeling.

The main features include:

- Comprehensive and extensible library of power systems for modeling.
- Automated serialization/de-serialization of cateloged Systems.


`PowerSystemCaseBuilder.jl` is an active project under development, and we welcome your feedback,
suggestions, and bug reports.

**Note**: `PowerSystemCaseBuilder.jl` uses [`PowerSystems.jl`](https://github.com/NREL-SIIP/PowerSystems.jl)
as a utility library. For most users there is no need to import `PowerSystems.jl`.

## Installation

The latest stable release of PowerSystemCaseBuilder can be installed using the Julia package manager with

```julia
] add PowerSystemCaseBuilder
```

For the current development version, "checkout" this package with

```julia
] add PowerSystemCaseBuilder#master
```

------------
PowerSystemCaseBuilder has been developed as part of the Scalable Integrated Infrastructure Planning
(SIIP) initiative at the U.S. Department of Energy's National Renewable Energy
Laboratory ([NREL](https://www.nrel.gov/))
