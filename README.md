Trello
===

Wrapper for trello api

#### Getting Started
```elixir
config :trello,
  app_key: "23o4hqsfkdhalsdjfalksjdfl;",
  name: "Test App"
```
###### To use env key
```elixir
config :trello,
  app_key: {:system, "TRELLO_KEY"}
```

### Methods
***Secret is from authorization via trello. You can use generate_auth_url to generate the url***

- `generate_auth_url(config)` - %{scope: "account,write,read", exipiry: "never", response_type: "token"}

- `get(url, secret)`
- `get!(url, secret)`

- `post(url, body, secret)`
- `post!(url, body, secret)`

- `put(url, body, secret)`
- `put!(url, body, secret)`

- `delete(url, secret)`
- `delete!(url, secret)`

- `get_board(board_id, secret)`
- `get_board!(board_id, secret)`
- `get_full_board(board_id, secret)` - Board with lists and cards

- `get_board_cards(board_id, secret)`
- `get_board_cards!(board_id, secret)`

- `get_board_labels(board_id, secret)`
- `get_board_labels!(board_id, secret)`

- `get_board_lists(board_id, secret)`
- `get_board_lists!(board_id, secret)`

- `get_label(label_id, secret)`
- `get_label!(label_id, secret)`

- `get_list(list_id, secret)`
- `get_list!(list_id, secret)`

- `add_comment_to_card( card_id, comment, secret )`
- `add_comment_to_card!( card_id, comment, secret )`

- `get_list_cards(list_id, secret)`
- `get_list_cards!(list_id, secret)`

- `get_member(member_id, secret)`
- `get_member!(member_id, secret)`
