defmodule CsgoStats.Logs.Parser.MatchStart do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: World triggered "Match_Start" on "de_inferno"
  def parser() do
    ignore(string(~s/"Match_Start" on "/))
    |> concat(Parser.GameMap.parser())
    |> ignore(string(~s/"/))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([game_map]) do
    %Events.MatchStart{game_map: game_map}
  end
end
