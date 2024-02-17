function select_decomposition_all(db::SQLite.DB)
    return execute_query(db, "SELECT * FROM decomposition")
end

function select_decomposition_by(db::SQLite.DB, by, val)
    query = "SELECT * FROM decomposition WHERE $by = $val"
    return execute_query(db, query; mpi=false)
end
