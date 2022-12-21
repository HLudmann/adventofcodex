defmodule AdventOfCodex.MixProject do
  use Mix.Project

  def project do
    [
      app: :advent_of_codex,
      version: "0.2.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:eastar, "~> 0.5.1"},
      {:nx, "~> 0.2"},
      {:progress_bar, "> 0.0.0"}
    ]
  end
end
