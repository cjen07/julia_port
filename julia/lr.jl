using DelimitedFiles
function load_data(f :: String)
  a = open(readdlm, f)
  x2 = a[a[:,1] .== 2, 2:end]
  x3 = a[a[:,1] .== 3, 2:end]
  y2 = ones(size(x2,1))
  y3 = (-1)*ones(size(x3,1))
  x = vcat(x2, x3)
  x = hcat(ones(size(x,1)), x)
  y = vcat(y2, y3)
  (x, y)
end

function lr_train(x_train :: Array{Float64,2}, y_train :: Array{Float64,1})
  inv(transpose(x_train) * x_train) * (transpose(x_train) * y_train)
end

function lr_test(x_test :: Array{Float64,2}, y_test :: Array{Float64,1}, beta :: Array{Float64,1})
  y_result = x_test * beta
  y_compare = y_result .* y_test
  length(y_compare[y_compare .> 0]) / length(y_result)
end
