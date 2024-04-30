# PSID cases creation
function build_psid_4bus_multigen(; raw_data, kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = joinpath(raw_data, "FourBusMulti.raw")
    dyr_file = joinpath(raw_data, "FourBus_multigen.dyr")

    sys = System(raw_file, dyr_file; sys_kwargs...)
    for l in get_components(PSY.StandardLoad, sys)
        transform_load_to_constant_impedance(l)
    end
    return sys
end

function build_psid_11bus_andes(; raw_data, kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = joinpath(raw_data, "11BUS_KUNDUR.raw")
    dyr_file = joinpath(raw_data, "11BUS_KUNDUR_TGOV.dyr")
    sys = System(raw_file, dyr_file; sys_kwargs...)
    for l in get_components(PSY.StandardLoad, sys)
        transform_load_to_constant_impedance(l)
    end
    return sys
end

function build_psid_omib(; raw_data, kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    sys_file = joinpath(DATA_DIR, "psid_tests", "data_examples", "omib_sys.json")
    sys = System(sys_file; sys_kwargs...)
    return sys
end

function build_psid_3bus(; raw_data, kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    sys_file = joinpath(DATA_DIR, "psid_tests", "data_examples", "threebus_sys.json")
    sys = System(sys_file; sys_kwargs...)
    return sys
end

function build_wecc_240_dynamic(; raw_data, kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    sys_file = joinpath(DATA_DIR, "psid_tests", "data_tests", "WECC_240_dynamic.json")
    sys = System(sys_file; sys_kwargs...)
    return sys
end

function build_psid_14bus_multigen(; raw_data, kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = joinpath(raw_data, "14bus.raw")
    dyr_file = joinpath(raw_data, "dyn_data.dyr")

    sys = System(raw_file, dyr_file; sys_kwargs...)
    for l in get_components(PSY.StandardLoad, sys)
        transform_load_to_constant_impedance(l)
    end
    return sys
end

function build_3bus_inverter(; raw_data, kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = joinpath(raw_data, "ThreeBusInverter.raw")
    sys = System(raw_file; sys_kwargs...)
    return sys
end

##################################
# Add Load tutorial systems here #
##################################

function build_psid_load_tutorial_omib(; raw_data, kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    sys = System(raw_data; runchecks = false, sys_kwargs...)
    l = first(get_components(StandardLoad, sys))
    exp_load = PSY.ExponentialLoad(;
        name = PSY.get_name(l),
        available = PSY.get_available(l),
        bus = PSY.get_bus(l),
        active_power = PSY.get_constant_active_power(l),
        reactive_power = PSY.get_constant_reactive_power(l),
        active_power_coefficient = 0.0, # Constant Power
        reactive_power_coefficient = 0.0, # Constant Power
        base_power = PSY.get_base_power(l),
        max_active_power = PSY.get_max_constant_active_power(l),
        max_reactive_power = PSY.get_max_constant_reactive_power(l),
    )
    remove_component!(sys, l)
    add_component!(sys, exp_load)
    return sys
end

function build_psid_load_tutorial_genrou(; raw_data, kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    sys = build_psid_load_tutorial_omib(; force_build = true, raw_data, sys_kwargs...)
    gen = get_component(ThermalStandard, sys, "generator-101-1")
    dyn_device = dyn_genrou(gen)
    add_component!(sys, dyn_device, gen)
    return sys
end

function build_psid_load_tutorial_droop(; raw_data, kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    sys = build_psid_load_tutorial_omib(; force_build = true, raw_data, sys_kwargs...)
    gen = get_component(ThermalStandard, sys, "generator-101-1")
    dyn_device = inv_droop(gen)
    add_component!(sys, dyn_device, gen)
    return sys
end
