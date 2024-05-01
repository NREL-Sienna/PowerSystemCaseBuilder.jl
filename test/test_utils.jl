@testset "Test _is_system_hash_name" begin
    @test PSB._is_system_hash_name(
        "16bed6368b8b1542cd6eb87f5bc20dc830b41a2258dde40438a75fa701d24e9a",
    )
    @test !PSB._is_system_hash_name("1234ghij")
end

@testset "Test clear_all_serialized_systems" begin
    path = mktempdir()
    dir1 = joinpath(path, "1234abc")
    dir2 = joinpath(path, "5678def")
    bystander_dir = mkpath(joinpath(path, "mnop"))
    bystander_file = joinpath(path, "1234abc.txt")
    touch(bystander_file)
    PSB.clear_all_serialized_systems(path)
    @test !isdir(dir1)
    @test !isdir(dir2)
    @test isdir(bystander_dir)
    @test isfile(bystander_file)
end
