function solve_decomposition!(db::SQLite.DB, decomposition::Dict)
    data = PowerModels.parse_file(select_instance_data_path(decomposition["name"], decomposition["scenario"]))
    pm = InfrastructureModels.InitializeInfrastructureModel(PowerModels.SparseSDPWRMPowerModel,
                                                            data,
                                                            PowerModels._pm_global_keys,
                                                            PowerModels.pm_it_sym)
    PowerModels.ref_add_core!(pm.ref)
    nw = collect(nw_ids(pm))[1]
    groups = readdlm(decomposition["cliques_path"], '\t', Int, '\n')
    lookup_index = readdlm(decomposition["lookup_index_path"], '\t', Int, '\n')
    perm = readdlm(decomposition["perm_path"], '\t', Int, '\n')
    pm.ext[:SDconstraintDecomposition] = PowerModels._SDconstraintDecomposition(groups, lookup_index, perm)
    PowerModels.build_opf(pm)
    sdp_solver = JuMP.optimizer_with_attributes(SCS.Optimizer, "verbose"=>false)
    result = optimize_model!(pm, optimizer=sdp_solver)
    insert_solve!(db, decomposition, result, "SCS")
end
