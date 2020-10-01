defmodule CsgoStats.Logs.Parser.GotTheBomb do
  import NimbleParsec

  alias CsgoStats.Events

  # Example: "tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>" triggered "Got_The_Bomb"
  def parser() do
    ignore(string(~s/ triggered "Got_The_Bomb"/))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([]) do
    %Events.GotTheBomb{}
  end
end
