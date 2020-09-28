defmodule CsgoStats.Logs.Parser.PlayerEnteredTheGame do
  import NimbleParsec

  alias CsgoStats.Events

  # Example: "Uri<13><BOT><>" entered the game
  def parser() do
    ignore(string(" entered the game"))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([]) do
    %Events.PlayerEnteredTheGame{}
  end
end
