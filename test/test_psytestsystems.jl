@testset "Test Serialization/De-Serialization PSY Tests" begin
    system_catalog = SystemCatalog(SYSTEM_CATALOG)
    for (name, descriptor) in system_catalog.data[PSYTestSystems]
        # build a new system from scratch
        for forecasts in [true, false]
            sys = build_system(PSYTestSystems, name;
            add_forecasts = forecasts,
            force_build = true)

            @test isa(sys, System)
            # build a new system from json
            @test PSB.is_serialized(name, forecasts, false)
            sys2 = build_system(
                PSYTestSystems,
                name;
                add_forecasts = forecasts,
                force_build = true,
            )
            @test isa(sys2, System)

            PSB.clear_serialized_system(name)
            @test !PSB.is_serialized(name, forecasts, false)
        end
    end
end
