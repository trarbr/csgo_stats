defmodule CsgoStats.Logs.Parser.Attacked do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: "Niles<16><BOT><TERRORIST>" [123 616 72] attacked "Elmer<18><BOT><CT>" [932 550 88] with "glock" (damage "17") (damage_armor "0") (health "83") (armor "100") (hitgroup "right leg")
  def parser() do
    ignore(string(" "))
    |> ignore(Parser.Position.parser())
    |> ignore(string(" attacked "))
    |> concat(Parser.Player.parser())
    |> ignore(string(" "))
    |> ignore(Parser.Position.parser())
    |> ignore(string(" with "))
    |> concat(Parser.Weapon.parser())
    |> ignore(string(" "))
    |> concat(stat())
    |> ignore(string(" "))
    |> concat(stat())
    |> ignore(string(" "))
    |> concat(stat())
    |> ignore(string(" "))
    |> concat(stat())
    |> ignore(string(" "))
    |> concat(hitgroup())
    |> reduce({__MODULE__, :cast, []})
  end

  # Example: (hitgroup "right leg")
  # TODO: atomize
  defp hitgroup() do
    ignore(string(~s/(hitgroup "/))
    |> ascii_string([?a..?z, ?\s], min: 1)
    |> ignore(string(~s/")/))
  end

  # Example: (damage_armor "32")
  defp stat() do
    ignore(
      choice([
        string(~s/(damage_armor "/),
        string(~s/(damage "/),
        string(~s/(health "/),
        string(~s/(armor "/)
      ])
    )
    |> integer(min: 1)
    |> ignore(string(~s/")/))
  end

  def cast([
        attacked,
        weapon,
        damage,
        damage_armor,
        health,
        armor,
        hitgroup
      ]) do
    %Events.Attacked{
      attacked: attacked,
      weapon: weapon,
      damage: damage,
      damage_armor: damage_armor,
      health: health,
      armor: armor,
      hitgroup: hitgroup
    }
  end
end
