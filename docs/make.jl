using Documenter, PowerSystemCaseBuilder
# import DataStructures: OrderedDict
# using Literate

if isfile("docs/src/howto/.DS_Store.md")
    rm("docs/src/howto/.DS_Store.md")
end

makedocs(
    sitename = "PowerSystemCaseBuilder.jl",
    format = Documenter.HTML(
        mathengine = Documenter.MathJax(),
        prettyurls = get(ENV, "CI", nothing) == "true",
    ),
    modules = [PowerSystemCaseBuilder],
    strict = true,
    authors = "Sourabh Dalvi",
    pages = Any[
        "Introduction" => "index.md",
    ],
)

deploydocs(
    repo = "github.com/NREL-SIIP/PowerSystemCaseBuilder.jl.git",
    target = "build",
    branch = "gh-pages",
    devbranch = "master",
    devurl = "dev",
    versions = ["stable" => "v^", "v#.#"],
)
