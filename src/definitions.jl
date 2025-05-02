const PACKAGE_DIR = joinpath(dirname(dirname(pathof(PowerSystemCaseBuilder))))

const PSTD_DIR_KEY = "PSTD_DIR"  # Environment variable to check for PowerSystemsTestData directory
const RTS_DIR_KEY = "RTS_DIR"  # Environment variable to check for RTS directory

const ARTIFACT_PATHS = Dict(
    PSTD_DIR_KEY => joinpath(LazyArtifacts.artifact"CaseData", "PowerSystemsTestData-3.2"),
    RTS_DIR_KEY => joinpath(LazyArtifacts.artifact"rts", "RTS-GMLC-0.2.2"),
)

# Julia files we'll need to `include` from paths that depend on data dir keys
const DATA_INCLUDES_PATHS = Dict(
    PSTD_DIR_KEY => [
        joinpath("psy_data", "generation_cost_function_data.jl"),
        joinpath("psy_data", "data_5bus_pu.jl"),
        joinpath("psy_data", "data_10bus_ac_dc_pu.jl"),
        joinpath("psy_data", "data_14bus_pu.jl"),
        joinpath("psy_data", "data_mthvdc_twin_rts.jl"),
        joinpath("psid_tests", "data_tests", "dynamic_test_data.jl"),
        joinpath("psid_tests", "data_examples",  "load_tutorial_functions.jl"),
        # uncomment once PR #65 in PowerSystemsTestData is merged
        # joinpath("118-Bus", "data_118bus.jl"),
    ],
    RTS_DIR_KEY => [],
)

# Global state to keep track of the root paths we have loaded the DATA_INCLUDES_PATHS files from
DATA_INCLUDES_STATUS = Dict{String, Ref{Union{Nothing, String}}}(key => nothing for key in keys(DATA_INCLUDES_PATHS))

const SYSTEM_DESCRIPTORS_FILE = joinpath(PACKAGE_DIR, "src", "system_descriptor.jl")

const SERIALIZED_DIR = joinpath(PACKAGE_DIR, "data", "serialized_system")

const SERIALIZE_FILE_EXTENSIONS =
    [".json", "_metadata.json", "_validation_descriptors.json", "_time_series_storage.h5"]

const ACCEPTED_PSID_TEST_SYSTEMS_KWARGS = [:avr_type, :tg_type, :pss_type, :gen_type]
const AVAILABLE_PSID_PSSE_AVRS_TEST =
    ["AC1A", "AC1A_SAT", "EXAC1", "EXST1", "SEXS", "SEXS_noTE"]

const AVAILABLE_PSID_PSSE_TGS_TEST = ["GAST", "HYGOV", "TGOV1"]

const AVAILABLE_PSID_PSSE_GENS_TEST = [
    "GENCLS",
    "GENROE",
    "GENROE_SAT",
    "GENROU",
    "GENROU_NoSAT",
    "GENROU_SAT",
    "GENSAE",
    "GENSAL",
]

const AVAILABLE_PSID_PSSE_PSS_TEST = ["STAB1", "IEEEST", "IEEEST_FILTER"]

function reload_includes(data_dir_key, include_path::String)
    old_path = DATA_INCLUDES_STATUS[data_dir_key][]
    (old_path == include_path) && return

    if isnothing(old_path)
        @info "Loading $data_dir_key files from $include_path"
    else
        throw(error("$data_dir_key data files are already loaded from $old_path. We don't currently support changing the data source once PowerSystemCaseBuilder has already initialized. Consider setting the $data_dir_key environment variable to the desired path before importing PowerSystemCaseBuilder."))
    end

    for p in DATA_INCLUDES_PATHS[data_dir_key]
        @show p
        include(joinpath(include_path, p))
    end
    # include.(joinpath.(include_path, DATA_INCLUDES_PATHS[data_dir_key]))
    DATA_INCLUDES_STATUS[data_dir_key][] = include_path
end

reload_includes(data_dir_key) =
    reload_includes(
        data_dir_key,
        calculate_data_dir(data_dir_key, ARTIFACT_PATHS[data_dir_key])
    )

reload_all_includes() = reload_includes.(keys(DATA_INCLUDES_STATUS))

SYSTEM_CATALOG_REF = Ref{Any}(nothing)
function reload_catalog()
    reload_all_includes()
    println("LIBRARY")
    include("src/system_library.jl")
    println("DESCRIPTOR DATA")
    include("src/system_descriptor_data.jl")
end

function calculate_data_dir(data_dir_key, artifact_path)
    if haskey(ENV, data_dir_key)
        candidate = ENV[data_dir_key]
        if isdir(candidate)
            @debug "Using PSB data dir $candidate from environment variable"
        else
            error(
                "The directory specified by the environment variable $data_dir_key, $candidate, does not exist.",
            )
        end
    else
        candidate = artifact_path
        if isdir(candidate)
            @debug "Using default PSB data dir $candidate"
        else
            error(
                "Nothing specified by environment variable $data_dir_key, and the default, $candidate, does not exist.",
            )
        end
    end
    return candidate
end

get_pstd_data_dir() = DATA_INCLUDES_STATUS[PSTD_DIR_KEY][]
get_rts_data_dir() = DATA_INCLUDES_STATUS[RTS_DIR_KEY][]

from_data_dir(data_dir_key, subpath...) =
    (DATA_INCLUDES_STATUS[data_dir_key], isempty(subpath) ? "" : joinpath(subpath...))
from_pstd_data_dir(subpath...) = from_data_dir(PSTD_DIR_KEY, subpath...)
from_rts_data_dir(subpath...) = from_data_dir(RTS_DIR_KEY, subpath...)
