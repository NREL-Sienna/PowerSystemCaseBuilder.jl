"""
    _update_rts_names_into_ei_sys!(sys::PSY.System)

Updates the names of components in the RTS system to match the EI system naming conventions.
This includes renaming lines and areas to their respective EI names.

# Arguments
- `sys`: The RTS system to update.
"""
function _update_rts_names_into_ei_sys!(sys::PSY.System, sys_name::String)
    PSY.set_name!(sys, sys_name)
    PSY.set_name!(sys, PSY.get_component(Line, sys, "AB1"), "AB-1")
    PSY.set_name!(sys, PSY.get_component(Line, sys, "AB2"), "AB-2")
    PSY.set_name!(sys, PSY.get_component(Line, sys, "AB3"), "AB-3")
    PSY.set_name!(sys, PSY.get_component(Area, sys, "1"), "PJM")
    PSY.set_name!(sys, PSY.get_component(Area, sys, "2"), "NYISO")
    PSY.set_name!(sys, PSY.get_component(Area, sys, "3"), "ISONE")
    PSY.set_units_base_system!(sys, "NATURAL_UNITS")
end

"""
Summarizes the RTS-GMLC and PJM-NYISO-ISONE data.

Returns three dictionaries:
- rts_data: summary of RTS system (loads, generation, area breakdowns, etc.)
- scale_factor_data: scaling factors for loads and interties by area

# Arguments
- `sys`: The RTS system for which to summarize data.
- `iso_data`: The EI ISO data to incorporate into the summary.
"""
function _summary_rts_and_ei_data(sys::PSY.System, iso_data::Dict)
    # Initialize dictionary to store RTS system data
    rts_data = Dict()

    # Calculate total system load by summing max active power of all available loads
    rts_data["total_load"] =
        sum(
            PSY.get_max_active_power.(
                PSY.get_components(PSY.get_available, PSY.PowerLoad, sys)
            ),
        ) # 8550 MW

    # Calculate total thermal generation capacity
    rts_data["total_thermal"] =
        sum(
            PSY.get_max_active_power.(
                PSY.get_components(PSY.get_available, PSY.ThermalStandard, sys)
            ),
        ) # 7752 MW

    # Calculate total dispatchable renewable generation capacity
    rts_data["total_ren_dispatch"] =
        sum(
            PSY.get_max_active_power.(
                PSY.get_components(PSY.get_available, PSY.RenewableDispatch, sys)
            ),
        ) # 5616 MW

    # Calculate total non-dispatchable renewable generation capacity (e.g., solar PV, wind)
    rts_data["total_ren_nondispatch"] = sum(
        PSY.get_max_active_power.(
            PSY.get_components(PSY.get_available, PSY.RenewableNonDispatch, sys)
        ),
    ) # 348.42 MW

    # Calculate total hydro generation capacity
    rts_data["total_hydro"] =
        sum(
            PSY.get_max_active_power.(
                PSY.get_components(PSY.get_available, PSY.HydroDispatch, sys)
            ),
        ) # 50.0 MW

    # Calculate total installed generation capacity across all technologies
    rts_data["total_installed"] =
        rts_data["total_thermal"] + rts_data["total_ren_dispatch"] +
        rts_data["total_ren_nondispatch"] + rts_data["total_hydro"] # 13767.32 MW

    # Calculate installed generation capacity by area - PJM region
    rts_data["pjm_total_installed"] = sum(
        PSY.get_max_active_power.(
            PSY.get_components(
                x -> x.available && (x.bus.area.name == "PJM"),
                Generator,
                sys,
            )
        ),
    ) # approx 4163.73

    # Calculate installed generation capacity by area - NYISO region  
    rts_data["nyiso_total_installed"] = sum(
        PSY.get_max_active_power.(
            PSY.get_components(
                x -> x.available && (x.bus.area.name == "NYISO"),
                Generator,
                sys,
            )
        ),
    ) # approx 2907.16

    # Calculate installed generation capacity by area - ISONE region
    rts_data["isone_total_installed"] = sum(
        PSY.get_max_active_power.(
            PSY.get_components(
                x -> x.available && (x.bus.area.name == "ISONE"),
                Generator,
                sys,
            )
        ),
    ) # approx 6696.42

    # Calculate peak load by area - PJM region
    rts_data["pjm_peak_load"] = sum(
        PSY.get_max_active_power.(
            PSY.get_components(
                x -> x.available && x.bus.area.name == "PJM",
                PowerLoad,
                sys,
            )
        ),
    )

    # Calculate peak load by area - NYISO region
    rts_data["nyiso_peak_load"] = sum(
        PSY.get_max_active_power.(
            PSY.get_components(
                x -> x.available && x.bus.area.name == "NYISO",
                PowerLoad,
                sys,
            )
        ),
    )

    # Calculate peak load by area - ISONE region
    rts_data["isone_peak_load"] = sum(
        PSY.get_max_active_power.(
            PSY.get_components(
                x -> x.available && x.bus.area.name == "ISONE",
                PowerLoad,
                sys,
            )
        ),
    )

    # Calculate system-wide ratios for analysis
    rts_data["renewable_to_total_ratio"] =
        rts_data["total_ren_dispatch"] / rts_data["total_installed"] # 0.407

    # Calculate scaling factors to scale RTS data to match EI proportions
    scale_factor_data = Dict()

    # Load scaling factors: scale RTS loads to match EI load proportions
    scale_factor_data["pjm_load_scaling"] =
        rts_data["total_load"] * iso_data["pjm_load_to_total_ratio"] /
        rts_data["pjm_peak_load"]
    scale_factor_data["nyiso_load_scaling"] =
        rts_data["total_load"] * iso_data["nyiso_load_to_total_ratio"] /
        rts_data["nyiso_peak_load"]
    scale_factor_data["isone_load_scaling"] =
        rts_data["total_load"] * iso_data["isone_load_to_total_ratio"] /
        rts_data["isone_peak_load"]

    # Intertie scaling factors: use maximum of connected area scaling factors
    scale_factor_data["pjm_nyiso_intertie_scaling"] =
        max(scale_factor_data["pjm_load_scaling"], scale_factor_data["nyiso_load_scaling"])
    scale_factor_data["pjm_isone_intertie_scaling"] =
        max(scale_factor_data["pjm_load_scaling"], scale_factor_data["isone_load_scaling"])
    scale_factor_data["nyiso_isone_intertie_scaling"] = max(
        scale_factor_data["nyiso_load_scaling"],
        scale_factor_data["isone_load_scaling"],
    )
    scale_factor_data["rts_ei_offshore_installed"] =
        iso_data["offshore_new_capacity"] * rts_data["total_installed"] /
        iso_data["total_installed"]
    scale_factor_data["rts_pjm_offshore_installed"] =
        iso_data["pjm_offshore_new_capacity"] * rts_data["total_installed"] /
        iso_data["total_installed"]
    scale_factor_data["rts_nyiso_offshore_installed"] =
        iso_data["nyiso_offshore_new_capacity"] * rts_data["total_installed"] /
        iso_data["total_installed"]
    scale_factor_data["rts_isone_offshore_installed"] =
        iso_data["isone_offshore_new_capacity"] * rts_data["total_installed"] /
        iso_data["total_installed"]
    return rts_data, scale_factor_data
