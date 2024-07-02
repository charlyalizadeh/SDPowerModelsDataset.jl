function check_has_table(db::SQLite.DB, table)
    query = "SELECT name FROM sqlite_master WHERE type='table' AND name='$table';"
    results = execute_query(db, query; mpi=false) |> DataFrame
    return nrow(results) != 0
end

function check_db_initialized(db::SQLite.DB)
    # TODO: Check each table
    return check_has_table(db, "instance")
end

function get_decomposition_cholesky_time(db::SQLite.DB, name::AbstractString, scenario::AbstractString)
    query = """
    SELECT time FROM solve
    WHERE decomposition_id = (
        SELECT id FROM decomposition
        WHERE name = '$name' AND scenario = '$scenario'
        AND decomposition_alg = '(OPFSDP.CholeskyExtension|perm:nothing;shift:0.0)'
    )
    """
    results = execute_query(db, query; mpi=false) |> DataFrame
    if nrow(results) == 0
        return -1
    end
    return results[1, :time]
end
