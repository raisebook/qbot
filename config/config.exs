use Mix.Config

config :qbot,
  workers_per_queue: 1,
  aws_stack: "development"

config :rollbax,
  access_token: "unset-for-dev-we-only-log",
  environment: "development",
  enabled: :log

import_config "#{Mix.env}.exs"
