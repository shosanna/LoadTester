defmodule LoadTester.Mixfile do
  use Mix.Project

  def project do
    [app: :load_tester,
     version: "0.1.0",
     elixir: "~> 1.4",
     escript: [main_module: LoadTester.CLI], #1
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      mod: {LoadTester, []},
      applications: [:logger, :httpoison, :timex]
    ]
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
      {:httpoison, "~> 0.9.0"},
      {:timex, "~> 3.0"},
      {:tzdata, "~> 0.1.8", overide: true}
    ]
  end
end
