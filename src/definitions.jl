const PACKAGE_DIR = joinpath(dirname(dirname(pathof(PowerSystemCaseBuilder))))

const PSTD_DIR_KEY = "PSTD_DIR"  # Environment variable to check for PowerSystemsTestData directory
const PSTD_ARTIFACT_PATH =
    joinpath(LazyArtifacts.artifact"CaseData", "PowerSystemsTestData-3.2")

const RTS_DIR_KEY = "RTS_DIR"  # Environment variable to check for RTS directory
const RTS_ARTIFACT_PATH = joinpath(LazyArtifacts.artifact"rts", "RTS-GMLC-0.2.2")

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

function get_data_dir(data_dir_key, artifact_path)
    if haskey(ENV, data_dir_key)
        candidate = ENV[data_dir_key]
        if isdir(candidate)
            @debug "Using PSB data dir $candidate from environment variable"
            return candidate
        else
            error(
                "The directory specified by the environment variable $data_dir_key, $candidate, does not exist.",
            )
        end
    else
        candidate = artifact_path
        if isdir(candidate)
            @debug "Using default PSB data dir $candidate"
            return candidate
        else
            error(
                "Nothing specified by environment variable $data_dir_key, and the default, $candidate, does not exist.",
            )
        end
    end
end

function set_data_dir!(data_dir_key, dir::AbstractString)
    isdir(dir) || @warn("Directory $dir does not exist, continuing anyway")
    ENV[data_dir_key] = dir
    return
end

function with_data_dir(f::Function, data_dir_key, dir::AbstractString)
    isdir(dir) || @warn("Directory $dir does not exist, continuing anyway")
    return withenv(f, data_dir_key => dir)
end

function reset_data_dir!(data_dir_key)
    delete!(ENV, data_dir_key)
    return
end

get_pstd_data_dir() = get_data_dir(PSTD_DIR_KEY, PSTD_ARTIFACT_PATH)
get_rts_data_dir() = get_data_dir(RTS_DIR_KEY, RTS_ARTIFACT_PATH)

set_pstd_data_dir!(dir::AbstractString) = set_data_dir!(PSTD_DIR_KEY, dir)
set_rts_data_dir!(dir::AbstractString) = set_data_dir!(RTS_DIR_KEY, dir)

with_pstd_data_dir!(f::Function, data_dir::AbstractString) =
    with_data_dir(f, PSTD_DIR_KEY, data_dir)
with_rts_data_dir!(f::Function, data_dir::AbstractString) =
    with_data_dir(f, RTS_DIR_KEY, data_dir)

reset_pstd_data_dir!() = reset_data_dir!(PSTD_DIR_KEY)
reset_rts_data_dir!() = reset_data_dir!(RTS_DIR_KEY)
