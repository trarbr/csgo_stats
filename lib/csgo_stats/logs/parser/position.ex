defmodule CsgoStats.Logs.Parser.Position do
  import NimbleParsec

  # Example: [849 2387 143]
  def parser() do
    ignore(string("["))
    |> ascii_string([?0..?9, ?-], min: 1)
    |> ignore(string(" "))
    |> ascii_string([?0..?9, ?-], min: 1)
    |> ignore(string(" "))
    |> ascii_string([?0..?9, ?-], min: 1)
    |> ignore(string("]"))
  end
end
