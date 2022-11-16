using CairoMakie
using Meshes, MeshViz,GeometryBasics
"""使用makie绘制cell\n
 注意：主要用于调试"""
 function cellmakie(cell,name)
    point,polys=Rever(cell)
    point=point[:,1:2]
    points=Point2[point[i,:] for i in 1:size(point,1)]
    connec=connect.([Tuple(polys[i]') for i in 1:length(polys)],Ngon)
    mesh = SimpleMesh(points, connec)

    picture=viz(mesh, showfacets = true)

 end
 