defmodule QBot.QueueConfig do
  @moduledoc """
  Struct that contains the important bits of the incoming message
  """
  defstruct [
    :name,
    :target,
    :sqs_url
  ]

  def sqs_queue_name(%QBot.QueueConfig{} = config) do
    config.sqs_url |> String.replace(~r/^.*amazonaws.com\//, "")
  end
end
