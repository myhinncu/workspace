#=
    使用VoronoiCells 包实现Voronoi划分
=#
include("struct.jl")
using VoronoiCells
using GeometryBasics:Point2
#using Plots
using Random
using DelimitedFiles

"""
使用VoronoiCells 包实现Voronoi划分\n
输出两个point.txt 和 poly.txt文件
"""
function Voronoicells()
    rng = Random.MersenneTwister(133)
    rect = Rectangle(Point2(0, 0), Point2(1, 1))
    points = [Point2(rand(rng), rand(rng)) for _ in 1:10]

    tess = voronoicells(points, rect);
    #=绘图
    scatter(points, markersize = 6, label = "generators")
    annotate!([(points[n][1] + 0.02, points[n][2] + 0.03, Plots.text(n)) for n in 1:10])
    plot!(tess, legend = :topleft)
    =#


    cell=tess.Cells;
    cellpoints=[];
    for i in 1:size(cell,1)
        #收集所有点数据
        for j in 1:size(cell[i],1)
            a=[cell[i][j][1] cell[i][j][2]]
            push!(cellpoints,a)
        end
    end
    unique!(cellpoints); #去除重复的
    #cellpoints=vcat(cellpoints...)#所有节点的坐标

    poly=[]
    for i in 1:size(cell,1)
        ppid=[]#poly_point_id
        for j in 1:size(cell[i],1)
            a=[cell[i][j][1] cell[i][j][2]]
            id=findall(x->x==a,cellpoints)
            push!(ppid,id)
        end
        ppid=vcat(ppid...)'
        push!(poly,ppid)
    end
    writedlm("date//poly.txt",poly)
    writedlm("date//points.txt",cellpoints)
    
end




