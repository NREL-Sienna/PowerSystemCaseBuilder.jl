# PowerSystemCaseBuilder.jl

[![Main - CI](https://github.com/NREL-Sienna/PowerSystemCaseBuilder.jl/workflows/Main%20-%20CI/badge.svg)](https://github.com/NREL-Sienna/PowerSystemCaseBuilder.jl/actions/workflows/main-tests.yml)
[![codecov](https://codecov.io/gh/NREL-Sienna/PowerSystemCaseBuilder.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/NREL-Sienna/PowerSystemCaseBuilder.jl)
[![Documentation Build](https://github.com/NREL-Sienna/PowerSystemCaseBuilder.jl/workflows/Documentation/badge.svg?)](https://nrel-sienna.github.io/PowerSystemCaseBuilder.jl/stable)
[<img src="https://img.shields.io/badge/slack-@Sienna/PSB-sienna.svg?logo=slack">](https://join.slack.com/t/nrel-sienna/shared_invite/zt-glam9vdu-o8A9TwZTZqqNTKHa7q3BpQ)
[![PowerSystemCaseBuilder.jl Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/PowerSystemCaseBuilder)](https://pkgs.genieframework.com?packages=PowerSystemCaseBuilder)


The `PowerSystemCaseBuilder.jl` package provides a library
of over 200 power systems test cases using the
[`PowerSystems.jl`](https://nrel-sienna.github.io/PowerSystems.jl/stable/) data model.

Power system test cases are suitable for simulating and prototyping with
[`PowerSimulations.jl`](https://github.com/NREL-Sienna/PowerSimulations.jl) and
[`PowerSimulationsDynamics.jl`](https://github.com/NREL-Sienna/PowerSimulationsDynamics.jl).

For information on using the package, see the [stable documentation](https://nrel-sienna.github.io/PowerSystemCaseBuilder.jl/stable/). Use the [in-development documentation](https://nrel-sienna.github.io/PowerSystemCaseBuilder.jl/dev/) for the version of the documentation which contains the unreleased features.

## Development

Contributions to the development and enhancement of PowerSystemCaseBuilder are welcome. Please see
[CONTRIBUTING.md](https://github.com/NREL/PowerSystemCaseBuilder.jl/blob/main/CONTRIBUTING.md) for
code contribution guidelines.

## License

PowerSystems is released under a BSD [license](https://github.com/NREL/PowerSystems.jl/blob/main/LICENSE).
PowerSystems has been developed as part of the Scalable Integrated Infrastructure Planning (SIIP)
initiative at the U.S. Department of Energy's National Renewable Energy Laboratory ([NREL](https://www.nrel.gov/)) Software Record SWR-23-105.