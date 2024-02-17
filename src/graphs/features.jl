function nv(adj::SparseMatrixCSC)
    return adj.n
end

function ne(adj::SparseMatrixCSC)
    nedges = 0
    for i in 1:adj.n-1
        for j in i+1:adj.n
            nedges += (adj[i, j] != 0)
        end
    end
    return nedges
end
