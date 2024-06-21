function generate_decomposition!(db::SQLite.DB, instance::DataFrameRow, decomposition_alg::OPFSDP.AbstractChordalExtension)
    println("Generating decomposition: ($(instance[:name]) $(instance[:scenario])) using $decomposition_alg")

    # Chordal extension
    adj = sparse(readdlm(instance[:adj_path], '\t', Float64, '\n'))
    cadj = OPFSDP.chordal_extension(adj, decomposition_alg)
    cliques = OPFSDP.maximal_cliques(cadj)
    cliquetree = OPFSDP.maximal_cliquetree(cliques)

    # Features extraction
    # TODO
    nb_added_edge = ne(cadj) - ne(adj)

    insert_decomposition!(db,
                          instance[:name], string(instance[:scenario]),
						  cadj,
						  cliques,
                          cliquetree,
						  nb_added_edge,
						  decomposition_alg,
						  "chordal extension")
end

function generate_decompositions!(db::SQLite.DB; decomposition_alg::OPFSDP.AbstractChordalExtension, subset=nothing)
	instances = select_instance_by_ids(db, subset) |> DataFrame
	generate_function!(row) = generate_decomposition!(db, row, decomposition_alg)
	generate_function!.(eachrow(instances))
end

function generate_decomposition_one_clique!(db::SQLite.DB, instance::DataFrameRow)
    println("Generating decomposition: ($(instance[:name]) $(instance[:scenario])) using one clique")

    # Chordal extension
    adj = sparse(readdlm(instance[:adj_path], '\t', Float64, '\n'))
    cliques = [collect(1:adj.n)]
    cliquetree = sparse(zeros(0, 0))

    # Features extraction
    # TODO
    nb_added_edge = trunc(Int, (adj.n * (adj.n - 1) / 2) - ne(adj))
    cadj = sparse(ones(adj.n, adj.n))

    insert_decomposition!(db,
						  instance[:name], instance[:scenario],
						  cadj,
						  cliques,
                          cliquetree,
						  nb_added_edge,
						  "OneClique",
						  "chordal extension")
end

function generate_decompositions_one_clique!(db::SQLite.DB)
	instances = select_instance_all(db) |> DataFrame
	generate_function!(row) = generate_decomposition_one_clique!(db, row)
	generate_function!.(eachrow(instances))
end
