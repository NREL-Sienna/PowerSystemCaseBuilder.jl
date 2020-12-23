function build_system(category::Type{<:SystemCategory}, name::String, print_stat::Bool=false; kwargs...)
    add_forecasts = get(kwargs, :add_forecasts, true)
    add_reserves = get(kwargs, :add_reserves, false)
    system_catelog = get(kwargs, :system_catelog, SystemCatalog(SYSTEM_CATELOG))
    sys_descriptor = get_system_descriptor(category, system_catelog, name)
    if !is_serialized(name, add_forecasts, add_reserves)
        check_serailized_storage()
        download_function = get_download_function(sys_descriptor)
        if !isnothing(download_function)
            filepath = download_function(; kwargs...)
            set_raw_data!(sys_descriptor, filepath)
        end
        @debug "Build new system" sys_descriptor.name
        build_func = get_build_function(sys_descriptor)
        start = time()
        sys = build_func(;
            raw_data = sys_descriptor.raw_data,
            kwargs...
        )
        construct_time = time() - start
        serialized_filepath = get_serialized_filepath(name, add_forecasts, add_reserves)
        start = time()
        PSY.to_json(sys, serialized_filepath)
        serialize_time = time() - start
        set_stats!(sys_descriptor, SystemBuildStats(construct_time, serialize_time))
    else
        @debug "Deserialize system from file" sys_descriptor.name
        start = time()
        time_series_in_memory = get(kwargs, :time_series_in_memory, false)
        file_path = get_serialized_filepath(name, add_forecasts, add_reserves)
        sys = PSY.System(
            file_path;
            time_series_in_memory = time_series_in_memory,
        )   
        update_stats!(sys_descriptor, time() - start)
    end
    print_stat ? print_stats(sys_descriptor) : nothing
    return sys
end
