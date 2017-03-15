use Mix.Config

config :logger, backends: [LoggerPapertrailBackend.Logger,
                           Rollbax.Logger,
                           :console],
                           utc_log: true

config :logger, Rollbax.Logger,
  level: :error

config :logger, :logger_papertrail_backend,
  host: {:system, "PAPERTRAIL_ENDPOINT"},
  level: :info,
  system_name: "QBot",
  format: "[$level] $levelpad$metadata $message",
  access_token: {:system, "PAPERTRAIL_ACCESS_TOKEN"}

config :rollbax,
  access_token: {:system, "ROLLBAR_ACCESS_TOKEN"},
  environment: "production",
  enabled: true
