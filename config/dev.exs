use Mix.Config

config :ex_aws,
  region: "ap-southeast-2"

config :logger, backends: [:console], utc_log: true, level: :debug
