defmodule QBot.HttpInvokerSpec do
  use ESpec

  alias SqsService.Message
  alias QBot.QueueConfig
  alias QBot.HttpInvoker

  describe "HttpInvoker" do
      # SQS Service delivers the body with string keys
      let message: %Message{body:
        %{ "metadata" => %{
           "CorrelationUUID" => "12345-12345-12345-12345",
           "NotForTheHeader" => "DiscardMe",
           "Authorization" => "Bearer supers3cret"
         },
         "payload" => %{
           "some" => "data",
           "wrapped" => "here"
         }
      }
    }

    describe "invoke/2" do
      let config: %QueueConfig{}

      subject do: HttpInvoker.invoke!(message(), config())
      pending "it does an HTTP POST top the target"
    end


    describe "http_headers_from/1" do
      subject do: HttpInvoker.http_headers(message())

      it "pulls the correlation id from metadata into X-Request-ID" do
        expect subject() |> to(have_any &match?({"X-Request-ID", "12345-12345-12345-12345"}, &1))
      end

      it "passes through auth tokens" do
        expect subject() |> to(have_any &match?({"Authorization", "Bearer supers3cret"}, &1))
      end

      context "with no metadata" do
        let message: %Message{body: %{"key" => "value"}}

        it "returns an empty hash" do
          expect subject() |> to(eq %{})
        end
      end
    end

    describe "payload_from/1" do
      subject do: HttpInvoker.payload(message())

      context "wrapped with the payload key" do
        it "returns the unwrapped payload" do
          expect subject() |> to(eq(%{"some" => "data", "wrapped" => "here"}))
        end
      end

      context "bare payload" do
        let message: %Message{body: %{"key" => "value"}}

        it "returns the payload as given" do
          expect subject() |> to(eq(%{"key" => "value"}))
        end
      end
    end
  end
end
