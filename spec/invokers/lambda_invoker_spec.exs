defmodule QBot.Invoker.LambdaSpec do
  use ESpec, async: false

  alias SqsService.Message
  alias QBot.QueueConfig
  alias QBot.Invoker.Lambda

  describe "invoke!/2" do
    # SQS Service delivers the body with string keys
    let payload: %{"some" => "data", "wrapped" => "here"}
    let message: %Message{body: payload()}
    let config: %QueueConfig{target: "arn:aws:lambda:ap-southeast-2:1234567:function:test-function"}

    subject do: Lambda.invoke!(message(), config())

    before do: allow ExAws |> to(accept :request, fn req -> mock_aws(req) end)

    it "invokes the target lambda function" do
      subject()
      expect ExAws |> to(accepted :request, :any, count: 1)
    end

    it "returns the original message" do
      expect subject() |> to(eq {:ok, message()})
    end

    context "error from the lambda function" do
      let payload: %{"error" => "remote fail"}

      it "raises with the error from the remote" do

        expect(fn -> subject() end) |> to(raise_exception(RuntimeError, "remote fail"))
      end
    end
  end
  def mock_aws(%ExAws.Operation.JSON{service: :lambda, data: data}) do
    case data do
      {:ok, ~s({"error":"remote fail"})} -> {:ok, %{"errorMessage" => "remote fail"}}
      _ -> {:ok, nil}
    end
  end

end
