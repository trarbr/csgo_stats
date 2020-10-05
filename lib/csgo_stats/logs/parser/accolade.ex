defmodule CsgoStats.Logs.Parser.Accolade do
  import NimbleParsec

  alias CsgoStats.{Events, Types}
  alias CsgoStats.Logs.Parser

  @awards Enum.map(Types.awards(), fn award ->
            string(to_string(award))
          end)

  # ACCOLADE, FINAL: {3k},	Neil<8>,	VALUE: 1.000000,	POS: 2,	SCORE: 20.000002
  def parser() do
    ignore(string("ACCOLADE, FINAL: {"))
    |> choice(@awards)
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

  def cast([award, player, _tag, value, position, score]) do
    award = String.to_existing_atom(award)

    %Events.Accolade{
      award: award,
      player: %{username: player},
      value: String.to_float(value),
      position: position,
      score: String.to_float(score)
    }
  end
end