end

"""
    _scale_load_per_area_proportion!(sys::PSY.System, scale_factor_data::Dict)

Scales the maximum active power of loads in each area (PJM, NYISO, ISONE) according to the provided scaling factors.
Logs (in debug mode) before/after summary and asserts total load is preserved.

# Arguments
- `sys`: The system object (PSY.System)
- `scale_factor_data`: Dictionary with scaling factors for each area
"""
function _scale_load_per_area_proportion!(sys::PSY.System, scale_factor_data::Dict)
    # Calculate current total load for each area before scaling
    rts_pjm_load = sum(
        get_max_active_power.(
            get_components(x -> x.available && x.bus.area.name == "PJM", PowerLoad, sys)
        ),
    )
    rts_nyiso_load = sum(
        get_max_active_power.(
            get_components(x -> x.available && x.bus.area.name == "NYISO", PowerLoad, sys)
        ),
    )
    rts_isone_load = sum(
        get_max_active_power.(
            get_components(x -> x.available && x.bus.area.name == "ISONE", PowerLoad, sys)
        ),
    )
    rts_total_load = rts_pjm_load + rts_nyiso_load + rts_isone_load

    # Create dictionary mapping area names to their scaling factors
    scale_factor = Dict(
        "PJM" => scale_factor_data["pjm_load_scaling"],
        "NYISO" => scale_factor_data["nyiso_load_scaling"],
        "ISONE" => scale_factor_data["isone_load_scaling"],
    )

    # Apply scaling factors to each load based on its area
    for load in PSY.get_components(PSY.get_available, PowerLoad, sys)
        area = load.bus.area.name
        # Scale the load's maximum active power by the area's scaling factor
        PSY.set_max_active_power!(load, PSY.get_max_active_power(load) * scale_factor[area])
    end

    # Calculate new total loads after scaling for verification
    updated_rts_pjm_load = round(
        sum(
            PSY.get_max_active_power.(
                PSY.get_components(
                    x -> x.available && x.bus.area.name == "PJM",
                    PowerLoad,
                    sys,
                )
            ),
        );
        digits = 2,
    )
    updated_rts_nyiso_load = round(
        sum(
            PSY.get_max_active_power.(
                PSY.get_components(
                    x -> x.available && x.bus.area.name == "NYISO",
                    PowerLoad,
                    sys,
                )
            ),
        );
        digits = 2,
    )
    updated_rts_isone_load = round(
        sum(
            PSY.get_max_active_power.(
                PSY.get_components(
                    x -> x.available && x.bus.area.name == "ISONE",
                    PowerLoad,
                    sys,
                )
            ),
        );
        digits = 2,
    )
    updated_rts_total_load =
        updated_rts_pjm_load + updated_rts_nyiso_load + updated_rts_isone_load

    # Print before and after load summaries for verification
    @info(
        "|$(PSY.get_name(sys))| Before scaling PJM has a total load of $(rts_pjm_load) MW, NYISO has $(rts_nyiso_load) MW, and ISONE has $(rts_isone_load) MW (Total: $(rts_total_load) MW)."
    )
    @info(
        "|$(PSY.get_name(sys))| After scaling PJM has a total load of $(updated_rts_pjm_load) MW, NYISO has $(updated_rts_nyiso_load) MW, and ISONE has $(updated_rts_isone_load) MW (Total: $(updated_rts_total_load) MW)."
    )

    # Verify that total load is preserved (within numerical tolerance)
    @assert isapprox(rts_total_load, updated_rts_total_load; atol = 0.01)
