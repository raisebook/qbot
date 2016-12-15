defmodule QBot.Mixfile do
  use Mix.Project

  def project do
    [app: :qbot,
     version: "0.1.0",
     elixir: "~> 1.3",
     preferred_cli_env: [espec: :test],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :logger_papertrail_backend, :rollbax, :apex],
     mod: {QBot, []}]
  end

  defp deps do
    [
      {:ex_aws, "~> 1.0.0-rc4"},
      {:distillery, "1.0.0"},
      {:logger_papertrail_backend, "0.1.1"},
      {:rollbax, "0.8.0"},
      {:dogma, "0.1.13", only: [:dev, :test, :lint]},
      {:credo, "0.5.3", only: [:dev, :test, :lint]},
      {:espec, "1.2.0", only: :test,  app: false},
      {:apex, "0.6.0"},
      {:codeclimate_credo, git: "https://github.com/fazibear/codeclimate-credo",
                           branch: "master", only: [:dev, :test] },
    ]
  end
end
