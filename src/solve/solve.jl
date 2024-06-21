function solve_decomposition!(db::SQLite.DB, decomposition::DataFrameRow)
    println("Solving ($(decomposition[:name]), $(decomposition[:scenario]), $(decomposition[:id]), $(decomposition[:decomposition_alg]), $(decomposition[:last_process_type]))")
    path = get_decomposition_data_path(db, decomposition[:name], string(decomposition[:scenario]))
    network = OPFSDP.read_network(path)
    cliques_data_dict = load(decomposition[:cliques_path])
    maximal_cliques = cliques_data_dict["cliques"]
    cliquetree = nothing
    if decomposition[:decomposition_alg] == "OneClique"
        cliquetree = sparse(zeros(OPFSDP.nbus(network), OPFSDP.nbus(network)))
    else
        cliquetree = sparse(readdlm(decomposition[:cliquetree_path]))
    end
    model = OPFSDP.solve(network, maximal_cliques, cliquetree)
    result = Dict("status" => JuMP.termination_status(model),
                  "objective" => JuMP.objective_value(model),
                  "solve_time" => JuMP.solve_time(model))
    insert_solve!(db, decomposition, result, "Mosek")
end

function solve_decompositions!(db::SQLite.DB; resolve=false, subset=nothing)
	decompositions = select_decomposition_by_ids(db, subset) |> DataFrame
	solve_function!(row) = solve_decomposition!(db, row)
	solve_function!.(eachrow(decompositions))
end
