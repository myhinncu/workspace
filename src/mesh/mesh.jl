

#生成网格文件并输出
using WriteVTK
using Random
using DelimitedFiles
include("struct.jl")
include("GemetoryModule.jl")


#=run()
    Vx=Vy=5.;
    node,point=CreatPoint(Vx,Vy)
    triangle=Delaonay(node,point)
    cenpoint,polys=DVoronoi(triangle,node)
    #可视化
    cenpoint=cenpoint'
    mesh=Vector{MeshCell{WriteVTK.PolyData.Polys, Vector{Int64}}}()
    for i in collect(keys(polys)) 

        cenid=Vector{Int64}(undef,length(polys[i].p))
        for j in 1:length(polys[i].p)
            cenid[j]=polys[i].p[j].id
        end
        mesh1=MeshCell(PolyData.Polys(),cenid)
        push!(mesh,mesh1)
    end

    trc=vtk_grid("VoronioMesh", cenpoint, mesh)
    vtk_save(trc)
    #

=#

"""
从文件导入point顶点坐标和三角形网格；\n
转换成DVoronoi函数使用的数据类型\n
文件名分别为point.txt和ele.txt
"""
function LoadPoint()
    p=readdlm("date//point.txt")
    ele=readdlm("date//ele.txt",Int)
    ele=ele[:,1:3]
    p=[p[:,1] p[:,2] zeros(size(p,1))]    # Delaonay三角形顶点坐标矩阵
    node=Dict(i=>Pointc(i,p[i,1],p[i,2],p[i,3]) for i in 1:size(p,1))#将坐标矩阵转化为字典
    for i in 1:size(ele,1)
        
    end
    triangle=Dict(x=>TriEle(x,))
end

