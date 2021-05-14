defmodule Arlix.MixProject do
  use Mix.Project

  def project do
    [
      app: :arlix,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ari, github: 'libreearth/ari'},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:neuron, "~> 5.0.0"}
    ]
  end
end
