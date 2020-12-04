function deserialize(file_path::AbstractString = SERIALIZED_SYSTEM_DESCRIPTORS_FILE)
    data = open(file_path) do io
        JSON3.read(io, Array)
    end
    deserialize_data = SystemDescriptor[]
    for sys in data
        push!(deserialize_data, IS.deserialize(SystemDescriptor, sys))
    end
    return deserialize_data
end
