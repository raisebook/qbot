defmodule QBot.AppConfig do
  @moduledoc """
    Wrapper around application-specific config variables, with defaults
  """

  require Config

  def config_poll_delay_sec, do: fetch_int(:config_poll_delay_sec, 120)
  def workers_per_queue, do: fetch_int(:workers_per_queue, 1)

  def aws_stacks do
    :aws_stacks |> fetch("development-queues") |> String.split(",")
  end

  def only_queues do
    case :only_queues |> fetch("") do
      qs when qs == "" -> nil
      qs -> qs |> String.split(",")
    end
  end

  defp fetch(key, default) do
    case Config.get(:qbot, key, default: default) do
      {:ok, value} -> value
      {:error, _} -> raise "ENV: #{key} not set"
    end
  end

  defp fetch_int(key, default) do
    case Config.get_integer(:qbot, key, default: default) do
      {:ok, value} -> value
      {:error, _} -> raise "ENV: #{key} not set"
    end
  end
end
