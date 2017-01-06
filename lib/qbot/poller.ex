defmodule QBot.Poller do
  @moduledoc """
  Provides poll/1, which runs in an infinite loop.
  """
  alias QBot.QueueConfig
  alias SqsService.Message

  require Logger

  def poll(config, worker_id) do
    if System.get_env("NO_POLL") == "true" do
      Logger.info("Application started with NO_POLL")
      wait_forever
    else
      polling_loop(config, worker_id)
    end
  end

  def process_message(%QueueConfig{} = config) do
    config |> QBot.QueueConfig.sqs_queue_name
           |> SqsService.get_message
           |> reconfigure_logger_with_uuid
           |> invoke(config)
           |> SqsService.mark_done

    Logger.metadata([uuid: nil])
  end

  defp invoke({:no_message, _} = passthrough, _), do: passthrough
  defp invoke({:ok, %Message{} = message}, %QueueConfig{} = config) do
    case config |> QueueConfig.endpoint_type do
      :lambda -> QBot.Invoker.Lambda.invoke!(message, config)
      :http   -> QBot.Invoker.Http.invoke!(message, config)
    end
  end

  defp polling_loop(config, worker_id) do
    try do
      Logger.debug "Doing a poll on worker id: #{worker_id}"
      config |> process_message
    rescue
      exception ->
        Rollbax.report(:error, exception, System.stacktrace())
        exit :rollbar_caught_exception
    end
    polling_loop(config, worker_id)
  end

  defp wait_forever do
    :timer.sleep(10_000)
    wait_forever
  end

  defp reconfigure_logger_with_uuid({:ok, %Message{body: %{"correlation_uuid" => uuid}}} = passthrough) do
    Logger.configure_backend(LoggerPapertrailBackend.Logger, metadata: [:uuid])
    Logger.configure_backend(:console, metadata: [:uuid])

    Logger.metadata([uuid: uuid])
    passthrough
  end
  defp reconfigure_logger_with_uuid(passthrough), do: passthrough

end
