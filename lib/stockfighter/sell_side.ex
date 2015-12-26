defmodule StockFighter.SellSide do
  def buy(amount, account, venue, stock) do
    _buy(amount, amount, account, venue, stock)
  end


  def _buy(amount_made, _, _, _, _) when amount_made >= 10_000 do
  end

  def _buy(_, amount, account, venue, stock) do
    orders = StockFighter.Api.status_for_all_orders(venue, account)
    StockFighter.Orders.cancel_all(orders["orders"])

    last_quote = StockFighter.Api.quote_for_stock(venue, stock)
    last = last_quote["last"]

    amount_made = StockFighter.Orders.profit(orders["orders"], last)
    IO.puts "Profit: #{amount_made / 100}"

    position = StockFighter.Orders.get_position(orders["orders"])
    make_bid_for_last_quote(position, last_quote, account, venue, stock)

    IO.puts ""
    _buy(amount_made / 1000, amount, account, venue, stock)
  end

  def make_bid_for_last_quote(position, last_quote, account, venue, stock) do
    buy_quantity = 100
    sell_quantity = 100

    if position > 300 do
      buy_quantity = 20
    end

    if position < -300 do
      sell_quantity = 20
    end

    middle = div(last_quote["ask"] - last_quote["bid"], 2) + last_quote["bid"]

    StockFighter.Api.place_an_order(account, venue, stock, middle - 10, buy_quantity, "buy", "limit")
    StockFighter.Api.place_an_order(account, venue, stock, middle + 10, sell_quantity, "sell", "limit")
  end
end
