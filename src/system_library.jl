include(joinpath(PACKAGE_DIR, "data","data_5bus_pu.jl"))
include(joinpath(PACKAGE_DIR, "data","data_14bus_pu.jl"))

function build_c_sys5(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5 =
        PSY.System(100.0, nodes, thermal_generators5(nodes), loads5(nodes), branches5(nodes); sys_kwargs...)

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PowerLoad, c_sys5))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(load_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][ix]
            end
            add_time_series!(c_sys5, l, PSY.Deterministic("max_active_power", forecast_data))
        end
    end

    return c_sys5
end

function build_c_sys5_ml(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5_ml = PSY.System(
        100.0,
        nodes,
        thermal_generators5(nodes),
        loads5(nodes),
        branches5(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PowerLoad, c_sys5_ml))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(load_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_ml, l, PSY.Deterministic("max_active_power", forecast_data))
        end
    end

    return c_sys5_ml
end

function build_c_sys14(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes14()
    c_sys14 = PSY.System(
        100.0,
        nodes,
        thermal_generators14(nodes),
        loads14(nodes),
        branches14(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
        for (ix, l) in enumerate(PSY.get_components(PowerLoad, c_sys14))
            ini_time = TimeSeries.timestamp(timeseries_DA14[ix])[1]
            forecast_data[ini_time] = timeseries_DA14[ix]
            PSY.add_time_series!(c_sys14, l, PSY.Deterministic("max_active_power", forecast_data))
        end
    end

    return c_sys14
end

function build_c_sys5_re(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5_re = PSY.System(
        100.0,
        nodes,
        thermal_generators5(nodes),
        renewable_generators5(nodes),
        loads5(nodes),
        branches5(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_re))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(load_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_re, l, PSY.Deterministic("max_active_power", forecast_data))
        end
        for (ix, r) in enumerate(PSY.get_components(RenewableGen, c_sys5_re))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(ren_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = ren_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_re, r, PSY.Deterministic("max_active_power", forecast_data))
        end
    end

    if get(kwargs, :add_reserves, false)
        reserve_re = reserve5_re(PSY.get_components(PSY.RenewableDispatch, c_sys5_re))
        PSY.add_service!(c_sys5_re, reserve_re[1], PSY.get_components(PSY.RenewableDispatch, c_sys5_re))
        PSY.add_service!(
            c_sys5_re,
            reserve_re[2],
            [collect(PSY.get_components(PSY.RenewableDispatch, c_sys5_re))[end]],
        )
        # ORDC
        PSY.add_service!(c_sys5_re, reserve_re[3], PSY.get_components(PSY.RenewableDispatch, c_sys5_re))
        for (ix, serv) in enumerate(PSY.get_components(PSY.VariableReserve, c_sys5_re))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(Reserve_ts[t])[1]
                forecast_data[ini_time] = Reserve_ts[t]
            end
            PSY.add_time_series!(c_sys5_re, serv, PSY.Deterministic("requirement", forecast_data))
        end
        for (ix, serv) in enumerate(PSY.get_components(PSY.ReserveDemandCurve, c_sys5_re))
            forecast_data = SortedDict{Dates.DateTime, Vector{IS.PWL}}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(ORDC_cost_ts[t])[1]
                forecast_data[ini_time] = TimeSeries.values(ORDC_cost_ts[t])
            end
            resolution = TimeSeries.timestamp(ORDC_cost_ts[1])[2] - TimeSeries.timestamp(ORDC_cost_ts[1])[1]
            PSY.set_variable_cost!(
                c_sys5_re,
                serv,
                PSY.Deterministic("variable_cost", forecast_data, resolution),
            )
        end
    end

    return c_sys5_re
end

function build_c_sys5_re_only(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5_re_only = PSY.System(
        100.0,
        nodes,
        renewable_generators5(nodes),
        loads5(nodes),
        branches5(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_re_only))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(load_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(
                c_sys5_re_only,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, r) in enumerate(PSY.get_components(PSY.RenewableGen, c_sys5_re_only))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(ren_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = ren_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(
                c_sys5_re_only,
                r,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
    end

    return c_sys5_re_only
end

function build_c_sys5_hy(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5_hy = PSY.System(
        100.0,
        nodes,
        thermal_generators5(nodes),
        [hydro_generators5(nodes)[1]],
        loads5(nodes),
        branches5(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_hy))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(load_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_hy, l, PSY.Deterministic("max_active_power", forecast_data))
        end
        for (ix, r) in enumerate(PSY.get_components(PSY.HydroGen, c_sys5_hy))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(hydro_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = hydro_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_hy, r, PSY.Deterministic("max_active_power", forecast_data))
        end
    end

    return c_sys5_hy
end

function build_c_sys5_hyd(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5_hyd = PSY.System(
        100.0,
        nodes,
        thermal_generators5(nodes),
        [hydro_generators5(nodes)[2]],
        loads5(nodes),
        branches5(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_hyd))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(load_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(
                c_sys5_hyd,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, h) in enumerate(PSY.get_components(HydroGen, c_sys5_hyd))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(hydro_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = hydro_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(
                c_sys5_hyd,
                h,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, h) in enumerate(PSY.get_components(PSY.HydroEnergyReservoir, c_sys5_hyd))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(hydro_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = hydro_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_hyd, h, PSY.Deterministic("hydro_budget", forecast_data))
        end
        for (ix, h) in enumerate(PSY.get_components(PSY.HydroEnergyReservoir, c_sys5_hyd))
            forecast_data_inflow = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            forecast_data_target = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(hydro_timeseries_DA[t][ix])[1]
                forecast_data_inflow[ini_time] = hydro_timeseries_DA[t][ix] .* 0.8
                forecast_data_target[ini_time] = hydro_timeseries_DA[t][ix] .* 0.5
            end
            PSY.add_time_series!(c_sys5_hyd, h, PSY.Deterministic("inflow", forecast_data_inflow))
            PSY.add_time_series!(
                c_sys5_hyd,
                h,
                PSY.Deterministic("storage_target", forecast_data_target),
            )
        end
    end

    if get(kwargs, :add_reserves, false)
        reserve_hy = reserve5_hy(PSY.get_components(PSY.HydroEnergyReservoir, c_sys5_hyd))
        PSY.add_service!(
            c_sys5_hyd,
            reserve_hy[1],
            PSY.get_components(PSY.HydroEnergyReservoir, c_sys5_hyd),
        )
        PSY.add_service!(
            c_sys5_hyd,
            reserve_hy[2],
            [collect(PSY.get_components(PSY.HydroEnergyReservoir, c_sys5_hyd))[end]],
        )
        # ORDC curve
        PSY.add_service!(
            c_sys5_hyd,
            reserve_hy[3],
            PSY.get_components(PSY.HydroEnergyReservoir, c_sys5_hyd),
        )
        for (ix, serv) in enumerate(PSY.get_components(PSY.VariableReserve, c_sys5_hyd))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(Reserve_ts[t])[1]
                forecast_data[ini_time] = Reserve_ts[t]
            end
            PSY.add_time_series!(c_sys5_hyd, serv, PSY.Deterministic("requirement", forecast_data))
        end
        for (ix, serv) in enumerate(PSY.get_components(PSY.ReserveDemandCurve, c_sys5_hyd))
            forecast_data = SortedDict{Dates.DateTime, Vector{IS.PWL}}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(ORDC_cost_ts[t])[1]
                forecast_data[ini_time] = TimeSeries.values(ORDC_cost_ts[t])
            end
            resolution = TimeSeries.timestamp(ORDC_cost_ts[1])[2] - TimeSeries.timestamp(ORDC_cost_ts[1])[1]
            PSY.set_variable_cost!(
                c_sys5_hyd,
                serv,
                PSY.Deterministic("variable_cost", forecast_data, resolution),
            )
        end
    end

    return c_sys5_hyd
end

function build_c_sys5_bat(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    time_series_in_memory = get(kwargs, :time_series_in_memory, true)
    nodes = nodes5()
    c_sys5_bat = PSY.System(
        100.0,
        nodes,
        thermal_generators5(nodes),
        renewable_generators5(nodes),
        loads5(nodes),
        branches5(nodes),
        battery5(nodes);
        time_series_in_memory = time_series_in_memory,
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_bat))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(load_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(
                c_sys5_bat,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, r) in enumerate(PSY.get_components(PSY.RenewableGen, c_sys5_bat))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(ren_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = ren_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(
                c_sys5_bat,
                r,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
    end

    if get(kwargs, :add_reserves, false)
        reserve_bat = reserve5_re(PSY.get_components(PSY.RenewableDispatch, c_sys5_bat))
        PSY.add_service!(c_sys5_bat, reserve_bat[1], PSY.get_components(PSY.GenericBattery, c_sys5_bat))
        PSY.add_service!(c_sys5_bat, reserve_bat[2], PSY.get_components(PSY.GenericBattery, c_sys5_bat))
        # ORDC
        PSY.add_service!(c_sys5_bat, reserve_bat[3], PSY.get_components(PSY.GenericBattery, c_sys5_bat))
        for (ix, serv) in enumerate(PSY.get_components(PSY.VariableReserve, c_sys5_bat))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(Reserve_ts[t])[1]
                forecast_data[ini_time] = Reserve_ts[t]
            end
            PSY.add_time_series!(c_sys5_bat, serv, PSY.Deterministic("requirement", forecast_data))
        end
        for (ix, serv) in enumerate(PSY.get_components(PSY.ReserveDemandCurve, c_sys5_bat))
            forecast_data = SortedDict{Dates.DateTime, Vector{IS.PWL}}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(ORDC_cost_ts[t])[1]
                forecast_data[ini_time] = TimeSeries.values(ORDC_cost_ts[t])
            end
            resolution = TimeSeries.timestamp(ORDC_cost_ts[1])[2] - TimeSeries.timestamp(ORDC_cost_ts[1])[1]
            PSY.set_variable_cost!(
                c_sys5_bat,
                serv,
                PSY.Deterministic("variable_cost", forecast_data, resolution),
            )
        end
    end

    return c_sys5_bat
end

function build_c_sys5_il(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5_il = PSY.System(
        100.0,
        nodes,
        thermal_generators5(nodes),
        loads5(nodes),
        interruptible(nodes),
        branches5(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_il))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(load_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_il, l, PSY.Deterministic("max_active_power", forecast_data))
        end
        for (ix, i) in enumerate(PSY.get_components(PSY.InterruptibleLoad, c_sys5_il))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(Iload_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = Iload_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_il, i, PSY.Deterministic("max_active_power", forecast_data))
        end
    end

    if get(kwargs, :add_reserves, false)
        reserve_il = reserve5_il(PSY.get_components(PSY.InterruptibleLoad, c_sys5_il))
        PSY.add_service!(c_sys5_il, reserve_il[1], PSY.get_components(PSY.InterruptibleLoad, c_sys5_il))
        PSY.add_service!(
            c_sys5_il,
            reserve_il[2],
            [collect(PSY.get_components(PSY.InterruptibleLoad, c_sys5_il))[end]],
        )
        # ORDC
        PSY.add_service!(c_sys5_il, reserve_il[3], PSY.get_components(PSY.InterruptibleLoad, c_sys5_il))
        for (ix, serv) in enumerate(PSY.get_components(PSY.VariableReserve, c_sys5_il))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(Reserve_ts[ix])[1]
                forecast_data[ini_time] = Reserve_ts[t]
            end
            PSY.add_time_series!(c_sys5_il, serv, PSY.Deterministic("requirement", forecast_data))
        end
        for (ix, serv) in enumerate(PSY.get_components(PSY.ReserveDemandCurve, c_sys5_il))
            forecast_data = SortedDict{Dates.DateTime, Vector{IS.PWL}}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(ORDC_cost_ts[t])[1]
                forecast_data[ini_time] = TimeSeries.values(ORDC_cost_ts[t])
            end
            resolution = TimeSeries.timestamp(ORDC_cost_ts[1])[2] - TimeSeries.timestamp(ORDC_cost_ts[1])[1]
            PSY.set_variable_cost!(
                c_sys5_il,
                serv,
                PSY.Deterministic("variable_cost", forecast_data, resolution),
            )
        end
    end

    return c_sys5_il
end

function build_c_sys5_dc(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5_dc = PSY.System(
        100.0,
        nodes,
        thermal_generators5(nodes),
        renewable_generators5(nodes),
        loads5(nodes),
        branches5_dc(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_dc))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(load_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_dc, l, PSY.Deterministic("max_active_power", forecast_data))
        end
        for (ix, r) in enumerate(PSY.get_components(PSY.RenewableGen, c_sys5_dc))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(ren_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = ren_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_dc, r, PSY.Deterministic("max_active_power", forecast_data))
        end
    end

    return c_sys5_dc
end

function build_c_sys14_dc(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes14()
    c_sys14_dc = PSY.System(
        100.0,
        nodes,
        thermal_generators14(nodes),
        loads14(nodes),
        branches14_dc(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys14_dc))
            ini_time = TimeSeries.timestamp(timeseries_DA14[ix])[1]
            forecast_data[ini_time] = timeseries_DA14[ix]
            PSY.add_time_series!(
                c_sys14_dc,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
    end

    return c_sys14_dc
end

function build_c_sys5_reg(; kwargs...)
    nodes = nodes5()
    sys_kwargs = filter_kwargs(; kwargs...)
    c_sys5_reg =
        PSY.System(100.0, nodes, thermal_generators5(nodes), loads5(nodes), branches5(nodes), sys_kwargs...)

    area = PSY.Area("1")
    PSY.add_component!(c_sys5_reg, area)
    [PSY.set_area!(b, area) for b in PSY.get_components(PSY.Bus, c_sys5_reg)]
    AGC_service = PSY.AGC(
        name = "AGC_Area1",
        available = true,
        bias = 739.0,
        K_p = 2.5,
        K_i = 0.1,
        K_d = 0.0,
        delta_t = 4,
        area = first(PSY.get_components(PSY.Area, c_sys5_reg)),
    )
    #add_component!(c_sys5_reg, AGC_service)
    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_reg))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = TimeSeries.timestamp(load_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(
                c_sys5_reg,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (_, l) in enumerate(PSY.get_components(PSY.ThermalStandard, c_sys5_reg))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = PSY.TimeSeries.timestamp(load_timeseries_DA[t][1])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][1]
            end
            PSY.add_time_series!(
                c_sys5_reg,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
    end

    contributing_devices = Vector()
    for g in PSY.get_components(PSY.Generator, c_sys5_reg)
        droop =
            isa(g, PSY.ThermalStandard) ? 0.04 * PSY.get_base_power(g) : 0.05 * PSY.get_base_power(g)
        p_factor = (up = 1.0, dn = 1.0)
        t = PSY.RegulationDevice(g, participation_factor = p_factor, droop = droop)
        PSY.add_component!(c_sys5_reg, t)
        push!(contributing_devices, t)
    end
    PSY.add_service!(c_sys5_reg, AGC_service, contributing_devices)
    return c_sys5_reg
end

function build_sys_ramp_testing(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    node = PSY.Bus(1, "nodeA", "REF", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing)
    load = PSY.PowerLoad("Bus1", true, node, nothing, 0.4, 0.9861, 100.0, 1.0, 2.0)
    gen_ramp = [
        PSY.ThermalStandard(
            name = "Alta",
            available = true,
            status = true,
            bus = node,
            active_power = 0.20, # Active power
            reactive_power = 0.010,
            rating = 0.5,
            prime_mover = PSY.PrimeMovers.ST,
            fuel = PSY.ThermalFuels.COAL,
            active_power_limits = (min = 0.0, max = 0.40),
            reactive_power_limits = nothing,
            ramp_limits = nothing,
            time_limits = nothing,
            operation_cost = PSY.ThreePartCost((0.0, 1400.0), 0.0, 4.0, 2.0),
            base_power = 100.0,
        ),
        PSY.ThermalStandard(
            name = "Park City",
            available = true,
            status = true,
            bus = node,
            active_power = 0.70, # Active Power
            reactive_power = 0.20,
            rating = 2.0,
            prime_mover = PSY.PrimeMovers.ST,
            fuel = PSY.ThermalFuels.COAL,
            active_power_limits = (min = 0.7, max = 2.20),
            reactive_power_limits = nothing,
            ramp_limits = (up = 0.010625 * 2.0, down = 0.010625 * 2.0),
            time_limits = nothing,
            operation_cost = PSY.ThreePartCost((0.0, 1500.0), 0.0, 1.5, 0.75),
            base_power = 100.0,
        ),
    ]
    DA_ramp = collect(
        DateTime("1/1/2024  0:00:00", "d/m/y  H:M:S"):Hour(1):DateTime(
            "1/1/2024  4:00:00",
            "d/m/y  H:M:S",
        ),
    )
    ramp_load = [0.9, 1.1, 2.485, 2.175, 0.9]
    ts_dict = SortedDict(DA_ramp[1] => ramp_load)
    load_forecast_ramp = PSY.Deterministic("max_active_power", ts_dict, Hour(1))
    ramp_test_sys = PSY.System(100.0, sys_kwargs...)
    PSY.add_component!(ramp_test_sys, node)
    PSY.add_component!(ramp_test_sys, load)
    PSY.add_component!(ramp_test_sys, gen_ramp[1])
    PSY.add_component!(ramp_test_sys, gen_ramp[2])
    PSY.add_time_series!(ramp_test_sys, load, load_forecast_ramp)
    return ramp_test_sys
end

function build_c_sys5_uc(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5_uc = PSY.System(
        100.0,
        nodes,
        thermal_generators5_uc_testing(nodes),
        loads5(nodes),
        branches5(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_uc))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = timestamp(load_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_uc, l, PSY.Deterministic("max_active_power", forecast_data))
        end
        for (ix, r) in enumerate(PSY.get_components(PSY.RenewableGen, c_sys5_uc))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = timestamp(ren_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = ren_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_uc, r, PSY.Deterministic("max_active_power", forecast_data))
        end
        for (ix, i) in enumerate(PSY.get_components(PSY.InterruptibleLoad, c_sys5_uc))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = timestamp(Iload_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = Iload_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_uc, r, PSY.Deterministic("max_active_power", forecast_data))
        end
    end

    if get(kwargs, :add_reserves, false)
        reserve_uc = reserve5(PSY.get_components(PSY.ThermalStandard, c_sys5_uc))
        PSY.add_service!(c_sys5_uc, reserve_uc[1], PSY.get_components(PSY.ThermalStandard, c_sys5_uc))
        PSY.add_service!(
            c_sys5_uc,
            reserve_uc[2],
            [collect(PSY.get_components(PSY.ThermalStandard, c_sys5_uc))[end]],
        )
        PSY.add_service!(c_sys5_uc, reserve_uc[3], PSY.get_components(PSY.ThermalStandard, c_sys5_uc))
        # ORDC Curve
        PSY.add_service!(c_sys5_uc, reserve_uc[4], PSY.get_components(PSY.ThermalStandard, c_sys5_uc))
        for serv in PSY.get_components(PSY.VariableReserve, c_sys5_uc)
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = timestamp(Reserve_ts[t])[1]
                forecast_data[ini_time] = Reserve_ts[t]
            end
            PSY.add_time_series!(c_sys5_uc, serv, PSY.Deterministic("requirement", forecast_data))
        end
        for (ix, serv) in enumerate(PSY.get_components(PSY.ReserveDemandCurve, c_sys5_uc))
            forecast_data = SortedDict{Dates.DateTime, Vector{IS.PWL}}()
            for t in 1:2
                ini_time = timestamp(ORDC_cost_ts[t])[1]
                forecast_data[ini_time] = TimeSeries.values(ORDC_cost_ts[t])
            end
            resolution = timestamp(ORDC_cost_ts[1])[2] - timestamp(ORDC_cost_ts[1])[1]
            PSY.set_variable_cost!(
                c_sys5_uc,
                serv,
                PSY.Deterministic("variable_cost", forecast_data, resolution),
            )
        end
    end

    return c_sys5_uc
end

function build_c_sys5_pwl_uc(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    c_sys5_uc = build_c_sys5_uc(; sys_kwargs...)
    thermal = thermal_generators5_pwl(collect(PSY.get_components(PSY.Bus, c_sys5_uc)))
    for d in thermal
        PSY.add_component!(c_sys5_uc, d)
    end
    return c_sys5_uc
end

function build_c_sys5_ed(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5_ed = PSY.System(
        100.0,
        nodes,
        thermal_generators5_uc_testing(nodes),
        renewable_generators5(nodes),
        loads5(nodes),
        interruptible(nodes),
        branches5(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2 # loop over days
                ta = load_timeseries_DA[t][ix]
                for i in 1:length(ta) # loop over hours
                    ini_time = timestamp(ta[i]) #get the hour
                    data = when(load_timeseries_RT[t][ix], hour, hour(ini_time[1])) # get the subset ts for that hour
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(c_sys5_ed, l, PSY.Deterministic("max_active_power", forecast_data))
        end
        for (ix, l) in enumerate(PSY.get_components(PSY.RenewableGen, c_sys5_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2 # loop over days
                ta = load_timeseries_DA[t][ix]
                for i in 1:length(ta) # loop over hours
                    ini_time = timestamp(ta[i]) #get the hour
                    data = when(load_timeseries_RT[t][ix], hour, hour(ini_time[1])) # get the subset ts for that hour
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(c_sys5_ed, l, PSY.Deterministic("max_active_power", forecast_data))
        end
        for (ix, l) in enumerate(PSY.get_components(PSY.InterruptibleLoad, c_sys5_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2 # loop over days
                ta = load_timeseries_DA[t][ix]
                for i in 1:length(ta) # loop over hours
                    ini_time = timestamp(ta[i]) #get the hour
                    data = when(load_timeseries_RT[t][ix], hour, hour(ini_time[1])) # get the subset ts for that hour
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(c_sys5_ed, l, PSY.Deterministic("max_active_power", forecast_data))
        end
    end

    return c_sys5_ed
end

function build_c_sys5_pwl_ed(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    c_sys5_ed = build_c_sys5_ed(; sys_kwargs...)
    thermal = thermal_generators5_pwl(collect(PSY.get_components(PSY.Bus, c_sys5_ed)))
    for d in thermal
        PSY.add_component!(c_sys5_ed, d)
    end
    return c_sys5_ed
end

function build_c_sys5_pwl_ed_nonconvex(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    c_sys5_ed = build_c_sys5_ed(; sys_kwargs...)
    thermal = thermal_generators5_pwl_nonconvex(collect(PSY.get_components(PSY.Bus, c_sys5_ed)))
    for d in thermal
        PSY.add_component!(c_sys5_ed, d)
    end
    return c_sys5_ed
end

function build_init(gens, data)
    init = Vector{PSY.InitialCondition}(undef, length(collect(gens)))
    for (ix, g) in enumerate(gens)
        init[ix] = PSY.InitialCondition(
            g,
            PSI.UpdateRef{JuMP.VariableRef}(PSI.ACTIVE_POWER),
            data[ix],
            PSY.TimeStatusChange,
        )
    end
    return init
end

function build_c_sys5_hy_uc(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5_hy_uc = PSY.System(
        100.0,
        nodes,
        thermal_generators5_uc_testing(nodes),
        hydro_generators5(nodes),
        renewable_generators5(nodes),
        loads5(nodes),
        branches5(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_hy_uc))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = timestamp(load_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(
                c_sys5_hy_uc,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, h) in enumerate(PSY.get_components(PSY.HydroEnergyReservoir, c_sys5_hy_uc))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = timestamp(hydro_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = hydro_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(
                c_sys5_hy_uc,
                h,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, h) in enumerate(PSY.get_components(PSY.HydroEnergyReservoir, c_sys5_hy_uc))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = timestamp(hydro_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = hydro_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(
                c_sys5_hy_uc,
                h,
                PSY.Deterministic("storage_capacity", forecast_data),
            )
            PSY.add_time_series!(
                c_sys5_hy_uc,
                h,
                PSY.Deterministic("storage_target", forecast_data),
            )
        end
        for (ix, h) in enumerate(PSY.get_components(PSY.HydroEnergyReservoir, c_sys5_hy_uc))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = timestamp(hydro_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = hydro_timeseries_DA[t][ix] .* 0.8
            end
            PSY.add_time_series!(c_sys5_hy_uc, h, PSY.Deterministic("inflow", forecast_data))
        end
        for (ix, h) in enumerate(PSY.get_components(PSY.HydroDispatch, c_sys5_hy_uc))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = timestamp(hydro_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = hydro_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(
                c_sys5_hy_uc,
                h,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, r) in enumerate(PSY.get_components(PSY.RenewableGen, c_sys5_hy_uc))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = timestamp(ren_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = ren_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(
                c_sys5_hy_uc,
                r,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, i) in enumerate(PSY.get_components(PSY.InterruptibleLoad, c_sys5_hy_uc))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = timestamp(Iload_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = Iload_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(
                c_sys5_hy_uc,
                i,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
    end

    return c_sys5_hy_uc
end

function build_c_sys5_hy_ed(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5_hy_ed = PSY.System(
        100.0,
        nodes,
        thermal_generators5_uc_testing(nodes),
        hydro_generators5(nodes),
        renewable_generators5(nodes),
        loads5(nodes),
        interruptible(nodes),
        branches5(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_hy_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2 # loop over days
                ta = load_timeseries_DA[t][ix]
                for i in 1:length(ta) # loop over hours
                    ini_time = timestamp(ta[i]) #get the hour
                    data = when(load_timeseries_RT[t][ix], hour, hour(ini_time[1])) # get the subset ts for that hour
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(
                c_sys5_hy_ed,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, l) in enumerate(PSY.get_components(PSY.HydroEnergyReservoir, c_sys5_hy_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ta = hydro_timeseries_DA[t][ix]
                for i in 1:length(ta)
                    ini_time = timestamp(ta[i])
                    data = when(hydro_timeseries_RT[t][ix], hour, hour(ini_time[1]))
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(
                c_sys5_hy_ed,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, l) in enumerate(PSY.get_components(PSY.RenewableGen, c_sys5_hy_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ta = load_timeseries_DA[t][ix]
                for i in 1:length(ta)
                    ini_time = timestamp(ta[i])
                    data = when(load_timeseries_RT[t][ix], hour, hour(ini_time[1]))
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(
                c_sys5_hy_ed,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, l) in enumerate(PSY.get_components(PSY.HydroEnergyReservoir, c_sys5_hy_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ta = hydro_timeseries_DA[t][ix]
                for i in 1:length(ta)
                    ini_time = timestamp(ta[i])
                    data = when(hydro_timeseries_RT[t][ix], hour, hour(ini_time[1]))
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(
                c_sys5_hy_ed,
                l,
                PSY.Deterministic("storage_capacity", forecast_data),
            )
            PSY.add_time_series!(
                c_sys5_hy_ed,
                l,
                PSY.Deterministic("storage_target", forecast_data),
            )
        end
        for (ix, l) in enumerate(PSY.get_components(PSY.HydroEnergyReservoir, c_sys5_hy_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ta = hydro_timeseries_DA[t][ix]
                for i in 1:length(ta)
                    ini_time = timestamp(ta[i])
                    data = when(hydro_timeseries_RT[t][ix] .* 0.8, hour, hour(ini_time[1]))
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(c_sys5_hy_ed, l, PSY.Deterministic("inflow", forecast_data))
        end
        for (ix, l) in enumerate(PSY.get_components(PSY.InterruptibleLoad, c_sys5_hy_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ta = load_timeseries_DA[t][ix]
                for i in 1:length(ta)
                    ini_time = timestamp(ta[i])
                    data = when(load_timeseries_RT[t][ix], hour, hour(ini_time[1]))
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(
                c_sys5_hy_ed,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, l) in enumerate(PSY.get_components(PSY.HydroDispatch, c_sys5_hy_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ta = hydro_timeseries_DA[t][ix]
                for i in 1:length(ta)
                    ini_time = timestamp(ta[i])
                    data = when(hydro_timeseries_RT[t][ix], hour, hour(ini_time[1]))
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(
                c_sys5_hy_ed,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
    end

    return c_sys5_hy_ed
end

function build_c_sys5_phes_ed(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5_phes_ed = PSY.System(
        100.0,
        nodes,
        thermal_generators5_uc_testing(nodes),
        phes5(nodes),
        renewable_generators5(nodes),
        loads5(nodes),
        interruptible(nodes),
        branches5(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_phes_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2 # loop over days
                ta = load_timeseries_DA[t][ix]
                for i in 1:length(ta) # loop over hours
                    ini_time = timestamp(ta[i]) #get the hour
                    data = when(load_timeseries_RT[t][ix], hour, hour(ini_time[1])) # get the subset ts for that hour
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(
                c_sys5_phes_ed,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, l) in enumerate(PSY.get_components(PSY.HydroGen, c_sys5_phes_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ta = hydro_timeseries_DA[t][ix]
                for i in 1:length(ta)
                    ini_time = timestamp(ta[i])
                    data = when(hydro_timeseries_RT[t][ix], hour, hour(ini_time[1]))
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(
                c_sys5_phes_ed,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, l) in enumerate(PSY.get_components(PSY.RenewableGen, c_sys5_phes_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ta = load_timeseries_DA[t][ix]
                for i in 1:length(ta)
                    ini_time = timestamp(ta[i])
                    data = when(load_timeseries_RT[t][ix], hour, hour(ini_time[1]))
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(
                c_sys5_phes_ed,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
        for (ix, l) in enumerate(PSY.get_components(PSY.HydroPumpedStorage, c_sys5_phes_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ta = hydro_timeseries_DA[t][ix]
                for i in 1:length(ta)
                    ini_time = timestamp(ta[i])
                    data = when(hydro_timeseries_RT[t][ix], hour, hour(ini_time[1]))
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(
                c_sys5_phes_ed,
                l,
                PSY.Deterministic("storage_capacity", forecast_data),
            )
        end
        for (ix, l) in enumerate(PSY.get_components(PSY.HydroPumpedStorage, c_sys5_phes_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ta = hydro_timeseries_DA[t][ix]
                for i in 1:length(ta)
                    ini_time = timestamp(ta[i])
                    data = when(hydro_timeseries_RT[t][ix] .* 0.8, hour, hour(ini_time[1]))
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(c_sys5_phes_ed, l, PSY.Deterministic("inflow", forecast_data))
            PSY.add_time_series!(c_sys5_phes_ed, l, PSY.Deterministic("outflow", forecast_data))
        end
        for (ix, l) in enumerate(PSY.get_components(PSY.InterruptibleLoad, c_sys5_phes_ed))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ta = load_timeseries_DA[t][ix]
                for i in 1:length(ta)
                    ini_time = timestamp(ta[i])
                    data = when(load_timeseries_RT[t][ix], hour, hour(ini_time[1]))
                    forecast_data[ini_time[1]] = data
                end
            end
            PSY.add_time_series!(
                c_sys5_phes_ed,
                l,
                PSY.Deterministic("max_active_power", forecast_data),
            )
        end
    end

    return c_sys5_phes_ed
end

function build_c_sys5_pglib(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    nodes = nodes5()
    c_sys5_uc = PSY.System(
        100.0,
        nodes,
        thermal_generators5_uc_testing(nodes),
        thermal_pglib_generators5(nodes),
        loads5(nodes),
        branches5(nodes);
        time_series_in_memory = get(kwargs, :time_series_in_memory, true),
        sys_kwargs...,
    )

    if get(kwargs, :add_forecasts, true)
        forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
        for (ix, l) in enumerate(PSY.get_components(PSY.PowerLoad, c_sys5_uc))
            for t in 1:2
                ini_time = timestamp(load_timeseries_DA[t][ix])[1]
                forecast_data[ini_time] = load_timeseries_DA[t][ix]
            end
            PSY.add_time_series!(c_sys5_uc, l, PSY.Deterministic("max_active_power", forecast_data))
        end
    end

    if get(kwargs, :add_reserves, false)
        reserve_uc = reserve5(PSY.get_components(PSY.ThermalStandard, c_sys5_uc))
        PSY.add_service!(c_sys5_uc, reserve_uc[1], PSY.get_components(PSY.ThermalStandard, c_sys5_uc))
        PSY.add_service!(
            c_sys5_uc,
            reserve_uc[2],
            [collect(PSY.get_components(PSY.ThermalStandard, c_sys5_uc))[end]],
        )
        PSY.add_service!(c_sys5_uc, reserve_uc[3], PSY.get_components(PSY.ThermalStandard, c_sys5_uc))
        for (ix, serv) in enumerate(PSY.get_components(PSY.VariableReserve, c_sys5_uc))
            forecast_data = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
            for t in 1:2
                ini_time = timestamp(Reserve_ts[ix])[1]
                forecast_data[ini_time] = Reserve_ts[t]
            end
            PSY.add_time_series!(c_sys5_uc, serv, PSY.Deterministic("requirement", forecast_data))
        end
    end

    return c_sys5_uc
end

function build_sos_test_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    node = PSY.Bus(1, "nodeA", "PV", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing)
    load = PSY.PowerLoad("Bus1", true, node, nothing, 0.4, 0.9861, 100.0, 1.0, 2.0)
    gens_cost_sos = [
        PSY.ThermalStandard(
            name = "Alta",
            available = true,
            status = true,
            bus = node,
            active_power = 0.52,
            reactive_power = 0.010,
            rating = 0.5,
            prime_mover = PSY.PrimeMovers.ST,
            fuel = PSY.ThermalFuels.COAL,
            active_power_limits = (min = 0.22, max = 0.55),
            reactive_power_limits = nothing,
            time_limits = nothing,
            ramp_limits = nothing,
            operation_cost = PSY.ThreePartCost(
                [(1122.43, 0.22), (1617.43, 0.33), (1742.48, 0.44), (2075.88, 0.55)],
                0.0,
                5665.23,
                0.0,
            ),
            base_power = 100.0,
        ),
        PSY.ThermalStandard(
            name = "Park City",
            available = true,
            status = true,
            bus = node,
            active_power = 0.62,
            reactive_power = 0.20,
            rating = 2.2125,
            prime_mover = PSY.PrimeMovers.ST,
            fuel = PSY.ThermalFuels.COAL,
            active_power_limits = (min = 0.62, max = 1.55),
            reactive_power_limits = nothing,
            time_limits = nothing,
            ramp_limits = nothing,
            operation_cost = PSY.ThreePartCost(
                [(1500.19, 0.62), (2132.59, 0.929), (2829.875, 1.24), (2831.444, 1.55)],
                0.0,
                5665.23,
                0.0,
            ),
            base_power = 100.0,
        ),
    ]

    #Checks the data remains non-convex
    for g in gens_cost_sos
        @assert PSI.pwlparamcheck(PSY.get_operation_cost(g).variable) == false
    end

    DA_load_forecast = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
    ini_time = DateTime("1/1/2024  0:00:00", "d/m/y  H:M:S")
    cost_sos_load = [[1.3, 2.1], [1.3, 2.1]]
    for (ix, date) in enumerate(range(ini_time; length = 2, step = Hour(1)))
        DA_load_forecast[date] = TimeSeries.TimeArray([date, date + Hour(1)], cost_sos_load[ix])
    end
    load_forecast_cost_sos = PSY.Deterministic("max_active_power", DA_load_forecast)
    cost_test_sos_sys =
        PSY.System(100.0; sys_kwargs...)
        PSY.add_component!(cost_test_sos_sys, node)
        PSY.add_component!(cost_test_sos_sys, load)
        PSY.add_component!(cost_test_sos_sys, gens_cost_sos[1])
        PSY.add_component!(cost_test_sos_sys, gens_cost_sos[2])
        PSY.add_time_series!(cost_test_sos_sys, load, load_forecast_cost_sos)

    return cost_test_sos_sys
end

function build_pwl_test_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    node = PSY.Bus(1, "nodeA", "PV", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing)
    load = PSY.PowerLoad("Bus1", true, node, nothing, 0.4, 0.9861, 100.0, 1.0, 2.0)
    gens_cost = [
        PSY.ThermalStandard(
            name = "Alta",
            available = true,
            status = true,
            bus = node,
            active_power = 0.52,
            reactive_power = 0.010,
            rating = 0.5,
            prime_mover = PSY.PrimeMovers.ST,
            fuel = PSY.ThermalFuels.COAL,
            active_power_limits = (min = 0.22, max = 0.55),
            reactive_power_limits = nothing,
            time_limits = nothing,
            ramp_limits = nothing,
            operation_cost = PSY.ThreePartCost(
                [(589.99, 0.220), (884.99, 0.33), (1210.04, 0.44), (1543.44, 0.55)],
                532.44,
                5665.23,
                0.0,
            ),
            base_power = 100.0,
        ),
        PSY.ThermalStandard(
            name = "Park City",
            available = true,
            status = true,
            bus = node,
            active_power = 0.62,
            reactive_power = 0.20,
            rating = 221.25,
            prime_mover = PSY.PrimeMovers.ST,
            fuel = PSY.ThermalFuels.COAL,
            active_power_limits = (min = 0.62, max = 1.55),
            reactive_power_limits = nothing,
            time_limits = nothing,
            ramp_limits = nothing,
            operation_cost = PSY.ThreePartCost(
                [(1264.80, 0.62), (1897.20, 0.93), (2594.4787, 1.24), (3433.04, 1.55)],
                235.397,
                5665.23,
                0.0,
            ),
            base_power = 100.0,
        ),
    ]

    DA_load_forecast = SortedDict{Dates.DateTime, TimeSeries.TimeArray}()
    ini_time = DateTime("1/1/2024  0:00:00", "d/m/y  H:M:S")
    cost_sos_load = [[1.3, 2.1], [1.3, 2.1]]
    for (ix, date) in enumerate(range(ini_time; length = 2, step = Hour(1)))
        DA_load_forecast[date] = TimeSeries.TimeArray([date, date + Hour(1)], cost_sos_load[ix])
    end
    load_forecast_cost_sos = PSY.Deterministic("max_active_power", DA_load_forecast)
    cost_test_sys =
        PSY.System(100.0; sys_kwargs...)
    PSY.add_component!(cost_test_sys, node)
    PSY.add_component!(cost_test_sys, load)
    PSY.add_component!(cost_test_sys, gens_cost[1])
    PSY.add_component!(cost_test_sys, gens_cost[2])
    PSY.add_time_series!(cost_test_sys, load, load_forecast_cost_sos)
    return cost_test_sys
end

function build_duration_test_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    node = PSY.Bus(1, "nodeA", "PV", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing)
    load = PSY.PowerLoad("Bus1", true, node, nothing, 0.4, 0.9861, 100.0, 1.0, 2.0)
    DA_dur = collect(
        DateTime("1/1/2024  0:00:00", "d/m/y  H:M:S"):Hour(1):DateTime(
            "1/1/2024  6:00:00",
            "d/m/y  H:M:S",
        ),
    )
    gens_dur = [
        PSY.ThermalStandard(
            name = "Alta",
            available = true,
            status = true,
            bus = node,
            active_power = 0.40,
            reactive_power = 0.010,
            rating = 0.5,
            prime_mover = PSY.PrimeMovers.ST,
            fuel = PSY.ThermalFuels.COAL,
            active_power_limits = (min = 0.3, max = 0.9),
            reactive_power_limits = nothing,
            ramp_limits = nothing,
            time_limits = (up = 4, down = 2),
            operation_cost = PSY.ThreePartCost((0.0, 1400.0), 0.0, 4.0, 2.0),
            base_power = 100.0,
            time_at_status = 2.0,
        ),
        PSY.ThermalStandard(
            name = "Park City",
            available = true,
            status = false,
            bus = node,
            active_power = 1.70,
            reactive_power = 0.20,
            rating = 2.2125,
            prime_mover = PSY.PrimeMovers.ST,
            fuel = PSY.ThermalFuels.COAL,
            active_power_limits = (min = 0.7, max = 2.2),
            reactive_power_limits = nothing,
            ramp_limits = nothing,
            time_limits = (up = 6, down = 4),
            operation_cost = PSY.ThreePartCost((0.0, 1500.0), 0.0, 1.5, 0.75),
            base_power = 100.0,
            time_at_status = 3.0,
        ),
    ]

    duration_load = [0.3, 0.6, 0.8, 0.7, 1.7, 0.9, 0.7]
    load_data = SortedDict(DA_dur[1] => TimeSeries.TimeArray(DA_dur, duration_load))
    load_forecast_dur = PSY.Deterministic("max_active_power", load_data)
    duration_test_sys =
        PSY.System(100.0; sys_kwargs...)
    PSY.add_component!(duration_test_sys, node)
    PSY.add_component!(duration_test_sys, load)
    PSY.add_component!(duration_test_sys, gens_dur[1])
    PSY.add_component!(duration_test_sys, gens_dur[2])
    PSY.add_time_series!(duration_test_sys, load, load_forecast_dur)

    return duration_test_sys
end

function build_pwl_marketbid_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    node = PSY.Bus(1, "nodeA", "PV", 0, 1.0, (min = 0.9, max = 1.05), 230, nothing, nothing)
    load = PSY.PowerLoad("Bus1", true, node, nothing, 0.4, 0.9861, 100.0, 1.0, 2.0)
    gens_cost = [
        PSY.ThermalStandard(
            name = "Alta",
            available = true,
            status = true,
            bus = node,
            active_power = 0.52,
            reactive_power = 0.010,
            rating = 0.5,
            prime_mover = PSY.PrimeMovers.ST,
            fuel = PSY.ThermalFuels.COAL,
            active_power_limits = (min = 0.22, max = 0.55),
            reactive_power_limits = nothing,
            time_limits = nothing,
            ramp_limits = nothing,
            operation_cost = PSY.MarketBidCost(
                no_load = 0.0,
                start_up = (hot = 0.0, warm = 0.0, cold = 0.0),
                shut_down = 0.0,
            ),
            base_power = 100.0,
        ),
        PSY.ThermalMultiStart(
            name = "115_STEAM_1",
            available = true,
            status = true,
            bus = node,
            active_power = 0.05,
            reactive_power = 0.010,
            rating = 0.12,
            prime_mover = PSY.PrimeMovers.ST,
            fuel = PSY.ThermalFuels.COAL,
            active_power_limits = (min = 0.05, max = 0.12),
            reactive_power_limits = (min = -0.30, max = 0.30),
            ramp_limits = (up = 0.2 * 0.12, down = 0.2 * 0.12),
            power_trajectory = (startup = 0.05, shutdown = 0.05),
            time_limits = (up = 4.0, down = 2.0),
            start_time_limits = (hot = 2.0, warm = 4.0, cold = 12.0),
            start_types = 3,
            operation_cost = PSY.MarketBidCost(
                no_load = 0.0,
                start_up = (hot = 393.28, warm = 455.37, cold = 703.76),
                shut_down = 0.0,
            ),
            base_power = 100.0,
        ),
    ]
    ini_time = DateTime("1/1/2024  0:00:00", "d/m/y  H:M:S")
    DA_load_forecast = Dict{Dates.DateTime, TimeSeries.TimeArray}()
    market_bid_gen1_data = Dict(
        ini_time => [
            [(589.99, 0.220), (884.99, 0.33), (1210.04, 0.44), (1543.44, 0.55)],
            [(589.99, 0.220), (884.99, 0.33), (1210.04, 0.44), (1543.44, 0.55)],
        ],
        ini_time + Hour(1) => [
            [(589.99, 0.220), (884.99, 0.33), (1210.04, 0.44), (1543.44, 0.55)],
            [(589.99, 0.220), (884.99, 0.33), (1210.04, 0.44), (1543.44, 0.55)],
        ],
    )
    market_bid_gen1 = PSY.Deterministic(
        name = "variable_cost",
        data = market_bid_gen1_data,
        resolution = Hour(1),
    )
    market_bid_gen2_data = Dict(
        ini_time => [
            [(0.0, 0.05), (290.1, 0.0733), (582.72, 0.0967), (894.1, 0.120)],
            [(0.0, 0.05), (300.1, 0.0733), (600.72, 0.0967), (900.1, 0.120)],
        ],
        ini_time + Hour(1) => [
            [(0.0, 0.05), (290.1, 0.0733), (582.72, 0.0967), (894.1, 0.120)],
            [(0.0, 0.05), (300.1, 0.0733), (600.72, 0.0967), (900.1, 0.120)],
        ],
    )
    market_bid_gen2 = PSY.Deterministic(
        name = "variable_cost",
        data = market_bid_gen2_data,
        resolution = Hour(1),
    )
    market_bid_load = [[1.3, 2.1], [1.3, 2.1]]
    for (ix, date) in enumerate(range(ini_time; length = 2, step = Hour(1)))
        DA_load_forecast[date] = TimeSeries.TimeArray([date, date + Hour(1)], market_bid_load[ix])
    end
    load_forecast_cost_market_bid = PSY.Deterministic("max_active_power", DA_load_forecast)
    cost_test_sys =
        PSY.System(100.0; sys_kwargs...)
    PSY.add_component!(cost_test_sys, node)
    PSY.add_component!(cost_test_sys, load)
    PSY.add_component!(cost_test_sys, gens_cost[1])
    PSY.add_component!(cost_test_sys, gens_cost[2])
    PSY.add_time_series!(cost_test_sys, load, load_forecast_cost_market_bid)
    PSY.set_variable_cost!(cost_test_sys, gens_cost[1], market_bid_gen1)
    PSY.set_variable_cost!(cost_test_sys, gens_cost[2], market_bid_gen2)
    return cost_test_sys
end

############# Test System from TestData #############
function build_5_bus_hydro_uc_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    rawsys = PSY.PowerSystemTableData(
        joinpath(data_dir, "5-bus-hydro"),
        100.0,
        joinpath(data_dir, "5-bus-hydro", "user_descriptors.yaml");
        generator_mapping_file = joinpath(data_dir, "5-bus-hydro", "generator_mapping.yaml"),
    )
    c_sys5_hy_uc = PSY.System(
        rawsys,
        timeseries_metadata_file = joinpath(
                data_dir,
                "forecasts",
                "5bus_ts",
                "7day",
                "timeseries_pointers_da_7day.json",
            ),
        time_series_in_memory = true,
        sys_kwargs...,
    )
    PSY.transform_single_time_series!(c_sys5_hy_uc, 24, Hour(24))

    return c_sys5_hy_uc
end

function build_5_bus_hydro_ed_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    rawsys = PSY.PowerSystemTableData(
        joinpath(data_dir, "5-bus-hydro"),
        100.0,
        joinpath(data_dir, "5-bus-hydro", "user_descriptors.yaml");
        generator_mapping_file = joinpath(data_dir, "5-bus-hydro", "generator_mapping.yaml"),
    )
    c_sys5_hy_ed = PSY.System(
        rawsys,
        timeseries_metadata_file = joinpath(
            data_dir,
            "forecasts",
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

function build_5_bus_hydro_wk_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    c_sys5_hy_wk = System(rawsys,  sys_kwargs...)
    # TODO: better construction  of the time series data
    return
end

function build_psse_RTS_GMLC_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(data_dir), sys_kwargs...)

    return sys
end

function build_test_RTS_GMLC_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    RTS_GMLC_DIR = get_raw_data(; kwargs...)
    rawsys = PSY.PowerSystemTableData(
        RTS_GMLC_DIR,
        100.0,
        joinpath(RTS_GMLC_DIR, "user_descriptors.yaml"),
        timeseries_metadata_file = joinpath(RTS_GMLC_DIR, "timeseries_pointers.json"),
        generator_mapping_file = joinpath(RTS_GMLC_DIR, "generator_mapping.yaml"),
    )
    sys = PSY.System(rawsys; time_series_resolution = Dates.Hour(1), sys_kwargs...);
    PSY.transform_single_time_series!(sys, 24, Dates.Hour(24));

    return sys
end

function build_US_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = joinpath(PACKAGE_DIR, "data", "psse_raw",  "RTS-GMLC.RAW")
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    # TODO
    return sys
end

function build_ACTIVSg10k_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)

    return sys
end

function build_ACTIVSg70k_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)

    return sys
end

function build_psse_ACTIVSg2000_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    file_path = joinpath(data_dir, "ACTIVSg2000",  "ACTIVSg2000.RAW")
    dyr_file = joinpath(data_dir, "psse_dyr",  "ACTIVSg2000_dynamics.dyr")
    sys = PSY.System(PSY.PowerModelsData(file_path, dyr_file), sys_kwargs...)

    return sys
end

function build_matpower_ACTIVSg2000_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_ACTIVSg10k_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case2_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case3_tnep_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case5_asym_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case5_dc_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case5_gap_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case5_pwlc_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case5_re_intid_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case5_re_uc_pwl_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case5_re_uc_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case5_re_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case5_th_intid_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case5_tnep_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case5_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case6_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case7_tplgy_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case14_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case24_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case30_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_frankenstein_00_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_RTS_GMLC_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_matpower_case5_strg_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_case3_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_case5_alc_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_case5_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_case7_tplgy_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_case14_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_case24_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_case30_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_case73_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_frankenstein_00_2_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_frankenstein_00_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_frankenstein_20_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_frankenstein_70_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_parser_test_a_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_parser_test_b_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_parser_test_c_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_parser_test_d_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_parser_test_e_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_parser_test_f_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_parser_test_g_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_parser_test_h_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_parser_test_i_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_parser_test_j_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_three_winding_mag_test_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_three_winding_test_2_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_three_winding_test_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_two_winding_mag_test_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_pti_two_terminal_hvdc_test_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path))
    return sys
end

function build_pti_vsc_hvdc_test_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    file_path = get_raw_data(; kwargs...)
    sys = PSY.System(PSY.PowerModelsData(file_path), sys_kwargs...)
    return sys
end

function build_psse_Benchmark_4ger_33_2015_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    file_path = joinpath(data_dir, "psse_raw", "Benchmark_4ger_33_2015.raw")
    dyr_file = joinpath(data_dir, "psse_dyr", "Benchmark_4ger_33_2015.dyr")
    sys = PSY.System(PSY.PowerModelsData(file_path, dyr_file), sys_kwargs...)
    return sys
end

function build_psse_OMIB_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    file_path = joinpath(data_dir, "psse_raw", "OMIB.raw")
    dyr_file = joinpath(data_dir, "psse_dyr", "OMIB.dyr")
    sys = PSY.System(PSY.PowerModelsData(file_path, dyr_file), sys_kwargs...)
    return sys
end

function build_psse_3bus_gen_cls_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    file_path = joinpath(data_dir, "ThreeBusNetwork.raw")
    dyr_file = joinpath(data_dir, "TestGENCLS.dyr")
    sys = PSY.System(PSY.PowerModelsData(file_path, dyr_file), sys_kwargs...)
    return sys
end

function build_psse_3bus_no_cls_sys(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    file_path = joinpath(data_dir, "ThreeBusNetwork.raw")
    dyr_file = joinpath(data_dir, "Test-NoCLS.dyr")
    sys = PSY.System(PSY.PowerModelsData(file_path, dyr_file), sys_kwargs...)
    return sys
end
