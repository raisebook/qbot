defmodule QBot.Invoker.HttpSpec do
  use ESpec, async: false

  alias SqsService.Message
  alias QBot.QueueConfig
  alias QBot.Invoker.Http

  require Logger

  describe "HttpInvoker" do
    # SQS Service delivers the body with string keys
    let(payload: %{"some" => "data", "wrapped" => "here"})

    let(
      message: %Message{
        body: %{
          "metadata" => %{
            "CorrelationUUID" => "12345-12345-12345-12345",
            "NotForTheHeader" => "DiscardMe",
            "Authorization" => "Bearer supers3cret",
            "Callback" => "https://raisebook.dev/graphql"
          },
          "payload" => payload()
        }
      }
    )

    describe "invoke/2" do
      let(config: %QueueConfig{target: "https://test.endpoint/"})

      subject(do: Http.invoke!(message(), config()))

      before(do: allow(HTTPoison |> to(accept(:post, fn target, _, _, _ -> mock_http_call(target) end))))

      it "does an HTTP POST to the target" do
        subject()
        expect HTTPoison |> to(accepted(:post, :any, count: 1))
        [{_, {HTTPoison, :post, [target, _, _, _]}, _}] = :meck.history(HTTPoison)
        expect target |> to(eq("https://test.endpoint/"))
      end

      it "POSTs the message body" do
        subject()
        expect HTTPoison |> to(accepted(:post, :any, count: 1))

        [{_, {HTTPoison, :post, [_, body, _, _]}, _}] = :meck.history(HTTPoison)
        expect body |> to(eq(Http.post_body(message())))
      end

      it "sends the headers" do
        subject()
        expect HTTPoison |> to(accepted(:post, :any, count: 1))

        [{_, {HTTPoison, :post, [_, _, headers, _]}, _}] = :meck.history(HTTPoison)
        expect headers |> to(eq(Http.http_headers(message(), config())))
      end

      context "Connection Refused error" do
        let(config: %QueueConfig{target: "econnrefused"})

        it "returns a {:no_message, _} tuple" do
          expect(subject()) |> to(eq({:no_message, nil}))
        end
      end

      context "No such domain (misconfiguration)" do
        let(config: %QueueConfig{target: "nxdomain"})

        it "returns a {:no_message, _} tuple" do
          expect(subject()) |> to(eq({:no_message, nil}))
        end
      end

      context "2xx status codes" do
        let(config: %QueueConfig{target: "204"})

        it "treated as success" do
          expect subject() |> to(be_ok_result())
        end
      end

      context "Non-success status codes" do
        let(config: %QueueConfig{target: "404"})

        it "returns a {:no_message, _} tuple" do
          expect(subject()) |> to(eq({:no_message, nil}))
        end
      end
    end

    describe "http_headers/2" do
      let(config: %QueueConfig{target: "https://test.endpoint/"})

      subject(do: Http.http_headers(message(), config()))

      it "pulls the correlation id from metadata into X-Request-ID" do
        expect subject() |> to(have_any(&match?({"X-Request-ID", "12345-12345-12345-12345"}, &1)))
      end

      it "passes through auth tokens" do
        expect subject() |> to(have_any(&match?({"Authorization", "Bearer supers3cret"}, &1)))
      end

      it "passes through callback urls" do
        expect subject() |> to(have_any(&match?({"X-Callback", "https://raisebook.dev/graphql"}, &1)))
      end

      context "with no metadata" do
        let(message: %Message{body: "body payload"})

        it "returns an empty hash" do
          expect subject() |> to(eq(%{}))
        end
      end

      context "encrypted metadata value" do
        let(
          message: %Message{
            body: %{
              "metadata" => %{"Authorization" => "Bearer decrypt(3NCRYP7ED==)"},
              "payload" => payload()
            }
          }
        )

        it "decrypts the metadata" do
          result = {:ok, %{"Plaintext" => "raisebook-decrypt3d" |> Base.encode64()}}
          allow(ExAws |> to(accept(:request, fn _ -> result end)))
          expect subject() |> to(have_any(&match?({"Authorization", "Bearer raisebook-decrypt3d"}, &1)))
        end
      end

      context "with headers in config" do
        let(config: %QueueConfig{target: "https://test.endpoint/", headers: %{"Authorization" => "Bearer raisebook"}})

        let(
          message: %Message{
            body: payload()
          }
        )

        it "passes through auth tokens from config" do
          expect subject() |> to(have_any(&match?({"Authorization", "Bearer raisebook"}, &1)))
        end

        context "with encrypted headers in config, if they are wrapped with decrypt(...)" do
          let(
            config: %QueueConfig{
              target: "https://test.endpoint/",
              headers: %{"Authorization" => "Bearer decrypt(raisebook)"}
            }
          )

          it "decrypts encrypted strings" do
            result = {:ok, %{"Plaintext" => "raisebook-decrypted" |> Base.encode64()}}
            allow(ExAws |> to(accept(:request, fn _ -> result end)))
            expect subject() |> to(have_any(&match?({"Authorization", "Bearer raisebook-decrypted"}, &1)))
          end
        end
      end

      context "with header set in metadata and config" do
        let(config: %QueueConfig{target: "https://test.endpoint/", headers: %{"Authorization" => "Overridden"}})

        it "the metadata value takes priority" do
          expect subject() |> to(have_any(&match?({"Authorization", "Bearer supers3cret"}, &1)))
          expect subject() |> to_not(have_any(&match?({"Authorization", "Overridden"}, &1)))
        end
      end
    end

    describe "post_body/1" do
      subject(do: Http.post_body(message()))

      context "wrapped with the payload key" do
        it "returns the unwrapped payload as JSON" do
          expect subject() |> to(eq(~S|{"wrapped":"here","some":"data"}|))
        end
      end

      context "bare payload" do
        let(message: %Message{body: %{"body" => "payload"}})

        it "returns the whole payload as JSON" do
          expect subject() |> to(eq(~S|{"body":"payload"}|))
        end
      end
    end
  end

  defp mock_http_call(target) do
    case target do
      "econnrefused" -> {:error, :econnrefused}
      "nxdomain" -> {:error, %HTTPoison.Error{reason: :nxdomain}}
      "204" -> {:ok, %HTTPoison.Response{status_code: 204, body: %{}}}
      "404" -> {:ok, %HTTPoison.Response{status_code: 404, body: %{}}}
      _ -> {:ok, %HTTPoison.Response{status_code: 200, body: "Hello world!"}}
    end
  end
end
