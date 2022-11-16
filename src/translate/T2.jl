#t2变换，将面积较小的的单元删除

function cellArea(cell)
  cellarea=Dict()
  for i in collect(keys(cell))
      if length(cell[i].p)<=3
        a=Area(cell[i])
        push!(cellarea,i=>a)
      end
  end
  return cellarea
end

"""找到符合T2变换的单元\n
输入多边形id=>Area的Dict结构,thea删除的面积大小，默认0.001
"""
function cellsForT2(cell)
  cellarea=cellArea(cell)
  rcell=findall(x-> x<=thearea,cellarea)

  return rcell
end

"""T2变换"""
function T2Trans!(rcell,cell,node)
  ##计算待删除单元的形心点坐标
  centnode=Dict()
  repoint=Dict()#需要替换的节点，待替换=>替换结果
  for i in rcell#需要删除的单元编号
    n=length(cell[i].p)
    x=[cell[i].p[j].x for j in 1:n]
    y=[cell[i].p[j].y for j in 1:n]
    z=[cell[i].p[j].z for j in 1:n]
    x=sum(x)/n
    y=sum(y)/n
    z=sum(z)/n
    global np=np+1
    cennode=Pointc(np, x, y, z)
    push!(centnode,length(node)+i=>cennode)

    for j in cell[i].p
      push!(repoint,j=>cennode)
    end
  end

  ##用形心代替删除单元的所有节点
  for i in collect(keys(repoint))#为需要替换的节点
    for j in collect(values(cell))#在所有单元中找需要替换的节点
      nu=findall(x->x==i,j.p)#找到需要替换的节点位置（在j中）
      if nu!=[]
        j.p[nu[1]]=repoint[i]#替换节点
      end
      unique!(j.p)
    end

   #=  #在node中删除节点和添加新的节点
    k=findall(x->x==i,node)#返回删除节点在node中的key值
    delete!(node,k)
    merge(node,centnode)#合并两个节点字典 =#
  end

  #删除单元
  for i in rcell
    delete!(cell,i)
  end

  return cell,node
end



