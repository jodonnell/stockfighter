defmodule ChockABlock.Api do
  def stocks_on_pfex do
    stocks_on_a_venue("DTOTEX")
  end

  def stocks_on_a_venue(venue) do
    HTTPoison.get!("https://api.stockfighter.io/ob/api/venues/#{venue}/stocks")
    |> handle_response
    |> get_symbols
  end

  def orderbook_for_stock(venue, stock) do
    HTTPoison.get!("https://api.stockfighter.io/ob/api/venues/#{venue}/stocks/#{stock}")
    |> handle_response
    |> get_info
  end

  def place_an_order(account, venue, stock, price, qty, direction, order_type) do
    HTTPoison.post!("https://api.stockfighter.io/ob/api/venues/#{venue}/stocks/#{stock}/orders",
                    :jsx.encode(%{
                          "account": account,
                          "venue": venue,
                          "stock": stock,
                          "qty": qty,
                          "price": price,
                          "direction": direction,
                          "orderType": order_type
                            }),
                    ["X-Starfighter-Authorization": Application.get_env(:chock_a_block, :api_key)])
    |> handle_response
    |> get_info
  end

  def quote_for_stock(venue, stock) do
    "https://api.stockfighter.io/ob/api/venues/#{venue}/stocks/#{stock}/quote"
    |> HTTPoison.get!(["X-Starfighter-Authorization": Application.get_env(:chock_a_block, :api_key)])
    |> handle_response
    |> get_info
  end

  def status_for_order(id, venue, stock) do
    "https://api.stockfighter.io/ob/api/venues/#{venue}/stocks/#{stock}/orders/#{id}"
    |> HTTPoison.get!(["X-Starfighter-Authorization": Application.get_env(:chock_a_block, :api_key)])
    |> handle_response
    |> get_info
  end

  def cancel_order(venue, stock, order) do
    HTTPoison.delete!("https://api.stockfighter.io/ob/api/venues/#{venue}/stocks/#{stock}/orders/#{order}", ["X-Starfighter-Authorization": Application.get_env(:chock_a_block, :api_key)])
    |> handle_response
    |> get_info
  end

  def status_for_all_orders(venue, account) do
    HTTPoison.get!("https://api.stockfighter.io/ob/api/venues/#{venue}/accounts/#{account}/orders", ["X-Starfighter-Authorization": Application.get_env(:chock_a_block, :api_key)])
    |> handle_response
    |> get_info
  end

  def handle_response(%HTTPoison.Response{status_code: 200, body: body}), do: {:ok, :jsx.decode(body) }

  defp get_symbols({:ok, list}) do
    [head | _] = list["symbols"]
    head
  end

  defp get_info({:ok, list}) do
    list
  end
end
