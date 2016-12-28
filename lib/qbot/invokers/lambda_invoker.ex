defmodule QBot.Invoker.Lambda do
   @moduledoc """
   Directly Invokes the target AWS Lambda function with the payload
   """

  alias QBot.QueueConfig
  alias SqsService.Message

  require Logger

  def invoke!(%Message{body: body} = message, %QueueConfig{target: target}) do
    result = target |> ExAws.Lambda.invoke(body, %{})
                    |> ExAws.request

    Logger.info("Got #{inspect(result)} response from #{target}")

    case result do
      {:ok, nil} -> {:ok, message}
      {:ok, nil, _} -> {:ok, message}
      {:ok, %{"errorMessage" => error}} -> raise error
      _ -> raise "Got an unhandled response format from Lambda"
    end
  end

end
