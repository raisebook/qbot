use Mix.Config

config :qbot,
  workers_per_queue: "${WORKERS_PER_QUEUE}",
  aws_stacks: "${AWS_STACKS}",
  config_poll_delay_sec: "${CONFIG_POLL_DELAY_SEC}",
  only_queues: "${ONLY_QUEUES}"

config :rollbax,
  environment: "development",
  enabled: :log,
  config_callback: {QBot.Config.Callbacks, :rollbax}

# See https://github.com/ex-aws/ex_aws/issues/365 and https://github.com/ex-aws/ex_aws/issues/516
config :ex_aws,
  sqs: %{port: 443},
  cloudformation: %{port: 443},
  lambda: %{port: 443},
  region: "ap-southeast-2"

config :ex_aws, :hackney_opts,
  follow_redirect: true,
  recv_timeout: 30_000

config :ex_aws, :retries,
  max_attempts: 3,
  base_backoff_in_ms: 10,
  max_backoff_in_ms: 5_000

config :logger,
  backends: [{FlexLogger, :ex_aws_logger}, {FlexLogger, :default_logger}],
  utc_log: true

config :logger, :ex_aws_logger,
  logger: :console,
  default_level: :off,
  level_config: [
    [application: :ex_aws, module: ExAws.Request, level: :error]
  ]

config :logger, :default_logger,
  logger: :console,
  default_level: :info,
  level_config: [
    [application: :ex_aws, module: ExAws.Request, level: :off]
  ]

import_config "#{Mix.env()}.exs"
