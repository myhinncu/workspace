#=
    用于删除、减少结果文件数量
    time：2022-10-31
    created by：chen xuefei
   
=#


path="$(pwd())\\example\\result"
num=length(readdir(path))

for i in 1:1:num
    rm("$(path)\\fracture_static_normalization_$(i).vtp")
end

for i in readdir(path)
    rm("$(path)\\$i")
end


rm("$(path)";recursive=true)
