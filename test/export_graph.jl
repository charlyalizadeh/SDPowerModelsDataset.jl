@testset "exporting graph to the dot format" begin
    graph = SimpleGraph([0 1 0 0 1; 1 0 1 0 1; 0 1 0 0 0; 0 0 0 0 1; 1 1 0 1 0])
    SDPowerModelsDataset._export_graph(graph, "temp.gv")
    file_str = read(open("temp.gv", "r"), String)
    @test file_str == """graph {
    1 -- 2;
    1 -- 5;
    2 -- 3;
    2 -- 5;
    4 -- 5;
}"""
    graph2 = SDPowerModelsDataset._import_graph("temp.gv")
    @test graph == graph2
    rm("temp.gv")
end
