#将数据生成VTK文件，用paraview可视化

using WriteVTK

#=例子 example
    a=[[0 1 0];[-1 0 0]; [0 -1 0]; [1 0 0]; [1 1 0]]
    a=a';
    poly=MeshCell(PolyData.Polys(),[1,3,2]);#MeshCell(类型，[节点顺序])
    poly0=MeshCell(PolyData.Polys(),[1;1;1]);#空单元测试·empty cells test·
    poly3=MeshCell(PolyData.Polys(),[4,3,2]);#MeshCell(类型，[节点顺序])
    trc=vtk_grid("my_vtp", a, [poly;poly0;poly3])

    vtk_save(trc);#保存文件

    a为3xn的坐标矩阵，[poly]为MeshCell类型的向量[单元1；单元2......]
=#

"""将cell转化为节点坐标矩阵point[x y z]\n
和单元节点id[1 2 3 4]\n
if sortid = true 可使单元id与paraview里面对应
"""
function Rever(cell;sortid=false)
    point=[]#存储总的点坐标
    poly=[]#存储总的poly节点编号
    if sortid == true
        cellkeys=collect(keys(cell));
        for i in  1:1:maximum(cellkeys) #所有单元的key编号，遍历所有单元
            if i in cellkeys
                po=Vector(undef,length(cell[i].p))#存储这个单元的节点编号
        
                for j in 1:length(cell[i].p)
                    pin=[cell[i].p[j].x cell[i].p[j].y cell[i].p[j].z]#获得本poly的一个点的xyz坐标[x y z]
                    chack=findall(x->x==pin,point)#查找列表里是否已经存在这个点
                    if chack==[]#不存在
                        push!(point,pin)   #压入总列表
                    end
                    po[j]=findall(x->x==pin,point)#得到本单元节点的编号，与节点坐标对应
                end
                push!(poly,vcat(po...)')#压入节点编号总列表
            else
                push!(poly,[1 1 1])
            end
            
        end

    elseif sortid == false

        for i in collect(keys(cell))#所有单元的key编号，遍历所有单元
            po=Vector(undef,length(cell[i].p))#存储这个单元的节点编号
    
            for j in 1:length(cell[i].p)
                pin=[cell[i].p[j].x cell[i].p[j].y cell[i].p[j].z]#获得本poly的一个点的xyz坐标[x y z]
                chack=findall(x->x==pin,point)#查找列表里是否已经存在这个点
                if chack==[]#不存在
                    push!(point,pin)   #压入总列表
                end
                po[j]=findall(x->x==pin,point)#得到本单元节点的编号，与节点坐标对应
            end
            push!(poly,vcat(po...)')#压入节点编号总列表
    
        end
    end
    point=vcat(point...)
    return point,poly
end

"""生成可用paraview查看的可视化文件\n
stress为每一个单元的三个应力分量id=>[σxx;σyy;σxy]\n
T1,T4：要着色的单元id ::Vector[id1;id2...]
"""
function viewcell(cell,name;stress=[],T1=[],T4=[]) 
    cell=sort(cell);
    point,poly=Rever(cell);
    point=point';
    cellkeys=collect(keys(cell));
    polys=[MeshCell(PolyData.Polys(),i[:]) 
    for i in poly ]

    trc=vtk_grid(name, point, polys);

    if stress != []#写入单元stress
        vstress=collect(values(sort(stress)));
        vstress=vcat(vstress'...);
        trc["stress_xx",VTKCellData()]=vstress[:,1];#
        trc["stress_yy",VTKCellData()]=vstress[:,2];#
        trc["stress_xy",VTKCellData()]=vstress[:,3];#
    end

    if T1 != []
        indx=[findall(x->x==y,cellkeys) for y in T1];
        indx=vcat(indx...);
        T1cell=zeros(length(cellkeys));#生成与单元数相同的向量
        T1cell[indx].=1;#将要赋予量的单元置1
        trc["T1",VTKCellData()]=T1cell;
    end

    if T4 != []
        indx=[findall(x->x==y,cellkeys) for y in T4];
        indx=vcat(indx...);
        T4cell=zeros(length(cellkeys));#生成与单元数相同的向量
        T4cell[indx].=4;#将要赋予量的单元置4
        trc["T4",VTKCellData()]=T4cell;
    end

    vtk_save(trc)
end

"""
生成可用paraview查看的可视化文件\n
一个多边形
"""
function viewcell(poly::Poly,name)
    point=Matrix{Float64}(undef,length(poly.p),3)
    for i in 1:1:length(poly.p)
        point[i,1]=poly.p[i].x;
        point[i,2]=poly.p[i].y;
        point[i,3]=0.;
    end
    point=point';
    polys=MeshCell(PolyData.Polys(),1:1:length(poly.p));#MeshCell(类型，[节点顺序])
    trc=vtk_grid(name, point, [polys])
    vtk_save(trc)
end

"""
生成可用paraview查看的可视化文件\n
点以坐标矩阵形式；单元以矩阵形式\n
"""
function viewcell(points::Matrix,polys::Matrix,name)
    points=points'
    polys=[MeshCell(PolyData.Polys(),polys[i,:]) 
                    for i in 1:1:size(ecmquas,1) ];
    trc=vtk_grid(name, points, polys);
    vtk_save(trc)
end

"""输出当前单元"""
function exportcell(cell,pointname,polyname)
    point,poly=Rever(cell)
    writedlm("data//$(polyname).txt",poly)
    writedlm("data//$(pointname).txt",point)
end
#= point=point'
polys=[MeshCell(PolyData.Polys(),[triangle[i].i.id,triangle[i].j.id,triangle[i].k.id]) for i in collect(keys(triangle)) ]
trc=vtk_grid("my_vtp", point, polys)
vtk_save(trc)
=#



 