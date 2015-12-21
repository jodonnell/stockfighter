defmodule ChockABlock.Strategy do
  def buy(amount, account, venue, stock) do
    for _ <- 1..(div(amount, 1000)) do
      ChockABlock.Api.quote_for_stock(venue, stock)
      |> make_bid_for_last_quote(account, venue, stock)
    end
  end

  def make_bid_for_last_quote(last_quote, account, venue, stock) do
    IO.puts last_quote["last"]
    ChockABlock.Api.place_an_order(account, venue, stock, last_quote["last"] - 30, 10, "buy", "limit")
  end
end
