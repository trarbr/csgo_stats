defmodule CsgoStats.Logs.Parser.UserTag do
  import NimbleParsec

  # Example: <14>
  def parser() do
    ignore(string("<"))
    |> integer(min: 1)
    |> ignore(string(">"))
  end
end
