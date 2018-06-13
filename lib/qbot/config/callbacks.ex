efmodule QBot.Config.Callbacks do
  @moduledoc """
  Runtime configuration callbacks
  """

  def rollbax(config) do
    Keyword.put(config, :access_token, System.get_env("ROLLBAR_ACCESS_TOKEN"))
  end
end
