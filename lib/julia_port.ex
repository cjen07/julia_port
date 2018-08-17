defmodule JuliaPort do
  @moduledoc """
  example project to invoke julia functions in elixir to do scientific computing using port and metaprogramming
  """
  alias JuliaPort.GenFunction

  use GenFunction, rand: 2, sum: 1, *: 2
  use GenFunction, init_network: 1, train: 3, net_eval: 2
  use GenFunction, load_data: 1, lr_train: 2, lr_test: 3

  @doc """
  open a port to start a julia process
  """
  def init() do
    Port.open({:spawn, "julia"}, [:binary])
  end

  @doc """
  close a port to end a julia process
  """
  def terminate(port) do
    send(port, {self(), :close})
  end

  @doc """
  example to print julia version
  """
  def print_version(port) do
    port_send(port, "VERSION")
    IO.puts(port_receive(port, true))
  end

  @doc """
  example to do arithmetics
  """
  def simple_test(port) do
    port_send(port, "1+2")
    IO.puts(port_receive(port, true))
  end

  @doc """
  example to do linear algebra
  """
  def complex_test(port) do
    rand(port, :a, 3, 3)
    rand(port, :b, 3, 3)
    JuliaPort.*(port, :c, :a, :b)
    port_receive(port, false)
    sum(port, :d, :c)
    IO.puts(port_receive(port, true))
  end

  @doc """
  example to do neural network

  prerequisite: [`BackpropNeuralNet`](https://github.com/compressed/BackpropNeuralNet.jl) installed
  """
  def real_test(port) do
    port_send(port, "using BackpropNeuralNet")
    init_network(port, :net, [2, 3, 2])
    port_receive(port, false)
    train(port, :result1, :net, [0.15, 0.7], [0.1, 0.9])
    IO.puts(port_receive(port, true))
    net_eval(port, :result2, :net, [0.15, 0.7])
    IO.puts(port_receive(port, true))
  end

  @doc """
  example to do linear regression
  """
  def script_test(port) do
    include_script(port, "./julia/lr.jl")
    load_data(port, {:x_train, :y_train}, "./data/train")
    load_data(port, {:x_test, :y_test}, "./data/test")
    lr_train(port, :beta, :x_train, :y_train)
    port_receive(port, false)
    lr_test(port, :error, :x_test, :y_test, :beta)
    IO.puts(port_receive(port, true))
  end

  @doc """
  send a command through a port
  """
  def port_send(port, command) do
    send(port, {self(), {:command, command <> "\n"}})
  end

  @doc """
  include a script in julia repl
  """
  def include_script(port, path) do
    port_send(port, "include(\"" <> path <> "\")")
  end

  @doc """
  recieve messages from a port

  remark: a trick to use Ω and ω as finished signal
  """
  def port_receive(port, verbose?) do
    port_send(port, ":Ω")
    loop(verbose?, "")
  end

  @doc """
  helper function to recieve messages

  remark: one may modify this function to customise output format
  """
  def loop(verbose?, data) do
    receive do
      {_pid, {:data, raw}} ->
        data_new = String.replace(raw, "\n", "ω") |> String.trim() |> String.replace("ω", " ")

        cond do
          String.contains?(data_new, "Ω") ->
            if verbose?, do: "received data: " <> String.trim(data)

          data_new == ":" or data_new == "" ->
            loop(verbose?, data)

          true ->
            loop(verbose?, data <> data_new)
        end

      _ ->
        raise "receive error"
    end
  end
end
