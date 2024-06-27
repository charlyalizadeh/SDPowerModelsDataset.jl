function get_population_stats(population)
    if length(population) > 1
        return maximum(population), minimum(population), mean(population), median(population), var(population)
    else
        val = population[1]
        return val, val, val, val, 0
    end
end

function get_features_graph(g::Graphs.SimpleGraph)
    degree_max, degree_min, degree_mean, degree_median, degree_var = get_population_stats(degree(g))
    features = Dict(
        "ne" => ne(g),
        "nv" => nv(g),
        "deg_max" => degree_max,
        "deg_min" => degree_min,
        "deg_mean" => degree_mean,
        "deg_median" => degree_median,
        "deg_var" => degree_var,
        "glc" => global_clustering_coefficient(g),
        "density" => density(g),
        "diameter" => diameter(g),
        "radius" => radius(g)
    )
    return features
end
