defmodule CsgoStats.Logs.Parser.DefusedTheBomb do
  import NimbleParsec

  alias CsgoStats.Events

  # Example: "Elmer<18><BOT><CT>" triggered "Defused_The_Bomb"
  def parser() do
    ignore(string(~s/ triggered "Defused_The_Bomb"/))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([]) do
    %Events.DefusedTheBomb{}
  end
end
