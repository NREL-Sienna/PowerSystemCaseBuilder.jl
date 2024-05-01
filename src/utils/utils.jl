function verify_storage_dir(folder::AbstractString = SERIALIZED_DIR)
    directory = abspath(normpath(folder))
    if !isdir(directory)
        mkpath(directory)
    end
end

function check_serialized_storage()
    verify_storage_dir(SERIALIZED_DIR)
    return
end

function clear_serialized_systems(name::String)
    file_names = [name * ext for ext in SERIALIZE_FILE_EXTENSIONS]
    for dir in _get_system_directories(SERIALIZED_DIR)
        for file in file_names
            if isfile(joinpath(dir, file))
                @debug "Deleting file" file
                rm(joinpath(dir, file); force = true)
            end
        end
    end
    return
end

function clear_serialized_system(
    name::String,
    case_args::Dict{Symbol, <:Any} = Dict{Symbol, Any}(),
)
    file_path = get_serialized_filepath(name, case_args)
    if isfile(file_path)
        @debug "Deleting file at " file_path
        rm(file_path; force = true)
    end

    return
end

function clear_all_serialized_systems(path::String)
    for path in _get_system_directories(path)
        rm(path; recursive = true)
    end
end

clear_all_serialized_systems() = clear_all_serialized_systems(SERIALIZED_DIR)
clear_all_serialized_system() = clear_all_serialized_systems()

function get_serialization_dir(case_args::Dict{Symbol, <:Any} = Dict{Symbol, Any}())
    args_string = join(["$key=$value" for (key, value) in case_args], "_")
    hash_value = bytes2hex(SHA.sha256(args_string))
    return joinpath(PACKAGE_DIR, "data", "serialized_system", "$hash_value")
end

function get_serialized_filepath(
    name::String,
    case_args::Dict{Symbol, <:Any} = Dict{Symbol, Any}(),
)
    dir = get_serialization_dir(case_args)
    return joinpath(dir, "$(name).json")
end

function is_serialized(name::String, case_args::Dict{Symbol, <:Any} = Dict{Symbol, Any}())
    file_path = get_serialized_filepath(name, case_args)
    return isfile(file_path)
end

function get_raw_data(; kwargs...)
    if haskey(kwargs, :raw_data)
        return kwargs[:raw_data]
    else
        throw(ArgumentError("Raw data directory not passed in build function."))
    end
end

function filter_kwargs(; kwargs...)
    system_kwargs = filter(x -> in(first(x), PSY.SYSTEM_KWARGS), kwargs)
    return system_kwargs
end

function check_kwargs_psid(; kwargs...)
    psid_kwargs = filter(x -> in(first(x), ACCEPTED_PSID_TEST_SYSTEMS_KWARGS), kwargs)
    return psid_kwargs
end

"""
Creates a JSON file informing the user about the meaning of the hash value in the file path
if it doesn't exist already 
"""
function serialize_case_parameters(case_args::Dict{Symbol, <:Any})
    dir_path = get_serialization_dir(case_args)
    file_path = joinpath(dir_path, "case_parameters.json")

    if !isfile(file_path)
        open(file_path, "w") do io
            JSON3.write(io, case_args)
        end
    end
end

function _get_system_directories(path::String)
    return (
        joinpath(path, x) for
        x in readdir(path) if isdir(joinpath(path, x)) && _is_system_hash_name(x)
    )
end

_is_system_hash_name(name::String) = isempty(filter(!isxdigit, name))
