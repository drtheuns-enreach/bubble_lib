defmodule BubbleLib.MixProject do
  use Mix.Project

  def project do
    [
      app: :bubble_lib,
      version: File.read!("VERSION"),
      elixir: "~> 1.6",
      description: description(),
      package: package(),
      source_url: "https://github.com/botsquad/bubble_lib",
      homepage_url: "https://github.com/botsquad/bubble_lib",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp description do
    "Collection of utility functions for Botsquad's BubbleScript."
  end

  defp package do
    %{
      files: ["lib", "mix.exs", "*.md", "LICENSE", "VERSION"],
      maintainers: ["Arjan Scherpenisse"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/botsquad/bubble_lib"}
    }
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
      {:poison, "~> 3.0"},
      {:match_engine, "~> 1.0"}
    ]
  end
end
