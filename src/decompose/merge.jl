function merge_decomposition!(db::SQLite.DB, decomposition::DataFrameRow, merge_alg::OPFSDP.AbstractMerge)
    println("Merging decomposition: ($(decomposition[:name]), $(decomposition[:scenario]), $(decomposition[:id])) using $(merge_alg)")
	adj = sparse(readdlm(decomposition[:adj_path], '\t', Float64, '\n'))
	ne_before_merge = ne_matrix(adj)
    cliques_data_dict = load(decomposition[:cliques_path])
	cliques = cliques_data_dict["cliques"]
    cliquetree = sparse(readdlm(decomposition[:cliquetree_path]))
	n_clique_before = length(cliques)

	OPFSDP.merge_cliques!(adj, cliques, cliquetree, merge_alg)
    cliquetree = OPFSDP.maximal_cliquetree(cliques)

	nb_added_edge = decomposition[:nb_added_edge] + (ne_matrix(adj) - ne_before_merge)

    uuid = insert_decomposition!(db,
                                 decomposition[:name], string(decomposition[:scenario]),
						         adj,
						         cliques,
                                 cliquetree,
						         nb_added_edge,
						         decomposition[:decomposition_alg],
						         "merge")
	dst_id = get_decomposition_id(db, uuid)
    #dst_id = nothing
    #while isnothing(dst_id)
	#    dst_id = get_decomposition_id(db, uuid)
    #end
    insert_merge!(db, decomposition[:id], dst_id, merge_alg)
end

function merge_decompositions!(db::SQLite.DB; merge_alg::OPFSDP.AbstractMerge, subset=nothing)
	decompositions = select_decomposition_by_ids(db, subset) |> DataFrame
	merge_func!(row) = merge_decomposition!(db, row, merge_alg)
	merge_func!.(eachrow(decompositions))
end
