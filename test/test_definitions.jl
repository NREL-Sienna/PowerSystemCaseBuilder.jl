@testset "Test data directory configuration" begin
    td = mktempdir()
    withenv(PSB.DATA_DIR_KEY => td) do
        the_data_dir = PSB.get_data_dir()
        @test isdir(the_data_dir)
        @test the_data_dir == td
    end
    withenv(PSB.DATA_DIR_KEY => joinpath(td, "DNE")) do
        @test_throws ErrorException PSB.get_data_dir()
    end
    withenv(PSB.DATA_DIR_KEY => nothing) do
        the_data_dir = PSB.get_data_dir()
        @test isdir(the_data_dir)
        @test occursin("PowerSystemsTestData-2.0", the_data_dir)
    end
    @test isdir(PSB.DATA_DIR)
end
