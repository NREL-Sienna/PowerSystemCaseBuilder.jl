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
    df = DataFrames.DataFrame(Name = [], Count = [],)
    for (category,dict) in sys.data
        # println(io, "$(category) : $(length(dict))")
        push!(df, (category, length(dict) ))
    end
    show(df, allrows=true)
end

function list_systems(sys::SystemCatalog, category::Type{<:SystemCategory})
    df = DataFrames.DataFrame(Name = [], Descriptor = [])
    descriptors = get_system_descriptors(category, sys)
    for d in descriptors
        push!(df, (get_name(d), get_description(d)))
    end
    show(df, allrows=true, truncate=92, rowlabel = :Name)
end

function print_stats(data::SystemDescriptor)
    df = DataFrames.DataFrame(Name = [], Value = [])
    stats = get_stats(data)
    for name in fieldnames(typeof(stats))
        push!(df, (name, getfield(stats, name)))
    end
    show(df, allrows=true)
end

function get_total_system_count(sys::SystemCatalog)
    len = 0
    for (category,dict) in sys.data
        len += length(dict)
    end
    return len
end
