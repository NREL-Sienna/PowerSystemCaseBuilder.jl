# PSID cases creation
function build_psid_4bus_multigen(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    raw_file = joinpath(data_dir, "FourBusMulti.raw")
    dyr_file = joinpath(data_dir, "FourBus_multigen.dyr")

    sys = System(raw_file, dyr_file; sys_kwargs...)
    for l in get_components(PSY.PowerLoad, sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end
    return sys
end

function build_psid_11bus_andes(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    raw_file = joinpath(data_dir, "11BUS_KUNDUR.raw")
    dyr_file = joinpath(data_dir, "11BUS_KUNDUR_TGOV.dyr")
    sys = System(raw_file, dyr_file; sys_kwargs...)
    return sys
end
