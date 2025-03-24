function add_static_outage_data!(sys::PSY.System, gen_outage_data::DataFrame)
    for row in DataFrames.eachrow(gen_outage_data)
        transition_data = PSY.GeometricDistributionForcedOutage(;
            mean_time_to_recovery = row["MTTR(Hour)"],
            outage_transition_probability = row["lambda"],
        )

        comp = PSY.get_component(PSY.Generator, sys, row["GEN UID"])

        if !isnothing(comp)
            PSY.add_supplemental_attribute!(sys, comp, transition_data)
            @debug "Added outage data supplemental attribute to $(row["GEN UID"]) generator"
        else
            @warn "$(row["GEN UID"]) generator doesn't exist in the System."
        end
    end
end

function add_timeseries_outage_data!(sys::PSY.System, outage_data_file::HDF5.File)
    # Time series timestamps
    timestamps = Dates.DateTime.(read(outage_data_file["timestamps"])["timestamps"])

    # Add λ and μ time series 
    for gen_name in filter(x -> x !== "timestamps", keys(outage_data_file))
        comp = PSY.get_component(PSY.Generator, sys, gen_name)
        comp_supp_attr = first(
            PSY.get_supplemental_attributes(
                PSY.GeometricDistributionForcedOutage,
                comp,
            ),
        )
        PSY.add_time_series!(
            sys,
            comp_supp_attr,
            PSY.SingleTimeSeries(
                "outage_probability",
                TimeSeries.TimeArray(
                    timestamps,
                    read(outage_data_file[gen_name])["lambda"],
                ),
            ),
        )
        PSY.add_time_series!(
            sys,
            comp_supp_attr,
            PSY.SingleTimeSeries(
                "recovery_probability",
                TimeSeries.TimeArray(timestamps, read(outage_data_file[gen_name])["mu"]),
            ),
        )
        @debug "Added outage probability and recovery probability time series to supplemental attribute of $(gen_name) generator"
    end
end

function build_rts_gmlc_da_with_static_outage_data(; raw_data, kwargs...)
    sys = build_RTS_GMLC_DA_sys(; raw_data, kwargs...)
    RTS_SRC_DIR = joinpath(raw_data, "RTS_Data", "SourceData")

    gen_outage_data = CSV.read(
        joinpath(DATA_DIR, "spi_data", "RTS_GMLC", "Static_Outage_Data.csv"),
        DataFrame,
    )
    add_static_outage_data!(sys, gen_outage_data)

    return sys
end

function build_rts_gmlc_da_with_timeseries_outage_data(; raw_data, kwargs...)
    sys = build_rts_gmlc_da_with_static_outage_data(; raw_data, kwargs...)

    outage_data_file = HDF5.h5open(
        joinpath(DATA_DIR, "spi_data", "RTS_GMLC", "DA_Outage_TimeSeries_LambdaMu.h5"),
    )
    add_timeseries_outage_data!(sys, outage_data_file)

    return sys
end

function build_rts_gmlc_rt_with_static_outage_data(; raw_data, kwargs...)
    sys = build_RTS_GMLC_RT_sys(; raw_data, kwargs...)
    RTS_SRC_DIR = joinpath(raw_data, "RTS_Data", "SourceData")

    gen_outage_data = CSV.read(
        joinpath(DATA_DIR, "spi_data", "RTS_GMLC", "Static_Outage_Data.csv"),
        DataFrame,
    )
    add_static_outage_data!(sys, gen_outage_data)

    return sys
end

function build_rts_gmlc_rt_with_timeseries_outage_data(; raw_data, kwargs...)
    sys = build_rts_gmlc_rt_with_static_outage_data(; raw_data, kwargs...)

    outage_data_file = HDF5.h5open(
        joinpath(DATA_DIR, "spi_data", "RTS_GMLC", "RT_Outage_TimeSeries_LambdaMu.h5"),
    )
    add_timeseries_outage_data!(sys, outage_data_file)

    return sys
end
