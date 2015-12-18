defmodule ChockABlock.Api do
  def stocks_on_a_venue(venue) do
    "/venues/#{venue}/stocks"
    |> get
  end

  def orderbook_for_stock(venue, stock) do
    "/venues/#{venue}/stocks/#{stock}"
    |> get
  end

  def place_an_order(account, venue, stock, price, qty, direction, order_type) do
    post("/venues/#{venue}/stocks/#{stock}/orders",
         :jsx.encode(%{
               "account": account,
               "venue": venue,
               "stock": stock,
               "qty": qty,
               "price": price,
               "direction": direction,
               "orderType": order_type }))
  end

  def quote_for_stock(venue, stock) do
    "/venues/#{venue}/stocks/#{stock}/quote"
    |> get
  end

  def status_for_order(id, venue, stock) do
    "/venues/#{venue}/stocks/#{stock}/orders/#{id}"
    |> get
  end

  def cancel_order(venue, stock, order) do
    "/venues/#{venue}/stocks/#{stock}/orders/#{order}"
    |> delete
  end

  def status_for_all_orders(venue, account) do
    "/venues/#{venue}/accounts/#{account}/orders"
    |> get
  end

  defp post(url, body) do
    api_url_base <> url
    |> HTTPoison.post!(body, api_header)
    |> handle_response
    |> get_info
  end

  defp delete(url) do
    api_url_base <> url
    |> HTTPoison.delete!(api_header)
    |> handle_response
    |> get_info
  end

  defp get(url) do
    api_url_base <> url
    |> HTTPoison.get!(api_header)
    |> handle_response
    |> get_info
  end

  defp handle_response(%HTTPoison.Response{status_code: 200, body: body}), do: {:ok, :jsx.decode(body) }

  defp api_url_base do
    Application.get_env(:chock_a_block, :api_url_base)
  end

  defp api_header do
    ["X-Starfighter-Authorization": Application.get_env(:chock_a_block, :api_key)]
  end

  defp get_symbols({:ok, list}) do
    [head | _] = list["symbols"]
    head
  end

  defp get_info({:ok, list}) do
    list
  end
end
