defmodule CsgoStats.Logs.Parser.BeganBombDefuse do
  import NimbleParsec

  alias CsgoStats.Events

  # Example: "Clarence<17><BOT><CT>" triggered "Begin_Bomb_Defuse_With_Kit"
  def parser() do
    ignore(string(~s/ triggered "/))
    |> choice([
      string("Begin_Bomb_Defuse_With_Kit"),
      string("Begin_Bomb_Defuse_Without_Kit")
    ])
    |> ignore(string(~s/"/))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast(["Begin_Bomb_Defuse_With_Kit"]) do
    %Events.BeganBombDefuse{kit: true}
  end

  def cast(["Begin_Bomb_Defuse_Without_Kit"]) do
    %Events.BeganBombDefuse{kit: false}
  end
end
