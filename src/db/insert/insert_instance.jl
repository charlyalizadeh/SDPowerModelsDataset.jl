function insert_instance!(db::SQLite.DB,
                          name::AbstractString, scenario::AbstractString, source_type::AbstractString,
                          date::AbstractString,
                          data_path::AbstractString, dot_path::AbstractString,
                          nb_vertex::Integer, nb_edge::Integer)
    query = """
    INSERT INTO instance(name, scenario, source_type, date, data_path, dot_path, nb_vertex, nb_edge)
    VALUES('$name', '$scenario', '$source_type', '$date', '$data_path', '$dot_path', $nb_vertex, $nb_edge)
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
    perm = [findfirst(li -> li == i, lookup_index) for i in 1:length(data["bus"])]
    adj = adj[perm, perm]
    graph = SimpleGraph(adj)
    dot_path = "$(config["data_path"])graph/instance/$(data["name"])_$(scenario).dot"
    _export_graph(graph, dot_path)
    insert_instance!(db, data["name"], scenario, data["source_type"], date, path, dot_path, nv(graph), ne(graph))
end

function insert_instances!(db::SQLite.DB, paths::Vector{<:AbstractString},
                           extract_scenario::Union{Function, Nothing} = nothing)
    for path in paths
        scenario = isnothing(extract_scenario) ? "0" : extract_scenario(path)
        insert_instance!(db, p, scenario)
    end
end
