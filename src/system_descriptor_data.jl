const SYSTEM_CATALOG = [
    SystemDescriptor(;
        name = "c_sys14",
        description = "14-bus system",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_14bus_pu.jl"),
        build_function = build_c_sys14,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys14_dc",
        description = "14-bus system with DC line",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_14bus_pu.jl"),
        build_function = build_c_sys14_dc,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5",
        description = "5-Bus system",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_pjm",
        description = "5-Bus system",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_pjm,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_pjm_rt",
        description = "5-Bus system",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_pjm_rt,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_bat",
        description = "5-Bus system with Storage Device",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_bat,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_single_time_series,
                default = false,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_reserves,
                default = false,
                allowed_values = Set([true, false])
            ),
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_dc",
        description = "Systems with HVDC data in the branches",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_dc,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_ed",
        description = "5-Bus System for Economic Dispatch Simulations",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_ed,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_hy",
        description = "5-Bus system with HydroDispatch",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_hy,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_hy_ed",
        description = "5-Bus system with Hydro-Power for Economic Dispatch Simulations",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_hy_ed,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_hy_ems_ed",
        description = "5-Bus system with Hydro-Power for Economic Dispatch Simulations",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_hy_ems_ed,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_phes_ed",
        description = "5-Bus system with Hydro Pumped Energy Storage for Economic Dispatch Simulations",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_phes_ed,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_hy_uc",
        description = "5-Bus system with Hydro-Power for Unit Commitment Simulations",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_hy_uc,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_hy_ems_uc",
        description = "5-Bus system with Hydro-Power for Unit Commitment Simulations",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_hy_ems_uc,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_hyd",
        description = "5-Bus system with Hydro Energy Reservoir",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_hyd,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_single_time_series,
                default = false,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_reserves,
                default = false,
                allowed_values = Set([true, false])
            ),
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_hyd_ems",
        description = "5-Bus system with Hydro Energy Reservoir",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_hyd_ems,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_single_time_series,
                default = false,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_reserves,
                default = false,
                allowed_values = Set([true, false])
            ),
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_il",
        description = "System with Interruptible Load",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_il,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_reserves,
                default = false,
                allowed_values = Set([true, false])
            ),
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_ml",
        description = "Test System with Monitored Line",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_ml,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_re",
        description = "5-Bus system with Renewable Energy",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_re,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_reserves,
                default = false,
                allowed_values = Set([true, false])
            ),
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_re_only",
        description = "5-Bus system with only Renewable Energy",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_re_only,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_uc",
        description = "5-Bus system for Unit Commitment Simulations",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_uc,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_reserves,
                default = false,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_single_time_series,
                default = false,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_uc_non_spin",
        description = "5-Bus system for Unit Commitment with Non-Spinning Reserve Simulations",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_uc_non_spin,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_single_time_series,
                default = false,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_reserves,
                default = false,
                allowed_values = Set([true, false])
            ),
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_uc_re",
        description = "5-Bus system for Unit Commitment Simulations with Renewable Units",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_uc_re,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_single_time_series,
                default = false,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_reserves,
                default = false,
                allowed_values = Set([true, false])
            ),
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_pglib",
        description = "5-Bus with ThermalMultiStart",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_pglib,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_single_time_series,
                default = false,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_reserves,
                default = false,
                allowed_values = Set([true, false])
            ),
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_pwl_uc",
        description = "5-Bus with SOS cost function for Unit Commitment Simulations",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_pwl_uc,
    ),
    SystemDescriptor(;
        name = "c_sys5_pwl_ed",
        description = "5-Bus with pwl cost function",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_pwl_ed,
    ),
    SystemDescriptor(;
        name = "c_sys5_pwl_ed_nonconvex",
        description = "5-Bus with SOS cost function for Economic Dispatch Simulations",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_pwl_ed_nonconvex,
    ),
    SystemDescriptor(;
        name = "c_sys5_reg",
        description = "5-Bus with regulation devices and AGC",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_reg,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_radial",
        description = "5-Bus with a radial branches",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_radial,
    ),
    SystemDescriptor(;
        name = "sys10_pjm_ac_dc",
        description = "10-bus system (duplicate 5-bus PJM) with 4-DC bus system",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_10bus_ac_dc_pu.jl"),
        build_function = build_sys_10bus_ac_dc,
    ),
    SystemDescriptor(;
        name = "c_ramp_test",
        description = "1-bus for ramp testing",
        category = PSITestSystems,
        build_function = build_sys_ramp_testing,
    ),
    SystemDescriptor(;
        name = "c_duration_test",
        description = "1 Bus for duration testing",
        category = PSITestSystems,
        build_function = build_duration_test_sys,
    ),
    SystemDescriptor(;
        name = "c_linear_pwl_test",
        description = "1 Bus lineal PWL linear testing",
        category = PSITestSystems,
        build_function = build_pwl_test_sys,
    ),
    SystemDescriptor(;
        name = "c_sos_pwl_test",
        description = "1 Bus lineal PWL sos testing",
        category = PSITestSystems,
        build_function = build_sos_test_sys,
    ),
    SystemDescriptor(;
        name = "c_market_bid_cost",
        description = "1 bus system with MarketBidCost Model",
        category = PSITestSystems,
        build_function = build_pwl_marketbid_sys,
    ),
    SystemDescriptor(;
        name = "5_bus_hydro_uc_sys",
        description = "5-Bus hydro unit commitment data",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "5-Bus"),
        build_function = build_5_bus_hydro_uc_sys,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "5_bus_hydro_ed_sys",
        description = "5-Bus hydro economic dispatch data",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "5-Bus"),
        build_function = build_5_bus_hydro_ed_sys,
    ),
    SystemDescriptor(;
        name = "5_bus_hydro_wk_sys",
        description = "5-Bus hydro system for weekly dispatch",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "5-Bus"),
        build_function = build_5_bus_hydro_wk_sys,
    ),
    SystemDescriptor(;
        name = "5_bus_hydro_uc_sys_with_targets",
        description = "5-Bus hydro unit commitment data with energy targets",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "5-Bus"),
        build_function = build_5_bus_hydro_uc_sys_targets,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "5_bus_hydro_ed_sys_with_targets",
        description = "5-Bus hydro economic dispatch data with energy targets",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "5-Bus"),
        build_function = build_5_bus_hydro_ed_sys_targets,
    ),
    SystemDescriptor(;
        name = "5_bus_hydro_wk_sys_with_targets",
        description = "5-Bus hydro system for weekly dispatch with energy targets",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "5-Bus"),
        build_function = build_5_bus_hydro_wk_sys_targets,
    ),
    SystemDescriptor(;
        name = "psse_RTS_GMLC_sys",
        description = "PSSE .raw RTS-GMLC system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "RTS-GMLC.RAW"),
        build_function = build_psse_RTS_GMLC_sys,
    ),
    SystemDescriptor(;
        name = "test_RTS_GMLC_sys",
        description = "RTS-GMLC test system with day-ahead forecast",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "RTS_GMLC"),
        build_function = build_test_RTS_GMLC_sys,
    ),
    SystemDescriptor(;
        name = "test_RTS_GMLC_sys_with_hybrid",
        description = "RTS-GMLC test system with day-ahead forecast and HybridSystem",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "RTS_GMLC"),
        build_function = build_test_RTS_GMLC_sys_with_hybrid,
    ),
    SystemDescriptor(;
        name = "RTS_GMLC_DA_sys",
        description = "RTS-GMLC Full system from git repo for day-ahead simulations",
        category = PSISystems,
        raw_data = RTS_DIR,
        build_function = build_RTS_GMLC_DA_sys,
    ),
    SystemDescriptor(;
        name = "RTS_GMLC_DA_sys_noForecast",
        description = "RTS-GMLC Full system from git repo for day-ahead simulations",
        category = PSISystems,
        raw_data = RTS_DIR,
        build_function = build_RTS_GMLC_DA_sys_noForecast,
    ),
    SystemDescriptor(;
        name = "RTS_GMLC_RT_sys",
        description = "RTS-GMLC Full system from git repo for day-ahead simulations",
        category = PSISystems,
        raw_data = RTS_DIR,
        build_function = build_RTS_GMLC_RT_sys,
    ),
    SystemDescriptor(;
        name = "RTS_GMLC_RT_sys_noForecast",
        description = "RTS-GMLC Full system from git repo for day-ahead simulations",
        category = PSISystems,
        raw_data = RTS_DIR,
        build_function = build_RTS_GMLC_RT_sys_noForecast,
    ),
    SystemDescriptor(;
        name = "modified_RTS_GMLC_DA_sys",
        description = "Modified RTS-GMLC Full system for day-ahead simulations
            with modifications to reserve definitions to improve feasibility",
        category = PSISystems,
        raw_data = RTS_DIR,
        build_function = build_modified_RTS_GMLC_DA_sys,
    ),
    SystemDescriptor(;
        name = "modified_RTS_GMLC_DA_sys_noForecast",
        description = "Modified RTS-GMLC Full system for day-ahead simulations
            with modifications to reserve definitions to improve feasibility",
        category = PSISystems,
        raw_data = RTS_DIR,
        build_function = build_modified_RTS_GMLC_DA_sys_noForecast,
    ),
    SystemDescriptor(;
        name = "modified_RTS_GMLC_RT_sys",
        description = "Modified RTS-GMLC Full system for real-time simulations
            with modifications to reserve definitions to improve feasibility",
        category = PSISystems,
        raw_data = RTS_DIR,
        build_function = build_modified_RTS_GMLC_RT_sys,
    ),
    SystemDescriptor(;
        name = "modified_RTS_GMLC_RT_sys_noForecast",
        description = "Modified RTS-GMLC Full system for real-time simulations
            with modifications to reserve definitions to improve feasibility",
        category = PSISystems,
        raw_data = RTS_DIR,
        build_function = build_modified_RTS_GMLC_RT_sys_noForecast,
    ),
    SystemDescriptor(;
        name = "modified_RTS_GMLC_realization_sys",
        description = "Modified RTS-GMLC Full system for real-time simulations
            with modifications to reserve definitions to improve feasibility",
        category = PSISystems,
        raw_data = RTS_DIR,
        build_function = build_modified_RTS_GMLC_realization_sys,
    ),
    SystemDescriptor(;
        name = "AC_TWO_RTO_RTS_1Hr_sys",
        description = "Two Area RTO System Connected via AC with 1-hour resolution",
        category = PSISystems,
        raw_data = RTS_DIR,
        build_function = build_AC_TWO_RTO_RTS_1Hr_sys,
    ),
    SystemDescriptor(;
        name = "HVDC_TWO_RTO_RTS_1Hr_sys",
        description = "Two Area RTO System Connected via HVDC with 1-hour resolution",
        category = PSISystems,
        raw_data = RTS_DIR,
        build_function = build_HVDC_TWO_RTO_RTS_1Hr_sys,
    ),
    SystemDescriptor(;
        name = "AC_TWO_RTO_RTS_5min_sys",
        description = "Two Area RTO System Connected via AC with 5-min resolution",
        category = PSISystems,
        raw_data = RTS_DIR,
        build_function = build_AC_TWO_RTO_RTS_5Min_sys,
    ),
    SystemDescriptor(;
        name = "HVDC_TWO_RTO_RTS_5min_sys",
        description = "Two Area RTO System Connected via HVDC with 5-min resolution",
        category = PSISystems,
        raw_data = RTS_DIR,
        build_function = build_HVDC_TWO_RTO_RTS_5Min_sys,
    ),
    SystemDescriptor(;
        name = "modified_tamu_ercot_da_system",
        description = "Modified tamu ercot day ahead system",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "tamu_ercot"),
        build_function = build_modified_tamu_ercot_da_sys,
        download_function = download_modified_tamu_ercot_da,
    ),
    SystemDescriptor(;
        name = "psse_ACTIVSg2000_sys",
        description = "PSSE ACTIVSg2000 Test system",
        category = PSSEParsingTestSystems,
        raw_data = DATA_DIR,
        build_function = build_psse_ACTIVSg2000_sys,
    ),
    SystemDescriptor(;
        name = "matpower_ACTIVSg2000_sys",
        description = "MATPOWER ACTIVSg2000 Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "ACTIVSg2000.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "tamu_ACTIVSg2000_sys",
        description = "TAMU ACTIVSg2000 Test system",
        category = PSYTestSystems,
        raw_data = DATA_DIR,
        build_function = build_tamu_ACTIVSg2000_sys,
    ),
    SystemDescriptor(;
        name = "matpower_ACTIVSg10k_sys",
        description = "ACTIVSg10k Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case_ACTIVSg10k.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case2_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case2.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case3_tnep_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case3_tnep.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case5_asym_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case5_asym.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case5_dc_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case5_dc.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case5_gap_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case5_gap.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case5_pwlc_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case5_pwlc.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case5_re_uc_pwl_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case5_re_uc_pwl.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case5_re_uc_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case5_re_uc.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case5_re_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case5_re.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case5_tnep_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case5_tnep.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case5_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case5.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case6_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case6.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case7_tplgy_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case7_tplgy.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case14_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case14.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case24_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case24.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case30_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case30.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_frankenstein_00_sys",
        description = "Matpower Frankenstein Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "frankenstein_00.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_RTS_GMLC_sys",
        description = "Matpower RTS-GMLC Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "RTS_GMLC.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "matpower_case5_strg_sys",
        description = "Matpower Test system",
        category = MatpowerTestSystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case5_strg.m"),
        build_function = build_matpower,
    ),
    SystemDescriptor(;
        name = "pti_case3_sys",
        description = "PSSE 3-bus Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "case3.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_case5_alc_sys",
        description = "PSSE 5-Bus alc Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "case5_alc.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_case5_sys",
        description = "PSSE 5-Bus Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "case5.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_case7_tplgy_sys",
        description = "PSSE 7-bus Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "case7_tplgy.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_case14_sys",
        description = "PSSE 14-bus Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "case14.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_case24_sys",
        description = "PSSE 24-bus Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "case24.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_case30_sys",
        description = "PSSE 30-bus Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "case30.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_case73_sys",
        description = "PSSE 73-bus Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "case73.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_frankenstein_00_2_sys",
        description = "PSSE frankenstein Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "frankenstein_00_2.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_frankenstein_00_sys",
        description = "PSSE frankenstein Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "frankenstein_00.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_frankenstein_20_sys",
        description = "PSSE frankenstein Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "frankenstein_20.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_frankenstein_70_sys",
        description = "PSSE frankenstein Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "frankenstein_70.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_parser_test_a_sys",
        description = "PSSE Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "parser_test_a.raw"),
        build_function = build_pti,
    ),
    # SystemDescriptor(
    #     name =  "pti_parser_test_b_sys",
    #     description =  "PSSE Test system",
    #     category =  PSSEParsingTestSystems,
    #     raw_data =  joinpath(DATA_DIR, "psse_raw", "parser_test_b.raw"),
    #     build_function  =  build_pti
    # ),
    # SystemDescriptor(
    #     name =  "pti_parser_test_c_sys",
    #     description =  "PSSE Test system",
    #     category =  PSSEParsingTestSystems,
    #     raw_data =  joinpath(DATA_DIR, "psse_raw", "parser_test_c.raw"),
    #     build_function  =  build_pti
    # ),
    # SystemDescriptor(
    #     name =  "pti_parser_test_d_sys",
    #     description =  "PSSE Test system",
    #     category =  PSSEParsingTestSystems,
    #     raw_data =  joinpath(DATA_DIR, "psse_raw", "parser_test_d.raw"),
    #     build_function  =  build_pti
    # ),
    # SystemDescriptor(
    #     name =  "pti_parser_test_e_sys",
    #     description =  "PSSE Test system",
    #     category =  PSSEParsingTestSystems,
    #     raw_data =  joinpath(DATA_DIR, "psse_raw", "parser_test_e.raw"),
    #     build_function  =  build_pti
    # ),
    # SystemDescriptor(
    #     name =  "pti_parser_test_f_sys",
    #     description =  "PSSE Test system",
    #     category =  PSSEParsingTestSystems,
    #     raw_data =  joinpath(DATA_DIR, "psse_raw", "parser_test_f.raw"),
    #     build_function  =  build_pti
    # ),
    # SystemDescriptor(
    #     name =  "pti_parser_test_g_sys",
    #     description =  "PSSE Test system",
    #     category =  PSSEParsingTestSystems,
    #     raw_data =  joinpath(DATA_DIR, "psse_raw", "parser_test_g.raw"),
    #     build_function  =  build_pti
    # ),
    # SystemDescriptor(
    #     name =  "pti_parser_test_h_sys",
    #     description =  "PSSE Test system",
    #     category =  PSSEParsingTestSystems,
    #     raw_data =  joinpath(DATA_DIR, "psse_raw", "parser_test_h.raw"),
    #     build_function  =  build_pti
    # ),
    # SystemDescriptor(
    #     name =  "pti_parser_test_i_sys",
    #     description =  "PSSE Test system",
    #     category =  PSSEParsingTestSystems,
    #     raw_data =  joinpath(DATA_DIR, "psse_raw", "parser_test_i.raw"),
    #     build_function  =  build_pti
    # ),
    # SystemDescriptor(
    #     name =  "pti_parser_test_j_sys",
    #     description =  "PSSE Test system",
    #     category =  PSSEParsingTestSystems,
    #     raw_data =  joinpath(DATA_DIR, "psse_raw", "parser_test_j.raw"),
    #     build_function  =  build_pti
    # ),
    SystemDescriptor(;
        name = "pti_three_winding_mag_test_sys",
        description = "PSSE Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "three_winding_mag_test.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_three_winding_test_2_sys",
        description = "PSSE Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "three_winding_test_2.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_three_winding_test_sys",
        description = "PSSE Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "three_winding_test.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_two_winding_mag_test_sys",
        description = "PSSE Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "two_winding_mag_test.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_two_terminal_hvdc_test_sys",
        description = "PSSE Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "two-terminal-hvdc_test.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "pti_vsc_hvdc_test_sys",
        description = "PSSE Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "vsc-hvdc_test.raw"),
        build_function = build_pti,
    ),
    SystemDescriptor(;
        name = "PSSE 30 Test System",
        description = "PSSE 30 Test system",
        category = PSSEParsingTestSystems,
        raw_data = joinpath(DATA_DIR, "psse_raw", "synthetic_data_v30.raw"),
        build_function = build_pti_30,
    ),
    SystemDescriptor(;
        name = "psse_Benchmark_4ger_33_2015_sys",
        description = "Test parsing of PSSE Benchmark system",
        category = PSYTestSystems,
        raw_data = DATA_DIR,
        build_function = build_psse_Benchmark_4ger_33_2015_sys,
    ),
    SystemDescriptor(;
        name = "psse_OMIB_sys",
        description = "Test parsing of PSSE OMIB Test system",
        category = PSYTestSystems,
        raw_data = DATA_DIR,
        build_function = build_psse_OMIB_sys,
    ),
    SystemDescriptor(;
        name = "psse_3bus_gen_cls_sys",
        description = "Test parsing of PSSE 3-bus Test system with CLS",
        category = PSYTestSystems,
        raw_data = DATA_DIR,
        build_function = build_psse_3bus_gen_cls_sys,
    ),
    SystemDescriptor(;
        name = "psse_3bus_SEXS_sys",
        description = "Test parsing of PSSE 3-bus Test system with SEXS",
        category = PSYTestSystems,
        raw_data = DATA_DIR,
        build_function = build_psse_3bus_sexs_sys,
    ),
    SystemDescriptor(;
        name = "psse_240_parsing_sys",
        description = "Test parsing of PSSE 240 Bus Case system",
        category = PSYTestSystems,
        raw_data = DATA_DIR,
        build_function = build_psse_original_240_case,
    ),
    SystemDescriptor(;
        name = "psse_3bus_no_cls_sys",
        description = "Test parsing of PSSE 3-bus Test system without CLS",
        category = PSYTestSystems,
        raw_data = DATA_DIR,
        build_function = build_psse_3bus_no_cls_sys,
    ),
    SystemDescriptor(;
        name = "psse_renewable_parsing_1",
        description = "Test parsing PSSE 3-bus Test system with REPCA, REECB and REGCA",
        category = PSYTestSystems,
        raw_data = DATA_DIR,
        build_function = psse_renewable_parsing_1,
    ),
    SystemDescriptor(;
        name = "dynamic_inverter_sys",
        description = "PSY test dynamic inverter system",
        category = PSYTestSystems,
        build_function = build_dynamic_inverter_sys,
    ),
    SystemDescriptor(;
        name = "c_sys5_bat_ems",
        description = "5-Bus system with Storage Device with EMS",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_bat_ems,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_single_time_series,
                default = false,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_reserves,
                default = false,
                allowed_values = Set([true, false])
            ),
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_pglib_sim",
        description = "5-Bus with ThermalMultiStart for simulation",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_pglib_sim,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            ),
            SystemArgument(;
                name = :add_reserves,
                default = false,
                allowed_values = Set([true, false])
            ),
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_hybrid",
        description = "5-Bus system with Hybrid devices",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_hybrid,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_hybrid_uc",
        description = "5-Bus system with Hybrid devices and thermal UC devices",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_hybrid_uc,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "c_sys5_hybrid_ed",
        description = "5-Bus system with Hybrid devices and thermal devices for ED.",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_hybrid_ed,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
    SystemDescriptor(;
        name = "5_bus_matpower_DA",
        description = "matpower 5-Bus system with DA time series",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case5_re_uc.m"),
        build_function = build_5_bus_matpower_DA,
    ),
    SystemDescriptor(;
        name = "5_bus_matpower_RT",
        description = "matpower 5-Bus system with RT time series",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case5_re_uc.m"),
        build_function = build_5_bus_matpower_RT,
    ),
    SystemDescriptor(;
        name = "5_bus_matpower_AGC",
        description = "matpower 5-Bus system with AGC time series",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "matpower", "case5_re_uc.m"),
        build_function = build_5_bus_matpower_AGC,
    ),
    SystemDescriptor(;
        name = "hydro_test_case_c_sys",
        description = "test system for HydroGen Energy Target formulation(case-c)",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_hydro_test_case_c_sys,
    ),
    SystemDescriptor(;
        name = "hydro_test_case_b_sys",
        description = "test system for HydroGen Energy Target formulation(case-b)",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_hydro_test_case_b_sys,
    ),
    SystemDescriptor(;
        name = "hydro_test_case_d_sys",
        description = "test system for HydroGen Energy Target formulation(case-d)",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_hydro_test_case_d_sys,
    ),
    SystemDescriptor(;
        name = "hydro_test_case_e_sys",
        description = "test system for HydroGen Energy Target formulation(case-e)",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_hydro_test_case_e_sys,
    ),
    SystemDescriptor(;
        name = "hydro_test_case_f_sys",
        description = "test system for HydroGen  Energy Target formulation(case-f)",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_hydro_test_case_f_sys,
    ),
    SystemDescriptor(;
        name = "batt_test_case_b_sys",
        description = "test system for Storage Energy Target formulation(case-b)",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_batt_test_case_b_sys,
    ),
    SystemDescriptor(;
        name = "batt_test_case_d_sys",
        description = "test system for Storage Energy Target formulation(case-d)",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_batt_test_case_d_sys,
    ),
    SystemDescriptor(;
        name = "batt_test_case_c_sys",
        description = "test system for Storage Energy Target formulation(case-c)",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_batt_test_case_c_sys,
    ),
    SystemDescriptor(;
        name = "batt_test_case_e_sys",
        description = "test system for Storage Energy Target formulation(case-e)",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_batt_test_case_e_sys,
    ),
    SystemDescriptor(;
        name = "batt_test_case_f_sys",
        description = "test system for Storage Energy Target formulation(case-f)",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_batt_test_case_f_sys,
    ),
    SystemDescriptor(;
        name = "psid_psse_test_avr",
        description = "PSID AVR Test Cases for PSSE Validation",
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "psse", "AVRs"),
        build_function = build_psid_psse_test_avr,
    ),
    SystemDescriptor(;
        name = "psid_psse_test_tg",
        description = "PSID TG Test Cases for PSSE Validation",
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "psse", "TGs"),
        build_function = build_psid_psse_test_tg,
    ),
    SystemDescriptor(;
        name = "psid_psse_test_gen",
        description = "PSID GEN Test Cases for PSSE Validation",
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "psse", "GENs"),
        build_function = build_psid_psse_test_gen,
    ),
    SystemDescriptor(;
        name = "psid_psse_test_pss",
        description = "PSID PSS Test Cases for PSSE Validation",
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "psse", "PSSs"),
        build_function = build_psid_psse_test_pss,
    ),
    SystemDescriptor(;
        name = "psid_test_omib",
        description = "PSID OMIB Test Case", # Old Test 01
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "OMIB.raw"),
        build_function = build_psid_test_omib,
    ),
    SystemDescriptor(;
        name = "psid_test_threebus_oneDoneQ",
        description = "PSID Three Bus One-d-One-q Test Case", # Old Test 02
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "ThreeBusNetwork.raw"),
        build_function = build_psid_test_threebus_oneDoneQ,
    ),
    SystemDescriptor(;
        name = "psid_test_threebus_simple_marconato",
        description = "PSID Three Bus Simple Marconato Test Case", # Old Test 03
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "ThreeBusNetwork.raw"),
        build_function = build_psid_test_threebus_simple_marconato,
    ),
    SystemDescriptor(;
        name = "psid_test_threebus_marconato",
        description = "PSID Three Bus Simple Marconato Test Case", # Old Test 04
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "ThreeBusNetwork.raw"),
        build_function = build_psid_test_threebus_marconato,
    ),
    SystemDescriptor(;
        name = "psid_test_threebus_simple_anderson",
        description = "PSID Three Bus Simple Anderson-Fouad Test Case", # Old Test 05
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "ThreeBusNetwork.raw"),
        build_function = build_psid_test_threebus_simple_anderson,
    ),
    SystemDescriptor(;
        name = "psid_test_threebus_anderson",
        description = "PSID Three Bus Anderson-Fouad Test Case", # Old Test 06
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "ThreeBusNetwork.raw"),
        build_function = build_psid_test_threebus_anderson,
    ),
    SystemDescriptor(;
        name = "psid_test_threebus_5shaft",
        description = "PSID Three Bus 5-shaft Test Case", # Old Test 07
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "ThreeBusNetwork.raw"),
        build_function = build_psid_test_threebus_5shaft,
    ),
    SystemDescriptor(;
        name = "psid_test_vsm_inverter",
        description = "PSID Two Bus D'Arco VSM Inverter Test Case", # Old Test 08
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "OMIB_DARCO_PSR.raw"),
        build_function = build_psid_test_vsm_inverter,
    ),
    SystemDescriptor(;
        name = "psid_test_threebus_machine_vsm",
        description = "PSID Three Bus One-d-One-q Machine against VSM Inverter Test Case", # Old Test 09 and 10
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "ThreeBusNetwork.raw"),
        build_function = build_psid_test_threebus_machine_vsm,
    ),
    SystemDescriptor(;
        name = "psid_test_threebus_machine_vsm_dynlines",
        description = "PSID Three Bus One-d-One-q Machine against VSM Inverter Test Case with Dynamic Lines", # Old Test 11
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "ThreeBusNetwork.raw"),
        build_function = build_psid_test_threebus_machine_vsm_dynlines,
    ),
    SystemDescriptor(;
        name = "psid_test_threebus_multimachine",
        description = "PSID Three Bus Multi-Machine Test Case", # Old Test 12
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "ThreeBusMulti.raw"),
        build_function = build_psid_test_threebus_multimachine,
    ),
    SystemDescriptor(;
        name = "psid_test_threebus_psat_avrs",
        description = "PSID Three Bus TG Type I and AVR Type II Test Case", # Old Test 13
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "ThreeBusNetwork.raw"),
        build_function = build_psid_test_threebus_psat_avrs,
    ),
    SystemDescriptor(;
        name = "psid_test_threebus_vsm_reference",
        description = "PSID Three Bus Inverter Reference Test Case", # Old Test 14
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "ThreeBusMulti.raw"),
        build_function = build_psid_test_threebus_vsm_reference,
    ),
    SystemDescriptor(;
        name = "psid_test_threebus_genrou_avr",
        description = "PSID Three Bus GENROU with PSAT AVRs Test Case", # Old Test 17
        category = PSIDTestSystems,
        raw_data = joinpath(
            DATA_DIR,
            "psid_tests",
            "psse",
            "GENs",
            "GENROU",
            "ThreeBusMulti.raw",
        ),
        build_function = build_psid_test_threebus_genrou_avr,
    ),
    SystemDescriptor(;
        name = "psid_test_droop_inverter",
        description = "PSID Two Bus Droop GFM Inverter Test Case", # Old Test 23
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "OMIB_DARCO_PSR.raw"),
        build_function = build_psid_test_droop_inverter,
    ),
    SystemDescriptor(;
        name = "psid_test_gfoll_inverter",
        description = "PSID Two Bus Grid Following Inverter Test Case", # Old Test 24
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "OMIB_DARCO_PSR.raw"),
        build_function = build_psid_test_gfoll_inverter,
    ),
    SystemDescriptor(;
        name = "psid_test_threebus_multimachine_dynlines",
        description = "PSID Three Bus Multi-Machine with Dynamic Lines Test Case", # Old Test 25
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "ThreeBusMultiLoad.raw"),
        build_function = build_psid_test_threebus_multimachine_dynlines,
    ),
    SystemDescriptor(;
        name = "psid_test_pvs",
        description = "PSID OMIB with Periodic Variable Source Test Case", # Old Test 28
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "OMIB.raw"),
        build_function = build_psid_test_pvs,
    ), # TO ADD TEST 29
    SystemDescriptor(;
        name = "psid_test_ieee_9bus",
        description = "PSID IEEE 9-bus system with Anderson-Fouad Machine Test Case", # Old Test 32
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests", "9BusSystem.json"),
        build_function = build_psid_test_ieee_9bus,
    ),
    SystemDescriptor(;
        name = "psid_psse_test_constantP_load",
        description = "PSID Constant Power Load Test Case", # Old Test 33
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "psse", "LOAD"),
        build_function = build_psid_psse_test_constantP_load,
    ),
    SystemDescriptor(;
        name = "psid_psse_test_constantI_load",
        description = "PSID Constant Current Load Test Case", # Old Test 33
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "psse", "LOAD"),
        build_function = build_psid_psse_test_constantI_load,
    ),
    SystemDescriptor(;
        name = "psid_psse_test_exp_load",
        description = "PSID Exponential Load Test Case", # Old Test 34
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "psse", "LOAD"),
        build_function = build_psid_psse_test_exp_load,
    ),
    SystemDescriptor(;
        name = "psid_4bus_multigen",
        description = "PSID Multiple Generators in Single-Bus Test Case", # Old Test 35
        category = PSIDSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "psse", "MultiGen"),
        build_function = build_psid_4bus_multigen,
    ),
    SystemDescriptor(;
        name = "psid_11bus_andes",
        description = "PSID 11-bus Kundur System compared against Andes", # Old Test 36
        category = PSIDSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "psse", "ANDES"),
        build_function = build_psid_11bus_andes,
    ),
    SystemDescriptor(;
        name = "psid_test_indmotor",
        description = "PSID System without Induction Motor Test Case", # Old Test 37
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests"),
        build_function = build_psid_test_indmotor,
    ),
    SystemDescriptor(;
        name = "psid_test_5th_indmotor",
        description = "PSID System with 5th-order Induction Motor Test Case", # Old Test 37
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests"),
        build_function = build_psid_test_5th_indmotor,
    ),
    SystemDescriptor(;
        name = "psid_test_3rd_indmotor",
        description = "PSID System with 3rd-order Induction Motor Test Case", # Old Test 38
        category = PSIDTestSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_tests"),
        build_function = build_psid_test_3rd_indmotor,
    ),
    SystemDescriptor(;
        name = "2Area 5 Bus System",
        description = "PSI test system with two areas connected with an HVDC Line",
        category = PSISystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_two_zone_5_bus,
    ),
    SystemDescriptor(;
        name = "OMIB System",
        description = "OMIB case with 2 state machine for examples",
        category = PSIDSystems,
        build_function = build_psid_omib,
    ),
    SystemDescriptor(;
        name = "Three Bus Dynamic data Example System",
        description = "Three Bus case for examples",
        category = PSIDSystems,
        build_function = build_psid_3bus,
    ),
    SystemDescriptor(;
        name = "WECC 240 Bus",
        description = "WECC 240 Bus case dynamic data with some modifications",
        category = PSIDSystems,
        build_function = build_wecc_240_dynamic,
    ),
    SystemDescriptor(;
        name = "14 Bus Base Case",
        description = "14 Bus Dynamic Test System Case",
        category = PSIDSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_examples"),
        build_function = build_psid_14bus_multigen,
    ),
    SystemDescriptor(;
        name = "3 Bus Inverter Base",
        description = "3 Bus Base System for tutorials",
        category = PSIDSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_examples"),
        build_function = build_3bus_inverter,
    ),
    SystemDescriptor(;
        name = "2 Bus Load Tutorial",
        description = "2 Bus Base System for load tutorials",
        category = PSIDSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_examples", "Omib_Load.raw"),
        build_function = build_psid_load_tutorial_omib,
    ),
    SystemDescriptor(;
        name = "2 Bus Load Tutorial GENROU",
        description = "2 Bus Base System for load tutorials with GENROU",
        category = PSIDSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_examples", "Omib_Load.raw"),
        build_function = build_psid_load_tutorial_genrou,
    ),
    SystemDescriptor(;
        name = "2 Bus Load Tutorial Droop",
        description = "2 Bus Base System for load tutorials with Droop Inverter",
        category = PSIDSystems,
        raw_data = joinpath(DATA_DIR, "psid_tests", "data_examples", "Omib_Load.raw"),
        build_function = build_psid_load_tutorial_droop,
    ),
    SystemDescriptor(;
        name = "c_sys5_all_components",
        description = "5-Bus system with 5-Bus system with Renewable Energy, Hydro Energy Reservoir, and both StandardLoad and PowerLoad",
        category = PSITestSystems,
        raw_data = joinpath(DATA_DIR, "psy_data", "data_5bus_pu.jl"),
        build_function = build_c_sys5_all_components,
        supported_arguments = [
            SystemArgument(;
                name = :add_forecasts,
                default = true,
                allowed_values = Set([true, false])
            )
        ]
    ),
]
