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
    sys_descriptor = get_system_descriptor(category, system_catalog, name)

    sys_kwargs = filter_kwargs(; kwargs...)
    sys_args = Dict{Symbol, Any}()
    merge!(sys_args, Dict(k => v for (k, v) in sys_kwargs))
    #sys_args = Dict(k => v::Any for (k, v) in sys_kwargs) 
    sys_keys = keys(sys_args)

    psid_kwargs = check_kwargs_psid(; kwargs...)
    psid_args = Dict(k => v for (k, v) in psid_kwargs)
    psid_keys = keys(psid_args)

    case_keys = keys(get_supported_arguments_dict(sys_descriptor))

    if !(
        isempty(intersect(sys_keys, psid_keys)) &&
        isempty(intersect(psid_keys, case_keys)) &&
        isempty(intersect(sys_keys, case_keys))
    )
        throw(ErrorException("Collision detected between sys_kwargs and psid_kwargs!"))
    end

    if !isempty(psid_kwargs)
        kwarg_type = first(values(psid_kwargs))
        name = "$(name)_$kwarg_type"
    end

    non_sys_psid_kwargs = setdiff(kwargs, merge(psid_kwargs, sys_kwargs))
    non_sys_psid_args = Dict(k => v for (k, v) in non_sys_psid_kwargs)
    key_diff = setdiff(keys(non_sys_psid_args), case_keys)
    if !isempty(key_diff)
        throw(ArgumentError("unsupported kwargs are specified: $key_diff"))
    end

    case_args = Dict{Symbol, Any}()
    merge!(
        case_args,
        merge(get_supported_arguments_dict(sys_descriptor), non_sys_psid_args),
    )

    return _build_system(
        name,
        sys_descriptor,
        case_args,
        sys_args,
        print_stat;
        force_build,
        assign_new_uuids,
        skip_serialization,
    )
end

function _build_system(
    name::String,
    sys_descriptor::SystemDescriptor,
    case_args::Dict{Symbol, Any},
    sys_args::Dict{Symbol, Any},
    print_stat::Bool = false;
    force_build::Bool = false,
    assign_new_uuids::Bool = false,
    skip_serialization::Bool = false,
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
            check_parameters_json(case_args)
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
