"""网格函数"""


include("struct.jl")
include("GemetoryModule.jl")


"""从已有网格数据转化为Dict类型\n
输入points点坐标矩阵；polys多边形节点编号矩阵
polys=[1 2 3 4 "" ""
       3 4 5 8  2  3
       1 2 3 "" "" ""]

"""
function readCell(points,polys)
    #将points矩阵转化为Dict（）
    node=Dict(i=>Pointc(i, points[i,1], points[i,2], 0.0) for i in 1:1:size(points,1))

    #
    cell=Dict{Int,Poly}()

    for i in 1:1:size(polys,1)
        p=polys[i,:]#读取矩阵的一行
        m=findall(x->typeof(x)==Int||typeof(x)==Float64,p)#找到类型为Int的索引
        p=Int.(p[m])#只取为Int的

        po=[node[p[j]] for j in 1:1:size(p,1)] #将p里面的point序号和node关联

        push!(cell,i=>Poly(i,po))
        
    end

    return node,cell

end

"""生成点=>单元的字典"""
function pointTocell(cell)
    pointcell=Dict();#point=>[cell1,cell2,cell3]
    for i in collect(keys(cell))
        for j in cell[i].p

            if j in keys(pointcell)#判断此点是否在pointcell里面
                push!(pointcell[j],i)
            else
                push!(pointcell,j=>[i])
            end
        end
    end
    #chack
    if allunique([i.id for i in collect(keys(pointcell))])==false
        error("farea内部point有重复的，判断此点是否在pointcell里面，更改为id判别")
    end
    return pointcell
end

"""
计算单元中心到点的方向向量\n
points::Vector{Point}  目标点\n
pointcell::Dict{Point=>[cell.id cell.id]}  点=>单元id
"""
function point_cen_vector(points::Vector,pointcell::Dict,cell)
    pocen=Dict()
    for po in points #po::Point
        trpi=[0.;0.]
        for i in pointcell[po]   #i::Int
            cen=cenpoly(cell[i].p)#单元形心坐标
            tr=[po.x;po.y]-cen;
            trpi=trpi+tr;
        end
        normalize!(trpi)
        push!(pocen,po=>trpi)
    end
    return pocen
end

"""
从Poly里面删除一个point\n
Notice:此point必须与Poly里面的point同源，即hash值相同
"""
function deletepoint!(poly,point...)
    for i in point
        indx=findall(x->x==i,poly.p)
        if indx==[]
            @error "no point id： $(i.id) in this poly"
        else
            deleteat!(poly.p,indx)
        end
    end
end



    
