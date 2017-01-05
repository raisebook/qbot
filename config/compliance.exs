use Mix.Config

config :qbot,
  workers_per_queue: 1,
  aws_stack: "development"

# We use the instance role for production
config :ex_aws,
  region: "ap-southeast-2"

config :logger, backends: [LoggerPapertrailBackend.Logger,
                           Rollbax.Logger,
                           :console],
                           utc_log: true

config :logger, Rollbax.Logger,
  level: :error

config :logger, :logger_papertrail_backend,
  host: "logs5.papertrailapp.com:26166",
  level: :info,
  system_name: "QBot-Compliance",
  format: "[$level] $levelpad$metadata $message",
  access_token: System.get_env("PAPERTRAIL_ACCESS_TOKEN") || "SET_PAPERTRAIL_TOKEN"

config :rollbax,
  access_token: System.get_env("ROLLBAR_ACCESS_TOKEN") || "SET_ROLLBAR_TOKEN",
  environment: "compliance",
  enabled: true
