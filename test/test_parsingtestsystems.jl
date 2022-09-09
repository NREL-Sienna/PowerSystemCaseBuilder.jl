@testset "Test Serialization/De-Serialization Parsing System Tests" begin
    system_catalog = SystemCatalog(SYSTEM_CATALOG)
    for case_type in [PSSEParsingTestSystems, MatpowerTestSystems]
        for (name, descriptor) in system_catalog.data[case_type]
            # build a new system from scratch
            sys = build_system(case_type, name;
            force_build = true)

            @test isa(sys, System)
            # build a new system from json
            @test PSB.is_serialized(name, false, false)
            sys2 = build_system(
                case_type,
                name;
                force_build = true,
            )
            @test isa(sys2, System)

            PSB.clear_serialized_system(name)
            @test !PSB.is_serialized(name, false, false)
        end
    end
end
