function build_matpower(; raw_data, kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; raw_data)
    sys = PSY.System(PSY.PowerModelsData(file_path); sys_kwargs...)
    return sys
end
