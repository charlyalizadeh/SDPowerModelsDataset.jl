@testset "inserting instance in the database" begin
    db = create_pm_db("test_pm_db.sqlite")
    @test isfile("test_pm_db.sqlite")
    insert_instance!(db, "data/case14.m")
    rm("test_pm_db.sqlite")
end
