function select_decomposition_by_ids(db::SQLite.DB, ids)
    query = """
    SELECT * FROM decomposition
    WHERE id IN ($(join(ids, ',')))
    """
    return execute_query(db, query; return_results=true)
end

function select_decomposition_by_name_scenario(db::SQLite.DB, names, scenarios)
    names = map(x -> "'$x'", names)
    scenarios = map(x -> "'$x'", scenarios)
    query = """
    SELECT * FROM decomposition
    WHERE name IN ($(join(names, ','))) AND scenario IN ($(join(scenarios, ',')))
    """
    return execute_query(db, query; return_results=true)
end

function select_decomposition_all(db::SQLite.DB)
    query = "SELECT * FROM decomposition"
    return execute_query(db, query; return_results=true)
end

function get_ids_decomposition_not_merged(db; merge_alg::OPFSDP.AbstractMerge)
	query = """
	SELECT id FROM decomposition
    WHERE last_process_type = 'chordal extension'
    AND id NOT IN (
        SELECT m.id FROM merge m
        WHERE m.merge_alg ='$(get_object_str(merge_alg))'
    )
	"""
    results = execute_query(db, query; mpi=false) |> DataFrame
    return results[!, :id]
end

function get_ids_decomposition_not_combined(db::SQLite.DB)
    query = """
    SELECT t1.id AS id1, t2.id AS id2
    FROM decomposition t1, decomposition t2
    WHERE t1.id > t2.id AND t1.name = t2.name
    AND t1.last_process_type <> 'combine' AND t2.last_process_type <> 'combine'
    AND NOT EXISTS (
        SELECT in_id1, in_id2
        FROM combination
        WHERE (in_id1 = t1.id AND in_id2 = t2.id)
        OR (in_id1 = t2.id AND in_id2 = t1.id))
    AND EXISTS (SELECT decomposition_id FROM solve WHERE decomposition_id = t1.id)
    AND EXISTS (SELECT decomposition_id FROM solve WHERE decomposition_id = t2.id)
    AND (SELECT s1.time FROM solve s1 WHERE decomposition_id = t1.id) <= (
            SELECT s2.time FROM solve s2 LEFT JOIN decomposition d1 ON s2.decomposition_id = d1.id
            WHERE d1.name = t1.name AND d1.scenario = t1.scenario
            AND d1.decomposition_alg='(OPFSDP.CholeskyExtension|perm:nothing;shift:0.0)'
        )
    AND (SELECT s3.time FROM solve s3 WHERE s3.decomposition_id = t2.id) <= (
            SELECT s4.time FROM solve s4 LEFT JOIN decomposition d2 ON s4.decomposition_id = d2.id
            WHERE d2.name = t2.name AND d2.scenario = t2.scenario
            AND d2.decomposition_alg='(OPFSDP.CholeskyExtension|perm:nothing;shift:0.0)'
        )
    """
    results = execute_query(db, query; mpi=false) |> DataFrame
    ids = vcat([[id1, id2] for (id1, id2) in zip(results[!, :id1], results[!, :id2])]...)
    return ids
end

function get_ids_decomposition(db::SQLite.DB)
    results = execute_query(db, "SELECT id FROM decomposition"; mpi=false) |> DataFrame
    return results[!, :id]
end

function get_ids_decomposition_not_solved(db::SQLite.DB)
    query = """
    SELECT t1.id FROM decomposition t1 LEFT JOIN solve t2 ON t2.decomposition_id = t1.id WHERE t2.decomposition_id IS NULL AND t1.decomposition_alg <> 'OneClique'
    """
    results = execute_query(db, query; mpi=false) |> DataFrame
    return results[!, :id]
end

function get_ids_decomposition_no_features(db::SQLite.DB)
    query = "SELECT id FROM decomposition WHERE id NOT IN (SELECT decomposition_id FROM feature_decomposition)"
    results = execute_query(db, query; mpi=false) |> DataFrame
    return results[!, :id]
end

function get_decomposition_id(db::SQLite.DB, uuid::AbstractString)
	query = "SELECT id FROM decomposition WHERE uuid = '$uuid'"
	result = execute_query(db, query; return_results=true)
    isnothing(result) && return nothing
    result = result |> DataFrame
	return result[1, :id]
end

function get_decomposition_data_path(db::SQLite.DB, name::AbstractString, scenario::AbstractString)
	query = "SELECT data_path FROM instance WHERE name = '$name' AND scenario = '$scenario'"
    result = execute_query(db, query; return_results=true) |> DataFrame
    return result[1, :data_path]
end

