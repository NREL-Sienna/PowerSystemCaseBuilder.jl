# PSID cases creation
function build_psid_4bus_multigen(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    raw_file = joinpath(data_dir, "FourBusMulti.raw")
    dyr_file = joinpath(data_dir, "FourBus_multigen.dyr")

    sys = System(raw_file, dyr_file; sys_kwargs...)
    for l in get_components(PSY.StandardLoad, sys)
        transform_load_to_constant_impedance(l)
    end
    return sys
end

function build_psid_11bus_andes(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    raw_file = joinpath(data_dir, "11BUS_KUNDUR.raw")
    dyr_file = joinpath(data_dir, "11BUS_KUNDUR_TGOV.dyr")
    sys = System(raw_file, dyr_file; sys_kwargs...)
    for l in get_components(PSY.StandardLoad, sys)
        transform_load_to_constant_impedance(l)
    end
    return sys
end

function build_psid_omib(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    sys_file = joinpath(DATA_DIR, "psid_tests", "data_examples", "omib_sys.json")
    sys = System(sys_file; sys_kwargs...)
    return sys
end

function build_psid_3bus(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    sys_file = joinpath(DATA_DIR, "psid_tests", "data_examples", "threebus_sys.json")
    sys = System(sys_file; sys_kwargs...)
    return sys
end

function build_wecc_240_dynamic(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    sys_file = joinpath(DATA_DIR, "psid_tests", "data_tests", "WECC_240_dynamic.json")
    sys = System(sys_file; sys_kwargs...)
    return sys
end

function build_psid_14bus_multigen(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    raw_file = joinpath(data_dir, "14Bus.raw")
    dyr_file = joinpath(data_dir, "dyn_data.dyr")

    sys = System(raw_file, dyr_file; sys_kwargs...)
    for l in get_components(PSY.StandardLoad, sys)
        transform_load_to_constant_impedance(l)
    end
    return sys
end
