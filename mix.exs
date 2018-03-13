defmodule QBot.Mixfile do
  use Mix.Project

  def project do
    [app: :qbot,
     version: "0.1.0",
     elixir: "~> 1.5",
     preferred_cli_env: [espec: :test],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [
      :httpoison, :logger, :rollbax, :apex, :flex_logger,
      :ex_aws, :ex_sqs_service, :ex_aws_sqs, :ex_aws_lambda, :ex_aws_cloudformation, :ex_aws_kms,
      :sweet_xml, :poison, :config],
     mod: {QBot, []}]
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
      {:hackney, "~> 1.11.0"},
      {:httpoison, "~> 1.0.0"},
      {:poison, "~> 3.1.0"},
      {:rollbax, "~> 0.9.1"},
      {:sweet_xml, "~> 0.6.5"},

      {:distillery, "~> 1.4"},
      {:credo, "~> 0.8.1", only: [:dev, :test, :lint]},
      {:espec, "~> 1.5.0", only: :test,  app: false, env: :test},
    ]
  end
end
