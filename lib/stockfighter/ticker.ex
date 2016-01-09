defmodule StockFighter.Ticker do
  require Logger
  use GenServer

  def start_link(account, venue) do
    GenServer.start_link(__MODULE__, [account: account, venue: venue], name: __MODULE__)
  end

  def get_quote do
    GenServer.call __MODULE__, :get_quote
  end

  def init([account: account, venue: venue]) do
    {:ok, init_state(account, venue)}
  end

  def init_state(account, venue) do
    feed = StockFighter.Api.tickertape_for_venue(account, venue)

    {:ok, agent} = Agent.start_link fn ->
      %{"quoteTime" => nil}
    end

    task = Task.start fn ->
      process_feed(feed, agent, account, venue)
    end

    {agent, task}
  end

  def handle_call(:get_quote, _from, {agent, _} = state) do
    {:reply, Agent.get(agent, &(&1)), state}
  end

  def process_feed(feed, agent, account, venue) do
    Enum.each feed, fn(data) ->
      Agent.update(agent, (fn(state) -> data["quote"] end))
    end

    Logger.debug('Restarting feed')
    feed = StockFighter.Api.tickertape_for_venue(account, venue)
    process_feed(feed, agent, account, venue)
  end
end
