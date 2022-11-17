


"""生成规则的正六边形网格\n
m行n列个，半径为r的六边形阵列"""
function hexmesh(m::Int,n::Int,r,adress::String)
    cell=Matrix(undef,m,n)
    #创建第1、3、5、7...的中心坐标，从左上的【0，0】为起点
    point=Dict{Int,Vector}()
    hex=Vector{Int}(undef,6)
    for i in 1:2:n#列
        for j in 1:1:m#行
            center=[(i-1)*(r+r*cos(pi/3)); -(j-1)*2r*sin(pi/3)]  
            cellji=npoly(center[1],center[2],r,6)
            cell[j,i]=zeros(Int,6)
            if j==1
                for x in 1:1:6
                    id=length(point)+1
                    push!(point,id=>cellji[x,:])
                    cell[j,i][x]=id
                end
                 
            else
                for x in [1,4,5,6]
                    id=length(point)+1
                    push!(point,id=>cellji[x,:])
                    cell[j,i][x]=id
                    cell[j,i][2]=cell[j-1,i][6]
                    cell[j,i][3]=cell[j-1,i][5]
                end
            end
        end
    end

    #创建偶数列
    for i in 2:2:n
        for j in 1:1:m
            
            cell[j,i]=zeros(Int,6)
            if i==n#最后一列是偶数列
                center=[(i-1)*(r+r*cos(pi/3)); -(j-1)*2r*sin(pi/3)-r*sin(pi/3)]  
                cellji=npoly(center[1],center[2],r,6) 
                if j==1
                    id=length(point)+1
                    push!(point,id=>cellji[1,:],id+1=>cellji[2,:],id+2=>cellji[6,:])
                    cell[j,i]=[id,id+1, cell[j,i-1][1],  cell[j,i-1][6],  cell[j+1,i-1][1],id+2]
                elseif j==m
                    id=length(point)+1
                    push!(point,id=>cellji[1,:],id+1=>cellji[5,:],id+2=>cellji[6,:])
                    cell[j,i]=[id,cell[j-1,i][6], cell[j,i-1][1],  cell[j,i-1][6],  id+1,id+2]
                else
                    id=length(point)+1
                    push!(point,id=>cellji[1,:],id+1=>cellji[6,:])
                    cell[j,i]=[id, cell[j-1,i][6], cell[j,i-1][1],  cell[j,i-1][6],  cell[j+1,i-1][1],id+1]
                end
               
            else
                if j==m
                    center=[(i-1)*(r+r*cos(pi/3)); -(j-1)*2r*sin(pi/3)-r*sin(pi/3)]  
                    cellji=npoly(center[1],center[2],r,6)
                    id=length(point)+1
                    push!(point,id=>cellji[5,:],id+1=>cellji[6,:])

                    cell[j,i]=[cell[j,i+1][5], cell[j,i+1][4], cell[j,i-1][1],
                               cell[j,i-1][6], id, id+1]
                else
                    cell[j,i]=[cell[j,i+1][5], cell[j,i+1][4], cell[j,i-1][1],
                               cell[j,i-1][6], cell[j+1,i-1][1], cell[j+1,i+1][4]]
                end
               
            end
        end
        
    end
    #写入文件
    points=zeros(length(point),2)
    for i in 1:length(point)
        points[i,:]=values(point[i])
    end
    writedlm("$(adress)hexpoints.txt",points)
    writedlm("$(adress)hexcell.txt",[cell[i] for i in 1:m*n])
end

""" 生成一个正多边形\n
input:中心坐标下x，y，外接圆半径r,多边形边数n\n
output:"""
function npoly(x,y,r,n::Int)
    theta=2pi/n
    point=Matrix(undef,n,2)
    for i in 1:1:n
        point[i,1]=r*cos((i-1)*theta)+x
        point[i,2]=r*sin((i-1)*theta)+y
    end
    return point
end


