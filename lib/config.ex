defmodule Trello.Config do
  alias Trello.Http
  def generate_auth_url(config) do
    "authorize?" <> URI.encode_query(query_params(config))
    |> Http.process_url
  end

  def query_params(config) do
    query_params = Map.put(config, :key, key)
    cond do
      !name_configured?(config) -> Map.put(query_params, :name, trello_app_name)
      true                      -> query_params
    end
  end

  defp name_configured?(config), do: Map.has_key?(config, :name)
  defp trello_app_key,  do: Application.fetch_env!(:trello, :app_key)
  defp trello_app_name, do: Application.fetch_env!(:trello, :name)

  def key,                 do: key(trello_app_key)
  def key({:system, key}), do: System.get_env(key)
  def key(value),          do: value
end
