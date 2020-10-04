defmodule CsgoStats.Logs.Parser.Dropped do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: "Wesley<16><BOT><TERRORIST>" dropped "glock"
  def parser() do
    ignore(string(" dropped "))
    |> choice([
      Parser.Weapon.parser(),
      item()
    ])
    |> reduce({__MODULE__, :cast, []})
  end

  defp item() do
    ignore(string(~s/"/))
    |> choice([
      string("defuser"),
      string("vesthelm"),
      string("vest")
    ])
    |> ignore(string(~s/"/))
    |> reduce({__MODULE__, :cast_item, []})
  end

  def cast_item([item]) do
    case item do
      "defuser" -> :defuser
      "vesthelm" -> :vesthelm
      "vest" -> :vest
    end
  end

  def cast([item]) do
    %Events.Dropped{item: item}
  end
end
