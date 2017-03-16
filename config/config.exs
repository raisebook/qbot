use Mix.Config

config :qbot,
  workers_per_queue:      {:system, "WORKERS_PER_QUEUE"},
  aws_stack:              {:system, "AWS_STACK"},
  config_poll_delay_sec:  {:system, "CONFIG_POLL_DELAY_SEC"}

config :rollbax,
  access_token: "unset-for-dev-we-only-log",
  environment: "development",
  enabled: :log

config :ex_aws,
  sqs:            %{port: 443},
  cloudformation: %{port: 443},
  lambda:         %{port: 443},
  region:         {:system, "AWS_REGION"}

import_config "#{Mix.env}.exs"
