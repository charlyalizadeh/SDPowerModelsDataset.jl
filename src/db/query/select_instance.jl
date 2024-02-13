function select_instance(name::AbstractString, scenario::AbstractString)
    query = "SELECT * FROM instance WHERE name='$name' AND scenario='$scenario'"
    return execute_query(query; mpi=false)
end
