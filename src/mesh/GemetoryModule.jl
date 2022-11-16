#一些计算几何的函数



"""计算三角形单元外接圆圆心和半径"""
function CenterTri(i::Pointc,j::Pointc,k::Pointc,id::Int)
    ax=2*(k.y-j.y)*(j.x^2+j.y^2-i.x^2-i.y^2)-2*(j.y-i.y)*(k.x^2+k.y^2-j.x^2-j.y^2);
    bx=4*(k.y-j.y)*(j.x-i.x)-4*(j.y-i.y)*(k.x-j.x);
    x0=ax/bx;
    ay=-2*(k.x-j.x)*(j.x^2+j.y^2-i.x^2-i.y^2)+2*(j.x-i.x)*(k.x^2+k.y^2-j.x^2-j.y^2);
    y0=ay/bx;
    r=sqrt((i.x-x0)^2+(i.y-y0)^2);
    cen=Pointc(id,x0,y0,0);#id为这个三角形的id
    return cen,r
end

"""判断点与圆的位置;\n
p为要判断的点；cen为圆心点；r为半径;\n
由于点是由x坐标y坐标排序的所以按顺序输入点，只有这三种情况
"""
function JudgePoint(p::Pointc,cen::Pointc,r::Number)
    if p.x>cen.x+r   
        return 1 #点在圆右边
    elseif sqrt((p.x-cen.x)^2+(p.y-cen.y)^2)<=r
        return 0#点在圆内部
    elseif sqrt((p.x-cen.x)^2+(p.y-cen.y)^2)>r&&p.x<cen.x+r
        return -1#在上面
    end
end

"""
判定点p与三角形ele的位置关系;\n
在三角形内返回1，在三角形外返回(-1,point1,point2，point3)，点在point1、2一侧,point3是另一个点;\n
在三角形边上返回边(0,point1,point2,point3),其中1、2point是点所在边，point3是另一个点;
"""
function JudgeTri(p::Pointc,ele::TriEle)
    ij=[ele.j.x-ele.i.x,ele.j.y-ele.i.y]
    ip=[p.x-ele.i.x,p.y-ele.i.y]
    a=ij[1]*ip[2]-ij[2]*ip[1];#利用叉乘判断 ij叉乘ip

    jk=[ele.k.x-ele.j.x,ele.k.y-ele.j.y]
    jp=[p.x-ele.j.x,p.y-ele.j.y]
    b=jk[1]*jp[2]-jk[2]*jp[1];#利用叉乘判断 jk叉乘jp

    ki=[ele.i.x-ele.k.x,ele.i.y-ele.k.y]
    kp=[p.x-ele.k.x,p.y-ele.k.y]
    c=ki[1]*kp[2]-ki[2]*kp[1];#利用叉乘判断 ki叉乘kp

    if a>0&&b>0&&c>0||a<0&&b<0&&c<0#点在三角形内
        return 1
    elseif a==0                    #点在ij边上
        return 0,ele.i,ele.j,ele.k
    elseif b==0                    #点在jk边上
        return 0,ele.j,ele.k,ele.i
    elseif c==0                    #点在ki边上
        return 0,ele.k,ele.i,ele.j
    elseif a>0&&b>0&&c<0
        return -1,ele.k,ele.i,ele.j
    elseif a<0&&b>0&&c>0
        return -1,ele.i,ele.j,ele.k
    elseif a>0&&b<0&&c>0
        return -1,ele.j,ele.k,ele.i
    end
end

"""计算多边形面积\n
输入Poly类型"""
function Area(poly)
    p=poly.p;
    n=size(p,1);
    S=0;
    for i in 1:n
        if i < n    
            s=p[i].x*p[i+1].y-p[i].y*p[i+1].x
        elseif i==n
            s=p[i].x*p[1].y-p[i].y*p[1].x
        end
        S=S+s
    end
    S=S/2
    return S
end

"""计算多边形周长\n
输入p[point1; point2]"""
function peri(p::Vector)
    peri=0
    for i in 1:1:length(p)
        if i==length(p)
            peri=peri+Leng(p[i],p[1])
        else
            peri=peri+Leng(p[i],p[i+1])
        end
    end
    return peri
end

"""计算多边形周长"""
function peri(poly::Poly)
    p=poly.p;
    per=peri(p)
    return per
end

"""计算两点距离"""
function Leng(a::Pointc,b::Pointc)
    return sqrt((a.x-b.x)^2+(a.y-b.y)^2+(a.z-b.z)^2)
end

function Leng(a::Vector,b::Vector)
    return sqrt((a[1]-b[1])^2+(a[2]-b[2])^2)
end

