mutable struct SystemDescriptor <: PowerSystemBuilderType
    name::AbstractString
    description::AbstractString
    category::SystemCategorys.SystemCategory
    raw_data::AbstractString
    build_function::Function
    serialized::Dict{String, AbstractString}
    stats::Union{Nothing, SystemBuildStats}
end

function SystemDescriptor(
    name::AbstractString,
    description::AbstractString,
    category::SystemCategorys.SystemCategory,
    raw_data::AbstractString,
    build_function::Function
)
    return SystemDescriptor(
        name,
        description,
        category,
        raw_data,
        build_function,
        nothing,
        Dict{String, AbstractString}(),
    )
end

function SystemDescriptor(;
    name,
    description,
    category,
    raw_data,
    build_function,
    serialized = Dict{String, AbstractString}(),
    stats = nothing,
)
    return SystemDescriptor(
        name,
        description,
        category,
        raw_data,
        build_function,
        serialized,
        stats,
    )
end

get_name(v::SystemDescriptor) = v.name
get_description(v::SystemDescriptor) = v.description
get_category(v::SystemDescriptor) = v.category
get_raw_data(v::SystemDescriptor) = v.raw_data
get_build_function(v::SystemDescriptor) = v.build_function
get_serialized_file(v::SystemDescriptor, key::String) = v.serialized[key]
get_stats(v::SystemDescriptor) = v.stats

set_stats!(v::SystemDescriptor, value::SystemBuildStats) = v.stats = value
update_serialized!(v::SystemDescriptor, key::String, filepath::AbstractString) = v.serialized[key] = filepath
update_stats!(v::SystemDescriptor, deserialize_time::Float64) = update_stats!(v.stats, deserialize_time)
is_serialized(v::SystemDescriptor, key::String) = haskey(v.serialized, key)

function get_serialzed_file_name(v::SystemDescriptor, key::String)
    file_name = "$(v.name)_$(key).json"
    return file_name
end

function get_system_descriptor(data::Array{SystemDescriptor}, name::String)
    sys = filter(x -> x.name == name, data)
    if isempty(sys)
        error("invalid system name: $name")
    else
        return sys[1]
    end
end
