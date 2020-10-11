defmodule CsgoStats.Matches.EventHandler do
  @moduledoc """
  Applies events to a match in order to derive the new state of the match.
  """
  use GenServer

  alias CsgoStats.Matches.{DB, Match}

  defstruct [
    :match,
    :received_events,
    :processed_events,
    :event_delay,
    :timer_ref,
    :timers
  ]

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

  def lookup(server_instance_token) do
    case Registry.lookup(__MODULE__, server_instance_token) do
      [{event_handler, _value}] -> {:ok, event_handler}
      [] -> {:error, :not_found}
    end
  end

  def apply(event_handler, events) do
    GenServer.cast(event_handler, {:apply, events})
  end

  def get_events(server_instance_token) do
    {:ok, event_handler} = lookup(server_instance_token)
    GenServer.call(event_handler, :get_events)
  end

  def replay_from_event(server_instance_token, event_index) do
    {:ok, event_handler} = lookup(server_instance_token)
    GenServer.call(event_handler, {:replay_from_event, event_index})
  end

  @impl true
  def init(opts) do
    server_instance_token = Keyword.fetch!(opts, :server_instance_token)
    debug = Keyword.get(opts, :debug, CsgoStats.debug?())

    case Registry.register(__MODULE__, server_instance_token, nil) do
      {:ok, _pid} ->
        match = Match.new(server_instance_token, debug: debug)
        events = Keyword.get(opts, :events, [])

        state = %__MODULE__{
          match: match,
          received_events: events,
          processed_events: [],
          event_delay: 0,
          timers: []
        }

        :timer.send_interval(1_000, :tick)
        {:ok, state, {:continue, {:initial_apply, events}}}

      {:error, {reason, _pid}} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_continue({:initial_apply, []}, state) do
    {:noreply, state}
  end

  def handle_continue({:initial_apply, events} = _msg, state) do
    state = apply_events(state, events)
    match = Match.shift_timeout(state.match, List.last(events))
    DB.upsert(match)

    {:noreply, %{state | match: match}}
  end

  @impl true
  def handle_call(:get_events, _from, state) do
    {:reply, {state.processed_events, state.received_events}, state}
  end

  def handle_call({:replay_from_event, event_index}, _from, state) do
    case Enum.split(state.received_events, event_index) do
      {_previous_events, []} ->
        {:reply, :ok, state}

      {[] = previous_events, [event | _events] = remaining_events} ->
        replay_from_event(state, event, previous_events, remaining_events)

      {previous_events, remaining_events} ->
        event = List.last(previous_events)
        replay_from_event(state, event, previous_events, remaining_events)
    end
  end

  @impl true
  def handle_cast({:apply, []}, state) do
    {:noreply, state}
  end

  def handle_cast({:apply, events}, %{event_delay: offset} = state)
      when offset === 0 do
    state = apply_events(state, events)
    {:noreply, %{state | received_events: state.received_events ++ events}}
  end

  def handle_cast({:apply, events}, state) do
    now = NaiveDateTime.utc_now()
    extra_timers = delay_events(events, state.event_delay, now, state.timer_ref)

    {:noreply,
     %{
       state
       | timers: state.timers ++ extra_timers,
         received_events: state.received_events ++ events
     }}
  end

  @impl true
  def handle_info({:delayed_apply, events, timer_ref}, %{timer_ref: timer_ref} = state) do
    state = apply_events(state, events)
    {:noreply, state}
  end

  def handle_info({:delayed_apply, _events, _timer_ref}, state) do
    # Discard events as the timer_ref did not match what was in state
    {:noreply, state}
  end

  def handle_info(:tick, state) do
    match = Match.apply(state.match, :tick)
    DB.upsert(match)
    {:noreply, %{state | match: match}}
  end

  defp apply_events(state, events) do
    match =
      Enum.reduce(events, state.match, fn event, match ->
        Match.apply(match, event)
      end)

    processed_events =
      if match.debug do
        state.processed_events ++ events
      else
        []
      end

    DB.upsert(match)

    %{state | match: match, processed_events: processed_events}
  end

  defp replay_from_event(state, event, previous_events, remaining_events) do
    Enum.each(state.timers, fn timer ->
      Process.cancel_timer(timer, async: true, info: false)
    end)

    now = NaiveDateTime.utc_now()
    event_delay = NaiveDateTime.diff(now, event.timestamp, :millisecond)
    timer_ref = make_ref()
    timers = delay_events(remaining_events, event_delay, now, timer_ref)

    match = Match.new(state.match.server_instance_token, debug: state.match.debug)

    state = %{
      state
      | match: match,
        processed_events: [],
        timers: timers,
        timer_ref: timer_ref,
        event_delay: event_delay
    }

    {:reply, :ok, state, {:continue, {:initial_apply, previous_events}}}
  end

  defp delay_events(events, delay, reference_timestamp, timer_ref) do
    events
    |> Enum.group_by(fn event -> event.timestamp end)
    |> Enum.map(fn {timestamp, events} ->
      delay =
        timestamp
        |> NaiveDateTime.add(delay, :millisecond)
        |> NaiveDateTime.diff(reference_timestamp, :millisecond)

      Process.send_after(self(), {:delayed_apply, events, timer_ref}, max(delay, 0))
    end)
  end
end
