defmodule HistoryTest do
  use ExUnit.Case, async: false

  use Timex
  
  def test_date(hour) do
    Date.from({{2015, 6, 24}, {hour, 50, 34}})
  end

  test "initializes" do
    StockFighter.History.initial
    assert StockFighter.History.quotes() == []
  end

  test "can add to the history" do
    StockFighter.History.initial
    StockFighter.History.update_quotes(%{"last" => 200, "lastTrade" => test_date(1)})
    assert StockFighter.History.quotes() == [200]
  end

  test "doesn't add unless updated" do
    StockFighter.History.initial
    StockFighter.History.update_quotes(%{"last" => 200, "lastTrade" => test_date(1)})
    assert StockFighter.History.quotes() == [200]

    StockFighter.History.update_quotes(%{"last" => 300, "lastTrade" => test_date(1)})
    assert StockFighter.History.quotes() == [200]

    StockFighter.History.update_quotes(%{"last" => 400, "lastTrade" => test_date(2)})
    assert StockFighter.History.quotes() == [400, 200]
  end

  test "get min" do
    StockFighter.History.initial
    StockFighter.History.update_quotes(%{"last" => 200, "lastTrade" => test_date(1)})
    StockFighter.History.update_quotes(%{"last" => 400, "lastTrade" => test_date(2)})
    assert StockFighter.History.get_low() == 200
  end

  test "get max" do
    StockFighter.History.initial
    StockFighter.History.update_quotes(%{"last" => 200, "lastTrade" => test_date(1)})
    StockFighter.History.update_quotes(%{"last" => 400, "lastTrade" => test_date(2)})
    assert StockFighter.History.get_high() == 400
  end

  test "get average" do
    StockFighter.History.initial
    StockFighter.History.update_quotes(%{"last" => 100, "lastTrade" => test_date(1)})
    StockFighter.History.update_quotes(%{"last" => 200, "lastTrade" => test_date(2)})
    StockFighter.History.update_quotes(%{"last" => 300, "lastTrade" => test_date(3)})
    assert StockFighter.History.get_average() == 200
  end

  test "get local average" do
    StockFighter.History.initial
    StockFighter.History.update_quotes(%{"last" => 100, "lastTrade" => test_date(1)})
    StockFighter.History.update_quotes(%{"last" => 200, "lastTrade" => test_date(2)})
    StockFighter.History.update_quotes(%{"last" => 300, "lastTrade" => test_date(3)})
    assert StockFighter.History.get_local_average() == 200
  end
  
end
