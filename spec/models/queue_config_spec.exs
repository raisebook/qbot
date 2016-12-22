defmodule QBot.QueueConfigSpec do
  use ESpec

  alias QBot.QueueConfig

  describe "sqs_queue_name/1" do
    let config: %QueueConfig{
      target: "test-lambda", name: "test",
      sqs_url: "https://sqs.ap-southeast-2.amazonaws.com/038451313208/development-testingsqs"
    }
    subject do: QueueConfig.sqs_queue_name(config())

    it "Returns the SQS Queue name from the URL" do
      expect subject() |> to(eq "038451313208/development-testingsqs")
    end
  end

end