"""
在矩形区域内生成随机点
输入Vx：x坐标长度；Vy：y轴长度
输出node::Dict类型 id=>Pointc
point::Matrix类型，存储节点xyz坐标
"""
function CreatPoint(Vx::Float64,Vy::Float64)
    #=2D矩形网格生成
    Random.seed!(114);
    n=50;#节点的个数，也是将线段分的个数
    
    pointx=rand(0:0.1:Vx,n);
    pointy=rand(0:0.1:Vy,n);
    push!(pointx,0.,Vx,Vx,0.)
    push!(pointy,0.,0,Vy,Vy)
    point=[pointx pointy zeros(n+4)];
    =#
    m=10;n=10;
    point=Matrix(undef,m,n)
    dx=Vx/(n-1)
    dy=Vy/(m-1)
    for i in 1:m
        for j in 1:n
            x=(j-1)*dx+dx*rand(0.1:0.01:0.2,1)[1]
            y=(i-1)*dy+dy*rand(0.1:0.01:0.2,1)[1]
            point[i,j]=[x,y,0.]
        end
    end

    point=vcat(map(x->x',point)...)
    
    point=sortslices(point,dims=1);#对点依据xy坐标排序
    
    node=Dict(i=>Pointc(i,point[i,1],point[i,2],point[i,3])  for i in 1:m*n);#把坐标和节点编号生成字典
    
    return node,point
end

"""
Delaonay划分三角形网格
输入节点id=>坐标  Dict类型
"""
function Delaonay(node::Dict,point::Matrix)
    #算法地址 https://www.cnblogs.com/zhiyishou/p/4430017.html
    n=length(node);

    pmax=findmax(point ,dims=1)[1];#得到最大点的key值,就是最右上角的点
    pmin=findmin(point ,dims=1)[1];#得到最小点的key值,就是最左下角的点

    #Pn1,Pn2,Pn3是一个把所有点包围起来的大三角形，具体点坐标无所谓
    pn1=Pointc(n+1,2*pmax[1],2*pmax[2],pmax[3]);
    pn2=Pointc(n+2,pmin[1]+pmin[2]-2*pn1.y, pn1.y, pn1.z);
    pn3=Pointc(n+3,pn1.x, pmin[1]+pmin[2]-2*pn1.x, pn1.z);
    

    triangle=Dict();#创建保存单元的字典
    #将最大三角形存储到tempTri字典
    tempTri=Dict(1=>TriEle(1,pn1,pn2,pn3,  CenterTri(pn1,pn2,pn3,1)[1],   CenterTri(pn1,pn2,pn3,1)[2]));

    for i in 1:n  #对所有点遍历
        pju=TriEle[]#存储当多个三角形外接圆共同包含一个点时，需要删除的多余三角形
        for  j in collect(keys(tempTri))   #对所有三角形遍历
            c=JudgePoint(node[i],   tempTri[j].cen,   tempTri[j].r)

            if c==0  #点在圆内部，连接三角形顶点，形成新的三角形 tempTri[j]表示遍历的这个单元
                
                ju=JudgeTri(node[i],tempTri[j]);#判断点与三角形位置

                if ju==1#点在三角形内
                    ei,ej,ek,en=node[i],tempTri[j].i,tempTri[j].j , rand(Int64,1)[1] ;
                    tempTri[en]=TriEle(en, ei,ej , ek, CenterTri(ei,ej,ek,en)[1], CenterTri(ei,ej,ek,en)[2])#第一个三角形

                    ei,ej,ek,en=node[i],tempTri[j].j,tempTri[j].k , rand(Int64,1)[1];#给单元id一个随机数，防止重复
                    tempTri[en]=TriEle(en, ei, ej, ek, CenterTri(ei,ej,ek,en)[1], CenterTri(ei,ej,ek,en)[2])#第2个三角形

                    ei,ej,ek,en=node[i],tempTri[j].k,tempTri[j].i , rand(Int64,1)[1];
                    tempTri[en]=TriEle(en, ei,ej , ek, CenterTri(ei,ej,ek,en)[1], CenterTri(ei,ej,ek,en)[2])#第3个三角形

                    delete!(tempTri,j);#从tempTri删除此单元,下次不再遍历
                elseif ju[1]==0#点在三角形边上,划分两个三角形
                    ei,ej,ek,en=node[i],ju[4],ju[2], rand(Int64,1)[1] ;
                    tempTri[en]=TriEle(en, ei,ej , ek, CenterTri(ei,ej,ek,en)[1], CenterTri(ei,ej,ek,en)[2])

                    ei,ej,ek,en=node[i],ju[3],ju[4], rand(Int64,1)[1] ;
                    tempTri[en]=TriEle(en, ei,ej , ek, CenterTri(ei,ej,ek,en)[1], CenterTri(ei,ej,ek,en)[2])

                    delete!(tempTri,j);
                elseif ju[1]==-1 #点在三角形外,跟在边上一样
                    ei,ej,ek,en=node[i],ju[4],ju[2], rand(Int64,1)[1] ;
                    tempTri[en]=TriEle(en, ei,ej , ek, CenterTri(ei,ej,ek,en)[1], CenterTri(ei,ej,ek,en)[2])

                    ei,ej,ek,en=node[i],ju[3],ju[4], rand(Int64,1)[1] ;
                    tempTri[en]=TriEle(en, ei,ej , ek, CenterTri(ei,ej,ek,en)[1], CenterTri(ei,ej,ek,en)[2])

                    ei,ej,ek,en=node[i],ju[3],ju[2], rand(Int64,1)[1];#应该删除的三角形
                    c=TriEle(en, ei,ej , ek, CenterTri(ei,ej,ek,en)[1], CenterTri(ei,ej,ek,en)[2])
                    push!(pju,c)
                    delete!(tempTri,j);
                end

            elseif c==-1#点在上面
                continue
            elseif c==1 #点在圆右边
                push!(triangle,j=>tempTri[j]);#将单元存入triangle
                delete!(tempTri,j);#从tempTri删除此单元,下次不再遍历
            end

        end
        #将点在三角形外产生多余三角形删除
        for m in 1:length(pju)
            f(x)=x.i.id==pju[m].i.id&&x.j.id==pju[m].j.id&&x.k.id==pju[m].k.id
            mm=findall(f,tempTri)
            for h in 1:length(mm)
                delete!(tempTri,mm[h])
            end
        end
 
    end

    merge!(triangle,tempTri);#合并两个库中的三角形

    for i in collect(keys(triangle)) #遍历所有单元
        c1=triangle[i].i.id;#这单元的3个节点id
        c2=triangle[i].j.id
        c3=triangle[i].k.id
        big=[n+1,n+2,n+3] ;#最大三角形的顶点
        #判断此三角形顶点里面是否有最大三角形的顶点，如果有就删除
        if findall(isequal(c1),big)!=[] || findall(isequal(c2),big)!=[] ||findall(isequal(c3),big)!=[]
            delete!(triangle,i)
        end
    end

    #将三角形的id和cen的id重新排列一下
    j=0
    for i in collect(keys(triangle))
        j=j+1
        triangle[i].id=j
        triangle[i].cen.id=j
    end
    #=可视化
    point=point'
    mesh1=[MeshCell(PolyData.Polys(),[triangle[i].i.id,triangle[i].j.id,triangle[i].k.id]) for i in collect(keys(triangle)) ]
    trc=vtk_grid("DelaonayMesh", point,mesh1)
    vtk_save(trc)
    =#
    return triangle
end


"""
Delaonay法生成Voronoi网格
输入由delaonay的三角形网格triangle;和点坐标矩阵\n
triangle是由TriEle组成的字典
"""
function DVoronoi(triangle::Dict,node::Dict)
    polys=Dict{Int64,Poly}();#存储多边形单元
    for i in collect(keys(node))#遍历每一个顶点
        #查找使用此顶点的三角形
        f(x)=i==x.i.id||i==x.j.id||i==x.k.id
        mm=findall(f,triangle)#findall寻找的是符合f要求values相对的键值keys
        p=[triangle[j].cen for j in collect(mm)]#取三角形外接圆圆心点
        p=CCW(p)#逆时针排序

        poly=Poly(i,p)#生成poly
        c=JudgePoly(node[i],poly)#判断节点是否在多边形内,函数有点问题,需要把边缘的点形成的多边形排除

       # if c==1
            push!(polys,i=>poly)#将i=>poly存入
       # end

    end
    #导出多边形顶点坐标
    cenpoint=Matrix{Float64}(undef,length(triangle),3)
    for j in collect(keys(triangle))
        cenpoint[triangle[j].id,:]=[triangle[j].cen.x triangle[j].cen.y triangle[j].cen.z]
    end

    
    return cenpoint,polys
end






