@testset "decompose" begin
        db = create_pm_db("test_pm_db.sqlite")
        insert_instance!(db, "data/case14.m")
        instance = SDPowerModelsDataset.select_instance(db, "case14", "0") |> DataFrame
        generate_decomposition!(db, instance[1, :], PowerModels.CholeskyExtension())
        rm("test_pm_db.sqlite")
end
