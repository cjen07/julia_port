defmodule JuliaPort do
  use GenFunction, [rand: 2, sum: 1, *: 2]
  use GenFunction, [init_network: 1, train: 3, net_eval: 2]
  use GenFunction, [load_data: 1, lr_train: 2, lr_test: 3]

  def init() do
    Port.open({:spawn, "julia"}, [:binary])
  end

  def terminate(port) do
    send port, {self(), :close}
  end

  def simple_test(port) do
    port_send(port, "1+2")
    IO.puts port_receive(port, true)
  end

  def complex_test(port) do
    rand(port, :a, 3, 3)
    rand(port, :b, 3, 3)
    JuliaPort.*(port, :c, :a, :b)
    port_receive(port, false)
    sum(port, :d, :c)
    IO.puts port_receive(port, true)
  end

  def real_test(port) do
    port_send(port, "using BackpropNeuralNet")
    init_network(port, :net, [2, 3, 2])
    port_receive(port, false)
    train(port, :result1, :net, [0.15, 0.7], [0.1, 0.9])
    IO.puts port_receive(port, true)
    net_eval(port, :result2, :net, [0.15, 0.7])
    IO.puts port_receive(port, true)
  end

  def script_test(port) do
    include_script(port, "./julia/lr.jl")
    load_data(port, {:x_train, :y_train}, "./data/train")
    load_data(port, {:x_test, :y_test}, "./data/test")
    lr_train(port, :beta, :x_train, :y_train)
    port_receive(port, false)
    lr_test(port, :error, :x_test, :y_test, :beta)
    IO.puts port_receive(port, true)
  end

  defp port_send(port, command) do
    send port, {self(), {:command, command <> "\n"}}
  end

  defp include_script(port, path) do
    port_send(port, "include(\"" <> path <> "\")")
  end

  defp port_receive(port, verbose?) do
    port_send(port, ":Ω")
    loop(verbose?, "")
  end

  defp loop(verbose?, data) do
    receive do
      {_pid, {:data, raw}} ->
        data_new = String.replace(raw, "\n", "ω") |> String.trim |>  String.replace("ω", " ")
        cond do
          String.contains? data_new, "Ω" ->
            if verbose?, do: "received data: " <> String.trim(data)
          data_new == ":" or data_new == "" -> 
            loop(verbose?, data)
          true ->
            loop(verbose?, data <> data_new)
        end
      _ -> raise "receive error"
    end
  end
end