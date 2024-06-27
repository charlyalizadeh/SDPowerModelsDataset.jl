function get_object_str(object)
	name = string(typeof(object))
	object_fieldnames = sort(collect(map(string, fieldnames(typeof(object)))))
	key_val_str = join(["$f:$(getfield(object, Symbol(f)))" for f in object_fieldnames], ";")
    return "($(name)|$(key_val_str))"
end

function execute_query_mpi_return(db, query)
    query = "[RETURN]" * query
    query = [c for c in query]
    MPI.send(query, MPI.COMM_WORLD; dest=0)
    old_query = query
    while true
        has_recieved, status = MPI.Iprobe(MPI.COMM_WORLD, MPI.Status; source=0)
        if has_recieved
            query, status = MPI.recv(MPI.COMM_WORLD, MPI.Status; source=0)
            query = String(query)
            return DataFrame(CSV.File(IOBuffer(query)))
        end
    end
end

function execute_query_mpi_wait(db, query)
    query = "[WAIT]" * query
    query = [c for c in query]
    MPI.send(query, MPI.COMM_WORLD; dest=0)
    while true
        has_recieved, status = MPI.Iprobe(MPI.COMM_WORLD, MPI.Status; source=0)
        if has_recieved
            query, status = MPI.recv(MPI.COMM_WORLD, MPI.Status; source=0)
            query = String(query)
            if query == "executed"
                return
            end
        end
    end
end

function execute_query(db, query; mpi=true, wait_until_executed=false, time_to_sleep=0, return_results=false)
    # If we are not using MPI
    if !mpi || !MPI.Initialized()
        return DBInterface.execute(db, query)
    elseif return_results
        return execute_query_mpi_return(db, query)
    elseif wait_until_executed
        execute_query_mpi_wait(db, query)
    elseif time_to_sleep > 0
        query = "[SLEEP][$time_to_sleep]" * query
        query = [c for c in query]
        MPI.send(query, MPI.COMM_WORLD; dest=0)
    else
        query = [c for c in query]
        MPI.send(query, MPI.COMM_WORLD; dest=0)
    end
end

