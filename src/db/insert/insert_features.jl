function insert_feature_instance!(db::SQLite.DB, id, features::Dict)
    features_name = sort(collect(keys(features)))
    query = """
    INSERT INTO feature_instance(instance_id, $(join(features_name, ',')))
    VALUES($id, $(join([features[f] for f in features_name], ',')))
    """
    execute_query(db, query)
end

function insert_feature_decomposition!(db::SQLite.DB, id, features::Dict)
    features_name = sort(collect(keys(features)))
    query = """
    INSERT INTO feature_decomposition(decomposition_id, $(join(features_name, ',')))
    VALUES($id, $(join([features[f] for f in features_name], ',')))
    """
    execute_query(db, query)
end
