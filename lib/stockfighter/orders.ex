defmodule StockFighter.Orders do
  use Timex

  def open(orders) do
    Enum.filter(orders, fn(order) -> order["open"] == true end)
  end

  def cancel_all(orders) do
    Enum.map(open(orders), fn order ->
      StockFighter.Api.cancel_order(order["venue"], order["symbol"], order["id"])
    end)
  end

  def current_net_assets(orders) do
    Enum.map(orders, fn(order) ->
      sum_list(Enum.map(order["fills"], fn(fill) ->
        totalFilled = flip_sign_on_buy(order["direction"], fill["qty"])
        fill["price"] * totalFilled
      end))
    end)
    |> sum_list
  end

  def oldest_open_order(orders) do
    open(orders)
    |> get_min_date
  end

  def get_filled_quantity(orders) do
    Enum.map(orders, fn(order) -> order["totalFilled"] end)
    |> sum_list
  end

  def get_position(orders) do
    Enum.map(orders, &flip_sign_on_sell/1)
    |> sum_list
  end

  defp sum_list(list), do: Enum.reduce(list, 0, &(&1 + &2))

  defp flip_sign_on_sell(order = %{"direction" => "sell"}) do
    order["totalFilled"] * -1
  end

  defp flip_sign_on_sell(order = %{"direction" => "buy"}) do
    order["totalFilled"]
  end

  defp flip_sign_on_buy("sell", qty) do
    qty
  end

  defp flip_sign_on_buy("buy", qty) do
    qty * -1
  end

  defp get_min_date([]) do
    nil
  end

  defp get_min_date(orders) do
    Enum.min_by(orders, fn(order) ->
      order["ts"] |> DateFormat.parse("{ISO}")
    end)
  end
end
