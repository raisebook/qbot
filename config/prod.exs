use Mix.Config

# The System.get_env variables are evaluated at *COMPILE TIME*, so make sure they are set
# When you are building the release

config :qbot,
  worker_count: 4,
  aws_stack: "production"

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
  system_name: "QBot",
  format: "[$level] $levelpad$metadata $message",
  access_token: System.get_env("PAPERTRAIL_ACCESS_TOKEN") || "SET_PAPERTRAIL_TOKEN"

config :rollbax,
  access_token: System.get_env("ROLLBAR_ACCESS_TOKEN") || "SET_ROLLBAR_TOKEN",
  environment: "production",
  enabled: true
