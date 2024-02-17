function insert_decomposition!(db::SQLite.DB,
                               name::AbstractString, scenario::AbstractString,
                               adj_path::AbstractString,
                               lookup_index_path::AbstractString, perm_path::AbstractString, cliques_path::AbstractString,
                               nb_added_edge::Int,
                               decomposition_alg::AbstractString, date::AbstractString,
                               merge_alg::Union{AbstractString, Nothing})
    if isnothing(merge_alg)
        insert_query_addon =  ""
        value_query_addon = ""
    else
        insert_query_addon = ", merge_alg"
        value_query_addon = ", '$(merge_alg)'"
    end
    query = """
    INSERT INTO decomposition(name, scenario, adj_path, lookup_index_path, perm_path, cliques_path, nb_added_edge, decomposition_alg, date$(insert_query_addon))
    VALUES('$name', '$scenario', '$adj_path', '$lookup_index_path', '$perm_path', '$cliques_path', $nb_added_edge, '$decomposition_alg', '$date'$(value_query_addon))
    """
    execute_query(db, query)
end


function insert_decomposition!(db::SQLite.DB,
                               name::AbstractString, scenario::AbstractString,
                               adj::SparseMatrixCSC,
                               lookup_index_path::AbstractString, perm::Vector{Int}, cliques::Vector{Vector{Int}},
                               nb_added_edge::Int,
                               decomposition_alg::AbstractString,
                               merge_alg::Union{AbstractString, Nothing}=nothing)
    uuid = uuid1(MersenneTwister(42))
    date = Dates.format(Dates.now(), "dd-mm-yyy HH:MM:SS:sss")

    adj_path = joinpath(config["adj_path"]["decomposition"], "$(name)_$(scenario)_$(uuid)_cadj.txt")
    perm_path = joinpath(config["adj_path"]["decomposition"], "$(name)_$(scenario)_$(uuid)_perm.txt")
    cliques_path = joinpath(config["adj_path"]["decomposition"], "$(name)_$(scenario)_$(uuid)_cliques.txt")

    writedlm(adj_path, adj)
    writedlm(perm_path, perm)
    writedlm(cliques_path, cliques)

    insert_decomposition!(db, name, scenario, adj_path, lookup_index_path, perm_path, cliques_path, nb_added_edge, decomposition_alg, date, merge_alg)
end


function insert_solve!(db::SQLite.DB,
                       dec_id::Int, time::Float64, solver::AbstractString,
                       date::AbstractString, objective::Float64, data_path::AbstractString,
                       log_path::AbstractString)

    query = """
    INSERT INTO solve(dec_id, time, solver, date, objective, data_path, log_path)
    VALUES($dec_id, $time, '$solver', '$date', $objective, '$data_path', '$log_path')
    """
    execute_query(db, query)
end


function insert_solve!(db::SQLite.DB, decomposition, result, solver::AbstractString)
    date = Dates.format(Dates.now(), "dd-mm-yyy HH:MM:SS:sss")
    insert_solve!(db, decomposition["id"], result["solve_time"], solver, date, result["objective"], "", "")
end
