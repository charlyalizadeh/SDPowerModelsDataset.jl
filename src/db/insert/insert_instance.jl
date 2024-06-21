function _extract_scenario_rawgo(path::AbstractString)
	dirs = splitpath(path)
	scenario_dir = dirs[findfirst(x -> occursin("scenario", x), dirs)]
    scenario = parse(Int, split(scenario_dir, '_')[end])
    return string(scenario)
end

function _extract_name_rawgo(path::AbstractString)
	dirs = splitpath(path)
	name = dirs[findfirst(x -> occursin("scenario", x), dirs) - 1]
	return name
end

function _extract_name_matpower(path::AbstractString)
    filename, ext = splitext(basename(path))
    return filename
end

function _get_network_name(path)
    filename, ext = splitext(path)
    if ext == ".m"
        return _extract_name_matpower(path)
    elseif ext == ".raw"
        return _extract_name_rawgo(path)
    end
end

function _check_matpower_scenario(path::AbstractString)
	data = read(open(path, "r"), String)
	return occursin("function chgtab", data)
end

function _get_source_type(path::AbstractString)
    filename, ext = splitext(path)
    if ext == ".m"
        return "MATPOWER"
    elseif ext == ".raw"
        return "RAW"
    end
end


function insert_instance!(db::SQLite.DB,
                          name::AbstractString, scenario::AbstractString, source_type::AbstractString,
                          date::AbstractString,
                          data_path::AbstractString, adj_path::AbstractString,
                          nb_vertex::Integer, nb_edge::Integer)
    query = """
    INSERT INTO instance(name, scenario, source_type, date, data_path, adj_path, nb_vertex, nb_edge)
    VALUES('$name', '$scenario', '$source_type', '$date', '$data_path', '$adj_path', $nb_vertex, $nb_edge)
    """
    try
        execute_query(db, query; mpi=false)
    catch e
        if isa(e, SQLiteException) && e.msg == "UNIQUE constraint failed: instance.name, instance.scenario"
            println("Instance $(name) $(scenario) already in the database.")
        end
    end
end

function insert_instance!(db::SQLite.DB, path::AbstractString, name::Union{AbstractString, Nothing} = nothing, scenario::AbstractString = "0", exclude = [])
    name = _get_network_name(path)
    if name in exclude
        println("Instance $(name) $(scenario) in exclude list")
        return
    end
    if is_instance_in_db(db, name, scenario)
        println("Instance $(name) $(scenario) already in the database")
        return
    end
    date = Dates.format(Dates.now(), "dd-mm-yyy HH:MM:SS:sss")
    network = OPFSDP.read_network(path)
    adj = OPFSDP.adjacency_matrix(network)
    adj_path = joinpath(config["adj_path"]["instance"], "$(network.name)_$(scenario)_adj.txt")
    writedlm(adj_path, adj)
    source_type = _get_source_type(path)
    insert_instance!(db, name, scenario, source_type, date, path, adj_path, nv(adj), ne(adj))
end

function insert_instances!(db::SQLite.DB, paths::Vector{<:AbstractString};
						   extract_name::Union{Function, Nothing} = nothing, extract_scenario::Union{Function, Nothing} = nothing,
                           nv_min::Number = -Inf, nv_max::Number = Inf, exclude=[])
    for path in paths
        println("Loading $(path)")
		if _check_matpower_scenario(path)
			println("Not loading $(path), not a matpower case file.")
			continue
		end
		nv_path = nv(path)
		if nv_path < nv_min || nv_path > nv_max
			println("Not loading $(path), this instance doesn't meet the requirement for the number of nodes ($(nv_min) <= nv <= $(nv_max) got $(nv_path))")
			continue
		end
		name = isnothing(extract_name) ? nothing : extract_name(path)
        scenario = isnothing(extract_scenario) ? "0" : extract_scenario(path)
        insert_instance!(db, path, name, scenario, exclude)
    end
end
