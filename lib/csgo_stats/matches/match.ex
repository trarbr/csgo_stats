defmodule CsgoStats.Matches.Match do
  @behaviour :gen_statem

  alias CsgoStats.Matches.Registry

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
    :gen_statem.start_link(__MODULE__, opts, [])
  end

  def apply(match, events) do
    :gen_statem.cast(match, {:apply, events})
  end

  @impl true
  def callback_mode(), do: [:handle_event_function]

  @impl true
  def init(opts) do
    server_instance_token = Keyword.fetch!(opts, :server_instance_token)

    case Registry.register(server_instance_token) do
      {:ok, _pid} ->
        events = Keyword.get(opts, :events, [])
        data = %{}
        actions = events_to_actions(events)
        {:ok, :initial_state, data, actions}

      {:error, {reason, _pid}} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_event(:cast, {:apply, events}, :initial_state, _data) do
    actions = events_to_actions(events)
    {:keep_state_and_data, actions}
  end

  def handle_event(event_type, event, state, data) do
    IO.inspect({:__MODULE__, {event_type, event, state, data}})
    :keep_state_and_data
  end

  defp events_to_actions(events) do
    Enum.map(events, fn event -> {:next_event, :internal, {:apply, event}} end)
  end
end
