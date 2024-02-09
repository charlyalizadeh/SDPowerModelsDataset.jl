function execute_query(db, query)
    DBInterface.execute(db, query)
end

include("create_db.jl")
include("insert_instance.jl")
