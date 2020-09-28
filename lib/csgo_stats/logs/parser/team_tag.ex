defmodule CsgoStats.Logs.Parser.TeamTag do
  import NimbleParsec

  alias CsgoStats.Logs.Parser

  # Example: <CT>
  def parser() do
    ignore(string("<"))
    |> concat(optional(Parser.Team.parser()))
    |> ignore(string(">"))
  end
end
