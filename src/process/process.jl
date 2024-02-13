using Random


function add_random_edges!(graph::AbstractGraph, nedge::Int; rng=default_rng())
    nb_added_edge = 0
    added_edges = []

    for e in shuffle(edges(complement(graph)))
        add_edge!(g, e)
        push!(added_edges, e)
        nb_added_edge += 1
        if nb_added_edge == nedge
            break
        end
    end
    return (nb_added_edge, added_edges)
end


function add_random_edges!(graph::AbstractGraph, nedge::Float64)
    nedge_int = trunc(Int, nedge * ne(graph))
    add_random_edges!(graph, nedge_int)
end


# TODO: More performant way of doing that, maybe using the adjacency matrix
function add_random_edges_max_dist!(graph::AbstractGraph, nedge::Int; max_dist=5)
    nb_added_edge = 0
    added_edges = []

    for e in shuffle(edges)
        if length(a_star(src(e), dst(e))) <= max_dist
            add_edge!(graph, e)
            push!(added_edges, e)
            nb_added_edge += 1
        end
        if nb_added_edge == nedge
            break
        end
    end
    return (nb_added_edge, added_edges)
end


function add_random_edges_max_dist!(graph::AbstractGraph, nedge::Float64; max_dist=5)
    nedge_int = trunc(Int, nedge * ne(graph))
    add_random_edges_min_dist!(graph, nedge_int; max_dist=max_dist)
end
