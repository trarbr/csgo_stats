defmodule CsgoStatsWeb.MatchView do
  use CsgoStatsWeb, :view

  alias CsgoStats.Matches.Match

  def formatted_roundtime(time_left) do
    minutes = floor(time_left / 60)
    seconds = time_left - minutes * 60
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    "#{minutes}:#{seconds}"
  end

  def timer_class(%Match{phase: :round_over, bomb_timeout: nil}), do: "hide"
  def timer_class(%Match{phase: :freeze_period}), do: "red"
  def timer_class(%Match{bomb_timeout: nil}), do: ""
  def timer_class(_), do: "red"

  def bomb_class(%Match{bomb_timeout: nil}), do: ""
  def bomb_class(_), do: "shown"
end
