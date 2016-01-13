defmodule StockFighter.History do
  def initial do
    %{"lastTrade" => Date.from({{1950, 1, 1}, {0, 0, 0}}), "quotes" => []}
  end

  def update_quotes(all_quotes, new_quote) do
    if all_quotes["lastTrade"] < new_quote["lastTrade"] do
      %{"lastTrade" => new_quote["lastTrade"], "quotes" => [new_quote | all_quotes["quotes"]]}
    else
      all_quotes
    end
  end

  def get_low(all_quotes) do
    all_quotes
    |> quotes
    |> Enum.min
  end

  def get_high(all_quotes) do
    all_quotes
    |> quotes
    |> Enum.max
  end

  def get_average(all_quotes) do
    all_quotes
    |> quotes
    |> _get_average
  end

  def get_local_average(all_quotes) do
    my_quotes = all_quotes
    |> quotes
    |> Enum.take(30)
    |> _get_average
  end

  defp _get_average(my_quotes) do
    Enum.sum(my_quotes) / Enum.count(my_quotes)
  end
  
  def quotes(all_quotes) do
    Enum.map(all_quotes["quotes"], fn(my_quote) ->
      my_quote["last"]
    end)
  end
end
