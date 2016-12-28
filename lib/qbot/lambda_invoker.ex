defmodule QBot.LambdaInvoker do
   @moduledoc """
   Directly Invokes the target AWS Lambda function with the payload
   """

  alias QBot.QueueConfig
  alias SqsService.Message

  def invoke!(%Message{} = message, %QueueConfig{} = config) do

  end

end