end

"""
    _scale_internal_branch_ratings!(sys::PSY.System, scale_factor_data::Dict)

Scales the branch ratings (capacity) for internal branches within each area (PJM, NYISO, ISONE) according to the provided scaling factors.
Prints before/after summary.

# Arguments
- `sys`: The system object (PSY.System)
- `scale_factor_data`: Dictionary with scaling factors for each area
"""
function _scale_internal_branch_ratings!(sys::PSY.System, scale_factor_data::Dict)
    # Get all internal branches (within each area) for capacity calculations
    # PJM internal branches: both from and to buses are in PJM area
    pjm_branches = PSY.get_components(
        x ->
            x.available && x.arc.from.area.name == "PJM" && x.arc.to.area.name == "PJM",
        Branch,
        sys,
    )
    # NYISO internal branches: both from and to buses are in NYISO area
    nyiso_branches = PSY.get_components(
        x ->
            x.available && x.arc.from.area.name == "NYISO" && x.arc.to.area.name == "NYISO",
        Branch,
        sys,
    )
    # ISONE internal branches: both from and to buses are in ISONE area
    isone_branches = PSY.get_components(
        x ->
            x.available && x.arc.from.area.name == "ISONE" && x.arc.to.area.name == "ISONE",
        Branch,
        sys,
    )

    # Calculate total branch ratings for each area before scaling
    rts_pjm_ratings = sum(PSY.get_rating.(pjm_branches))
    rts_nyiso_ratings = sum(PSY.get_rating.(nyiso_branches))
    rts_isone_ratings = sum(PSY.get_rating.(isone_branches))
    rts_total_ratings = rts_pjm_ratings + rts_nyiso_ratings + rts_isone_ratings

    # Create dictionary mapping area names to their scaling factors
    scale_factor = Dict(
        "PJM" => scale_factor_data["pjm_load_scaling"],
        "NYISO" => scale_factor_data["nyiso_load_scaling"],
        "ISONE" => scale_factor_data["isone_load_scaling"],
    )

    # Scale all internal branches by their area's scaling factor
    for branch in PSY.get_components(
        x -> x.available && x.arc.from.area.name == x.arc.to.area.name,
        Branch,
        sys,
    )
        area = branch.arc.from.area.name
        # Apply scaling factor to branch rating (thermal capacity)
        PSY.set_rating!(branch, PSY.get_rating(branch) * scale_factor[area])
    end

    # Calculate updated branch ratings after scaling for verification
    updated_rts_pjm_ratings = round(sum(PSY.get_rating.(pjm_branches)); digits = 2)
    updated_rts_nyiso_ratings = round(sum(PSY.get_rating.(nyiso_branches)); digits = 2)
    updated_rts_isone_ratings = round(sum(PSY.get_rating.(isone_branches)); digits = 2)
    updated_rts_total_ratings =
        updated_rts_pjm_ratings + updated_rts_nyiso_ratings + updated_rts_isone_ratings

    # Print before and after branch rating summaries
    @info(
        "|$(PSY.get_name(sys))| Before scaling PJM has a total branch rating of $(rts_pjm_ratings) MW, NYISO has $(rts_nyiso_ratings) MW, and ISONE has $(rts_isone_ratings) MW (Total: $(rts_total_ratings) MW)."
    )
    @info(
        "|$(PSY.get_name(sys))| After scaling PJM has a total branch rating of $(updated_rts_pjm_ratings) MW, NYISO has $(updated_rts_nyiso_ratings) MW, and ISONE has $(updated_rts_isone_ratings) MW (Total: $(updated_rts_total_ratings) MW)."
    )
