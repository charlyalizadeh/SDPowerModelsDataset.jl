function _insert_decomposition!(db::SQLite.DB,
							   uuid::AbstractString,
                               name::AbstractString, scenario::AbstractString,
                               adj_path::AbstractString,
                               cliques_path::AbstractString,
                               cliquetree_path::AbstractString,
                               nb_added_edge::Int,
                               decomposition_alg::Union{OPFSDP.AbstractChordalExtension, AbstractString}, date::AbstractString,
							   last_process_type::AbstractString; time_to_sleep=0)
    decomposition_alg = typeof(decomposition_alg) == String ? decomposition_alg : get_object_str(decomposition_alg)
    query = """
    INSERT INTO decomposition(uuid, name, scenario, adj_path, cliques_path, cliquetree_path, nb_added_edge, decomposition_alg, date, last_process_type)
    VALUES('$uuid', '$name', '$scenario', '$adj_path', '$cliques_path', '$cliquetree_path', $nb_added_edge, '$(decomposition_alg)', '$date', '$last_process_type')
    """
    execute_query(db, query; time_to_sleep=time_to_sleep)
	return uuid
end


function insert_decomposition!(db::SQLite.DB,
                               name::AbstractString, scenario::AbstractString,
                               adj::SparseMatrixCSC,
                               cliques::Vector{Vector{Int}},
                               cliquetree::SparseMatrixCSC,
                               nb_added_edge::Int,
                               decomposition_alg::Union{OPFSDP.AbstractChordalExtension, AbstractString},
							   last_process_type::AbstractString; time_to_sleep=0)
	uuid = string(uuid1(MersenneTwister(42)))
    date = Dates.format(Dates.now(), "dd-mm-yyy HH:MM:SS:sss")

    adj_path = joinpath(config["adj_path"]["decomposition"], "$(name)_$(scenario)_$(uuid)_adj.txt")
    cliquetree_path = joinpath(config["adj_path"]["decomposition"], "$(name)_$(scenario)_$(uuid)_cliquetree.txt")
    cliques_path = joinpath(config["adj_path"]["decomposition"], "$(name)_$(scenario)_$(uuid)_cliques.jld2")

    writedlm(adj_path, adj)
    writedlm(cliquetree_path, cliquetree)
    jldsave(cliques_path; cliques)

    _insert_decomposition!(db, uuid, name, scenario, adj_path, cliques_path, cliquetree_path, nb_added_edge, decomposition_alg, date, last_process_type; time_to_sleep=time_to_sleep)
	return uuid
end


function insert_solve!(db::SQLite.DB,
                       decomposition_id::Int, time::Float64, solver::AbstractString,
                       date::AbstractString, objective::Float64, data_path::AbstractString,
                       log_path::AbstractString)

    query = """
    INSERT INTO solve(decomposition_id, time, solver, date, objective, data_path, log_path)
    VALUES($decomposition_id, $time, '$solver', '$date', $objective, '$data_path', '$log_path')
    """
    execute_query(db, query)
end


function insert_solve!(db::SQLite.DB, decomposition, result, solver::AbstractString)
    date = Dates.format(Dates.now(), "dd-mm-yyy HH:MM:SS:sss")
    insert_solve!(db, decomposition["id"], result["solve_time"], solver, date, result["objective"], "", "")
end
