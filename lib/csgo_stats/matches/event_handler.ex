defmodule CsgoStats.Matches.EventHandler do
  @moduledoc """
  Applies events to a match in order to derive the new state of the match.
  """
  use GenServer

  alias CsgoStats.Matches.{DB, Match}

  def lookup(server_instance_token) do
    case Registry.lookup(__MODULE__, server_instance_token) do
      [{event_handler, _value}] -> {:ok, event_handler}
      [] -> {:error, :not_found}
    end
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def apply(event_handler, events) do
    GenServer.cast(event_handler, {:apply, events})
  end

  @impl true
  def init(opts) do
    server_instance_token = Keyword.fetch!(opts, :server_instance_token)

    case Registry.register(__MODULE__, server_instance_token, nil) do
      {:ok, _pid} ->
        match = Match.new(server_instance_token)
        state = %{match: match}
        events = Keyword.get(opts, :events, [])
        {:ok, state, {:continue, {:apply, events}}}

      {:error, {reason, _pid}} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_continue({:apply, events}, state) do
    apply_events(state, events)
  end

  @impl true
  def handle_cast({:apply, events}, state) do
    apply_events(state, events)
  end

  defp apply_events(state, events) do
    match =
      Enum.reduce(events, state.match, fn event, match ->
        Match.apply(match, event)
      end)

    DB.upsert(match)

    {:noreply, %{state | match: match}}
  end
end
