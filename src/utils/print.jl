function Base.summary(sys::SystemDescriptor)
    return "System $(get_name(sys)) : $(get_description(sys)))"
end

function Base.show(io::IO, sys::SystemDescriptor)
    println(io, "$(get_name(sys)) : $(get_description(sys))")
end

function list_system(data::Array{SystemDescriptor})
    df = DataFrames.DataFrame(Name = [], Category = [], Descriptor = [], )
    for d in data
        push!(df, (get_name(d), get_category(d), get_description(d)))
    end
    show(df, allrows=true, truncate=92, rowlabel = :Name)
end
