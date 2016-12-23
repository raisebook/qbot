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

  describe "endpoint_type/1" do
    let target: "arn:aws:lambda:ap-southeast-2:038451313208:function:development-Tingler"
    let config: %QueueConfig{
      target: target(), name: "test",
      sqs_url: "https://sqs.ap-southeast-2.amazonaws.com/038451313208/development-testingsqs"
    }
    subject do: QueueConfig.endpoint_type(config())

    context "lambda endpoint" do
      it "returns :lambda" do
        expect subject() |> to(eq :lambda)
      end
    end

    context "https endpoint" do
      let target: "https://stockroom.api.raisebook.com/graphql"

      it "returns http" do
        expect subject() |> to(eq :http)
      end
    end

    context "something else" do
      let target: "gopher://cern.ch"

      it "raises" do
        expect(fn -> subject() end) |> to(raise_exception(RuntimeError,
                                          "Un-supported target type for gopher://cern.ch"))
      end
    end
  end

end
