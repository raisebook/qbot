defmodule QBot do
  use Application

  @moduledoc """
    Service to pull messages from Queues and get them where they are going
  """

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: QBot.Worker.start_link(arg1, arg2, arg3)
      # worker(QBot.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
