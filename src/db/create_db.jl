function create_pm_table_instance(db::SQLite.DB)
    query = """
    CREATE TABLE IF NOT EXISTS instance(
        id INTEGER NOT NULL,
        name TEXT NOT NULL,
        scenario TEXT NOT NULL,
        source_type TEXT NOT NULL,
        date TEXT NOT NULL,
        data_path TEXT NOT NULL,
        adj_path TEXT NOT NULL,

        UNIQUE(name, scenario),
        PRIMARY KEY(id)
    )
    """
    DBInterface.execute(db, query)
end

function create_pm_table_decomposition(db::SQLite.DB)
    query = """
    CREATE TABLE IF NOT EXISTS decomposition(
        id INTEGER NOT NULL,
		uuid TEXT NOT NULL,
        name TEXT NOT NULL,
        scenario TEXT NOT NULL,
        adj_path TEXT NOT NULL,
        cliques_path TEXT NON NULL,
        cliquetree_path TEXT NON NULL,
        nb_added_edge INTEGER NOT NULL,
        decomposition_alg TEXT NOT NULL,
        date TEXT NOT NULL,
		last_process_type TEXT NOT NULL,

        PRIMARY KEY(id),
        FOREIGN KEY(name, scenario) REFERENCES instance(name, scenario) ON DELETE CASCADE
    )
    """
    DBInterface.execute(db, query)
end

function create_pm_table_merge(db::SQLite.DB)
    query = """
    CREATE TABLE IF NOT EXISTS merge(
        id INTEGER NOT NULL,
        src_id INTEGER NOT NULL,
		dst_id INTEGER NOT NULL,
		merge_alg TEXT NOT NULL,

        PRIMARY KEY(id),
        FOREIGN KEY(src_id) REFERENCES decomposition(id),
        FOREIGN KEY(dst_id) REFERENCES decomposition(id) ON DELETE CASCADE
    )
    """
    DBInterface.execute(db, query)
end

function create_pm_table_solve(db::SQLite.DB)
    query = """
    CREATE TABLE IF NOT EXISTS solve(
        id INTEGER NOT NULL,
        decomposition_id INTEGER NOT NULL,
        time REAL NOT NULL,
        solver TEXT NOT NULL,
        date TEXT NOT NULL,
        objective REAL,
        data_path TEXT NOT NULL,
        log_path TEXT NOT NULL,

        PRIMARY KEY(id),
        FOREIGN KEY(decomposition_id) REFERENCES decomposition(id) ON DELETE CASCADE
    )
    """
    DBInterface.execute(db, query)
end

function create_pm_table_combination(db::SQLite.DB)
    query = """
    CREATE TABLE IF NOT EXISTS combination(
        id INTEGER NOT NULL,
        in_id1 INTEGER NOT NULL,
        in_id2 INTEGER NOT NULL,
        out_id INTEGER NOT NULL,

        PRIMARY KEY(id),
        FOREIGN KEY(in_id1) REFERENCES decomposition(id),
        FOREIGN KEY(in_id2) REFERENCES decomposition(id),
        FOREIGN KEY(out_id) REFERENCES decomposition(id),
        UNIQUE(in_id1, in_id2, out_id)
    )
    """
    DBInterface.execute(db, query)
end

function create_pm_table_feature_instance(db::SQLite.DB)
    query = """
    CREATE TABLE IF NOT EXISTS feature_instance(
        id INTEGER NOT NULL,
        instance_id INTEGER NOT NULL,

        nv INTEGER NOT NULL,
        ne INTEGER NOT NULL,
        deg_max INTEGER NOT NULL,
        deg_min INTEGER NOT NULL,
        deg_mean INTEGER NOT NULL,
        deg_median INTEGER NOT NULL,
        deg_var INTEGER NOT NULL,
        glc REAL NOT NULL,
        density REAL NOT NULL,
        diameter INTEGER NOT NULL,
        radius INTEGER NOT NULL,

        PRIMARY KEY(id),
        FOREIGN KEY(instance_id) REFERENCES instance(id),
        UNIQUE(instance_id)
    )
    """
    DBInterface.execute(db, query)
end

function create_pm_table_feature_decomposition(db::SQLite.DB)
    query = """
    CREATE TABLE IF NOT EXISTS feature_decomposition(
        id INTEGER NOT NULL,
        decomposition_id INTEGER NOT NULL,

        nv INTEGER NOT NULL,
        ne INTEGER NOT NULL,
        deg_max INTEGER NOT NULL,
        deg_min INTEGER NOT NULL,
        deg_mean INTEGER NOT NULL,
        deg_median INTEGER NOT NULL,
        deg_var INTEGER NOT NULL,
        glc REAL NOT NULL,
        density REAL NOT NULL,
        diameter INTEGER NOT NULL,
        radius INTEGER NOT NULL,
        nclq INTEGER NOT NULL,
        clqsize_max INTEGER NOT NULL,
        clqsize_min INTEGER NOT NULL,
        clqsize_mean INTEGER NOT NULL,
        clqsize_median INTEGER NOT NULL,
        clqsize_var INTEGER NOT NULL,


        PRIMARY KEY(id),
        FOREIGN KEY(decomposition_id) REFERENCES decomposition(id),
        UNIQUE(decomposition_id)
    )
    """
    DBInterface.execute(db, query)
end


function create_pm_tables(db::SQLite.DB)
    create_pm_table_instance(db)
    create_pm_table_decomposition(db)
    create_pm_table_merge(db)
    create_pm_table_solve(db)
    create_pm_table_combination(db)
    create_pm_table_feature_instance(db)
    create_pm_table_feature_decomposition(db)
end

function create_pm_db(path::AbstractString="opfsdp.sqlite"; delete_if_exists=false)
    db = SQLite.DB(path)
    if delete_if_exists
        delete_table(db, table) = DBInterface.execute(db, "DROP TABLE IF EXISTS $table")
        delete_table(db, "instance")
        delete_table(db, "decomposition")
        delete_table(db, "merge")
        delete_table(db, "solve")
        delete_table(db, "combination")
        delete_table(db, "feature_instance")
        delete_table(db, "feature_decomposition")
    end
    create_pm_tables(db)
    return db
end
