mutable struct SystemCatalog
    data::Dict{DataType, Dict{String, SystemDescriptor}}
end

function get_system_descriptor(
    category::Type{<:SystemCategory},
    catalog::SystemCatalog,
    name::String,
)
    data = catalog.data
    if haskey(data, category) && haskey(data[category], name)
        return data[category][name]
    else
        error("System $(name) of Category $(category) not found in current SystemCatalog")
    end
end

function get_system_descriptors(category::Type{<:SystemCategory}, catalog::SystemCatalog)
    data = catalog.data
    if haskey(data, category)
        array = SystemDescriptor[descriptor for descriptor in values(data[category])]
        return array
    else
        error("Category $(category) not found in SystemCatalog")
    end
end

function list_categories()
    catalog = SystemCatalog()
    return list_categories(catalog)
end

list_categories(c::SystemCatalog) = sort!([x for x in (keys(c.data))], by = x -> string(x))

function SystemCatalog(system_catalogue::Array{SystemDescriptor} = SYSTEM_CATELOG)
    data = Dict{DataType, Dict{String, SystemDescriptor}}()
    for descriptor in system_catalogue
        category = get_category(descriptor)
        if haskey(data, category)
            push!(data[category], (descriptor.name => descriptor))
        else
            push!(data, (category => Dict{String, SystemDescriptor}()))
            push!(data[category], (descriptor.name => descriptor))
        end
    end
    return SystemCatalog(data)
end
