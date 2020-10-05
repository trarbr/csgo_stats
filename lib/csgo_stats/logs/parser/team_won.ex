defmodule CsgoStats.Logs.Parser.TeamWon do
  import NimbleParsec

  alias CsgoStats.{Events, Types}
  alias CsgoStats.Logs.Parser

  # Example: Team "TERRORIST" triggered "SFUI_Notice_Terrorists_Win" (CT "0") (T "1")
  def parser() do
    ignore(string(~s/Team "/))
    |> concat(Parser.Team.parser())
    |> ignore(string(~s/" triggered "/))
    |> concat(win_condition())
    |> ignore(string(~s/" /))
    |> concat(team_score())
    |> ignore(string(" "))
    |> concat(team_score())
    |> reduce({__MODULE__, :cast, []})
  end

  # Example: SFUI_Notice_Terrorists_Win
  defp win_condition() do
    ignore(string("SFUI_Notice_"))
    |> choice([
      string("Terrorists_Win"),
      string("Target_Bombed"),
      string("Bomb_Defused"),
      string("Target_Saved"),
      string("CTs_Win")
    ])
  end

  Enum.each(Types.win_conditions(), fn
    :terrorists_win -> defp cast_win_condition("Terrorists_Win"), do: :terrorists_win
    :cts_win -> defp cast_win_condition("CTs_Win"), do: :cts_win
    :target_bombed -> defp cast_win_condition("Target_Bombed"), do: :target_bombed
    :bomb_defused -> defp cast_win_condition("Bomb_Defused"), do: :bomb_defused
    :target_saved -> defp cast_win_condition("Target_Saved"), do: :target_saved
  end)

  # Example: (CT "0")
  defp team_score() do
    ignore(string("("))
    |> concat(Parser.Team.parser())
    |> ignore(string(~s/ "/))
    |> integer(min: 1)
    |> ignore(string(~s/")/))
  end

  def cast([team, win_condition, :ct, ct_score, :terrorist, terrorist_score]) do
    win_condition = cast_win_condition(win_condition)

    %Events.TeamWon{
      team: team,
      win_condition: win_condition,
      ct_score: ct_score,
      terrorist_score: terrorist_score
    }
  end
end
