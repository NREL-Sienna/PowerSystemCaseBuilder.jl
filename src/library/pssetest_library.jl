function build_psse_RTS_GMLC_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(data_dir), sys_kwargs...)

    return sys
end

function build_psse_ACTIVSg2000_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    file_path = joinpath(data_dir, "ACTIVSg2000", "ACTIVSg2000.RAW")
    dyr_file = joinpath(data_dir, "psse_dyr", "ACTIVSg2000_dynamics.dyr")
    sys = PSY.System(file_path, dyr_file; sys_kwargs...)

    return sys
end

function build_pti(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end
