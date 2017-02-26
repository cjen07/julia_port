## julia_port
experiments on calling julia functions to do scientific computing in elixir using port

### prerequisite
* [julia](http://julialang.org/) installed and its access from shell

### usage
```
iex -S mix
port = JuliaPort.init
JuliaPort.simple_test port
JuliaPort.complex_test port
JuliaPort.terminate port
```

### to-do
- [ ] using otp application
- [ ] using metaprogramming to support more functions
- [ ] better interface of recieving message from julia
