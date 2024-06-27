function select_instance_by_ids(db::SQLite.DB, ids)
    query = """
    SELECT * FROM instance
    WHERE id IN ($(join(ids, ',')))
    """
    return execute_query(db, query; return_results=true)
end

function get_instance_data_path(db::SQLite.DB, name::AbstractString, scenario::AbstractString)
    query = "SELECT data_path FROM instance WHERE name='$name' AND scenario='$scenario'"
    result = execute_query(db, query, return_results=true) |> DataFrame
    return result[1, :data_path]
end

function is_instance_in_db(db::SQLite.DB, name::AbstractString, scenario::AbstractString="0")
    query = "SELECT * FROM instance WHERE name = '$name' AND scenario = '$scenario'"
    result = execute_query(db, query, return_results=true) |> DataFrame
    return nrow(result) > 0
end

function get_ids_instance_not_decomposed(db::SQLite.DB; decomposition_alg::OPFSDP.AbstractChordalExtension)
    println("DECOMPOSITION ALG: $(get_object_str(decomposition_alg))")
    query = """
            SELECT i.id FROM instance i
            WHERE NOT EXISTS (
                SELECT 1 FROM decomposition d
                WHERE i.name = d.name AND i.scenario = d.scenario
                AND d.decomposition_alg = '$(get_object_str(decomposition_alg))'
            )
            """
    results = execute_query(db, query; mpi=false) |> DataFrame
    return results[!, :id]
end

function get_ids_instance(db::SQLite.DB)
    query = "SELECT id FROM instance"
    results = execute_query(db, query; mpi=false) |> DataFrame
    return results[!, :id]
end

function get_ids_instance_no_features(db::SQLite.DB)
    query = "SELECT id FROM instance WHERE id NOT IN (SELECT instance_id FROM feature_instance)"
    results = execute_query(db, query; mpi=false) |> DataFrame
    return results[!, :id]
end
