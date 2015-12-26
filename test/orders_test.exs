defmodule OrdersTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  test "oldest_open_order" do
    test_data = [%{"ts" => "2015-12-20T15:43:08.307871852Z", "open" => true},
                 %{"ts" => "2014-12-19T15:43:08.307871852Z", "open" => true},
                 %{"ts" => "2014-12-20T15:43:08.307871852Z", "open" => true},
                 %{"ts" => "2013-12-20T15:43:08.307871852Z", "open" => false}]

    assert StockFighter.Orders.oldest_open_order(test_data) == %{"ts" => "2014-12-19T15:43:08.307871852Z", "open" => true}

    test_data = [%{"ts" => "2013-12-20T15:43:08.307871852Z", "open" => false}]

    assert StockFighter.Orders.oldest_open_order(test_data) == nil

  end

  test "get_filled_quantity" do
    test_data = [%{"totalFilled" => 100},
                 %{"totalFilled" => 200},
                 %{"totalFilled" => 300},
                 %{"totalFilled" => 400}]

    assert StockFighter.Orders.get_filled_quantity(test_data) == 1000
  end

  test "get_position" do
    test_data = [%{"totalFilled" => 100, "direction" => "buy"},
                 %{"totalFilled" => 200, "direction" => "buy"},
                 %{"totalFilled" => 300, "direction" => "sell"},
                 %{"totalFilled" => 400, "direction" => "buy"}]

    assert StockFighter.Orders.get_position(test_data) == 400
  end

  test "open_orders" do
    test_data = [%{"open" => true},
                 %{"open" => false}]

    assert StockFighter.Orders.open(test_data) == [%{"open" => true}]
  end

  test "cancel_all" do
    use_cassette "cancel_all" do
      test_data = [%{"open" => true, "venue" => "TESTEX", "symbol" => "FOOBAR", "id" => 1},
                   %{"open" => false}]


      [canceled_order | _] = StockFighter.Orders.cancel_all(test_data)
      assert canceled_order["id"] == 1
    end
  end

  test "current_cash" do
    test_data = [%{"direction" => "buy", "fills" => [ %{"price" => 1, "qty" => 1} ]},
                 %{"direction" => "buy", "fills" => [ %{"price" => 1, "qty" => 1}, %{"price" => 2, "qty" => 2} ]},
                 %{"direction" => "buy", "fills" => [ %{"price" => 3, "qty" => 3} ]},
                 %{"direction" => "sell", "fills" => [ %{"price" => 1, "qty" => 1} ]},
                 %{"direction" => "sell", "fills" => [ %{"price" => 1, "qty" => 1}, %{"price" => 2, "qty" => 2} ]},
                 %{"direction" => "sell", "fills" => [ %{"price" => 3, "qty" => 3} ]} ]

    assert StockFighter.Orders.current_cash(test_data) == 0
  end

  test "net_asset_value" do
    test_data = [%{"totalFilled" => 10, "direction" => "buy"},
                 %{"totalFilled" => 20, "direction" => "buy"},
                 %{"totalFilled" => 30, "direction" => "sell"},
                 %{"totalFilled" => 40, "direction" => "buy"}]

    assert StockFighter.Orders.get_position(test_data) == 40
    assert StockFighter.Orders.net_asset_value(test_data, 10) == 400

    #test_data = [%{"totalFilled" => 1, "direction" => "sell"}]

    # assert StockFighter.Orders.get_position(test_data) == -1
    # assert StockFighter.Orders.net_asset_value(test_data, 10) == 400

  end

  test "profit" do
    test_data = [%{"totalFilled" => 1, "direction" => "buy", "fills" => [ %{"price" => 1, "qty" => 1} ]},
                 %{"totalFilled" => 3, "direction" => "buy", "fills" => [ %{"price" => 1, "qty" => 1}, %{"price" => 2, "qty" => 2} ]},
                 %{"totalFilled" => 3, "direction" => "buy", "fills" => [ %{"price" => 3, "qty" => 3} ]},
                 %{"totalFilled" => 1, "direction" => "sell", "fills" => [ %{"price" => 1, "qty" => 1} ]}]

    assert StockFighter.Orders.current_cash(test_data) == -14
    assert StockFighter.Orders.net_asset_value(test_data, 10) == 60
    assert StockFighter.Orders.profit(test_data, 10) == 60 - 14
  end


end
