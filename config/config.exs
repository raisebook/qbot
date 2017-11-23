use Mix.Config

config :qbot,
  workers_per_queue:      {:system, "WORKERS_PER_QUEUE"},
  aws_stacks:             {:system, "AWS_STACKS"},
  config_poll_delay_sec:  {:system, "CONFIG_POLL_DELAY_SEC"},
  only_queues:            {:system, "ONLY_QUEUES"}

config :rollbax,
  access_token: "unset-for-dev-we-only-log",
  environment: "development",
  enabled: :log

config :ex_aws,
  sqs:            %{port: 443},
  cloudformation: %{port: 443},
  lambda:         %{port: 443},
  region:         {:system, "AWS_REGION"}

config :ex_aws, :httpoison_opts,
       recv_timeout: 30_000,
       hackney: [recv_timeout: 20_000]

config :ex_aws, :retries,
       max_attempts: 3,
       base_backoff_in_ms: 10,
       max_backoff_in_ms: 5_000

import_config "#{Mix.env}.exs"
