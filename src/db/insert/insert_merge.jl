function insert_merge!(db::SQLite.DB, src_id::Int, dst_id::Int, merge_alg::OPFSDP.AbstractMerge)
    query = "INSERT INTO merge(src_id, dst_id, merge_alg) VALUES($src_id, $dst_id, '$(get_object_str(merge_alg))')"
	execute_query(db, query)
end
