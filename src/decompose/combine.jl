function combine_decomposition!(db::SQLite.DB, decomposition1::DataFrameRow, decomposition2::DataFrameRow)
    println("Combining decomposition: ($(decomposition1[:name]), $(decomposition1[:scenario]), $(decomposition1[:id])) ($(decomposition2[:name]), $(decomposition2[:scenario]), $(decomposition2[:id]))")
	adj1 = sparse(readdlm(decomposition1[:adj_path], '\t', Float64, '\n'))
	adj2 = sparse(readdlm(decomposition2[:adj_path], '\t', Float64, '\n'))

	combine_adj = OPFSDP.combine(adj1, adj2)
    cadj = OPFSDP.chordal_extension(combine_adj, OPFSDP.CholeskyExtension())
    cliques = OPFSDP.maximal_cliques(cadj)
    cliquetree = OPFSDP.maximal_cliquetree(cliques)

    nb_added_edge = decomposition1[:nb_added_edge] + (ne_matrix(cadj) - ne_matrix(adj1))

    uuid = insert_decomposition!(db,
                                 decomposition1[:name], string(decomposition1[:scenario]),
						         cadj,
						         cliques,
                                 cliquetree,
						         nb_added_edge,
                                 OPFSDP.CholeskyExtension(),
						         "combine")
	out_id = get_decomposition_id(db, uuid)
    insert_combine!(db, decomposition1[:id], decomposition2[:id], out_id)
end


function combine_decompositions!(db::SQLite.DB; subset=nothing)
	decompositions = select_decomposition_by_ids(db, subset) |> DataFrame
    for i in 1:2:length(subset)
        combine_decomposition!(db,
                               decompositions[decompositions.id .== subset[i], :][1, :],
                               decompositions[decompositions.id .== subset[i + 1], :][1, :])
    end
end
