module SDPowerModelsDataset

using TOML

config_path = normpath(joinpath(@__DIR__, "..", "config.toml"))
config = TOML.parse(read(open(config_path, "r"), String))
if occursin("~", config["data_path"])
    config["data_path"] = replace(config["data_path"], "~" => homedir())
end
if config["data_path"] == ""
    config["data_path"] = normpath(joinpath(@__DIR__, "..", "data"))
end
isdir(config["data_path"]) || mkdir(config["data_path"])
config["adj_path"] = Dict()
config["adj_path"]["instance"] = joinpath(config["data_path"], "adj", "instance")
config["adj_path"]["decomposition"] = joinpath(config["data_path"], "adj", "decomposition")
isdir(config["adj_path"]["instance"]) || mkpath(config["adj_path"]["instance"])
isdir(config["adj_path"]["decomposition"]) || mkpath(config["adj_path"]["decomposition"])

using PowerModels
using Dates
using Graphs
using SparseArrays
using Random
using UUIDs
using DelimitedFiles
using DataFrames
using FileIO
using JLD2
using InfrastructureModels
using JuMP
using SCS

include("utils.jl")
include("graphs/export_graph.jl")
include("graphs/features.jl")
include("db.jl")
include("create_db.jl")
include("query/select_instance.jl")
include("query/select_decomposition.jl")
include("insert/insert_instance.jl")
include("insert/insert_decomposition.jl")
include("decompose.jl")
include("solve.jl")

export create_pm_db
export insert_instance!, insert_instances!
export insert_decomposition!
export generate_decomposition!
export solve_decomposition!


end
