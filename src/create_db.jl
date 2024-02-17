using SQLite

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
        lookup_index_path TEXT NOT NULL,
        nb_vertex INTEGER NOT NULL,
        nb_edge INTEGER NOT NULL,

        UNIQUE(name, scenario),
        PRIMARY KEY(id)
    )
    """
    SQLite.execute(db, query)
end

function create_pm_table_decomposition(db::SQLite.DB)
    query = """
    CREATE TABLE IF NOT EXISTS decomposition(
        id INTEGER NOT NULL,
        name TEXT NOT NULL,
        scenario TEXT NOT NULL,
        adj_path TEXT NOT NULL,
        lookup_index_path TEXT NOT NULL,
        perm_path TEXT NOT NULL,
        cliques_path TEXT NON NULL,
        nb_added_edge INTEGER NOT NULL,
        decomposition_alg TEXT NOT NULL,
        date TEXT NOT NULL,

        merge_alg TEXT,

        PRIMARY KEY(id),
        FOREIGN KEY(name, scenario) REFERENCES instance(name, scenario),
        FOREIGN KEY(lookup_index_path) REFERENCES instance(lookup_index_path)
    )
    """
    SQLite.execute(db, query)
end

function create_pm_table_solve(db::SQLite.DB)
    query = """
    CREATE TABLE IF NOT EXISTS solve(
        id INTEGER NOT NULL,
        dec_id INTEGER NOT NULL,
        time REAL NOT NULL,
        solver TEXT NOT NULL,
        date TEXT NOT NULL,
        objective REAL,
        data_path TEXT NOT NULL,
        log_path TEXT NOT NULL,

        PRIMARY KEY(id)
        FOREIGN KEY(dec_id) REFERENCES decomposition(id)
    )
    """
    SQLite.execute(db, query)
end

function create_pm_table_combination(db::SQLite.DB)
    query = """
    CREATE TABLE IF NOT EXISTS combination(
        id INTEGER NOT NULL,
        in_id1 INTEGER NOT NULL,
        in_id2 INTEGER NOT NULL,
        out_id INTEGER NOT NULL,
        process_path TEXT NOT NULL,

        PRIMARY KEY(id),
        FOREIGN KEY(in_id1) REFERENCES decomposition(id),
        FOREIGN KEY(in_id2) REFERENCES decomposition(id),
        FOREIGN KEY(out_id) REFERENCES decomposition(id),
        UNIQUE(in_id1, in_id2, out_id, process_path)
    )
    """
    SQLite.execute(db, query)
end

function create_pm_tables(db::SQLite.DB)
    create_pm_table_instance(db)
    create_pm_table_decomposition(db)
    create_pm_table_solve(db)
    create_pm_table_combination(db)
end

function create_pm_db(path::AbstractString="powermodels_db.sqlite"; delete_if_exists=false)
    db = SQLite.DB(path)
    if delete_if_exists
        delete_table(db, table) = DBInterface.execute(db, "DROP TABLE IF EXISTS $table")
        delete_table(db, "instance")
        delete_table(db, "decomposition")
        delete_table(db, "solve")
        delete_table(db, "combination")
    end
    create_pm_tables(db)
    return db
end
