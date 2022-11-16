#细胞分裂



"""选择进行分裂的单元\n
areathe默认=2.2，细胞大于平均细胞面积areath倍进行分裂"""
function selectDivCells(cell)
    #计算多边形面积
    cellarea=Dict()#存储单元面积id=>area
    mean=0.;#所有单元的平均面积
    for i in collect(keys(cell))
        S=Area(cell[i])
        push!(cellarea, i=>S)

        mean=mean+S/length(cell)
    end

    #选择进行分裂的单元
    divcell=findall(x-> x > areathe*mean, cellarea)
    #随机选择，随机个数
   #=  if divcell!=[]
        number=rand(1:length(divcell))
        divcell=rand(divcell,number)#随机选几个
        unique!(divcell)
    end =#
    
    return divcell
end

"""细胞分裂"""
function cellDivision!(cell,divcell)
    #选取细胞进行分裂
    for i in divcell
        x0,y0=cenpoly(cell[i].p)#形心坐标
        Ixx,Iyy,Ixy=inertia(cell[i].p,x0,y0)#计算惯性矩
        matr=[Ixx -Ixy;
             -Ixy  Iyy]
        matr=eigen!(matr)#获取特征值和特征向量
        maxvalue=findmax(matr.values)#最大特征值
        maxvector=matr.vectors[maxvalue[2],:]#最大特征值的特征向量

        ##求特征向量与形心构成直线与单元的交点
        cenpi=Pointc(-1,x0,y0,0.)
        matrpi=Pointc(-1,maxvector[1]+x0, maxvector[2]+y0, 0.)
        interpi=[]#存储交点坐标
        line=[]#存储交点所在直线，直线的点在p中的位置
        for j in 1:length(cell[i].p)
            
            if j < length(cell[i].p)
               b=j+1
            elseif j==length(cell[i].p)
                b=1
            end

            inpi=lineToSegment([cenpi,matrpi], [cell[i].p[j], cell[i].p[b]])#直线与线段交点

            if inpi!=[]
                push!(interpi,inpi)
                push!(line, [j,b])
            end
        end
        unique!(interpi)

        #重新构建单元
        if length(line)==2#直线穿过两条线段
            global np=np+1
            pi1=Pointc(np, interpi[1][1], interpi[1][2], 0)#两个交点
            global np=np+1
            pi2=Pointc(np, interpi[2][1], interpi[2][2], 0)

            #从1:line[1][1];pi1;pi2；line[2][2]:end为一个单元，line[1][2]：line[2][1]；pi2;pi1为一个单元
            #line:[2, 3]
            #     [4, 1]
            #[1 2 p1 p2] [3 4 p2 p1]
            if line[2][2]==1
                po1=[cell[i].p[1:line[1][1]];pi1;pi2]#新的两个单元的节点集合
            else
                po1=[cell[i].p[1:line[1][1]];pi1;pi2; cell[i].p[line[2][2]:end]]#新的两个单元的节点
            end
            po2=[cell[i].p[line[1][2]:line[2][1]]; pi2; pi1]
            global nc=nc+1
            push!(cell,nc=>Poly(nc,po1))
            global nc=nc+1
            push!(cell,nc=>Poly(nc,po2))
           # 

            #查找与两个边相关的单元
            p1=cell[i].p[line[1][1]]
            p2=cell[i].p[line[1][2]]
            p3=cell[i].p[line[2][1]]
            p4=cell[i].p[line[2][2]]
            a1=findall(x->p1 in x.p && p2 in x.p,cell)
            setdiff!(a1,i)#a1为除i以外另一个单元编号
            if a1!=[]
               push!( cell[a1[1]].p,pi1)
               cell[a1[1]].p=CCW(cell[a1[1]].p)
            end
            a2=findall(x->p3 in x.p && p4 in x.p,cell)
            setdiff!(a2,i)
            if a2!=[]
                push!(cell[a2[1]].p,pi2)
                cell[a2[1]].p=CCW(cell[a2[1]].p)
             end
            delete!(cell,i)
        end
        ###未完成
        if length(line)==3
            c1=findall(x->typeof(x)==Pointc,interpi)#重合点在interpi的位置
            c2=findall(x->x==interpi[c1][1],cell[i].p)#重合点在单元的位置
            d1=findall(x->typeof(x)!=Pointc,interpi)#交点在interpi的位置

            line=[line[c1];line[d1]]

        end
        #未完成
        if length(line)==4

        end

    end
end

"""计算多边形对于形心的惯性矩"""
function inertia(p,x0,y0)
    Ixx=0
    Iyy=0
    Ixy=0
    for i in 1:length(p)
        if i<length(p)
            xi=p[i].x-x0
            yi=p[i].y-y0
            xi1=p[i+1].x-x0#xᵢ₊₁
            yi1=p[i+1].y-y0
        else
            xi=p[i].x-x0
            yi=p[i].y-y0
            xi1=p[1].x-x0
            yi1=p[1].y-y0
        end
        Ixx=Ixx+(xi*yi1 - xi1*yi)*(yi^2 + yi*yi1 + yi1^2)/12
        Iyy=Iyy+(xi*yi1 - xi1*yi)*(xi^2 + xi*xi1 + xi1^2)/12
        Ixy=Ixy+(xi*yi1 - xi1*yi)*(xi*yi1 + 2*xi*yi + 2*xi1*yi1 + xi1*yi)/24
    end
    return Ixx,Iyy,Ixy
end