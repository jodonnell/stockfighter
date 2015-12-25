defmodule StockFighter.Strategy do


  def buy(amount, account, venue, stock) do
    _buy(amount, amount, account, venue, stock)
  end


  def _buy(amount_left, _, _, _, _) when amount_left <= 0 do
  end

  def _buy(_, amount, account, venue, stock) do
    StockFighter.Api.quote_for_stock(venue, stock)
    |> make_bid_for_last_quote(account, venue, stock)

    orders = StockFighter.Api.status_for_all_orders(venue, account)

    oo = StockFighter.Orders.oldest_open_order(orders["orders"])
    if oo != nil do
      StockFighter.Api.cancel_order(venue, stock, oo["id"])
    end

    quantity = StockFighter.Orders.get_filled_quantity(orders["orders"])
    amount_left = amount - quantity
    IO.puts "Amount purchased: #{quantity}"
    IO.puts "Amount left: #{amount_left}"
    IO.puts ""
    _buy(amount_left, amount, account, venue, stock)
  end

  def make_bid_for_last_quote(last_quote, account, venue, stock) do
    last = last_quote["last"]
    IO.puts "Last quote: $#{last / 100}"

    :random.seed(:erlang.now())
    buy = :random.uniform(2200 + 400)
    response = StockFighter.Api.place_an_order(account, venue, stock, last - 10, buy, "buy", "limit")
    IO.puts response["price"]
  end
end
