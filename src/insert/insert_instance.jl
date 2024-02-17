function insert_instance!(db::SQLite.DB,
                          name::AbstractString, scenario::AbstractString, source_type::AbstractString,
                          date::AbstractString,
                          data_path::AbstractString, adj_path::AbstractString, lookup_index_path::AbstractString,
                          nb_vertex::Integer, nb_edge::Integer)
    query = """
    INSERT INTO instance(name, scenario, source_type, date, data_path, adj_path, lookup_index_path, nb_vertex, nb_edge)
    VALUES('$name', '$scenario', '$source_type', '$date', '$data_path', '$adj_path', '$lookup_index_path', $nb_vertex, $nb_edge)
    """
    execute_query(db, query)
end

function insert_instance!(db::SQLite.DB, path::AbstractString, scenario::AbstractString = "0")
    data = PowerModels.parse_file(path)
    date = Dates.format(Dates.now(), "dd-mm-yyy HH:MM:SS:sss")
    pm = PowerModels.instantiate_model(data,
                                       PowerModels.SparseSDPWRMPowerModel,
                                       PowerModels.build_opf)
    adj, lookup_index = PowerModels._adjacency_matrix(pm)
    adj_path = joinpath(config["adj_path"]["instance"], "$(data["name"])_$(scenario)_adj.txt")
    lookup_index_path = joinpath(config["adj_path"]["instance"], "$(data["name"])_$(scenario)_lookup_index.jld2")
    writedlm(adj_path, adj)
    save(lookup_index_path, keys_to_string(lookup_index))
    insert_instance!(db, data["name"], scenario, data["source_type"], date, path, adj_path, lookup_index_path, nv(adj), ne(adj))
end

function insert_instances!(db::SQLite.DB, paths::Vector{<:AbstractString},
                           extract_scenario::Union{Function, Nothing} = nothing)
    for path in paths
        scenario = isnothing(extract_scenario) ? "0" : extract_scenario(path)
        insert_instance!(db, p, scenario)
    end
end
