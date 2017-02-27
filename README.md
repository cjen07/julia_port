## julia_port
experiments on calling julia functions to do scientific computing in elixir using port

### prerequisite
* [julia](http://julialang.org/) installed and its access from shell

### usage
* simple_test
```
def simple_test(port) do
  port_send(port, "1+2")
  port_receive(port, true)
end
```
* complex_test
```
use GenFunction, [rand: 2, sum: 1, *: 2]

def complex_test(port) do
  rand(port, :a, 3, 3)
  rand(port, :b, 3, 3)
  JuliaPort.*(port, :c, :a, :b)
  port_receive(port, false)
  sum(port, :d, :c)
  port_receive(port, true)
end
```
* run
```
iex -S mix
port = JuliaPort.init
# => #Port<0.5310>
JuliaPort.simple_test port
# => "received data: 3"
JuliaPort.complex_test port
# => "received data: 7.341049643572958"
JuliaPort.terminate port
# => {#PID<0.143.0>, :close}
```

### to-do
- [ ] using otp application
- [x] using metaprogramming to support more functions
- [x] better interface of recieving message from julia
