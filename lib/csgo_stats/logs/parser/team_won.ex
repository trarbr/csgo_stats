defmodule CsgoStats.Logs.Parser.TeamWon do
  import NimbleParsec

  alias CsgoStats.Events
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

  # Example: (CT "0")
  defp team_score() do
    ignore(string("("))
    |> concat(Parser.Team.parser())
    |> ignore(string(~s/ "/))
    |> integer(min: 1)
    |> ignore(string(~s/")/))
  end

  def cast([team, win_condition, :ct, ct_score, :terrorist, terrorist_score]) do
    win_condition =
      case win_condition do
        "Terrorists_Win" -> :terrorists_win
        "CTs_Win" -> :cts_win
        "Target_Bombed" -> :target_bombed
        "Bomb_Defused" -> :bomb_defused
        "Target_Saved" -> :target_saved
      end

    %Events.TeamWon{
      team: team,
      win_condition: win_condition,
      ct_score: ct_score,
      terrorist_score: terrorist_score
    }
  end
end
