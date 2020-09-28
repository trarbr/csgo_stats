defmodule CsgoStats.Logs.Parser.Timestamp do
  import NimbleParsec

  # Example: 11/24/2019 - 21:43:39.781
  def parser() do
    date()
    |> ignore(string(" - "))
    |> concat(time())
    |> reduce({__MODULE__, :cast, []})
  end

  # Example: 11/24/2019
  defp date() do
    integer(2)
    |> ignore(string("/"))
    |> integer(2)
    |> ignore(string("/"))
    |> integer(4)
  end

  # Example: 21:43:39.781
  defp time() do
    integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string("."))
    |> integer(3)
  end

  def cast([month, day, year, hour, minute, second, millisecond]) do
    case NaiveDateTime.new(year, month, day, hour, minute, second, {millisecond * 1000, 3}) do
      {:ok, datetime} -> datetime
      {:error, _error} -> nil
    end
  end
end
