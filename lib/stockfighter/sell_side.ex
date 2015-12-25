defmodule StockFighter.SellSide do
  def buy(amount, account, venue, stock) do
    _buy(amount, amount, account, venue, stock)
  end


  def _buy(amount_made, _, _, _, _) when amount_made >= 10_000 do
  end

  def _buy(_, amount, account, venue, stock) do
    orders = StockFighter.Api.status_for_all_orders(venue, account)
    StockFighter.Orders.cancel_all(orders["orders"])

    StockFighter.Api.quote_for_stock(venue, stock)
    |> make_bid_for_last_quote(account, venue, stock)

    amount_made = StockFighter.Orders.current_net_assets(orders["orders"])
    IO.puts "Amount made: #{amount_made / 1000}"
    IO.puts ""
    _buy(amount_made / 1000, amount, account, venue, stock)
  end

  def make_bid_for_last_quote(last_quote, account, venue, stock) do
    last = last_quote["last"]
    IO.puts "Last quote: $#{last / 100}"

    StockFighter.Api.place_an_order(account, venue, stock, last - 10, 100, "buy", "limit")
    StockFighter.Api.place_an_order(account, venue, stock, last + 10, 100, "sell", "limit")
  end
end
