defmodule QBot.Poller do
  @moduledoc """
  Provides poll/1, which runs in an infinite loop.
  """
  alias QBot.QueueConfig
  alias SqsService.Message

  require Logger

  @spec poll(config :: %QBot.QueueConfig{}, worker_id :: pos_integer) :: none
  def poll(config, worker_id) do
    if System.get_env("NO_POLL") == "true" do
      Logger.info("Application started with NO_POLL")
      wait_forever()
    else
      polling_loop(config, worker_id)
    end
  end

  @spec process_message(%QBot.QueueConfig{}) :: :ok
  def process_message(%QueueConfig{} = config) do
    with queue_name <- config |> QBot.QueueConfig.sqs_queue_name(),
         {:ok, message} <- queue_name |> SqsService.get_message(),
         _ <- message |> reconfigure_logger_with_uuid(),
         result <- {:ok, message} |> invoke(config) do
      result |> SqsService.mark_done()
    else
      {:no_message, _} -> :ok
      {:error, :closed} -> :ok
      {:error, :timeout} -> :ok
      error -> error
    end

    Logger.metadata(uuid: nil)
  end

  defp invoke({:no_message, _} = passthrough, _), do: passthrough

  defp invoke({:ok, %Message{} = message}, %QueueConfig{} = config) do
    case config |> QueueConfig.endpoint_type() do
      :lambda -> QBot.Invoker.Lambda.invoke!(message, config)
      :http -> QBot.Invoker.Http.invoke!(message, config)
    end
  end

  defp polling_loop(config, worker_id) do
    try do
      Logger.debug(fn -> "Doing a poll on worker id: #{worker_id}" end)
      config |> process_message
    rescue
      exception ->
        trace = System.stacktrace()
        Rollbax.report(:error, exception, trace)
        Logger.error("#{inspect(exception)} - #{inspect(System.stacktrace())}")
        reraise exception, trace
    end

    polling_loop(config, worker_id)
  end

  defp wait_forever do
    :timer.sleep(10_000)
    wait_forever()
  end

  defp reconfigure_logger_with_uuid({:ok, %Message{body: %{"correlation_uuid" => uuid}}} = passthrough) do
    Logger.configure_backend(:console, metadata: [:uuid])
    Logger.metadata(uuid: uuid)
    passthrough
  end

  defp reconfigure_logger_with_uuid(passthrough), do: passthrough
end
