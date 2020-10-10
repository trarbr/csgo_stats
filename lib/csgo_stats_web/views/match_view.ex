defmodule CsgoStatsWeb.MatchView do
  use CsgoStatsWeb, :view

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
end
