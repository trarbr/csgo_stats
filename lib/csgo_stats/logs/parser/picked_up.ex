defmodule CsgoStats.Logs.Parser.PickedUp do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: "George<21><BOT><CT>" picked up "hkp2000"
  def parser() do
    ignore(string(" picked up "))
    |> choice([
      Parser.Weapon.parser(),
      Parser.Item.parser()
    ])
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([item]) do
    %Events.PickedUp{item: item}
  end
end
