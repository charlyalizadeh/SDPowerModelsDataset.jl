function arg_to(lines, pattern)
    i = 1
    while !occursin(pattern, lines[i])
        i += 1
    end
    return i
end

function nv_matrix(adj::SparseMatrixCSC)
    return adj.n
end

function ne_matrix(adj::SparseMatrixCSC)
    nedges = 0
    for i in 1:adj.n-1
        for j in i+1:adj.n
            nedges += (adj[i, j] != 0)
        end
    end
    return nedges
end

function nv_file(path::AbstractString)
    extension = split(path, '.')[end]
    if extension == "m"
        return nv_matpower_file(path)
    elseif extension == "raw"
        return nv_raw_file(path)
    end
end

function nv_matpower_file(path::AbstractString)
    lines = split(read(open(path, "r"), String), '\n')
    nv = 0
    i = arg_to(lines, "mpc.bus")
    while !occursin("];", lines[i])
        i += 1
        nv += 1
    end
    return nv - 1
end

function nv_raw_file(path::AbstractString)
    lines = split(read(open(path, "r"), String), '\n')
    i = 4
    while !occursin("END OF BUS DATA BEGIN LOAD DATA", lines[i])
        i += 1
    end
    return i - 4
end
