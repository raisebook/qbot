use Mix.Config

config :qbot,
  workers_per_queue: 1,
  aws_stack: "development",
  config_poll_delay_sec: 120

config :rollbax,
  access_token: "unset-for-dev-we-only-log",
  environment: "development",
  enabled: :log

config :ex_aws,
  sqs:            %{port: 443},
  cloudformation: %{port: 443},
  lambda:         %{port: 443}

import_config "#{Mix.env}.exs"
