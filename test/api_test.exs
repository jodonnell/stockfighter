defmodule ApiTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney


  test "the truth" do
    use_cassette "api" do
      assert ChockABlock.Api.quote_for_stock("WEAREX", "APIY") == {:ok,
                                                                   %{"ask" => 9455, "askDepth" => 36231, "askSize" => 12077, "bid" => 9046, "bidDepth" => 38766, "bidSize" => 12922,
                                                                     "last" => 9674, "lastSize" => 65, "lastTrade" => "2015-12-18T04:49:30.358468548Z", "ok" => true,
                                                                     "quoteTime" => "2015-12-18T04:49:30.449020896Z", "symbol" => "APIY", "venue" => "WEAREX"}}
    end
  end
end
