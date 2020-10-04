defmodule CsgoStats.Logs.Parser.ThrewGrenade do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: "Ryan<13><BOT><TERRORIST>" threw flashbang [1333 376 179] flashbang entindex 239)
  def parser() do
    ignore(string(" threw "))
    |> concat(Parser.Weapon.grenade_name())
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([item]) do
    %Events.ThrewGrenade{item: item}
  end
end
