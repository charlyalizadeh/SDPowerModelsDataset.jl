function solve_decomposition!(db::SQLite.DB, decomposition::DataFrameRow)
    data = PowerModels.parse_file(select_instance_data_path(db, decomposition[:name], decomposition[:scenario]))
    pm = InfrastructureModels.InitializeInfrastructureModel(PowerModels.SparseSDPWRMPowerModel,
                                                            data,
                                                            PowerModels._pm_global_keys,
                                                            PowerModels.pm_it_sym)
    PowerModels.ref_add_core!(pm.ref)
    nw = collect(PowerModels.nw_ids(pm))[1]
    data_dict = load(decomposition[:cliques_path])
    groups = data_dict["cliques"]
    perm = data_dict["perm"]
    lookup_index = keys_to_int(load(decomposition[:lookup_index_path]))
    pm.ext[:SDconstraintDecomposition] = PowerModels._SDconstraintDecomposition(groups, lookup_index, perm)
    PowerModels.build_opf(pm)
    sdp_solver = JuMP.optimizer_with_attributes(SCS.Optimizer, "verbose"=>false)
    result = optimize_model!(pm, optimizer=sdp_solver)
    insert_solve!(db, decomposition, result, "SCS")
end
