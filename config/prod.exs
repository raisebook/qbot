use Mix.Config

config :logger, backends: [Rollbax.Logger,
                           :console],
                           utc_log: true

config :logger, Rollbax.Logger,
  level: :error

config :logger, :console,
  level: :info

config :rollbax,
  access_token: {:system, "ROLLBAR_ACCESS_TOKEN"},
  environment: "production",
  enabled: true