end

"""
    _scale_intertie_ratings!(sys::PSY.System, scale_factor_data::Dict)

Scales the ratings (capacity) of intertie (inter-area) AC transmission lines according to the provided scaling factors.
Prints before/after for each intertie.

# Arguments
- `sys`: The system object (PSY.System)
- `scale_factor_data`: Dictionary with scaling factors for each intertie pair
"""
function _scale_intertie_ratings!(sys::PSY.System, scale_factor_data::Dict)
    # Create bidirectional mapping of area pairs to their scaling factors
    # Each intertie can be traversed in both directions, so we need both (A,B) and (B,A)
    scale_factor = Dict(
        ("PJM", "NYISO") => scale_factor_data["pjm_nyiso_intertie_scaling"],
        ("NYISO", "PJM") => scale_factor_data["pjm_nyiso_intertie_scaling"],
        ("PJM", "ISONE") => scale_factor_data["pjm_isone_intertie_scaling"],
        ("ISONE", "PJM") => scale_factor_data["pjm_isone_intertie_scaling"],
        ("NYISO", "ISONE") => scale_factor_data["nyiso_isone_intertie_scaling"],
        ("ISONE", "NYISO") => scale_factor_data["nyiso_isone_intertie_scaling"],
    )

    # Get all intertie lines (AC transmission lines connecting different areas)
    interties = collect(
        PSY.get_components(
            x -> x.available && x.arc.from.area.name != x.arc.to.area.name,
            PSY.ACTransmission,
            sys,
        ),
    )

    # Scale each intertie line individually with detailed logging
    for line in interties
        area_pair = (line.arc.from.area.name, line.arc.to.area.name)
        @info(
            "|$(PSY.get_name(sys))| Original rating for intertie $(PSY.get_name(line)) between $(area_pair[1]) and $(area_pair[2]) is $(PSY.get_rating(line)) MW."
        )
        # Apply the scaling factor for this specific area pair
        PSY.set_rating!(line, PSY.get_rating(line) * scale_factor[area_pair])
        @info(
            "|$(PSY.get_name(sys))| Updated rating for intertie $(PSY.get_name(line)) between $(area_pair[1]) and $(area_pair[2]) is $(round(PSY.get_rating(line), digits = 2)) MW."
        )
    end
end

"""
    add_offshore_area!(sys::PSY.System, area_name = "Offshore")

Adds a new area (default name: "Offshore") to the system.
Prints confirmation.

# Arguments
- `sys`: The system object (PSY.System)
"""
function _add_offshore_area!(sys::PSY.System)

    # Create a new Area component for offshore wind generation
    # Initialize with zero peak powers since no existing loads/generators in this area
    area = PSY.Area(;
        name = "Offshore",
        peak_active_power = 0.0,  # Will be updated when offshore generators are added
        peak_reactive_power = 0.0,  # Will be updated when offshore generators are added
        load_response = 0.0,  # Offshore areas typically have no load response
        ext = Dict{String, Any}(),  # Empty extension dictionary for future metadata
    )

    # Add the new area to the system
    PSY.add_component!(sys, area)
    @info("|$(PSY.get_name(sys))| Area added: $(area.name)")
end

