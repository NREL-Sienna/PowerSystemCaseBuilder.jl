function build_matpower(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path); sys_kwargs...)
    return sys
end
