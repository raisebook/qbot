defmodule QBot.Configerator do
  @moduledoc false

  require Logger

  def discover! do
    QBot.AppConfig.aws_stacks()
    |> Enum.map(&(&1 |> get_all_sqs_queues |> get_queue_metadata))
    |> List.flatten()
  end

  defp get_all_sqs_queues(stack) do
    with {:ok, %{body: %{resources: resources}}} <-
           stack |> ExAws.Cloudformation.list_stack_resources()
           |> ExAws.request(),
         queues <-
           resources
           |> Enum.filter(&live_sqs_queue(&1))
           |> Enum.map(&Map.get(&1, :logical_resource_id))
           |> filter_selected_queues() do
      Logger.info(fn -> "Found #{stack} SQS Queues: #{queues |> Enum.join(", ")}" end)
      {stack, queues}
    end
  end

  defp get_queue_metadata({stack, queues}) do
    queues
    |> Enum.map(&fetch_resource(&1, stack))
    |> Enum.filter(&match?(%{metadata: %{"QBotEndpoint" => _}}, &1))
    |> Enum.map(&map_values(&1))
  end

  defp fetch_resource(queue, stack) do
    :timer.sleep(500)

    with result <- stack |> ExAws.Cloudformation.describe_stack_resource(queue) |> ExAws.request(),
         {:ok, %{body: %{resource: resource}}} <- result,
         do: resource
  end

  defp map_values(queue_result) do
    %QBot.QueueConfig{
      name: queue_result[:logical_resource_id],
      sqs_url: queue_result[:physical_resource_id],
      target: queue_result |> get_in([:metadata, "QBotEndpoint"]),
      headers: queue_result |> get_in([:metadata, "QBotHeaders"]) || %{}
    }
  end

  defp live_sqs_queue(resource) do
    resource[:resource_type] == "AWS::SQS::Queue" &&
      (resource[:resource_status] == :create_complete || resource[:resource_status] == :update_complete)
  end

  defp filter_selected_queues(queues) do
    case QBot.AppConfig.only_queues() do
      nil -> queues
      filter -> queues |> Enum.filter(fn q -> filter |> Enum.member?(q) end)
    end
  end
end
