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
