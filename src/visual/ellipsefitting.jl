#=
    最小二乘法拟合椭圆
    time：2022-10-11
    created by：chen xuefei
    
=# 
using LinearAlgebra

"""
椭圆拟合参数求解-最小二乘法\n
example:测试数据\n
    theta=0:0.05:2pi;
    w=0.1;#noise
    x=2*cos.(theta)+w*rand(length(theta));
    y=sin.(theta)+w*rand(length(theta));
    u=[x y]
"""
function ellipsefit(u)::Vector
    x=u[:,1];
    y=u[:,2];
    #构造矩阵
    D=[x.^2 x.*y y.^2 x y ones(length(x))];
    S=D'*D;

    C=zeros(6,6);
    C[1,3]=2;C[2,2]=-1;C[3,1]=2;

    #求特征值和特征向量
    val,vec=eigen(S\C);
    ind=findall(x->x>0,val);
    W=vec[:,ind];
    W=sqrt(1/((W'*S*W)...))*W;
    W=vcat(W...)
    #W=[a;b;c;d;e;f]

    return W
end

"""计算椭圆几何参数\n
input:[a,b,c,d,e,f]\n
output:cx,cy,mar,mir,theta 中心点x，y，长轴mar，短轴mir，长轴倾角theta
"""
function ellipsepara(W)
    a,b,c,d,e,f=W;

    #椭圆中心
    cx=(b*e-2c*d)/(4a*c-b^2);
    cy=(b*d-2a*e)/(4a*c-b^2);

    #长短轴
    mar=sqrt(2*(a*cx^2+c*cy^2+b*cx*cy-f)/(a+c+sqrt((a-c)^2+b^2)));
    mir=sqrt(2*(a*cx^2+c*cy^2+b*cx*cy-f)/(a+c-sqrt((a-c)^2+b^2)));

    #长轴倾角
    if b==0
        if f*a>f*c
            theta=0;
        else
            theta=pi/2;
        end
    else
        if f*a>f*c
            alpha=atan((a-c)/b);
            if alpha<0
                theta=0.5*(-pi/2-alpha)
            else
                theta=0.5*(pi/2-alpha)
            end
        else
            alpha=atan((a-c)/b);
            if alpha<0
                theta=pi/2+0.5*(-pi/2-alpha)
            else
                theta=pi/2+0.5*(pi/2-alpha)
            end
        end
        
    end

    return cx,cy,max(mar,mir),min(mar,mir),theta
end

"""得到椭圆点\n
input:中心点cx，cy，长轴mar，短轴mir，长轴倾角theta
"""
function getellipsepoints(cx, cy, mar, mir, θ)
	t = range(0, 2*pi, length=100)
	ellipse_x_r = @. mar * cos(t)
	ellipse_y_r = @. mir * sin(t)
	R = [cos(θ) sin(θ); -sin(θ) cos(θ)]
	r_ellipse = [ellipse_x_r ellipse_y_r] * R
	x = @. cx + r_ellipse[:,1]
	y = @. cy + r_ellipse[:,2]
	return x,y
end

#=椭圆曲线拟合示例
    using CairoMakie
    theta=0:0.05:2pi;
    w=0.1;#noise
    x=2*cos.(theta)+w*rand(length(theta));
    y=sin.(theta)+w*rand(length(theta));
    u=[x y]
    f = Figure();
    ax = Axis(f[1, 1]);
    scatter!(ax,x, y);

    W=ellipsefit(u);
    cx,cy,mar,mir,theta=ellipsepara(W);
    x0,y0=getellipsepoints(cx, cy, mar, mir, theta);
    lines!(ax,x0,y0)
    f
=#
