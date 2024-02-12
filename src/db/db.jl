function execute_query(db, query; mpi=true)
    DBInterface.execute(db, query)
end

include("create_db.jl")
include("insert/insert_instance.jl")
include("insert/insert_decomposition.jl")
