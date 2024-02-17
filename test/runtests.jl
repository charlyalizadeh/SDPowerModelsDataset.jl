using SDPowerModelsDataset
using Test
using Graphs
using SQLite
using DataFrames
using PowerModels

const testdir = dirname(@__FILE__)
tests = [
        "insert",
        "export_graph",
        "decompose"
]

@testset "SDPowerModelsDataset.jl" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
