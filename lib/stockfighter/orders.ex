defmodule StockFighter.Orders do
  use Timex

  def oldest_open_order(orders) do
    Enum.filter(orders["orders"], fn(order) -> order["open"] == true end)
    |> get_min_date
  end

  def get_filled_quantity(orders) do
    quantities = Enum.map(orders["orders"], fn(order) ->
      order["totalFilled"]
    end)

    sum_list(quantities)
  end

  defp sum_list(list), do: Enum.reduce(list, 0, &(&1 + &2))


  defp get_min_date([]) do
    nil
  end

  defp get_min_date(orders) do
    Enum.min_by(orders, fn(order) ->
      order["ts"] |> DateFormat.parse("{ISO}")
    end)
  end
end
