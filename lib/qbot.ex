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
    workers_per_queue = Application.get_env(:qbot, :workers_per_queue)

    Logger.info "QBot has started"

    auto_config = QBot.ConfigAutoDiscovery.discover
    Logger.info "Got Auto-Discovery config:"
    Logger.info inspect(auto_config)

    # Define workers and child supervisors to be supervised
    children = [supervisor(QBot.TaskSupervisor, [{auto_config, workers_per_queue}],
                           restart: :permanent)
               ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QBot.Supervisor]
    {:ok, _pid} = Supervisor.start_link(children, opts)
  end

  defmodule TaskSupervisor do
    @moduledoc """
    OTP Supervisor for the Poller workers
    """

    use Supervisor
    import Supervisor.Spec, warn: false

    def start_link(arg) do
      Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
    end

    def init({auto_config, count}) do
      Logger.info "QBot starting workers, #{count} per queue}"

      tasks = auto_config |> Enum.flat_map(fn config ->
        1..count |> Enum.map(fn c ->
          id = "#{config[:queue_name]}_#{c}"
          worker(Task, [fn -> QBot.Poller.poll(config, id) end], id: id)
         end)
      end)

      supervise(tasks, strategy: :one_for_one, max_restarts: 3)
    end
  end

end
