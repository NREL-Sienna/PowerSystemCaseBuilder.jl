function Base.summary(sys::SystemDescriptor)
    return "System $(get_name(sys)) : $(get_description(sys)))"
end

function Base.show(io::IO, sys::SystemDescriptor)
    println(io, "$(get_name(sys)) : $(get_description(sys))")
end

function Base.show(io::IO, sys::SystemCatalog)
    println(io, "SystemCatalog")
    println(io, "======")
    println(io, "Num Systems: $(get_total_system_count(sys))\n")
    df = DataFrames.DataFrame(; Name = [], Count = [])
    for (category, dict) in sys.data
        # println(io, "$(category) : $(length(dict))")
        push!(df, (category, length(dict)))
    end
    show(df; allrows = true)
end

function list_systems(sys::SystemCatalog, category::Type{<:SystemCategory}; kwargs...)
    descriptors = get_system_descriptors(category, sys)
    sort!(descriptors; by = x -> x.name)
    header = ["Name", "Descriptor"]
    data = Array{Any, 2}(undef, length(descriptors), length(header))
    for (i, d) in enumerate(descriptors)
        data[i, 1] = get_name(d)
        data[i, 2] = get_description(d)
    end

    PrettyTables.pretty_table(stdout, data; header = header, alignment = :l, kwargs...)
end

show_categories() = println(join(string.(list_categories()), "\n"))

function show_systems(; kwargs...)
    catalog = SystemCatalog()
    show_systems(catalog; kwargs...)
end

function show_systems(category::Type{<:SystemCategory}; kwargs...)
    catalog = SystemCatalog()
    show_systems(catalog, category; kwargs...)
end

function show_systems(catalog::SystemCatalog; kwargs...)
    for category in list_categories(catalog)
        println("\nCategory: $category\n")
        list_systems(catalog, category)
    end
end

show_systems(s::SystemCatalog, c::Type{<:SystemCategory}; kwargs...) =
    list_systems(s, c; kwargs...)

function print_stats(data::SystemDescriptor)
    df = DataFrames.DataFrame(; Name = [], Value = [])
    stats = get_stats(data)
    for name in fieldnames(typeof(stats))
        push!(df, (name, getfield(stats, name)))
    end
    show(df; allrows = true)
end

function get_total_system_count(sys::SystemCatalog)
    len = 0
    for (category, dict) in sys.data
        len += length(dict)
    end
    return len
end
