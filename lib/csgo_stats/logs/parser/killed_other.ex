defmodule CsgoStats.Logs.Parser.KilledOther do
  import NimbleParsec

  alias CsgoStats.{Events, Types}
  alias CsgoStats.Logs.Parser

  @killables Enum.map(Types.killables(), fn killable ->
               string(to_string(killable))
             end)

  # Example: "tbroedsgaard<12><STEAM_1:1:42376214><TERRORIST>" [849 2387 143] killed other "chicken<159>" [814 2555 138] with "awp"
  def parser() do
    ignore(string(" "))
    |> ignore(Parser.Position.parser())
    |> ignore(string(~s/ killed other "/))
    |> choice(@killables)
    |> ignore(ascii_string([?0..?9, ?<, ?>, ?"], min: 1))
    |> ignore(string(" "))
    |> ignore(Parser.Position.parser())
    |> ignore(string(" with "))
    |> concat(Parser.Weapon.parser())
    |> optional(choice([string(" (headshot)"), string(" (penetrated)")]))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([killed, weapon]) do
    killed = String.to_existing_atom(killed)

    %Events.KilledOther{
      killed: killed,
      weapon: weapon,
      headshot: false,
      penetrated: false
    }
  end

  def cast([killed, weapon, extra]) do
    event = cast([killed, weapon])

    # TODO: Handle headshots that penetrated
    case extra do
      " (headshot)" -> %{event | headshot: true}
      " (penetrated)" -> %{event | penetrated: true}
    end
  end
end
