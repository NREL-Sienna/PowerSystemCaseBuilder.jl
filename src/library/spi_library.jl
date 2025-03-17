function build_rts_gmlc_with_static_outage_data(; raw_data, kwargs...)
    sys = build_RTS_GMLC_DA_sys(; raw_data, kwargs...)
    RTS_SRC_DIR = joinpath(raw_data, "RTS_Data", "SourceData")

    gen_for_data = CSV.read(joinpath(RTS_SRC_DIR, "gen.csv"), DataFrames.DataFrame)

    for row in DataFrames.eachrow(gen_for_data)
        λ, μ = SPI.rate_to_probability(row.FOR, row["MTTR Hr"])
        transition_data = PSY.GeometricDistributionForcedOutage(;
            mean_time_to_recovery = row["MTTR Hr"],
            outage_transition_probability = λ,
        )
        comp = PSY.get_component(PSY.Generator, sys, row["GEN UID"])

        if !isnothing(comp)
            PSY.add_supplemental_attribute!(sys, comp, transition_data)
            @debug "Added outage data supplemental attribute to $(row["GEN UID"]) generator"
        else
            @warn "$(row["GEN UID"]) generator doesn't exist in the System."
        end
    end

    return sys
end
