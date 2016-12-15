use Mix.Config

config :qbot,
  worker_count: 4

config :rollbax,
  access_token: "unset-for-dev-we-only-log",
  environment: "development",
  enabled: :log

import_config "#{Mix.env}.exs"
