"""
Building PSILibrary scripts.
Making the set of components we place on the base 5-bus system fully customizable.
- Start with building a baseline system with buses and lines.
- Then call on add_components for each component type we want.
- StandardLoad
- ThermalStandard
- RenewableDispatch
- RenewableNonDispatch
"""

function build_sys5_nodes(; add_forecasts, raw_data, sys_kwargs...) #might remove kwargs
    nodes = nodes5()
    c_sys5 = PSY.System(
        100.0,
        nodes,
        branches5(nodes); # this is in PowerSystemsTestData/psy_data
        sys_kwargs..., 
    )
    return c_sys5
end

function add_ThermalStandard!(sys)
    buses = get_components(ACBus,sys) |> collect
    add_components!(sys,thermal_generators5(buses))
end

function add_StandardLoad!(sys)
    buses = get_components(ACBus,sys) |> collect
    add_components!(sys,loads5(buses))
end

function add_RenewableDispatch!(sys)
    buses = get_components(ACBus,sys) |> collect
    add_components!(sys,renewable_dispatch5(buses))
end

function add_HydroDispatch!(sys)
    buses = get_components(ACBus,sys) |> collect
    add_components!(sys,hydro_dispatch5(buses))
end

function add_RenewableNonDispatch!(sys)
    buses = get_components(ACBus,sys) |> collect
    add_components!(sys,renewable_nondispatch5(buses))
end

function add_EnergyReservoirStorage!(sys)
    buses = get_components(ACBus,sys) |> collect
    add_components!(sys,battery5(buses))
end

function add_InterruptiblePowerLoad!(sys)
    buses = get_components(ACBus,sys) |> collect
    add_components!(sys,interruptible(buses))
end

function add_HydroReservoirs!(sys,hydroLevelDataType)
    buses = get_components(ACBus,sys) |> collect
    add_components!(sys,cabincreekreservoirs(buses,hydroLevelDataType))
end

function add_HydroTurbine!(sys)
    buses = get_components(ACBus,sys) |> collect
    add_components!(sys,cabincreeknopump(buses,sys))
end

function add_HydroPumpTurbine!(sys)
    buses = get_components(ACBus,sys) |> collect
    add_components!(sys,cabincreekpump(buses,sys))
end

"""build the pjm 5bus system and select the desired component types to be added in. \\
inputs: \\
- raw_data: directory where PowerSystemsTestData is kept \\
- add_forecasts: true/false \\
- decision_model_type: "uc" or "ed", or nothing, determines resolution of timeseries data \\
- with<Device>: true/false, whether to include given <Device> type in system.
- 
"""
function build_custom_csys5(;raw_data,add_forecasts=true, 
    decision_model_type="ed",
    withStandardLoad=true,
    withThermalStandard=true,
    withRenewableDispatch=false,
    withRenewableNonDispatch=false,
    withEnergyReservoirStorage=false,
    withInterruptiblePowerLoad=false,
    withHydroTurbine=false,
    withHydroPumpTurbine=false,
    withHydroDispatch=false,
    hydroLevelDataType=PSY.ReservoirDataType.USABLE_VOLUME,
    sys_kwargs...,
    )
    sys = build_sys5_nodes(; add_forecasts, raw_data, sys_kwargs...,)

    if withStandardLoad
        add_StandardLoad!(sys)
    end
    if withThermalStandard
        add_ThermalStandard!(sys)
    end
    if withRenewableDispatch
        add_RenewableDispatch!(sys)
    end
    if withRenewableNonDispatch
        add_RenewableNonDispatch!(sys)
    end
    if withEnergyReservoirStorage
        add_EnergyReservoirStorage!(sys)
    end
    if withInterruptiblePowerLoad
        add_InterruptiblePowerLoad!(sys)
    end
    # make sure to add HydroReservoir first
    if withHydroTurbine || withHydroPumpTurbine
        add_HydroReservoirs!(sys,hydroLevelDataType)
    end
    if withHydroTurbine
        add_HydroTurbine!(sys)
    end
    if withHydroPumpTurbine
        add_HydroPumpTurbine!(sys)
    end
    if withHydroDispatch
        add_HydroDispatch!(sys)
    end

    ## decision_model_type ##

    if add_forecasts

        # one week model
        if decision_model_type == "wk"

            timeseries_metadata_file = joinpath(
            raw_data,
            "5-bus",
            "5bus_ts",
            "7day",
            "timeseries_pointers_wk_7day_"*string(hydroLevelDataType)*".json",
            )
            add_time_series!(sys,timeseries_metadata_file;resolution=nothing)
            PSY.transform_single_time_series!(sys, Hour(24*7), Hour(24*7))

        # unit commitment 24 hours model
        elseif decision_model_type == "uc"
            timeseries_metadata_file = joinpath(
                raw_data,
                "5-Bus",
                "5bus_ts",
                "7day",
                "timeseries_pointers_da_7day_"*string(hydroLevelDataType)*".json",
            )
            add_time_series!(sys,timeseries_metadata_file;resolution=nothing)
            PSY.transform_single_time_series!(sys, Hour(24), Hour(24))

        # economic dispatch 1 hour forecast with 15-minute execution steps
        elseif decision_model_type == "ed"
            timeseries_metadata_file = joinpath(
                raw_data,
                "5-Bus",
                "5bus_ts",
                "7day",
                "timeseries_pointers_rt_7day_"*string(hydroLevelDataType)*".json",
            )
            @info "Adding economic dispatch timeseries data"
            add_time_series!(sys,timeseries_metadata_file;resolution=nothing)
            PSY.transform_single_time_series!(sys, Hour(1), Hour(1))
        end
    end
    return sys
end


####### below are just scripting examples for myself ####
# we'll start getting into the named scenarios now.

function build_csys5_re(;raw_data,add_forecasts,decision_model_type)

    build_custom_csys5(;raw_data,add_forecasts,decision_model_type,
        
        withStandardLoad=true,
        withThermalStandard=true,
        withRenewableDispatch=true,
        withRenewableNonDispatch=true,
        )

end

function build_csys5_all_components_uc(;raw_data,add_forecasts)

    build_custom_csys5(;raw_data,add_forecasts,
    
        decision_model_type="uc", 
        withStandardLoad=true,
        withThermalStandard=true,
        withRenewableDispatch=true,
        withRenewableNonDispatch=true,
        withEnergyReservoirStorage=false,
        withInterruptiblePowerLoad=false
        )

end