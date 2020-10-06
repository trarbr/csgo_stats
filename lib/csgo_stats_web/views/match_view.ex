defmodule CsgoStatsWeb.MatchView do
  use CsgoStatsWeb, :view

  alias CsgoStats.Matches.Match

  defp current_timeout(%Match{bomb_timeout: nil, round_timeout: nil, freeze_timeout: nil}),
    do: NaiveDateTime.utc_now()

  defp current_timeout(%Match{bomb_timeout: nil, round_timeout: nil} = match),
    do: match.freeze_timeout

  defp current_timeout(%Match{bomb_timeout: nil} = match), do: match.round_timeout

  defp current_timeout(%Match{} = match), do: match.bomb_timeout

  def timer_class(%Match{phase: :round_over, bomb_timeout: nil}), do: "hide"
  def timer_class(%Match{phase: :freeze_period}), do: "red"
  def timer_class(%Match{bomb_timeout: nil}), do: ""

  def timer_class(%Match{wins: wins, phase: :round_over}) do
    case List.last(wins) do
      :bomb_defused -> "hide"
      :target_bombed -> "hide"
      _ -> "red"
    end
  end

  def timer_class(_), do: "red"

  def bomb_class(%Match{bomb_timeout: nil}), do: ""

  def bomb_class(%Match{wins: wins, phase: :round_over}) do
    case List.last(wins) do
      :bomb_defused -> "shown defused"
      _ -> "shown"
    end
  end

  def bomb_class(_), do: "shown"
end
