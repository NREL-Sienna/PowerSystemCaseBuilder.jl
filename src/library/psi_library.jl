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
    timeseries_dataset = HDF5.h5read(
        joinpath(PACKAGE_DIR, "PowerSystemsTestData", "5-bus", "PJM_5_BUS_7_DAYS.h5"),
        "Time Series Data",
    )
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
                PACKAGE_DIR,
                "PowerSystemsTestData",
                "5-bus",
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
                PACKAGE_DIR,
                "PowerSystemsTestData",
                "forecasts",
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
    timeseries_dataset = HDF5.h5read(
        joinpath(PACKAGE_DIR, "PowerSystemsTestData", "5-bus", "PJM_5_BUS_7_DAYS.h5"),
        "Time Series Data",
    )
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
                PACKAGE_DIR,
                "PowerSystemsTestData",
                "5-bus",
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
                PACKAGE_DIR,
                "PowerSystemsTestData",
                "forecasts",
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
            rawsys,
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
            rawsys,
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
    cost = PSY.StorageManagementCost(
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
        rawsys,
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
        rawsys,
        timeseries_metadata_file = joinpath(
            data_dir,
            "5bus_ts",
            "7day",
            "timeseries_pointers_rt_7day.json",
        ),
        time_series_in_memory = true,
        sys_kwargs...,
    )
    cost = PSY.StorageManagementCost(
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
        rawsys,
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
        rawsys,
        timeseries_metadata_file = joinpath(
            data_dir,
            "5bus_ts",
            "7day",
            "timeseries_pointers_wk_7day.json",
        ),
        time_series_in_memory = true,
        sys_kwargs...,
    )
    cost = PSY.StorageManagementCost(
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
        joinpath(RTS_SIIP_DIR, "user_descriptors.yaml"),
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
        joinpath(RTS_SIIP_DIR, "user_descriptors.yaml"),
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
        joinpath(RTS_SIIP_DIR, "user_descriptors.yaml"),
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
        PSY.ThermalStandard,
        sys,
        x -> PSY.get_prime_mover(x) in [PSY.PrimeMovers.CT, PSY.PrimeMovers.CC],
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
    for d in PSY.get_components(PSY.Generator, sys, x -> x.name ∈ names)
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
        PSY.ThermalStandard,
        sys,
        x -> (occursin(r"STEAM|NUCLEAR", PSY.get_name(x))),
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
        PSY.RenewableDispatch,
        sys,
        x -> PSY.get_prime_mover(x) == PSY.PrimeMovers.PVe,
    )
        rat_ = PSY.get_rating(g)
        PSY.set_rating!(g, DISPATCH_INCREASE * rat_)
    end

    for g in PSY.get_components(
        PSY.RenewableFix,
        sys,
        x -> PSY.get_prime_mover(x) == PSY.PrimeMovers.PVe,
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
