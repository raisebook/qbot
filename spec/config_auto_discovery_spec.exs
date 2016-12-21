defmodule QBot.ConfigAutoDiscoverySpec do
  use ESpec

  alias ExAws.Operation.Query

  describe "ConfigAutoDiscovery" do
    describe "discover/0" do

      subject do: QBot.ConfigAutoDiscovery.discover

      before do
        allow ExAws |> to(accept :request, fn req -> mock_decider(req) end)
      end

      it "returns a map of config data from Cloudformation metadata" do
        expected_config = [
          %{queue_name: "WithMeta",
             target:  "arn:aws:lambda:ap-southeast-2:038451313208:function:target-lambda",
             sqs_url: "https://sqs.ap-southeast-2.amazonaws.com/038451313208/test-queue"
            }
          ]

        expect subject() |> to(eq expected_config)
      end
    end
  end

  defp mock_decider(%Query{action: :list_stack_resources}), do: mock_list_stack_resources
  defp mock_decider(%Query{action: :describe_stack_resource, params: %{"LogicalResourceId" => res}}) do
    mock_describe_stack_resource(res)
  end

  defp mock_list_stack_resources do
    {:ok, %{body:
      %{resources: [
        %{last_updated_timestamp: "2016-11-09T03:35:08.628Z",
          logical_resource_id: "WithMeta",
          physical_resource_id: "https://sqs.ap-southeast-2.amazonaws.com/038451313208/test-queue",
          resource_status: :create_complete,
          resource_type: "AWS::SQS::Queue"},

        %{last_updated_timestamp: "2016-12-16T06:14:17.240Z",
          logical_resource_id: "NoMeta",
          physical_resource_id: "https://sqs.ap-southeast-2.amazonaws.com/038451313208/test-queue-2",
          resource_status: :create_complete, resource_type: "AWS::SQS::Queue"},

        %{last_updated_timestamp: "2016-12-16T06:14:17.240Z",
          logical_resource_id: "FilteredOutBecauseOfState",
          physical_resource_id: "https://sqs.ap-southeast-2.amazonaws.com/038451313208/deleted-queue",
          resource_status: :delete_complete, resource_type: "AWS::SQS::Queue"},

        %{last_updated_timestamp: "2016-10-31T04:50:23.052Z",
          logical_resource_id: "FilteredOutResource",
          physical_resource_id: "CoolLambda",
          resource_status: :create_complete,
          resource_type: "AWS::Lambda::Function"},
      ]
    }}}
  end

  defp mock_describe_stack_resource(resource_name) do
    {:ok, %{body: %{resources: resources}}} = mock_list_stack_resources
    resource = resources |> Enum.find(&(match? %{logical_resource_id: ^resource_name}, &1))

    metadata = case resource_name do
      "WithMeta" -> %{"QBotEndpoint" => "arn:aws:lambda:ap-southeast-2:038451313208:function:target-lambda"}
               _ -> nil
    end

    {:ok, %{body: %{
         resource: %{last_updated_timestamp: resource[:last_updated_timestamp],
           logical_resource_id: resource_name,
           metadata: metadata,
           physical_resource_id: resource[:physical_resource_id],
           resource_status: resource[:resource_status],
           resource_type: resource[:resource_type]
           }
         },
       }}
  end

end
