defmodule OrdersTest do
  use ExUnit.Case, async: false


  test "oldest_open_order" do
    test_data = %{"orders" => [%{"ts" => "2015-12-20T15:43:08.307871852Z", "open" => true},
                               %{"ts" => "2014-12-19T15:43:08.307871852Z", "open" => true},
                               %{"ts" => "2014-12-20T15:43:08.307871852Z", "open" => true},
                               %{"ts" => "2013-12-20T15:43:08.307871852Z", "open" => false}]}

    assert StockFighter.Orders.oldest_open_order(test_data) == %{"ts" => "2014-12-19T15:43:08.307871852Z", "open" => true}

    test_data = %{"orders" => [%{"ts" => "2013-12-20T15:43:08.307871852Z", "open" => false}]}

    assert StockFighter.Orders.oldest_open_order(test_data) == nil

  end

  test "get_filled_quantity" do
    test_data = %{"orders" => [%{"totalFilled" => 100},
                               %{"totalFilled" => 200},
                               %{"totalFilled" => 300},
                               %{"totalFilled" => 400}]}

    assert StockFighter.Orders.get_filled_quantity(test_data) == 1000
  end

end
