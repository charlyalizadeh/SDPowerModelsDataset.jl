function insert_combine!(db::SQLite.DB, in_id1::Int, in_id2::Int, out_id::Int)
    query = "INSERT INTO combination(in_id1, in_id2, out_id) VALUES($in_id1, $in_id2, $out_id)"
	execute_query(db, query)
end
