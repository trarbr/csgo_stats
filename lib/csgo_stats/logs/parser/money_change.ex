defmodule CsgoStats.Logs.Parser.MoneyChange do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  def parser() do
    ignore(string(" money change "))
    |> integer(min: 1)
    |> choice([
      string("+"),
      string("-")
    ])
    |> integer(min: 1)
    |> ignore(string(" = $"))
    |> integer(min: 1)
    |> ignore(string(" (tracked)"))
    |> optional(
      ignore(string(" (purchase: "))
      |> choice([
        Parser.Weapon.prefixed(),
        Parser.Item.prefixed()
      ])
      |> ignore(string(")"))
    )
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([previous, sign, diff_absolute, result]) do
    diff =
      case sign do
        "-" -> -diff_absolute
        "+" -> diff_absolute
      end

    %Events.MoneyChange{
      previous: previous,
      diff: diff,
      result: result
    }
  end

  def cast([previous, sign, diff_absolute, result, purchase]) do
    event = cast([previous, sign, diff_absolute, result])
    %{event | purchase: purchase}
  end
end
