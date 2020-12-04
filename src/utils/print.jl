function Base.summary(sys::SystemDescriptor)
    return "System $(get_name(sys)) : $(get_description(sys)))"
end

function Base.show(io::IO, sys::SystemDescriptor)
    println(io, "$(get_name(sys)) : $(get_description(sys))")
end
