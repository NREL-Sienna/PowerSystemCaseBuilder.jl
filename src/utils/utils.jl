using Base.Filesystem
using JSON
using IterTools

function verify_storage_dir(folder::AbstractString = SERIALIZED_DIR)
    directory = abspath(normpath(folder))
    if !isdir(directory)
        mkpath(directory)
    end
end

function check_serialized_storage()
    verify_storage_dir(SERIALIZED_DIR)
    for path in SEARCH_DIRS
        verify_storage_dir(path)
    end
    return
end

function clear_serialized_systems(name::String)
    seralized_file_extension =
        [".json", "_validation_descriptors.json", "_time_series_storage.h5"]
    file_names = [name * ext for ext in SERIALIZE_FILE_EXTENSIONS]
    for dir in SEARCH_DIRS
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

    try
        if isfile(file_path)
            @debug "Deleting file at " file_path
            rm(file_path; force = true)
        end
    catch e
        @show uperm(dirname(file_path))
        @show gperm(dirname(file_path))
        @show operm(dirname(file_path))
        @show isdir(dirname(file_path)) && readdir(dirname(file_path))
        rethrow()
    end

    return
end

function clear_all_serialized_system()
    for dir in SEARCH_DIRS
        @debug "Deleting dir" dir
        rm(dir; force = true, recursive = true)
    end
    check_serialized_storage()
    return
end

function get_serialization_dir(case_args::Dict{Symbol, <:Any} = Dict{Symbol, Any}())
    args_string = join(["$key=$value" for (key, value) in case_args], "_")
    hash_value = hash(args_string)
    return joinpath(PACKAGE_DIR, "data", "serialized_system", "$hash_value")
end

#make sure to have a check for unique name
function get_serialized_filepath(
    name::String,
    case_args::Dict{Symbol, <:Any} = Dict{Symbol, Any}(),
)
    dir = get_serialization_dir(case_args)
    if isdir(dir) && has_duplicates(dir, "$(name).json")
        throw(
            ErrorException(
                "Duplicate file name = $(name).json is detected in directory = $(dir)!",
            ),
        )
    else
        return joinpath(dir, "$(name).json")
    end
end

function is_serialized(name::String, case_args::Dict{Symbol, <:Any} = Dict{Symbol, Any}())
    file_path = get_serialized_filepath(name, case_args)

    try
        if isfile(file_path)
            return true
        else
            return false
        end
    catch e
        @show uperm(dirname(file_path))
        @show gperm(dirname(file_path))
        @show operm(dirname(file_path))
        @show isdir(dirname(file_path)) && readdir(dirname(file_path))
        rethrow()
    end
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
function check_parameters_json(case_args::Dict{Symbol, <:Any})
    dir_path = get_serialization_dir(case_args)
    file_path = joinpath(dir_path, "case_parameters.json")
    case_args_json = JSON.json(case_args)

    if !isfile(file_path)
        open(file_path, "w") do file
            write(file, case_args_json)
        end
    end
end

function has_duplicates(directory::String, filename::String)
    files = readdir(directory)
    file_count = count(file -> file == filename, files)
    return file_count > 1
end
