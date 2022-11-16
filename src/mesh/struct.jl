#数据类型

"""顶点数据类型"""
mutable struct Pointc
    id::Int
    x::Number
    y::Number
    z::Number
end

"""边"""
mutable struct Edge
    p1::Pointc
    p2::Pointc
end

"""由于三角划分的三角单元类型"""
mutable struct TriEle
    id::Int64
    i::Pointc
    j::Pointc
    k::Pointc
    cen::Pointc#外接圆圆心坐标  CenterTri(i,j,k,id)[1]
    r::Float64#外接圆半径       CenterTri(i,j,k,id)[2]
end

"""多边形结构\n
p为逆时针排列的点
"""
mutable struct Poly
    id::Int64
    p::Vector{Pointc}
end

"""三角形单元数据类型"""
#= mutable struct TriCell <: Poly
    id::Int64
    point1::Pointc
    point2::Pointc
    point3::Pointc
    

end =#


