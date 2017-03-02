## julia_port
experiments on calling julia functions to do scientific computing in elixir using port and metaprogramming

### prerequisite
* [julia](http://julialang.org/) installed and its access from shell
* in real_test: [`BackpropNeuralNet`](https://github.com/compressed/BackpropNeuralNet.jl) installed

### usage
* simple_test: arithmetics 
```elixir
def simple_test(port) do
  port_send(port, "1+2")
  IO.puts port_receive(port, true)
end
```
* complex_test: linear algebra
```elixir
use GenFunction, [rand: 2, sum: 1, *: 2]

def complex_test(port) do
  rand(port, :a, 3, 3)
  rand(port, :b, 3, 3)
  JuliaPort.*(port, :c, :a, :b)
  port_receive(port, false)
  sum(port, :d, :c)
  IO.puts port_receive(port, true)
end
```
* real_test: neural network
```elixir
use GenFunction, [init_network: 1, train: 3, net_eval: 2]

def real_test(port) do
  port_send(port, "using BackpropNeuralNet")
  init_network(port, :net, [2, 3, 2])
  port_receive(port, false)
  train(port, :result1, :net, [0.15, 0.7], [0.1, 0.9])
  IO.puts port_receive(port, true)
  net_eval(port, :result2, :net, [0.15, 0.7])
  IO.puts port_receive(port, true)
end
```
* run
```elixir
iex -S mix
port = JuliaPort.init
# => #Port<0.5310>
JuliaPort.simple_test port
# => received data: 3
JuliaPort.complex_test port
# => received data: 5.710327361153192
JuliaPort.real_test port
# => received data: 0.09117138901807831
# => received data: 2-element Array{Float64,1}: 0.381892 0.592638
JuliaPort.terminate port
# => {#PID<0.143.0>, :close}
```

### to-do
- [x] using metaprogramming to support more functions
- [x] better interface of communicating with julia
- [x] potentially computational intensive real problem
- [ ] support more julia [syntax](https://en.wikibooks.org/wiki/Introducing_Julia/Arrays_and_tuples)
- [ ] publish it in hex  
- [ ] build a real-world project with it
