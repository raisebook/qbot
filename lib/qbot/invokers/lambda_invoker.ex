defmodule QBot.Invoker.Lambda do
   @moduledoc """
   Directly Invokes the target AWS Lambda function with the payload
   """

  alias QBot.QueueConfig
  alias SqsService.Message

  require Logger

  @spec invoke!(%SqsService.Message{}, %QBot.QueueConfig{}) :: {:ok, %SqsService.Message{}}
  def invoke!(%Message{body: body} = message, %QueueConfig{target: target}) do
    {:ok, payload} = body |> Poison.encode

    Logger.info fn -> "Invoking #{target} with: #{inspect(payload)}" end
    result = target |> ExAws.Lambda.invoke(payload, %{})
                    |> ExAws.request

    Logger.info fn -> "Got #{inspect(result)} response from #{target}" end

    case result do
      {:ok, nil} -> {:ok, message}
      {:ok, nil, _} -> {:ok, message}
      {:ok, %{"errorMessage" => error}} -> raise error
      _ -> raise "Got an unhandled response format from Lambda"
    end
  end

end
