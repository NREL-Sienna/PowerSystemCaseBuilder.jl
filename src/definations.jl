IS.@scoped_enum SystemCategory begin
    PCMSystem
    DynamicSystems
    TestSystem
end

const PACKAGE_DIR = joinpath(dirname(dirname(pathof(PowerSystemBuilder))))

const SYSTEM_DESCRIPTORS_FILE =
    joinpath(PACKAGE_DIR, "src", "system_descriptor.json")

const SERIALIZED_SYSTEM_DESCRIPTORS_FILE =
    joinpath(PACKAGE_DIR, "data", "serialized_system_descriptor.json")

const SERIALIZED_SYSTEM_DIR = joinpath(PACKAGE_DIR, "data", "serialized_system")



const ENUMS = (
    SystemCategorys.SystemCategory,
)

const ENUM_MAPPINGS = Dict()

for enum in ENUMS
    ENUM_MAPPINGS[enum] = Dict()
    for value in instances(enum)
        ENUM_MAPPINGS[enum][lowercase(string(value))] = value
    end
end

"""Get the enum value for the string. Case insensitive."""
function get_enum_value(enum, value::String)
    if !haskey(ENUM_MAPPINGS, enum)
        throw(ArgumentError("enum=$enum is not valid"))
    end

    val = lowercase(value)
    if !haskey(ENUM_MAPPINGS[enum], val)
        throw(ArgumentError("enum=$enum does not have value=$val"))
    end

    return ENUM_MAPPINGS[enum][val]
end

Base.convert(::Type{SystemCategorys.SystemCategory}, val::String) = get_enum_value(SystemCategorys.SystemCategory, val)
