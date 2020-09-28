defmodule CsgoStats.Logs.Parser.Killed do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: "Niles<16><BOT><TERRORIST>" [418 570 87] killed "Elmer<18><BOT><CT>" [944 538 152] with "glock"
  def parser() do
    ignore(string(" "))
    |> ignore(Parser.Position.parser())
    |> ignore(string(" killed "))
    |> concat(Parser.Player.parser())
    |> ignore(string(" "))
    |> ignore(Parser.Position.parser())
    |> ignore(string(" with "))
    |> concat(Parser.Weapon.parser())
    |> optional(choice([string(" (headshot)"), string(" (penetrated)")]))
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([killed, weapon]) do
    %Events.Killed{
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
