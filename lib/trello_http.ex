defmodule Trello.Http do
  use HTTPoison.Base

  def process_url(url), do: "https://trello.com/1/" <> url

  def process_response_body(body) when is_bitstring(body) do
    if (is_json(body)), do: decode_body(body), else: body
  end

  defp decode_body(body) do
    with {:ok, data} <- Poison.decode(body), do: atomize_keys(data)
  end

  defp atomize_keys(data) when is_map(data) do
    for {key, val} <- data, into: %{} do
      key_name = String.to_atom(key)

      {key_name, atomize_keys(val)}
    end
  end
  
  defp atomize_keys(data) when is_list(data) do
    for item <- data, into: [], do: atomize_keys(item)
  end

  defp atomize_keys(data), do: data
  defp is_json(string), do: Regex.match?(~r/^({|\[).*(}|\])$/, string)
end
