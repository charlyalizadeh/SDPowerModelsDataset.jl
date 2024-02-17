function generate_decomposition!(db::SQLite.DB, instance::DataFrameRow, decomposition_alg::PowerModels.AbstractChordalExtension)
    println("Generating decomposition: ($(instance[:name]) $(instance[:scenario])) ($decomposition_alg)")

    # Chordal extensoin
    adj = sparse(readdlm(instance[:adj_path], '\t', Float64, '\n'))
    lookup_index = keys_to_int(load(instance[:lookup_index_path]))
    cadj, perm = PowerModels._chordal_extension(adj, decomposition_alg)

    cliques = PowerModels._maximal_cliques(cadj)
    lookup_bus_index = Dict((reverse(p) for p = pairs(lookup_index)))
    groups = [[lookup_bus_index[gi] for gi in g] for g in cliques]

    # Features extraction
    # TODO
    nb_added_edge = ne(cadj) - ne(adj)

    insert_decomposition!(db, instance[:name], instance[:scenario], cadj, instance[:lookup_index_path], perm, groups, nb_added_edge, string(typeof(decomposition_alg)))
end
