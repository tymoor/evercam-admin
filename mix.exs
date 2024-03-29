defmodule EvercamAdmin.MixProject do
  use Mix.Project

  def project do
    [
      app: :evercam_admin,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {EvercamAdmin.Application, []},
      extra_applications: [:logger, :runtime_tools, :poison]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:dotenv, "~> 3.0.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:evercam_models, github: "evercam/evercam_models"},
      {:comeonin, "~> 5.1"},
      {:bcrypt_elixir, "~> 2.0"},
      {:floki, "~> 0.23.0"},
      {:calendar, "~> 1.0.0", override: true},
      {:httpoison, "~> 1.5"},
      {:sweet_xml, "~> 0.6.6"},
      {:sshex, "~> 2.2"},
      {:telemetry, "~> 0.4.0", override: true},
      {:poison, "~> 3.1.0", override: true}
    ]
  end
end
