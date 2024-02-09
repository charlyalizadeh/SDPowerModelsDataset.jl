function execute_query(db, query)
    DBInterface.execute(db, query)
end

include("create_db.jl")
include("add_instance.jl")
