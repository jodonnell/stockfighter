defmodule ApiTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @test_exchange "TESTEX"
  @test_stock "FOOBAR"
  @test_account "EXB123456"

  test "stocks on a venue" do
    use_cassette "stocks_on_a_venue" do
      assert StockFighter.Api.stocks_on_a_venue(@test_exchange) ==
        %{"ok" => true, "symbols" => [%{"name" => "Foreign Owned Occluded Bridge Architecture Resources", "symbol" => @test_stock}]}
      end
  end


  test "place an order" do
    use_cassette "place_an_order" do
      assert StockFighter.Api.place_an_order(@test_account, @test_exchange, @test_stock, 100, 100, "buy", "limit") ==
        %{"account" => @test_account, "direction" => "buy", "fills" => [], "id" => 5606, "ok" => true, "open" => true,
          "orderType" => "limit", "originalQty" => 100, "price" => 100, "qty" => 100, "symbol" => @test_stock, "totalFilled" => 0,
          "ts" => "2015-12-21T00:55:21.321969216Z", "venue" => @test_exchange}
    end

  end

  test "orderbook_for_stock" do
    use_cassette "orderbook_for_stock" do
      response = StockFighter.Api.orderbook_for_stock(@test_exchange, @test_stock)

      [first_ask | _] = response["asks"]
      [first_bid | _] = response["bids"]
      assert response["ok"] == true
      assert response["symbol"] == @test_stock
      assert response["venue"] == @test_exchange
      assert first_ask == %{"isBuy" => false, "price" => 2000040, "qty" => 180}
      assert first_bid == %{"isBuy" => true, "price" => 2000000, "qty" => 100}
    end
  end

  test "quote for a stock" do
    use_cassette "quote_for_stock" do
      assert StockFighter.Api.quote_for_stock(@test_exchange, @test_stock) ==
            %{"ask" => 2000040, "askDepth" => 580, "askSize" => 580, "bid" => 2000000, "bidDepth" => 147091, "bidSize" => 522,
              "last" => 2000040, "lastSize" => 10, "lastTrade" => "2015-12-21T00:29:38.571545316Z", "ok" => true,
              "quoteTime" => "2015-12-21T00:55:20.88646802Z", "symbol" => @test_stock, "venue" => @test_exchange}
    end
  end

  test "status_for_order" do
    use_cassette "status_for_order" do
      response = StockFighter.Api.place_an_order(@test_account, @test_exchange, @test_stock, 100, 100, "buy", "limit")
      assert StockFighter.Api.status_for_order(response["id"], @test_exchange, @test_stock) ==
        %{"account" => @test_account, "direction" => "buy", "fills" => [], "id" => 5658, "ok" => true, "open" => true,
          "orderType" => "limit", "originalQty" => 100, "price" => 100, "qty" => 100, "symbol" => @test_stock, "totalFilled" => 0,
          "ts" => "2015-12-21T01:22:04.694908193Z", "venue" => @test_exchange}
    end
  end

  test "status_for_all_orders" do
    use_cassette "status_for_all_orders" do
      response = StockFighter.Api.status_for_all_orders(@test_exchange, @test_account)
      [first_order | _] = response["orders"]
      assert response["ok"] == true
      assert response["venue"] == @test_exchange
      assert first_order == %{"account" => @test_account, "direction" => "buy", "fills" => [], "id" => 16, "ok" => true, "open" => true,
                              "orderType" => "limit", "originalQty" => 10, "price" => 100, "qty" => 10, "symbol" => @test_stock, "totalFilled" => 0,
                              "ts" => "2015-12-20T15:43:08.307871852Z", "venue" => @test_exchange}
    end
  end

  test "cancel_order" do
    use_cassette "cancel_order" do
      response = StockFighter.Api.place_an_order(@test_account, @test_exchange, @test_stock, 100, 100, "buy", "limit")
      assert StockFighter.Api.cancel_order(@test_exchange, @test_stock, response["id"]) ==
        %{"account" => @test_account, "direction" => "buy", "fills" => [], "id" => 5657, "ok" => true, "open" => false,
             "orderType" => "limit", "originalQty" => 100, "price" => 100, "qty" => 0, "symbol" => @test_stock, "totalFilled" => 0,
             "ts" => "2015-12-21T01:21:08.491009244Z", "venue" => @test_exchange}
    end
  end

end
