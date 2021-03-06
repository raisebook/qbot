defmodule QBot do
  @moduledoc """
    Service to pull messages from Queues and get them where they are going
  """

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    workers_per_queue = QBot.AppConfig.workers_per_queue()
    Logger.info("QBot has started")

    try do
      auto_config = wait_for_config([])
      children = [supervisor(QBot.TaskSupervisor, [{auto_config, workers_per_queue}], restart: :permanent)]

      opts = [strategy: :one_for_one, name: QBot.Supervisor]
      {:ok, _pid} = Supervisor.start_link(children, opts)
    rescue
      exception ->
        trace = System.stacktrace()
        Logger.error("#{inspect(exception)} #{inspect(trace)}")
        Rollbax.report(:error, exception, System.stacktrace())
        reraise exception, trace
    end
  end

  defp wait_for_config([]) do
    auto_config = QBot.Configerator.discover!()
    Logger.info("Got Auto-Discovery config:")
    Apex.ap(auto_config)

    if auto_config == [] do
      :timer.sleep(QBot.AppConfig.config_poll_delay_sec() * 1000)
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

    def start_link(arg) do
      Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
    end

    def init({auto_config, count}) do
      Logger.info(fn -> "QBot starting workers, #{count} per queue}" end)

      tasks =
        auto_config
        |> Enum.flat_map(fn config ->
          1..count
          |> Enum.map(fn c ->
            id = "#{config.name}_#{c}"
            worker(Task, [fn -> QBot.Poller.poll(config, id) end], id: id)
          end)
        end)

      supervise(tasks, strategy: :one_for_one, max_restarts: 3)
    end
  end
end