"""
将一系列2D点逆时针排列;\n
输入点向量::Vector{Pointc}
"""
function CCW(p::Vector{Pointc})
    n=length(p);
    #计算质心坐标
    x0,y0=cenpoly(p)

    #计算各点相对于质心的极坐标角度
    newp=Matrix(undef,n,2);#初始化数组，第二列存点i在p的位置，第一列存极坐标角度
    for i in 1:n
        newp[i,1]=atan(p[i].y-y0,p[i].x-x0)
        newp[i,2]=i
    end
    newp=sortslices(newp,dims=1);#将newp排序
    point=Vector{Pointc}(undef,n)
    for i in 1:n
        point[i]=p[newp[i,2]]
    end
    return point
end


"""计算两向量叉乘"""
function VectorPro(p1::Pointc,p2::Pointc,p3::Pointc,p4::Pointc)
    pa=[p2.x-p1.x, p2.y-p1.y]
    pb=[p4.x-p3.x, p4.y-p3.y]
    result=pa[1]*pb[2]-pa[2]*pb[1]
    return result
end
"""计算两向量叉乘；输入点坐标\n
T可以是Vector:[x,y]  或者Tuple:(x,y)
"""
function VectorPro(p1,p2,p3,p4) 
    pa=[p2[1]-p1[1], p2[2]-p1[2]]
    pb=[p4[1]-p3[1], p4[2]-p3[2]]
    result=pa[1]*pb[2]-pa[2]*pb[1]
    return result
end
"""计算两向量叉乘；输入向量"""
function  VectorPro(pa::Vector,pb::Vector)
    result=pa[1]*pb[2]-pa[2]*pb[1]
    return result
end

"""
判断点是否在多边形内；\n
输入Point,[point1,point2....]类型\n
输出:如果为0--点在多边形边上;如果为1--点在多边形内部;如果为-1--点在多边形外
"""
function judgePoly(p::Pointc,ce::Vector)
    n=length(ce)#多边形点的个数
    jud=zeros(n)
    for i in 1:n
        if i<n
          b=i+1
        elseif i==n
          b=1
        end
        l1=[ce[b].x-ce[i].x; ce[b].y-ce[i].y; ce[b].z-ce[i].z]
        l2=[p.x-ce[i].x; p.y-ce[i].y; p.z-ce[i].z]
        a=VectorPro(l1,l2)
        jud[i]=a
    end
    #judge
    if findmin(jud)[1] == 0

        return 0,findall(x->x==0,jud)#点在边上，输出点落在第几条边(如果有两个数，表示与某个点重合)

    elseif findmin(jud)[1] >0
        ds=zeros(n)
        for i in 1:n
            if i<n
                b=i+1
            elseif i==n
                b=1
            end
            d=lengPtoLine(p,ce[i],ce[b])
            ds[i]=d
        end
        return 1, findmin(ds)[2] #点在多边形内,输出离点最近的边序号，有可能与多条边距离相等，输出第一条边

    elseif findmin(jud)[1] <0
        edge=findall(x->x<0,jud)

        return -1,edge #点在多边形外,输出位于那条边的一侧，如果edge有两个，则位于两条边之外的共同区域
    else
        return @error "others"
    end
end


"""点到直线距离\n
input:Pointc,[point1,point2]
"""
function lengPtoLine(p::Pointc,p1::Pointc,p2::Pointc)
    #直线ax + by + c = 0
    a=p1.y-p2.y
    b=p2.x-p1.x
    c=p1.x*p2.y-p2.x*p1.y

    d=abs(a*p.x+b*p.y+c)/sqrt(a^2+b^2)
    return d
end


"""点到直线距离\n
input:Pointc,[point1,point2]
"""
function lengPtoLine(p::Vector,p1::Pointc,p2::Pointc)
    #直线ax + by + c = 0
    a=p1.y-p2.y
    b=p2.x-p1.x
    c=p1.x*p2.y-p2.x*p1.y

    d=abs(a*p[1]+b*p[2]+c)/sqrt(a^2+b^2)
    return d
end

"""计算两个2D点的垂直平分线\n
返回两点中点往垂直平分线方向的dsep/2长度（双向都是d/2）\n
return  [x1 y1;
        x2  y2]
"""
function midnormal(p1::Pointc,p2::Pointc,d)
    k1=(p2.y-p1.y)/(p2.x-p1.x)
    k2=-1/k1
    midpoint=[(p1.x+p2.x)/2 ;(p1.y+p2.y)/2]#中点坐标
    if k2==-Inf || k2==Inf
        mid=[midpoint[1]; midpoint[2]+d/2]
        mod=[midpoint[1]; midpoint[2]-d/2]
    else
        k2=normalize([1,k2])
        mid=midpoint.+(d/2)*k2 
        mod=midpoint.-(d/2)*k2
    end
    
    return [mid'; mod']
