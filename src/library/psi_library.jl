function build_c_sys5_pjm(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5 = PSY.System(
        100.0,
        nodes,
        thermal_generators5(nodes),
        loads5(nodes),
        branches5(nodes);
        sys_kwargs...,
    )
    pv_device = PSY.RenewableDispatch(
        "PVBus5",
        true,
        nodes[3],
        0.0,
        0.0,
        3.84,
        PrimeMovers.PVe,
        (min = 0.0, max = 0.0),
        1.0,
        TwoPartCost(0.0, 0.0),
        100.0,
    )
    wind_device = PSY.RenewableDispatch(
        "WindBus1",
        true,
        nodes[1],
        0.0,
        0.0,
        4.51,
        PrimeMovers.WT,
        (min = 0.0, max = 0.0),
        1.0,
        TwoPartCost(0.0, 0.0),
        100.0,
    )
    PSY.add_component!(c_sys5, pv_device)
    PSY.add_component!(c_sys5, wind_device)
    timeseries_dataset =
        HDF5.h5read(joinpath(DATA_DIR, "5-Bus", "PJM_5_BUS_7_DAYS.h5"), "Time Series Data")
    refdate = first(DayAhead)
    da_load_time_series = DateTime[]
    da_load_time_series_val = Float64[]

    for i in 1:7
        for v in timeseries_dataset["DA Load Data"]["DA_LOAD_DAY_$(i)"]
            h = refdate + Hour(v.HOUR + (i - 1) * 24)
            push!(da_load_time_series, h)
            push!(da_load_time_series_val, v.LOAD)
        end
    end

    re_timeseries = Dict(
        "PVBus5" => CSV.read(
            joinpath(
                DATA_DIR,
                "5-Bus",
                "5bus_ts",
                "gen",
                "Renewable",
                "PV",
                "da_solar.csv",
            ),
            DataFrame,
        )[
            :,
            :SolarBusC,
        ],
        "WindBus1" => CSV.read(
            joinpath(
                DATA_DIR,
                "5-Bus",
                "5bus_ts",
                "gen",
                "Renewable",
                "WIND",
                "da_wind.csv",
            ),
            DataFrame,
        )[
            :,
            :WindBusA,
        ],
    )
    re_timeseries["WindBus1"] = re_timeseries["WindBus1"] ./ 451

    bus_dist_fact = Dict("Bus2" => 0.33, "Bus3" => 0.33, "Bus4" => 0.34)
    peak_load = maximum(da_load_time_series_val)
    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PowerLoad, c_sys5))
            set_max_active_power!(l, bus_dist_fact[PSY.get_name(l)] * peak_load / 100)
            add_time_series!(
                c_sys5,
                l,
                PSY.SingleTimeSeries(
                    "max_active_power",
                    TimeArray(da_load_time_series, da_load_time_series_val ./ peak_load),
                ),
            )
        end
        for (ix, g) in enumerate(PSY.get_components(RenewableDispatch, c_sys5))
            add_time_series!(
                c_sys5,
                g,
                PSY.SingleTimeSeries(
                    "max_active_power",
                    TimeArray(da_load_time_series, re_timeseries[PSY.get_name(g)]),
                ),
            )
        end
    end

    return c_sys5
end

