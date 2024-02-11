using SDPowerModelsDataset
using Test
using Graphs

@testset "SDPowerModelsDataset.jl" begin
    @testset "inserting instance in the database" begin
    end
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
    rm("temp.gv")
    end
end
