defmodule CsgoStats.Logs.Parser.Team do
  import NimbleParsec

  # Example: CT
  def parser() do
    choice([string("CT"), string("TERRORIST"), string("T"), string("Unassigned")])
    |> reduce({__MODULE__, :cast, []})
  end

  def cast([team]) do
    case team do
      "CT" -> :ct
      "TERRORIST" -> :terrorist
      "T" -> :terrorist
      "Unassigned" -> nil
    end
  end
end
