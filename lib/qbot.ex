defmodule QBot do
  @moduledoc """
    Service to pull messages from Queues and get them where they are going
  """

  use Application
  require Logger

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    worker_count = Application.get_env(:qbot, :worker_count)

    Logger.info "QBot has started"

    # Define workers and child supervisors to be supervised
    children = [supervisor(QBot.TaskSupervisor, [worker_count], restart: :permanent)]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QBot.Supervisor]
    {:ok, _pid} = Supervisor.start_link(children, opts)
  end

  defmodule TaskSupervisor do
    @moduledoc """
    OTP Superviros for the Poller workers
    """

    use Supervisor
    import Supervisor.Spec, warn: false

    def start_link(arg) do
      Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
    end

    def init(count) do
      Logger.info "QBot starting #{count} workers"
      tasks = Enum.map(1..count, fn(id) ->
        worker(Task, [fn -> QBot.Poller.poll(id) end], id: id)
      end)
      supervise(tasks, strategy: :one_for_one, max_restarts: 3)
    end
  end

end
