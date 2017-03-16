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
      {:ex_aws, git: "https://github.com/raisebook/ex_aws", branch: "feature/cloudformation"},
      {:ex_sqs_service, git: "https://github.com/raisebook/ex_sqs_service"},
      {:sweet_xml, "~> 0.6.5"},
      {:poison, "3.1.0", override: true},
      {:httpoison, "~> 0.11.0"},
      {:distillery, "1.1.2"},
      {:config, github: "renderedtext/ex-config"},
      {:rollbax, "0.8.1"},
      {:dogma, "0.1.14", only: [:dev, :test, :lint]},
      {:credo, "0.6.1", only: [:dev, :test, :lint]},
      {:espec, "1.2.2", only: :test,  app: false},
      {:apex, "1.0.0"}
    ]
  end
end
