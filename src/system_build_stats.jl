mutable struct SystemBuildStats <: PowerSystemCaseBuilderType
    count::Int
    initial_construct_time::Float64
    serialize_time::Float64
    min_deserialize_time::Float64
    max_deserialize_time::Float64
    total_deserialize_time::Float64
end

function SystemBuildStats(;
    count,
    initial_construct_time,
    serialize_time,
    min_deserialize_time,
    max_deserialize_time,
    total_deserialize_time,
)
    return SystemBuildStats(
        count,
        initial_construct_time,
        serialize_time,
        min_deserialize_time,
        max_deserialize_time,
        total_deserialize_time,
    )
end

function SystemBuildStats(initial_construct_time::Float64, serialize_time::Float64)
    return SystemBuildStats(1, initial_construct_time, serialize_time, 0.0, 0.0, 0.0)
end

function update_stats!(stats::SystemBuildStats, deserialize_time::Float64)
    stats.count += 1
    if stats.min_deserialize_time == 0 || deserialize_time < stats.min_deserialize_time
        stats.min_deserialize_time = deserialize_time
    end
    if deserialize_time > stats.max_deserialize_time
        stats.max_deserialize_time = deserialize_time
    end
    stats.total_deserialize_time += deserialize_time
end

avg_deserialize_time(stats::SystemBuildStats) = stats.total_deserialize_time / stats.count
