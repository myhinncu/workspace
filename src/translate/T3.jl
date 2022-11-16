#T3变换，当细胞与另一个细胞接触

#=test T3 1
ce1=Poly(1,[Pointc(1,-1,1,0);Pointc(2,-1,-1,0);Pointc(3,1,-1,0);Pointc(4,1,1,0)])
ce2=Poly(2,[Pointc(5,0.8,0.9,0);Pointc(6,1,1.5,0);Pointc(7,-1,1.5,0)])
cell=Dict(1=>ce1,2=>ce2)
test2
points=[-1 1;-1 -1;1 -1;1 1 ;0.8 0.9;1 1.5;0.5 1.7;0 1.6;-0.5 1.7;-1 1.5]
polys=[1 2 3 4;5 6 7 8;5 8 9 10]
test3
points=[-1 1;-1 -1;1 -1;1 1 ;0.8 0.9;1 1.5;-1 1.5]
polys=[1 2 3 4;1 5 6 7]

test4
points=[-1 1;-1 -1;1 -1;1 1 ;0.8 0.9;1 1.5;0.5 1.7;0 1.6;-0.5 1.7]
polys=[1 2 3 4;5 6 7 8;5 8 9 1]
=#



"""选择需要T3translate的顶点和单元\n
output:point=>(cellid,edgeid in cell)\n
表示point这个点在cellid单元里面，并且离第edgeid最近
"""
function T3candates(cell,pointcell)
    candatep=findall(x->length(x)<3,pointcell)#只有两个单元相邻的节点
    candatec=unique(vcat([pointcell[i] for i in candatep]...))#边缘单元

    candate=Dict();#节点=>单元id,距离最近的边;该节点在单元里面
    for i in candatec
        for j in candatep
            a=judgePoly(j,cell[i].p)
            if a[1]==1 #The point j are inside the cell i
                push!(candate,j=>(i,a[2]))
            end
        end
    end
    return candate
end

