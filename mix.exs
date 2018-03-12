defmodule Turtles.Mixfile do
  use Mix.Project

  def project do
    [
      app: :turtles,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Turtles.Application, []},
      applications: [:gen_state_machine, :httpotion]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:cowboy, "~> 1.1"},
      {:plug, "~> 1.4"},
      {:gen_state_machine, "~> 2.0"},
      {:httpotion, "~> 3.1.0"},
      {:gen_pnet, "~> 0.1.7"}
    ]
  end
end
