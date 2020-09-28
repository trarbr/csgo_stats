defmodule CsgoStats.Logs.Parser.MoneyChange do
  import NimbleParsec

  alias CsgoStats.Events

  # Example: "Uri<8><BOT><CT>" money change 3000-2000 = $1000 (tracked) (purchase: weapon_xm1014)
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
      |> concat(item())
      |> ignore(string(")"))
    )
    |> reduce({__MODULE__, :cast, []})
  end

  defp item() do
    ascii_string([?a..?z, ?0..?9, ?_], min: 1)
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

  # TODO: atomize purchase
  def cast([previous, sign, diff_absolute, result, purchase]) do
    event = cast([previous, sign, diff_absolute, result])
    %{event | purchase: purchase}
  end
end