function build_c_sys5_pjm_rt(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5 = PSY.System(
        100.0,
        nodes,
        thermal_generators5(nodes),
        loads5(nodes),
        branches5(nodes);
        sys_kwargs...,
    )
    pv_device = PSY.RenewableDispatch(
        "PVBus5",
        true,
        nodes[3],
        0.0,
        0.0,
        3.84,
        PrimeMovers.PVe,
        (min = 0.0, max = 0.0),
        1.0,
        TwoPartCost(0.0, 0.0),
        100.0,
    )
    wind_device = PSY.RenewableDispatch(
        "WindBus1",
        true,
        nodes[1],
        0.0,
        0.0,
        4.51,
        PrimeMovers.WT,
        (min = 0.0, max = 0.0),
        1.0,
        TwoPartCost(0.0, 0.0),
        100.0,
    )
    PSY.add_component!(c_sys5, pv_device)
    PSY.add_component!(c_sys5, wind_device)
    timeseries_dataset =
        HDF5.h5read(joinpath(DATA_DIR, "5-Bus", "PJM_5_BUS_7_DAYS.h5"), "Time Series Data")
    refdate = first(DayAhead)
    rt_load_time_series = DateTime[]
    rt_load_time_series_val = Float64[]
    for i in 1:7
        for v in timeseries_dataset["Actual Load Data"]["ACTUAL_LOAD_DAY_$(i).xls"]
            h = refdate + Second(round(v.Time * 86400)) + Day(i - 1)
            push!(rt_load_time_series, h)
            push!(rt_load_time_series_val, v.Load)
        end
    end

    re_timeseries = Dict(
        "PVBus5" => CSV.read(
            joinpath(
                DATA_DIR,
                "5-Bus",
                "5bus_ts",
                "gen",
                "Renewable",
                "PV",
                "rt_solar.csv",
            ),
            DataFrame,
        )[
            :,
            :SolarBusC,
        ],
        "WindBus1" => CSV.read(
            joinpath(
                DATA_DIR,
                "5-Bus",
                "5bus_ts",
                "gen",
                "Renewable",
                "WIND",
                "rt_wind.csv",
            ),
            DataFrame,
        )[
            :,
            :WindBusA,
        ],
    )

    re_timeseries["WindBus1"] = re_timeseries["WindBus1"] ./ 451
    re_timeseries["PVBus5"] = re_timeseries["PVBus5"] ./ maximum(re_timeseries["PVBus5"])

    rt_re_time_stamps =
        collect(DateTime("2024-01-01T00:00:00"):Minute(5):DateTime("2024-01-07T23:55:00"))

    rt_timearray = TimeArray(rt_load_time_series, rt_load_time_series_val)
    rt_timearray = collapse(rt_timearray, Minute(5), first, TimeSeries.mean)
    bus_dist_fact = Dict("Bus2" => 0.33, "Bus3" => 0.33, "Bus4" => 0.34)
    peak_load = maximum(rt_load_time_series_val)
    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PowerLoad, c_sys5))
            set_max_active_power!(l, bus_dist_fact[PSY.get_name(l)] * peak_load / 100)
            rt_timearray =
                TimeArray(rt_load_time_series, rt_load_time_series_val ./ peak_load)
            rt_timearray = collapse(rt_timearray, Minute(5), first, TimeSeries.mean)
            add_time_series!(
                c_sys5,
                l,
                PSY.SingleTimeSeries("max_active_power", rt_timearray),
            )
        end
        for (ix, g) in enumerate(PSY.get_components(RenewableDispatch, c_sys5))
            add_time_series!(
                c_sys5,
                g,
                PSY.SingleTimeSeries(
                    "max_active_power",
                    TimeArray(rt_re_time_stamps, re_timeseries[PSY.get_name(g)]),
                ),
            )
        end
    end

    return c_sys5
end

function build_5_bus_hydro_uc_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    rawsys = PSY.PowerSystemTableData(
        data_dir,
        100.0,
        joinpath(data_dir, "user_descriptors.yaml");
        generator_mapping_file = joinpath(data_dir, "generator_mapping.yaml"),
    )
    if get(kwargs, :add_forecasts, true)
        c_sys5_hy_uc = PSY.System(
            rawsys;
            timeseries_metadata_file = joinpath(
                data_dir,
                "5bus_ts",
                "7day",
                "timeseries_pointers_da_7day.json",
            ),
            time_series_in_memory = true,
            sys_kwargs...,
        )
        PSY.transform_single_time_series!(c_sys5_hy_uc, 24, Hour(24))
    else
        c_sys5_hy_uc = PSY.System(rawsys; sys_kwargs...)
    end

    return c_sys5_hy_uc
end

