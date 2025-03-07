using Documenter, PowerSystemCaseBuilder
import DataStructures: OrderedDict
# using Literate

if isfile("docs/src/howto/.DS_Store.md")
    rm("docs/src/howto/.DS_Store.md")
end

pages = OrderedDict(
    "Welcome" => "index.md",
    ## TODO remove stubs as new material is added
    # "Tutorials" => Any["stub" => "tutorials/stub.md"],
    # "How to..." => Any["stub" => "how_to_guides/stub.md"],
    # "Explanation" => Any["stub" => "explanation/stub.md"],
    "Reference" => Any[
        "Public API" => "reference/public.md",
        "Developers" => ["Developer Guidelines" => "reference/developer_guidelines.md",
        "Internals" => "reference/internal.md"],
    ],
)

makedocs(;
    sitename = "PowerSystemCaseBuilder.jl",
    format = Documenter.HTML(;
        mathengine = Documenter.MathJax(),
        prettyurls = haskey(ENV, "GITHUB_ACTIONS"),
    ),
    modules = [PowerSystemCaseBuilder],
    authors = "Sourabh Dalvi, Kate Doubleday",
    pages = Any[p for p in pages],
)

deploydocs(;
    repo = "github.com/NREL-Sienna/PowerSystemCaseBuilder.jl.git",
    target = "build",
    branch = "gh-pages",
    devbranch = "main",
    devurl = "dev",
    push_preview=true,
    versions = ["stable" => "v^", "v#.#"],
)
