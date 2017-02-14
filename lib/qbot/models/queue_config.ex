defmodule QBot.QueueConfig do
  @moduledoc """
  Struct that contains the important bits of the incoming message
  """
  defstruct  name: nil, target: nil, headers: %{}, sqs_url: nil

  @type endpoint_type :: :lambda | :http

  @spec sqs_queue_name(%QBot.QueueConfig{}) :: String.t
  def sqs_queue_name(%QBot.QueueConfig{sqs_url: url}) do
    url |> String.replace(~r/^.*amazonaws.com\//, "")
  end

  @spec endpoint_type(%QBot.QueueConfig{}) :: endpoint_type
  def endpoint_type(%QBot.QueueConfig{target: t}) do
    cond do
      String.match?(t, ~r/^arn:aws:lambda.*/) -> :lambda
      String.match?(t, ~r/^http.*/)           -> :http
      true -> raise "Un-supported target type for #{t}"
    end
  end
end
