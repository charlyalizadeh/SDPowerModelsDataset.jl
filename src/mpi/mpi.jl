const process_functions = Dict(
    "generate_decompositions" => generate_decompositions!,
    "merge_decompositions" => merge_decompositions!,
    "combine_decompositions" => combine_decompositions!,
    "delete_duplicate_decompositions" => delete_duplicate_decompositions!,
    "solve_decompositions" => solve_decompositions!,
    "read_feature_instances" => read_feature_instances!,
    "read_feature_decompositions" => read_feature_decompositions!
)
const ids_functions = Dict(
    "generate_decompositions" => get_ids_instance_not_decomposed,
    "merge_decompositions" => get_ids_decomposition_not_merged,
    "combine_decompositions" => get_ids_decomposition_not_combined,
    "delete_duplicate_decompositions" => get_ids_instance,
    "solve_decompositions" => get_ids_decomposition_not_solved,
    "read_feature_instances" => get_ids_instance_no_features,
    "read_feature_decompositions" => get_ids_decomposition_no_features
)

function mpi_init()
    !MPI.Initialized() && MPI.Init()
    rank = MPI.Comm_rank(MPI.COMM_WORLD)
    size = MPI.Comm_size(MPI.COMM_WORLD)
    return MPI.COMM_WORLD, rank, size
end

function df_to_str(df)
    io = IOBuffer()
    CSV.write(io, df)
    return String(take!(io))
end

function get_query_part(query)
    query = replace(query, "[" => "")
    return split(query, "]")
end

function process_query(db::SQLite.DB, query, rank)
    query = String(query)
    println("[$rank] Recieved query: $query")
    flush(stderr)
    flush(stdout)
    if query == "over"
        println("Process $rank over.")
        return true
    elseif query == "Barrier"
        MPI.Barrier(MPI.COMM_WORLD)
    else
        query_parts = get_query_part(query)
        if query_parts[1] == "WAIT"
            DBInterface.execute(db, query_parts[2])
            MPI.send(['e', 'x', 'e', 'c', 'u', 't', 'e', 'd'], MPI.COMM_WORLD; dest=rank)
        elseif query_parts[1] == "SLEEP"
            time_to_sleep = parse(Float64, query_parts[2])
            DBInterface.execute(db, query_parts[3])
            sleep(time_to_sleep)
        elseif query_parts[1] == "RETURN"
            results = DBInterface.execute(db, query_parts[2]) |> DataFrame
            results_str = df_to_str(results)
            MPI.send([c for c in results_str], MPI.COMM_WORLD; dest=rank)
        else
            try
                DBInterface.execute(db, query_parts[1])
            catch e
                println(query_parts)
                rethrow()
            end
        end
    end
    return false
end

function assign_indexes_combine(db::SQLite.DB; kwargs...)
    size = MPI.Comm_size(MPI.COMM_WORLD)
    nb_process = size - 1
    ids = get_ids_decomposition_not_combined(db; kwargs...)
    println("---- $(Dates.now()) ----")
    println("Number of ids: $(length(ids))")
    if isempty(ids)
        println("Nothing to process.")
        for i in 1:nb_process
            println("Sending to $( 1): [-1]")
            MPI.send([-1], MPI.COMM_WORLD; dest=i)
        end
    elseif length(ids) / 2 <= nb_process
        nb_process_used = 1
        for i in 1:2:length(ids) - 1
            println("Sending to $(1): [$(ids[i])]")
            MPI.send([ids[i], ids[i + 1]], MPI.COMM_WORLD; dest=nb_process_used)
            nb_process_used += 1
        end
        for i in nb_process_used:nb_process
            println("Sending to $(1): [-1]")
            MPI.send([-1], MPI.COMM_WORLD; dest=i)
        end
    else
        nb_ids = trunc(Int, length(ids) / 2)
        nb_ids_per_chunk = trunc(Int, nb_ids / nb_process)
        start = 1
        stop = -1
        for i in 1:nb_process
            start = i == 1 ? start : stop + 1
            stop = (start + nb_ids_per_chunk) * 2
            stop = stop > length(ids) - 1 ? length(ids) : stop
            if i == nb_process && stop != length(ids)
                stop = length(ids)
            end
            chunk = ids[start:stop]
            println("Sending [$(start) -> $(stop)] to $(i):\n$chunk\n")
            if isempty(chunk)
                chunck = [-1]
            end
            MPI.send(chunk, MPI.COMM_WORLD; dest=i)
        end
    end
    flush(stderr)
    flush(stdout)
end

function assign_indexes(db::SQLite.DB, process::AbstractString; kwargs...)
    size = MPI.Comm_size(MPI.COMM_WORLD)
    nb_process = size - 1
    ids = ids_functions[process](db; kwargs...)
    println("---- $(Dates.now()) ----")
    println("Number of ids: $(length(ids))")
    if isempty(ids)
        println("Nothing to process.")
        for i in 1:nb_process
            println("Sending to $(i - 1): [-1]")
            MPI.send([-1], MPI.COMM_WORLD; dest=i)
        end
    elseif length(ids) <= nb_process
        for i in 1:length(ids)
            println("Sending to $(i - 1): [$(ids[i])]")
            MPI.send([ids[i]], MPI.COMM_WORLD; dest=i)
        end
        for i in length(ids)+1:nb_process
            println("Sending to $(i - 1): [-1]")
            MPI.send([-1], MPI.COMM_WORLD; dest=i)
        end
    else
        nb_ids_per_chunk = trunc(Int, length(ids) / nb_process)
        start = 1
        stop = -1
        for i in 1:nb_process
            start = i == 1 ? start : stop + 1
            stop = start + nb_ids_per_chunk
            stop = stop > length(ids) ? length(ids) : stop
            if i == nb_process && stop != length(ids)
                stop = length(ids)
            end
            chunk = ids[start:stop]
            println("Sending [$start -> $stop] to $(i):\n$chunk\n")
            if isempty(chunk)
                chunck = [-1]
            end
            MPI.send(chunk, MPI.COMM_WORLD; dest=i)
        end
    end
    flush(stderr)
    flush(stdout)
