@testset "Test _is_system_hash_name" begin
    @test PSB._is_system_hash_name(
        "16bed6368b8b1542cd6eb87f5bc20dc830b41a2258dde40438a75fa701d24e9a",
    )
    @test !PSB._is_system_hash_name(
        "xyzed6368b8b1542cd6eb87f5bc20dc830b41a2258dde40438a75fa701d24e9a",
    )
end

@testset "Test clear_all_serialized_systems" begin
    path = mktempdir()
    dir1 =
        joinpath(path, "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
    dir2 = joinpath(path, "5678def")
    bystander_dir = mkpath(
        joinpath(path, "xyzed6368b8b1542cd6eb87f5bc20dc830b41a2258dde40438a75fa701d24e9a"),
    )
    bystander_file =
        joinpath(path, "61952bcb9d33df3fee16757f69ea29d22806c0f55677f5e503557a77ec50d22a")
    touch(bystander_file)
    PSB.clear_all_serialized_systems(path)
    @test !isdir(dir1)
    @test !isdir(dir2)
    @test isdir(bystander_dir)
    @test isfile(bystander_file)
end

@testset "test show" begin
    # no actual @test here--just making sure they run without error.
    redirect_stdout(devnull) do
        show_systems(MatpowerTestSystems)
        show_systems()
        c = SystemCatalog()
        category = collect(list_categories(c))[2]
        show_systems(c, category)
        show_systems(c)

        show_categories()
        show_categories(c)
    end
end
