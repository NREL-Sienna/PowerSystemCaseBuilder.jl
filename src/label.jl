function make_system_label(has_forecasts::Bool=true, has_reserves::Bool=false)
    _forecast = has_forecasts ? "forecast" : ""
    _reserve = has_reserves ? "reserve" : ""
    return "has_$(_forecast)_$(_reserve)"
end
