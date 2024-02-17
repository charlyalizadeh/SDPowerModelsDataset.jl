function select_instance(db::SQLite.DB, name::AbstractString, scenario::AbstractString)
    query = "SELECT * FROM instance WHERE name='$name' AND scenario='$scenario'"
    return execute_query(db, query; mpi=false)
end

function select_instance_data_path(db::SQLite.DB, name::AbstractString, scenario::AbstractString)
    query = "SELECT data_path FROM instance WHERE name='$name' AND scenario='$scenario'"
    result = execute_query(db, query; mpi=false) |> DataFrame
    return result[1, :data_path]
end
