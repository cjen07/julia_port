defmodule JuliaPort do

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
    rand(:a, {3,3}, port)
    rand(:b, {3,3}, port)
    mul(:c, :a, :b, port)
    port_receive()
    sum(:d, :c, port)
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

  defp rand(var, dims, port) do
    s1 = to_string(var)
    s2 = "=rand("
    s3 = 
      case dims do
        {m, n} -> to_string(m) <> "," <> to_string(n)
        n -> to_string(n)
      end
    s4 = ")"
    s = s1 <> s2 <> s3 <> s4
    port_send(s, port)
  end

  defp mul(var0, var1, var2, port) do
    s1 = to_string(var0)
    s2 = "="
    s3 = to_string(var1) <> "*" <> to_string(var2)
    s = s1 <> s2 <> s3
    port_send(s, port)
  end

  defp sum(var0, var1, port) do
    s1 = to_string(var0)
    s2 = "=sum("
    s3 = to_string(var1)
    s4 = ")"
    s = s1 <> s2 <> s3 <> s4
    port_send(s, port)
  end

end
