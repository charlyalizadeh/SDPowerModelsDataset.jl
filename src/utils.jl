function keys_to_int(dict::Dict{String,<:Any})
    return Dict(parse(Int, k) => v for (k, v) in dict)
end

function keys_to_string(dict::Dict{Int,<:Any})
    return Dict(string(k) => v for (k, v) in dict)
end
