function _check_duplicate(dec1::DataFrameRow, dec2::DataFrameRow)
	adj1 = sparse(readdlm(dec1[:adj_path], '\t', Float64, '\n'))
	adj2 = sparse(readdlm(dec2[:adj_path], '\t', Float64, '\n'))
	return adj1 == adj2
end

function delete_duplicate_decompositions_by_instance!(db::SQLite.DB, instance::DataFrameRow)
    decompositions = select_decomposition_by_name_scenario(db::SQLite.DB, [instance[:name]], [string(instance[:scenario])])
    deleted_ids = []
    for (i, dec1) in enumerate(eachrow(decompositions[begin:end-1, :]))
        (dec1[:id] in deleted_ids) && continue
        for dec2 in eachrow(decompositions[i+1:end, :])
			(dec2[:id] in deleted_ids) && continue
            if _check_duplicate(dec1, dec2)
                println("Deleting decomposition ($(dec2[:id]), $(dec2[:name]), $(dec2[:scenario]), $(dec2[:decomposition_alg]))")
                delete_decomposition!(db, dec2[:id])
                push!(deleted_ids, dec2[:id])
            end
        end
    end
end

function delete_duplicate_decompositions!(db::SQLite.DB; subset=nothing)
    instances = select_instance_by_ids(db::SQLite.DB, subset) |> DataFrame
    delete_func!(row) = delete_duplicate_decompositions_by_instance!(db, row)
    delete_func!.(eachrow(instances))
end
