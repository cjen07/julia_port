defmodule GenFunction do
  defmacro __using__(opts) do
    Enum.map(opts, fn {name, arity} ->
      args = Enum.map(0..arity+1, &Macro.var(:"a#{&1}", __MODULE__))
      quote do
        def unquote(name)(unquote_splicing(args)) do
          [a0 | [ a1 | args ]] = [unquote_splicing(args)]
          s1 = to_string(a1)
          s2 = "=#{unquote(name)}("
          s3 = 
            case unquote(arity) do
              0 -> ""
              _ -> 
                args
                |> Enum.map(&(to_string(&1))) 
                |> Enum.join(",")
            end
          s4 = ")"
          s = s1 <> s2 <> s3 <> s4
          send a0, {self(), {:command, s <> "\n"}}
        end
      end
    end)
  end
end
