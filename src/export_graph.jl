abstract type GraphExportType end
mutable struct DotExportType <: GraphExportType end

function _export_graph(graph::SimpleGraph, path::AbstractString, to::DotExportType=DotExportType())
    io = open(path, "w")
    write(io, "graph {\n")
    for edge in edges(graph)
        write(io, "    $(src(edge)) -- $(dst(edge));\n")
    end
    write(io, "}")
    close(io)
end
