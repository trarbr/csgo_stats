defmodule CsgoStats.Logs.Processor do
  use GenServer

  require Logger

  alias CsgoStats.Logs.Parser
  alias CsgoStats.Matches

  def child_spec(opts) do
    scheduler = Keyword.fetch!(opts, :scheduler)
    id = name = name(scheduler)
    opts = []

    %{
      id: id,
      start: {__MODULE__, :start_link, [opts, name]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(opts, name) do
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def enqueue(entry) do
    processor =
      entry.server_instance_token
      |> :erlang.phash2()
      |> rem(System.schedulers())
      |> name()

    GenServer.cast(processor, {:process, entry})
  end

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:process, entry}, state) do
    events =
      Enum.reduce(entry.lines, [], fn line, acc ->
        event_text = String.slice(line, 28..-1)

        case Parser.parse(event_text) do
          {:ok, %event_type{} = event} ->
            Logger.debug([
              "event_parsed||",
              Atom.to_string(event_type),
              "||",
              event |> Map.from_struct() |> Jason.encode!()
            ])

            [event | acc]

          {:ok, %event_type{} = event, leftovers} ->
            Logger.warn([
              "event_leftover||",
              Atom.to_string(event_type),
              "||",
              event |> Map.from_struct() |> Jason.encode!(),
              "||",
              leftovers
            ])

            [event | acc]

          {:error, _, unparsed} ->
            Logger.error(["event_error||", event_text, "||", unparsed])
            acc
        end
      end)

    Matches.apply(entry.server_instance_token, events)

    {:noreply, state}
  end

  defp name(scheduler) do
    String.to_atom("#{__MODULE__}_#{scheduler}")
  end
end
