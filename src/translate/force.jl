#=
These functions compute the forces on all vertices

=#
"""计算每个节点受力\n
如果flpoint里面存储需要改变线张力的一组点[Pointc,Pointc],kc为改变后的线张力\n

"""
function force(cell;kc=k,flpoint::Vector=[])
    farea=Dict()#存储节点=>力
    
    for i in values(cell)#遍历每个单元
        areai=Area(i)
        per=peri(i.p)
        for j in 1:length(i.p)#遍历每个点，求解此单元对该点i.p[j]的力

            if j==1
                gc=i.p[end]#该j点的前一个点
            else
                gc=i.p[j-1]
            end
            if j==length(i.p)
                gcc=i.p[1]#该j点后一个点
            else
                gcc=i.p[j+1]
            end

            begin#变形力
                diffvec=[gcc.x-gc.x; gcc.y-gc.y]#本单元在节点i前后两个单元的坐标差
                grad1=0.5*[0 1;-1 0]*diffvec
                coeff1=2ka*(areai-A0)
                fa=coeff1*grad1   #此单元对此节点的面积力
            end

            begin#表面力
               v1=normalize([i.p[j].x-gc.x; i.p[j].y-gc.y])
               v2=normalize([i.p[j].x-gcc.x; i.p[j].y-gcc.y])
               grad2=v1+v2
               coeff2=2*beta*(per-P0)
               fp=coeff2*grad2
            end

            #判断此点是否需要改变线张力
            if j in flpoint
               gcc in flpoint ?  k2=kc : k2=k;
               gc in flpoint ? k1=kc : k1=k;
            else
                k1=k
                k2=k
            end

            begin#细胞间黏附力
                fl=k1*v1+k2*v2
            end

            #判断此点是否在farea里面
            #！！！这里in判断比较的是hash()值，只有从同一个数据集中取出的点才能比较
            if i.p[j] in keys(farea)
                farea[i.p[j]]=farea[i.p[j]]-fa-fp-fl
            else
                push!(farea,i.p[j]=>-fa-fp-fl)
            end
        end
    end
    #chack
    if allunique([i.id for i in collect(keys(farea))])==false
        error("farea内部point有重复的，判断此点是否在farea里面，更改为id判别")
    end
    return farea
end

"""更新节点位置"""
function upPoint!(farea,dt)
       for j in keys(farea)
           dl=farea[j]/mu.*dt
           j.x=j.x+dl[1]
           j.y=j.y+dl[2]
       end
end
