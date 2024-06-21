function delete_decomposition!(db::SQLite.DB, id::Integer)
	query = "DELETE FROM decomposition WHERE id == $id"
	execute_query(db, query)
end