"""
    add_offshore_three_area!(sys::PSY.System)

Adds three new offshore wind areas to the system.
Prints confirmation.

# Arguments
- `sys`: The system object (PSY.System)
"""
function _add_offshore_three_area!(sys::PSY.System)
    # Create a new Area component for offshore wind generation
    # Initialize with zero peak powers since no existing loads/generators in this area
    for area_name in ["Offshore_PJM", "Offshore_NYISO", "Offshore_ISONE"]
        area = PSY.Area(;
            name = area_name,
            peak_active_power = 0.0,  # Will be updated when offshore generators are added
            peak_reactive_power = 0.0,  # Will be updated when offshore generators are added
            load_response = 0.0,  # Offshore areas typically have no load response
            ext = Dict{String, Any}(),  # Empty extension dictionary for future metadata
        )

        # Add the new area to the system
        PSY.add_component!(sys, area)
        @info("|$(PSY.get_name(sys))| Area added: $(area_name)")
    end
end

"""
    add_interchanges_one_area!(sys::PSY.System, scale_factor_data::Dict)

Adds AreaInterchange components between all major areas (PJM, NYISO, ISONE, Offshore) in the system.
For Offshore, uses a default flow limit; for others, sums ratings of interties.
Prints confirmation for each interchange.

# Arguments
- `sys`: The system object (PSY.System)
- `scale_factor_dict`: A dictionary containing scale factors for each area
"""
function _add_interchanges_one_area!(sys::PSY.System, scale_factor_data::Dict)
    # Define all area pairs that should have AreaInterchange components
    # This includes traditional inter-ISO connections and new offshore connections
    interchanges = [
        ("PJM", "NYISO"),      # Traditional Eastern Interconnection boundary
        ("PJM", "ISONE"),      # Traditional Eastern Interconnection boundary  
        ("NYISO", "ISONE"),    # Traditional Eastern Interconnection boundary
        ("Offshore", "PJM"),   # Offshore wind to PJM (e.g., Atlantic Coast)
        ("Offshore", "NYISO"), # Offshore wind to NYISO (e.g., NY Bight)
        ("Offshore", "ISONE"), # Offshore wind to ISONE (e.g., Gulf of Maine)
    ]

    # Get system base power for per-unit conversion of flow limits
    base_power = PSY.get_base_power(sys)

    # Create AreaInterchange component for each area pair
    for (from_area, to_area) in interchanges
        # Determine flow limits based on area type
        if from_area == "Offshore"
            # Use default flow limits for offshore connections (100 MW)
            # These will typically be updated when actual offshore transmission is added
            limit = scale_factor_data["rts_ei_offshore_installed"]
            flow_limits = (from_to = limit / base_power, to_from = limit / base_power)
        else
            # For traditional inter-ISO connections, sum up all existing AC transmission ratings
            interties = PSY.get_components(
                x ->
                    x.available && (
                        # Check both directions: A->B and B->A
                        (
                            x.arc.from.area.name == from_area &&
                            x.arc.to.area.name == to_area
                        ) || (
                            x.arc.from.area.name == to_area &&
                            x.arc.to.area.name == from_area
                        )
                    ),
                PSY.ACTransmission,
                sys,
            )
            # Convert MW ratings to per-unit for flow limits
            flow_limits = (
                from_to = sum(get_rating.(interties)) / base_power,
                to_from = sum(get_rating.(interties)) / base_power,
            )
        end

        # Create the AreaInterchange component
        interchange = PSY.AreaInterchange(;
            name = "$(from_area)_$(to_area)",
            available = true,
            active_power_flow = 0.0,  # Initial flow is zero
            from_area = get_component(PSY.Area, sys, from_area),
            to_area = get_component(PSY.Area, sys, to_area),
            flow_limits = flow_limits,
        )

        # Add interchange to system and log confirmation
        PSY.add_component!(sys, interchange)
        @info(
            "|$(PSY.get_name(sys))| Interchange added: $(from_area) <-> $(to_area) with flow limits from_to: $(round(flow_limits.from_to * base_power, digits = 2)) MW, to_from: $(round(flow_limits.to_from * base_power, digits = 2)) MW."
        )
    end
end

