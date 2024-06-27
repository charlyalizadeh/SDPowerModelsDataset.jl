function read_feature_instance!(db::SQLite.DB, instance::DataFrameRow)
    println("Reading feature of instance: ($(instance[:name]) $(instance[:scenario]))")

    adj = sparse(readdlm(instance[:adj_path], '\t', Float64, '\n'))
    g = Graphs.SimpleGraph(adj)
    features = get_features_graph(g)
    insert_feature_instance!(db, instance[:id], features)
end

function read_feature_instances!(db::SQLite.DB; subset=nothing)
	instances = select_instance_by_ids(db, subset) |> DataFrame
	read_feature_function!(row) = read_feature_instance!(db, row)
	read_feature_function!.(eachrow(instances))
end

function read_feature_decomposition!(db::SQLite.DB, decomposition::DataFrameRow)
    println("Reading feature of decomposition: ($(decomposition[:name]) $(decomposition[:scenario]) $(decomposition[:id]))")

    adj = sparse(readdlm(decomposition[:adj_path], '\t', Float64, '\n'))
    g = Graphs.SimpleGraph(adj)
    features = get_features_graph(g)

    cliques_data_dict = load(decomposition[:cliques_path])
    cliques = cliques_data_dict["cliques"]
    cliques_size = [length(c) for c in cliques]
    max, min, mean, median, var = get_population_stats(cliques_size)
    merge!(features,
           Dict("nclq" => length(cliques),
                "clqsize_max" => max,
                "clqsize_min" => min,
                "clqsize_mean" => mean,
                "clqsize_median" => median,
                "clqsize_var" => var))
    insert_feature_decomposition!(db, decomposition[:id], features)
end

function read_feature_decompositions!(db::SQLite.DB; subset=nothing)
	decompositions = select_decomposition_by_ids(db, subset) |> DataFrame
	read_feature_function!(row) = read_feature_decomposition!(db, row)
	read_feature_function!.(eachrow(decompositions))
end
