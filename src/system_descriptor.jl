struct SystemArgument
    name::Symbol
    default::Any
    allowed_values::Set{<:Any}

    function SystemArgument(name, default, allowed_values)
        isempty(allowed_values) && error("allowed_values cannot be empty")
        new(name, default, allowed_values)
    end
end

function SystemArgument(;
    name,
    default = nothing,
    allowed_values,
)
    return SystemArgument(
        name,
        default,
        allowed_values,
    )
end

get_name(arg::SystemArgument) = arg.name
get_default(arg::SystemArgument) = arg.default
get_allowed_values(arg::SystemArgument) = arg.allowed_values

set_name(arg::SystemArgument, name::Symbol) = arg.name = name
set_default(arg::SystemArgument, default::Any) = arg.default = default

mutable struct SystemDescriptor <: PowerSystemCaseBuilderType
    name::AbstractString
    description::AbstractString
    category::Type{<:SystemCategory}
    raw_data::Union{AbstractString, Tuple{Base.RefValue{Union{Nothing, String}}, String}}  # TODO
    build_function::Function
    download_function::Union{Nothing, Function}
    stats::Union{Nothing, SystemBuildStats}
    supported_arguments::Vector{SystemArgument}
end

function SystemDescriptor(;
    name,
    description,
    category,
    build_function,
    raw_data = "",
    download_function = nothing,
    stats = nothing,
    supported_arguments = Vector{SystemArgument}(),
)
    return SystemDescriptor(
        name,
        description,
        category,
        raw_data,
        build_function,
        download_function,
        stats,
        supported_arguments,
    )
end

_process_raw_data(raw_data::AbstractString) = raw_data

function _process_raw_data(raw_data::Tuple{Ref, AbstractString})
    root_ref, subpath = raw_data
    @show root_ref
    @show root_ref[]
    return joinpath(root_ref[], subpath)
end

get_name(v::SystemDescriptor) = v.name
get_description(v::SystemDescriptor) = v.description
get_category(v::SystemDescriptor) = v.category
get_raw_data(v::SystemDescriptor) = _process_raw_data(v.raw_data)
get_build_function(v::SystemDescriptor) = v.build_function
get_download_function(v::SystemDescriptor) = v.download_function
get_stats(v::SystemDescriptor) = v.stats
get_supported_arguments(v::SystemDescriptor) = v.supported_arguments
get_supported_argument_names(v::SystemDescriptor) =
    Set([x.name for x in v.supported_arguments])

function get_default_arguments(v::SystemDescriptor)
    Dict{Symbol, Any}(
        x.name => x.default for x in v.supported_arguments if !isnothing(x.default)
    )
end

function get_supported_args_permutations(v::SystemDescriptor)
    keys_arr = get_supported_argument_names(v)
    permutations = Dict{Symbol, Any}[]
    supported_arguments = get_supported_arguments(v)

    if !isnothing(supported_arguments)
        comprehensive_set = Set()
        for arg in get_supported_arguments(v)
            set = get_allowed_values(arg)
            comprehensive_set = union(comprehensive_set, set)
        end

        for values in
            Iterators.product(Iterators.repeated(comprehensive_set, length(keys_arr))...)
            permutation = Dict{Symbol, Any}()
            for (i, key) in enumerate(keys_arr)
                permutation[key] = values[i]
            end
            if !isempty(permutation)
                push!(permutations, permutation)
            end
        end
    end

    return permutations
end

set_name!(v::SystemDescriptor, value::String) = v.name = value
set_description!(v::SystemDescriptor, value::String) = v.description = value
set_category!(v::SystemDescriptor, value::Type{<:SystemCategory}) = v.category = value
set_raw_data!(v::SystemDescriptor, value::String) = v.raw_data = value
set_build_function!(v::SystemDescriptor, value::Function) = v.build_function = value
set_download_function!(v::SystemDescriptor, value::Function) = v.download_function = value
set_stats!(v::SystemDescriptor, value::SystemBuildStats) = v.stats = value

update_stats!(v::SystemDescriptor, deserialize_time::Float64) =
    update_stats!(v.stats, deserialize_time)

"""
Return the keyword arguments passed by the user that apply to the descriptor.
Add any default values for fields not passed by the user.
"""
function filter_descriptor_kwargs(descriptor::SystemDescriptor; kwargs...)
    case_arg_names = get_supported_argument_names(descriptor)
    case_kwargs = get_default_arguments(descriptor)
    for (key, val) in kwargs
        if key in case_arg_names
            case_kwargs[key] = val
        end
    end
    return case_kwargs
end
