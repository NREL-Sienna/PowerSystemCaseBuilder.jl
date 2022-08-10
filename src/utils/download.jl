import Downloads
abstract type AbstractOS end
abstract type Unix <: AbstractOS end
abstract type BSD <: Unix end

abstract type Windows <: AbstractOS end
abstract type MacOS <: BSD end
abstract type Linux <: BSD end

const os = if Sys.iswindows()
    Windows
elseif Sys.isapple()
    MacOS
else
    Linux
end

"""
Download Data from a "branch" into a "data" folder in given argument path.
Skip the actual download if the folder already exists and force=false.
Returns the downloaded folder name.
"""
function Downloads.download(
    repo::AbstractString,
    branch::AbstractString,
    folder::AbstractString,
    force::Bool = false,
)
    if Sys.iswindows()
        DATA_URL = "$repo/archive/$branch.zip"
    else
        DATA_URL = "$repo/archive/$branch.tar.gz"
    end
    directory = abspath(normpath(folder))
    reponame = splitpath(repo)[end]
    data = joinpath(directory, "$reponame-$branch")
    if !isdir(data) || force
        @info "Downloading $DATA_URL"
        tempfilename = Downloads.download(DATA_URL)
        mkpath(directory)
        @info "Extracting data to $data"
        unzip(os, tempfilename, directory)
    end

    return data
end

function unzip(::Type{<:BSD}, filename, directory)
    @assert success(`tar -xvf $filename -C $directory`) "Unable to extract $filename to $directory"
end

function unzip(::Type{Windows}, filename, directory)
    path_7z = if Base.VERSION < v"0.7-"
        "$JULIA_HOME/7z"
    else
        sep = Sys.iswindows() ? ";" : ":"
        withenv(
            "PATH" => string(
                joinpath(Sys.BINDIR, "..", "libexec"),
                sep,
                Sys.BINDIR,
                sep,
                ENV["PATH"],
            ),
        ) do
            Sys.which("7z")
        end
    end
    @assert success(`$path_7z x $filename -y -o$directory`) "Unable to extract $filename to $directory"
end

function download_RTS(; kwargs...)
    download(
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
