defmodule QBot.Invoker.LambdaSpec do
  use ESpec, async: false

  alias SqsService.Message
  alias QBot.QueueConfig
  alias QBot.Invoker.Lambda

  describe "invoke!/2" do
    # SQS Service delivers the body with string keys
    let(payload: %{"some" => "data", "wrapped" => "here"})
    let(message: %Message{body: payload()})
    let(config: %QueueConfig{target: "arn:aws:lambda:ap-southeast-2:1234567:function:test-function"})

    subject(do: Lambda.invoke!(message(), config()))

    before(do: allow(ExAws |> to(accept(:request, fn req -> mock_aws(req) end))))

    it "invokes the target lambda function" do
      subject()
      expect ExAws |> to(accepted(:request, :any, count: 1))

      [{_, {ExAws, :request, [%ExAws.Operation.JSON{data: data, service: :lambda}]}, {:ok, nil}}] = :meck.history(ExAws)

      # Check we invoke the lambda with encoded JSON
      expect data |> to(eq(~s({"wrapped":"here","some":"data"})))
    end

    it "returns the original message" do
      expect subject() |> to(eq({:ok, message()}))
    end

    context "error from the lambda function" do
      let(payload: %{"this" => "will fail"})

      it "does not raise" do
        expect(fn -> subject() end) |> to_not(raise_exception(RuntimeError, "remote fail"))
      end

      it "returns a {:no_message, _} tuple" do
        expect(subject()) |> to(eq({:no_message, nil}))
      end
    end
  end

  def mock_aws(%ExAws.Operation.JSON{service: :lambda, data: data}) do
    case data do
      ~s({"this":"will fail"}) -> {:ok, %{"errorMessage" => "remote fail"}}
      _ -> {:ok, nil}
    end
  end
end
