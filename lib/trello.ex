defmodule Trello do
  alias Trello.Http
  alias Trello.Config

  def get(url, secret), do: Http.get(create_url(url, secret)) |> unwrap_http
  def get!(url, secret), do: Http.get!(create_url(url, secret)) |> unwrap_http

  def post(url, body, secret), do: Http.post(create_url(url, secret), body, %{ "Content-Type": "application/json; charset=utf-8"}) |> unwrap_http
  def post!(url, body, secret), do: Http.post!(create_url(url, secret), body, %{ "Content-Type": "application/json; charset=utf-8"}) |> unwrap_http

  @doc """
  post via multipart/form-data
  requried for attachments
      body: [{"name", "value"}, {:file, path_to_file}]
  """
  def post_multipart(url, body, secret) do
    Http.post(create_url(url, secret), {:multipart, body}, %{"Content-Type": "multipart/form-data"}) |> unwrap_http
  end
  def post_multipart!(url, body, secret) do
    Http.post!(create_url(url, secret), {:multipart, body}, %{"Content-Type": "multipart/form-data"}) |> unwrap_http
  end

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

  def add_comment_to_card(card_id, comment, secret), do: post "/cards/#{card_id}/actions/comments", %{text: comment}, secret
  def add_comment_to_card!(card_id, comment, secret), do: post! "/cards/#{card_id}/actions/comments", %{text: comment}, secret

  @doc """
    https://developers.trello.com/advanced-reference/card#post-1-cards-card-id-or-shortlink-attachments
    [{"name", "value"},  {"mimeType", "value"}, {:file, path_to_file}]
    opts
      file (optional)     Valid Values: A file
      url (optional)      Valid Values: A URL starting with http:// or https:// or null
      name (optional)     Valid Values: a string with a length from 0 to 256
      mimeType (optional) Valid Values: a string with a length from 0 to 256
  """
  @valid_attachment_opts [:file, "name", "mimeType", "url"]
  def add_attachment_to_card(card_id, opts, secret),  do: add_attachment_to_card(validate_attachment_opts(opts), card_id, opts, secret)
  def add_attachment_to_card!(card_id, opts, secret), do: add_attachment_to_card!(validate_attachment_opts(opts), card_id, opts, secret)

  def add_attachment_to_card(true, card_id, opts, secret),    do: post_multipart("cards/#{card_id}/attachments", opts, secret)
  def add_attachment_to_card(false, _card_id, opts, _secret), do: raise "only following keys allowed #{inspect @valid_attachment_opts} \n --> #{inspect opts}"

  def add_attachment_to_card!(true, card_id, opts, secret),    do: post_multipart!("cards/#{card_id}/attachments", opts, secret)
  def add_attachment_to_card!(false, _card_id, opts, _secret), do: raise "only following keys allowed #{inspect @valid_attachment_opts} \n --> #{inspect opts}"
  defp validate_attachment_opts(opts), do: Enum.all?(opts, fn({k,_v})-> k in [:file, "name", "mimeType", "url"] end)

  def get_list_cards(list_id, secret), do: get "/lists/#{list_id}/cards", secret
  def get_list_cards!(list_id, secret), do: get! "/lists/#{list_id}/cards", secret

  def get_member(member_id, secret), do: get "/members/#{member_id}", secret
  def get_member!(member_id, secret), do: get! "/members/#{member_id}", secret

  def get_member_organizations(member_id, secret), do: get "/members/#{member_id}/organizations", secret
  def get_member_organizations!(member_id, secret), do: get "/members/#{member_id}/organizations", secret

  def get_current_member(secret), do: get("/members/me", secret)
  def get_current_member!(secret), do: get!("/members/me", secret)

  def get_full_board(board_id, secret) do
    with {:ok, board}  <- get_board(board_id, secret),
         {:ok, cards}  <- get_board_cards(board_id, secret),
         {:ok, labels} <- get_board_labels(board_id, secret),
         {:ok, lists}  <- get_board_lists(board_id, secret) do

      lists = Enum.map(lists, fn(list) ->
        Map.put list, :cards, get_lists_with_id(list[:id], "idList", cards)
      end)

      board = board
        |> Map.put(:cards,  cards)
        |> Map.put(:labels, labels)
        |> Map.put(:lists,  lists)

      {:ok, board}
    end
  end

  def process_error(error),  do: error
  def process_success(body), do: body

  defp has_query_params?(url), do: Regex.match?(~r/\?/, url)

  defp get_lists_with_id(id, idName, list) do
    Enum.filter list, fn(item) ->
      Map.get(item, String.to_atom(idName)) == id
    end
  end

  defp create_url(url, secret) do
    params = "token=#{secret}&key=#{Config.key}"
    seperator = if has_query_params?(url), do: "&", else: "?"

    url <> seperator <> params
  end

  defp unwrap_http(response) do
    with {:ok, %HTTPoison.Response{body: body}} <- response do
      if (is_bitstring body), do: {:error, process_error(body)}, else: {:ok, process_success(body)}
    end
  end
end
