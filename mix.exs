defmodule QBot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :qbot,
      version: "0.1.0",
      elixir: "~> 1.5",
      preferred_cli_env: [espec: :test],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [mod: {QBot, []}]
  end

  defp deps do
    [
      {:apex, "~> 1.2.0"},
      {:config, github: "renderedtext/ex-config"},
      {:ex_aws, "~> 2.0.1"},
      {:ex_aws_sqs, "~> 2.0"},
      {:ex_aws_lambda, "~> 2.0"},
      {:ex_aws_kms, "~> 2.0"},
      {:ex_aws_cloudformation, "~> 2.0"},
      {:ex_sqs_service, git: "https://github.com/raisebook/ex_sqs_service", tag: "v0.2.1"},
      {:flex_logger, "~> 0.2.1"},
      {:hackney, "~> 1.12.1"},
      {:httpoison, "~> 1.1.1"},
      {:poison, "~> 3.1.0"},
      {:rollbax, "~> 0.9.2"},
      {:sweet_xml, "~> 0.6.5"},
      {:distillery, "~> 1.4", runtime: false},
      {:credo, "~> 0.9.3", only: [:dev, :test, :lint]},
      {:espec, "~> 1.5.0", only: :test, app: false, env: :test}
    ]
  end
end
