@testset "insert" begin
    @testset "insert instance in the database" begin
        db = create_pm_db("test_pm_db.sqlite"; delete_if_exists=true)
        @test isfile("test_pm_db.sqlite")
        insert_instance!(db, "data/case14.m")
        query = "SELECT * FROM instance WHERE name = \"case14\" AND scenario =\"0\""
        result = DBInterface.execute(db, query) |> DataFrame
        @test size(result, 1) == 1
        rm("test_pm_db.sqlite")
    end
end
