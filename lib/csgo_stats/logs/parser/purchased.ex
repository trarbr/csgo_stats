defmodule CsgoStats.Logs.Parser.Purchased do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: "Ryan<13><BOT><TERRORIST>" purchased "negev"
  def parser() do
    ignore(string(" purchased "))
    |> choice([
      Parser.Weapon.parser(),
      Parser.Item.prefixed()
    ])
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([item]) do
    %Events.Purchased{item: item}
  end
end
