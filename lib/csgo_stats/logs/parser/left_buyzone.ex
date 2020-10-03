defmodule CsgoStats.Logs.Parser.LeftBuyzone do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: "Fred<27><BOT><CT>" left buyzone with [ weapon_knife weapon_hkp2000 weapon_scar20 weapon_hegrenade ]
  def parser() do
    ignore(string(" left buyzone with [ "))
    |> concat(items())
    |> ignore(string("]"))
    |> reduce({__MODULE__, :cast, []})
  end

  defp items() do
    item()
    |> ignore(string(" "))
    |> repeat()
  end

  # unhandled
  # C4
  # defuser
  # helmet
  defp item() do
    choice([
      weapon(),
      kevlar(),
      string("C4"),
      string("defuser"),
      string("helmet")
    ])
  end

  defp weapon() do
    ignore(string("weapon_"))
    |> concat(Parser.Weapon.weapon_name())
    |> reduce({__MODULE__, :cast_weapon, []})
  end

  defp kevlar() do
    ignore(string("kevlar"))
    |> ignore(string("("))
    |> integer(min: 1)
    |> ignore(string(")"))
    |> reduce({__MODULE__, :cast_kevlar, []})
  end

  def cast(items) do
    Enum.reduce(
      items,
      %Events.LeftBuyzone{weapons: [], defuser: false, c4: false, helmet: false, kevlar: 0},
      fn
        {:weapon, weapon}, acc -> %{acc | weapons: acc.weapons ++ [weapon]}
        {:kevlar, hitpoints}, acc -> %{acc | kevlar: hitpoints}
        "C4", acc -> %{acc | c4: true}
        "defuser", acc -> %{acc | defuser: true}
        "helmet", acc -> %{acc | helmet: true}
      end
    )
  end

  def cast_weapon([weapon]) do
    {:weapon, weapon}
  end

  def cast_kevlar([hitpoints]) do
    {:kevlar, hitpoints}
  end
end
