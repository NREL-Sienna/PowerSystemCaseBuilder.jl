@testset "Test data directory configuration" begin
    @test PSB.get_pstd_data_dir() == PSB.PSTD_ARTIFACT_PATH
    @test PSB.get_rts_data_dir() == PSB.RTS_ARTIFACT_PATH

    @test isdir(PSB.get_pstd_data_dir())
    @test isdir(PSB.get_rts_data_dir())

    empty_dir = mktempdir()
    PSB.with_pstd_data_dir!(empty_dir) do
        @test PSB.get_pstd_data_dir() == empty_dir
    end
    @test PSB.get_pstd_data_dir() == PSB.PSTD_ARTIFACT_PATH
    PSB.with_rts_data_dir!(empty_dir) do
        @test PSB.get_rts_data_dir() == empty_dir
    end
    @test PSB.get_rts_data_dir() == PSB.RTS_ARTIFACT_PATH

    PSB.set_pstd_data_dir!(empty_dir)
    @test PSB.get_pstd_data_dir() == empty_dir
    PSB.set_rts_data_dir!(empty_dir)
    @test PSB.get_rts_data_dir() == empty_dir

    PSB.reset_pstd_data_dir!()
    @test PSB.get_pstd_data_dir() == PSB.PSTD_ARTIFACT_PATH
    PSB.reset_rts_data_dir!()
    @test PSB.get_rts_data_dir() == PSB.RTS_ARTIFACT_PATH

    nonexistent_dir = joinpath(empty_dir, "DNE")
    PSB.with_pstd_data_dir!(nonexistent_dir) do
        @test_throws Exception PSB.get_pstd_data_dir()
    end
    PSB.with_rts_data_dir!(nonexistent_dir) do
        @test_throws Exception PSB.get_rts_data_dir()
    end
end
