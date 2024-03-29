defmodule PlugDeviseSession.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plug_devise_session,
      version: "1.0.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      aliases: aliases(),
      preferred_cli_env: [
        check: :test
      ],
      name: "PlugDeviseSession",
      description: "Simple plug for sharing Devise session in Elixir",
      source_url: "https://github.com/surgeventures/plug_devise_session",
      homepage_url: "https://github.com/surgeventures/plug_devise_session",
      docs: [main: "readme", extras: ["README.md"]]
    ]
  end

  defp package do
    [
      maintainers: ["Fresha"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/surgeventures/plug_devise_session"
      },
      files: ~w(mix.exs lib LICENSE.md README.md)
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      check: check_alias()
    ]
  end

  defp deps do
    [
      {:confix, "~> 0.1"},
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:ex_marshal, "~> 0.0.8"},
      {:junit_formatter, "~> 3.3", only: [:test]},
      {:plug, "~> 1.3.2 or ~> 1.4"},
      {:plug_rails_cookie_session_store, "~> 2.0"}
    ]
  end

  defp check_alias do
    [
      "compile --warnings-as-errors --force",
      "test",
      "credo --strict"
    ]
  end
end
