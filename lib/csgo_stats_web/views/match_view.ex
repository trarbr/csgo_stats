defmodule CsgoStatsWeb.MatchView do
  use CsgoStatsWeb, :view

  alias CsgoStats.Matches.Match.Player

  def timer_class(match) do
    case match.phase do
      :freeze_period -> "red"
      :round_started -> ""
      :bomb_planted -> "red"
      _ -> "hide"
    end
  end

  def formatted_time_left(nil), do: ""

  def formatted_time_left(time_left) do
    minutes = floor(time_left / 60)

    seconds =
      (time_left - minutes * 60)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    "#{minutes}:#{seconds}"
  end

  def bomb_class(match) do
    case match.phase do
      :bomb_planted -> "shown"
      {:round_over, :target_bombed} -> "shown"
      {:round_over, :bomb_defused} -> "shown defused"
      _ -> ""
    end
  end

  def player_class(%Player{health: 0}), do: "dead"
  def player_class(_), do: ""

  def events(match) do
    {processed_events, received_events} =
      CsgoStats.Matches.EventHandler.get_events(match.server_instance_token)

    "#{Enum.count(processed_events)}/#{Enum.count(received_events)}"
  end
end
