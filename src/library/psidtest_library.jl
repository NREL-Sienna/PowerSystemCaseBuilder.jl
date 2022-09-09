function build_psid_psse_test_avr(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    avr_type = get(kwargs, :avr_type, "")
    if isempty(avr_type)
        error("No AVR type provided. Provide avr_type as kwarg when using build_system")
    elseif avr_type == "AC1A_SAT"
        raw_file = joinpath(data_dir, "AC1A/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "AC1A/ThreeBus_ESAC1A_SAT.dyr")
    elseif avr_type == "AC1A"
        raw_file = joinpath(data_dir, "AC1A/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "AC1A/ThreeBus_ESAC1A.dyr")
    elseif avr_type == "EXAC1" || avr_type == "EXST1"
        raw_file = joinpath(data_dir, avr_type, "TVC_System_32.raw")
        dyr_file = joinpath(data_dir, avr_type, "TVC_System.dyr")
    elseif avr_type == "SEXS"
        raw_file = joinpath(data_dir, "SEXS/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "SEXS/ThreeBus_SEXS.dyr")
    elseif avr_type == "SEXS_noTE"
        raw_file = joinpath(data_dir, "SEXS/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "SEXS/ThreeBus_SEXS_noTE.dyr")
    else
        error(
            "Kwarg avr_type = $(avr_type) for PSID/PSSE test not supported. Available kwargs are: $(AVAILABLE_PSID_PSSE_AVRS_TEST)",
        )
    end
    avr_sys = System(raw_file, dyr_file; sys_kwargs...)
    for l in get_components(PSY.PowerLoad, avr_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end
    return avr_sys
end

function build_psid_psse_test_tg(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    tg_type = get(kwargs, :tg_type, "")
    if isempty(tg_type)
        error(
            "No Turbine Governor type provided. Provide tg_type as kwarg when using build_system",
        )
    elseif tg_type == "GAST"
        raw_file = joinpath(data_dir, "GAST/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "GAST/ThreeBus_GAST.dyr")
    elseif tg_type == "HYGOV"
        raw_file = joinpath(data_dir, "HYGOV/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "HYGOV/ThreeBus_HYGOV.dyr")
    elseif tg_type == "TGOV1"
        raw_file = joinpath(data_dir, "TGOV1/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "TGOV1/ThreeBus_TGOV1.dyr")
    else
        error(
            "Kwarg tg_type = $(tg_type) for PSID/PSSE test not supported. Available kwargs are: $(AVAILABLE_PSID_PSSE_TGS_TEST)",
        )
    end
    tg_sys = System(raw_file, dyr_file; sys_kwargs...)
    for l in get_components(PSY.PowerLoad, tg_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end
    return tg_sys
end

function build_psid_psse_test_gen(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    gen_type = get(kwargs, :gen_type, "")
    if isempty(gen_type)
        error(
            "No Generator model type provided. Provide gen_type as kwarg when using build_system",
        )
    elseif gen_type == "GENCLS"
        raw_file = joinpath(data_dir, "GENCLS/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "GENCLS/ThreeBus_GENCLS.dyr")
    elseif gen_type == "GENROE"
        raw_file = joinpath(data_dir, "GENROE/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "GENROE/ThreeBus_GENROE.dyr")
    elseif gen_type == "GENROE_SAT"
        raw_file = joinpath(data_dir, "GENROE/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "GENROE/ThreeBus_GENROE_HIGH_SAT.dyr")
    elseif gen_type == "GENROU"
        raw_file = joinpath(data_dir, "GENROU/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "GENROU/ThreeBus_GENROU.dyr")
    elseif gen_type == "GENROU_NoSAT"
        raw_file = joinpath(data_dir, "GENROU/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "GENROU/ThreeBus_GENROU_NO_SAT.dyr")
    elseif gen_type == "GENROU_SAT"
        raw_file = joinpath(data_dir, "GENROU/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "GENROU/ThreeBus_GENROU_HIGH_SAT.dyr")
    elseif gen_type == "GENSAE"
        raw_file = joinpath(data_dir, "GENSAE/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "GENSAE/ThreeBus_GENSAE.dyr")
    elseif gen_type == "GENSAL"
        raw_file = joinpath(data_dir, "GENSAL/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "GENSAL/ThreeBus_GENSAL.dyr")
    else
        error(
            "Kwarg gen_type = $(gen_type) for PSID/PSSE test not supported. Available kwargs are: $(AVAILABLE_PSID_PSSE_GENS_TEST)",
        )
    end
    gen_sys = System(raw_file, dyr_file; sys_kwargs...)
    for l in get_components(PSY.PowerLoad, gen_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end
    return gen_sys
end

function build_psid_psse_test_pss(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    pss_type = get(kwargs, :pss_type, "")
    if isempty(pss_type)
        error("No PSS type provided. Provide pss_type as kwarg when using build_system")
    elseif pss_type == "STAB1"
        raw_file = joinpath(data_dir, "STAB1/OMIB_SSS.raw")
        dyr_file = joinpath(data_dir, "STAB1/OMIB_SSS.dyr")
    elseif pss_type == "IEEEST"
        raw_file = joinpath(data_dir, "IEEEST/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "IEEEST/ThreeBus_IEEEST.dyr")
    elseif pss_type == "IEEEST_FILTER"
        raw_file = joinpath(data_dir, "IEEEST/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "IEEEST/ThreeBus_IEEEST_with_filter.dyr")
    else
        error(
            "Kwarg tg_type = $(pss_type) for PSID/PSSE test not supported. Available kwargs are: $(AVAILABLE_PSID_PSSE_PSS_TEST)",
        )
    end
    pss_sys = System(raw_file, dyr_file; sys_kwargs...)
    for l in get_components(PSY.PowerLoad, pss_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end
    return pss_sys
end

function build_psid_psse_test_exp_load(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    raw_file = joinpath(data_dir, "ThreeBusMulti.raw")
    dyr_file = joinpath(data_dir, "ThreeBus_GENROU.dyr")
    sys = System(raw_file, dyr_file; sys_kwargs...)
    for l in collect(get_components(PSY.PowerLoad, sys))
        exp_load = PSY.ExponentialLoad(
            name = PSY.get_name(l),
            available = PSY.get_available(l),
            bus = PSY.get_bus(l),
            active_power = PSY.get_active_power(l),
            reactive_power = PSY.get_reactive_power(l),
            active_power_coefficient = 0.0, # Constant Power
            reactive_power_coefficient = 0.0, # Constant Power
            base_power = PSY.get_base_power(l),
            max_active_power = PSY.get_max_active_power(l),
            max_reactive_power = PSY.get_max_reactive_power(l),
        )
        PSY.remove_component!(sys, l)
        PSY.add_component!(sys, exp_load)
    end
    return sys
end

function build_psid_psse_test_constantP_load(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    raw_file = joinpath(data_dir, "ThreeBusMulti.raw")
    dyr_file = joinpath(data_dir, "ThreeBus_GENROU.dyr")
    sys = System(raw_file, dyr_file; sys_kwargs...)
    return sys
end

function build_psid_test_omib(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = get_raw_data(; kwargs...)
    omib_sys = System(raw_file, runchecks = false; sys_kwargs...)
    add_source_to_ref(omib_sys)

    function dyn_gen_classic(generator)
        return DynamicGenerator(
            name = PSY.get_name(generator),
            ω_ref = 1.0,
            machine = machine_classic(),
            shaft = shaft_damping(),
            avr = avr_none(),
            prime_mover = tg_none(),
            pss = pss_none(),
        )
    end

    gen = [g for g in get_components(Generator, omib_sys)][1]
    case_gen = dyn_gen_classic(gen)
    add_component!(omib_sys, case_gen, gen)

    for l in get_components(PSY.PowerLoad, omib_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end

    return omib_sys
end

function build_psid_test_threebus_oneDoneQ(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = get_raw_data(; kwargs...)
    threebus_sys = System(raw_file, runchecks = false; sys_kwargs...)
    add_source_to_ref(threebus_sys)

    function dyn_gen_oneDoneQ(generator)
        return PSY.DynamicGenerator(
            name = PSY.get_name(generator),
            ω_ref = 1.0,
            machine = machine_oneDoneQ(),
            shaft = shaft_no_damping(),
            avr = avr_type1(),
            prime_mover = tg_none(),
            pss = pss_none(),
        )
    end

    for g in get_components(Generator, threebus_sys)
        case_gen = dyn_gen_oneDoneQ(g)
        add_component!(threebus_sys, case_gen, g)
    end

    for l in get_components(PSY.PowerLoad, threebus_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end

    return threebus_sys
end

function build_psid_test_threebus_simple_marconato(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = get_raw_data(; kwargs...)
    threebus_sys = System(raw_file, runchecks = false; sys_kwargs...)
    add_source_to_ref(threebus_sys)

    function dyn_gen_simple_marconato(generator)
        return PSY.DynamicGenerator(
            name = PSY.get_name(generator),
            ω_ref = 1.0,
            machine = machine_simple_marconato(),
            shaft = shaft_no_damping(),
            avr = avr_type1(),
            prime_mover = tg_none(),
            pss = pss_none(),
        )
    end

    for g in get_components(Generator, threebus_sys)
        case_gen = dyn_gen_simple_marconato(g)
        add_component!(threebus_sys, case_gen, g)
    end

    for l in get_components(PSY.PowerLoad, threebus_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end

    return threebus_sys
end

function build_psid_test_threebus_marconato(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = get_raw_data(; kwargs...)
    threebus_sys = System(raw_file, runchecks = false; sys_kwargs...)
    add_source_to_ref(threebus_sys)

    function dyn_gen_marconato(generator)
        return PSY.DynamicGenerator(
            name = PSY.get_name(generator), #static generator
            ω_ref = 1.0, # ω_ref
            machine = machine_marconato(), #machine
            shaft = shaft_no_damping(), #shaft
            avr = avr_type1(), #avr
            prime_mover = tg_none(), #tg
            pss = pss_none(),
        ) #pss
    end

    for g in get_components(Generator, threebus_sys)
        case_gen = dyn_gen_marconato(g)
        add_component!(threebus_sys, case_gen, g)
    end

    for l in get_components(PSY.PowerLoad, threebus_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end

    return threebus_sys
end

function build_psid_test_threebus_simple_anderson(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = get_raw_data(; kwargs...)
    threebus_sys = System(raw_file, runchecks = false; sys_kwargs...)
    add_source_to_ref(threebus_sys)

    function dyn_gen_simple_anderson(generator)
        return PSY.DynamicGenerator(
            name = PSY.get_name(generator), #static generator
            ω_ref = 1.0, # ω_ref
            machine = machine_simple_anderson(), #machine
            shaft = shaft_no_damping(), #shaft
            avr = avr_type1(), #avr
            prime_mover = tg_none(), #tg
            pss = pss_none(),
        ) #pss
    end

    for g in get_components(Generator, threebus_sys)
        case_gen = dyn_gen_simple_anderson(g)
        add_component!(threebus_sys, case_gen, g)
    end

    for l in get_components(PSY.PowerLoad, threebus_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end

    return threebus_sys
end

function build_psid_test_threebus_anderson(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = get_raw_data(; kwargs...)
    threebus_sys = System(raw_file, runchecks = false; sys_kwargs...)
    add_source_to_ref(threebus_sys)

    function dyn_gen_anderson(generator)
        return PSY.DynamicGenerator(
            name = PSY.get_name(generator), #static generator
            ω_ref = 1.0, # ω_ref
            machine = machine_anderson(), #machine
            shaft = shaft_no_damping(), #shaft
            avr = avr_type1(), #avr
            prime_mover = tg_none(), #tg
            pss = pss_none(),
        ) #pss
    end

    for g in get_components(Generator, threebus_sys)
        case_gen = dyn_gen_anderson(g)
        add_component!(threebus_sys, case_gen, g)
    end

    for l in get_components(PSY.PowerLoad, threebus_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end

    return threebus_sys
end

function build_psid_test_threebus_5shaft(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = get_raw_data(; kwargs...)
    threebus_sys = System(raw_file, runchecks = false; sys_kwargs...)
    add_source_to_ref(threebus_sys)

    #Reduce generator output
    for g in get_components(Generator, threebus_sys)
        g.active_power = 0.75
    end

    function dyn_gen_five_mass_shaft_order(generator)
        return PSY.DynamicGenerator(
            name = PSY.get_name(generator),
            ω_ref = 1.0, # ω_ref,
            machine = machine_oneDoneQ(), #machine
            shaft = shaft_fivemass(), #shaft
            avr = avr_type1(), #avr
            prime_mover = tg_none(),
            pss = pss_none(),
        ) #pss
    end

    function dyn_gen_first_order(generator)
        return PSY.DynamicGenerator(
            name = PSY.get_name(generator),
            ω_ref = 1.0, # ω_ref,
            machine = machine_oneDoneQ(), #machine
            shaft = shaft_damping(), #shaft
            avr = avr_type1(), #avr
            prime_mover = tg_none(), #tg
            pss = pss_none(),
        ) #pss
    end

    for g in get_components(Generator, threebus_sys)
        if get_number(get_bus(g)) == 103
            case_gen = dyn_gen_five_mass_shaft_order(g)
            add_component!(threebus_sys, case_gen, g)
        elseif get_number(get_bus(g)) == 102
            case_inv = dyn_gen_first_order(g)
            add_component!(threebus_sys, case_inv, g)
        end
    end

    for l in get_components(PSY.PowerLoad, threebus_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end

    return threebus_sys
end

function build_psid_test_vsm_inverter(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = get_raw_data(; kwargs...)
    omib_sys = System(raw_file, runchecks = false; sys_kwargs...)
    add_source_to_ref(omib_sys)

    function inv_darco(static_device)
        return PSY.DynamicInverter(
            PSY.get_name(static_device),
            1.0, #ω_ref
            converter_low_power(), #converter
            outer_control(), #outercontrol
            inner_control(), #inner_control
            dc_source_lv(),
            pll(),
            filt(),
        ) #pss
    end

    for l in get_components(PSY.PowerLoad, omib_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end

    #Attach dynamic generator. Currently use PSS/e format based on bus #.
    device = [g for g in get_components(Generator, omib_sys)][1]
    case_inv = inv_darco(device)
    add_component!(omib_sys, case_inv, device)

    return omib_sys
end

function build_psid_test_threebus_machine_vsm(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = get_raw_data(; kwargs...)
    threebus_sys = System(raw_file, runchecks = false; sys_kwargs...)
    add_source_to_ref(threebus_sys)

    function dyn_gen_second_order(generator)
        return DynamicGenerator(
            name = PSY.get_name(generator),
            ω_ref = 1.0, # ω_ref,
            machine = machine_oneDoneQ(), #machine
            shaft = shaft_no_damping(), #shaft
            avr = avr_type1(), #avr
            prime_mover = tg_none(), #tg
            pss = pss_none(), #pss
        )
    end

    function inv_case78(static_device)
        return DynamicInverter(
            name = PSY.get_name(static_device),
            ω_ref = 1.0, # ω_ref,
            converter = converter_high_power(), #converter
            outer_control = outer_control(), #outer control
            inner_control = inner_control(), #inner control voltage source
            dc_source = dc_source_lv(), #dc source
            freq_estimator = pll(), #pll
            filter = filt(), #filter
        )
    end

    for g in get_components(Generator, threebus_sys)
        if get_number(get_bus(g)) == 102
            case_gen = dyn_gen_second_order(g)
            add_component!(threebus_sys, case_gen, g)
        elseif get_number(get_bus(g)) == 103
            case_inv = inv_case78(g)
            add_component!(threebus_sys, case_inv, g)
        end
    end

    for l in get_components(PSY.PowerLoad, threebus_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end

    return threebus_sys
end

function build_psid_test_threebus_machine_vsm_dynlines(; kwargs...)
    threebus_sys = build_psid_test_threebus_machine_vsm(; kwargs...)
    dyn_branch = DynamicBranch(get_component(Branch, threebus_sys, "BUS 2-BUS 3-i_1"))
    add_component!(threebus_sys, dyn_branch)

    return threebus_sys
end

function build_psid_test_threebus_multimachine(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    raw_file = get_raw_data(; kwargs...)
    threebus_sys = System(raw_file, runchecks = false; sys_kwargs...)

    function dyn_gen_multi(generator)
        return PSY.DynamicGenerator(
            name = PSY.get_name(generator),
            ω_ref = 1.0, # ω_ref,
            machine = machine_classic(), #machine
            shaft = shaft_damping(), #shaft
            avr = avr_none(), #avr
            prime_mover = tg_none(), #tg
            pss = pss_none(),
        )
    end

    function dyn_gen_multi_tg(generator)
        return PSY.DynamicGenerator(
            name = PSY.get_name(generator),
            ω_ref = 1.0, # ω_ref,
            machine = machine_classic(), #machine
            shaft = shaft_damping(), #shaft
            avr = avr_none(), #avr
            prime_mover = tg_type2(), #tg
            pss = pss_none(),
        )
    end

    # Add dynamic generators to the system (each gen is linked through a static one)
    for g in get_components(Generator, threebus_sys)
        if get_number(get_bus(g)) == 101
            case_gen = dyn_gen_multi(g)
            add_component!(threebus_sys, case_gen, g)
        elseif get_number(get_bus(g)) == 102
            case_gen = dyn_gen_multi_tg(g)
            add_component!(threebus_sys, case_gen, g)
        end
    end

    return threebus_sys
end
