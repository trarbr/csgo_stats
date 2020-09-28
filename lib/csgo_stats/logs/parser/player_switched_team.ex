defmodule CsgoStats.Logs.Parser.PlayerSwitchedTeam do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: "Uri<13><BOT>" switched from team <Unassigned> to <CT>
  def parser() do
    ignore(string(" switched from team "))
    |> concat(Parser.TeamTag.parser())
    |> ignore(string(" to "))
    |> concat(Parser.TeamTag.parser())
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([from, to]) do
    %Events.PlayerSwitchedTeam{from: from, to: to}
  end
end
