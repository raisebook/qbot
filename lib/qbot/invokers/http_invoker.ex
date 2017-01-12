defmodule QBot.Invoker.Http do
  @moduledoc """
  Does HTTPS calls to the configured message target
  """

  alias QBot.QueueConfig
  alias SqsService.Message

  def invoke!(%Message{} = message, %QueueConfig{} = config) do
    case HTTPoison.post(config.target, post_body(message), http_headers(message)) do
      {:ok, %HTTPoison.Response{status_code: code}}
        when code >= 200 and code < 300 -> {:ok, message}
      {:ok, %HTTPoison.Response{status_code: code}} -> raise "Got HTTP Status #{code}"
      {:error, %HTTPoison.Error{reason: reason}}    -> raise reason
      {:error, error}                               -> raise inspect(error)
      _ -> raise "Unknown HTTP error"
    end
  end

  def http_headers(%Message{body: %{"metadata" => metadata}}) do
    metadata |> Enum.flat_map(fn {key, value} ->
      case key |> String.downcase do
        "correlationuuid" -> %{"X-Request-ID"   => value}
              "requestid" -> %{"X-Request-ID"   => value}
           "x-request-id" -> %{"X-Request-ID"   => value}
          "authorization" -> %{"Authorization"  => value}
                        _ -> %{}
      end
    end)
  end
  def http_headers(%Message{}), do: %{}


  def post_body(%Message{body: body}) do
    {:ok, result} = case body do
      %{"payload" => payload} -> payload |> Poison.encode
                 bare_payload -> bare_payload |> Poison.encode
    end
    result
  end

end
