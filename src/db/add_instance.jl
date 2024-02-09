function add_instance(db::SQLite.DB,
                      name::String, scenario::String, source::String,
                      date::String,
                      data_path::String, dot_path::String,
                      nb_vertex::Int, nb_edge::Int)
    query = """
    INSERT INTO instance(name, scenario, source, date, data_path, dot_path, nb_vertex, nb_edge)
    VALUES('$name', '$scenario', '$source', '$date', '$data_path', '$dot_path', $nb_vertex, $nb_edge)
    """
    execute_query(db, query)
end

function add_instance(db::SQLite.DB, path::String, scenario::String, source::String)
    data = PowerModels.parse_file(path)
    date = Dates.now()
    adj, lookup_index = PowerModels._adjacency_matrix()
    perm = [findfirst(==i, lookup_index) for i in 1:length(data["bus"])]
    adj = adj[perm, perm]
    graph = SimpleGraph(adj)
    dot_path = "data/graph/instance/$(data["name"])_$(scenario).dot"
    _export(dot_path, graph)
    add_instance(db, data["name"], scenario, source, date, path, dot_path, nv(graph), ne(graph))
end
