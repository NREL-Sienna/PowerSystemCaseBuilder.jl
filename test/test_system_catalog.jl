@testset "list systems" begin
    matpower_systems = list_systems(MatpowerTestSystems)
    c = SystemCatalog()
    @test Set(keys(c.data[MatpowerTestSystems])) == Set(matpower_systems)
    delete!(c.data, MatpowerTestSystems)
    @test_throws ErrorException list_systems(c, MatpowerTestSystems)
end
