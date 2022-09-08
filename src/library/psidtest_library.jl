function build_psid_psse_test_avr(; kwargs...)
    sys_kwargs = filter_kwargs(; kwargs...)
    data_dir = get_raw_data(; kwargs...)
    avr_type = get(kwargs, :avr_type, "")
    if isempty(avr_type)
        error("No AVR type provided. Provide :avr_type as kwarg when using build_system")
    elseif avr_type == "AC1A_SAT"
        raw_file = joinpath(data_dir, "AC1A/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "AC1A/ThreBus_ESAC1A_SAT.dyr")
    elseif avr_type == "AC1A"
        raw_file = joinpath(data_dir, "AC1A/ThreeBusMulti.raw")
        dyr_file = joinpath(data_dir, "AC1A/ThreBus_ESAC1A.dyr")
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
            "Kwarg :avr_type = $(avr_type) for PSID/PSSE test not supported. Available kwargs are: $(AVAILABLE_PSID_PSSE_AVRS_TEST)",
        )
    end
    avr_sys = System(raw_file, dyr_file; sys_kwargs...)
    for l in get_components(PSY.PowerLoad, avr_sys)
        PSY.set_model!(l, PSY.LoadModels.ConstantImpedance)
    end
    return avr_sys
end
