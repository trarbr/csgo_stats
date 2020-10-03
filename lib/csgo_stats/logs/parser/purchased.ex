defmodule CsgoStats.Logs.Parser.Purchased do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # Example: "Ryan<13><BOT><TERRORIST>" purchased "negev"
  def parser() do
    ignore(string(" purchased "))
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
      ignore(string("item_"))
      |> choice([
        string("kevlar"),
        string("assaultsuit")
      ])
    ])
    |> ignore(string(~s/"/))
    |> reduce({__MODULE__, :cast_item, []})
  end

  def cast_item([item]) do
    case item do
      "defuser" -> :defuser
      "assaultsuit" -> :vesthelm
      "kevlar" -> :vest
    end
  end

  def cast([item]) do
    %Events.Purchased{item: item}
  end
end
