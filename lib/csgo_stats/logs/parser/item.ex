defmodule CsgoStats.Logs.Parser.Item do
  import NimbleParsec

  alias CsgoStats.Types

  # Example: "defuser"
  def parser() do
    ignore(string(~s/"/))
    |> choice([
      string("c4"),
      string("defuser"),
      string("vesthelm"),
      string("vest")
    ])
    |> ignore(string(~s/"/))
    |> reduce({__MODULE__, :cast, []})
  end

  # Example: item_defuser
  def prefixed() do
    ignore(string(~s/"item_/))
    |> choice([
      string("defuser"),
      string("kevlar"),
      string("assaultsuit")
    ])
    |> ignore(string(~s/"/))
    |> reduce({__MODULE__, :cast, []})
  end

  Enum.each(Types.items(), fn
    :c4 -> defp cast_item("c4"), do: :c4
    :defuser -> defp cast_item("defuser"), do: :defuser
    :vest -> defp cast_item(item) when item in ["vest", "kevlar"], do: :vest
    :vesthelm -> defp cast_item(item) when item in ["vesthelm", "assaultsuit"], do: :vesthelm
  end)

  def cast([item]) do
    cast_item(item)
  end
end
