defmodule McsePicture.MixProject do
  use Mix.Project

  def project do
    [
      app: :mcse_picture,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {McsePicture.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oban, "~> 2.19"},
      {:ecto_sqlite3, "~> 0.12"},
      {:ecto, "~> 3.10"},
      {:igniter, "~> 0.1", only: [:dev, :test]},
      {:tortoise311, "~> 0.12.1"},
      {:briefly, "~> 0.4"},
      {:jason, "~> 1.4"},
      {:astro, "~> 1.1"}
    ]
  end
end
