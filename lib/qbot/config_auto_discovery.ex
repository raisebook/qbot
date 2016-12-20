defmodule QBot.ConfigAutoDiscovery do
  @moduledoc false

  def discover do
    get_all_sqs_queues
  end

  defp get_all_sqs_queues do
    {:ok, %{body: %{resources: resources}}} = Application.get_env(:qbot, :aws_stack)
    |> ExAws.Cloudformation.list_stack_resources
    |> ExAws.request

    resources
    |> Enum.filter_map(&(&1 |> live_sqs_queue),
                       &(&1 |> Map.get(:logical_resource_id)))
  end

  defp live_sqs_queue(resource) do
    resource[:resource_type] == "AWS::SQS::Queue" &&
      resource[:resource_status] == :create_complete || resource[:resource_status] == :update_complete
  end
end
