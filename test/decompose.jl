@testset "decompose" begin
        db = create_pm_db("test_pm_db.sqlite")
        insert_instance!(db, "data/case14.m")
        instance = SDPowerModelsDataset.select_instance(db, "case14", "0") |> DataFrame
        generate_decomposition!(db, instance[1, :], PowerModels.CholeskyExtension())
        decomposition = SDPowerModelsDataset.select_decomposition_all(db) |> DataFrame
        decomposition = decomposition[1, :]
        solve_decomposition!(db, decomposition)
        rm("test_pm_db.sqlite")
end