function build_5_bus_hydro_uc_sys_targets(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    rawsys = PSY.PowerSystemTableData(
        data_dir,
        100.0,
        joinpath(data_dir, "user_descriptors.yaml");
        generator_mapping_file = joinpath(data_dir, "generator_mapping.yaml"),
    )
    if get(kwargs, :add_forecasts, true)
        c_sys5_hy_uc = PSY.System(
            rawsys;
            timeseries_metadata_file = joinpath(
                data_dir,
                "5bus_ts",
                "7day",
                "timeseries_pointers_da_7day.json",
            ),
            time_series_in_memory = true,
            sys_kwargs...,
        )
        PSY.transform_single_time_series!(c_sys5_hy_uc, 24, Hour(24))
    else
        c_sys5_hy_uc = PSY.System(rawsys; sys_kwargs...)
    end
    cost = PSY.StorageManagementCost(;
        variable = VariableCost(0.15),
        fixed = 0.0,
        start_up = 0.0,
        shut_down = 0.0,
        energy_shortage_cost = 50.0,
        energy_surplus_cost = 0.0,
    )
    for hy in get_components(HydroEnergyReservoir, c_sys5_hy_uc)
        set_operation_cost!(hy, cost)
    end
    return c_sys5_hy_uc
end

function build_5_bus_hydro_ed_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    rawsys = PSY.PowerSystemTableData(
        data_dir,
        100.0,
        joinpath(data_dir, "user_descriptors.yaml");
        generator_mapping_file = joinpath(data_dir, "generator_mapping.yaml"),
    )
    c_sys5_hy_ed = PSY.System(
        rawsys;
        timeseries_metadata_file = joinpath(
            data_dir,
            "5bus_ts",
            "7day",
            "timeseries_pointers_rt_7day.json",
        ),
        time_series_in_memory = true,
        sys_kwargs...,
    )
    PSY.transform_single_time_series!(c_sys5_hy_ed, 12, Hour(1))

    return c_sys5_hy_ed
end

function build_5_bus_hydro_ed_sys_targets(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    rawsys = PSY.PowerSystemTableData(
        data_dir,
        100.0,
        joinpath(data_dir, "user_descriptors.yaml");
        generator_mapping_file = joinpath(data_dir, "generator_mapping.yaml"),
    )
    c_sys5_hy_ed = PSY.System(
        rawsys;
        timeseries_metadata_file = joinpath(
            data_dir,
            "5bus_ts",
            "7day",
            "timeseries_pointers_rt_7day.json",
        ),
        time_series_in_memory = true,
        sys_kwargs...,
    )
    cost = PSY.StorageManagementCost(;
        variable = VariableCost(0.15),
        fixed = 0.0,
        start_up = 0.0,
        shut_down = 0.0,
        energy_shortage_cost = 50.0,
        energy_surplus_cost = 0.0,
    )
    for hy in get_components(HydroEnergyReservoir, c_sys5_hy_ed)
        set_operation_cost!(hy, cost)
    end
    PSY.transform_single_time_series!(c_sys5_hy_ed, 12, Hour(1))

    return c_sys5_hy_ed
end

function build_5_bus_hydro_wk_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    rawsys = PSY.PowerSystemTableData(
        data_dir,
        100.0,
        joinpath(data_dir, "user_descriptors.yaml");
        generator_mapping_file = joinpath(data_dir, "generator_mapping.yaml"),
    )
    c_sys5_hy_wk = PSY.System(
        rawsys;
        timeseries_metadata_file = joinpath(
            data_dir,
            "5bus_ts",
            "7day",
            "timeseries_pointers_wk_7day.json",
        ),
        time_series_in_memory = true,
        sys_kwargs...,
    )
    PSY.transform_single_time_series!(c_sys5_hy_wk, 2, Hour(48))

    return c_sys5_hy_wk
end

function build_5_bus_hydro_wk_sys_targets(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    rawsys = PSY.PowerSystemTableData(
        data_dir,
        100.0,
        joinpath(data_dir, "user_descriptors.yaml");
        generator_mapping_file = joinpath(data_dir, "generator_mapping.yaml"),
    )
    c_sys5_hy_wk = PSY.System(
        rawsys;
        timeseries_metadata_file = joinpath(
            data_dir,
            "5bus_ts",
            "7day",
            "timeseries_pointers_wk_7day.json",
        ),
        time_series_in_memory = true,
        sys_kwargs...,
    )
    cost = PSY.StorageManagementCost(;
        variable = VariableCost(0.15),
        fixed = 0.0,
        start_up = 0.0,
        shut_down = 0.0,
        energy_shortage_cost = 50.0,
        energy_surplus_cost = 0.0,
    )
    for hy in get_components(HydroEnergyReservoir, c_sys5_hy_wk)
        set_operation_cost!(hy, cost)
    end
    PSY.transform_single_time_series!(c_sys5_hy_wk, 2, Hour(48))

    return c_sys5_hy_wk
end

function build_RTS_GMLC_DA_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    RTS_GMLC_DIR = get_raw_data(; kwargs...)
    RTS_SRC_DIR = joinpath(RTS_GMLC_DIR, "RTS_Data", "SourceData")
    RTS_SIIP_DIR = joinpath(RTS_GMLC_DIR, "RTS_Data", "FormattedData", "SIIP")
    rawsys = PSY.PowerSystemTableData(
        RTS_SRC_DIR,
        100.0,
        joinpath(RTS_SIIP_DIR, "user_descriptors.yaml");
        timeseries_metadata_file = joinpath(RTS_SIIP_DIR, "timeseries_pointers.json"),
        generator_mapping_file = joinpath(RTS_SIIP_DIR, "generator_mapping.yaml"),
    )
    resolution = get(kwargs, :time_series_resolution, Dates.Hour(1))
    sys = PSY.System(rawsys; time_series_resolution = resolution, sys_kwargs...)
    interval = get(kwargs, :interval, Dates.Hour(24))
    horizon = get(kwargs, :horizon, 48)
    PSY.transform_single_time_series!(sys, horizon, interval)
    return sys
end

function build_RTS_GMLC_RT_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    RTS_GMLC_DIR = get_raw_data(; kwargs...)
    RTS_SRC_DIR = joinpath(RTS_GMLC_DIR, "RTS_Data", "SourceData")
    RTS_SIIP_DIR = joinpath(RTS_GMLC_DIR, "RTS_Data", "FormattedData", "SIIP")
    rawsys = PSY.PowerSystemTableData(
        RTS_SRC_DIR,
        100.0,
        joinpath(RTS_SIIP_DIR, "user_descriptors.yaml");
        timeseries_metadata_file = joinpath(RTS_SIIP_DIR, "timeseries_pointers.json"),
        generator_mapping_file = joinpath(RTS_SIIP_DIR, "generator_mapping.yaml"),
    )
    resolution = get(kwargs, :time_series_resolution, Dates.Minute(5))
    sys = PSY.System(rawsys; time_series_resolution = resolution, sys_kwargs...)
    interval = get(kwargs, :interval, Dates.Minute(5))
    horizon = get(kwargs, :horizon, 24)
    PSY.transform_single_time_series!(sys, horizon, interval)
    return sys
end

function build_RTS_GMLC_DA_sys_noTS(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    RTS_GMLC_DIR = get_raw_data(; kwargs...)
    RTS_SRC_DIR = joinpath(RTS_GMLC_DIR, "RTS_Data", "SourceData")
    RTS_SIIP_DIR = joinpath(RTS_GMLC_DIR, "RTS_Data", "FormattedData", "SIIP")
    rawsys = PSY.PowerSystemTableData(
        RTS_SRC_DIR,
        100.0,
        joinpath(RTS_SIIP_DIR, "user_descriptors.yaml");
        timeseries_metadata_file = joinpath(RTS_SIIP_DIR, "timeseries_pointers.json"),
        generator_mapping_file = joinpath(RTS_SIIP_DIR, "generator_mapping.yaml"),
    )
    resolution = get(kwargs, :time_series_resolution, Dates.Hour(1))
    sys = PSY.System(rawsys; time_series_resolution = resolution, sys_kwargs...)
    return sys
end

function build_RTS_GMLC_RT_sys_noTS(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    RTS_GMLC_DIR = get_raw_data(; kwargs...)
    RTS_SRC_DIR = joinpath(RTS_GMLC_DIR, "RTS_Data", "SourceData")
    RTS_SIIP_DIR = joinpath(RTS_GMLC_DIR, "RTS_Data", "FormattedData", "SIIP")
    rawsys = PSY.PowerSystemTableData(
        RTS_SRC_DIR,
        100.0,
        joinpath(RTS_SIIP_DIR, "user_descriptors.yaml");
        timeseries_metadata_file = joinpath(RTS_SIIP_DIR, "timeseries_pointers.json"),
        generator_mapping_file = joinpath(RTS_SIIP_DIR, "generator_mapping.yaml"),
    )
    resolution = get(kwargs, :time_series_resolution, Dates.Minute(5))
    sys = PSY.System(rawsys; time_series_resolution = resolution, sys_kwargs...)
    return sys
end

function make_modified_RTS_GMLC_sys(resolution::Dates.TimePeriod = Hour(1); kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    RTS_GMLC_DIR = get_raw_data(; kwargs...)
    RTS_SRC_DIR = joinpath(RTS_GMLC_DIR, "RTS_Data", "SourceData")
    RTS_SIIP_DIR = joinpath(RTS_GMLC_DIR, "RTS_Data", "FormattedData", "SIIP")
    DISPATCH_INCREASE = 2.0
    FIX_DECREASE = 0.3

    rawsys = PSY.PowerSystemTableData(
        RTS_SRC_DIR,
        100.0,
        joinpath(RTS_SIIP_DIR, "user_descriptors.yaml");
        timeseries_metadata_file = joinpath(RTS_SIIP_DIR, "timeseries_pointers.json"),
        generator_mapping_file = joinpath(RTS_SIIP_DIR, "generator_mapping.yaml"),
    )

    sys = PSY.System(rawsys; time_series_resolution = resolution, sys_kwargs...)
    PSY.set_units_base_system!(sys, "SYSTEM_BASE")
    res_up = PSY.get_component(PSY.VariableReserve{PSY.ReserveUp}, sys, "Flex_Up")
    res_dn = PSY.get_component(PSY.VariableReserve{PSY.ReserveDown}, sys, "Flex_Down")
    PSY.remove_component!(sys, res_dn)
    PSY.remove_component!(sys, res_up)
    reg_reserve_up = PSY.get_component(PSY.VariableReserve, sys, "Reg_Up")
    PSY.set_requirement!(reg_reserve_up, 1.75 * PSY.get_requirement(reg_reserve_up))
    reg_reserve_dn = PSY.get_component(PSY.VariableReserve, sys, "Reg_Down")
    PSY.set_requirement!(reg_reserve_dn, 1.75 * PSY.get_requirement(reg_reserve_dn))
    spin_reserve_R1 = PSY.get_component(PSY.VariableReserve, sys, "Spin_Up_R1")
    spin_reserve_R2 = PSY.get_component(PSY.VariableReserve, sys, "Spin_Up_R2")
    spin_reserve_R3 = PSY.get_component(PSY.VariableReserve, sys, "Spin_Up_R3")
    for g in PSY.get_components(
        x -> PSY.get_prime_mover(x) in [PSY.PrimeMovers.CT, PSY.PrimeMovers.CC],
        PSY.ThermalStandard,
        sys,
    )
        if PSY.get_fuel(g) == PSY.ThermalFuels.DISTILLATE_FUEL_OIL
            PSY.remove_component!(sys, g)
            continue
        end
        g.operation_cost.shut_down = g.operation_cost.start_up / 2.0
        if PSY.get_base_power(g) > 3
            continue
        end
        PSY.clear_services!(g)
        PSY.add_service!(g, reg_reserve_dn)
        PSY.add_service!(g, reg_reserve_up)
    end
    #Remove units that make no sense to include
    names = [
        "114_SYNC_COND_1",
        "314_SYNC_COND_1",
        "313_STORAGE_1",
        "214_SYNC_COND_1",
        "212_CSP_1",
    ]
    for d in PSY.get_components(x -> x.name ∈ names, PSY.Generator, sys)
        PSY.remove_component!(sys, d)
    end
    for br in PSY.get_components(PSY.DCBranch, sys)
        PSY.remove_component!(sys, br)
    end
    for d in PSY.get_components(PSY.Storage, sys)
        PSY.remove_component!(sys, d)
    end
    # Remove large Coal and Nuclear from reserves
    for d in PSY.get_components(
        x -> (occursin(r"STEAM|NUCLEAR", PSY.get_name(x))),
        PSY.ThermalStandard,
        sys,
    )
        PSY.get_fuel(d) == PSY.ThermalFuels.COAL &&
            (PSY.set_ramp_limits!(d, (up = 0.001, down = 0.001)))
        if PSY.get_fuel(d) == PSY.ThermalFuels.DISTILLATE_FUEL_OIL
            PSY.remove_component!(sys, d)
            continue
        end
        PSY.get_operation_cost(d).shut_down = PSY.get_operation_cost(d).start_up / 2.0
        if PSY.get_rating(d) < 3
            PSY.set_status!(d, false)
            PSY.set_status!(d, false)
            PSY.set_active_power!(d, 0.0)
            continue
        end
        PSY.clear_services!(d)
        if PSY.get_fuel(d) == PSY.ThermalFuels.NUCLEAR
            PSY.set_ramp_limits!(d, (up = 0.0, down = 0.0))
            PSY.set_time_limits!(d, (up = 4380.0, down = 4380.0))
        end
    end
    for d in PSY.get_components(PSY.RenewableDispatch, sys)
        PSY.clear_services!(d)
    end

    # Add Hydro to regulation reserves
    for d in PSY.get_components(PSY.HydroEnergyReservoir, sys)
        PSY.remove_component!(sys, d)
    end

    for d in PSY.get_components(PSY.HydroDispatch, sys)
        PSY.clear_services!(d)
    end

    for g in PSY.get_components(
        x -> PSY.get_prime_mover(x) == PSY.PrimeMovers.PVe,
        PSY.RenewableDispatch,
        sys,
    )
        rat_ = PSY.get_rating(g)
        PSY.set_rating!(g, DISPATCH_INCREASE * rat_)
    end

    for g in PSY.get_components(
        x -> PSY.get_prime_mover(x) == PSY.PrimeMovers.PVe,
        PSY.RenewableFix,
        sys,
    )
        rat_ = PSY.get_rating(g)
        PSY.set_rating!(g, FIX_DECREASE * rat_)
    end

    return sys
end

function build_modified_RTS_GMLC_DA_sys(; kwargs...)
    sys = make_modified_RTS_GMLC_sys(; kwargs...)
    PSY.transform_single_time_series!(sys, 48, Hour(24))
    return sys
end

function build_modified_RTS_GMLC_DA_sys_noTS(; kwargs...)
    sys = make_modified_RTS_GMLC_sys(; kwargs...)
    return sys
end

function build_modified_RTS_GMLC_realization_sys(; kwargs...)
    sys = make_modified_RTS_GMLC_sys(Minute(5); kwargs...)
    # Add area renewable energy forecasts for RT model
    area_mapping = PSY.get_aggregation_topology_mapping(PSY.Area, sys)
    for (k, buses_in_area) in area_mapping
        k == "1" && continue
        PSY.remove_component!(sys, PSY.get_component(PSY.Area, sys, k))
        for b in buses_in_area
            PSY.set_area!(b, PSY.get_component(PSY.Area, sys, "1"))
        end
    end
    return sys
end

function build_modified_RTS_GMLC_RT_sys(; kwargs...)
    sys = build_modified_RTS_GMLC_realization_sys(; kwargs...)
    PSY.transform_single_time_series!(sys, 12, Minute(15))
    return sys
end

function build_modified_tamu_ercot_da_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    system_path = joinpath(data_dir, "DA_sys.json")
    sys = System(system_path; sys_kwargs...)
    return sys
end

function build_two_zone_5_bus(; kwargs...)
    ## System with 10 buses ######################################################
    """
    It is composed by 2 identical 5-bus systems connected by a DC line
    """

    # Buses
    nodes10() = [
        Bus(1, "nodeA", "PV", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing),
        Bus(2, "nodeB", "PQ", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing),
        Bus(3, "nodeC", "PV", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing),
        Bus(4, "nodeD", "REF", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing),
        Bus(5, "nodeE", "PV", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing),
        Bus(6, "nodeA2", "PV", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing),
        Bus(7, "nodeB2", "PQ", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing),
        Bus(8, "nodeC2", "PV", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing),
        Bus(9, "nodeD2", "REF", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing),
        Bus(10, "nodeE2", "PV", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing),
    ]

    # Lines
    branches10_ac(nodes10) = [
        Line(
            "nodeA-nodeB",
            true,
            0.0,
            0.0,
            Arc(; from = nodes10[1], to = nodes10[2]),
            0.00281,
            0.0281,
            (from = 0.00356, to = 0.00356),
            2.0,
            (min = -0.7, max = 0.7),
        ),
        Line(
            "nodeA-nodeD",
            true,
            0.0,
            0.0,
            Arc(; from = nodes10[1], to = nodes10[4]),
            0.00304,
            0.0304,
            (from = 0.00329, to = 0.00329),
            2.0,
            (min = -0.7, max = 0.7),
        ),
        Line(
            "nodeA-nodeE",
            true,
            0.0,
            0.0,
            Arc(; from = nodes10[1], to = nodes10[5]),
            0.00064,
            0.0064,
            (from = 0.01563, to = 0.01563),
            18.8120,
            (min = -0.7, max = 0.7),
        ),
        Line(
            "nodeB-nodeC",
            true,
            0.0,
            0.0,
            Arc(; from = nodes10[2], to = nodes10[3]),
            0.00108,
            0.0108,
            (from = 0.00926, to = 0.00926),
            11.1480,
            (min = -0.7, max = 0.7),
        ),
        Line(
            "nodeC-nodeD",
            true,
            0.0,
            0.0,
            Arc(; from = nodes10[3], to = nodes10[4]),
            0.00297,
            0.0297,
            (from = 0.00337, to = 0.00337),
            40.530,
            (min = -0.7, max = 0.7),
        ),
        Line(
            "nodeD-nodeE",
            true,
            0.0,
            0.0,
            Arc(; from = nodes10[4], to = nodes10[5]),
            0.00297,
            0.0297,
            (from = 0.00337, to = 0.00337),
            2.00,
            (min = -0.7, max = 0.7),
        ),
        Line(
            "nodeA2-nodeB2",
            true,
            0.0,
            0.0,
            Arc(; from = nodes10[6], to = nodes10[7]),
            0.00281,
            0.0281,
            (from = 0.00356, to = 0.00356),
            2.0,
            (min = -0.7, max = 0.7),
        ),
        Line(
            "nodeA2-nodeD2",
            true,
            0.0,
            0.0,
            Arc(; from = nodes10[6], to = nodes10[9]),
            0.00304,
            0.0304,
            (from = 0.00329, to = 0.00329),
            2.0,
            (min = -0.7, max = 0.7),
        ),
        Line(
            "nodeA2-nodeE2",
            true,
            0.0,
            0.0,
            Arc(; from = nodes10[6], to = nodes10[10]),
            0.00064,
            0.0064,
            (from = 0.01563, to = 0.01563),
            18.8120,
            (min = -0.7, max = 0.7),
        ),
        Line(
            "nodeB2-nodeC2",
            true,
            0.0,
            0.0,
            Arc(; from = nodes10[7], to = nodes10[8]),
            0.00108,
            0.0108,
            (from = 0.00926, to = 0.00926),
            11.1480,
            (min = -0.7, max = 0.7),
        ),
        Line(
            "nodeC2-nodeD2",
            true,
            0.0,
            0.0,
            Arc(; from = nodes10[8], to = nodes10[9]),
            0.00297,
            0.0297,
            (from = 0.00337, to = 0.00337),
            40.530,
            (min = -0.7, max = 0.7),
        ),
        Line(
            "nodeD2-nodeE2",
            true,
            0.0,
            0.0,
            Arc(; from = nodes10[9], to = nodes10[10]),
            0.00297,
            0.0297,
            (from = 0.00337, to = 0.00337),
            2.00,
            (min = -0.7, max = 0.7),
        ),
        HVDCLine(
            "nodeC-nodeC2",
            true,
            0.0,
            Arc(; from = nodes10[3], to = nodes10[8]),
            (min = -2.0, max = 2.0),
            (min = -2.0, max = 2.0),
            (min = -2.0, max = 2.0),
            (min = -2.0, max = 2.0),
            (l0 = 0.0, l1 = 0.0),
        ),
    ]

    # Generators
    thermal_generators10(nodes10) = [
        ThermalStandard(;
            name = "Alta",
            available = true,
            status = true,
            bus = nodes10[1],
            active_power = 0.40,
            reactive_power = 0.010,
            rating = 0.5,
            prime_mover = PrimeMovers.ST,
            fuel = ThermalFuels.COAL,
            active_power_limits = (min = 0.0, max = 0.40),
            reactive_power_limits = (min = -0.30, max = 0.30),
            ramp_limits = nothing,
            time_limits = nothing,
            operation_cost = ThreePartCost((0.0, 14.0), 0.0, 4.0, 2.0),
            base_power = 100.0,
        ),
        ThermalStandard(;
            name = "Park City",
            available = true,
            status = true,
            bus = nodes10[1],
            active_power = 1.70,
            reactive_power = 0.20,
            rating = 2.2125,
            prime_mover = PrimeMovers.ST,
            fuel = ThermalFuels.COAL,
            active_power_limits = (min = 0.0, max = 1.70),
            reactive_power_limits = (min = -1.275, max = 1.275),
            ramp_limits = (up = 0.02 * 2.2125, down = 0.02 * 2.2125),
            time_limits = (up = 2.0, down = 1.0),
            operation_cost = ThreePartCost((0.0, 15.0), 0.0, 1.5, 0.75),
            base_power = 100.0,
        ),
        ThermalStandard(;
            name = "Solitude",
            available = true,
            status = true,
            bus = nodes10[3],
            active_power = 5.2,
            reactive_power = 1.00,
            rating = 5.2,
            prime_mover = PrimeMovers.ST,
            fuel = ThermalFuels.COAL,
            active_power_limits = (min = 0.0, max = 5.20),
            reactive_power_limits = (min = -3.90, max = 3.90),
            ramp_limits = (up = 0.012 * 5.2, down = 0.012 * 5.2),
            time_limits = (up = 3.0, down = 2.0),
            operation_cost = ThreePartCost((0.0, 30.0), 0.0, 3.0, 1.5),
            base_power = 100.0,
        ),
        ThermalStandard(;
            name = "Sundance",
            available = true,
            status = true,
            bus = nodes10[4],
            active_power = 2.0,
            reactive_power = 0.40,
            rating = 2.5,
            prime_mover = PrimeMovers.ST,
            fuel = ThermalFuels.COAL,
            active_power_limits = (min = 0.0, max = 2.0),
            reactive_power_limits = (min = -1.5, max = 1.5),
            ramp_limits = (up = 0.015 * 2.5, down = 0.015 * 2.5),
            time_limits = (up = 2.0, down = 1.0),
            operation_cost = ThreePartCost((0.0, 40.0), 0.0, 4.0, 2.0),
            base_power = 100.0,
        ),
        ThermalStandard(;
            name = "Brighton",
            available = true,
            status = true,
            bus = nodes10[5],
            active_power = 6.0,
            reactive_power = 1.50,
            rating = 0.75,
            prime_mover = PrimeMovers.ST,
            fuel = ThermalFuels.COAL,
            active_power_limits = (min = 0.0, max = 6.0),
            reactive_power_limits = (min = -4.50, max = 4.50),
            ramp_limits = (up = 0.015 * 7.5, down = 0.015 * 7.5),
            time_limits = (up = 5.0, down = 3.0),
            operation_cost = ThreePartCost((0.0, 10.0), 0.0, 1.5, 0.75),
            base_power = 100.0,
        ),
        ThermalStandard(;
            name = "Alta-2",
            available = true,
            status = true,
            bus = nodes10[6],
            active_power = 0.40,
            reactive_power = 0.010,
            rating = 0.5,
            prime_mover = PrimeMovers.ST,
            fuel = ThermalFuels.COAL,
            active_power_limits = (min = 0.0, max = 0.40),
            reactive_power_limits = (min = -0.30, max = 0.30),
            ramp_limits = nothing,
            time_limits = nothing,
            operation_cost = ThreePartCost((0.0, 14.0), 0.0, 4.0, 2.0),
            base_power = 100.0,
        ),
        ThermalStandard(;
            name = "Park City-2",
            available = true,
            status = true,
            bus = nodes10[6],
            active_power = 1.70,
            reactive_power = 0.20,
            rating = 2.2125,
            prime_mover = PrimeMovers.ST,
            fuel = ThermalFuels.COAL,
            active_power_limits = (min = 0.0, max = 1.70),
            reactive_power_limits = (min = -1.275, max = 1.275),
            ramp_limits = (up = 0.02 * 2.2125, down = 0.02 * 2.2125),
            time_limits = (up = 2.0, down = 1.0),
            operation_cost = ThreePartCost((0.0, 15.0), 0.0, 1.5, 0.75),
            base_power = 100.0,
        ),
        ThermalStandard(;
            name = "Solitude-2",
            available = true,
            status = true,
            bus = nodes10[8],
            active_power = 5.2,
            reactive_power = 1.00,
            rating = 5.2,
            prime_mover = PrimeMovers.ST,
            fuel = ThermalFuels.COAL,
            active_power_limits = (min = 0.0, max = 5.20),
            reactive_power_limits = (min = -3.90, max = 3.90),
            ramp_limits = (up = 0.012 * 5.2, down = 0.012 * 5.2),
            time_limits = (up = 3.0, down = 2.0),
            operation_cost = ThreePartCost((0.0, 30.0), 0.0, 3.0, 1.5),
            base_power = 100.0,
        ),
        ThermalStandard(;
            name = "Sundance-2",
            available = true,
            status = true,
            bus = nodes10[9],
            active_power = 2.0,
            reactive_power = 0.40,
            rating = 2.5,
            prime_mover = PrimeMovers.ST,
            fuel = ThermalFuels.COAL,
            active_power_limits = (min = 0.0, max = 2.0),
            reactive_power_limits = (min = -1.5, max = 1.5),
            ramp_limits = (up = 0.015 * 2.5, down = 0.015 * 2.5),
            time_limits = (up = 2.0, down = 1.0),
            operation_cost = ThreePartCost((0.0, 40.0), 0.0, 4.0, 2.0),
            base_power = 100.0,
        ),
        ThermalStandard(;
            name = "Brighton-2",
            available = true,
            status = true,
            bus = nodes10[10],
            active_power = 6.0,
            reactive_power = 1.50,
            rating = 0.75,
            prime_mover = PrimeMovers.ST,
            fuel = ThermalFuels.COAL,
            active_power_limits = (min = 0.0, max = 6.0),
            reactive_power_limits = (min = -4.50, max = 4.50),
            ramp_limits = (up = 0.015 * 7.5, down = 0.015 * 7.5),
            time_limits = (up = 5.0, down = 3.0),
            operation_cost = ThreePartCost((0.0, 10.0), 0.0, 1.5, 0.75),
            base_power = 100.0,
        ),
    ]

    # Loads
    loads10(nodes10) = [
        PowerLoad("Load-nodeB", true, nodes10[2], 3.0, 0.9861, 100.0, 3.0, 0.9861),
        PowerLoad("Load-nodeC", true, nodes10[3], 3.0, 0.9861, 100.0, 3.0, 0.9861),
        PowerLoad("Load-nodeD", true, nodes10[4], 4.0, 1.3147, 100.0, 4.0, 1.3147),
        PowerLoad("Load-nodeB2", true, nodes10[7], 3.0, 0.9861, 100.0, 3.0, 0.9861),
        PowerLoad("Load-nodeC2", true, nodes10[8], 3.0, 0.9861, 100.0, 3.0, 0.9861),
        PowerLoad("Load-nodeD2", true, nodes10[9], 4.0, 1.3147, 100.0, 4.0, 1.3147),
    ]

    # Load Timeseries
    loadbusB_ts_DA = [
        0.792729978
        0.723201574
        0.710952098
        0.677672816
        0.668249175
        0.67166919
        0.687608809
        0.711821241
        0.756320618
        0.7984057
        0.827836527
        0.840362459
        0.84511032
        0.834592803
        0.822949221
        0.816941743
        0.824079963
        0.905735139
        0.989967048
        1
        0.991227765
        0.960842114
        0.921465115
        0.837001437
    ]

    loadbusC_ts_DA = [
        0.831093782
        0.689863228
        0.666058513
        0.627033103
        0.624901388
        0.62858924
        0.650734211
        0.683424321
        0.750876413
        0.828347191
        0.884248576
        0.888523615
        0.87752169
        0.847534405
        0.8227661
        0.803809323
        0.813282799
        0.907575962
        0.98679848
        1
        0.990489904
        0.952520972
        0.906611479
        0.824307054
    ]

    loadbusD_ts_DA = [
        0.871297342
        0.670489749
        0.642812243
        0.630092987
        0.652991383
        0.671971681
        0.716278493
        0.770885833
        0.810075243
        0.85562361
        0.892440566
        0.910660449
        0.922135467
        0.898416969
        0.879816542
        0.896390855
        0.978598576
        0.96523761
        1
        0.969626503
        0.901212601
        0.81894251
        0.771004923
        0.717847996
    ]

    nodes = nodes10()

    sys = PSY.System(
        100.0,
        nodes,
        thermal_generators10(nodes),
        loads10(nodes),
        branches10_ac(nodes),
    )

    resolution = Dates.Hour(1)
    loads = PSY.get_components(PowerLoad, sys)
    for l in loads
        if occursin("nodeB", PSY.get_name(l))
            data = Dict(DateTime("2020-01-01T00:00:00") => loadbusB_ts_DA)
            PSY.add_time_series!(
                sys,
                l,
                Deterministic("max_active_power", data, resolution),
            )
        elseif occursin("nodeC", PSY.get_name(l))
            data = Dict(DateTime("2020-01-01T00:00:00") => loadbusC_ts_DA)
            PSY.add_time_series!(
                sys,
                l,
                Deterministic("max_active_power", data, resolution),
            )
        else
            data = Dict(DateTime("2020-01-01T00:00:00") => loadbusD_ts_DA)
            PSY.add_time_series!(
                sys,
                l,
                Deterministic("max_active_power", data, resolution),
            )
        end
    end
    return sys
end
