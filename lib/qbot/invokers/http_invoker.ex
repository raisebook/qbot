defmodule QBot.Invoker.Http do
  @moduledoc """
  Does HTTPS calls to the configured message target
  """

  alias QBot.QueueConfig
  alias SqsService.Message

  require Logger

  @http_options [timeout: 45_000, recv_timeout: 30_000]

  @spec invoke!(%SqsService.Message{}, %QBot.QueueConfig{}) :: {:ok, %SqsService.Message{}}
  def invoke!(%Message{} = message, %QueueConfig{} = config) do
    case HTTPoison.post(config.target, post_body(message), http_headers(message, config), @http_options) do
      {:ok, %HTTPoison.Response{status_code: code}} when code >= 200 and code < 300 -> {:ok, message}
      {:ok, %HTTPoison.Response{status_code: code}} -> remote_failed("Got HTTP Status #{code} from #{config.target}")
      {:error, %HTTPoison.Error{reason: :nxdomain}} -> remote_failed("NX Domain for #{config.target}", rollbar: true)
      {:error, %HTTPoison.Error{reason: reason}} -> remote_failed("Failure for #{config.target}: #{reason}")
      {:error, error} -> remote_failed(inspect(error))
      _ -> raise "Unknown HTTP error"
    end
  end

  @spec http_headers(%SqsService.Message{}, %QBot.QueueConfig{}) :: map
  def http_headers(%Message{body: %{"metadata" => metadata}}, %QueueConfig{headers: headers}) do
    headers |> Map.merge(metadata)
    |> add_headers
  end

  def http_headers(%Message{}, %QueueConfig{headers: headers}), do: add_headers(headers)

  @spec add_headers(headers :: map) :: map
  def add_headers(headers) do
    headers
    |> Enum.flat_map(fn {k, v} -> %{k => decrypt(v)} end)
    |> Enum.flat_map(fn {key, value} ->
      case key |> String.downcase() do
        "correlationuuid" -> %{"X-Request-ID" => value}
        "requestid" -> %{"X-Request-ID" => value}
        "request_id" -> %{"X-Request-ID" => value}
        "x-request-id" -> %{"X-Request-ID" => value}
        "authorization" -> %{"Authorization" => value}
        "callback" -> %{"X-Callback" => value}
        _ -> %{}
      end
    end)
    |> Enum.into(%{})
  end

  @spec post_body(%SqsService.Message{}) :: String.t()
  def post_body(%Message{body: body}) do
    {:ok, result} =
      case body do
        %{"payload" => payload} -> payload |> Poison.encode()
        bare_payload -> bare_payload |> Poison.encode()
      end

    result
  end

  defp decrypt_key(key) do
    with {:ok, %{"Plaintext" => plaintext}} <- key |> ExAws.KMS.decrypt() |> ExAws.request(),
         {:ok, decrypted} <- plaintext |> Base.decode64(),
         do: decrypted
  end

  defp decrypt(value) do
    value
    |> String.split(" ")
    |> Enum.map(fn token ->
      case Regex.run(~r/^decrypt\((.+)\)$/, token) do
        [_, encrypted] -> encrypted |> decrypt_key
        _ -> token
      end
    end)
    |> Enum.join(" ")
  end

  defp remote_failed(error, rollbar: true) do
    Rollbax.report(:error, error, System.stacktrace())
    remote_failed(error)
  end

  defp remote_failed(error) do
    Logger.warn(error)
    {:no_message, nil}
  end
end
