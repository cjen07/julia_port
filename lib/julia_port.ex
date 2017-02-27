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
    port_send("1+2", port)
    port_receive(true)
  end

  def complex_test(port) do
    rand(port, :a, 3, 3)
    rand(port, :b, 3, 3)
    JuliaPort.*(port, :c, :a, :b)
    port_receive()
    sum(port, :d, :c)
    port_receive(true)
  end

  defp port_send(command, port) do
    send port, {self(), {:command, command <> "\n"}}
  end

  defp port_receive(verbose? \\ false) do
    receive do
      {_pid, {:data, data}} ->
        if verbose?, do: Logger.debug "received data: #{inspect(data)}"
        port_receive()
      _ -> raise "receive error"
    after
      2000 -> :ok
    end
  end
end