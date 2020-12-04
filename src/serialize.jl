function check_for_serialized_descriptor()
    return isfile(SERIALIZED_SYSTEM_DESCRIPTORS_FILE)
end

function serialize(data::Array{SystemDescriptor}, file_path::AbstractString = SERIALIZED_SYSTEM_DESCRIPTORS_FILE)
    serialize_data = []
    for sys in data
        push!(serialize_data, IS.serialize(sys))
    end
    open(file_path, "w") do io
        JSON3.write(io, serialize_data)
    end
    return
end


function IS.serialize_struct(val::T) where {T <: SystemBuildStats}
    @debug "serialize_struct" val T
    data = Dict{String, Any}(string(name) => IS.serialize(getfield(val, name)) for name in fieldnames(T))
    IS.add_serialization_metadata!(data, T)
    return data
end
