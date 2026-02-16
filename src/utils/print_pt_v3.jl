function show_systems(sys::SystemCatalog, category::Type{<:SystemCategory}; kwargs...)
    descriptors = get_system_descriptors(category, sys)
    sort!(descriptors; by = x -> x.name)
    column_labels = ["Name", "Descriptor"]
    data = Array{Any, 2}(undef, length(descriptors), length(column_labels))
    for (i, d) in enumerate(descriptors)
        data[i, 1] = get_name(d)
        data[i, 2] = get_description(d)
    end

    PrettyTables.pretty_table(
        stdout,
        data;
        column_labels = column_labels,
        alignment = :l,
        fit_table_in_display_horizontally = false,  # show full column content (no horizontal truncation)
        fit_table_in_display_vertically = false,   # show all rows (no vertical truncation)
        kwargs...,
    )
end
