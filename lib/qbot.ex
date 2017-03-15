defmodule QBot do
  @moduledoc """
    Service to pull messages from Queues and get them where they are going
  """

  use Application
  require Logger

  @lint {Credo.Check.Readability.Specs, false}
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    workers_per_queue = Qbot.AppConfig.workers_per_queue
    Logger.info "QBot has started"

    try do
      auto_config = wait_for_config([])
      children = [supervisor(QBot.TaskSupervisor, [{auto_config, workers_per_queue}],
                             restart: :permanent)
                 ]

      opts = [strategy: :one_for_one, name: QBot.Supervisor]
      {:ok, _pid} = Supervisor.start_link(children, opts)
    rescue
      exception ->
        Logger.error "#{inspect(exception)} #{inspect(System.stacktrace())}"
        Rollbax.report(:error, exception, System.stacktrace())
        raise exception
    end
  end

  defp wait_for_config([]) do
    auto_config = QBot.Configerator.discover!
    Logger.info "Got Auto-Discovery config:"
    Logger.info inspect(auto_config)

    if auto_config == [] do
      :timer.sleep(Qbot.AppConfig.config_poll_delay_sec * 1000)
    end
    wait_for_config(auto_config)
  end
  defp wait_for_config(config), do: config

  defmodule TaskSupervisor do
    @moduledoc """
    OTP Supervisor for the Poller workers
    """

    use Supervisor
    import Supervisor.Spec, warn: false

    @lint {Credo.Check.Readability.Specs, false}
    def start_link(arg) do
      Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
    end

    @lint {Credo.Check.Readability.Specs, false}
    def init({auto_config, count}) do
      Logger.info "QBot starting workers, #{count} per queue}"

      tasks = auto_config |> Enum.flat_map(fn config ->
        1..count |> Enum.map(fn c ->
          id = "#{config.name}_#{c}"
          worker(Task, [fn -> QBot.Poller.poll(config, id) end], id: id)
         end)
      end)

      supervise(tasks, strategy: :one_for_one, max_restarts: 3)
    end
  end

end
