const PSID_BUILD_TESTS =
    ["psid_psse_test_avr", "psid_psse_test_tg", "psid_psse_test_gen", "psid_psse_test_pss"]

@testset "Test Serialization/De-Serialization PSID Tests" begin
    system_catalog = SystemCatalog(SYSTEM_CATALOG)
    for case_type in [PSIDTestSystems, PSIDSystems]
        for (name, descriptor) in system_catalog.data[case_type]
            supported_args_permutations = PSB.get_supported_args_permutations(descriptor)
            # build a new system from scratch
            if name in PSID_BUILD_TESTS
                for supported_arg in supported_args_permutations
                    sys = build_system(
                        case_type,
                        name;
                        force_build = true,
                        supported_arg...,
                    )
                    @test isa(sys, System)
                    # build a new system from json
                    @test PSB.is_serialized("$(name)_$(first(supported_arg)[2])")
                    sys2 = build_system(
                        case_type,
                        name;
                        supported_arg...,
                    )
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
