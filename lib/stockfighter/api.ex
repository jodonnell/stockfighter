defmodule StockFighter.Api do
  use Timex

  def tickertape_for_venue(account, venue) do
    get_stream("/ws/#{account}/venues/#{venue}/tickertape")
  end

  def tickertape_for_stock(account, venue, stock) do
    get_stream("/ws/#{account}/venues/#{venue}/tickertape/stocks/#{stock}")
  end

  def stocks_on_a_venue(venue) do
    "/venues/#{venue}/stocks"
    |> get
  end

  def orderbook_for_stock(venue, stock) do
    "/venues/#{venue}/stocks/#{stock}"
    |> get
  end

  def place_an_order(account, venue, stock, price, qty, direction, order_type) do
    {:ok, json} = JSX.encode(%{
          "account": account,
          "venue": venue,
          "stock": stock,
          "qty": qty,
          "price": price,
          "direction": direction,
          "orderType": order_type })
    post("/venues/#{venue}/stocks/#{stock}/orders", json)
  end

  def quote_for_stock(venue, stock) do
    "/venues/#{venue}/stocks/#{stock}/quote"
    |> get
    |> get_time("lastTrade")
    |> get_time("quoteTime")
  end

  def get_time(my_quote, key) do
    {:ok, date} = my_quote[key] |> DateFormat.parse("{ISO}")
     %{my_quote | key => date}
  end

  def status_for_order(id, venue, stock) do
    "/venues/#{venue}/stocks/#{stock}/orders/#{id}"
    |> get
  end

  def status_for_all_orders(venue, account) do
    "/venues/#{venue}/accounts/#{account}/orders"
    |> get
  end

  def cancel_order(venue, stock, order) do
    "/venues/#{venue}/stocks/#{stock}/orders/#{order}"
    |> delete
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

  defp handle_response(%HTTPoison.Response{status_code: 200, body: body}), do: {:ok, JSX.decode(body) }

  defp api_url_base do
    Application.get_env(:stockfighter, :api_url_base)
  end

  defp api_header do
    ["X-Starfighter-Authorization": Application.get_env(:stockfighter, :api_key)]
  end

  defp get_symbols({:ok, list}) do
    [head | _] = list["symbols"]
    head
  end

  defp get_info({:ok, list}) do
    {:ok, thing} = list
    thing
  end

  defp get_stream(path) do
    Stream.resource(
      fn -> get_socket(path) end,
      &iter_socket/1,
      fn(socket) -> Socket.Web.close(socket) end
    )
  end

  defp get_socket(path) do
    url = String.replace(api_url_base <> path, "https", "wss")
    {:ok, socket} = Socket.connect(url)
    socket
  end

  defp iter_socket(socket) do
    case Socket.Web.recv(socket) do
      {:ok, {:text, data}} ->
        {[JSX.decode!(data)], socket}

      {:error, msg} ->
        {:halt, socket}

      _ ->
        iter_socket(socket)
    end
  end
end
