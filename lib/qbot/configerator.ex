defmodule QBot.Configerator do
  @moduledoc false

  require Logger

  def discover! do
    get_all_sqs_queues
    |> get_queue_metadata
  end

  defp get_all_sqs_queues do
    with {:ok, %{body: %{resources: resources}}} <- Qbot.AppConfig.aws_stack
              |> ExAws.Cloudformation.list_stack_resources
              |> ExAws.request,
         queues <- resources |> Enum.filter_map(&(live_sqs_queue(&1)),
                                 &(Map.get(&1, :logical_resource_id)))
    do
      Logger.info "Found SQS Queues: #{queues |> Enum.join(", ")}"
      queues
    end
  end

  defp get_queue_metadata(queues) do
    map_values = fn q ->
      %QBot.QueueConfig{
        name: q[:logical_resource_id],
        target: q |> get_in([:metadata, "QBotEndpoint"]),
        headers: q |> get_in([:metadata, "QBotHeaders"]) || %{},
        sqs_url:  q[:physical_resource_id]
       }
    end

    queues
    |> Enum.map(&(fetch_resource(&1)))
    |> Enum.filter(&match?(%{metadata: %{"QBotEndpoint" => _}}, &1))
    |> Enum.map(&(map_values.(&1)))
  end

  defp fetch_resource(queue) do
    :timer.sleep(500)

    with stack <- Qbot.AppConfig.aws_stack,
         result <- stack |> ExAws.Cloudformation.describe_stack_resource(queue)
                         |> ExAws.request,
         {:ok, %{body: %{resource: resource}}} <- result,
         do: resource
  end

  defp live_sqs_queue(resource) do
    resource[:resource_type] == "AWS::SQS::Queue" &&
      (resource[:resource_status] == :create_complete || resource[:resource_status] == :update_complete)
  end
end
