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
    [applications: [
      :httpoison, :logger, :rollbax, :apex,
      :ex_aws, :ex_sqs_service, :sweet_xml, :poison, :config],
     mod: {QBot, []}]
  end

  defp deps do
    [
      {:apex, "~> 1.0.0"},
      {:config, github: "renderedtext/ex-config"},
      {:ex_aws, "~> 1.1"},
      {:ex_sqs_service, git: "https://github.com/raisebook/ex_sqs_service"},
      {:hackney, "~> 1.9.0", override: true},
      {:httpoison, "~> 0.13.0"},
      {:poison, "~> 3.1.0"},
      {:rollbax, "~> 0.8.1"},
      {:sweet_xml, "~> 0.6.5"},

      {:distillery, "~> 1.4"},
      {:dogma, "~> 0.1.14", only: [:dev, :test, :lint]},
      {:credo, "~> 0.8.1", only: [:dev, :test, :lint]},
      {:espec, "~> 1.4", only: :test,  app: false, env: :test,
        git: "https://github.com/joffotron/espec", branch: "passthrough-mix-options"},
    ]
  end
end
