@testset "Test Serialization/De-Serialization PSI Cases" begin
    system_catalog = SystemCatalog(SYSTEM_CATALOG)
    for (name, descriptor) in system_catalog.data[PSITestSystems]
        # build a new system from scratch
        for forecasts in [true, false], reserves in [true, false]
            sys = build_system(
                PSITestSystems,
                name;
                add_forecasts = forecasts,
                add_reserves = reserves,
                force_build = true,
            )

            @test isa(sys, System)
            # build a new system from json
            @test PSB.is_serialized(name, forecasts, reserves)
            sys2 = build_system(
                PSITestSystems,
                name;
                add_forecasts = forecasts,
                add_reserves = reserves,
                force_build = true,
            )
            @test isa(sys2, System)

            PSB.clear_serialized_system(name)
            @test !PSB.is_serialized(name, forecasts, reserves)
        end
    end
end
