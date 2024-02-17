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

function _import_graph(path::AbstractString, from::DotExportType=DotExportType())
    lines = split(read(open(path, "r"), String), '\n')
    graph = SimpleGraph(length(lines) - 2)
    for l in lines[2:end-1]
        src, dst = split(replace(l, " " => "", ";" => ""), "--")
        add_edge!(graph, parse(Int, src), parse(Int, dst))
    end
    return graph
end
