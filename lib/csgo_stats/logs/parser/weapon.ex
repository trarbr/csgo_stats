defmodule CsgoStats.Logs.Parser.Weapon do
  import NimbleParsec

  # Example: "glock"
  # TODO: atomize
  def parser() do
    ignore(string(~s/"/))
    |> ascii_string([?a..?z, ?0..?9, ?_], min: 1)
    |> ignore(string(~s/"/))
  end
end
