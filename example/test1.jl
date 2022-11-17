#=
    一个简单的顶点模型
    time：2022-11-17
    created by：chen xuefei
    unit: normalize
    备注：
=# 
using DelimitedFiles
using LinearAlgebra
using WriteVTK
using Random
include("$(pwd())\\src\\mesh\\struct.jl")
include("$(pwd())\\src\\mesh\\MeshModule.jl")
include("$(pwd())\\src\\visual\\View.jl")
include("$(pwd())\\src\\mesh\\GemetoryModule.jl")
include("$(pwd())\\src\\translate\\T2.jl")
include("$(pwd())\\src\\translate\\T1.jl")
include("$(pwd())\\src\\translate\\cellDivision.jl")
include("$(pwd())\\src\\mesh\\hexmesh.jl")
include("$(pwd())\\src\\translate\\T3.jl")
include("$(pwd())\\src\\translate\\force.jl")

#parameter
begin
    global beta=0.16; #膜表面能系数Γ;  nN/μm
    global P0=2.1;#2*sqrt(pi*A0); #单元目标周长  μm
    global k=0;#线张力Λ;       nN  待研究
    global dsep=0.2;#交换邻居后的边长度 μm
    global lmin=0.1;#T1最小边长度  μm
    global thearea=0.003;#最小单元面积  μm^2
    global areathe=2;#单元面积超过平均面积的areathe倍进行分裂
            r=0.56;
    global A0=1.;
    global ka=1;
    global mu=1;

    ##sove parameter
    allstep=1000;   #总步数
    dt=0.01;     #每一步时间
    t=Int(0);
    scr=2;
    #cell单元行列数
    row=30;
    col=25;

    vx=30;#

    fname="$(pwd())\\example\\result\\test1_beta$(beta)_p0$(P0)_lmin$(lmin)_dt$(dt)_scr$(scr)_vx$(vx)_$(row)x$(col)-"
end

#读取cell网格数据
#生成网格：hexmesh(row,col,r,"$(pwd())\\data\\$(row)x$(col)_")
begin
    cellpoints=readdlm("$(pwd())\\data\\$(row)x$(col)_hexpoints.txt");#读取点坐标文件和poly文件
    cellpolys=readdlm("$(pwd())\\data\\$(row)x$(col)_hexcell.txt",Int);
    node,cell=readCell(cellpoints,cellpolys);#其中cell里面的节点值改变会导致node里面的也随着改变
    global np=maximum(keys(node));#节点最大编号
    global nc=maximum(keys(cell));#单元最大编号
end

#solve
while t<allstep
    
    #T2变换
    rcell=cellsForT2(cell);#需要进行T2变换的单元
    if rcell !=[]
        cell,node=T2Trans!(rcell,cell,node);
    end
   
    #T1变换
    lpoint,pi1,pi2=edgeT1(cell)
    if lpoint!=[]#如果有符合要求的边，进行t1变换
        cell=T1Trans!(cell,lpoint,pi1,pi2)
    end
    
    #细胞分裂
    divcell=selectDivCells(cell)
    if divcell!=[]
        cellDivision!(cell,divcell)
    end 
 
    #更新节点位置
    farea=force(cell)
    upPoint!(farea,dt)

    #可视化
   
    viewcell(cell,"$(fname)$(t).vtp")
    println(Int(t))
    t=t+1
end



