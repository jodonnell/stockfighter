defmodule StockFighter.History do
  use Timex

  def initial do
    Agent.start_link(fn -> %{"lastTrade" => Date.from({{1950, 1, 1}, {0, 0, 0}}), "quotes" => []} end, name: __MODULE__)
  end

  def quotes do
    Enum.map(all_quotes["quotes"], fn(my_quote) ->
      my_quote["last"]
    end)
  end

  def update_quotes(new_quote) do
    if all_quotes["lastTrade"] < new_quote["lastTrade"] do
        Agent.update(__MODULE__,  fn dict ->
          %{"lastTrade" => new_quote["lastTrade"], "quotes" => [new_quote | dict["quotes"]]}
        end)
    end

    all_quotes
  end

  def get_low() do
    quotes
    |> Enum.min
  end

  def get_high() do
    quotes
    |> Enum.max
  end

  def get_average() do
    quotes
    |> _get_average
  end

  def get_local_average() do
    quotes
    |> Enum.take(30)
    |> _get_average
  end

  defp all_quotes do
    Agent.get(__MODULE__, &(&1))
  end

  defp _get_average(my_quotes) do
    Enum.sum(my_quotes) / Enum.count(my_quotes)
  end

end
