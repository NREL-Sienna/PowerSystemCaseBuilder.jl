function get_system_library(; kwargs...)
    if check_for_serialized_descriptor()
        return deserialize()
    else
        return parse_system_library()
    end
end

function build_system(name::String, print_stat::Bool=false; kwargs...)
    #TODO: add check for supported kwargs
    add_forecasts = get(kwargs, :add_forecasts, true)
    add_reserves = get(kwargs, :add_reserves, false)
    system_library = get(kwargs, :system_library, get_system_library())
    sys_descriptor = get_system_descriptor(system_library, name)
    label = make_system_label(add_forecasts, add_reserves)
    if !is_serialized(sys_descriptor, label)
        check_storage_dir()
        include(joinpath(PACKAGE_DIR, get_raw_data(sys_descriptor)))
        @debug "Build new system" sys_descriptor.description
        build_func = get_build_function(sys_descriptor)
        start = time()
        sys = build_func(;
            kwargs...
        )
        construct_time = time() - start
        serialized_file = joinpath(SERIALIZED_SYSTEM_DIR, get_serialzed_file_name(sys_descriptor, label))
        start = time()
        PSY.to_json(sys, serialized_file)
        serialize_time = time() - start
        set_stats!(sys_descriptor, SystemBuildStats(construct_time, serialize_time))
        update_serialized!(sys_descriptor, label, serialized_file)
        serialize(system_library)
    else
        @debug "Deserialize system from file" label
        start = time()
        time_series_in_memory = get(kwargs, :time_series_in_memory, false)
        file_path = get_serialized_file(sys_descriptor, label)
        sys = PSY.System(
            file_path;
            time_series_in_memory = time_series_in_memory,
        )   
        update_stats!(sys_descriptor, time() - start)
    end
    print_stat ? print_stats(sys_descriptor) : nothing
    return sys
end
