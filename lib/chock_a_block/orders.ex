defmodule ChockABlock.Orders do
  use Timex

  def oldest_open_order(orders) do
    Enum.filter(orders["orders"], fn(order) -> order["open"] == true end)
    |> Enum.min_by(fn(order) ->
      order["ts"] |> DateFormat.parse("{ISO}")
    end)
  end

  def get_filled_quantity(orders) do
    quantities = Enum.map(orders["orders"], fn(order) ->
      order["totalFilled"]
    end)

    sum_list(quantities)
  end

  defp sum_list(list), do: Enum.reduce(list, 0, &(&1 + &2))
end
