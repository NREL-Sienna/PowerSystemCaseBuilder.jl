using Test
using Logging
using DataStructures
using Dates
using TimeSeries
using InfrastructureSystems
const IS = InfrastructureSystems
using PowerSystems
const PSY = PowerSystems
using PowerSystemCaseBuilder
const PSB = PowerSystemCaseBuilder

@testset "Test Serializtion/De-Serializtion" begin
    system_catelog = SystemCatalog(SYSTEM_CATALOG)
    for (type, descriptor_dict) in system_catelog.data
        for (name, descriptor) in descriptor_dict
            name == "c_sys5_hybrid" && continue
            for forecasts in [true, false], reserves in [true, false]
                # build a new system from scratch
                sys = build_system(
                    type,
                    name;
                    add_forecasts = forecasts,
                    add_reserves = reserves,
                    force_build = true,
                )
                @test isa(sys, System)
                # build a new system from json
                @test PSB.is_serialized(name, forecasts, reserves)
                sys2 = build_system(
                    type,
                    name;
                    add_forecasts = forecasts,
                    add_reserves = reserves,
                )
                @test isa(sys2, System)

                PSB.clear_serialized_system(name)
                @test !PSB.is_serialized(name, forecasts, reserves)
            end
        end
    end
end
