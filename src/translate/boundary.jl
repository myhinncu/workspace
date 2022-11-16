#=
    此文件存放约束单元节点函数
    created by chen xuefei 
    time: 2022-6-19
=#

"""将单元限制于一个矩形内\n
wallpoint
"""
function boundrect!(rect::Vector,wallpoint)
    n=length(rect)#n边形
    for i in wallpoint
        jud,edge=judgePoly(i,rect)
        if jud==-1 && size(edge,1)==1#在多边形外,且位于一条边的一侧
            edge[1]==n ? b=1 : b=edge[1]+1
            cen=pointToLine(i,[rect[edge[1]],rect[b]])
            i.x=cen[1]
            i.y=cen[2]
        elseif jud==-1 && size(edge,1)==2#点在多边形外，且位于两条边外
            edge[1]==n ? b1=1 : b1=edge[1]+1
            edge[2]==n ? b2=1 : b2=edge[2]+1
            p=intersect([edge[1];b1],[edge[2];b2])
            i.x=rect[p...].x
            i.y=rect[p...].y
        end
    end
    
end


"""通过两点生成矩形多边形\n
input:左上点坐标p1，右下点坐标p2"""
function rectpoly(p1,p2)
    #将矩形看成一个多边形
   return rect=Poly(0,[Pointc(-1,p1[1],p1[2],0.); Pointc(-2,p1[1],p2[2],0.);
        Pointc(-3,p2[1],p2[2],0.); Pointc(-4,p2[1],p1[2],0.)])
end

"""获取包围所有点的矩形四个边界\n
返回左上角和右下角坐标[x0,y0]坐标"""
function rectpi(points)
    xmin=findmin(points[:,1])[1];
    xmax=findmax(points[:,1])[1];
    ymin=findmin(points[:,2])[1];
    ymax=findmax(points[:,2])[1];
    return [xmin,ymax],[xmax,ymin]
end
