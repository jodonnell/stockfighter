defmodule ChockABlock.Strategy do


  def buy(amount, account, venue, stock) do
    _buy(amount, amount, account, venue, stock)
  end


  def _buy(amount_left, _, _, _, _) when amount_left <= 0 do
  end

  def _buy(_, amount, account, venue, stock) do
    ChockABlock.Api.quote_for_stock(venue, stock)
    |> make_bid_for_last_quote(account, venue, stock)
    |> get_id

    orders = ChockABlock.Api.status_for_all_orders(venue, account)

    oo = ChockABlock.Orders.oldest_open_order(orders)
    ChockABlock.Api.cancel_order(venue, stock, oo["id"])

    quantity = ChockABlock.Orders.get_filled_quantity(orders)
    amount_left = amount - quantity
    IO.puts "Amount purchased: #{quantity}"
    IO.puts "Amount left: #{amount_left}"
    IO.puts ""
    _buy(amount_left, amount, account, venue, stock)
  end

  def make_bid_for_last_quote(last_quote, account, venue, stock) do
    last = last_quote["last"]
    IO.puts "Last quote: $#{last / 100}"
    ChockABlock.Api.place_an_order(account, venue, stock, last - 5, 10000, "buy", "limit")
  end

  def get_id(order) do
    order["id"]
  end


end
