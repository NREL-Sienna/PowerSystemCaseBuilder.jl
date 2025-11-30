function show_systems(sys::SystemCatalog, category::Type{<:SystemCategory}; kwargs...)
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
