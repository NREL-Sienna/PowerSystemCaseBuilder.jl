PSID_BUILD_TESTS = Dict(
    "psid_psse_test_avr" => (:avr_type, PSB.AVAILABLE_PSID_PSSE_AVRS_TEST),
    "psid_psse_test_tg" => (:tg_type, PSB.AVAILABLE_PSID_PSSE_TGS_TEST),
    "psid_psse_test_gen" => (:gen_type, PSB.AVAILABLE_PSID_PSSE_GENS_TEST),
    "psid_psse_test_pss" => (:pss_type, PSB.AVAILABLE_PSID_PSSE_PSS_TEST),
)

@testset "Test Serialization/De-Serialization PSID Tests" begin
    system_catalog = SystemCatalog(SYSTEM_CATALOG)
    for case_type in [PSIDTestSystems, PSIDSystems]
        for (name, descriptor) in system_catalog.data[case_type]
            # build a new system from scratch
            if haskey(PSID_BUILD_TESTS, name)
                args = PSID_BUILD_TESTS[name]
                for dyn_type in args[2]
                    sys = build_system(
                        case_type,
                        name;
                        force_build = true,
                        args[1] => dyn_type,
                    )
                    @test isa(sys, System)
                    # build a new system from json
                    @test PSB.is_serialized("$(name)_$(dyn_type)")
                    sys2 = build_system(case_type, name; (args[1] => dyn_type))
                    @test isa(sys2, System)

                    PSB.clear_serialized_system(name)
                    @test !PSB.is_serialized(name)
                end
            else
                sys = build_system(case_type, name; force_build = true)
                @test isa(sys, System)
                # build a new system from json
                @test PSB.is_serialized(name)
                sys2 = build_system(case_type, name;)
                @test isa(sys2, System)

                PSB.clear_serialized_system(name)
                @test !PSB.is_serialized(name)
            end
        end
    end
end
