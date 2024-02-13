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
config["graph_path"] = joinpath(config["data_path"], "graph")
config["instance_path"] = joinpath(config["graph_path"], "instance")
config["decomposition_path"] = joinpath(config["graph_path"], "decomposition")
config["process_path"] = joinpath(config["data_path"], "process")
isdir(config["graph_path"]) || mkdir(config["graph_path"])
isdir(config["instance_path"]) || mkdir(config["instance_path"])
isdir(config["decomposition_path"]) || mkdir(config["decomposition_path"])
isdir(config["process_path"]) || mkdir(config["process_path"])

using PowerModels
using Dates
using Graphs
using DelimitedFiles

include("export_graph.jl")
include("db/db.jl")

export create_pm_db
export insert_instance!, insert_instances!
export insert_decomposition!


end
