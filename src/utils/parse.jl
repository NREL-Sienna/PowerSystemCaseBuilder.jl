function parse_build_function(string::AbstractString)
    return getfield(PowerSystemCaseBuilder, Symbol(string))
end

function parse_system_descriptor(data::Dict)
    sys_descriptor = SystemDescriptor(
        name = data["name"],
        description = data["description"],
        category = data["category"],
        raw_data = data["raw_data"],
        build_function = parse_build_function(data["build_function"]),
    )
    return sys_descriptor
end

function parse_system_library(filepath::AbstractString = SYSTEM_DESCRIPTORS_FILE)
    data = open(filepath) do io
        JSON3.read(io, Dict)
    end

    descriptors = SystemDescriptor[]
    for descriptor_dict in data["system_catalogue"]
        sys = parse_system_descriptor(descriptor_dict)
        push!(descriptors, sys)
    end

    return descriptors
end
