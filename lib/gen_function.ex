defmodule JuliaPort.GenFunction do
  @moduledoc """
  extensible interface of julia function definition in elixir using macro 
  """

  @doc ~S"""
  the macro to define functions with dynamic name and arity 
  """
  defmacro __using__(opts) do
    Enum.map(opts, fn {name, arity} ->
      args = Enum.map(0..(arity + 1), &Macro.var(:"a#{&1}", __MODULE__))

      quote do
        @doc """
        helper function defined in GenFunction
        """
        def unquote(name)(unquote_splicing(args)) do
          [a0 | [a1 | args]] = [unquote_splicing(args)]

          s1 =
            cond do
              is_tuple(a1) ->
                "(" <> (Tuple.to_list(a1) |> Enum.map(&to_string(&1)) |> Enum.join(",")) <> ")"

              true ->
                to_string(a1)
            end

          s2 = "=#{unquote(name)}("

          s3 =
            case unquote(arity) do
              0 ->
                ""

              _ ->
                args
                |> Enum.map(fn arg ->
                  cond do
                    is_list(arg) ->
                      "[" <> (Enum.map(arg, &to_string(&1)) |> Enum.join(",")) <> "]"

                    is_bitstring(arg) ->
                      "\"" <> arg <> "\""

                    true ->
                      to_string(arg)
                  end
                end)
                |> Enum.join(",")
            end

          s4 = ")"
          s = s1 <> s2 <> s3 <> s4
          send(a0, {self(), {:command, s <> "\n"}})
        end
      end
    end)
  end
end
