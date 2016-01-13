defmodule StockFighter.SellSide do
  def buy(account, venue, stock) do
    { :ok, _ } = StockFighter.Ticker.start_link(account, venue)
    all_quotes = StockFighter.History.update_quotes(StockFighter.History.initial)
    _buy(account, venue, stock, all_quotes)
  end

  def _buy(account, venue, stock, all_quotes) do
    last_quote = StockFighter.Ticker.get_quote
    if last_quote["quoteTime"] do
      IO.inspect(last_quote)
      last = last_quote["last"]

      orders = StockFighter.Api.status_for_all_orders(venue, account)
      StockFighter.Orders.cancel_all(orders["orders"])

      amount_made = StockFighter.Orders.profit(orders["orders"], last)
      IO.puts "Profit: #{amount_made / 100}"

      position = StockFighter.Orders.get_position(orders["orders"])

      all_quotes = StockFighter.History.update_quotes(last_quote)
      average = StockFighter.History.get_local_average(all_quotes)

      IO.puts ""
      _buy(account, venue, stock, all_quotes)
    else
      _buy(account, venue, stock, all_quotes)
    end
  end

  def make_bid_for_last_quote(position, last_quote, account, venue, stock) do
    StockFighter.Api.place_an_order(account, venue, stock, last_quote["last"] - 10, buy_quantity(position), "buy", "limit")
    StockFighter.Api.place_an_order(account, venue, stock, last_quote["last"] + 10, sell_quantity(position), "sell", "limit")
  end

  defp buy_quantity(position) when position > 300 do
    20
  end

  defp buy_quantity(position) do
    100
  end

  defp sell_quantity(position) when position < -300 do
    20
  end

  defp sell_quantity(position) do
    100
  end

end