end


"""
将线段p1,p2向垂直平分线方向各平移d距离\n
p1对应的两个点l1[1],l2[1];p2对应的两个点l1[2],l2[2]
"""
function midtrans(p1::Pointc,p2::Pointc,d)
    midline=midnormal(p1,p2,2d)
    midpoint=[(p1.x+p2.x)/2;(p1.y+p2.y)/2]
    dxy=midline-[midpoint';midpoint']#两个dx dy

    l1=[[p1.x+dxy[1,1] p1.y+dxy[1,2]];[p2.x+dxy[1,1] p2.y+dxy[1,2]]]
    l2=[[p1.x+dxy[2,1] p1.y+dxy[2,2]];[p2.x+dxy[2,1] p2.y+dxy[2,2]]]

    global np=np+1;
    p11=Pointc(np,l1[1],l1[3],0.);
    global np=np+1;
    p12=Pointc(np,l1[2],l1[4],0.);
    l1=[p11;p12]

    global np=np+1
    p21=Pointc(np,l2[1],l2[3],0.)
    global np=np+1
    p22=Pointc(np,l2[2],l2[4],0.)
    l2=[p21;p22]

    return l1,l2
end


"""计算多边形形心坐标\n
输入p[point1,point2....]"""
function cenpoly(p::Vector)
    x=0
    y=0
    for i in p
        x=x+i.x/length(p)
        y=y+i.y/length(p)
    end
    return [x,y]
end

"""计算多边形形心坐标\n
输入poly"""
function cenpoly(poly::Poly)
    p=poly.p
    cen=cenpoly(p)
    return cen
end

"""判断线段与直线是否相交\n
不相交返回[]，相交返回交点坐标\n
输入直线l[point1,point2],线段s[point1,point2]
"""
function lineToSegment(l,s)
    #若线段两点都在直线同一侧则没有交点，在直线两侧必有交点
    ls1=VectorPro(l[1],l[2],l[1],s[1])
    ls2=VectorPro(l[1],l[2],l[1],s[2])

    if ls1*ls2 > 0
        return []
    elseif ls1*ls2 < 0
        return lineToline(l,s)
    else    #如果有点刚好在直线上，则输出该点
        if ls1==0
            return s[1]
        elseif ls2==0
            return s[2]
        end
    end
end

"""两直线交点\n
输入直线l1[point1,point2],直线l2[point1,point2]"""
function lineToline(l1,l2)
    #直线ax + by + c = 0
    a1=l1[1].y-l1[2].y
    a2=l2[1].y-l2[2].y

    b1=l1[2].x-l1[1].x
    b2=l2[2].x-l2[1].x

    c1=l1[1].x*l1[2].y-l1[2].x*l1[1].y
    c2=l2[1].x*l2[2].y-l2[2].x*l2[1].y

    D=a1*b2-a2*b1
    if D==0
        return []
    else
        x=(b1*c2-b2*c1)/D
        y=(a2*c1-a1*c2)/D
        return [x,y]
    end
end

"""线段与线段交点\n
输入直线l1[point1,point2],直线l2[point1,point2]"""
function segmentToSegment(s1,s2)
    ss1=lineToSegment(s1,s2)
    if ss1==[]
        return []
    else
        ss2=lineToSegment(s2,s1)
        if ss2==[]
            return []
        else
            return ss2
        end
    end
end

"""点到直线的垂线交点\n
input:point,l[point1,point2]    \n
output:x,y
"""
function pointToLine(p1,l1)
    k1=(l1[2].y-l1[1].y)/(l1[2].x-l1[1].x)
    k2=1/k1
    if k2==Inf || k2==-Inf
        p2=Pointc(2,p1.x,p1.y+1,0)
    else
        p2=Pointc(2,p1.x+1,p1.y+k2,0)
    end
    
    lineToline([p1,p2],l1)
end

"""过圆心的直线与圆的交点\n
input:cen圆心坐标->[x,y],r->number>0,l1->[point1,point2]
output:
"""
function lineCircle(cen::Vector,r,l1::Vector)
    k1=(l1[2].y-l1[1].y)/(l1[2].x-l1[1].x)#the slope of global line(l1)
    x1=cen[1]+sqrt(r^2/(k1^2+1))#求解在直线l1上，点cen左右dsep/2长度的两个点
    y1=cen[2]+k1*(x1-cen[1])
    x2=cen[1]-sqrt(r^2/(k1^2+1))
    y2=cen[2]+k1*(x2-cen[1])
    return (x1,y1),(x2,y2)
end

