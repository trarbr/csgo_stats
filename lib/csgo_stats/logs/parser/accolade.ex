defmodule CsgoStats.Logs.Parser.Accolade do
  import NimbleParsec

  alias CsgoStats.Events
  alias CsgoStats.Logs.Parser

  # ACCOLADE, FINAL: {3k},	Neil<8>,	VALUE: 1.000000,	POS: 2,	SCORE: 20.000002
  def parser() do
    ignore(string("ACCOLADE, FINAL: {"))
    |> concat(award())
    |> ignore(string("},\t"))
    |> concat(Parser.Username.parser())
    |> concat(Parser.UserTag.parser())
    |> ignore(string(",\tVALUE: "))
    |> ascii_string([?0..?9, ?.], min: 1)
    |> ignore(string(",\tPOS: "))
    |> integer(min: 1)
    |> ignore(string(",\tSCORE: "))
    |> ascii_string([?0..?9, ?.], min: 1)
    |> reduce({__MODULE__, :cast, []})
  end

  # Example: "3k"
  defp award() do
    choice([
      string("3k"),
      string("hsp"),
      string("firstkills"),
      string("cashspent"),
      string("deaths"),
      string("mvps"),
      string("assists")
    ])
  end

  def cast([award, player, _tag, value, position, score]) do
    award =
      case award do
        "3k" -> :"3k"
        "hsp" -> :hsp
        "firstkills" -> :firstkills
        "cashspent" -> :cashspent
        "deaths" -> :deaths
        "mvps" -> :mvps
        "assists" -> :assists
      end

    %Events.Accolade{
      award: award,
      player: %{username: player},
      value: String.to_float(value),
      position: position,
      score: String.to_float(score)
    }
  end
end
