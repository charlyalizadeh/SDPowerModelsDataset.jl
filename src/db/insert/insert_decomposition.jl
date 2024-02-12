function insert_decomposition!(db::SQLite.DB,
                               name::AbstractString, scenario::AbstractString,
                               dot_path::AbstractString, nb_added_edge::Integer,
                               decomposition_alg::AbstractString, date::AbstractString,
                               process_path::AbstractString, merge_alg::Union{AbstractString, Nothing})
    if isnothing(merge_alg)
        insert_query_addon =  ""
        value_query_addon = ""
    else
        insert_query_addon = ", merge_alg"
        value_query_addon = ", '$(merge_alg)'"
    end
    query = """
    INSERT INTO decomposition(name, scenario, dot_path, nb_added_edge, decomposition_alg, date, process_path$(insert_query_addon))
    VALUES ('$name', '$scenario', '$dot_path', $nb_added_edge, '$decomposition_agl', $date, '$process_path'$(value_query_addon))
    """
    execute_query(db, query)
end