"""T3 translate"""
function T3trans!(cell,candate,pointcell)

    for i in keys(candate)
        #judge
        if length(pointcell[i])==1
            inv=cell[pointcell[i]...]#入侵单元
            beinv=cell[candate[i][1]]#被入侵单元
            judge=indexin(inv.p,beinv.p)#两单元是否有相同的节点
            numj=findall(x->x!==nothing,judge)
        elseif length(pointcell[i])==2
            inv1=cell[pointcell[i][1]]
            inv2=cell[pointcell[i][2]]
            beinv=cell[candate[i][1]]
            judge1=indexin(inv1.p,beinv.p)#两单元是否有相同的节点
            judge2=indexin(inv2.p,beinv.p)#两单元是否有相同的节点
            numj1=findall(x->x!==nothing,judge1)#表示inv1.p的第numj1个元素是共同点
            numj2=findall(x->x!==nothing,judge2)
        else
            @error " 超出4种情况，检查点$i "
        end
        ########################################################################
        if length(pointcell[i])==1 && numj==[]####第一种情况
            a=candate[i]
            if a[2]==length(cell[a[1]].p)
                b=1
            else
                b=a[2]+1
            end
            l1=[cell[a[1]].p[a[2]];cell[a[1]].p[b]] #点穿过的那条直线
            cen=pointToLine(i,l1)#入侵点与直线的垂线交点 o
            p1,p2=lineCircle(cen,dsep/2,l1)#以垂线交点为中心，在直线l1上两端各dsep/2距离的点坐标

            if Leng(cen,[l1[1].x,l1[1].y]) <= dsep+dsep/2  #交点与线段第一个点距离,如果小于3/2dsep就用第一个点
                px1=l1[1]
            else#否则新建一个点p1或者p2
                v1=VectorPro([i.x,i.y],cen,[i.x,i.y],[l1[1].x,l1[1].y])#io❌i l1[1]
                v2=VectorPro([i.x,i.y],cen,[i.x,i.y],p1)
                global np=np+1
                v1*v2>0 ? px1=Pointc(np,p1[1],p1[2],0) : px1=Pointc(np,p2[1],p2[2],0)
            end

            if Leng(cen,[l1[2].x,l1[2].y]) <= dsep+dsep/2  #交点与线段第2个点距离,如果小于3/2dsep就用第一个点
                px2=l1[2]
            else#否则新建一个点p1或者p2
                v1=VectorPro([i.x,i.y],cen,[i.x,i.y],[l1[2].x,l1[2].y])
                v2=VectorPro([i.x,i.y],cen,[i.x,i.y],p1)
                global np=np+1
                v1*v2>0 ? px2=Pointc(np,p1[1],p1[2],0) : px2=Pointc(np,p2[1],p2[2],0)
            end

            #pointcell[i]为入侵单元id candate[i][1]为被入侵单元id
            pid=findall(x->x==i,cell[pointcell[i][1]].p)#入侵点在入侵单元的位置
            deleteat!(cell[pointcell[i][1]].p,pid)#删除入侵节点
            push!(cell[pointcell[i][1]].p,px2,px1)
            cell[pointcell[i][1]].p=CCW(cell[pointcell[i][1]].p)

            push!(cell[a[1]].p,px1,px2)
            unique!(cell[a[1]].p)
            cell[a[1]].p=CCW(cell[a[1]].p)


            ##########################################################
        elseif length(pointcell[i])==2 && numj1==[] && numj2==[]######二
            a=candate[i]
            if a[2]==length(cell[a[1]].p)
                b=1
            else
                b=a[2]+1
            end
            l1=[cell[a[1]].p[a[2]];cell[a[1]].p[b]] #点穿过的边
            l2= intersect(inv1.p,inv2.p)#两个入侵单元的公共边
            cen=segmentToSegment(l1,l2)#l1与l2交点
            
            p1,p2=lineCircle(cen,dsep,l1)#以垂线交点为中心，在直线l1上两端各dsep距离的点坐标
            v1=VectorPro([i.x,i.y],cen,[i.x,i.y],[l1[1].x,l1[1].y])#io❌i l1[1]
            v2=VectorPro([i.x,i.y],cen,[i.x,i.y],p1)

            lo1=Leng(cen,[l1[1].x,l1[1].y])#点o到l1[1]的距离
            if lo1 < dsep#如果l1[1]这一边距离<dsep，将l1[1]往外移动
               if v1*v2 >0
                    l1[1].x=p1[1]
                    l1[1].y=p1[2]
               else
                    l1[1].x=p2[1]
                    l1[1].y=p2[2]
               end 
                px1=l1[1]
            elseif lo1>=dsep && lo1<2*dsep
                px1=l1[1]
            elseif lo1>=2*dsep
                global np=np+1
                v1*v2>0 ? px1=Pointc(np,p1[1],p1[2],0) : px1=Pointc(np,p2[1],p2[2],0)
            else @error " "
            end

            lo2=Leng(cen,[l1[2].x,l1[2].y])#点o到l1[2]的距离
            if lo2 < dsep#如果l1[2]这一边距离<dsep，将l1[2]往外移动
                if v1*v2 >0 
                    l1[2].x=p2[1]
                    l1[2].y=p2[2]
                else
                    l1[2].x=p1[1]
                    l1[2].y=p1[2]
                end
                px2=l1[2]
            elseif lo2>=dsep && lo2<2*dsep
                px2=l1[2]
            elseif lo2>=2*dsep
                global np=np+1
                v1*v2>0 ? px2=Pointc(np,p2[1],p2[2],0) : px2=Pointc(np,p1[1],p1[2],0)
            else @error " "
            end

            global np=np+1
            cenp=Pointc(np,cen[1],cen[2],0)
            #判断哪个单元用哪个点
            ceninv1=cenpoly(inv1.p)#第一个入侵单元形心
            v3=VectorPro([i.x,i.y],cen,[i.x,i.y],ceninv1)#io叉乘i_ceninv1
            if v1*v3>0 #inv1与l1一侧
                invpx1=px1
                invpx2=px2
            else
                invpx1=px2
                invpx2=px1
            end
            
            pid=findall(x->x==i,cell[pointcell[i][1]].p)#入侵点在入侵单元的位置
            deleteat!(cell[pointcell[i][1]].p,pid)#删除入侵节点
            push!(cell[pointcell[i][1]].p,cenp,invpx1)
            cell[pointcell[i][1]].p=CCW(cell[pointcell[i][1]].p)

            pid=findall(x->x==i,cell[pointcell[i][2]].p)#入侵点在入侵单元的位置
            deleteat!(cell[pointcell[i][2]].p,pid)#删除入侵节点
            push!(cell[pointcell[i][2]].p,cenp,invpx2)
            cell[pointcell[i][2]].p=CCW(cell[pointcell[i][2]].p)

            push!(cell[a[1]].p,px1,px2,cenp)
            unique!(cell[a[1]].p)
            cell[a[1]].p=CCW(cell[a[1]].p)

            ##########################################
        elseif length(pointcell[i])==1 && numj!==[]######三
            a=candate[i]
            if a[2]==length(cell[a[1]].p)
                b=1
            else
                b=a[2]+1
            end
            l1=[cell[a[1]].p[a[2]];cell[a[1]].p[b]] 
            compi=inv.p[numj...]##共同点
            cen=pointToLine(i,l1)#入侵点与直线的垂线交点 o
            if compi in l1
                non=findall(x->x!=compi,l1)
                nonpi=[l1[non...].x,l1[non...].y]
                L=Leng(nonpi,cen)
                if L<dsep
                     #以non为中心，在直线l1上两端各dsep距离的点坐标
                    p1,p2=lineCircle(nonpi,dsep,l1)
                    v1=VectorPro([i.x,i.y],nonpi,[i.x,i.y],[compi.x,compi.y])#i_non ❌i_compi
                    v2=VectorPro([i.x,i.y],nonpi,[i.x,i.y],p1)
                    v1*v2>0 ? cen=p1 : cen=p2
                end

                compi.x=cen[1]
                compi.y=cen[2]

            else @error "检查穿过的边l1与$(i)的位置 "
            end

            deleteat!(inv.p,findall(x->x==i,inv.p))

        ##########################################################
        elseif length(pointcell[i])==2 && numj1!==[] || numj2!==[]######四
            #选择与被入侵单元连接的入侵单元
            if numj1==[] && numj2!==[]
                cominv=cell[pointcell[i][2]]#有共同点的入侵单元
                uninv=cell[pointcell[i][1]]#没有共同点的入侵单元
                compi=cominv.p[numj2[1]]#共同点
            elseif numj2==[] && numj1!==[]
                cominv=cell[pointcell[i][1]]
                uninv=cell[pointcell[i][2]]
                compi=cominv.p[numj1[1]]
            else @error " error"
            end

            #
            a=candate[i]
            if a[2]==length(cell[a[1]].p)
                b=1
            else
                b=a[2]+1
            end
            l1=[cell[a[1]].p[a[2]];cell[a[1]].p[b]]#点穿过的边
            l2= intersect(inv1.p,inv2.p)#两个入侵单元的公共边
            cen=segmentToSegment(l1,l2)#l1与l2交点
            
            p1,p2=lineCircle(cen,dsep,l1)#以垂线交点为中心，在直线l1上两端各dsep距离的点坐标
            non=findall(x->x!=compi,l1)
            nonpi=[l1[non[1]].x,l1[non[1]].y]

            v1=VectorPro([i.x,i.y],cen,[i.x,i.y],[compi.x,compi.y])#io❌i l1[1]
            v2=VectorPro([i.x,i.y],cen,[i.x,i.y],p1)
           
            v1*v2>0 ? begin compi.x=p1[1];compi.y=p1[2] end : begin compi.x=p2[1];compi.y=p2[2] end
                
            lon=Leng(cen,nonpi)#cen与non点的距离
           if lon<dsep
            v1*v2>0 ? begin l1[non...].x=p2[1];l1[non...].y=p2[2] end : 
                        begin l1[non...].x=p1[1];l1[non...].y=p1[2] end
           end

            global np=np+1
            cenpi=Pointc(np,cen[1],cen[2],0.)

            push!(beinv.p,cenpi)
            beinv.p=CCW(beinv.p)
            push!(uninv.p,cenpi,compi)
            deleteat!(uninv.p,findall(x->x==i,uninv.p))
            uninv.p=CCW(uninv.p)
            deleteat!(cominv.p,findall(x->x==i,cominv.p))
        end
    end
    
end


