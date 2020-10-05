defmodule CsgoStats.Logs.Parser.Dropped do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: "Wesley<16><BOT><TERRORIST>" dropped "glock"
  def parser() do
    ignore(string(" dropped "))
    |> choice([
      Parser.Weapon.parser(),
      Parser.Item.parser()
    ])
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([item]) do
    %Events.Dropped{item: item}
  end
end
