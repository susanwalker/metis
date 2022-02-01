defmodule Metis.MixProject do
  use Mix.Project

  @version "0.1.0"
  @elixir_version "~> 1.12"

  def project do
    [
      aliases: aliases(),
      app: :metis,
      compilers: [:gettext] ++ Mix.compilers(),
      deps: deps(),
      elixir: @elixir_version,
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: @version
    ]
  end

  def application do
    [
      mod: {Metis.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Prod dependencies
      {:esbuild, "~> 0.3", runtime: Mix.env() == :dev},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_view, "~> 0.17.5"},
      {:phoenix, "~> 1.6.6"},
      {:plug_cowboy, "~> 2.5"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:tentacat, "~> 2.2.0"},

      # Dev and Test dependencies
      {:credo, "~> 1.5.6", only: :dev},
      {:excoveralls, "~> 0.14.2", only: ~w[dev test]a},
      {:exvcr, "~> 0.13.3", only: :test},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:sobelow, "~> 0.8", only: :dev}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
