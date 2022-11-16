#T1translate，当边小于一定值时交换邻居



"""查找需要T1变换的边\n

"""
function edgeT1(cell)
    ##计算边长度，找到满足需要的边
    lpoint=[];#需要T1变换的边的两个节点[point1 point2]
    for i in collect(keys(cell))
        p=cell[i].p
        for j in 1:length(p)
            #
            if j==last(1:length(p))
                b=1
            else
               b=j+1
            end
            L=Leng(p[j],p[b])
           #判断边长度与lmin
           if L<=lmin
               push!(lpoint,[p[j] p[b]])
           end
        end
    end
    ##lpoint去重,and not sort for lpoint
    unique!(x->sort!(union(x[1].id, x[2].id)),lpoint)

    ##找到与该边相关的单元
    pi1=[];#存储与point1相关的单元
    pi2=[];#存储与point2相关的单元
    for j in lpoint   #j为一条边,x=poly
        a=findall(x->j[1] in x.p,cell)
        b=findall(x->j[2] in x.p,cell)
        push!(pi1,a)
        push!(pi2,b) 
    end

    return lpoint,pi1,pi2
end


"""T1变换"""
function T1Trans!(cell,lpoint,pi1,pi2)
    
    ##遍历每一条短边
    for i in 1:1:length(lpoint)#lpoint的每一个元素都是一条边

        twopi=intersect(pi1[i],pi2[i])#两节点单元编号
        onepi=[setdiff(pi1[i],pi2[i]);setdiff(pi2[i],pi1[i])]#单节点单元编号

        if onepi==[] && length(pi1[i])==length(pi2[i])==1#没有只包含一个点的单元，说明这条边没有与其他单元相邻,用中点代替
          a= findall(x->x==lpoint[i][1] || x==lpoint[i][2], cell[twopi...].p) 
          xx=(lpoint[i][1].x+lpoint[i][2].x)/2
          yy=(lpoint[i][1].y+lpoint[i][2].y)/2
          global np=np+1
          cenpi=Pointc(np, xx, yy, 0.)
          cell[twopi...].p[a[1]]=cenpi
          cell[twopi...].p[a[2]]=cenpi
          unique!(cell[twopi...].p)
        else#边与其他单元关联
            mid=midnormal(lpoint[i][1],lpoint[i][2],dsep)#该边的垂直平分线两点坐标
            ######################################################
            ######处理两节点单元
            ##先处理twopi[1]这个单元
            cen1=cenpoly(cell[twopi[1]].p)#两节点单元中心坐标[x;y]

            #判断该将两点替换为mid里面的哪个点，利用单元中心点和目标点在该边的同一侧原理
            p1p2=[lpoint[i][2].x-lpoint[i][1].x; lpoint[i][2].y-lpoint[i][1].y ];
            p1cen1=[cen1[1]-lpoint[i][1].x; cen1[2]-lpoint[i][1].y ];
            p1mid1=[mid[1,1]-lpoint[i][1].x; mid[1,2]-lpoint[i][1].y];
            #p1mid2=[mid[2,1]-lpoint[i][1].x; mid[2,2]-lpoint[i][1].y];

            a1=VectorPro(p1p2,p1cen1)#叉乘
            a2=VectorPro(p1p2,p1mid1)
           # a3=VectorPro(p1p2,p1mid2)
           #在第一个两节点单元里面的点设为midpi1
            if a1>=0 && a2>=0 || a1<=0  && a2<=0#如果mid1与cen在边的同一边
                midpi1=mid[1,:]
                midpi2=mid[2,:]
            else
                midpi1=mid[2,:]
                midpi2=mid[1,:]
            end
            #两个垂直平分线点
            global np=np+1
            midpi1=Pointc(np,midpi1[1], midpi1[2], 0. )
            global np= np+1
            midpi2=Pointc(np,midpi2[1], midpi2[2], 0. )

            #将两个点替换成一个点
            q=findall(x->x==lpoint[i][1] || x==lpoint[i][2], cell[twopi[1]].p)
            
            if length(q)<2
                println("q:",q)
                print("cell:",twopi[1])    
            end
            
            cell[twopi[1]].p[q[1]]=midpi1
            cell[twopi[1]].p[q[2]]=midpi1

            unique!( cell[twopi[1]].p)

            #处理twopi[2]
            if length(twopi)==2
                q=findall(x->x==lpoint[i][1] || x==lpoint[i][2], cell[twopi[2]].p)
                cell[twopi[2]].p[q[1]]=midpi2
                cell[twopi[2]].p[q[2]]=midpi2
                unique!( cell[twopi[2]].p)
            end
            ####################################################################
            ################处理一节点单元
            onepo1=setdiff(pi1[i],twopi)#一节点单元id
            onepo2=setdiff(pi2[i],twopi)

            if onepo1!=[]
                q2=findall(x->x==lpoint[i][1], cell[onepo1[1]].p)
                cell[onepo1[1]].p[q2[1]]=midpi1 #将一个点替换
                push!( cell[onepo1[1]].p,midpi2)#加上一个点
                cell[onepo1[1]].p= CCW( cell[onepo1[1]].p)
            end
            
            if onepo2!=[]
                q2=findall(x->x==lpoint[i][2], cell[onepo2[1]].p)
                cell[onepo2[1]].p[q2[1]]=midpi1 #将一个点替换
                push!( cell[onepo2[1]].p,midpi2)#加上一个点
                cell[onepo2[1]].p=CCW( cell[onepo2[1]].p)
            end
           
        end

    end
    return cell
end



