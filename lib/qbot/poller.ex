defmodule QBot.Poller do
  @moduledoc """
  Provides poll/1, which runs in an infinite loop.
  """

  require Logger

  def poll(worker_id) do
    if System.get_env("NO_POLL") == "true" do
      Logger.info("Application started with NO_POLL")
      wait_forever
    else
      polling_loop(worker_id)
    end
  end

  def process_message do
    :timer.sleep(1_000)
  end

  defp polling_loop(worker_id) do
    try do
      Logger.debug "Doing a poll on worker id: #{worker_id}"
      process_message
    rescue
      exception ->
        Rollbax.report(:error, exception, System.stacktrace())
        exit :rollbar_caught_exception
    end
    polling_loop(worker_id)
  end

  defp wait_forever do
    :timer.sleep(10_000)
    wait_forever
  end
end