end

function listen_queries(db::SQLite.DB)
    size = MPI.Comm_size(MPI.COMM_WORLD)
    nb_process = size - 1
    process_done = zeros(Bool, nb_process)
    while !all(process_done)
        for i in 1:nb_process
            has_recieved, status = MPI.Iprobe(MPI.COMM_WORLD, MPI.Status; source=i)
            if has_recieved
                query, status = MPI.recv(MPI.COMM_WORLD, MPI.Status; source=i)
                process_done[i] = process_query(db, query, i)
            end
        end
    end
end

function execute_process_main(db::SQLite.DB, process::AbstractString; finalize=true, kwargs...)
    if process == "combine_decompositions"
        assign_indexes_combine(db; kwargs...)
    else
        assign_indexes(db, process; kwargs...)
    end
    listen_queries(db)
    MPI.Barrier(MPI.COMM_WORLD)
    finalize && MPI.Finalize()
end

function execute_process_secondary(db::SQLite.DB, process::String; finalize=true, kwargs...)
    indexes, status = MPI.recv(MPI.COMM_WORLD, MPI.Status; source=0)
    if indexes == [-1]
        println("Nothing to process. Exiting.")
        MPI.send(['o', 'v', 'e', 'r'], MPI.COMM_WORLD; dest=0)
        println("Finalize")
        MPI.Barrier(MPI.COMM_WORLD)
        finalize && MPI.Finalize()
        return
    end
    println("Recieved: $indexes")
    process_functions[process](db; subset=indexes, kwargs...)
    println("Process done.")
    MPI.send(['o', 'v', 'e', 'r'], MPI.COMM_WORLD; dest=0)
    println("Finalize.")
    MPI.Barrier(MPI.COMM_WORLD)
    finalize && MPI.Finalize()
end

function execute_process_mpi(db_path::AbstractString, process::AbstractString, log_dir::AbstractString; finalize=true, kwargs...)
    comm, rank, size = mpi_init()
    db = SQLite.DB(db_path)
    if rank == 0 && !check_db_initialized(db)
        db = create_pm_db(db_path)
        insert_instances!(db, readdir("data/matpower", join=true); nv_min=100, nv_max=500, exclude=["case_ACTIVSg200", "case118zh"])
    end
    MPI.Barrier(MPI.COMM_WORLD)
    log_dir = joinpath(log_dir, process)
    !isdir(log_dir) && mkpath(log_dir)
    #redirect_stdio(stdout=joinpath(log_dir, "$rank.txt"), stderr=joinpath(log_dir, "$rank.txt")) do
        println("Rank: $rank / $(size - 1)")
        if rank == 0
            execute_process_main(db, process; finalize=finalize, kwargs...)
        else
            execute_process_secondary(db, process; finalize=finalize, kwargs...)
        end
    #end
end

generate_decompositions_mpi!(db_path::AbstractString,
                             decomposition_alg::OPFSDP.AbstractChordalExtension,
                             log_dir::AbstractString=".logs/generate"; kwargs...
                            ) = execute_process_mpi(db_path, "generate_decompositions", log_dir; decomposition_alg=decomposition_alg, kwargs...)
merge_decompositions_mpi!(db_path::AbstractString,
                          merge_alg::OPFSDP.AbstractMerge,
                          log_dir::AbstractString=".logs/merge"; kwargs...
                         ) = execute_process_mpi(db_path, "merge_decompositions", log_dir; merge_alg=merge_alg, kwargs...)
solve_decompositions_mpi!(db_path::AbstractString,
                          log_dir::AbstractString=".logs/solve"; kwargs...
                         ) = execute_process_mpi(db_path, "solve_decompositions", log_dir; kwargs...)
combine_decompositions_mpi!(db_path::AbstractString,
                            log_dir::AbstractString=".logs/combine"; kwargs...
                           ) = execute_process_mpi(db_path, "combine_decompositions", log_dir; kwargs...)
delete_duplicate_decompositions_mpi!(db_path::AbstractString,
                                     log_dir::AbstractString=".logs/delete"; kwargs...
                                    ) = execute_process_mpi(db_path, "delete_duplicate_decompositions", log_dir; kwargs...)
read_feature_instances_mpi!(db_path::AbstractString,
                            log_dir::AbstractString=".logs/read_feature_instance"; kwargs...
                           ) = execute_process_mpi(db_path, "read_feature_instances", log_dir; kwargs...)
read_feature_decompositions_mpi!(db_path::AbstractString,
                                 log_dir::AbstractString=".logs/read_feature_instance"; kwargs...
                                ) = execute_process_mpi(db_path, "read_feature_decompositions", log_dir; kwargs...)
