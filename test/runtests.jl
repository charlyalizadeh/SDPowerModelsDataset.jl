using SDPowerModelsDataset
using Test
using Graphs

const testdir = dirname(@__FILE__)
tests = [
        "db/insert",
        "export_graph",
        "process"
]

@testset "SDPowerModelsDataset.jl" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
