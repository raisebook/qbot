use Mix.Config

config :ex_aws,
  access_key_id: "fake",
  secret_access_key: "fake",
  region: "fake",
  sqs: %{scheme: "http://", host: "fakesqs", port: "4568"}

config :logger, backends: []
