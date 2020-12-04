function check_storage_dir(
    folder::AbstractString = SERIALIZED_SYSTEM_DIR,
)
    directory = abspath(normpath(folder))
    if !isdir(directory)
        mkpath(directory)
    end
end

function clear_serialized_system(name::String)
    files = joinpath.(SERIALIZED_SYSTEM_DIR, filter(contains(name), readdir(SERIALIZED_SYSTEM_DIR)))
    for file in files
        @debug "Deleting file" file
        rm(file, force = true)
    end
end

function clear_serialized_system_library()
    if isfile(SERIALIZED_SYSTEM_DESCRIPTORS_FILE)
        @debug "Deleting file" SERIALIZED_SYSTEM_DESCRIPTORS_FILE
        rm(SERIALIZED_SYSTEM_DESCRIPTORS_FILE, force = true)
    end
end
