defmodule JuliaPort do
  use GenFunction, [rand: 2, sum: 1, *: 2]

  require Logger

  def init() do
    Port.open({:spawn, "julia"}, [:binary])
  end

  def terminate(port) do
    send port, {self(), :close}
  end

  def simple_test(port) do
    port_send(port, "1+2")
    port_receive(port, true)
  end

  def complex_test(port) do
    rand(port, :a, 3, 3)
    rand(port, :b, 3, 3)
    JuliaPort.*(port, :c, :a, :b)
    port_receive(port, false)
    sum(port, :d, :c)
    port_receive(port, true)
  end

  defp port_send(port, command) do
    send port, {self(), {:command, command <> "\n"}}
  end

  defp port_receive(port, verbose?) do
    port_send(port, ":f")
    loop(verbose?, "")
  end

  defp loop(verbose?, data) do
    receive do
      {_pid, {:data, raw}} ->
        data_new = String.trim(raw)
        cond do
          String.contains? data_new, "f" ->
            if verbose?, do: "received data: " <> data
          data_new == ":" or data_new == "" -> 
            loop(verbose?, data)
          true ->
            loop(verbose?, data <> data_new)
        end
      _ -> raise "receive error"
    end
  end
end