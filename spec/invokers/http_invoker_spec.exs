defmodule QBot.Invoker.HttpSpec do
  use ESpec, async: false

  alias SqsService.Message
  alias QBot.QueueConfig
  alias QBot.Invoker.Http

  describe "HttpInvoker" do
      # SQS Service delivers the body with string keys
      let payload: %{"some" => "data", "wrapped" => "here"}

      let message: %Message{body:
        %{ "metadata" => %{
           "CorrelationUUID" => "12345-12345-12345-12345",
           "NotForTheHeader" => "DiscardMe",
           "Authorization" => "Bearer supers3cret"
         },
         "payload" => payload()
      }
    }

    describe "invoke/2" do
      let config: %QueueConfig{target: "https://test.endpoint/"}

      subject do: Http.invoke!(message(), config())

      before do: allow HTTPoison |> to(accept :post, fn(_,_,_) -> mock_http_call end)

      it "does an HTTP POST to the target" do
        subject()
        expect HTTPoison |> to(accepted :post, :any, count: 1)
        [{_,{HTTPoison, :post, [target, _, _]},_}] = :meck.history(HTTPoison)
        expect target |> to(eq "https://test.endpoint/")
      end

      it "POSTs the message body" do
        subject()
        expect HTTPoison |> to(accepted :post, :any, count: 1)

        [{_,{HTTPoison, :post, [_, body, _]},_}] = :meck.history(HTTPoison)
        expect body |> to(eq Http.post_body(message()))
      end

      it "sends the headers" do
        subject()
        expect HTTPoison |> to(accepted :post, :any, count: 1)

        [{_,{HTTPoison, :post, [_, _, headers]},_}] = :meck.history(HTTPoison)
        expect headers |> to(eq Http.http_headers(message()))
      end
    end

    describe "http_headers_from/1" do
      subject do: Http.http_headers(message())

      it "pulls the correlation id from metadata into X-Request-ID" do
        expect subject() |> to(have_any &match?({"X-Request-ID", "12345-12345-12345-12345"}, &1))
      end

      it "passes through auth tokens" do
        expect subject() |> to(have_any &match?({"Authorization", "Bearer supers3cret"}, &1))
      end

      context "with no metadata" do
        let message: %Message{body: "body payload"}

        it "returns an empty hash" do
          expect subject() |> to(eq %{})
        end
      end
    end

    describe "post_body/1" do
      subject do: Http.post_body(message())

      context "wrapped with the payload key" do
        it "returns the unwrapped payload as JSON" do
          expect subject() |> to(eq ~S|{"wrapped":"here","some":"data"}|)
        end
      end

      context "bare payload" do
        let message: %Message{body: %{"body" => "payload"}}

        it "returns the whole payload as JSON" do
          expect subject() |> to(eq ~S|{"body":"payload"}|)
        end
      end
    end
  end

  defp mock_http_call do
    {:ok, %HTTPoison.Response{status_code: 200, body: %{}}}
  end
end