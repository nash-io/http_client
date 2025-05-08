defmodule HttpClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :http_client,
      version: "0.2.5",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      package: package(),
      description: description(),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true,
        plt_core_path: "priv/plts/",
        plt_add_apps: [:mix]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {HttpClient.Application, []}]
  end

  defp deps do
    [
      {:httpoison, "~> 1.5"},
      {:telemetry, "~> 0.4.0 or ~> 1.0"},
      {:ex2ms, "~> 1.6.1"},
      {:mox, "~> 0.5", only: :test},
      {:excoveralls, "~> 0.12", only: [:test]},
      {:ex_unit_sonarqube, "~> 0.1.2", only: [:dev, :test]},
      {:credo, "~> 1.0", runtime: false, only: [:dev]},
      {:git_hooks, "~> 0.3", runtime: false, only: [:dev]},
      {:dialyxir, "~> 1.0", runtime: false, only: [:dev]},
      {:sobelow, "~> 0.9", runtime: false, only: [:dev]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false, only: [:dev, :test]}
    ]
  end

  defp description do
    "Httpoison boosted with telemetry, mox and rate limit."
  end

  defp package do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "http_client",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/nash-io/http_client"}
    ]
  end
end
