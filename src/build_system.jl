"""
build_system(
    category::Type{<:SystemCategory},
    name::String,
    print_stat::Bool = false;
    kwargs...,
)

Accepted Key Words:
- `force_build::Bool`: `true` runs entire build process, `false` (Default) uses deserializiation if possible
- `skip_serialization::Bool`: Default is `false`
- `system_catalog::SystemCatalog`
- `assign_new_uuids::Bool`: Assign new UUIDs to the system and all components if
   deserialization is used. Default is `true`.
"""
function build_system(
    category::Type{<:SystemCategory},
    name::String,
    print_stat::Bool = false;
    force_build::Bool = false,
    assign_new_uuids::Bool = false,
    skip_serialization::Bool = false,
    system_catalog::SystemCatalog = SystemCatalog(SYSTEM_CATALOG),
    kwargs...,
)
    #Needs to be a dictionary
    sys_kwargs = filter_kwargs(; kwargs...)
    sys_args = Dict(symbol(k) => v for (k, v) in sys_kwargs) 
    
    case_kwargs = filter_case_kwargs(; kwargs...)
    case_args = Dict(symbol(k) => v for (k, v) in case_kwargs) 

    sys_descriptor = get_system_descriptor(category, system_catalog, name)

    key_diff = setdiff(keys(case_args), keys(get_supported_arguments(sys_descriptor)))
    if !isempty(key_diff)
        throw(ArgumentError("unsupported kwargs are specified: $key_diff"))
    end

    case_args = merge(get_supported_arguments(sys_descriptor), case_args)
    return _build_system(name, sys_descriptor, case_args, sys_args, print_stat; force_build, assign_new_uuids, skip_serialization)
end

function build_system(
    category::Type{T},
    name::String,
    print_stat::Bool = false;
    force_build::Bool = false,
    assign_new_uuids::Bool = false,
    skip_serialization::Bool = false,
    system_catalog::SystemCatalog = SystemCatalog(SYSTEM_CATALOG),
    kwargs...,
) where {T <: Union{PSIDTestSystems, PSIDSystems}}
    sys_descriptor = get_system_descriptor(category, system_catalog, name)

    sys_kwargs = filter_kwargs(; kwargs...)
    sys_args = Dict(symbol(k) => v for (k, v) in sys_kwargs) 

    case_kwargs = filter_case_kwargs(; kwargs...)
    case_args = Dict(symbol(k) => v for (k, v) in case_kwargs) 
    case_args[:add_forecasts]=false

    key_diff = setdiff(keys(case_args), keys(get_supported_arguments(sys_descriptor)))
    if !isempty(key_diff)
        throw(ArgumentError("unsupported kwargs are specified: $key_diff"))
    end

    case_args = merge(get_supported_arguments(sys_descriptor), case_args)
    
    psid_kwargs = check_kwargs_psid(; kwargs...)
    if !isempty(psid_kwargs)
        kwarg_type = first(values(psid_kwargs))
        name = "$(name)_$kwarg_type"
    end
    return _build_system(
        name,
        sys_descriptor,
        case_args,
        sys_args,
        print_stat;
        force_build, 
        assign_new_uuids, 
        skip_serialization
    )
end

function build_system(
    category::Type{T},
    name::String,
    print_stat::Bool = false;
    force_build::Bool = false,
    assign_new_uuids::Bool = false,
    skip_serialization::Bool = false,
    system_catalog::SystemCatalog = SystemCatalog(SYSTEM_CATALOG),
    kwargs...,
) where {T <: Union{PSITestSystems, PSISystems}}
    sys_descriptor = get_system_descriptor(category, system_catalog, name)

    sys_kwargs = filter_kwargs(; kwargs...)
    sys_args = Dict(k => v for (k, v) in sys_kwargs) 

    case_kwargs = filter_case_kwargs(; kwargs...)
    case_args = Dict(k => v for (k, v) in case_kwargs) 
    case_args[:add_forecasts]=true
    @info (get_supported_arguments(sys_descriptor))
    key_diff = setdiff(keys(case_args), keys(get_supported_arguments(sys_descriptor)))
    if !isempty(key_diff)
        throw(ArgumentError("unsupported kwargs are specified: $key_diff"))
    end

    case_args = merge(get_supported_arguments(sys_descriptor), case_args)
    
    psid_kwargs = check_kwargs_psid(; kwargs...)
    if !isempty(psid_kwargs)
        kwarg_type = first(values(psid_kwargs))
        name = "$(name)_$kwarg_type"
    end
    return _build_system(
        name,
        sys_descriptor,
        case_args,
        sys_args,
        print_stat;
        force_build, 
        assign_new_uuids, 
        skip_serialization
    )
end

function _build_system(
    name::String,
    sys_descriptor::SystemDescriptor,
    case_args::Dict{Symbol, <:Any},
    sys_args::Dict{Symbol, <:Any},
    print_stat::Bool = false;
    force_build::Bool = false,
    assign_new_uuids::Bool = false,
    skip_serialization::Bool = false
)
    if !is_serialized(name, case_args) || force_build
        check_serialized_storage()
        download_function = get_download_function(sys_descriptor)
        if !isnothing(download_function)
            #removing kwargs because they seem not needed, but not completely sure
            filepath = download_function()
            set_raw_data!(sys_descriptor, filepath)
        end
        @info "Building new system $(sys_descriptor.name) from raw data" sys_descriptor.raw_data
        build_func = get_build_function(sys_descriptor)
        start = time()
        sys = build_func(; raw_data = sys_descriptor.raw_data, case_args..., sys_args...)
        construct_time = time() - start
        serialized_filepath = get_serialized_filepath(name, case_args)
        start = time()
        if !skip_serialization
            PSY.to_json(sys, serialized_filepath; force = true)
            serialize_time = time() - start
        end
        # set_stats!(sys_descriptor, SystemBuildStats(construct_time, serialize_time))
    else
        @debug "Deserialize system from file" sys_descriptor.name
        start = time()
        # time_series_in_memory = get(kwargs, :time_series_in_memory, false)
        file_path = get_serialized_filepath(name, case_args)
        sys = PSY.System(file_path; assign_new_uuids = assign_new_uuids, sys_args...)
        PSY.get_runchecks(sys)
        # update_stats!(sys_descriptor, time() - start)
    end
    print_stat ? print_stats(sys_descriptor) : nothing
    return sys
end
