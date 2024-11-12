defmodule Kore.MixProject do
  use Mix.Project

  def project do
    [
      app: :kore,
      version: "0.1.0",
      elixir: "~> 1.17",
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
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:decimal, "~> 2.1"},
      {:swoosh, "~> 1.3"},
      {:hackney, "~> 1.9"},
      {:chromic_pdf, "~> 1.15"},
      {:phoenix, "~> 1.7.11"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_view, "~> 0.20.17"},
      {:time_zone_info, "~> 0.7"},
      {:ecto, "~> 3.11"},
      {:jason, "~> 1.4"}
    ]
  end
end
