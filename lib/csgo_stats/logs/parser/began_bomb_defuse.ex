defmodule CsgoStats.Logs.Parser.BeganBombDefuse do
  import NimbleParsec

  alias CsgoStats.Events

  # Example: "Clarence<17><BOT><CT>" triggered "Begin_Bomb_Defuse_With_Kit"
  def parser() do
    ignore(string(~s/ triggered "/))
    |> string("Begin_Bomb_Defuse_With_Kit")
    |> ignore(string(~s/"/))
    |> reduce({__MODULE__, :cast, []})
  end

  # TODO: Handle Without_Kit
  def cast(["Begin_Bomb_Defuse_With_Kit"]) do
    %Events.BeganBombDefuse{kit: true}
  end
end
