defmodule Trello.Config do
  alias Trello.Http

  def generate_auth_url(config) do
    query = URI.encode_query(query_params(config))
    Http.process_url("authorize?" <> query)
  end

  def query_params(config) do
    query_params = Map.put(config, :key, key())

    case name_configured?(config) do
      true  -> query_params
      false -> Map.put(query_params, :name, trello_app_name())
    end
  end

  defp name_configured?(config), do: Map.has_key?(config, :name)

  defp trello_app_key,  do: Application.fetch_env!(:trello, :app_key)
  defp trello_app_name, do: Application.fetch_env!(:trello, :name)

  def key,                 do: key(trello_app_key())
  def key({:system, key}), do: System.get_env(key)
  def key(value),          do: value
end
