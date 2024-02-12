module SDPowerModelsDataset

using TOML

config = TOML.parse(read(open("config.toml", "r"), String))
if occursin("~", config["data_path"])
    config["data_path"] = replace(config["data_path"], "~" => homedir())
end
isdir(config["data_path"]) || mkdir(config["data_path"])
let graph_path = joinpath(config["data_path"], "graph")
    instance_path = joinpath(graph_path, "instance")
    decomposition_path = joinpath(graph_path, "decomposition")
    isdir(graph_path) || mkdir(graph_path)
    isdir(instance_path) || mkdir(instance_path)
    isdir(decomposition_path) || mkdir(decomposition_path)
end

using PowerModels
using Dates
using Graphs

include("export_graph.jl")
include("db/db.jl")

export create_pm_db
export insert_instance!, insert_instances!
export insert_decomposition!


end