"""
    _add_offshore_one_generator!(sys::PSY.System, scale_factor_data::Dict)

Add an offshore wind generator and its associated transmission infrastructure to the power system.

This function creates a comprehensive offshore wind infrastructure by adding:
1. A dedicated offshore bus for the wind farm
2. A single large offshore wind generator
3. Converter buses at onshore connection points (Anna, Bardeen, Cary)
4. AC transformers for converter connections
5. HVDC transmission lines to connect offshore wind to each ISO area

The offshore wind capacity is distributed across three HVDC connections to PJM, NYISO, 
and ISONE areas based on the scaling factors provided in scale_factor_data.

# Arguments
- `sys::PSY.System`: The power system to modify
- `scale_factor_data::Dict`: Dictionary containing offshore wind capacity data with keys:
  - `"rts_ei_offshore_installed"`: Total offshore wind capacity (MW)
  - `"rts_pjm_offshore_installed"`: PJM-allocated offshore capacity (MW)
  - `"rts_nyiso_offshore_installed"`: NYISO-allocated offshore capacity (MW) 
  - `"rts_isone_offshore_installed"`: ISONE-allocated offshore capacity (MW)

# Details
- Creates offshore bus at 230 kV with bus number 401
- Adds RenewableDispatch generator with wind turbine prime mover
- Uses near-zero impedance transformer for converter connection between offshore and onshore buses
- HVDC lines have 10% transmission losses via LinearCurve
- All components are logged upon successful addition

# Modifies
- Adds offshore bus, generator, converter buses, AC lines and transformers, and HVDC lines to the system
"""
function _add_offshore_one_generator!(sys, scale_factor_data::Dict)
    # Extract total offshore wind generation capacity from scaling data
    offshore_gen_cap = scale_factor_data["rts_ei_offshore_installed"]

    # Define offshore infrastructure naming and numbering conventions
    offshore_bus_name = "Offshore_Wind_Bus"
    offshore_gen_name = "Offshore_Wind"
    offshore_bus_number = 401

    # Create a new offshore AC bus to serve as the collection point for offshore wind
    # This bus represents the offshore substation where the wind farm connects
    offshore_bus = PSY.ACBus(;
        name = offshore_bus_name,
        available = true,
        number = offshore_bus_number,
        bustype = PSY.ACBusTypes.PV,  # PV bus type for generator connection
        angle = 0.0,                  # Initial phase angle
        magnitude = 1.0,              # Initial voltage magnitude (p.u.)
        voltage_limits = (min = 0.95, max = 1.05),  # ±5% voltage tolerance
        base_voltage = 230.0,         # 230 kV transmission level
        area = PSY.get_component(PSY.Area, sys, "Offshore"),
    )

    # Add the offshore bus to the system
    PSY.add_component!(sys, offshore_bus)
    @info("|$(PSY.get_name(sys))| Offshore Bus added: $(offshore_bus_name).")

    # Create the offshore wind generator as a dispatchable renewable resource
    # Uses RenewableDispatch to allow for curtailment and dispatch optimization
    os_wind = RenewableDispatch(;
        name = offshore_gen_name,
        available = true,
        bus = offshore_bus,           # Connect to offshore bus
        active_power = 0.0,           # Initial active power output
        reactive_power = 0.0,         # Initial reactive power output
        rating = 1.0,                 # Per-unit rating
        prime_mover_type = PrimeMovers.WS,  # Wind turbine technology
        reactive_power_limits = (min = 0.0, max = 0.05),  # Limited reactive capability
        power_factor = 1.0,           # Unity power factor operation
        operation_cost = RenewableGenerationCost(nothing),  # No fuel costs
        base_power = offshore_gen_cap,  # Total capacity in MW
    )

    # Add the offshore wind generator to the system
    add_component!(sys, os_wind)
    @info(
        "|$(PSY.get_name(sys))| Offshore Wind Generator added: $(offshore_gen_name) with capacity $(round(offshore_gen_cap, digits = 2)) MW."
    )

    # Copy time series from another wind plant: 122_WIND_1
    wind_plant = get_component(PSY.RenewableDispatch, sys, "122_WIND_1")
    PSY.copy_time_series!(os_wind, wind_plant)
    @info(
        "|$(PSY.get_name(sys))| Time series copied from 122_WIND_1 to Offshore Wind Generator."
    )

    # Get system base power for per-unit conversions
    base_power = PSY.get_base_power(sys)

    # Define the three onshore connection points (one per ISO area)
    bus_names = [
        "Anna",    # PJM connection point (bus 111)
        "Bardeen", # NYISO connection point (bus 211) 
        "Cary",    # ISONE connection point (bus 311)
    ]

    # Define the corresponding ISO areas
    areas = [
        "PJM",
        "NYISO",
        "ISONE",
    ]

    # Define converter bus names for HVDC terminals
    dummy_buses = [
        "Anna_ConverterBus",
        "Bardeen_ConverterBus",
        "Cary_ConverterBus",
    ]

    # Define AC transformer names connecting each bus to its converter
    iso_dummy_lines = [
        "PJM-PJM_Transformer",
        "NYISO-NYISO_Transformer",
        "ISONE-ISONE_Transformer",
    ]

    # Define dummy AC line names from offshore bus to each converter
    offshore_dummy_lines = [
        "Offshore-PJM_Dummy_Line",
        "Offshore-NYISO_Dummy_Line",
        "Offshore-ISONE_Dummy_Line",
    ]

    # Define HVDC line names for each connection
    hvdc_lines = [
        "Offshore-PJM_HVDC",
        "Offshore-NYISO_HVDC",
        "Offshore-ISONE_HVDC",
    ]

    # Calculate HVDC capacity limits for each connection (in per-unit)
    hvdc_capacity = [
        scale_factor_data["rts_pjm_offshore_installed"] / base_power,     # PJM allocation (p.u.)
        scale_factor_data["rts_nyiso_offshore_installed"] / base_power,   # NYISO allocation (p.u.)
        scale_factor_data["rts_isone_offshore_installed"] / base_power,   # ISONE allocation (p.u.)
    ]

    # Create HVDC infrastructure for each ISO connection
    for (ix, bus_name) in enumerate(bus_names)

        # Get the existing onshore bus for this ISO area
        bus = PSY.get_component(PSY.ACBus, sys, bus_name)

        # Create a converter bus adjacent to the onshore bus
        # This represents the HVDC converter station terminal
        dummy_bus = PSY.ACBus(;
            name = dummy_buses[ix],
            available = true,
            number = PSY.get_number(bus) * 10,  # Use 10x original bus number
            bustype = PSY.get_bustype(bus),     # Match original bus characteristics
            angle = PSY.get_angle(bus),
            magnitude = PSY.get_magnitude(bus),
            voltage_limits = PSY.get_voltage_limits(bus),
            base_voltage = PSY.get_base_voltage(bus),
            area = PSY.get_area(bus),           # Same area as original bus
        )
        PSY.add_component!(sys, dummy_bus)
        @info("|$(PSY.get_name(sys))| Dummy Bus added: $(dummy_buses[ix]).")

        # Add near-zero impedance AC line between original bus and converter bus
        # This represents the short AC connection at the converter station
        dummy_iso_transformer = PSY.Transformer2W(;
            name = iso_dummy_lines[ix],
            arc = PSY.Arc(dummy_bus, bus),      # Connect converter to original bus
            available = true,
            active_power_flow = 0.0,
            reactive_power_flow = 0.0,
            r = 0.0,                            # Zero resistance (lossless)
            x = 0.05,                           # Minimal reactance for numerical stability
            primary_shunt = 0.0,         # No shunt susceptance
            rating = hvdc_capacity[ix],        # Same capacity as the HVDC connection
            base_power = base_power,
        )
        PSY.add_component!(sys, dummy_iso_transformer)
        @info(
            "|$(PSY.get_name(sys))| $(areas[ix])-$(areas[ix]) Transformer added: $(iso_dummy_lines[ix]) with rating of $(round(hvdc_capacity[ix] * base_power, digits = 2)) MW and 0.05 impedance."
        )

        # Add dummy AC line from offshore bus to converter bus
        # This is a modeling artifact required for HVDC connection topology
        arc_offshore_dummy = PSY.Arc(offshore_bus, dummy_bus)
        dummy_offshore_line = PSY.Line(;
            name = offshore_dummy_lines[ix],
            arc = arc_offshore_dummy,
            available = true,
            active_power_flow = 0.0,
            reactive_power_flow = 0.0,
            r = 0.0,                            # Zero resistance
            x = 1e-5,                           # Minimal reactance for stability
            b = (from = 0.0, to = 0.0),         # No shunt susceptance
            rating = 1e-6,                      # Near-zero rating (forces HVDC usage)
            angle_limits = (min = -1.8, max = 1.8),
        )
        PSY.add_component!(sys, dummy_offshore_line)
        @info(
            "|$(PSY.get_name(sys))| Dummy Offshore-Wind Line added: $(offshore_dummy_lines[ix]) with near zero rating and near zero impedance."
        )

        # Add the main HVDC transmission line for power transfer
        # This carries the actual offshore wind power to the onshore grid
        hvdc = PSY.TwoTerminalGenericHVDCLine(;
            name = hvdc_lines[ix],
            available = true,
            active_power_flow = 0.0,            # Initial power flow
            arc = arc_offshore_dummy,           # Same topology as dummy AC line
            active_power_limits_from = (min = 0.0, max = hvdc_capacity[ix]),  # Offshore->Onshore limits
            active_power_limits_to = (min = 0.0, max = hvdc_capacity[ix]),    # Onshore->Offshore limits
            reactive_power_limits_from = (min = 0.0, max = 0.0),              # No reactive transfer
            reactive_power_limits_to = (min = 0.0, max = 0.0),                # No reactive transfer
            loss = LinearCurve(0.1),            # 10% transmission losses
        )
        PSY.add_component!(sys, hvdc)
        @info(
            "|$(PSY.get_name(sys))| HVDC Line added: $(hvdc_lines[ix]) with rating $(round(hvdc_capacity[ix] * base_power, digits = 2)) MW."
        )
    end
