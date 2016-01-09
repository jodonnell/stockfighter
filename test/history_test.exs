defmodule HistoryTest do
  use ExUnit.Case, async: false

  use Timex
  
  def test_date(hour) do
    Date.from({{2015, 6, 24}, {hour, 50, 34}})
  end

  def initial do
    %{"lastTrade" => test_date(0), "quotes" => []}
  end

  test "can add to the history" do
    all_quotes = StockFighter.History.update_quotes(initial, %{"last" => 200, "lastTrade" => test_date(1)})
    assert StockFighter.History.quotes(all_quotes) == [200]
  end

  test "doesn't add unless updated" do
    all_quotes = StockFighter.History.update_quotes(initial, %{"last" => 200, "lastTrade" => test_date(1)})
    assert StockFighter.History.quotes(all_quotes) == [200]

    all_quotes = StockFighter.History.update_quotes(all_quotes, %{"last" => 300, "lastTrade" => test_date(1)})
    assert StockFighter.History.quotes(all_quotes) == [200]

    all_quotes = StockFighter.History.update_quotes(all_quotes, %{"last" => 400, "lastTrade" => test_date(2)})
    assert StockFighter.History.quotes(all_quotes) == [400, 200]
  end

  test "get min" do
    all_quotes = StockFighter.History.update_quotes(initial, %{"last" => 200, "lastTrade" => test_date(1)})
    |> StockFighter.History.update_quotes(%{"last" => 400, "lastTrade" => test_date(2)})
    assert StockFighter.History.get_low(all_quotes) == 200
  end

  test "get max" do
    all_quotes = StockFighter.History.update_quotes(initial, %{"last" => 200, "lastTrade" => test_date(1)})
    |> StockFighter.History.update_quotes(%{"last" => 400, "lastTrade" => test_date(2)})
    assert StockFighter.History.get_high(all_quotes) == 400
  end

  test "get average" do
    all_quotes = StockFighter.History.update_quotes(initial, %{"last" => 100, "lastTrade" => test_date(1)})
    |> StockFighter.History.update_quotes(%{"last" => 200, "lastTrade" => test_date(2)})
    |> StockFighter.History.update_quotes(%{"last" => 300, "lastTrade" => test_date(3)})
    assert StockFighter.History.get_average(all_quotes) == 200
  end

  test "get local average" do
    all_quotes = StockFighter.History.update_quotes(initial, %{"last" => 100, "lastTrade" => test_date(1)})
    |> StockFighter.History.update_quotes(%{"last" => 200, "lastTrade" => test_date(2)})
    |> StockFighter.History.update_quotes(%{"last" => 300, "lastTrade" => test_date(3)})
    assert StockFighter.History.get_local_average(all_quotes) == 200
  end
  
end
