defmodule JuliaPort.Mixfile do
  use Mix.Project

  def project do
    [
      app: :julia_port,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev},
      {:earmark, "~> 1.1", only: :dev}
    ]
  end

  defp description do
    """
    example project to invoke julia functions in elixir to do scientific computing using port and metaprogramming
    """
  end

  defp package do
    [
      files: ["data", "julia", "lib", "mix.exs", "README.md"],
      maintainers: ["Wang Chen"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/cjen07/julia_port",
        "Docs" => "http://hexdocs.pm/julia_port/"
      }
    ]
  end
end
