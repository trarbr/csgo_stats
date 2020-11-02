defmodule CsgoStats.Logs.Parser.ThrewGrenade do
  import NimbleParsec

  alias CsgoStats.{Events, Types}

  @grenades Enum.map(Types.grenades(), fn grenade ->
              string(to_string(grenade))
            end)

  # Example: "Ryan<13><BOT><TERRORIST>" threw flashbang [1333 376 179] flashbang entindex 239)
  def parser() do
    ignore(string(" threw "))
    |> choice(@grenades)
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([item]) do
    item = String.to_existing_atom(item)
    %Events.ThrewGrenade{item: item}
  end
end
