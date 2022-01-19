abstract type SystemCategory <: PowerSystemCaseBuilderType end
struct PSYTestSystems <: SystemCategory end
struct PSITestSystems <: SystemCategory end
struct SIIPExampleSystems <: SystemCategory end
struct PSIDTestSystems <: SystemCategory end
struct PSSETestSystems <: SystemCategory end
struct MatPowerTestSystems <: SystemCategory end

const PACKAGE_DIR = joinpath(dirname(dirname(pathof(PowerSystemCaseBuilder))))

const SYSTEM_DESCRIPTORS_FILE = joinpath(PACKAGE_DIR, "src", "system_descriptor.jl")

const SERIALIZED_DIR = joinpath(PACKAGE_DIR, "data", "serialized_system")
const SERIALIZE_NOARGS_DIR = joinpath(PACKAGE_DIR, "data", "serialized_system", "NoArgs")
const SERIALIZE_FORECASTONLY_DIR =
    joinpath(PACKAGE_DIR, "data", "serialized_system", "ForecastOnly")
const SERIALIZE_RESERVEONLY_DIR =
    joinpath(PACKAGE_DIR, "data", "serialized_system", "ReserveOnly")
const SERIALIZE_FORECASTRESERVE_DIR =
    joinpath(PACKAGE_DIR, "data", "serialized_system", "ForecastReserve")

const SEARCH_DIRS = [
    SERIALIZE_NOARGS_DIR,
    SERIALIZE_FORECASTONLY_DIR,
    SERIALIZE_RESERVEONLY_DIR,
    SERIALIZE_FORECASTRESERVE_DIR,
]

const SERIALIZE_FILE_EXTENSIONS =
    [".json", "_validation_descriptors.json", "_time_series_storage.h5"]

function download_RTS(; kwargs...)
    PowerSystems.download(
        "https://github.com/GridMod/RTS-GMLC",
        "master",
        joinpath(PACKAGE_DIR, "data"),
    )
end

function download_modified_tamu_ercot_da(; kwargs...)
    directory = abspath(normpath(joinpath(PACKAGE_DIR, "data")))
    data = joinpath(directory, "tamu_ercot")
    # This is temporary place for hosting the dataset.
    data_urls = Dict(
        "DA_sys.json" => "https://www.dropbox.com/sh/uzohjqzoyinyyas/AAC40qKEowAbGax-yYiB_4wna/DA_sys.json?dl=1",
        "DA_sys_validation_descriptors.json" => "https://www.dropbox.com/sh/uzohjqzoyinyyas/AADWU21wuWW62Fl5SP4ubo8Va/DA_sys_validation_descriptors.json?dl=1",
        "DA_sys_time_series_storage.h5" => "https://www.dropbox.com/sh/uzohjqzoyinyyas/AADURazsNKxO5l4_1wBiW8qsa/DA_sys_time_series_storage.h5?dl=1",
    )
    if !isdir(data)
        @info "Downloading TAMU ERCOT dataset."
        mkpath(data)
        for (file, urls) in data_urls
            tempfilename = Base.download(urls)
            mv(tempfilename, joinpath(data, file), force = true)
        end
    end
    return data
end
