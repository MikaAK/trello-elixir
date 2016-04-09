defmodule Trello do
  alias Trello.Http
  import IEx

  def get(url, secret), do: Http.get(create_url(url, secret)) |> unwrap_http
  def get!(url, secret), do: Http.get!(create_url(url, secret)) |> unwrap_http

  def post(url, body, secret), do: Http.post(create_url(url, secret), body) |> unwrap_http
  def post!(url, body, secret), do: Http.post!(create_url(url, secret), body) |> unwrap_http

  def put(url, body, secret), do: Http.put(create_url(url, secret), body) |> unwrap_http
  def put!(url, body, secret), do: Http.put!(create_url(url, secret), body) |> unwrap_http

  def delete(url, secret), do: Http.delete(create_url(url, secret)) |> unwrap_http
  def delete!(url, secret), do: Http.delete!(create_url(url, secret)) |> unwrap_http

  def get_board(board_id, secret), do: get "/boards/#{board_id}", secret
  def get_board!(board_id, secret), do: get! "/boards/#{board_id}", secret

  def get_board_cards(board_id, secret), do: get "/boards/#{board_id}/cards", secret
  def get_board_cards!(board_id, secret), do: get! "/boards/#{board_id}/cards", secret

  def get_board_labels(board_id, secret), do: get "/boards/#{board_id}/labels", secret
  def get_board_labels!(board_id, secret), do: get! "/boards/#{board_id}/labels", secret

  def get_board_lists(board_id, secret), do: get "/boards/#{board_id}/lists", secret
  def get_board_lists!(board_id, secret), do: get! "/boards/#{board_id}/lists", secret

  def get_label(label_id, secret), do: get "/labels/#{label_id}", secret
  def get_label!(label_id, secret), do: get! "/labels/#{label_id}", secret

  def get_list(list_id, secret), do: get "/lists/#{list_id}", secret
  def get_list!(list_id, secret), do: get! "/lists/#{list_id}", secret

  def get_list_cards(list_id, secret), do: get "/lists/#{list_id}/cards", secret
  def get_list_cards!(list_id, secret), do: get! "/lists/#{list_id}/cards", secret

  def get_member(member_id, secret), do: get "/members/#{member_id}", secret
  def get_member!(member_id, secret), do: get! "/members/#{member_id}", secret

  def get_full_board(board_id, secret) do
    with {:ok, board} <- get_board(board_id, secret),
         {:ok, cards} <- get_board_cards(board_id, secret),
         {:ok, labels} <- get_board_labels(board_id, secret),
         {:ok, lists} <- get_board_lists(board_id, secret) do

      lists = Enum.map(lists, fn(list) ->
        Map.put list, :cards, get_lists_with_id(list[:id], "idList", cards)
      end)

      Map.put(board, :cards, cards)
        |> Map.put(:labels, labels)
        |> Map.put(:lists, lists)
    end
  end

  defp key, do: Application.fetch_env!(:trello, :secret)
  defp has_query_params?(url), do: Regex.match?(~r/\?/, url)
  
  defp get_lists_with_id(id, idName, list) do
    Enum.filter list, fn(item) ->
      Map.get(item, String.to_atom(idName)) == id
    end
  end

  defp create_url(url, secret) do
    params = "token=#{secret}&key=#{key}"
    seperator = if has_query_params?(url), do: "&", else: "?"

    url <> seperator <> params
  end

  defp unwrap_http(response) do
    with {:ok, %HTTPoison.Response{body: body}} <- response do
      if (is_bitstring body), do: {:error, body}, else: {:ok, body}
    end
  end
end