end

function _add_new_intertie_hvdc_lines!(sys)
    areas = [
        "PJM",
        "NYISO",
        "ISONE",
    ]

    from_buses = [
        "Austen",
        "Curtiss",
        "Clark",
    ]

    to_buses = [
        "Bates",
        "Attlee",
        "Bloch",
    ]

    converter_buses = [
        "Bates_ConverterBus",
        "Attlee_ConverterBus",
        "Bloch_ConverterBus",
    ]

    rate_new_lines = 1000.0 # 1 GW
    base_power = PSY.get_base_power(sys)
    rate_new_lines_pu = rate_new_lines / base_power

    for (ix, to_bus_name) in enumerate(to_buses)
        # Get the existing TO bus for this ISO area
        to_bus = PSY.get_component(PSY.ACBus, sys, to_bus_name)
        # Get the FROM area for this ISO area
        from_bus = PSY.get_component(PSY.ACBus, sys, from_buses[ix])
        from_area = PSY.get_area(from_bus)

        # Create a converter bus adjacent to the TO bus, but in the FROM area
        # This represents the HVDC converter station terminal
        dummy_bus = PSY.ACBus(;
            name = converter_buses[ix],
            available = true,
            number = PSY.get_number(to_bus) * 10,  # Use 10x original TO bus number
            bustype = PSY.ACBusTypes.PQ,     # PQ Bus
            angle = PSY.get_angle(to_bus),
            magnitude = PSY.get_magnitude(to_bus),
            voltage_limits = PSY.get_voltage_limits(to_bus),
            base_voltage = PSY.get_base_voltage(to_bus),
            area = from_area,
        )
        PSY.add_component!(sys, dummy_bus)
        @info(
            "|$(PSY.get_name(sys))| Converter Bus added: $(converter_buses[ix]) located at area $(from_area.name)."
        )

        # Add near-zero impedance AC transformer between TO bus and converter bus
        # This represents the AC connection at the converter station
        dummy_iso_transformer = PSY.Transformer2W(;
            name = "$(from_bus.area.name)_$(to_bus.area.name)_Transformer",
            arc = PSY.Arc(from_bus, dummy_bus),      # Connect converter to original TO bus
            available = true,
            active_power_flow = 0.0,
            reactive_power_flow = 0.0,
            r = 0.0,                            # Zero resistance (lossless)
            x = 0.05,                           # Minimal reactance for numerical stability
            primary_shunt = 0.0,         # No shunt susceptance
            rating = rate_new_lines / base_power,        # Same capacity as the HVDC connection
            base_power = base_power,
        )
        @info(
            "|$(PSY.get_name(sys))| $(from_bus.area.name)-$(to_bus.area.name) Transformer added: $(dummy_iso_transformer.name) with rating of $(round(rate_new_lines, digits = 2)) MW and 0.05 impedance."
        )
        PSY.add_component!(sys, dummy_iso_transformer)

        # Add HVDC line between FROM bus and converter bus
        hvdc_line = PSY.TwoTerminalGenericHVDCLine(;
            name = "$(from_bus.area.name)_$(to_bus.area.name)_new_HVDC",
            arc = PSY.Arc(dummy_bus, to_bus),
            available = true,
            active_power_flow = 0.0,
            active_power_limits_from = (min = -rate_new_lines_pu, max = rate_new_lines_pu),  # Offshore->Onshore limits
            active_power_limits_to = (min = -rate_new_lines_pu, max = rate_new_lines_pu),    # Onshore->Offshore limits
            reactive_power_limits_from = (min = 0.0, max = 0.0),              # No reactive transfer
            reactive_power_limits_to = (min = 0.0, max = 0.0),                # No reactive transfer
            loss = LinearCurve(0.1),            # 10% transmission losses
        )
        PSY.add_component!(sys, hvdc_line)
        @info(
            "|$(PSY.get_name(sys))| HVDC Line added: $(hvdc_line.name) with rating $(round(rate_new_lines, digits = 2)) MW."
        )
    end
end
