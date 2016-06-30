defmodule Trello do
  alias Trello.Http

  def generate_auth_url(config) do
    query_params = Map.put(config, :key, trello_app_key)

    query_params = if (!Map.has_key?(config, :name)) do
      Map.put(query_params, :name, trello_app_name)
    else
      query_params
    end

    "authorize?" <> URI.encode_query(query_params)
      |> Http.process_url
  end

  def get(url, secret), do: Http.get(create_url(url, secret)) |> unwrap_http
  def get!(url, secret), do: Http.get!(create_url(url, secret)) |> unwrap_http

  def post(url, body, secret), do: Http.post(create_url(url, secret), body, %{ "Content-Type": "application/json; charset=utf-8"}) |> unwrap_http
  def post!(url, body, secret), do: Http.post!(create_url(url, secret), body, %{ "Content-Type": "application/json; charset=utf-8"}) |> unwrap_http

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

  def get_member_organizations(member_id, secret), do: get "/members/#{member_id}/organizations", secret
  def get_member_organizations!(member_id, secret), do: get "/members/#{member_id}/organizations", secret

  def get_current_member(secret), do: get("/members/me", secret)
  def get_current_member!(secret), do: get!("/members/me", secret)

  def get_full_board(board_id, secret) do
    with {:ok, board} <- get_board(board_id, secret),
         {:ok, cards} <- get_board_cards(board_id, secret),
         {:ok, labels} <- get_board_labels(board_id, secret),
         {:ok, lists} <- get_board_lists(board_id, secret) do

      lists = Enum.map(lists, fn(list) ->
        Map.put list, :cards, get_lists_with_id(list[:id], "idList", cards)
      end)

      board = Map.put(board, :cards, cards)
        |> Map.put(:labels, labels)
        |> Map.put(:lists, lists)

      {:ok, board}
    end
  end

  def process_error(error), do: error
  def process_success(body), do: body

  defp trello_app_key, do: Application.fetch_env!(:trello, :app_key)
  defp trello_app_name, do: Application.fetch_env!(:trello, :name)
  defp has_query_params?(url), do: Regex.match?(~r/\?/, url)

  defp key do
    if (is_tuple trello_app_key) do
      {:system, key} = trello_app_key

      System.get_env(key)
    else
      trello_app_key
    end
  end
  
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
      if (is_bitstring body), do: {:error, process_error(body)}, else: {:ok, process_success(body)}
    end
  end
end
