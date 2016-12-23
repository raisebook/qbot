defmodule QBot.LambdaInvoker do
  alias QBot.QueueConfig
  alias SqsService.Message

  def invoke!(%Message{} = message, %QueueConfig{} = config) do

  end

end
