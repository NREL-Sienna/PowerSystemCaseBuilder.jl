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

PSID_BUILD_TESTS = Dict(
    "psid_psse_test_avr" => (:avr_type, PSB.AVAILABLE_PSID_PSSE_AVRS_TEST),
    "psid_psse_test_tg" => (:tg_type, PSB.AVAILABLE_PSID_PSSE_TGS_TEST),
    "psid_psse_test_gen" => (:gen_type, PSB.AVAILABLE_PSID_PSSE_GENS_TEST),
    "psid_psse_test_pss" => (:pss_type, PSB.AVAILABLE_PSID_PSSE_PSS_TEST),
)

@testset "Test Serialization/De-Serialization" begin
    system_catalog = SystemCatalog(SYSTEM_CATALOG)
    for (type, descriptor_dict) in system_catalog.data
        for (name, descriptor) in descriptor_dict
            # build a new system from scratch
            if type <: PSIDTestSystems && haskey(PSID_BUILD_TESTS, name)
                args = PSID_BUILD_TESTS[name]
                for dyn_type in args[2]
                    sys =
                        build_system(type, name; force_build = true, (args[1] => dyn_type))
                    @test isa(sys, System)
                    # build a new system from json
                    @test PSB.is_serialized("$(name)_$(dyn_type)", false, false)
                    sys2 = build_system(
                        type,
                        name;
                        (args[1] => dyn_type),
                        #add_forecasts = forecasts,
                        #add_reserves = reserves,
                    )
                    @test isa(sys2, System)

                    PSB.clear_serialized_system(name)
                    @test !PSB.is_serialized(name, false, false)
                end
            elseif type <: PSIDTestSystems && !haskey(PSID_BUILD_TESTS, name)
                #TO ADD PREVIOUS FUNCTION
                sys = build_system(type, name; force_build = true)
                @test isa(sys, System)
                # build a new system from json
                @test PSB.is_serialized(name, false, false)
                sys2 = build_system(
                    type,
                    name;
                    #add_forecasts = forecasts,
                    #add_reserves = reserves,
                )
                @test isa(sys2, System)

                PSB.clear_serialized_system(name)
                @test !PSB.is_serialized(name, false, false)
            end
        end
    end
end

#=
    for forecasts in [true, false], reserves in [true, false]
    sys = build_system(
        type,
        name;
        add_forecasts = forecasts,
        add_reserves = reserves,
        force_build = true,
    )
=#
