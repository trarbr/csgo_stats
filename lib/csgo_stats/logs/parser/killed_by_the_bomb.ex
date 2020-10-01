defmodule CsgoStats.Logs.Parser.KilledByTheBomb do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: "Graham<14><BOT><TERRORIST>" [1494 792 204] was killed by the bomb.
  def parser() do
    ignore(string(" "))
    |> ignore(Parser.Position.parser())
    |> ignore(string(" was killed by the bomb."))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([]) do
    %Events.KilledByTheBomb{}
  end
end
