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

using OPFSDP
using Dates
using SparseArrays
using Random
using UUIDs
using DelimitedFiles
using DataFrames
using FileIO
using JLD2
using JuMP
using SCS
using Mosek
using MosekTools
using Memento
using MPI
using CSV
using SQLite

_LOGGER = getlogger(@__MODULE__)

include("utils.jl")
include("graphs/features.jl")
include("db/db.jl")
include("db/create_db.jl")
include("db/query/infos.jl")
include("db/query/select_instance.jl")
include("db/query/select_decomposition.jl")
include("db/query/delete_decomposition.jl")
include("db/insert/insert_instance.jl")
include("db/insert/insert_decomposition.jl")
include("db/insert/insert_merge.jl")
include("db/insert/insert_combine.jl")
include("decompose/decompose.jl")
include("decompose/merge.jl")
include("decompose/combine.jl")
include("delete_duplicate.jl")
include("solve/solve.jl")
include("mpi/mpi.jl")

export create_pm_db
export insert_instance!, insert_instances!
export insert_decomposition!
export insert_merge!
export generate_decomposition!, generate_decompositions!, generate_decompositions_one_clique!
export solve_decomposition!, solve_decompositions!
export delete_duplicate_decomposition!
export merge_decomposition!, merge_decompositions!
export execute_process_mpi
export generate_decompositions_mpi!, merge_decompositions_mpi!, solve_decompositions_mpi!
export combine_decompositions_mpi!, delete_duplicate_decompositions_mpi!


end
