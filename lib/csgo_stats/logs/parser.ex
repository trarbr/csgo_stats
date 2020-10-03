defmodule CsgoStats.Logs.Parser do
  @moduledoc """
  Parses CS:GO game server log lines to events
  """
  import NimbleParsec

  require Logger

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  @doc """
  Parse a set of log lines into their corresponding events.

  ## Examples

      iex> CsgoStats.Logs.Parser.parse(~s|11/24/2019 - 21:43:39.781 - World triggered "Game_Commencing"|)
      {:ok, [%CsgoStats.Events.GameCommencing{timestamp: ~N[2019-11-24 21:43:39.781]}]}
  """
  def parse(lines, accumulator \\ [])

  def parse("", accumulator) do
    {:ok, accumulator}
  end

  def parse(lines, accumulator) do
    case do_parse(lines) do
      {:ok, events, "", _, _, _} ->
        {:ok, accumulator ++ events}

      {:ok, events, leftovers, _, _, _} ->
        [unhandled, next_events] =
          case String.split(leftovers, "\n", parts: 2) do
            [unhandled, next_events] -> [unhandled, next_events]
            [unhandled] -> [unhandled, ""]
          end

        Logger.info("event_unhandled||#{unhandled}")
        parse(next_events, accumulator ++ events)

      {:error, error, unparsed, _context, _, _} ->
        {:error, error, unparsed}
    end
  end

  world_event =
    choice([
      ignore(string("World triggered "))
      |> choice([
        Parser.GameCommencing.parser(),
        Parser.MatchStart.parser(),
        Parser.RoundStart.parser(),
        Parser.RoundEnd.parser()
      ]),
      Parser.FreezePeriodStarted.parser(),
      Parser.TeamWon.parser(),
      Parser.GameOver.parser(),
      Parser.Accolade.parser()
    ])

  player_event =
    Parser.Player.parser()
    |> choice([
      Parser.PlayerConnected.parser(),
      Parser.PlayerSwitchedTeam.parser(),
      Parser.PlayerEnteredTheGame.parser(),
      Parser.PlayerDisconnected.parser(),
      Parser.GotTheBomb.parser(),
      Parser.DroppedTheBomb.parser(),
      Parser.PlantedTheBomb.parser(),
      Parser.BeganBombDefuse.parser(),
      Parser.DefusedTheBomb.parser(),
      Parser.KilledByTheBomb.parser(),
      Parser.Attacked.parser(),
      Parser.Killed.parser(),
      Parser.Assisted.parser(),
      Parser.KilledOther.parser(),
      Parser.MoneyChange.parser(),
      Parser.LeftBuyzone.parser(),
      Parser.PickedUp.parser(),
      Parser.Dropped.parser()
    ])
    |> reduce({:set_player, []})

  defp set_player([player, %Events.Attacked{} = event]) do
    %{event | attacker: player}
  end

  defp set_player([player, %Events.Killed{} = event]) do
    %{event | killer: player}
  end

  defp set_player([player, %Events.Assisted{} = event]) do
    %{event | assistant: player}
  end

  defp set_player([player, %Events.KilledOther{} = event]) do
    %{event | killer: player}
  end

  defp set_player([player, event]) do
    %{event | player: player}
  end

  defparsecp(
    :do_parse,
    Parser.Timestamp.parser()
    |> ignore(string(" - "))
    |> choice([
      world_event,
      player_event
    ])
    |> ignore(optional(string("\n")))
    |> reduce({:set_timestamp, []})
    |> repeat(),
    inline: true
  )

  defp set_timestamp([timestamp, event]) do
    %{event | timestamp: timestamp}
  end
end
